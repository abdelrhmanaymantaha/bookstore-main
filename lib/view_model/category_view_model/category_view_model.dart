import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bookstore_app/repositories/book_repository/provider/book_repository_provider.dart';

part 'category_view_model.g.dart';

@riverpod
class CategoryViewModel extends _$CategoryViewModel {
  @override
  FutureOr<List<BookModel>> build({required String category}) {
    return ref.watch(bookRepositoryProvider).getBooksByCategory(category);
  }
}
