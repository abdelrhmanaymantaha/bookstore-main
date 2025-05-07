import 'package:bookstore_app/core/router/router_names.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:flutter/material.dart';

import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BookHorizontalCard extends StatelessWidget {
  const BookHorizontalCard({
    super.key,
    required this.book,
  });

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          RouterNames.bookDetail,
          extra: book,
        );
      },
      child: Container(
        height: 160.h,
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 320.w,
          minWidth: 260.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12).r,
          color: AppColors.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 90.w,
              constraints: BoxConstraints(
                minWidth: 70.w,
                maxWidth: 100.w,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ).r,
                image: DecorationImage(
                  image: NetworkImage(
                    book.imageUrl,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      book.category,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            color: AppColors.secondaryColor.withOpacity(0.6),
                            fontSize: 11.sp,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.secondaryColor,
                            fontSize: 13.sp,
                            height: 1.2,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: AppColors.secondaryColor,
                            fontSize: 11.sp,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${book.price}',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: AppColors.secondaryColor,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Container(
                          height: 20.h,
                          constraints: BoxConstraints(
                            minWidth: 45.w,
                            maxWidth: 55.w,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4).r,
                            color: AppColors.secondaryColor,
                          ),
                          child: Center(
                            child: Text(
                              '${book.discount ?? 10}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                    color: AppColors.primaryColor,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
