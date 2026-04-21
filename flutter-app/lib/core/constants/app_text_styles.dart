import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const _gameFont = 'BlackHanSans';

  static const display = TextStyle(
    fontFamily: _gameFont,
    fontSize: 40,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
    color: Colors.white,
  );

  static const heading = TextStyle(
    fontFamily: _gameFont,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const title = TextStyle(
    fontFamily: _gameFont,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const button = TextStyle(
    fontFamily: _gameFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: Colors.white,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  static const caption = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const micro = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
  );
}
