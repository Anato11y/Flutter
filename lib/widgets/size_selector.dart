import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {
  final List<String> sizes;
  final Function(String) onSelected;

  const SizeSelector(
      {super.key, required this.sizes, required this.onSelected});

  @override
  State<SizeSelector> createState() =>
      _SizeSelectorState(); // ✅ Используем стандартное объявление
}

class _SizeSelectorState extends State<SizeSelector> {
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: widget.sizes.map((size) {
        bool isSelected = size == selectedSize;
        return ChoiceChip(
          label: Text(size),
          selected: isSelected,
          onSelected: (selected) {
            if (selectedSize != size) {
              setState(() {
                selectedSize = size;
              });
              widget.onSelected(size);
            }
          },
        );
      }).toList(),
    );
  }
}
