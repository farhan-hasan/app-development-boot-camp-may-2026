import 'package:flutter/material.dart';
import 'package:hisabi/config/theme.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.name,
    required this.emoji,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String emoji;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : colors.cardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : colors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
