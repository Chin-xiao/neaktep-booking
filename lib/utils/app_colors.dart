import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3056D3);
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color divider = Color(0xFFE6E8EE);
  static const Color border = Color(0xFFE6E8EE);
  static const Color accent = Color(0xFFE45858);

  // Additional utilities
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color warning = Color(0xFFFFC107);

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3056D3), Color(0xFF5C7EFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BoxShadow softShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
  ];
}
