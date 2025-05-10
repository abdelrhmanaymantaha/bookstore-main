import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/core/widgets/custom_snackbar.dart';

import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/view_model/cart_view_model/cart_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.book});

  final BookModel book;

  void _showMessage(BuildContext context, String message,
      {bool isError = false}) {
    if (isError) {
      CustomSnackBar.showError(
        context: context,
        message: message,
      );
    } else {
      CustomSnackBar.showSuccess(
        context: context,
        message: message,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartBooks = ref.watch(cartViewModelProvider);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ScaffoldMessenger.of(context).clearSnackBars();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            book.category,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          centerTitle: true,
          actions: [],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20).r,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  children: [
                    Container(
                      height: 215.h,
                      width: 138.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            book.imageUrl,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    SizedBox(
                      width: 160.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Author: ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Flexible(
                                child: Text(
                                  book.author,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category: ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Flexible(
                                child: Text(
                                  book.category,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rating: ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${book.rating}/5',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pricing: ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '\$${book.price}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16.h,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (cartBooks
                                  .any((item) => item.book.id == book.id)) {
                                _showMessage(
                                  context,
                                  'Book is already in cart.',
                                );
                                return;
                              }

                              ref
                                  .read(cartViewModelProvider.notifier)
                                  .addToCart(book);

                              _showMessage(
                                context,
                                'Book has been added to cart.',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(160.w, 40.h),
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.secondaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5).r,
                              ),
                            ),
                            child: Text(
                              'Add to Cart',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: AppColors.secondaryColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  'Description:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  book.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
