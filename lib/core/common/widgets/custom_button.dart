import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.title,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    this.border,
  });

  final VoidCallback onPressed;
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? icon;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(320.w, 56.h),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5).r,
          side: border?.left ?? BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: 12.w),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: foregroundColor,
                ),
          ),
        ],
      ),
    );
  }
}
