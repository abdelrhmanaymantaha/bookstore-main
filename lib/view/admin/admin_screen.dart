// admin_screen.dart
import 'package:flutter/material.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/view/admin/edit_book_screen.dart';
import 'package:bookstore_app/view/admin/add_book_screen.dart';
import 'package:bookstore_app/view_model/home_view_model/home_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  bool _isLoading = false;
  List<BookModel> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final books =
          await ref.read(homeViewModelProvider.notifier).getAllBooks();
      setState(() => _books = books);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.white, size: 20.r),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'Error loading books: $e',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showBookSelectionDialog() {
    final TextEditingController searchController = TextEditingController();
    List<BookModel> filteredBooks = _books;

    if (_isLoading) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: AppColors.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 3,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Loading books...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    if (_books.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: AppColors.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.r,
                  color: Colors.red[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Books Available',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[400],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please add some books first',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddBookScreen(),
                      ),
                    ).then((added) {
                      if (added == true) {
                        _loadBooks();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    'Add New Book',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: AppColors.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select a Book to Edit',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: AppColors.primaryColor, size: 24.r),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey[400], size: 20.r),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: Colors.grey[400], size: 20.r),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() => filteredBooks = _books);
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredBooks = _books.where((book) {
                            final title = book.title.toLowerCase();
                            final author = book.author.toLowerCase();
                            final category = book.category.toLowerCase();
                            final search = value.toLowerCase();
                            return title.contains(search) ||
                                author.contains(search) ||
                                category.contains(search);
                          }).toList();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.r),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
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
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : filteredBooks.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.r),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        searchController.text.isEmpty
                                            ? Icons.book_outlined
                                            : Icons.search_off,
                                        size: 48.r,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        searchController.text.isEmpty
                                            ? 'No books available'
                                            : 'No books found',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        searchController.text.isEmpty
                                            ? 'Add a new book to get started'
                                            : 'Try different search terms',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredBooks.length,
                                itemBuilder: (context, index) {
                                  final book = filteredBooks[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(12.r),
                                      leading: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: Image.network(
                                          book.imageUrl,
                                          width: 50.w,
                                          height: 70.h,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 50.w,
                                            height: 70.h,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Icon(Icons.book,
                                                size: 30.r,
                                                color: Colors.grey[400]),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4.h),
                                          Text(
                                            book.author,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.category_outlined,
                                                size: 12.r,
                                                color: Colors.grey[500],
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                book.category,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16.r,
                                        color: AppColors.primaryColor,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditBookScreen(book: book),
                                          ),
                                        ).then((updated) {
                                          if (updated == true) {
                                            _loadBooks();
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book Management',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
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
                  ).then((added) {
                    if (added == true) {
                      _loadBooks();
                    }
                  });
                },
              ),
              SizedBox(height: 12.h),
              _buildAdminButton(
                icon: Icons.edit,
                label: 'Edit Books',
                onPressed: _showBookSelectionDialog,
              ),
              SizedBox(height: 12.h),
              _buildAdminButton(
                icon: Icons.person,
                label: 'Manage Users',
                onPressed: () {
                  // TODO: Implement user management
                },
              ),
              SizedBox(height: 12.h),
              _buildAdminButton(
                icon: Icons.receipt_long,
                label: 'View Orders',
                onPressed: () {
                  // TODO: Implement order management
                },
              ),
            ],
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
}
