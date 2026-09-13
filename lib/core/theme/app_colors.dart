import 'package:flutter/material.dart';

/// Raw color tokens — source of truth, sesuai design.md section 2.
/// Dipakai langsung di widget yang butuh warna spesifik (StatusBadge, dll)
/// ATAU lewat ColorScheme di AppTheme untuk widget Material standar.
class AppColors {
  AppColors._(); // no instance

  // Neutral / brand
  static const richBlack = Color(0xFF0A1128);
  static const deepNavy = Color(0xFF001F54);
  static const royalBlue = Color(0xFF034078);
  static const tealBlue = Color(0xFF1282A2);
  static const offWhite = Color(0xFFFEFCFB);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFE63946);

  // Tint variants (~10-12% opacity) — dipakai buat background badge/pill
  // dan highlight card (item hilang, row verifikasi, dll)
  static Color get successTint => success.withValues(alpha: 0.12);
  static Color get warningTint => warning.withValues(alpha: 0.12);
  static Color get dangerTint => danger.withValues(alpha: 0.12);

  // Text secondary — richBlack 60% sesuai design.md
  static Color get textSecondary => richBlack.withValues(alpha: 0.6);

  // Border subtle — richBlack 8-10% sesuai design.md
  static Color get borderSubtle => richBlack.withValues(alpha: 0.08);
}