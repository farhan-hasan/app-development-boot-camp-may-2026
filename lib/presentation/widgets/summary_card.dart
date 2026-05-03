import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.subtext,
    required this.gradientColors,
    required this.shadowColor,
    required this.currency,
    this.onTap,
    this.flex = 1,
    this.amountFontSize = 26,
  });

  final String label;
  final double amount;
  final String subtext;
  final List<Color> gradientColors;
  final Color shadowColor;
  final String currency;
  final VoidCallback? onTap;
  final int flex;
  final double amountFontSize;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(symbol: currency, decimalDigits: 0).format(amount);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xBFFFFFFF),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatted,
              style: TextStyle(
                fontSize: amountFontSize,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0x99FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
