import 'dart:convert';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:http/http.dart' as http;

class BookRepository {
  static const String _baseUrl =
      'https://book-app-backend-production-304e.up.railway.app/books';
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // Default values for required fields
  static const String _defaultTitle = 'Untitled Book';
  static const String _defaultDescription = 'No description available';
  static const String _defaultAuthor = 'Unknown Author';
  static const String _defaultImageUrl =
      'https://via.placeholder.com/150?text=No+Image';
  static const String _defaultCategory = 'General';
  static const double _defaultRating = 0.0;
  static const double _defaultPrice = 0.0;

  Future<List<BookModel>> fetchBooks() async {
    print('Fetching books from backend...');
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  List<BookModel> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => _parseBook(json)).toList();
    } else {
      throw _handleError(response.statusCode);
    }
  }

  BookModel _parseBook(Map<String, dynamic> json) {
    return BookModel(
      id: _parseId(json['id']),
      title: _parseTitle(json['title']),
      description: _parseDescription(json['description']),
      author: _parseAuthor(json['author']),
      imageUrl: _parseImageUrl(json['imageUrl']),
      category: _parseCategory(json['category']),
      rating: _parseRating(json['rating']),
      price: _parsePrice(json['price']),
      discount: _parseDiscount(json['discount']),
      amount: _parseAmount(json['amount']),
      isBestDeal: json['isBestDeal'] == true,
      isTopBook: json['isTopBook'] == true,
      isLatestBook: json['isLatestBook'] == true,
      isUpcomingBook: json['isUpcomingBook'] == true,
    );
  }

  // Field parsers with proper type conversion
  String _parseId(dynamic id) => id?.toString() ?? '0';
  String _parseTitle(dynamic title) => title?.toString() ?? _defaultTitle;
  String _parseDescription(dynamic desc) =>
      desc?.toString() ?? _defaultDescription;
  String _parseAuthor(dynamic author) => author?.toString() ?? _defaultAuthor;
  String _parseImageUrl(dynamic url) => url?.toString() ?? _defaultImageUrl;
  String _parseCategory(dynamic category) =>
      category?.toString() ?? _defaultCategory;
  double _parseRating(dynamic rating) => _parseDouble(rating) ?? _defaultRating;
  double _parsePrice(dynamic price) => _parseDouble(price) ?? _defaultPrice;
  String? _parseDiscount(dynamic discount) => discount?.toString();
  int? _parseAmount(dynamic amount) => amount is int ? amount : null;

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Exception _handleError(dynamic error) {
    if (error is int) {
      switch (error) {
        case 400:
          return Exception('Bad request');
        case 401:
          return Exception('Unauthorized');
        case 403:
          return Exception('Forbidden');
        case 404:
          return Exception('Books not found');
        case 500:
          return Exception('Server error');
        default:
          return Exception('HTTP error $error');
      }
    }
    return Exception('Network error: ${error.toString()}');
  }

  Future<List<BookModel>> getBestDeals() async {
    final books = await fetchBooks();
    return books.where((book) => book.isBestDeal).toList();
  }

  Future<List<BookModel>> getTopBooks() async {
    final books = await fetchBooks();
    return books.where((book) => book.isTopBook).toList();
  }

  Future<List<BookModel>> getLatestBooks() async {
    final books = await fetchBooks();
    return books.where((book) => book.isLatestBook).toList();
  }

  Future<List<BookModel>> getUpcomingBooks() async {
    final books = await fetchBooks();
    return books.where((book) => book.isUpcomingBook).toList();
  }

  Future<List<BookModel>> getBooksByCategory(String category) async {
    final books = await fetchBooks();
    return books
        .where((book) => book.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
