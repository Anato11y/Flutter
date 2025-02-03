// models/cart_item.dart
class CartItem {
  final String id;
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;
  final Map<String, dynamic> specifications;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.specifications,
    this.quantity = 1,
  });

  // Метод для создания объекта CartItem из JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      specifications: json['specifications'] as Map<String, dynamic>,
    );
  }

  // Метод для преобразования объекта CartItem в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'specifications': specifications,
    };
  }

  // Метод для создания копии объекта с измененными полями
  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? imageUrl,
    double? price,
    int? quantity,
    Map<String, dynamic>? specifications,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      specifications: specifications ?? this.specifications,
    );
  }

  // Метод для подсчета общей стоимости товара в корзине
  double get totalPrice => price * quantity;
}
