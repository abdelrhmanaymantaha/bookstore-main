import 'package:flutter/material.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/view/admin/edit_book_screen.dart';
import 'package:bookstore_app/view/admin/admin_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditBooksPage extends ConsumerStatefulWidget {
  const EditBooksPage({super.key});

  @override
  ConsumerState<EditBooksPage> createState() => _EditBooksPageState();
}

class _EditBooksPageState extends ConsumerState<EditBooksPage> {
  bool _isLoading = false;
  List<BookModel> _books = [];
  final TextEditingController _searchController = TextEditingController();
  List<BookModel> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
            'https://book-app-backend-production-304e.up.railway.app/books'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = json.decode(response.body);
          print('Response data: $data'); // Debug log

          if (data.isEmpty) {
            setState(() {
              _books = [];
              _filteredBooks = [];
              _isLoading = false;
            });
            return;
          }

          setState(() {
            _books = data.map((json) => BookModel.fromJson(json)).toList();
            _filteredBooks = _books;
            print('Books loaded: ${_books.length}'); // Debug log
          });
        } catch (parseError) {
          print('Parse error: $parseError'); // Debug log
          _showMessage('Error parsing book data: $parseError', isError: true);
        }
      } else {
        print('Failed with status code: ${response.statusCode}'); // Debug log
        print('Response body: ${response.body}'); // Debug log
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _loadBooks: $e'); // Debug log
      _showMessage('Error loading books: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _books;
      } else {
        final lowercaseQuery = query.toLowerCase();
        _filteredBooks = _books.where((book) {
          return book.title.toLowerCase().contains(lowercaseQuery) ||
              book.author.toLowerCase().contains(lowercaseQuery) ||
              book.category.toLowerCase().contains(lowercaseQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        title: Text(
          'Edit Books',
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
            onPressed: _loadBooks,
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
                  controller: _searchController,
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
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[400],
                              size: 20.r,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterBooks('');
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
                  onChanged: _filterBooks,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
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
                  : _filteredBooks.isEmpty
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
                                _searchController.text.isEmpty
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
                          itemCount: _filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = _filteredBooks[index];
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
                                  Icons.edit,
                                  size: 24.r,
                                  color: AppColors.primaryColor,
                                ),
                                onTap: () {
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
    );
  }
}
