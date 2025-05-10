import 'package:bookstore_app/core/common/widgets/custom_button.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/core/router/router_names.dart';
import 'package:bookstore_app/view/auth/widgets/custom_text_field.dart';
import 'package:bookstore_app/view_model/auth_view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/custom_snackbar.dart';

class RegisterScreen extends StatefulHookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String username,
  }) async {
    try {
      // First update the display name in Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(username);
        debugPrint('Updated display name in Firebase Auth: $username');
      }

      // Then create/update the Firestore document
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'username': username,
        'displayName': username,
        'isProfileComplete': false,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Created user profile in Firestore for: $username');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
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

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(authViewModelProvider, (previous, next) {
      if (next is AsyncError) {
        _showMessage(next.error.toString(), isError: true);
      }
    });

    final emailController = useTextEditingController();
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final showPassword = useState(false);
    final showConfirmPassword = useState(false);

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
              'Register',
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
                      SizedBox(height: 30.h),
                      Text(
                        'Please fill your details to signup.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 32.h),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(
                              controller: usernameController,
                              hintText: 'Username',
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value!.length < 3 || value.isEmpty) {
                                  return 'Name must be at least 3 characters.';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24.h),
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
                            SizedBox(height: 24.h),
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
                            SizedBox(height: 24.h),
                            CustomTextField(
                              controller: confirmPasswordController,
                              hintText: 'Confirm Password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  showConfirmPassword.value =
                                      !showConfirmPassword.value;
                                },
                                icon: FaIcon(
                                  showConfirmPassword.value
                                      ? FontAwesomeIcons.solidEyeSlash
                                      : FontAwesomeIcons.solidEye,
                                ),
                                color: const Color.fromRGBO(37, 37, 37, 1),
                              ),
                              obscureText: !showConfirmPassword.value,
                              enableSuggestions: false,
                              keyboardType: TextInputType.visiblePassword,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.trim() != passwordController.text ||
                                    value.isEmpty) {
                                  return 'Password doesn\'t match.';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      CustomButton(
                        onPressed: () async {
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            overlay.show();

                            try {
                              final success = await ref
                                  .read(authViewModelProvider.notifier)
                                  .signUp(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                    username: usernameController.text.trim(),
                                  );

                              if (success) {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  // Create user profile in Firestore
                                  await _createUserProfile(
                                    uid: user.uid,
                                    email: emailController.text.trim(),
                                    username: usernameController.text.trim(),
                                  );

                                  if (context.mounted) {
                                    overlay.hide();
                                    _showMessage('Registration successful!');
                                    context.pop();
                                  }
                                }
                              }
                            } catch (e) {
                              overlay.hide();
                              _showMessage('Registration failed: $e',
                                  isError: true);
                            }
                          }
                        },
                        title: 'Register',
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.secondaryColor,
                      ),
                      SizedBox(height: 20.h),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Already a Member? ',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.black,
                                    ),
                          ),
                          InkWell(
                            onTap: () =>
                                context.pushReplacementNamed(RouterNames.login),
                            child: Text(
                              'Signin',
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
                      SizedBox(height: 20.h),
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
}
