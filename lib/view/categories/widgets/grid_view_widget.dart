import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/core/enums/categories.dart';
import 'package:bookstore_app/core/router/router_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bookstore_app/view_model/category_view_model/category_view_model.dart';

class GridViewWidget extends ConsumerWidget {
  const GridViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20.h,
        crossAxisSpacing: 20.w,
        childAspectRatio: 3 / 2,
      ),
      itemCount: Categories.values.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final category = Categories.values[index];
        final books =
            ref.watch(categoryViewModelProvider(category: category.title));

        return GestureDetector(
          onTap: () {
            context.pushNamed(
              RouterNames.categorySceen,
              extra: books.value,
              queryParameters: {
                'title': category.title,
              },
            );
          },
          child: Container(
            height: 100.h,
            width: 150.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5).r,
              image: DecorationImage(
                image: NetworkImage(category.bgImageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5).r,
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Text(
                  category.title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.secondaryColor,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
