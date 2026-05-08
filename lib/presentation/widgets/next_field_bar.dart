import 'package:flutter/material.dart';
import 'package:hisabi/config/theme.dart';

class NextFieldBar extends StatelessWidget {
  const NextFieldBar({super.key, required this.colors, required this.onNext});
  final AppColors colors;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onNext,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Next', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kPrimary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_right_rounded, color: kPrimary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
