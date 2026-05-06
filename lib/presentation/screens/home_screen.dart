import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';
import 'package:hisabi/presentation/widgets/empty_state.dart';
import 'package:hisabi/presentation/widgets/expense_detail_sheet.dart';
import 'package:hisabi/presentation/widgets/expense_list_item.dart';
import 'package:hisabi/presentation/widgets/month_selector.dart';
import 'package:hisabi/presentation/widgets/summary_card.dart';
import 'package:hisabi/utils/category_utils.dart';
import 'package:hisabi/utils/date_formatter.dart';
import 'package:hisabi/utils/network_utils.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(expenseListProvider);
    ref.invalidate(monthlyTotalProvider);
    ref.invalidate(todayTotalProvider);
    await ref.read(expenseListProvider.future);
  }

  List<dynamic> _buildFlatList(
    List<Expense> expenses,
    String query,
    bool showAll,
  ) {
    final filtered = query.isEmpty
        ? expenses
        : expenses
              .where(
                (e) =>
                    e.title.toLowerCase().contains(query.toLowerCase()) ||
                    e.category.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    final limited = showAll ? filtered : filtered.take(10).toList();

    final Map<String, List<Expense>> grouped = {};
    for (final e in limited) {
      final key = DateFormat('yyyy-MM-dd').format(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final List<dynamic> flat = [];
    for (final entry in grouped.entries) {
      flat.add(entry.key);
      flat.addAll(entry.value);
    }
    return flat;
  }

  String _formatDateKey(String key) {
    final date = DateTime.parse(key);
    final now = DateTime.now();
    if (isSameDay(date, now)) return 'Today';
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  double _dailyTotal(List<dynamic> flat, String dateKey) {
    double total = 0;
    bool found = false;
    for (final item in flat) {
      if (item is String && item == dateKey) {
        found = true;
        continue;
      }
      if (found) {
        if (item is Expense) {
          total += item.amount;
        } else {
          break;
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final currency = ref.watch(currencyProvider);
    final expensesAsync = ref.watch(expenseListProvider);
    final monthlyAsync = ref.watch(monthlyTotalProvider);
    final todayAsync = ref.watch(todayTotalProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final searchMode = ref.watch(searchModeProvider);
    final showAll = ref.watch(showAllTransactionsProvider);
    final query = ref.watch(searchQueryProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);
    final extraCategories = ref
        .watch(customCategoriesProvider)
        .map((c) => c.toMap())
        .toList();

    ref.listen<DateTime>(selectedMonthProvider, (_, __) {
      ref.read(categoryFilterProvider.notifier).state = null;
    });

    return RefreshIndicator(
      color: kPrimary,
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: searchMode
                    ? _buildSearchBar(colors, query)
                    : _buildHeaderRow(context, colors, selectedMonth),
              ),
            ),
          ),

          // ── Summary cards ──
          if (!searchMode)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SummaryCard(
                          label: 'This Month',
                          amount: monthlyAsync.valueOrNull ?? 0,
                          subtext: DateFormat(
                            'MMMM yyyy',
                          ).format(selectedMonth),
                          gradientColors: const [kPrimary, kPrimaryDark],
                          shadowColor: const Color(0x440D9488),
                          currency: currency,
                          onTap: () => context.go('/analytics'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SummaryCard(
                          label: 'Today',
                          amount: todayAsync.valueOrNull ?? 0,
                          subtext: DateFormat('MMM d').format(DateTime.now()),
                          gradientColors: const [
                            Color(0xFFF97316),
                            Color(0xFFEA580C),
                          ],
                          shadowColor: const Color(0x59F97316),
                          currency: currency,
                          //amountFontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Category filter chips ──
          if (!searchMode)
            SliverToBoxAdapter(
              child: expensesAsync.maybeWhen(
                data: (data) {
                  final catTotals = <String, double>{};
                  for (final e in data) {
                    catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
                  }
                  final catNames = (catTotals.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)))
                      .map((e) => e.key)
                      .toList();
                  if (catNames.length < 2) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _CategoryFilterRow(
                      categories: catNames,
                      selectedCategory: categoryFilter,
                      extraCategories: extraCategories,
                      colors: colors,
                      onSelected: (cat) =>
                          ref.read(categoryFilterProvider.notifier).state = cat,
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ),

          // ── Section header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: expensesAsync.when(
                data: (data) {
                  final filtered = categoryFilter == null
                      ? data
                      : data.where((e) => e.category == categoryFilter).toList();
                  return Row(
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (filtered.length > 10)
                        GestureDetector(
                          onTap: () =>
                              ref
                                      .read(showAllTransactionsProvider.notifier)
                                      .state =
                                  !showAll,
                          child: Text(
                            showAll ? 'Show Less' : 'See All',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: kPrimary,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),

          // ── Transaction list ──
          expensesAsync.when(
            data: (data) {
              final categoryFiltered = categoryFilter == null
                  ? data
                  : data.where((e) => e.category == categoryFilter).toList();
              final flat = _buildFlatList(categoryFiltered, query, showAll);
              if (flat.isEmpty) {
                return SliverFillRemaining(child: EmptyState());
              }
              int expenseIndex = 0;
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.builder(
                  itemCount: flat.length,
                  itemBuilder: (ctx, i) {
                    final item = flat[i];
                    if (item is String) {
                      return _DateGroupHeader(
                        label: _formatDateKey(item),
                        total: _dailyTotal(flat, item),
                        currency: currency,
                        colors: colors,
                      );
                    }
                    final expense = item as Expense;
                    final animIdx = expenseIndex++;
                    return ExpenseListItem(
                      key: ValueKey(expense.id),
                      expense: expense,
                      currency: currency,
                      animationIndex: animIdx,
                      extraCategories: extraCategories,
                      onDelete: () => ref
                          .read(expenseListProvider.notifier)
                          .deleteExpense(expense.id)
                          .catchError((e) {
                            if (context.mounted) showNetworkSnackBar(context, e);
                          }),
                      onTap: () => showExpenseDetailSheet(
                        context,
                        expense,
                        currency,
                        () => ref
                            .read(expenseListProvider.notifier)
                            .deleteExpense(expense.id)
                            .catchError((e) {
                              if (context.mounted) showNetworkSnackBar(context, e);
                            }),
                        extraCategories: extraCategories,
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => _SkeletonList(colors: colors),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_outlined, size: 48, color: colors.textSec),
                    const SizedBox(height: 12),
                    Text(
                      err is NetworkException ? err.message : 'Failed to load expenses',
                      style: TextStyle(color: colors.textSec, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
    AppColors colors,
    DateTime month,
  ) {
    return Row(
      children: [
        const MonthSelector(),
        const Spacer(),
        _IconBtn(
          icon: Icons.search_outlined,
          onTap: () => ref.read(searchModeProvider.notifier).state = true,
        ),
        const SizedBox(width: 8),
        _IconBtn(
          icon: Icons.settings_outlined,
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppColors colors, String query) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: colors.cardAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
              style: TextStyle(fontSize: 14, color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                hintStyle: TextStyle(color: colors.textSec, fontSize: 14),
                prefixIcon: Icon(Icons.search, size: 18, color: colors.textSec),
                suffixIcon: query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: colors.textSec,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: false,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            _searchCtrl.clear();
            ref.read(searchQueryProvider.notifier).state = '';
            ref.read(searchModeProvider.notifier).state = false;
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14,
              color: kPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.appColors.cardAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: context.appColors.textPrimary),
    ),
  );
}

class _DateGroupHeader extends StatelessWidget {
  const _DateGroupHeader({
    required this.label,
    required this.total,
    required this.currency,
    required this.colors,
  });
  final String label;
  final double total;
  final String currency;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 0,
    ).format(total);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textSec,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          Text(
            formatted,
            style: TextStyle(fontSize: 12, color: colors.textSec),
          ),
        ],
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({required this.colors});
  final AppColors colors;

  Widget _box(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(color: colors.cardAlt, borderRadius: BorderRadius.circular(4)),
      );

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverList.builder(
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: colors.cardAlt, borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(120, 12),
                    const SizedBox(height: 6),
                    _box(80, 10),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _box(60, 12),
                  const SizedBox(height: 6),
                  _box(40, 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({
    required this.categories,
    required this.selectedCategory,
    required this.extraCategories,
    required this.colors,
    required this.onSelected,
  });
  final List<String> categories;
  final String? selectedCategory;
  final List<Map<String, dynamic>> extraCategories;
  final AppColors colors;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterPill(
            label: 'All',
            selected: selectedCategory == null,
            color: kPrimary,
            colors: colors,
            onTap: () => onSelected(null),
          ),
          ...categories.map((cat) {
            final emoji = getCategoryEmoji(cat, extra: extraCategories);
            final color = getCategoryColor(cat, extra: extraCategories);
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterPill(
                label: cat,
                emoji: emoji,
                selected: selectedCategory == cat,
                color: color,
                colors: colors,
                onTap: () => onSelected(selectedCategory == cat ? null : cat),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.color,
    required this.colors,
    required this.onTap,
    this.emoji,
  });
  final String label;
  final bool selected;
  final Color color;
  final AppColors colors;
  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : colors.cardAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : colors.textSec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
