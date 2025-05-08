import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/core/router/router_names.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BookVerticalCard extends StatelessWidget {
  const BookVerticalCard({
    super.key,
    required this.book,
  });

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(RouterNames.bookDetail, extra: book),
      child: SizedBox(
        height: 294.h,
        width: 180.w,
        child: Column(
          children: [
            // Image Section
            Container(
              height: 140.h,
              width: 180.w,
              decoration: BoxDecoration(
                color: AppColors.greyColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.network(
                    book.imageUrl,
                    height: 128.h,
                    width: 92.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.book, size: 92.w),
                  ),
                ),
              ),
            ),

            // Text Section
            Expanded(
              child: Container(
                width: 180.w,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8.r)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category
                              Text(
                                book.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.secondaryColor
                                          .withOpacity(0.6),
                                      fontSize: 10.sp,
                                      height: 1.2,
                                    ),
                              ),
                              SizedBox(height: 4.h),

                              // Title
                              Flexible(
                                child: Text(
                                  book.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppColors.secondaryColor,
                                        fontSize: 14.sp,
                                        height: 1.2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              SizedBox(height: 4.h),

                              // Author
                              Text(
                                book.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.secondaryColor,
                                      fontSize: 10.sp,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Price
                        Text(
                          '\$${book.price}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.secondaryColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
