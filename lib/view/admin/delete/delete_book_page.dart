import 'package:flutter/material.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/view_model/home_view_model/home_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:bookstore_app/core/widgets/custom_snackbar.dart';

class DeleteBookPage extends ConsumerStatefulWidget {
  const DeleteBookPage({super.key});

  @override
  ConsumerState<DeleteBookPage> createState() => _DeleteBookPageState();
}

class _DeleteBookPageState extends ConsumerState<DeleteBookPage> {
  final TextEditingController searchController = TextEditingController();
  List<BookModel> filteredBooks = [];
  bool isLoading = true;

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
      final books =
          await ref.read(homeViewModelProvider.notifier).getAllBooks();
      if (!mounted) return;
      setState(() {
        filteredBooks = books;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error loading books: $e', isError: true);
      setState(() {
        isLoading = false;
      });
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
            color: Colors.red[400],
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      book.category,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue,
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
                  headers: {'Content-Type': 'application/json'},
                );

                if (response.statusCode == 204) {
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
              backgroundColor: Colors.red[400],
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
              child: TextField(
                controller: searchController,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Search books ...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      fetchBooks();
                    } else {
                      filteredBooks = filteredBooks.where((book) {
                        final title = book.title.toLowerCase();
                        final author = book.author.toLowerCase();
                        final category = book.category.toLowerCase();
                        final search = value.toLowerCase();
                        return title.contains(search) ||
                            author.contains(search) ||
                            category.contains(search);
                      }).toList();
                    }
                  });
                },
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
                                      child: Icon(
                                        Icons.book,
                                        size: 30.r,
                                        color: Colors.grey[400],
                                      ),
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
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        book.category,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.delete,
                                  size: 24.r,
                                  color: Colors.red[400],
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
