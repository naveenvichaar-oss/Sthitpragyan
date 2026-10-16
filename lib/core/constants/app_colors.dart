import 'package:flutter/material.dart';

/// AppColors encapsulates the ultra-minimalist Slate/Zinc palette for Sthitaprajna.
/// Strictly dark mode only. Designed to reduce visual stimulation, promote cognitive
/// detachment, and deliver instantaneous contrast (<100ms render target).
abstract class AppColors {
  // Pure Dark Backgrounds (Zinc Palette)
  static const Color background = Color(0xFF09090B); // Zinc 950 (Deep Obsidian)
  static const Color surface = Color(0xFF141416); // Zinc 900+ (Card background)
  static const Color surfaceElevated = Color(
    0xFF202024,
  ); // Zinc 850 (Modals/Sheets)
  static const Color surfaceHover = Color(0xFF27272A); // Zinc 800 (Hover/Press)

  // Architectural Borders & Dividers
  static const Color borderSubtle = Color(0xFF27272A); // Zinc 800
  static const Color borderMedium = Color(0xFF3F3F46); // Zinc 700
  static const Color borderBright = Color(0xFF52525B); // Zinc 600

  // High-Contrast Minimalist Typography
  static const Color textPrimary = Color(
    0xFFF4F4F5,
  ); // Zinc 100 (Uncompromising clarity)
  static const Color textSecondary = Color(
    0xFFA1A1AA,
  ); // Zinc 400 (Executive context)
  static const Color textMuted = Color(
    0xFF71717A,
  ); // Zinc 500 (Subtle metadata)
  static const Color textDisabled = Color(0xFF52525B); // Zinc 600

  // Stoic Psychological Accents (Muted, Non-Distracting)
  static const Color shieldPrimary = Color(
    0xFF38BDF8,
  ); // Sky 400 (Cold clarity, composure)
  static const Color shieldGlow = Color(0x3338BDF8); // Sky 400 20% opacity
  static const Color shieldAccent = Color(0xFF0284C7); // Sky 600

  // Semantic Signals for Indices & Tactical Alerts
  static const Color emeraldSuccess = Color(
    0xFF10B981,
  ); // Emerald 500 (Boundary Retained)
  static const Color emeraldMuted = Color(0x1F10B981); // Emerald 12% fill
  static const Color amberWarning = Color(
    0xFFF59E0B,
  ); // Amber 500 (Caution/Friction)
  static const Color amberMuted = Color(0x1FF59E0B); // Amber 12% fill
  static const Color roseDanger = Color(
    0xFFF43F5E,
  ); // Rose 500 (Acute panic / hijack)
  static const Color roseMuted = Color(0x1FF43F5E); // Rose 12% fill
  static const Color redError = roseDanger; // Error alias

  // Breathing Pulse Gradient stops
  static const Color breathPulseOuter = Color(0x1538BDF8);
  static const Color breathPulseMiddle = Color(0x3538BDF8);
  static const Color breathPulseCore = Color(0xFF38BDF8);
}
