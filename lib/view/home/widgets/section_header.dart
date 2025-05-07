import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/core/router/router_names.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeMore,
  });

  final String title;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          TextButton(
            onPressed: onSeeMore,
            child: Text(
              'See more',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
