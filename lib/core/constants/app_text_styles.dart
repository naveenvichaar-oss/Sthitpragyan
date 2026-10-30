import 'package:flutter/material.dart';

import 'app_colors.dart';

/// AppTextStyles defines the typographic scale for Sthitaprajna.
/// Backed by Google Fonts "Noto Sans Devanagari" & "Poppins" for flawless
/// Devanagari rendering, fully preserving conjuncts (संयुक्ताक्षर) and upper/lower matras.
abstract class AppTextStyles {
  static const String devanagariFont = 'Noto Sans Devanagari';
  static const List<String> fontFallback = [
    'Noto Sans Devanagari',
    'Poppins',
    'sans-serif',
  ];

  // Brand & High-Status Headers
  static const TextStyle brandHeader = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: fontFallback,
    letterSpacing: 2.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: 26.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.0,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 21.0,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.0,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 16.5,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.0,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle subhead = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.0,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.0,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  // Body & Reading
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.1,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textMuted,
  );

  /// Alias for [bodyLarge] — use for general body copy in new screens.
  static const TextStyle body = bodyLarge;

  /// Alias for [bodySmall] — use for metadata, timestamps, and small labels.
  static const TextStyle caption = bodySmall;

  // Verbatim Script & Tactical Quotations
  static const TextStyle scriptVerbatim = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.1,
    height: 1.55,
    color: AppColors.textPrimary,
  );

  // Tactical Labels & Metadata Badges
  static const TextStyle labelBadge = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: fontFallback,
    letterSpacing: 1.2,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: fontFallback,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  // Numeric Monospace Metrics (Strictly Western Arabic Numerals)
  static const TextStyle metricLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    fontFamily: 'monospace',
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle metricMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    fontFamily: 'monospace',
    color: AppColors.textPrimary,
  );

  static const TextStyle metricSmall = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'monospace',
    color: AppColors.textSecondary,
  );
}

