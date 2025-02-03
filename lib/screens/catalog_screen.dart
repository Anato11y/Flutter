// screens/catalog_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_shop/models/product.dart';
import 'package:provider/provider.dart';
import 'package:online_shop/widgets/product_card.dart';
import '../providers/products_provider.dart';

class CatalogScreen extends StatefulWidget {
  final String categoryId; // ✅ Изменяем на categoryId
  const CatalogScreen({super.key, required this.categoryId});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _categoryTitle; // ✅ Добавляем поле для хранения названия категории

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategoryTitle(); // ✅ Загружаем название категории при инициализации
  }

  Future<void> _loadProducts() async {
    try {
      await Provider.of<ProductsProvider>(context, listen: false).fetchProducts(
          categoryId: widget.categoryId); // ✅ Передаем categoryId
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCategoryTitle() async {
    try {
      final categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .get();

      // Явное преобразование к String?
      final name =
          categoryDoc.data()?['name']?.toString(); // ✅ Преобразуем к String?
      setState(() => _categoryTitle = name ?? 'Без категории');
    } catch (e) {
      debugPrint('Ошибка получения категории: $e');
      setState(() => _categoryTitle = 'Ошибка категории');
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductsProvider>(context).products;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _categoryTitle ?? 'Без категории'), // ✅ Используем _categoryTitle
        centerTitle: true,
      ),
      body: _buildBody(products),
    );
  }

  Widget _buildBody(List<Product> products) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    if (products.isEmpty) {
      return _buildEmptyState();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Ошибка загрузки',
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: _loadProducts,
            child: const Text('Повторить попытку'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('Товары не найдены'),
    );
  }
}
