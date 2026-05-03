import 'package:flutter/material.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/utils/category_utils.dart';
import 'package:hisabi/utils/date_formatter.dart';
import 'package:intl/intl.dart';

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.currency,
    required this.onDelete,
    required this.onTap,
  });

  final Expense expense;
  final String currency;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final catColor = getCategoryColor(expense.category);
    final catEmoji = getCategoryEmoji(expense.category);
    final colors = context.appColors;
    final amount = NumberFormat.currency(symbol: currency, decimalDigits: 0).format(expense.amount);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: kDanger,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Category icon bubble
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(catEmoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              // Title + category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expense.category,
                      style: TextStyle(fontSize: 12, color: colors.textSec),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount + date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kExpense),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(expense.date),
                    style: TextStyle(fontSize: 11, color: colors.textSec),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete expense?'),
          content: Text('Remove "${expense.title}" permanently.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: kDanger)),
            ),
          ],
        ),
      );
}
