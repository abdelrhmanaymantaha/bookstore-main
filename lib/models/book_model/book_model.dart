
class BookModel {
  final String id;
  final String title;
  final String description;
  final String author;
  final String imageUrl;
  final String category;
  final double rating;
  final double price;
  final String? discount;
  final int? amount;
  final bool isBestDeal;
  final bool isTopBook;
  final bool isLatestBook;
  final bool isUpcomingBook;

  const BookModel({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.price,
    this.discount,
    this.amount,
    required this.isBestDeal,
    required this.isTopBook,
    required this.isLatestBook,
    required this.isUpcomingBook,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      discount: json['discount'] as String?,
      amount: json['amount'] as int?,
      isBestDeal: json['isBestDeal'] as bool,
      isTopBook: json['isTopBook'] as bool,
      isLatestBook: json['isLatestBook'] as bool,
      isUpcomingBook: json['isUpcomingBook'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'price': price,
      'discount': discount,
      'amount': amount,
      'isBestDeal': isBestDeal,
      'isTopBook': isTopBook,
      'isLatestBook': isLatestBook,
      'isUpcomingBook': isUpcomingBook,
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    String? imageUrl,
    String? category,
    double? rating,
    double? price,
    String? discount,
    int? amount,
    bool? isBestDeal,
    bool? isTopBook,
    bool? isLatestBook,
    bool? isUpcomingBook,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      amount: amount ?? this.amount,
      isBestDeal: isBestDeal ?? this.isBestDeal,
      isTopBook: isTopBook ?? this.isTopBook,
      isLatestBook: isLatestBook ?? this.isLatestBook,
      isUpcomingBook: isUpcomingBook ?? this.isUpcomingBook,
    );
  }
}
