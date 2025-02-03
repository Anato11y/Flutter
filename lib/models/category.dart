// models/category.dart
class Category {
  final String id;
  final String name;
  final String imageUrl;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.productCount,
  });

  // Метод для создания объекта Category из JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      productCount: json['productCount'] as int,
    );
  }

  // Метод для преобразования объекта Category в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'productCount': productCount,
    };
  }
}
