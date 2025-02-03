// models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId; // ✅ Изменяем на categoryId
  final String imageUrl;
  final String filterType;
  final int serviceLife;
  final double flowRate;
  final List<String> compatibility;
  final double? rating;
  final Map<String, dynamic> specifications;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId, // ✅ Изменяем на categoryId
    required this.imageUrl,
    required this.filterType,
    required this.serviceLife,
    required this.flowRate,
    required this.compatibility,
    this.rating = 0.0,
    this.specifications = const {},
  });

  /// Создание объекта из Firestore документа
  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return Product.fromMap(data, doc.id);
    } catch (e) {
      developer.log('Ошибка создания продукта: $e', name: 'ProductModel');
      rethrow; // Пробрасываем ошибку для обработки выше
    }
  }

  /// Создание объекта из Map
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map.getString(ProductKeys.name) ?? 'Неизвестный продукт',
      description:
          map.getString(ProductKeys.description) ?? 'Описание отсутствует',
      price: map.getDouble(ProductKeys.price), // ✅ Добавляем заглушку
      categoryId: map.getString(ProductKeys.categoryId) ??
          '', // ✅ Изменяем на categoryId и добавляем заглушку
      imageUrl: map.getString(ProductKeys.imageUrl) ??
          'https://example.com/default-product.jpg', // Заглушка для изображения
      filterType: map.getString(ProductKeys.filterType) ?? 'Не указано',
      serviceLife: map.getInt(ProductKeys.serviceLife),
      flowRate: map.getDouble(ProductKeys.flowRate), // ✅ Добавляем заглушку
      compatibility: map.getList(ProductKeys.compatibility),
      rating: map.getDouble(ProductKeys.rating), // Рейтинг может быть null
      specifications: map.getMap(ProductKeys.specifications),
    );
  }

  /// Преобразование объекта в Map для сохранения в Firestore
  Map<String, dynamic> toFirestore() => {
        ProductKeys.id: id,
        ProductKeys.name: name,
        ProductKeys.description: description,
        ProductKeys.price: price,
        ProductKeys.categoryId: categoryId, // ✅ Изменяем на categoryId
        ProductKeys.imageUrl: imageUrl,
        ProductKeys.filterType: filterType,
        ProductKeys.serviceLife: serviceLife,
        ProductKeys.flowRate: flowRate,
        ProductKeys.compatibility: compatibility,
        ProductKeys.rating: rating,
        ProductKeys.specifications: specifications,
      };

  /// Метод для копирования объекта с обновлением полей
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId, // ✅ Изменяем на categoryId
    String? imageUrl,
    String? filterType,
    int? serviceLife,
    double? flowRate,
    List<String>? compatibility,
    double? rating,
    Map<String, dynamic>? specifications,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId, // ✅ Изменяем на categoryId
      imageUrl: imageUrl ?? this.imageUrl,
      filterType: filterType ?? this.filterType,
      serviceLife: serviceLife ?? this.serviceLife,
      flowRate: flowRate ?? this.flowRate,
      compatibility: compatibility ?? this.compatibility,
      rating: rating ?? this.rating,
      specifications: specifications ?? this.specifications,
    );
  }
}

/// Константы для ключей Firestore
class ProductKeys {
  static const String id = 'id';
  static const String name = 'name';
  static const String description = 'description';
  static const String price = 'price';
  static const String categoryId = 'categoryId'; // ✅ Добавляем ключ categoryId
  static const String imageUrl = 'imageUrl';
  static const String filterType = 'filter_type';
  static const String serviceLife = 'service_life';
  static const String flowRate = 'flow_rate';
  static const String compatibility = 'compatibility';
  static const String rating = 'rating';
  static const String specifications = 'specifications';
}

/// Расширение для безопасного получения данных из Firestore
extension FirestoreData on Map<String, dynamic> {
  String? getString(String key) {
    final value = this[key];
    if (value is String) return value;
    return null; // Возвращаем null, если значение отсутствует или некорректно
  }

  double getDouble(String key) {
    final value = this[key];
    if (value is num) return value.toDouble();
    return 0.0; // Возвращаем заглушку, если значение отсутствует или некорректно
  }

  int getInt(String key) {
    final value = this[key];
    if (value is num) return value.toInt();
    return 0; // Возвращаем заглушку, если значение отсутствует или некорректно
  }

  List<String> getList(String key) {
    final value = this[key];
    if (value is List<dynamic>) {
      return value.map((e) => e.toString()).toList();
    }
    return []; // Возвращаем пустой список, если значение отсутствует или некорректно
  }

  Map<String, dynamic> getMap(String key) {
    final value = this[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    return {}; // Возвращаем пустой Map, если значение отсутствует или некорректно
  }
}
