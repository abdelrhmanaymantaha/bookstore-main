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
      onTap: () {
        context.pushNamed(
          RouterNames.bookDetail,
          extra: book,
        );
      },
      child: Container(
        height: 294.h,
        width: 180.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8).r,
          color: AppColors.greyColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 140.h,
                width: 92.w,
                padding: const EdgeInsets.only(top: 12).r,
                child: Image.network(
                  book.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 154.h,
              width: 180.w,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
              ).r,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ).r,
                color: AppColors.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.category,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: AppColors.secondaryColor.withOpacity(0.6),
                        ),
                  ),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Text(
                    '\$${book.price}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
