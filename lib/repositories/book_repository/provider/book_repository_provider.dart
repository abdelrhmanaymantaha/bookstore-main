import 'package:bookstore_app/repositories/book_repository/book_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book_repository_provider.g.dart';

@riverpod
BookRepository bookRepository(Ref ref) {
  return BookRepository();
}
