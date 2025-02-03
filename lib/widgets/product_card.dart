// widgets/product_card.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Проверяем, что экран ещё существует
        if (!context.mounted) return;

        // Переход к экрану продукта
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10), // ✅ Добавили const
                ),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (ctx, error, stackTrace) => Container(
                    color: Colors
                        .grey[200], // Заглушка при ошибке загрузки изображения
                    child: const Icon(
                        Icons.image_not_supported), // ✅ Добавили const
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8), // ✅ Добавили const
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2, // Ограничиваем количество строк для названия
                    overflow:
                        TextOverflow.ellipsis, // Обрезаем текст с многоточием
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, // ✅ Добавили const
                    ),
                  ),
                  Text(
                    "${product.price.toStringAsFixed(0)} ₽", // Отображаем цену без десятичных знаков
                    style: const TextStyle(
                      color: Colors.green, // ✅ Добавили const
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
