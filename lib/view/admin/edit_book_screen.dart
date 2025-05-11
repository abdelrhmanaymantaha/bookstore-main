import 'package:flutter/material.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/widgets/custom_snackbar.dart';

class EditBookScreen extends StatefulWidget {
  final BookModel book;

  const EditBookScreen({
    super.key,
    required this.book,
  });

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;
  late TextEditingController _discountController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _descriptionController =
        TextEditingController(text: widget.book.description);
    _priceController =
        TextEditingController(text: widget.book.price.toString());
    _categoryController = TextEditingController(text: widget.book.category);
    _imageUrlController = TextEditingController(text: widget.book.imageUrl);
    _discountController =
        TextEditingController(text: widget.book.discount?.toString() ?? '0');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse(
            'https://book-app-backend-production-304e.up.railway.app/books/update/${widget.book.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'author': _authorController.text,
          'imageUrl': _imageUrlController.text,
          'category': _categoryController.text,
          'rating': widget.book.rating ?? 0,
          'price': double.parse(_priceController.text),
          'discount': int.parse(_discountController.text),
          'amount': widget.book.amount ?? 0,
          'isBestDeal': widget.book.isBestDeal ?? false,
          'isTopBook': widget.book.isTopBook ?? false,
          'isLatestBook': widget.book.isLatestBook ?? false,
          'isUpcomingBook': widget.book.isUpcomingBook ?? false,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showMessage('Book updated successfully');
          Navigator.pop(context, true);
        }
      } else {
        final errorMessage = response.statusCode == 422
            ? 'Invalid data format. Please check all fields.'
            : 'Failed to update book';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error updating book: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        title: Text(
          'Edit Book',
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
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: AppColors.primaryColor),
            onPressed: _isLoading ? null : _updateBook,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePreview(),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter a title'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _authorController,
                        label: 'Author',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter an author'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        maxLines: 3,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter a description'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please enter a price';
                          if (double.tryParse(value!) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _categoryController,
                        label: 'Category',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter a category'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _imageUrlController,
                        label: 'Image URL',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter an image URL'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _discountController,
                        label: 'Discount (%)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return null; // Allow empty discount
                          final number = int.tryParse(value!);
                          if (number == null || number < 0 || number > 100) {
                            return 'Please enter a valid discount (0-100)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          _imageUrlController.text,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.image_not_supported,
              size: 50.r,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14.sp,
        ),
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: Colors.white,
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        isDense: true,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (value) {
        if (label == 'Image URL') {
          setState(() {});
        }
      },
    );
  }
}
