import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const _font = 'Pretendard';

  static const display = TextStyle(
    fontFamily: _font,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: 2,
    color: Colors.white,
  );

  static const heading = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static const title = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const button = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const body = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static const caption = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const micro = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
