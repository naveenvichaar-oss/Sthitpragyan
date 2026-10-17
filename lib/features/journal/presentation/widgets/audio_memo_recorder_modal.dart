import 'dart:async';
import 'dart:io';

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
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
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
    setState(() {
      _recordedFilePath = null;
      _recordDurationSeconds = 0;
    });
  }

  void _attachAndClose() {
    HapticService.selectionClick();
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
                  // Pulse Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? AppColors.roseDanger.withValues(alpha: 0.15)
                          : AppColors.surfaceElevated,
                      border: Border.all(
                        color: _isRecording
                            ? AppColors.roseDanger
                            : AppColors.borderMedium,
                        width: _isRecording ? 2.0 : 1.0,
                      ),
                    ),
                    child: Icon(
                      _isRecording
                          ? Icons.mic_rounded
                          : (_recordedFilePath != null
                              ? Icons.check_circle_rounded
                              : Icons.mic_none_rounded),
                      color: _isRecording
                          ? AppColors.roseDanger
                          : (_recordedFilePath != null
                              ? AppColors.emeraldSuccess
                              : AppColors.shieldPrimary),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Duration text
                  Text(
                    _isRecording
                        ? _formatDuration(_recordDurationSeconds)
                        : (_recordedFilePath != null
                            ? 'Audio memo captured'
                            : '00:00'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRecording
                        ? 'Recording discreet verbal audit...'
                        : (_recordedFilePath != null
                            ? 'Local file ready to attach'
                            : 'Tap record to capture verbal thoughts'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
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
                  label: const Text('STOP RECORDING'),
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
                      onPressed: _discardRecording,
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('DISCARD'),
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
                      label: const Text('ATTACH TO AUDIT'),
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
                  onPressed: _isInitialized ? _startRecording : null,
                  icon: const Icon(Icons.fiber_manual_record_rounded, size: 16),
                  label: const Text('START AUDIO MEMO'),
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
