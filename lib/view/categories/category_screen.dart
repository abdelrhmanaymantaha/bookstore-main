// ignore_for_file: unnecessary_null_comparison

import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/view/home/widgets/book_vertical_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bookstore_app/core/constants/app_colors.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    super.key,
    required this.title,
    required this.books,
  });
  final String title;
  final List<BookModel> books;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late List<BookModel> _filteredBooks;
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'title'; // Default sort by title
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing CategoryScreen with ${widget.books.length} books');
    _initializeBooks();
  }

  Future<void> _initializeBooks() async {
    setState(() => _isLoading = true);
    try {
      if (widget.books.isEmpty) {
        debugPrint('Warning: No books provided to CategoryScreen');
      }
      _filteredBooks = List.from(widget.books);
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate loading
      _sortBooks();
    } catch (e) {
      debugPrint('Error initializing books: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void didUpdateWidget(CategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.books != widget.books) {
      debugPrint('Books list updated. New count: ${widget.books.length}');
      _initializeBooks();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _sortBooks() {
    if (_filteredBooks.isEmpty) {
      debugPrint('No books to sort');
      return;
    }

    try {
      debugPrint('Sorting books by $_sortBy');
      switch (_sortBy) {
        case 'title':
          _filteredBooks.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'price':
          _filteredBooks.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'rating':
          _filteredBooks.sort((a, b) => b.rating.compareTo(a.rating));
          break;
      }
      debugPrint('Sort complete. First book: ${_filteredBooks.first.title}');
    } catch (e) {
      debugPrint('Error sorting books: $e');
      // Reset to original order if sorting fails
      _filteredBooks = List.from(widget.books);
    }
  }

  void _filterBooks(String query) {
    debugPrint('Search query: $query');
    debugPrint('Total books before filter: ${widget.books.length}');

    if (widget.books.isEmpty) {
      debugPrint('No books available to filter');
      return;
    }

    try {
      setState(() {
        if (query.isEmpty) {
          _filteredBooks = List.from(widget.books);
          debugPrint('Empty query - showing all books');
        } else {
          final lowercaseQuery = query.toLowerCase();
          _filteredBooks = widget.books.where((book) {
            try {
              final matchesTitle =
                  book.title.toLowerCase().contains(lowercaseQuery);
              final matchesAuthor =
                  book.author.toLowerCase().contains(lowercaseQuery);
              final matchesCategory =
                  book.category.toLowerCase().contains(lowercaseQuery);

              debugPrint('Checking book: ${book.title}');
              debugPrint('Matches title: $matchesTitle');
              debugPrint('Matches author: $matchesAuthor');
              debugPrint('Matches category: $matchesCategory');

              return matchesTitle || matchesAuthor || matchesCategory;
            } catch (e) {
              debugPrint('Error checking book ${book.title}: $e');
              return false;
            }
          }).toList();
          debugPrint('Filtered books count: ${_filteredBooks.length}');
        }
        _sortBooks();
      });
    } catch (e) {
      debugPrint('Error filtering books: $e');
      // Reset to original list if filtering fails
      setState(() {
        _filteredBooks = List.from(widget.books);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'Building CategoryScreen with ${_filteredBooks.length} filtered books');

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        title: Text(
          widget.title,
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
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                // Search Bar
                Container(
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
                    onChanged: (value) {
                      debugPrint('Search text changed: $value');
                      _filterBooks(value);
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),
                SizedBox(height: 16.h),
                // Sort Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSortButton('Title', 'title'),
                    _buildSortButton('Price', 'price'),
                    _buildSortButton('Rating', 'rating'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_isLoading) {
                  return Center(
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
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (widget.books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64.r,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No Books Available',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'This category is empty',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64.r,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No Results Found',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Try different search terms',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: _filteredBooks.length,
                  itemBuilder: (context, index) {
                    return BookVerticalCard(book: _filteredBooks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String sortValue) {
    final isSelected = _sortBy == sortValue;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _sortBy = sortValue;
          _sortBooks();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryColor : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

// Source https://github.com/flutter/flutter/issues/55290#issuecomment-703117248
class SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight
    extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis.
  ///
  /// All of the arguments must not be null. The `mainAxisSpacing` and
  /// `crossAxisSpacing` arguments must not be negative. The `crossAxisCount`
  /// and `childAspectRatio` arguments must be greater than zero.
  const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.height = 56.0,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(height != null && height > 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The height of the crossAxis.
  final double height;

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(height > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = height;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
      SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.height != height;
  }
}
