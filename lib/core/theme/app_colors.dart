// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF409CFF);
  static const Color primaryDark = Color(0xFF0055B3);

  // Secondary Colors
  static const Color secondary = Color(0xFF5856D6);
  static const Color secondaryLight = Color(0xFF7A79E9);
  static const Color secondaryDark = Color(0xFF3634A3);

  // Background Colors
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textTertiary = Color(0xFF8E8E93);

  // Map Colors
  static const Color mapBorder = Color(0xFFE5E5EA);
  static const Color mapSelected = Color(0xFFFFD60A);
  static const Color mapMarker = Color(0xFFFF3B30);

  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF5856D6);

  // Region Colors for Map
  static const Map<String, Color> regionColors = {
    'GREATER ACCRA REGION': Color(0xFFFF9500),
    'ASHANTI REGION': Color(0xFF34C759),
    'CENTRAL REGION': Color(0xFF5856D6),
    'EASTERN REGION': Color(0xFFFF3B30),
    'WESTERN REGION': Color(0xFF007AFF),
    'VOLTA REGION': Color(0xFFAF52DE),
  };
}
