import 'package:bookstore_app/models/book_model/book_model.dart';

class HomeData {
  final List<BookModel> bestDeals;
  final List<BookModel> topBooks;
  final List<BookModel> latestBooks;
  final List<BookModel> upcomingBooks;

  const HomeData({
    required this.bestDeals,
    required this.topBooks,
    required this.latestBooks,
    required this.upcomingBooks,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      bestDeals: (json['bestDeals'] as List)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topBooks: (json['topBooks'] as List)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      latestBooks: (json['latestBooks'] as List)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingBooks: (json['upcomingBooks'] as List)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bestDeals': bestDeals.map((e) => e.toJson()).toList(),
      'topBooks': topBooks.map((e) => e.toJson()).toList(),
      'latestBooks': latestBooks.map((e) => e.toJson()).toList(),
      'upcomingBooks': upcomingBooks.map((e) => e.toJson()).toList(),
    };
  }

  HomeData copyWith({
    List<BookModel>? bestDeals,
    List<BookModel>? topBooks,
    List<BookModel>? latestBooks,
    List<BookModel>? upcomingBooks,
  }) {
    return HomeData(
      bestDeals: bestDeals ?? this.bestDeals,
      topBooks: topBooks ?? this.topBooks,
      latestBooks: latestBooks ?? this.latestBooks,
      upcomingBooks: upcomingBooks ?? this.upcomingBooks,
    );
  }
}
