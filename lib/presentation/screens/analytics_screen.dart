import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';
import 'package:hisabi/presentation/widgets/month_selector.dart';
import 'package:hisabi/utils/category_utils.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final currency = ref.watch(currencyProvider);
    final expensesAsync = ref.watch(expenseListProvider);
    final monthlyAsync = ref.watch(monthlyTotalProvider);
    final extraCategories = ref.watch(customCategoriesProvider).map((c) => c.toMap()).toList();

    return expensesAsync.when(
      data: (expenses) {
        final total = monthlyAsync.valueOrNull ?? 0;
        final breakdown = _buildBreakdown(expenses, extraCategories);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Text('Analytics',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5)),
                      const Spacer(),
                      const MonthSelector(),
                    ],
                  ),
                ),
              ),
            ),

            // Overview card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPrimary, kPrimaryDark]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: kPrimary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Spent', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xB3FFFFFF))),
                      const SizedBox(height: 6),
                      Text(
                        NumberFormat.currency(symbol: currency, decimalDigits: 0).format(total),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (expenses.isEmpty) ...[
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📊', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text('No data for this month', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Donut chart card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spending by Category',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 55,
                                  sections: breakdown.map((cat) {
                                    final pct = total > 0 ? (cat.amount / total) : 0.0;
                                    return PieChartSectionData(
                                      color: cat.color,
                                      value: cat.amount,
                                      title: pct >= 0.08 ? '${(pct * 100).round()}%' : '',
                                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                      radius: 55,
                                    );
                                  }).toList(),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Total', style: TextStyle(fontSize: 11, color: colors.textSec)),
                                  Text(
                                    NumberFormat.currency(symbol: currency, decimalDigits: 0).format(total),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Breakdown list card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                        const SizedBox(height: 12),
                        ...breakdown.asMap().entries.map((entry) {
                          final cat = entry.value;
                          final pct = total > 0 ? cat.amount / total : 0.0;
                          return _BreakdownRow(cat: cat, pct: pct, currency: currency, total: total, colors: colors);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: kPrimary)),
      error: (_, __) => Center(child: Text('Failed to load', style: TextStyle(color: context.appColors.textSec))),
    );
  }

  List<_CategoryData> _buildBreakdown(List<Expense> expenses, List<Map<String, dynamic>> extra) {
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    final list = totals.entries
        .map((e) => _CategoryData(
              name: e.key,
              amount: e.value,
              color: getCategoryColor(e.key, extra: extra),
              emoji: getCategoryEmoji(e.key, extra: extra),
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }
}

class _CategoryData {
  const _CategoryData({required this.name, required this.amount, required this.color, required this.emoji});
  final String name;
  final double amount;
  final Color color;
  final String emoji;
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.cat, required this.pct, required this.currency, required this.total, required this.colors});
  final _CategoryData cat;
  final double pct;
  final String currency;
  final double total;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('${cat.emoji} ${cat.name}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
              const Spacer(),
              Text(
                NumberFormat.currency(symbol: currency, decimalDigits: 0).format(cat.amount),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
              ),
              const SizedBox(width: 8),
              Text('${(pct * 100).round()}%', style: TextStyle(fontSize: 11, color: colors.textSec)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation(cat.color),
            ),
          ),
        ],
      ),
    );
  }
}
