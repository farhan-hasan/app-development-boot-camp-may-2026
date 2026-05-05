import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisabi/data/repositories/expense_repository_impl.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/domain/repositories/expense_repository.dart';

part 'expense_provider.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

final firestoreProvider = Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(firestoreProvider));
});

// ---------------------------------------------------------------------------
// UI state
// ---------------------------------------------------------------------------

final selectedMonthProvider = StateProvider<DateTime>((_) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final searchQueryProvider = StateProvider<String>((_) => '');
final searchModeProvider = StateProvider<bool>((_) => false);
final showAllTransactionsProvider = StateProvider<bool>((_) => false);
final onboardingPageProvider = StateProvider<int>((_) => 0);

// ---------------------------------------------------------------------------
// Custom categories
// ---------------------------------------------------------------------------

class CustomCategory {
  const CustomCategory({required this.name, required this.emoji, this.colorIndex = 0});
  final String name;
  final String emoji;
  final int colorIndex;

  static const presetColors = [
    Color(0xFFF59E0B), Color(0xFF3B82F6), Color(0xFFEC4899), Color(0xFF8B5CF6),
    Color(0xFFF97316), Color(0xFFEF4444), Color(0xFF22C55E), Color(0xFF0D9488),
  ];

  Color get color => presetColors[colorIndex % presetColors.length];

  Map<String, dynamic> toMap() => {
    'name': name, 'emoji': emoji, 'icon': Icons.label, 'color': color,
  };

  Map<String, dynamic> toJson() => {'name': name, 'emoji': emoji, 'colorIndex': colorIndex};

  factory CustomCategory.fromJson(Map<String, dynamic> json) => CustomCategory(
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    colorIndex: (json['colorIndex'] as int?) ?? 0,
  );
}

final customCategoriesProvider =
    StateNotifierProvider<CustomCategoriesNotifier, List<CustomCategory>>((ref) {
  return CustomCategoriesNotifier();
});

class CustomCategoriesNotifier extends StateNotifier<List<CustomCategory>> {
  CustomCategoriesNotifier() : super([]) { _load(); }

  static const _key = 'custom_categories';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    state = raw.map((s) {
      final parts = s.split('|');
      return CustomCategory(
        name: parts[0],
        emoji: parts[1],
        colorIndex: int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0,
      );
    }).toList();
  }

  Future<void> add(CustomCategory cat) async {
    state = [...state, cat];
    await _persist();
  }

  Future<void> remove(String name) async {
    state = state.where((c) => c.name != name).toList();
    await _persist();
  }

  Future<void> update(String oldName, CustomCategory updated) async {
    state = state.map((c) => c.name == oldName ? updated : c).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      state.map((c) => '${c.name}|${c.emoji}|${c.colorIndex}').toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Expense list AsyncNotifier (code-gen)
// ---------------------------------------------------------------------------

@riverpod
class ExpenseList extends _$ExpenseList {
  @override
  Future<List<Expense>> build() async {
    final month = ref.watch(selectedMonthProvider);
    final repo = ref.watch(expenseRepositoryProvider);
    return repo.getExpensesForMonth(month);
  }

  Future<void> addExpense(Expense expense) async {
    await ref.read(expenseRepositoryProvider).addExpense(expense);
    ref.invalidateSelf();
  }

  Future<void> deleteExpense(String id) async {
    // Optimistic update: remove from local state immediately so the UI
    // never flashes a loading spinner. Firestore delete follows in the background.
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.where((e) => e.id != id).toList());
    }
    await ref.read(expenseRepositoryProvider).deleteExpense(id);
  }
}

// ---------------------------------------------------------------------------
// Derived FutureProviders
// ---------------------------------------------------------------------------

@riverpod
Future<double> monthlyTotal(Ref ref) async {
  // Derives from expenseListProvider so it updates instantly on add/delete.
  final expenses = await ref.watch(expenseListProvider.future);
  return expenses.fold<double>(0.0, (acc, e) => acc + e.amount);
}

@riverpod
Future<double> todayTotal(Ref ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final today = DateTime.now();
  return expenses
      .where((e) => e.date.year == today.year && e.date.month == today.month && e.date.day == today.day)
      .fold<double>(0.0, (acc, e) => acc + e.amount);
}

