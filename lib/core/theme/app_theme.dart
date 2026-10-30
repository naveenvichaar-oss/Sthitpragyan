import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// AppTheme enforces an uncompromising dark mode aesthetic.
/// Stripped of unnecessary shadows, frivolous rounded pill shapes, or bright saturated fills.
abstract class AppTheme {
  static ThemeData get darkTheme {
    final devanagariTextTheme = GoogleFonts.notoSansDevanagariTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.shieldPrimary,
      canvasColor: AppColors.surface,
      fontFamily: GoogleFonts.notoSansDevanagari().fontFamily,
      textTheme: devanagariTextTheme,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.shieldPrimary,
        onPrimary: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.roseDanger,
        onError: AppColors.textPrimary,
      ),

      // App Bar Theme: Ultra-flat, border-bottom only
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.brandHeader,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 20),
      ),

      // Card Theme: Muted Zinc surface with razor-thin border
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          side: const BorderSide(
            color: AppColors.borderSubtle,
            width: AppDimens.cardBorderWidth,
          ),
        ),
      ),

      // Slider Theme: Custom Minimalist Executive Track
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.shieldPrimary,
        inactiveTrackColor: AppColors.borderSubtle,
        thumbColor: AppColors.textPrimary,
        overlayColor: AppColors.shieldGlow,
        trackHeight: 3.0,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 8.0,
          elevation: 0,
          pressedElevation: 2,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
        valueIndicatorTextStyle: AppTextStyles.metricSmall.copyWith(
          color: AppColors.background,
        ),
        valueIndicatorColor: AppColors.textPrimary,
      ),

      // Input Decoration Theme: High-precision single-line styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.shieldPrimary,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          borderSide: const BorderSide(color: AppColors.roseDanger, width: 1.0),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // Dialog Theme for Sheets & Modals
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusLarge),
          ),
          side: BorderSide(color: AppColors.borderMedium, width: 1.0),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          side: const BorderSide(color: AppColors.borderMedium, width: 1.0),
        ),
        titleTextStyle: AppTextStyles.heading,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
    );
  }
}
