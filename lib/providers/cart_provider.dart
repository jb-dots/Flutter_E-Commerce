import 'package:flutter/foundation.dart';
import 'package:ecommerce/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice =>
      (double.tryParse(product.price) ?? 0.0) * quantity.toDouble();
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);

  void addToCart(Product product) {
    final index = _items.indexWhere((e) => e.product.name == product.name);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.removeWhere((e) => e.product.name == product.name);
    notifyListeners();
  }

  void increaseQuantity(Product product) {
    final index = _items.indexWhere((e) => e.product.name == product.name);
    if (index >= 0) {
      _items[index].quantity += 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(Product product) {
    final index = _items.indexWhere((e) => e.product.name == product.name);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
