import 'package:bookstore_app/view/account/account_screen.dart';
import 'package:bookstore_app/view/cart/cart_screen.dart';
import 'package:bookstore_app/view/categories/categories_screen.dart';
import 'package:bookstore_app/view/library/library_page.dart';
import 'package:bookstore_app/view/main/widgets/nav_bar_icon.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/view/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  PersistentTabController controller = PersistentTabController(initialIndex: 0);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _goToBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<PersistentBottomNavBarItem> navBarItems = [
      navBarItem(
        icon: NavBarIcon(
          title: 'Home',
          icon: Icons.home,
          iconColor: AppColors.secondaryColor,
          backgroundColor: AppColors.primaryColor,
          textStyle: Theme.of(context).textTheme.titleSmall,
        ),
        inactiveIcon: NavBarIcon(
          title: 'Home',
          icon: Icons.home,
          iconColor: AppColors.primaryColor,
          backgroundColor: AppColors.secondaryColor,
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      navBarItem(
        icon: NavBarIcon(
          title: 'Categories',
          icon: Icons.category,
          iconColor: AppColors.secondaryColor,
          backgroundColor: AppColors.primaryColor,
          textStyle: Theme.of(context).textTheme.titleSmall,
        ),
        inactiveIcon: NavBarIcon(
          title: 'Categories',
          icon: Icons.category,
          iconColor: AppColors.primaryColor,
          backgroundColor: AppColors.secondaryColor,
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      navBarItem(
        icon: NavBarIcon(
          title: 'Library',
          icon: Icons.library_books,
          iconColor: AppColors.secondaryColor,
          backgroundColor: AppColors.primaryColor,
          textStyle: Theme.of(context).textTheme.titleSmall,
        ),
        inactiveIcon: NavBarIcon(
          title: 'Library',
          icon: Icons.library_books,
          iconColor: AppColors.primaryColor,
          backgroundColor: AppColors.secondaryColor,
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      navBarItem(
        icon: NavBarIcon(
          title: 'Cart',
          icon: Icons.shopping_cart,
          iconColor: AppColors.secondaryColor,
          backgroundColor: AppColors.primaryColor,
          textStyle: Theme.of(context).textTheme.titleSmall,
        ),
        inactiveIcon: NavBarIcon(
          title: 'Cart',
          icon: Icons.shopping_cart,
          iconColor: AppColors.primaryColor,
          backgroundColor: AppColors.secondaryColor,
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      navBarItem(
        icon: NavBarIcon(
          title: 'Account',
          icon: Icons.account_box,
          iconColor: AppColors.secondaryColor,
          backgroundColor: AppColors.primaryColor,
          textStyle: Theme.of(context).textTheme.titleSmall,
        ),
        inactiveIcon: NavBarIcon(
          title: 'Account',
          icon: Icons.account_box,
          iconColor: AppColors.primaryColor,
          backgroundColor: AppColors.secondaryColor,
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ];

    List<Widget> screens = [
      const HomeScreen(),
      const CategoriesScreen(),
      const LibraryPage(),
      const CartScreen(),
      const AccountScreen(),
    ];
    return SafeArea(
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: PersistentTabView(
          context,
          controller: controller,
          screens: screens,
          items: navBarItems,
          backgroundColor: AppColors.secondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).r,
          handleAndroidBackButtonPress: false,
          navBarHeight: 80.h,
          navBarStyle: NavBarStyle.style8,
          onItemSelected: (value) {
            _goToBranch(value);
          },
        ),
      ),
    );
  }
}

PersistentBottomNavBarItem navBarItem({
  required Widget icon,
  required Widget inactiveIcon,
}) {
  return PersistentBottomNavBarItem(
    icon: icon,
    inactiveIcon: inactiveIcon,
  );
}
