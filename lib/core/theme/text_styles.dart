import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyText = GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static TextStyle numberMetric = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
}
