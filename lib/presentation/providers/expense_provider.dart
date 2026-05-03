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
    await ref.read(expenseRepositoryProvider).deleteExpense(id);
    ref.invalidateSelf();
  }
}

// ---------------------------------------------------------------------------
// Derived FutureProviders
// ---------------------------------------------------------------------------

@riverpod
Future<double> monthlyTotal(Ref ref) async {
  final month = ref.watch(selectedMonthProvider);
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getTotalForMonth(month);
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
// Theme mode – persisted via SharedPreferences
// ---------------------------------------------------------------------------

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  static const _key = 'theme_mode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    if (v == 'light') state = ThemeMode.light;
    if (v == 'dark') state = ThemeMode.dark;
  }

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
