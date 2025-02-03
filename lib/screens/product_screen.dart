// screens/product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Добавляем импорт Firestore

class ProductScreen extends StatefulWidget {
  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String? _categoryName; // ✅ Добавляем поле для хранения названия категории

  @override
  void initState() {
    super.initState();
    _loadCategoryName(); // ✅ Загружаем название категории при инициализации
  }

  Future<void> _loadCategoryName() async {
    try {
      if (widget.product.categoryId.isEmpty) {
        setState(() => _categoryName = 'Без категории');
        return;
      }

      final categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.product.categoryId)
          .get();

      setState(
          () => _categoryName = categoryDoc.data()?['name'] ?? 'Без категории');
    } catch (e) {
      debugPrint('Ошибка загрузки категории: $e');
      setState(() => _categoryName = 'Ошибка категории');
    }
  }

  Future<void> _shareProduct() async {
    try {
      final message = '''
🚰 ${widget.product.name}  
💧 Тип фильтрации: ${widget.product.filterType}  
⏳ Срок службы: ${widget.product.serviceLife} мес.  
💦 Производительность: ${widget.product.flowRate} л/час  
💰 Цена: ${widget.product.price.toStringAsFixed(0)} ₽  
${widget.product.description}  
''';

      await Share.share(
        message,
        subject: 'Рекомендую этот фильтр для воды',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке: ${e.toString()}')),
      );
    }
  }

  void _addToCart(CartProvider cartProvider) {
    cartProvider.addItem(
      widget.product.id,
      widget.product.name,
      widget.product.imageUrl,
      widget.product.price,
      specifications: {
        'filterType': widget.product.filterType,
        'serviceLife': widget.product.serviceLife,
      },
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Фильтр добавлен в корзину").animate().fadeIn(),
        backgroundColor: AppColors.primary.withAlpha(0xE5), // 0.9 opacity
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSpecificationRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.imageUrl,
              height: 300,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                  child: child,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildRatingStars(widget.product.rating ?? 0.0),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.product.price.toStringAsFixed(0)} ₽',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Описание'),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                      'Категория'), // ✅ Добавляем секцию категории
                  Text(
                    _categoryName ?? 'Загрузка...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Основные характеристики'),
                  _buildSpecificationRow(
                      'Тип фильтрации', widget.product.filterType),
                  _buildSpecificationRow('Срок службы',
                      '${widget.product.serviceLife} мес. (${(widget.product.serviceLife / 12).toStringAsFixed(1)} лет)'),
                  _buildSpecificationRow(
                      'Производительность', '${widget.product.flowRate} л/час'),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Совместимость'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.product.compatibility
                        .map((system) => Chip(
                              label: Text(system),
                              backgroundColor:
                                  AppColors.secondary.withAlpha(0x19),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.secondary
                                      .withAlpha((0.3 * 255).round()),
                                  width: 1,
                                ),
                              ),
                              labelStyle:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Технические параметры'),
                  ...widget.product.specifications.entries.map(
                    (e) => _buildSpecificationRow(e.key, e.value.toString()),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text(
                      'Добавить в корзину',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    onPressed: () => _addToCart(cartProvider),
                  ).animate().scale(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );

  /// Отображение рейтинговых звезд
  Widget _buildRatingStars(double rating) => Row(
        children: List.generate(
          5,
          (index) => Icon(
            index < rating.floor() ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 20,
          ),
        ),
      );
}
