import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';

/// AudioMemoRecorderModal provides an ultra-discrete, zero-telemetry
/// voice memo recorder for immediate verbal reflection.
class AudioMemoRecorderModal extends StatefulWidget {
  final String? existingPath;

  const AudioMemoRecorderModal({super.key, this.existingPath});

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
      builder: (context) => AudioMemoRecorderModal(existingPath: existingPath),
    );
  }

  @override
  State<AudioMemoRecorderModal> createState() => _AudioMemoRecorderModalState();
}

class _AudioMemoRecorderModalState extends State<AudioMemoRecorderModal> {
  late final AudioRecorder _audioRecorder;
  AudioPlayer? _previewPlayer;
  bool _isPlayingPreview = false;
  bool _isRecording = false;
  int _recordDurationSeconds = 0;
  Timer? _timer;
  String? _recordedFilePath;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _recordedFilePath = widget.existingPath;
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          if (!hasPermission) {
            _errorMessage = 'Microphone permission not granted.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = 'Audio recorder not supported on this platform/device.';
        });
      }
    }
  }

  @override
  void dispose() {
    _previewPlayer?.dispose();
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _togglePreviewPlayback() async {
    final path = _recordedFilePath;
    if (path == null) return;
    HapticService.selectionClick();

    _previewPlayer ??= AudioPlayer();

    if (_isPlayingPreview) {
      await _previewPlayer!.stop();
      if (mounted) setState(() => _isPlayingPreview = false);
    } else {
      _previewPlayer!.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingPreview = false);
      });
      await _previewPlayer!.play(DeviceFileSource(path));
      if (mounted) setState(() => _isPlayingPreview = true);
    }
  }

  void _startTimer() {
    _recordDurationSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _recordDurationSeconds++;
      });
      // Safety cap at 3 minutes
      if (_recordDurationSeconds >= 180) {
        _stopRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    HapticService.heavyImpact();
    setState(() {
      _errorMessage = null;
    });

    try {
      if (_isPlayingPreview) {
        await _previewPlayer?.stop();
        _isPlayingPreview = false;
      }
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Microphone permission is required for voice memo.';
        });
        return;
      }

      String? targetPath;
      if (!kIsWeb) {
        final docsDir = await getApplicationDocumentsDirectory();
        final memosDir = Directory('${docsDir.path}/audio_memos');
        if (!await memosDir.exists()) {
          await memosDir.create(recursive: true);
        }
        targetPath =
            '${memosDir.path}/memo_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 44100,
      );

      await _audioRecorder.start(config, path: targetPath ?? '');

      setState(() {
        _isRecording = true;
        _recordedFilePath = null;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to start recording: $e';
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    HapticService.selectionClick();
    _timer?.cancel();

    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error stopping recording: $e';
        _isRecording = false;
      });
    }
  }

  void _discardRecording() {
    HapticService.lightImpact();
    _previewPlayer?.stop();
    setState(() {
      _isPlayingPreview = false;
      _recordedFilePath = null;
      _recordDurationSeconds = 0;
    });
  }

  void _attachAndClose() {
    HapticService.selectionClick();
    _previewPlayer?.stop();
    _isPlayingPreview = false;
    Navigator.of(context).pop(_recordedFilePath);
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Handle
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
            const SizedBox(height: 16),

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
                        Icons.mic_none_rounded,
                        size: 16,
                        color: AppColors.shieldPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRIVATE AUDIO MEMO',
                          style: AppTextStyles.labelBadge.copyWith(
                            color: AppColors.shieldPrimary,
                            letterSpacing: 1.5,
                            fontSize: 9.0,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          context.loc.oralAudioNote,
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
            Text(
              'Zero-cloud offline voice memo. Stored strictly in sandbox storage.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 20),

            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.amberWarning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.amberWarning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Recording Visualizer / Timer Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                border: Border.all(
                  color: _isRecording
                      ? AppColors.roseDanger.withValues(alpha: 0.4)
                      : AppColors.borderSubtle,
                ),
              ),
              child: Column(
                children: [
                  // Pulse Icon / Interactive Play Orb
                  GestureDetector(
                    onTap: (_recordedFilePath != null && !_isRecording)
                        ? _togglePreviewPlayback
                        : null,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording
                            ? AppColors.roseDanger.withValues(alpha: 0.15)
                            : (_recordedFilePath != null
                                ? (_isPlayingPreview
                                    ? AppColors.emeraldSuccess.withValues(alpha: 0.25)
                                    : AppColors.emeraldSuccess.withValues(alpha: 0.12))
                                : AppColors.surfaceElevated),
                        border: Border.all(
                          color: _isRecording
                              ? AppColors.roseDanger
                              : (_recordedFilePath != null
                                  ? AppColors.emeraldSuccess
                                  : AppColors.borderMedium),
                          width: (_isRecording || _isPlayingPreview) ? 2.5 : 1.5,
                        ),
                      ),
                      child: Icon(
                        _isRecording
                            ? Icons.mic_rounded
                            : (_recordedFilePath != null
                                ? (_isPlayingPreview
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded)
                                : Icons.mic_none_rounded),
                        color: _isRecording
                            ? AppColors.roseDanger
                            : (_recordedFilePath != null
                                ? AppColors.emeraldSuccess
                                : AppColors.shieldPrimary),
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Duration text
                  Text(
                    _isRecording
                        ? _formatDuration(_recordDurationSeconds)
                        : (_recordedFilePath != null
                            ? (_isPlayingPreview
                                ? context.loc.audioPlayingStatus
                                : context.loc.audioRecordingReady)
                            : '00:00'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRecording
                        ? context.loc.audioRecordingActivePrompt
                        : (_recordedFilePath != null
                            ? (_isPlayingPreview
                                ? context.loc.tapToPausePrompt
                                : context.loc.tapToListenPrompt)
                            : context.loc.tapRecordToCapturePrompt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _isPlayingPreview
                          ? AppColors.emeraldSuccess
                          : AppColors.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Controls
            if (_isRecording)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.stop_rounded, size: 18),
                  label: Text(context.loc.stopRecordingAction),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _togglePreviewPlayback,
                      icon: Icon(
                        _isPlayingPreview
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 20,
                        color: _isPlayingPreview
                            ? AppColors.amberWarning
                            : AppColors.emeraldSuccess,
                      ),
                      label: Text(
                        _isPlayingPreview
                            ? context.loc.pauseAudioAction
                            : context.loc.playAudioAction,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _isPlayingPreview
                              ? AppColors.amberWarning
                              : AppColors.emeraldSuccess,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: (_isPlayingPreview
                                  ? AppColors.amberWarning
                                  : AppColors.emeraldSuccess)
                              .withValues(alpha: 0.5),
                        ),
                        backgroundColor: (_isPlayingPreview
                                ? AppColors.amberWarning
                                : AppColors.emeraldSuccess)
                            .withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _discardRecording,
                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                          label: Text(context.loc.discardAction,
                              style: const TextStyle(fontSize: 11)),
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
                          label: Text(context.loc.attachAction,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
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
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isInitialized ? _startRecording : null,
                  icon: const Icon(Icons.fiber_manual_record_rounded, size: 16),
                  label: Text(context.loc.startAudioMemoAction),
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

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
