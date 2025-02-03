// providers/products_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // Селекторы для доступа к данным
  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Загрузка товаров из Firestore
  Future<void> fetchProducts({String? categoryId}) async {
    // ✅ Изменяем на categoryId
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Query query = FirebaseFirestore.instance.collection('products');

      // Фильтрация по категории через categoryId
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId',
            isEqualTo: categoryId); // ✅ Изменяем на categoryId
      }

      query = query.limit(20);

      final snapshot = await query.get();
      _products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id); // Используем метод fromMap
      }).toList();

      _error = null;
    } on FirebaseException catch (e) {
      _error = 'Ошибка Firestore: ${e.code}';
    } catch (e) {
      _error = 'Ошибка: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Поиск товаров по запросу
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return [..._products];

    return _products.where((product) {
      final nameMatch =
          product.name.toLowerCase().contains(query.toLowerCase());
      final descriptionMatch =
          product.description.toLowerCase().contains(query.toLowerCase());
      return nameMatch || descriptionMatch;
    }).toList();
  }

  // Фильтрация товаров по параметрам
  List<Product> filterProducts({
    String? categoryId, // ✅ Изменяем на categoryId
    double? minPrice,
    double? maxPrice,
    String? sortField,
    bool ascending = true,
  }) {
    List<Product> filteredProducts = [..._products];

    // Фильтрация по категории через categoryId
    if (categoryId != null && categoryId.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) =>
              product.categoryId == categoryId) // ✅ Изменяем на categoryId
          .toList();
    }

    // Фильтрация по цене
    if (minPrice != null && maxPrice != null) {
      filteredProducts = filteredProducts
          .where((product) =>
              product.price >= minPrice && product.price <= maxPrice)
          .toList();
    }

    // Сортировка товаров
    if (sortField != null && sortField.isNotEmpty) {
      filteredProducts.sort((a, b) {
        if (sortField == 'price') {
          return ascending
              ? a.price.compareTo(b.price)
              : b.price.compareTo(a.price);
        } else if (sortField == 'rating') {
          // Явная обработка null
          final aRating = a.rating ?? 0.0;
          final bRating = b.rating ?? 0.0;
          return ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        }
        return 0; // Если поле сортировки не определено
      });
    }

    return filteredProducts;
  }

  // Получение товара по ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null; // Возвращаем null, если товар не найден
    }
  }
}
