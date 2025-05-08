import 'package:bookstore_app/core/constants/app_colors.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/view/home/widgets/book_vertical_card.dart';
import 'package:bookstore_app/view/home/widgets/carousel_widget.dart';
import 'package:bookstore_app/view/home/widgets/section_header.dart';
import 'package:bookstore_app/view_model/home_view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookstore_app/core/router/router_names.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _hasError = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<BookModel> _searchResults = [];
  bool _isSearchLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
      return;
    }

    setState(() {
      _isSearchLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final allBooks =
          await ref.read(homeViewModelProvider.notifier).getAllBooks();
      final results = allBooks
          .where((book) =>
              book.title.toLowerCase().contains(query.toLowerCase()) ||
              (book.author.toLowerCase().contains(query.toLowerCase())))
          .toList();

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearchLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to search: ${e.toString()}';
          _isSearchLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToBookDetails(BookModel book) async {
    context.pushNamed(
      RouterNames.bookDetail,
      extra: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: _isSearching ? _buildSearchAppBar() : _buildMainAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: _isSearching ? _buildSearchResults() : _buildHomeContent(),
        ),
      ),
    );
  }

  AppBar _buildMainAppBar() {
    return AppBar(
      backgroundColor: AppColors.secondaryColor,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'Happy reading!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _isSearching = true),
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.search,
                size: 24.r,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      backgroundColor: AppColors.secondaryColor,
      elevation: 0,
      title: Container(
        height: 45.h,
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
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 16.sp,
            height: 1.0,
          ),
          controller: _searchController,
          autofocus: true,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'Search by title or author...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16.sp,
              height: 1.0,
            ),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            suffixIcon: IconButton(
              icon: Icon(Icons.close, color: AppColors.primaryColor),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchResults = [];
                });
              },
            ),
          ),
          onChanged: (value) {
            try {
              _performSearch(value);
            } catch (e) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Search failed: ${e.toString()}';
              });
            }
          },
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            _searchResults = [];
          });
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearchLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64.r,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Type to search for books',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
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
              'No results found for "${_searchController.text}"',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final book = _searchResults[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
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
              onTap: () => _navigateToBookDetails(book),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          book.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.book,
                              size: 30.r,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: AppColors.primaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            book.author,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  book.category,
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '\$${book.price}',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
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
      },
    );
  }

  Widget _buildBookList(List<BookModel> books, String title,
      Function(List<BookModel>) onSeeMore) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeMore: () => onSeeMore(books),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 294.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              return Container(
                width: 180.w,
                margin: EdgeInsets.only(right: 16.w),
                child: BookVerticalCard(
                  book: books[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _refreshHomeContent,
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Consumer(
              builder: (context, ref, child) {
                final homeState = ref.watch(homeViewModelProvider);
                return homeState.when(
                  data: (data) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.bestDeals.isNotEmpty) ...[
                          SectionHeader(
                            title: 'Best Deals',
                            onSeeMore: () {
                              context.pushNamed(
                                RouterNames.seeMore,
                                extra: {
                                  'title': 'Best Deals',
                                  'books': data.bestDeals,
                                },
                              );
                            },
                          ),
                          SizedBox(height: 16.h),
                          CarouselWidget(books: data.bestDeals),
                        ],
                        SizedBox(height: 24.h),
                        _buildBookList(
                          data.topBooks,
                          'Top Books',
                          (books) => context.pushNamed(
                            RouterNames.seeMore,
                            extra: {
                              'title': 'Top Books',
                              'books': books,
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                        _buildBookList(
                          data.latestBooks,
                          'Latest Books',
                          (books) => context.pushNamed(
                            RouterNames.seeMore,
                            extra: {
                              'title': 'Latest Books',
                              'books': books,
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                        _buildBookList(
                          data.upcomingBooks,
                          'Upcoming Books',
                          (books) => context.pushNamed(
                            RouterNames.seeMore,
                            extra: {
                              'title': 'Upcoming Books',
                              'books': books,
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  error: (error, stackTrace) {
                    setState(() {
                      _hasError = true;
                      _errorMessage = error.toString();
                    });
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.r,
                color: Colors.red[400],
              ),
              SizedBox(height: 16.h),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                _errorMessage ?? 'Failed to load content',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _refreshHomeContent();
                },
                icon: Icon(Icons.refresh, size: 20.r),
                label: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshHomeContent() async {
    try {
      ref.invalidate(homeViewModelProvider);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to refresh: ${e.toString()}';
        });
      }
    }
  }
}
