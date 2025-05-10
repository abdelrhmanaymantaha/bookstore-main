class LibraryBook {
  final String author;
  final String title;
  final bool available;
  final int bookid;

  LibraryBook({
    required this.author,
    required this.title,
    required this.available,
    required this.bookid,
  });

  factory LibraryBook.fromJson(Map<String, dynamic> json) {
    return LibraryBook(
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      available: json['available'] ?? false,
      bookid: json['bookid'] ?? 0,
    );
  }
}
