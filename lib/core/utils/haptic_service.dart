import 'package:flutter/services.dart';

/// HapticService provides sensory feedback to reinforce psychological
/// anchoring and tactile confirmation during acute stress states.
class HapticService {
  HapticService._();

  /// Triggered on SOS Shield activation or boundary lock
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Triggered on transition between breathing cycles (Inhale -> Hold -> Exhale)
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Triggered on slider adjustments, micro-interactions, copy actions
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Triggered on category tab selection or card expansion
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Tactile double-tap pulse to anchor breathing transition
  static Future<void> breathingStepPulse() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 70));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Triggered on successful save, drill completion, or journal commit
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }
}
