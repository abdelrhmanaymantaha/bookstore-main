import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.obscureText = false,
    this.enableSuggestions = true,
    this.keyboardType,
    this.autovalidateMode = AutovalidateMode.onUnfocus,
    this.textCapitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;

  final Widget? suffixIcon;
  final bool obscureText;
  final bool enableSuggestions;
  final TextInputType? keyboardType;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;
  final void Function(String value)? onFieldSubmitted;
  final void Function(String value)? onChanged;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      style: Theme.of(context).textTheme.bodySmall,
      decoration: InputDecoration(
        fillColor: AppColors.textFieldBgColor,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5).r,
          borderSide: const BorderSide(
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5).r,
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: const Color.fromRGBO(37, 37, 37, 1),
            ),
        suffixIcon: suffixIcon,
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
      ),
      obscureText: obscureText,
      obscuringCharacter: '*',
      enableSuggestions: enableSuggestions,
      keyboardType: keyboardType,
      autovalidateMode: autovalidateMode,
      autocorrect: false,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
