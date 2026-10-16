import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../data/services/media_vault_service.dart';

/// StealthPinDialog authenticates access to the isolated .hidden_vault repository.
/// Default PIN: 0000.
class StealthPinDialog extends StatefulWidget {
  final bool isChangePinMode;

  const StealthPinDialog({super.key, this.isChangePinMode = false});

  static Future<bool?> show(
    BuildContext context, {
    bool isChangePinMode = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => StealthPinDialog(isChangePinMode: isChangePinMode),
    );
  }

  @override
  State<StealthPinDialog> createState() => _StealthPinDialogState();
}

class _StealthPinDialogState extends State<StealthPinDialog> {
  final MediaVaultService _vaultService = MediaVaultService();
  String _enteredPin = '';
  String? _errorMessage;
  bool _isSuccess = false;

  void _onDigitPressed(String digit) {
    if (_enteredPin.length >= 4) return;

    HapticService.selectionClick();
    setState(() {
      _enteredPin += digit;
      _errorMessage = null;
    });

    if (_enteredPin.length == 4) {
      _verifyOrUpdatePin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    HapticService.lightImpact();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _verifyOrUpdatePin() async {
    if (widget.isChangePinMode) {
      await _vaultService.updateStealthPin(_enteredPin);
      HapticService.heavyImpact();
      setState(() => _isSuccess = true);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) Navigator.of(context).pop(true);
      });
      return;
    }

    final isValid = _vaultService.verifyStealthPin(_enteredPin);
    if (isValid) {
      HapticService.heavyImpact();
      setState(() => _isSuccess = true);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) Navigator.of(context).pop(true);
      });
    } else {
      HapticService.heavyImpact();
      setState(() {
        _errorMessage = 'Invalid PIN. (Default is 0000)';
        _enteredPin = '';
      });
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
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceElevated,
              border: Border.all(
                color: _isSuccess ? AppColors.emeraldSuccess : AppColors.amberWarning,
                width: 1.5,
              ),
            ),
            child: Icon(
              _isSuccess
                  ? Icons.lock_open_rounded
                  : (widget.isChangePinMode ? Icons.key_rounded : Icons.security_rounded),
              size: 22,
              color: _isSuccess ? AppColors.emeraldSuccess : AppColors.amberWarning,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.isChangePinMode ? 'SET NEW VAULT PIN' : 'STEALTH VAULT ACCESS',
            style: AppTextStyles.labelBadge.copyWith(
              color: _isSuccess ? AppColors.emeraldSuccess : AppColors.amberWarning,
              fontSize: 9.5,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.isChangePinMode
                ? 'Enter 4-digit code to update'
                : 'Enter 4-digit stealth PIN to unlock',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),

          // 4 PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < _enteredPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled
                      ? (_isSuccess ? AppColors.emeraldSuccess : AppColors.shieldPrimary)
                      : AppColors.surfaceElevated,
                  border: Border.all(
                    color: isFilled
                        ? (_isSuccess ? AppColors.emeraldSuccess : AppColors.shieldPrimary)
                        : AppColors.borderSubtle,
                    width: 1.5,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.roseDanger,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 14),

          // Tactile Number Pad
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _buildKeyRow(['1', '2', '3']),
                const SizedBox(height: 8),
                _buildKeyRow(['4', '5', '6']),
                const SizedBox(height: 8),
                _buildKeyRow(['7', '8', '9']),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 58),
                    const SizedBox(width: 12),
                    _buildKey('0'),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 58,
                      height: 46,
                      child: IconButton(
                        icon: const Icon(Icons.backspace_outlined, size: 18),
                        color: AppColors.textMuted,
                        onPressed: _onBackspace,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'DISMISS',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((d) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _buildKey(d),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String digit) {
    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 58,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
