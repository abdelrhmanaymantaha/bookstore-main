import 'package:flutter/material.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_snackbar.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  bool _isLoading = false;
  bool _isBestDeal = false;
  bool _isTopBook = false;
  bool _isLatestBook = false;
  bool _isUpcomingBook = false;

  late Category _selectedCategory;
  final List<Category> _categories = const [
    Category(
      name: 'Fiction',
      icon: Icons.auto_stories,
      color: Colors.blue,
    ),
    Category(
      name: 'Non-Fiction',
      icon: Icons.menu_book,
      color: Colors.green,
    ),
    Category(
      name: 'Science Fiction',
      icon: Icons.rocket_launch,
      color: Colors.purple,
    ),
    Category(
      name: 'Mystery',
      icon: Icons.psychology,
      color: Colors.indigo,
    ),
    Category(
      name: 'Romance',
      icon: Icons.favorite,
      color: Colors.pink,
    ),
    Category(
      name: 'Biography',
      icon: Icons.person,
      color: Colors.orange,
    ),
    Category(
      name: 'History',
      icon: Icons.history_edu,
      color: Colors.brown,
    ),
    Category(
      name: 'Science',
      icon: Icons.science,
      color: Colors.teal,
    ),
    Category(
      name: 'Technology',
      icon: Icons.computer,
      color: Colors.cyan,
    ),
    Category(
      name: 'Self-Help',
      icon: Icons.self_improvement,
      color: Colors.lightGreen,
    ),
    Category(
      name: 'Business',
      icon: Icons.business,
      color: Colors.blueGrey,
    ),
    Category(
      name: 'Art',
      icon: Icons.palette,
      color: Colors.deepPurple,
    ),
    Category(
      name: 'Cookbooks',
      icon: Icons.restaurant,
      color: Colors.red,
    ),
    Category(
      name: 'Travel',
      icon: Icons.flight_takeoff,
      color: Colors.amber,
    ),
    Category(
      name: 'Poetry',
      icon: Icons.format_quote,
      color: Colors.deepOrange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories[0];
    _categoryController.text = _selectedCategory.name;
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
    _amountController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _addBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            'https://book-app-backend-production-304e.up.railway.app/books/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'author': _authorController.text,
          'imageUrl': _imageUrlController.text,
          'category': _selectedCategory.name,
          'rating': double.parse(_ratingController.text),
          'price': double.parse(_priceController.text),
          'discount': int.parse(_discountController.text),
          'amount': int.parse(_amountController.text),
          'isBestDeal': _isBestDeal,
          'isTopBook': _isTopBook,
          'isLatestBook': _isLatestBook,
          'isUpcomingBook': _isUpcomingBook,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showMessage('Book added successfully');
          Navigator.pop(context, true);
        }
      } else {
        final errorMessage = response.statusCode == 422
            ? 'Invalid data format. Please check all fields.'
            : 'Failed to add book';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error adding book: $e', isError: true);
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
          'Add New Book',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: AppColors.primaryColor, size: 24.r),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: AppColors.primaryColor, size: 24.r),
            onPressed: _isLoading ? null : _addBook,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeWidth: 3,
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
                      SizedBox(height: 24.h),
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
                      _buildCategoryDropdown(),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _imageUrlController,
                        label: 'Image URL',
                        hintText:
                            'Enter the image link (e.g., https://example.com/image.jpg)',
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please enter an image URL';
                          final uri = Uri.tryParse(value!);
                          if (uri == null || !uri.hasAbsolutePath) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _discountController,
                        label: 'Discount (%)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return null;
                          final number = int.tryParse(value!);
                          if (number == null || number < 0 || number > 100) {
                            return 'Please enter a valid discount (0-100)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _amountController,
                        label: 'Amount',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please enter an amount';
                          if (int.tryParse(value!) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _ratingController,
                        label: 'Rating',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please enter a rating';
                          final number = double.tryParse(value!);
                          if (number == null || number < 0 || number > 5) {
                            return 'Please enter a valid rating (0-5)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Book Features',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildSwitchTile(
                        title: 'Best Deal',
                        value: _isBestDeal,
                        onChanged: (value) =>
                            setState(() => _isBestDeal = value),
                      ),
                      _buildSwitchTile(
                        title: 'Top Book',
                        value: _isTopBook,
                        onChanged: (value) =>
                            setState(() => _isTopBook = value),
                      ),
                      _buildSwitchTile(
                        title: 'Latest Book',
                        value: _isLatestBook,
                        onChanged: (value) =>
                            setState(() => _isLatestBook = value),
                      ),
                      _buildSwitchTile(
                        title: 'Upcoming Book',
                        value: _isUpcomingBook,
                        onChanged: (value) =>
                            setState(() => _isUpcomingBook = value),
                      ),
                      SizedBox(height: 24.h),
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
        child: _imageUrlController.text.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 50.r,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter image URL to preview',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              )
            : Image.network(
                _imageUrlController.text,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primaryColor,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 50.r,
                        color: Colors.red[300],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Invalid image URL',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
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
        hintText: hintText,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 12.sp,
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

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<Category>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category',
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
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
            filled: true,
            fillColor: Colors.white,
          ),
          items: _categories.map((category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Container(
                height: 40.r,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 32.r,
                      width: 32.r,
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 20.r,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (Category? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
                _categoryController.text = newValue.name;
              });
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.primaryColor,
            size: 28.r,
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          menuMaxHeight: 400.h,
          borderRadius: BorderRadius.circular(12.r),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
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
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
