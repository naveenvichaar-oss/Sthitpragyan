import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';

/// VideoReflectionDrillModal provides a 60-second camera composure review.
/// Designed for inspecting physical poise, jaw tension, and eye stillness.
/// Features a prominent shutter record button (🔴), stop button (⏹️),
/// live countdown timer, and save/attach confirmation.
class VideoReflectionDrillModal extends StatefulWidget {
  final String? existingPath;

  const VideoReflectionDrillModal({super.key, this.existingPath});

  static Future<String?> show(BuildContext context, {String? existingPath}) {
    HapticService.selectionClick();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLarge),
        ),
      ),
      builder: (context) => VideoReflectionDrillModal(existingPath: existingPath),
    );
  }

  @override
  State<VideoReflectionDrillModal> createState() =>
      _VideoReflectionDrillModalState();
}

class _VideoReflectionDrillModalState extends State<VideoReflectionDrillModal> {
  List<CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0;
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isRecording = false;
  int _secondsRemaining = 60;
  Timer? _countdownTimer;
  String? _recordedFilePath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _recordedFilePath = widget.existingPath;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'No camera found on this device.';
          });
        }
        return;
      }

      _availableCameras = cameras;

      // Prioritize front-facing lens for composure self-audit
      int frontIndex = 0;
      for (int i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == CameraLensDirection.front) {
          frontIndex = i;
          break;
        }
      }
      _currentCameraIndex = frontIndex;

      await _setupController(_availableCameras[_currentCameraIndex]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Camera initialization error: $e. You can still log text and audio.';
        });
      }
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    await _cameraController?.dispose();

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    await controller.initialize();

    if (mounted) {
      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (_availableCameras.length < 2 || _isRecording) return;
    HapticService.selectionClick();
    setState(() {
      _isCameraReady = false;
      _currentCameraIndex = (_currentCameraIndex + 1) % _availableCameras.length;
    });
    await _setupController(_availableCameras[_currentCameraIndex]);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  /// Start Recording (रिकॉर्ड शुरू करें)
  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    HapticService.heavyImpact();
    setState(() {
      _errorMessage = null;
      _secondsRemaining = 60;
      _recordedFilePath = null;
    });

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });

      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining <= 0) {
          _stopRecording();
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start video recording: $e';
        _isRecording = false;
      });
    }
  }

  /// Stop Recording (रिकॉर्ड रोकें)
  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;

    HapticService.heavyImpact();
    _countdownTimer?.cancel();

    try {
      final xfile = await _cameraController!.stopVideoRecording();

      String savedPath = xfile.path;
      if (!kIsWeb) {
        final docsDir = await getApplicationDocumentsDirectory();
        final videosDir = Directory('${docsDir.path}/video_reflections');
        if (!await videosDir.exists()) {
          await videosDir.create(recursive: true);
        }
        final dest =
            '${videosDir.path}/composure_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final savedFile = await File(xfile.path).copy(dest);
        savedPath = savedFile.path;
      }

      setState(() {
        _isRecording = false;
        _recordedFilePath = savedPath;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving video: $e';
        _isRecording = false;
      });
    }
  }

  /// Discard and Retake (पुनः रिकॉर्ड करें)
  void _discard() {
    HapticService.selectionClick();
    setState(() {
      _recordedFilePath = null;
      _secondsRemaining = 60;
    });
  }

  /// Save & Attach Video (वीडियो सहेजें)
  void _attachAndClose() {
    HapticService.heavyImpact();
    Navigator.of(context).pop(_recordedFilePath);
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.loc.isHindi;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        padding: const EdgeInsets.fromLTRB(
          AppDimens.space16,
          AppDimens.space12,
          AppDimens.space16,
          AppDimens.space16,
        ),
        child: Column(
          children: [
            // 1. Top Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 2. Header Bar
            _buildHeader(isHindi),
            const SizedBox(height: 8),

            // 3. Composure Directive Banner
            _buildDirectiveBanner(isHindi),
            const SizedBox(height: 10),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.amberWarning.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 11, color: AppColors.amberWarning),
                ),
              ),

            // 4. Camera Viewfinder Area (Expanded)
            Expanded(
              child: _buildCameraViewfinder(isHindi),
            ),
            const SizedBox(height: 14),

            // 5. Dedicated Control Panel (Always Visible at bottom)
            _buildBottomControlPanel(isHindi),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header Bar
  // ---------------------------------------------------------------------------
  Widget _buildHeader(bool isHindi) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.roseDanger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.roseDanger.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.videocam_rounded,
                size: 16,
                color: AppColors.roseDanger,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.sixtySecComposureBadge,
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.roseDanger,
                    letterSpacing: 1.5,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  context.loc.physicalComposureDrill,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
          onPressed: () => Navigator.of(context).pop(),
          visualDensity: VisualDensity.compact,
          tooltip: context.loc.closeTooltip,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Directive Banner
  // ---------------------------------------------------------------------------
  Widget _buildDirectiveBanner(bool isHindi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.remove_red_eye_outlined,
            size: 14,
            color: AppColors.shieldPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.loc.videoDrillHoldFrameHint,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Camera Viewfinder Area
  // ---------------------------------------------------------------------------
  Widget _buildCameraViewfinder(bool isHindi) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraReady && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            Container(
              color: AppColors.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.shieldPrimary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.loc.initializingLens,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Flip Camera Button (Top Left)
          if (_availableCameras.length > 1 && !_isRecording)
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: _toggleCamera,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),

          // Top Right Status / Countdown Pill
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isRecording ? AppColors.roseDanger : AppColors.borderSubtle,
                  width: _isRecording ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? AppColors.roseDanger
                          : (_recordedFilePath != null
                              ? AppColors.emeraldSuccess
                              : AppColors.shieldPrimary),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isRecording
                        ? '00:${_secondsRemaining.toString().padLeft(2, '0')}'
                        : (_recordedFilePath != null ? 'DONE' : '60s CAP'),
                    style: const TextStyle(
                      fontFamily: 'Noto Sans Devanagari',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Live Subtext Anchor during recording
          if (_isRecording)
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.roseDanger.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_rounded, color: AppColors.roseDanger, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      context.loc.recordingActiveHoldFrame,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Dedicated Control Panel (Always Visible at bottom)
  // ---------------------------------------------------------------------------
  Widget _buildBottomControlPanel(bool isHindi) {
    // STATE 1: Recording Completed -> Show Retake & Save Buttons
    if (_recordedFilePath != null && !_isRecording) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.emeraldSuccess.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.emeraldSuccess.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.emeraldSuccess),
                const SizedBox(width: 6),
                Text(
                  context.loc.videoDrillSuccessNotice,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emeraldSuccess,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Retake Button (पुनः रिकॉर्ड करें)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _discard,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    context.loc.videoDrillRetake,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Save Video Button (वीडियो सहेजें)
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _attachAndClose,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                    context.loc.videoDrillSaveRecord,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldSuccess,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // STATE 2: Recording In Progress -> Big Red Stop Button (⏹️)
    if (_isRecording) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.roseDanger.withValues(alpha: 0.4),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.roseDanger,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.loc.videoDrillStopRecord,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.roseDanger,
            ),
          ),
          Text(
            context.loc.secondsRemainingBadge('00:${_secondsRemaining.toString().padLeft(2, '0')}'),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      );
    }

    // STATE 3: Idle -> Big Red Shutter Record Button (🔴)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _isCameraReady ? _startRecording : null,
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: _isCameraReady ? Colors.white : AppColors.borderSubtle,
                width: 3.5,
              ),
              boxShadow: _isCameraReady
                  ? [
                      BoxShadow(
                        color: AppColors.roseDanger.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isCameraReady ? AppColors.roseDanger : AppColors.surfaceElevated,
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.loc.videoDrillStartRecord,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          context.loc.videoDrillStartRecordSub,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
