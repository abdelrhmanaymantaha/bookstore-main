import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bookstore_app/models/book_model/book_model.dart';

part 'cart_view_model.g.dart';

class CartItem {
  final BookModel book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});
}

@riverpod
class CartViewModel extends _$CartViewModel {
  static final List<CartItem> _cartItems = [];

  @override
  List<CartItem> build() {
    return _cartItems;
  }

  void addToCart(BookModel book) {
    final existingItemIndex =
        _cartItems.indexWhere((item) => item.book.id == book.id);
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity++;
    } else {
      _cartItems.add(CartItem(book: book));
    }
    state = List.from(_cartItems);
  }

  void removeFromCart(BookModel book) {
    _cartItems.removeWhere((item) => item.book.id == book.id);
    state = List.from(_cartItems);
  }

  void increaseQuantity(BookModel book) {
    final itemIndex = _cartItems.indexWhere((item) => item.book.id == book.id);
    if (itemIndex != -1) {
      _cartItems[itemIndex].quantity++;
      state = List.from(_cartItems);
    }
  }

  void decreaseQuantity(BookModel book) {
    final itemIndex = _cartItems.indexWhere((item) => item.book.id == book.id);
    if (itemIndex != -1) {
      if (_cartItems[itemIndex].quantity > 1) {
        _cartItems[itemIndex].quantity--;
      } else {
        _cartItems.removeAt(itemIndex);
      }
      state = List.from(_cartItems);
    }
  }

  double getTotalPrice() {
    return _cartItems.fold(
        0, (total, item) => total + (item.book.price * item.quantity));
  }
}
