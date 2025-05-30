// admin_screen.dart
import 'package:flutter/material.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/models/library_book.dart';
import 'package:bookstore_app/view/admin/edit_book_screen.dart';
import 'package:bookstore_app/view/admin/add_book_screen.dart';
import 'package:bookstore_app/view_model/home_view_model/home_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:bookstore_app/view/admin/edit_books_page.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  static String? _username;
  static String? _password;

  static String getBasicAuthHeader() {
    if (_username == null || _password == null) {
      throw Exception('Not authenticated');
    }
    return 'Basic ' + base64Encode(utf8.encode('$_username:$_password'));
  }

  static Future<bool> showLoginDialog(BuildContext context) async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isLoading = false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                title: Text(
                  'Admin Login',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter username',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        prefixIcon:
                            Icon(Icons.person, color: AppColors.primaryColor),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        prefixIcon:
                            Icon(Icons.lock, color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (usernameController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please fill all fields'),
                                  backgroundColor: AppColors.errorColor,
                                ),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            try {
                              final response = await http.post(
                                Uri.parse(
                                    'https://book-app-backend-production-304e.up.railway.app/login'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Basic ' +
                                      base64Encode(utf8.encode(
                                          '${usernameController.text}:${passwordController.text}')),
                                },
                              );

                              if (response.statusCode == 200) {
                                _username = usernameController.text;
                                _password = passwordController.text;
                                Navigator.of(context).pop(true);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Invalid credentials'),
                                    backgroundColor: AppColors.errorColor,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: AppColors.errorColor,
                                ),
                              );
                            } finally {
                              setState(() => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
  }

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  bool _isLoading = false;
  List<BookModel> _books = [];

  @override
  void initState() {
    super.initState();
    print('AdminScreen initialized');
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
        ),
      ),
      backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        title: Text(
          'Admin Panel',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.book,
                              color: AppColors.primaryColor,
                              size: 24.r,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Book Management',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildAdminButton(
                        icon: Icons.add_circle_outline,
                        label: 'Add New Book',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddBookScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      _buildAdminButton(
                        icon: Icons.edit,
                        label: 'Edit Books',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditBooksPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      _buildAdminButton(
                        icon: Icons.delete,
                        label: 'Delete Books',
                        onPressed: _showDeleteBookDialog,
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
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.library_books,
                              color: AppColors.primaryColor,
                              size: 24.r,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Library Management',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildAdminButton(
                        icon: Icons.library_add,
                        label: 'Add Library Book',
                        onPressed: _showAddLibraryBookDialog,
                      ),
                      SizedBox(height: 12.h),
                      _buildAdminButton(
                        icon: Icons.delete,
                        label: 'Delete Library Book',
                        onPressed: _showDeleteLibraryBookDialog,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddLibraryBookDialog() {
    final TextEditingController bookIdController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.library_add,
                                color: AppColors.primaryColor,
                                size: 24.r,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Add Library Book',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    TextField(
                      controller: bookIdController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Book ID',
                        hintText: 'Enter book ID',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: authorController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Author',
                        hintText: 'Enter author name',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: titleController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter book title',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (bookIdController.text.isEmpty ||
                                      authorController.text.isEmpty ||
                                      titleController.text.isEmpty) {
                                    _showMessage('Please fill all fields',
                                        isError: true);
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  try {
                                    final response = await http.post(
                                      Uri.parse(
                                          'https://book-app-backend-production-304e.up.railway.app/library/add'),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'Authorization':
                                            AdminScreen.getBasicAuthHeader(),
                                      },
                                      body: json.encode({
                                        'bookid':
                                            int.parse(bookIdController.text),
                                        'author': authorController.text,
                                        'title': titleController.text,
                                      }),
                                    );

                                    if (response.statusCode == 201) {
                                      Navigator.pop(context);
                                      _showMessage('Book added successfully');
                                    } else {
                                      throw Exception('Failed to add book');
                                    }
                                  } catch (e) {
                                    _showMessage('Error: ${e.toString()}',
                                        isError: true);
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Add Book',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteBookDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeleteBookPage(),
      ),
    );
  }

  void _showDeleteLibraryBookDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeleteLibraryBookPage(),
      ),
    );
  }
}

class DeleteLibraryBookPage extends ConsumerStatefulWidget {
  const DeleteLibraryBookPage({super.key});

  @override
  ConsumerState<DeleteLibraryBookPage> createState() =>
      _DeleteLibraryBookPageState();
}

