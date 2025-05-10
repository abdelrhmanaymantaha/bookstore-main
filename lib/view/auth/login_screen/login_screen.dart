import 'package:bookstore_app/core/router/router_names.dart';
import 'package:bookstore_app/view_model/auth_view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bookstore_app/core/common/widgets/custom_button.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/view/auth/widgets/custom_text_field.dart';
import 'package:bookstore_app/core/widgets/custom_snackbar.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';

class LoginScreen extends StatefulHookConsumerWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(authViewModelProvider, (previous, next) {
      print('Auth State Changed: $next');
      if (next is AsyncError) {
        print('Auth Error: ${next.error}');
        _showMessage(next.error.toString(), isError: true);
      }
    });

    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final showPassword = useState(false);

    final overlay = context.loaderOverlay;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: LoaderOverlay(
        overlayWidgetBuilder: (_) => const Center(
          child: SpinKitFadingCircle(
            color: Colors.black,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Get Started',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            centerTitle: true,
          ),
          body: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 30.h,
                      ),
                      Text(
                        'Please fill your details to login.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(
                        height: 32.h,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: emailController,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (!value!.contains('@') || value.isEmpty) {
                                  return 'Invalid email.';
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: 24.h,
                            ),
                            CustomTextField(
                              controller: passwordController,
                              hintText: 'Password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  showPassword.value = !showPassword.value;
                                },
                                icon: FaIcon(
                                  showPassword.value
                                      ? FontAwesomeIcons.solidEyeSlash
                                      : FontAwesomeIcons.solidEye,
                                ),
                                color: const Color.fromRGBO(37, 37, 37, 1),
                              ),
                              obscureText: !showPassword.value,
                              enableSuggestions: false,
                              keyboardType: TextInputType.visiblePassword,
                              validator: (value) {
                                if (value!.length < 6 || value.isEmpty) {
                                  return 'Password must be at least 6 characters.';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 32.h,
                      ),
                      CustomButton(
                        onPressed: () {
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            print('Login attempt with:');
                            print('Email: ${emailController.text.trim()}');
                            print(
                                'Password length: ${passwordController.text.trim().length}');

                            FocusManager.instance.primaryFocus?.unfocus();
                            overlay.show();

                            ref
                                .read(authViewModelProvider.notifier)
                                .signIn(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                )
                                .then(
                              (value) {
                                print('Login result: $value');
                                overlay.hide();

                                if (value) {
                                  if (context.mounted) {
                                    context.pop();
                                  }
                                }
                              },
                            );
                          }
                        },
                        title: 'Get Started',
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.secondaryColor,
                      ),
                      SizedBox(
                        height: 24.h,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16).r,
                            child: Text(
                              'OR',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 24.h,
                      ),
                      CustomButton(
                        onPressed: () {
                          overlay.show();
                          ref
                              .read(authViewModelProvider.notifier)
                              .signInWithGoogle()
                              .then(
                            (value) {
                              overlay.hide();
                              if (value) {
                                if (context.mounted) {
                                  context.pop();
                                }
                              }
                            },
                          );
                        },
                        title: 'Continue with Google',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        icon: Image.asset(
                          'assets/images/google_logo.png',
                          height: 24.h,
                        ),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      SizedBox(
                        height: 24.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80).r,
                        child: TextButton(
                          onPressed: () =>
                              context.pushNamed(RouterNames.forgotPassword),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            elevation: 0,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                    ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'New Member? ',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.black,
                                    ),
                          ),
                          InkWell(
                            onTap: () => context
                                .pushReplacementNamed(RouterNames.signup),
                            child: Text(
                              'Register',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
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
}
