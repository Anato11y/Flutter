// widgets/cart_item_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение продукта
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.background,
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Информация о продукте
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartItem.price.toStringAsFixed(0)} ₽ × ${cartItem.quantity}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (cartItem.specifications.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        cartItem.specifications.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(', '),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary
                              .withAlpha(0xB3), // 0.7 opacity
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Контроллер количества
            _QuantityController(
              quantity: cartItem.quantity,
              onDecrement: () => cartProvider.updateQuantity(
                cartItem.id,
                cartItem.quantity - 1,
              ),
              onIncrement: () => cartProvider.updateQuantity(
                cartItem.id,
                cartItem.quantity + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityController extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityController({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: AppColors.secondary,
          ),
          onPressed: quantity > 1
              ? onDecrement
              : null, // Отключаем кнопку, если количество <= 1
        ),
        Text(
          quantity.toString(),
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: AppColors.primary,
          ),
          onPressed: onIncrement,
        ),
      ],
    ).animate().fadeIn(); // Добавляем анимацию появления
  }
}
