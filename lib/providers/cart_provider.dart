// providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  // Получение списка товаров в корзине
  List<CartItem> get items => List.unmodifiable(_items);

  /// Добавление товара в корзину
  void addItem(
    String productId,
    String name,
    String imageUrl,
    double price, {
    required Map<String, dynamic> specifications,
  }) {
    if (productId.isEmpty || name.isEmpty || imageUrl.isEmpty || price <= 0) {
      return; // Защита от некорректных данных
    }

    final existingIndex = _findItemIndexByProductId(productId);
    if (existingIndex != -1) {
      // Если товар уже есть в корзине, увеличиваем количество
      _updateItemQuantity(existingIndex, _items[existingIndex].quantity + 1);
    } else {
      // Иначе добавляем новый товар
      _items.add(
        CartItem(
          id: DateTime.now().toString(),
          productId: productId,
          name: name,
          imageUrl: imageUrl,
          price: price,
          quantity: 1,
          specifications: specifications,
        ),
      );
    }
    notifyListeners();
  }

  /// Обновление количества товара
  void updateQuantity(String itemId, int newQuantity) {
    if (itemId.isEmpty || newQuantity < 0) {
      return; // Защита от некорректных данных
    }

    final index = _findItemIndexById(itemId);
    if (index != -1) {
      if (newQuantity > 0) {
        // Обновляем количество, если оно больше 0
        _updateItemQuantity(index, newQuantity);
      } else {
        // Удаляем товар, если количество равно 0
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Удаление товара из корзины
  void removeItem(String itemId) {
    if (itemId.isEmpty) {
      return; // Защита от пустого ID
    }

    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  /// Очистка корзины
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Общая сумма товаров в корзине
  double get totalAmount {
    return _items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  /// Количество товаров в корзине
  int get itemCount {
    return _items.fold<int>(
      0,
      (count, item) => count + item.quantity,
    );
  }

  /// Поиск индекса товара по ID
  int _findItemIndexById(String itemId) {
    return _items.indexWhere((item) => item.id == itemId);
  }

  /// Поиск индекса товара по product ID
  int _findItemIndexByProductId(String productId) {
    return _items.indexWhere((item) => item.productId == productId);
  }

  /// Обновление количества товара по индексу
  void _updateItemQuantity(int index, int newQuantity) {
    _items[index] = _items[index].copyWith(quantity: newQuantity);
  }
}
