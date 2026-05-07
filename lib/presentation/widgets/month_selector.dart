import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';
import 'package:hisabi/utils/date_formatter.dart';

class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key, this.todayButtonOnLeft = false});
  final bool todayButtonOnLeft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final colors = context.appColors;
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;

    final todayButton = !isCurrentMonth
        ? [
            const SizedBox(width: 4),
            _NavButton(
              icon: Icons.today,
              onTap: () {
                FocusScope.of(context).unfocus();
                ref.read(selectedMonthProvider.notifier).state =
                    DateTime(now.year, now.month);
              },
            ),
          ]
        : <Widget>[];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (todayButtonOnLeft) ...todayButton,
        _NavButton(
          icon: Icons.chevron_left,
          onTap: () => ref.read(selectedMonthProvider.notifier).state =
              DateTime(month.year, month.month - 1),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 120,
          child: Center(
            child: Text(
              formatMonthYear(month),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        _NavButton(
          icon: Icons.chevron_right,
          onTap: () => ref.read(selectedMonthProvider.notifier).state =
              DateTime(month.year, month.month + 1),
        ),
        if (!todayButtonOnLeft) ...todayButton,
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.appColors.cardAlt,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: context.appColors.textPrimary),
      ),
    );
  }
}
