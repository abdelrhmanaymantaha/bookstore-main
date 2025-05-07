import 'package:bookstore_app/view/categories/widgets/grid_view_widget.dart';
import 'package:flutter/material.dart';

import 'package:bookstore_app/view/categories/widgets/search_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20).r,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32.h,
              ),
              const SearchHeader(),
              SizedBox(
                height: 32.h,
              ),
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 32.h,
              ),
              const GridViewWidget(),
              SizedBox(
                height: 12.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}
