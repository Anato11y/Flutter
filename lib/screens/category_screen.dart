// screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:online_shop/models/user.dart';
import 'package:online_shop/screens/catalog_screen.dart'; // ✅ Импортируем CatalogScreen

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      body: StreamBuilder<QuerySnapshot<Category>>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .withConverter(
              fromFirestore: (snapshot, _) => Category.fromFirestore(snapshot),
              toFirestore: (category, _) => category.toMap(),
            )
            .orderBy('order')
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('Firestore Error: ${snapshot.error}');
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Категории не найдены'));
          }
          final categories =
              snapshot.data!.docs.map((doc) => doc.data()).toList();
          return _CategoryGrid(categories: categories);
        },
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (ctx, i) => _CategoryCard(category: categories[i]),
    ).animate().fadeIn(); // Добавляем анимацию появления
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Переход к каталогу товаров выбранной категории
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CatalogScreen(
                  categoryId: category.id), // ✅ Передаем categoryId
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
              Image.network(
                category.imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) => Icon(
                  Icons.category_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            else
              Icon(
                Icons.category_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    ).animate().scale(); // Добавляем анимацию масштабирования
  }
}

/// Модель категории
class Category {
  final String id; // ✅ Добавляем уникальный ID категории
  final String name;
  final int order;
  final String? imageUrl;

  const Category({
    required this.id, // ✅ Требуется указать ID
    required this.name,
    required this.order,
    this.imageUrl,
  });

  /// Создание объекта из Firestore документа
  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Category(
      id: doc.id, // ✅ Используем ID документа
      name: data.getString(CategoryKeys.name) ?? '',
      order: data.getInt(CategoryKeys.order),
      imageUrl: data.getString(CategoryKeys.imageUrl),
    );
  }

  /// Преобразование объекта в Map для сохранения в Firestore
  Map<String, dynamic> toMap() => {
        CategoryKeys.id: id, // ✅ Сохраняем ID
        CategoryKeys.name: name,
        CategoryKeys.order: order,
        CategoryKeys.imageUrl: imageUrl,
      };
}

/// Константы для ключей Firestore
class CategoryKeys {
  static const String id = 'id'; // ✅ Добавляем ключ для ID
  static const String name = 'name';
  static const String order = 'order';
  static const String imageUrl = 'imageUrl';
}
