import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bookstore_app/core/router/router_provider.dart';
import 'package:bookstore_app/core/theme/app_theme.dart';
import 'package:bookstore_app/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );

  await ScreenUtil.ensureScreenSize();

  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    const ProviderScope(
      child: BookstoreApp(),
    ),
  );
}

class BookstoreApp extends ConsumerWidget {
  const BookstoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}
