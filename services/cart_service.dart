import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// CartService — ChangeNotifier para gerenciar estado do carrinho.
/// Integrado com Provider para reatividade em toda a árvore de widgets.
class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalValue =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;

  // ─────────────────────────────────────────

  void addProduct(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    _items.removeWhere((i) => i.product.id == product.id);
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeProduct(product);
      return;
    }
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
