import 'package:bookstore_app/core/common/providers/auth_state_provider.dart';
import 'package:bookstore_app/core/common/widgets/splash_screen.dart';
import 'package:bookstore_app/core/router/router_names.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/view/account/account_screen.dart';
import 'package:bookstore_app/view/auth/forgot_password_screen/forgot_password_screen.dart';
import 'package:bookstore_app/view/auth/login_screen/login_screen.dart';
import 'package:bookstore_app/view/auth/register_screen/register_screen.dart';
import 'package:bookstore_app/view/auth/welcome_screen.dart';
import 'package:bookstore_app/view/book_detail/book_detail_screen.dart';
import 'package:bookstore_app/view/cart/cart_screen.dart';
import 'package:bookstore_app/view/categories/categories_screen.dart';
import 'package:bookstore_app/view/categories/category_screen.dart';
import 'package:bookstore_app/view/home/home_screen.dart';
import 'package:bookstore_app/view/home/see_more_screen.dart';
import 'package:bookstore_app/view/main/main_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bookstore_app/view/admin/admin_screen.dart';
import 'package:bookstore_app/view/orders/orders_screen.dart';
part 'router_provider.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _rootNavigatorHome =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _rootNavigatorCategories =
    GlobalKey<NavigatorState>(debugLabel: 'shellCategories');
final GlobalKey<NavigatorState> _rootNavigatorCart =
    GlobalKey<NavigatorState>(debugLabel: 'shellCart');
final GlobalKey<NavigatorState> _rootNavigatorAccount =
    GlobalKey<NavigatorState>(debugLabel: 'shellAccount');
final GlobalKey<NavigatorState> _rootNavigatorAdmin =
    GlobalKey<NavigatorState>(debugLabel: 'shellAdmin');

@riverpod
GoRouter router(Ref ref) {
  final user = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (user is AsyncLoading<User?>) {
        return state.namedLocation(RouterNames.splash);
      }

      final isLoggedIn = user.value != null;
      final isGoingToAuth = state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot_password';

      // If the user is not logged in and trying to access a protected screen, redirect to welcome
      final isGoingToProtectedRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/home' ||
          state.matchedLocation == '/categories' ||
          state.matchedLocation == '/cart' ||
          state.matchedLocation == '/account' ||
          state.matchedLocation == '/admin' ||
          state.matchedLocation == '/orders';

      if (!isLoggedIn && isGoingToProtectedRoute) {
        return state.namedLocation(RouterNames.welcome);
      }

      // If the user is logged in and trying to access an auth screen, redirect to home
      if (isLoggedIn && isGoingToAuth) {
        return state.namedLocation(RouterNames.home);
      }

      // If the user is logged in and trying to go to '/', redirect to home
      if (isLoggedIn && state.matchedLocation == '/') {
        return state.namedLocation(RouterNames.home);
      }

      return null; // No redirect needed
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainWrapper(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: _rootNavigatorHome,
            routes: [
              GoRoute(
                name: RouterNames.home,
                path: '/home',
                builder: (context, state) => HomeScreen(
                  key: state.pageKey,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorCategories,
            routes: [
              GoRoute(
                name: RouterNames.categories,
                path: '/categories',
                builder: (context, state) => CategoriesScreen(
                  key: state.pageKey,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorCart,
            routes: [
              GoRoute(
                name: RouterNames.cart,
                path: '/cart',
                builder: (context, state) => CartScreen(
                  key: state.pageKey,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorAccount,
            routes: [
              GoRoute(
                name: RouterNames.account,
                path: '/account',
                builder: (context, state) => AccountScreen(
                  key: state.pageKey,
                ),
              ),
              GoRoute(
                name: RouterNames.orders,
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _rootNavigatorAdmin,
            routes: [
              GoRoute(
                name: RouterNames.admin,
                path: '/admin',
                builder: (context, state) => const AdminScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: RouterNames.splash,
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: RouterNames.welcome,
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        name: RouterNames.login,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: RouterNames.signup,
        path: '/signup',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: RouterNames.forgotPassword,
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: RouterNames.bookDetail,
        path: '/book_detail',
        builder: (context, state) {
          final book = state.extra as BookModel;

          return BookDetailScreen(book: book);
        },
      ),
      GoRoute(
        name: RouterNames.seeMore,
        path: '/see_more',
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;
          final List<BookModel> books = extra['books'] as List<BookModel>;
          final String title = extra['title'] as String;

          return SeeMoreScreen(
            books: books,
            title: title,
          );
        },
      ),
      GoRoute(
        name: RouterNames.categorySceen,
        path: '/category',
        builder: (context, state) {
          final books = state.extra as List<BookModel>;
          final title = state.uri.queryParameters['title']!;

          return CategoryScreen(
            books: books,
            title: title,
          );
        },
      ),
    ],
  );
}
