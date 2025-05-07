import 'package:bookstore_app/core/common/widgets/custom_button.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/view/auth/widgets/custom_text_field.dart';
import 'package:bookstore_app/view_model/auth_view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordScreen extends StatefulHookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  void showDialog(BuildContext context, String email) {
    showAdaptiveDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'An email has been sent to $email to reset the password.\nPlease check your email inbox, and if you didn\'t find it check your spams or make sure that you provided the correct email address.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(
                  height: 20.h,
                ),
                CustomButton(
                  onPressed: () {
                    context.pop();
                    context.pop();
                  },
                  title: 'OK',
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.secondaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20).r,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please write your email, to send the link to reset your password.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(
              height: 32.h,
            ),
            Form(
              key: _formKey,
              child: CustomTextField(
                controller: emailController,
                hintText: 'Write your email here...',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (!value!.contains('@') || value.isEmpty) {
                    return 'Invalid email.';
                  }

                  return null;
                },
              ),
            ),
            SizedBox(
              height: 32.h,
            ),
            CustomButton(
              onPressed: () {
                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate()) {
                  FocusManager.instance.primaryFocus?.unfocus();

                  ref
                      .read(authViewModelProvider.notifier)
                      .resetPassword(email: emailController.text.trim())
                      .then(
                    (value) {
                      if (value) {
                        if (context.mounted) {
                          showDialog(context, emailController.text.trim());
                        }
                      }
                    },
                  );
                }
              },
              title: 'Send reset link',
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
