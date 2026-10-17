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

/// VideoReflectionDrillModal provides a 60-second front-camera composure review.
/// Designed for executives to inspect physical poise, jaw tension, and eye stillness.
class VideoReflectionDrillModal extends StatefulWidget {
  final String? existingPath;

  const VideoReflectionDrillModal({super.key, this.existingPath});

  static Future<String?> show(BuildContext context, {String? existingPath}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
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

      // Prioritize front camera for composure review
      CameraDescription chosenCamera = cameras.first;
      for (final cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.front) {
          chosenCamera = cam;
          break;
        }
      }

      final controller = CameraController(
        chosenCamera,
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Camera initialization error: $e. You can still log text and audio.';
        });
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

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

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;

    HapticService.selectionClick();
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

  void _discard() {
    HapticService.lightImpact();
    setState(() {
      _recordedFilePath = null;
      _secondsRemaining = 60;
    });
  }

  void _attachAndClose() {
    HapticService.selectionClick();
    Navigator.of(context).pop(_recordedFilePath);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.88,
      padding: const EdgeInsets.all(AppDimens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.videocam_outlined,
                      size: 16,
                      color: AppColors.shieldPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '60-SECOND COMPOSURE REVIEW',
                        style: AppTextStyles.labelBadge.copyWith(
                          color: AppColors.shieldPrimary,
                          letterSpacing: 1.5,
                          fontSize: 9.0,
                        ),
                      ),
                      Text(
                        context.loc.physicalComposureDrill,
                        style: const TextStyle(
                          fontSize: 14,
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
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Directive Banner
          Container(
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
                    'Direct eye contact • Unclenched jaw • Zero defensive posturing.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.amberWarning.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 11, color: AppColors.amberWarning),
              ),
            ),

          // Camera Preview Area
          Expanded(
            child: ClipRRect(
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
                              'Initializing front lens for composure review...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Countdown & Status Overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isRecording
                              ? AppColors.roseDanger
                              : AppColors.borderSubtle,
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
                                  : AppColors.emeraldSuccess,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isRecording ? '00:$_secondsRemaining' : '60s CAP',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlay Rule Card during recording
                  if (_isRecording)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HOLD FRAME: Tongue on roof of mouth. Smooth, slow breathing.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Control Bar
          if (_isRecording)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop_rounded, size: 18),
                label: const Text('STOP & REVIEW COMPOSURE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseDanger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          else if (_recordedFilePath != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _discard,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('RE-TAKE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.borderSubtle),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _attachAndClose,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('ATTACH VIDEO REFLECTION'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.shieldPrimary,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isCameraReady ? _startRecording : null,
                icon: const Icon(Icons.fiber_manual_record_rounded, size: 16),
                label: const Text('RECORD 60s COMPOSURE DRILL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceElevated,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.borderMedium),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
