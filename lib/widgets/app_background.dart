import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String backgroundUrl;

  const AppBackground({
    super.key,
    required this.child,
    this.backgroundUrl = 'assets/images/phon.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // Указываем направление текста
      child: Stack(
        children: [
          // Фоновое изображение
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(backgroundUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withAlpha(0x26), // 15% прозрачности
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Основной контент
          child,
        ],
      ),
    );
  }
}
