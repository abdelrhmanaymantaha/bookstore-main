import 'package:bookstore_app/core/common/widgets/custom_button.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/core/constants/asset_paths.dart';
import 'package:bookstore_app/view/cart/widgets/book_cart_card.dart';
import 'package:bookstore_app/view_model/cart_view_model/cart_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookstore_app/core/router/router_names.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/widgets/custom_snackbar.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

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

  Future<void> _purchaseBooks(
      BuildContext context, WidgetRef ref, List<CartItem> cartItems) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final userEmail = user.email;
      if (userEmail == null) {
        throw Exception('User email not found');
      }

      // Make POST request for each book
      for (var item in cartItems) {
        final response = await http.post(
          Uri.parse(
              'https://book-app-backend-production-304e.up.railway.app/users/add/purchase'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': userEmail,
            'books_title': item.book.title,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to purchase book: ${item.book.title}');
        }
      }

      // Clear the cart after successful purchase
      ref.read(cartViewModelProvider.notifier).clearCart();

      // Show success message
      if (context.mounted) {
        _showMessage(context, 'Purchase successful!');
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        _showMessage(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartViewModelProvider);
    final subtotal = ref.read(cartViewModelProvider.notifier).getTotalPrice();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20).r,
        child: cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      AssetPaths.emptyCart,
                    ),
                    Text(
                      'Cart is empty.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),
                    Center(
                      child: Text(
                        'Cart',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              RouterNames.bookDetail,
                              extra: item.book,
                              queryParameters: {
                                'title': item.book.title,
                              },
                            );
                          },
                          child: BookCartCard(
                            book: item.book,
                            quantity: item.quantity,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Subtotal',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '\$${subtotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Shipping',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '\$10.00',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    const Divider(color: AppColors.primaryColor),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '\$${(subtotal + 10).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    CustomButton(
                      onPressed: () => _purchaseBooks(context, ref, cartItems),
                      title: 'Proceed to Checkout',
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.secondaryColor,
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
      ),
    );
  }
}
