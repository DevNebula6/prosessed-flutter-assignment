import 'package:flutter/material.dart';

abstract final class AppColors {
  static const seed = Color(0xFF059669);

  // Fixed accents that read well on both light and dark surfaces.
  static const discount = Color(0xFFC2410C);
  static const rating = Color(0xFFF59E0B);

  /// Amber for "only a few left", dark enough for text in either theme.
  static Color lowStock(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFFFBBF24)
        : const Color(0xFFB45309);
  }
}
