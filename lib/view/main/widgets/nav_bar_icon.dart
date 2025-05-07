import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavBarIcon extends StatelessWidget {
  const NavBarIcon({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.textStyle,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Container(
          height: 32.h,
          width: 64.w,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ).r,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24).r,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24.r,
          ),
        ),
        SizedBox(
          height: 4.h,
        ),
        Text(
          title,
          style: textStyle,
        ),
      ],
    );
  }
}
