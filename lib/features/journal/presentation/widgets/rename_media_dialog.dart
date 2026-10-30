import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/models/media_record_log.dart';
import '../../data/services/media_vault_service.dart';

/// RenameMediaDialog presents a dark minimalist modal dialog allowing
/// executives to customize display titles and storage filenames.
class RenameMediaDialog extends StatefulWidget {
  final MediaRecordLog record;

  const RenameMediaDialog({super.key, required this.record});

  static Future<MediaRecordLog?> show(
    BuildContext context, {
    required MediaRecordLog record,
  }) {
    return showDialog<MediaRecordLog>(
      context: context,
      barrierDismissible: true,
      builder: (context) => RenameMediaDialog(record: record),
    );
  }

  @override
  State<RenameMediaDialog> createState() => _RenameMediaDialogState();
}

class _RenameMediaDialogState extends State<RenameMediaDialog> {
  late final TextEditingController _controller;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.record.displayName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitRename() async {
    final newName = _controller.text.trim();
    if (newName.isEmpty) {
      setState(() {
        _errorMessage = 'File name cannot be empty.';
      });
      return;
    }

    if (newName == widget.record.displayName) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      HapticService.selectionClick();
      final updated = await MediaVaultService().renameMedia(
        id: widget.record.id,
        newDisplayName: newName,
      );

      if (mounted) {
        Navigator.of(context).pop(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.emeraldSuccess,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Renamed to "$newName"',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.surfaceElevated,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Rename failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        side: const BorderSide(color: AppColors.borderMedium),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.record.isAudio ? Icons.mic_rounded : Icons.videocam_rounded,
              size: 16,
              color: AppColors.shieldPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RENAME RECORDING',
                  style: AppTextStyles.labelBadge.copyWith(
                    color: AppColors.shieldPrimary,
                    fontSize: 9.0,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.record.isAudio ? 'Audio Memo' : 'Video Composure Drill',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Updates storage file name and offline catalog metadata.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 80,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter strategic title...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              counterStyle: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.shieldPrimary, width: 1.5),
              ),
            ),
            onSubmitted: (_) => _submitRename(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.roseDanger, fontSize: 11),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(context.loc.cancelButton, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submitRename,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.shieldPrimary,
            foregroundColor: AppColors.background,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                )
              : Text(context.loc.saveNameButton, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ],
    );
  }
}
