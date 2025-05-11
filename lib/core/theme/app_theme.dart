import 'package:flutter/material.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/core/theme/custom_themes/app_bar_theme.dart';
import 'package:bookstore_app/core/theme/custom_themes/text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData().copyWith(
    appBarTheme: CAppBarTheme.lightAppBarTheme,
    scaffoldBackgroundColor: AppColors.secondaryColor,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionHandleColor: Colors.blue,
      selectionColor: Colors.lightBlue.withOpacity(0.3),
    ),
    textTheme: CTextTheme.lightTextTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: Colors.grey[600]),
      labelStyle: const TextStyle(color: Colors.black),
      prefixIconColor: Colors.black,
      suffixIconColor: Colors.black,
    ),
  );
}
