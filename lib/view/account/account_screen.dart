import 'package:flutter/material.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:bookstore_app/core/router/router_names.dart';
import 'package:bookstore_app/view/admin/admin_screen.dart';
import 'package:bookstore_app/view/orders/orders_screen.dart';
import 'package:bookstore_app/view/account/borrowed_books_page.dart';
import '../../core/widgets/custom_snackbar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    _verifyFirestoreConnection();
  }

  Future<void> _verifyFirestoreConnection() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    debugPrint('=== FIRESTORE DEBUG START ===');
    debugPrint('Checking document for UID: ${user.uid}');
    debugPrint('User photoURL from Auth: ${user.photoURL}');

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      debugPrint('Document exists: ${doc.exists}');
      if (doc.exists) {
        debugPrint('Document data: ${doc.data()}');
        debugPrint('User photoURL from Firestore: ${doc.data()?['photoURL']}');
      } else {
        debugPrint('No document found at path: users/${user.uid}');
        debugPrint('Attempting to create default profile...');
        await _createDefaultProfile(user);
      }
    } catch (e) {
      debugPrint('Firestore access error: $e');
      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Database error: $e',
        );
      }
    }
    debugPrint('=== FIRESTORE DEBUG END ===');
  }

  Future<void> _createDefaultProfile(User user) async {
    try {
      final userData = {
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': user.displayName ?? 'New User',
        'lastLogin': FieldValue.serverTimestamp(),
        'isProfileComplete': false,
        'uid': user.uid,
        'photoURL': user.photoURL,
        'phoneNumber': user.phoneNumber,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      if (mounted) {
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Profile created successfully!',
        );
      }
    } catch (e) {
      debugPrint('Error creating default profile: $e');
      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Error creating profile: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildUnauthenticatedView(context);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminScreen()),
            );
          },
          icon: const Icon(Icons.admin_panel_settings),
        ),
        title: Text(
          'Account',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView(
                context,
                'Error: ${snapshot.error}\n\n'
                'UID: ${user.uid}\n'
                'Path: users/${user.uid}');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildNoDataView(context, user.uid);
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildUserProfile(context, userData);
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 80),
            SizedBox(height: 20.h),
            Text(
              'Please login to view your account',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => context.pushReplacementNamed(RouterNames.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          SizedBox(height: 16.h),
          Text(
            'Data Load Error',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.red),
          ),
          SizedBox(height: 16.h),
          Text(error, textAlign: TextAlign.center),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _verifyFirestoreConnection,
            child: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView(BuildContext context, String userId) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_search, size: 64),
          SizedBox(height: 16.h),
          Text(
            'Profile Not Found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Text('UID: $userId', style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await _createDefaultProfile(user);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Create My Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(
      BuildContext context, Map<String, dynamic> userData) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  height: 120.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: userData['photoURL'] != null
                      ? ClipOval(
                          child: Image.network(
                            userData['photoURL'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 60.r,
                                color: Colors.white,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60.r,
                          color: Colors.white,
                        ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Username',
                  value: userData['displayName'] ?? 'Not set',
                ),
                SizedBox(height: 12.h),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: userData['email'] ?? 'Not set',
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _buildProfileSection(
            title: 'Edit Profile',
            icon: Icons.edit,
            onTap: () => _showEditProfileDialog(context, userData),
          ),
          _buildProfileSection(
            title: 'My Orders',
            icon: Icons.shopping_bag,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersScreen(),
                ),
              );
            },
          ),
          _buildProfileSection(
            title: 'Borrowed Books',
            icon: Icons.book,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BorrowedBooksPage(),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      context.pushReplacementNamed(RouterNames.login);
                    }
                  } catch (e) {
                    if (mounted) {
                      CustomSnackBar.showError(
                        context: context,
                        message: 'Error signing out: $e',
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 18.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryColor,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.r,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(
      BuildContext context, Map<String, dynamic> userData) async {
    final TextEditingController nameController = TextEditingController(
      text: userData['displayName'] ?? '',
    );
    final formKey = GlobalKey<FormState>();

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

    return showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: AppColors.primaryColor,
                    size: 24.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Edit Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.red[300]!),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.red[300]!),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({
                              'displayName': nameController.text,
                              'updatedAt': FieldValue.serverTimestamp(),
                            });

                            if (mounted) {
                              Navigator.pop(dialogContext);
                              _showMessage('Profile updated successfully');
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(dialogContext);
                            _showMessage('Error updating profile: $e',
                                isError: true);
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
