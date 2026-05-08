import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/utils/category_utils.dart';
import 'package:hisabi/utils/date_formatter.dart';
import 'package:intl/intl.dart';

Future<void> showExpenseDetailSheet(
  BuildContext context,
  Expense expense,
  String currency,
  VoidCallback onDelete, {
  List<Map<String, dynamic>> extraCategories = const [],
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ExpenseDetailSheet(
      expense: expense,
      currency: currency,
      onDelete: onDelete,
      extraCategories: extraCategories,
    ),
  );
}

class _ExpenseDetailSheet extends StatefulWidget {
  const _ExpenseDetailSheet({
    required this.expense,
    required this.currency,
    required this.onDelete,
    this.extraCategories = const [],
  });
  final Expense expense;
  final String currency;
  final VoidCallback onDelete;
  final List<Map<String, dynamic>> extraCategories;

  @override
  State<_ExpenseDetailSheet> createState() => _ExpenseDetailSheetState();
}

class _ExpenseDetailSheetState extends State<_ExpenseDetailSheet> {
  final _confirmingDelete = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _confirmingDelete.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final catColor = getCategoryColor(widget.expense.category, extra: widget.extraCategories);
    final catEmoji = getCategoryEmoji(widget.expense.category, extra: widget.extraCategories);
    final amount = NumberFormat.currency(symbol: widget.currency, decimalDigits: 0).format(widget.expense.amount);

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: catColor.withValues(alpha: 0.2), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(catEmoji, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(height: 12),

          Text(amount, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kExpense, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(widget.expense.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: catColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: catColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(widget.expense.category, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: catColor)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailRow(icon: Icons.calendar_today_outlined, label: 'Date', value: formatDate(widget.expense.date), colors: colors),
                Divider(color: colors.border, height: 1),
                if (widget.expense.isGrouped)
                  _ItemsBreakdown(expense: widget.expense, currency: widget.currency, colors: colors)
                else
                  _DetailRow(icon: Icons.attach_money_outlined, label: 'Amount', value: amount, colors: colors),
                if (widget.expense.note != null && widget.expense.note!.isNotEmpty) ...[
                  Divider(color: colors.border, height: 1),
                  _DetailRow(icon: Icons.info_outline, label: 'Note', value: widget.expense.note!, colors: colors),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _confirmingDelete,
                    builder: (context, confirming, _) {
                      return GestureDetector(
                        onTap: () {
                          if (confirming) {
                            Navigator.pop(context);
                            widget.onDelete();
                          } else {
                            _confirmingDelete.value = true;
                            Future.delayed(const Duration(seconds: 3), () {
                              if (mounted) _confirmingDelete.value = false;
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 50,
                          decoration: BoxDecoration(
                            color: confirming ? kDanger : colors.cardAlt,
                            borderRadius: BorderRadius.circular(14),
                            border: confirming ? null : Border.all(color: kDanger.withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            confirming ? 'Tap to confirm' : 'Delete',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: confirming ? Colors.white : kDanger,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/edit-expense', extra: widget.expense);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [kPrimaryLight, kPrimary]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: kPrimary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('Edit Expense', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value, required this.colors});
  final IconData icon;
  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.textSec),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 14, color: colors.textSec)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
        ],
      ),
    );
  }
}

class _ItemsBreakdown extends StatelessWidget {
  const _ItemsBreakdown({required this.expense, required this.currency, required this.colors});
  final Expense expense;
  final String currency;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final items = expense.items!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt_outlined, size: 18, color: colors.textSec),
              const SizedBox(width: 10),
              Text(
                '${items.length} item${items.length == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 14, color: colors.textSec),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.25,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 28),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item.name, style: TextStyle(fontSize: 14, color: colors.textPrimary)),
                      ),
                      Text(
                        NumberFormat.currency(symbol: currency, decimalDigits: 0).format(item.amount),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
