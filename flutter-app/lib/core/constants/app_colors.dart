import 'package:flutter/material.dart';

class AppColors {
  // Primary brand
  static const amber = Color(0xFFFFCC00);
  static const yellow = amber;

  // Semantic
  static const danger  = Color(0xFFE53935);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);

  // Surfaces (with alpha for glass-card feel)
  static const background = Color(0xFF0A0A1E);
  static const surface0   = Color(0xCC0A0A1E); // 80% — dialogs (cool)
  static const surface1   = Color(0x991A1A4E); // 60% — cards
  static const surface2   = Color(0x661A1A4E); // 40% — HUD badges

  // Warm dialog surface (amber-tinted for night backdrop)
  static const dialogSurface = Color(0xE6100D00); // near-black warm at 90%

  // Text — use these, not Flutter named Colors.whiteXX
  static const textPrimary   = Color(0xFFFFFFFF); // white
  static const textSecondary = Color(0xB3FFFFFF); // 70% — labels, values
  static const textMuted     = Color(0x80FFFFFF); // 50% — hints, secondary
  static const divider       = Color(0x1FFFFFFF); // 12% — borders, separators

  // Legacy aliases (kept for backward compat)
  static const backgroundMid = Color(0xFF0D1040);
  static const backgroundEnd = Color(0xFF151540);
  static const cardDark      = Color(0xFF1A1A4E);
  static const cardDarker    = Color(0xFF15153A);
  static const cardDeep      = Color(0xFF1A1A50);
}