class _DeleteLibraryBookPageState extends ConsumerState<DeleteLibraryBookPage> {
  final TextEditingController searchController = TextEditingController();
  List<LibraryBook> filteredBooks = [];
  List<LibraryBook> books = [];
  bool isLoading = true;

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
        ),
      ),
      backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    fetchLibraryBooks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchLibraryBooks() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://book-app-backend-production-304e.up.railway.app/library'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          books = data.map((json) => LibraryBook.fromJson(json)).toList();
          filteredBooks = books;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load library books');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error loading library books: $e', isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDeleteConfirmationDialog(LibraryBook book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Library Book',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.errorColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this library book?',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'By ${book.author}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: book.available
                          ? AppColors.successLightColor
                          : AppColors.errorLightColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      book.available ? 'Available' : 'Borrowed',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: book.available
                            ? AppColors.successColor
                            : AppColors.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog

              try {
                final response = await http.delete(
                  Uri.parse(
                      'https://book-app-backend-production-304e.up.railway.app/library/delete?bookid=${book.bookid}'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': AdminScreen.getBasicAuthHeader(),
                  },
                );

                if (response.statusCode == 204) {
                  _showMessage('Library book deleted successfully');
                  fetchLibraryBooks(); // Refresh the list
                } else {
                  throw Exception('Failed to delete library book');
                }
              } catch (e) {
                _showMessage('Error deleting library book: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        title: Text(
          'Delete Library Book',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: fetchLibraryBooks,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Container(
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
                child: TextField(
                  controller: searchController,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by title or author...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryColor,
                      size: 20.r,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[400],
                              size: 20.r,
                            ),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                filteredBooks = books;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        filteredBooks = books;
                      } else {
                        final lowercaseQuery = value.toLowerCase();
                        filteredBooks = books.where((book) {
                          return book.title
                                  .toLowerCase()
                                  .contains(lowercaseQuery) ||
                              book.author
                                  .toLowerCase()
                                  .contains(lowercaseQuery);
                        }).toList();
                      }
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Loading library books...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredBooks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48.r,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                searchController.text.isEmpty
                                    ? 'No library books available'
                                    : 'No books found',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.r),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12.h),
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(12.r),
                                title: Text(
                                  book.title,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  book.author,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: book.available
                                            ? AppColors.successLightColor
                                            : AppColors.errorLightColor,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        book.available
                                            ? 'Available'
                                            : 'Borrowed',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: book.available
                                              ? AppColors.successColor
                                              : AppColors.errorColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.delete,
                                      size: 24.r,
                                      color: AppColors.errorColor,
                                    ),
                                  ],
                                ),
                                onTap: () =>
                                    _showDeleteConfirmationDialog(book),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteBookPage extends ConsumerStatefulWidget {
  const DeleteBookPage({super.key});

  @override
  ConsumerState<DeleteBookPage> createState() => _DeleteBookPageState();
}

class _DeleteBookPageState extends ConsumerState<DeleteBookPage> {
  final TextEditingController searchController = TextEditingController();
  List<BookModel> filteredBooks = [];
  List<BookModel> books = [];
  bool isLoading = true;

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
        ),
      ),
      backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBooks() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://book-app-backend-production-304e.up.railway.app/books'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AdminScreen.getBasicAuthHeader(),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          books = data.map((json) => BookModel.fromJson(json)).toList();
          filteredBooks = books;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error loading books: $e', isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDeleteConfirmationDialog(BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Book',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.errorColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this book?',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'By ${book.author}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.infoLightColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      book.category,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog

              try {
                final response = await http.delete(
                  Uri.parse(
                      'https://book-app-backend-production-304e.up.railway.app/books/delete/${book.id}'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': AdminScreen.getBasicAuthHeader(),
                  },
                );

                if (response.statusCode == 200) {
                  _showMessage('Book deleted successfully');
                  fetchBooks(); // Refresh the list
                } else {
                  throw Exception('Failed to delete book');
                }
              } catch (e) {
                _showMessage('Error deleting book: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        title: Text(
          'Delete Book',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: fetchBooks,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Container(
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
                child: TextField(
                  controller: searchController,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by title, author, or category...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryColor,
                      size: 20.r,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[400],
                              size: 20.r,
                            ),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                filteredBooks = books;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        filteredBooks = books;
                      } else {
                        final lowercaseQuery = value.toLowerCase();
                        filteredBooks = books.where((book) {
                          return book.title
                                  .toLowerCase()
                                  .contains(lowercaseQuery) ||
                              book.author
                                  .toLowerCase()
                                  .contains(lowercaseQuery) ||
                              book.category
                                  .toLowerCase()
                                  .contains(lowercaseQuery);
                        }).toList();
                      }
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Loading books...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredBooks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48.r,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                searchController.text.isEmpty
                                    ? 'No books available'
                                    : 'No books found',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.r),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12.h),
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(12.r),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.network(
                                    book.imageUrl,
                                    width: 50.w,
                                    height: 70.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 50.w,
                                      height: 70.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(Icons.book,
                                          size: 30.r, color: Colors.grey[400]),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  book.title,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.author,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.infoLightColor,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        book.category,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.infoColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.delete,
                                  size: 24.r,
                                  color: AppColors.errorColor,
                                ),
                                onTap: () =>
                                    _showDeleteConfirmationDialog(book),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
