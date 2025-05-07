import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 56.h,
          width: 260.w,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ).r,
          decoration: BoxDecoration(
            color: AppColors.textFieldBgColor,
            borderRadius: BorderRadius.circular(5).r,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 24.r,
              ),
              SizedBox(
                width: 6.w,
              ),
              Text(
                'Search title/author/ISBN no',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 8.w,
        ),
        Container(
          height: 56.h,
          width: 52,
          decoration: BoxDecoration(
            color: AppColors.textFieldBgColor,
            borderRadius: BorderRadius.circular(5).r,
          ),
          child: Center(
            child: Icon(
              Icons.filter_alt,
              size: 24.r,
            ),
          ),
        ),
      ],
    );
  }
}