// ---------------------------------------------------------------------------
// Theme mode – initial value loaded in main() and passed via provider override
// ---------------------------------------------------------------------------

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier([super.initial = ThemeMode.system]);

  static const _key = 'theme_mode';

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next == ThemeMode.dark ? 'dark' : 'light');
  }
}

// ---------------------------------------------------------------------------
// Currency – persisted via SharedPreferences
// ---------------------------------------------------------------------------

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('৳') {
    _load();
  }

  static const _key = 'currency';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? '৳';
  }

  Future<void> setCurrency(String symbol) async {
    state = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, symbol);
  }
}

// ---------------------------------------------------------------------------
// Onboarding completed – persisted via SharedPreferences
// ---------------------------------------------------------------------------

final onboardingCompletedProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier([bool initial = false]) : super(initial) {
    if (!initial) _load();
  }

  static const _key = 'onboarding_completed';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> complete() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

// ---------------------------------------------------------------------------
// Add/Edit expense form state (autoDispose so it resets on every screen visit)
// ---------------------------------------------------------------------------

class AddExpenseFormState {
  const AddExpenseFormState({
    this.selectedCategory,
    required this.selectedDate,
    this.saving = false,
    this.amountError,
    this.titleError,
    this.categoryError,
    this.hasValidAmount = false,
    this.hasTitle = false,
  });

  final String? selectedCategory;
  final DateTime selectedDate;
  final bool saving;
  final String? amountError;
  final String? titleError;
  final String? categoryError;
  final bool hasValidAmount;
  final bool hasTitle;

  bool get isValid => hasValidAmount && hasTitle && selectedCategory != null;

  AddExpenseFormState copyWith({
    String? selectedCategory,
    bool clearCategory = false,
    DateTime? selectedDate,
    bool? saving,
    String? amountError,
    bool clearAmountError = false,
    String? titleError,
    bool clearTitleError = false,
    String? categoryError,
    bool clearCategoryError = false,
    bool? hasValidAmount,
    bool? hasTitle,
  }) {
    return AddExpenseFormState(
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedDate: selectedDate ?? this.selectedDate,
      saving: saving ?? this.saving,
      amountError: clearAmountError ? null : (amountError ?? this.amountError),
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      categoryError: clearCategoryError ? null : (categoryError ?? this.categoryError),
      hasValidAmount: hasValidAmount ?? this.hasValidAmount,
      hasTitle: hasTitle ?? this.hasTitle,
    );
  }
}

class AddExpenseFormNotifier extends StateNotifier<AddExpenseFormState> {
  AddExpenseFormNotifier(Expense? existing) : super(
    existing != null
        ? AddExpenseFormState(
            selectedCategory: existing.category,
            selectedDate: existing.date,
            hasValidAmount: existing.amount > 0,
            hasTitle: existing.title.isNotEmpty,
          )
        : AddExpenseFormState(selectedDate: DateTime.now()),
  );

  void updateAmount(String text) {
    final amount = double.tryParse(text) ?? 0;
    state = state.copyWith(hasValidAmount: amount > 0, clearAmountError: true);
  }

  void updateTitle(String text) {
    state = state.copyWith(hasTitle: text.trim().isNotEmpty, clearTitleError: true);
  }

  void selectCategory(String cat) {
    state = state.copyWith(selectedCategory: cat, clearCategoryError: true);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setSaving(bool v) {
    state = state.copyWith(saving: v);
  }

  void setErrors({String? amount, String? title, String? category}) {
    state = AddExpenseFormState(
      selectedCategory: state.selectedCategory,
      selectedDate: state.selectedDate,
      saving: state.saving,
      amountError: amount,
      titleError: title,
      categoryError: category,
      hasValidAmount: state.hasValidAmount,
      hasTitle: state.hasTitle,
    );
  }
}

final addExpenseFormProvider = StateNotifierProvider.autoDispose
    .family<AddExpenseFormNotifier, AddExpenseFormState, Expense?>(
  (ref, existing) => AddExpenseFormNotifier(existing),
);
