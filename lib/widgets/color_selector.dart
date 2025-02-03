import 'package:flutter/material.dart';

class ColorSelector extends StatefulWidget {
  final List<String> colors;
  final Function(String) onSelected;

  const ColorSelector(
      {super.key, required this.colors, required this.onSelected});

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  String? selectedColor;

  Color _parseColor(String color) {
    try {
      if (color.isEmpty || !color.startsWith("#") || color.length != 7) {
        return Colors
            .grey; // ✅ Используем серый цвет по умолчанию, если цвет некорректный
      }
      return Color(int.parse(color.replaceAll("#", "0xFF")));
    } catch (e) {
      debugPrint("Ошибка парсинга цвета: $color, ошибка: $e");
      return Colors.grey; // ✅ Используем серый цвет при ошибке
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: widget.colors.map((color) {
        bool isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedColor = color;
            });
            widget.onSelected(color);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _parseColor(color), // ✅ Безопасное преобразование цвета
              shape: BoxShape.circle,
              border:
                  isSelected ? Border.all(width: 3, color: Colors.black) : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
