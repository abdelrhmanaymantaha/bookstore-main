import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CTextTheme {
  CTextTheme._();

  static TextTheme lightTextTheme = const TextTheme().copyWith(
    headlineLarge: GoogleFonts.openSans().copyWith(
      fontSize: 24.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),
    headlineMedium: GoogleFonts.openSans().copyWith(
      fontSize: 22.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),
    titleLarge: GoogleFonts.openSans().copyWith(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),
    titleMedium: GoogleFonts.openSans().copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),
    titleSmall: GoogleFonts.openSans().copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),
    bodyMedium: GoogleFonts.openSans().copyWith(
      fontSize: 16.sp,
      color: AppColors.textColor,
    ),
    bodySmall: GoogleFonts.openSans().copyWith(
      fontSize: 14.sp,
      color: AppColors.textColor,
    ),
    displaySmall: GoogleFonts.openSans().copyWith(
      fontSize: 11.sp,
      fontWeight: FontWeight.w300,
      color: AppColors.textColor,
    ),
    labelSmall: GoogleFonts.openSans().copyWith(
      fontSize: 11.sp,
      color: AppColors.textColor,
    ),
  );
}
