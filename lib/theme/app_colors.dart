import 'package:flutter/material.dart';

class AppColors {
  // 主色调
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color primaryCyanDark = Color(0xFF00B8D4);
  static const Color accentPurple = Color(0xFFB388FF);
  static const Color accentPink = Color(0xFFFF4081);

  // 背景
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF141832);
  static const Color cardBackground = Color(0xFF1A1F3D);

  // 底部导航
  static const Color bottomNavBg = Color(0xFF0D1130);

  // 文字
  static const Color textPrimary = Color(0xFFE8EAFC);
  static const Color textSecondary = Color(0xFF7C84A6);
  static const Color textHint = Color(0xFF4E5578);

  // 功能色
  static const Color successGreen = Color(0xFF00E676);
  static const Color warningOrange = Color(0xFFFFAB40);
  static const Color errorRed = Color(0xFFFF5252);

  // 边框与发光
  static const Color borderGlow = Color(0xFF2A3058);
  static const Color cyanGlow = Color(0x4000E5FF);

  // 渐变
  static const List<Color> gradientCyanPurple = [
    Color(0xFF00E5FF),
    Color(0xFFB388FF),
  ];

  static const List<Color> gradientDark = [
    Color(0xFF0A0E21),
    Color(0xFF1A1F3D),
  ];

  // 电池色
  static const Color batteryHigh = Color(0xFF00E676);
  static const Color batteryMid = Color(0xFFFFAB40);
  static const Color batteryLow = Color(0xFFFF5252);

  // 波形色
  static const Color waveformCyan = Color(0xFF00E5FF);
  static const Color waveformPurple = Color(0xFFB388FF);
  static const Color waveformPink = Color(0xFFFF4081);
}
