import 'package:flutter/material.dart';

BoxDecoration neumorphicDecoration(
    {required bool isDark, double radius = 16}) {
  final baseColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0);
  final shadowColorDark =
      isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade500;
  final shadowColorLight = isDark ? Colors.grey.shade800 : Colors.white;

  return BoxDecoration(
    color: baseColor,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: shadowColorDark,
        offset: const Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: shadowColorLight,
        offset: const Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  );
}
