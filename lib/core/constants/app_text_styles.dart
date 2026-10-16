import 'package:flutter/material.dart';

import 'app_colors.dart';

/// AppTextStyles defines the typographic scale for Sthitaprajna.
/// Characterized by tight letter-spacing for headers, generous line-heights
/// for readability, and monospace styling for indices and temporal tracking.
abstract class AppTextStyles {
  // Brand & High-Status Headers
  static const TextStyle brandHeader = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 3.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle subhead = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: AppColors.textSecondary,
  );

  // Body & Reading
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textMuted,
  );

  // Verbatim Script & Tactical Quotations
  static const TextStyle scriptVerbatim = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    height: 1.55,
    color: AppColors.textPrimary,
  );

  // Tactical Labels & Metadata Badges
  static const TextStyle labelBadge = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // Numeric Monospace Metrics
  static const TextStyle metricLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    fontFamily: 'monospace',
    letterSpacing: -1.0,
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
