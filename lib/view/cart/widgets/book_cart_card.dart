import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/view_model/cart_view_model/cart_view_model.dart';
import 'package:flutter/material.dart';

import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookCartCard extends ConsumerWidget {
  const BookCartCard({
    super.key,
    required this.book,
    required this.quantity,
  });

  final BookModel book;
  final int quantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 144.h,
      width: 320.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8).r,
        color: AppColors.primaryColor,
      ),
      child: Row(
        children: [
          Container(
            width: 95.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8).r,
              image: DecorationImage(
                image: NetworkImage(
                  book.imageUrl,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: 220.w,
            padding: const EdgeInsets.only(
              left: 10,
              right: 8,
              top: 8,
              bottom: 8,
            ).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      book.category,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            color: AppColors.secondaryColor.withOpacity(0.6),
                          ),
                    ),
                    InkWell(
                      onTap: () {
                        ref
                            .read(cartViewModelProvider.notifier)
                            .removeFromCart(book);
                      },
                      child: Icon(
                        Icons.close,
                        color: AppColors.secondaryColor,
                        size: 20.r,
                      ),
                    ),
                  ],
                ),
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: AppColors.secondaryColor,
                      ),
                  overflow: TextOverflow.clip,
                ),
                SizedBox(
                  height: 6.h,
                ),
                Text(
                  book.author,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: AppColors.secondaryColor,
                      ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            ref
                                .read(cartViewModelProvider.notifier)
                                .decreaseQuantity(book);
                          },
                          child: Container(
                          height: 24.h,
                          width: 24.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5).r,
                            color: AppColors.secondaryColor,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.remove,
                              size: 24.r,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(
                          '$quantity',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: AppColors.secondaryColor,
                                  ),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        InkWell(
                          onTap: () {
                            ref
                                .read(cartViewModelProvider.notifier)
                                .increaseQuantity(book);
                          },
                          child: Container(
                          height: 24.h,
                          width: 24.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5).r,
                            color: AppColors.secondaryColor,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 24.r,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${(book.price * quantity).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: AppColors.secondaryColor,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
