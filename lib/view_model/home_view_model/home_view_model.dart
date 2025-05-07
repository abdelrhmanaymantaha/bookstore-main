import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bookstore_app/repositories/book_repository/provider/book_repository_provider.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/models/home_data/home_data.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  FutureOr<HomeData> build() async {
    final bestDeals = await ref.read(bookRepositoryProvider).getBestDeals();
    final topBooks = await ref.read(bookRepositoryProvider).getTopBooks();
    final latestBooks = await ref.read(bookRepositoryProvider).getLatestBooks();
    final upcomingBooks =
        await ref.read(bookRepositoryProvider).getUpcomingBooks();

    return HomeData(
      bestDeals: bestDeals,
      topBooks: topBooks,
      latestBooks: latestBooks,
      upcomingBooks: upcomingBooks,
    );
  }

  Future<List<BookModel>> getAllBooks() async {
    return ref.read(bookRepositoryProvider).fetchBooks();
  }

  Future<List<BookModel>> getBestDeals() async {
    return ref.watch(bookRepositoryProvider).getBestDeals();
  }

  Future<List<BookModel>> getTopBooks() async {
    return ref.watch(bookRepositoryProvider).getTopBooks();
  }

  Future<List<BookModel>> getLatestBooks() async {
    return ref.watch(bookRepositoryProvider).getLatestBooks();
  }

  Future<List<BookModel>> getUpcomingBooks() async {
    return ref.watch(bookRepositoryProvider).getUpcomingBooks();
  }
}
