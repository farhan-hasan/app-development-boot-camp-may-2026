// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyTotalHash() => r'9d829330ec772979b1e2828635c53263e0aa517a';

/// See also [monthlyTotal].
@ProviderFor(monthlyTotal)
final monthlyTotalProvider = AutoDisposeFutureProvider<double>.internal(
  monthlyTotal,
  name: r'monthlyTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyTotalRef = AutoDisposeFutureProviderRef<double>;
String _$todayTotalHash() => r'2588e6513369debef666e8b37e70ecd8f2d3c9f2';

/// See also [todayTotal].
@ProviderFor(todayTotal)
final todayTotalProvider = AutoDisposeFutureProvider<double>.internal(
  todayTotal,
  name: r'todayTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTotalRef = AutoDisposeFutureProviderRef<double>;
String _$expenseListHash() => r'14de092d3b3c8082dfd119de7a300cd8a755cfd4';

/// See also [ExpenseList].
@ProviderFor(ExpenseList)
final expenseListProvider =
    AutoDisposeAsyncNotifierProvider<ExpenseList, List<Expense>>.internal(
      ExpenseList.new,
      name: r'expenseListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpenseList = AutoDisposeAsyncNotifier<List<Expense>>;
String _$allExpensesHash() => r'4cfd5bd27b48dfdb1cfd5ef6cce82eff496fe292';

/// See also [AllExpenses].
@ProviderFor(AllExpenses)
final allExpensesProvider =
    AutoDisposeAsyncNotifierProvider<AllExpenses, List<Expense>>.internal(
      AllExpenses.new,
      name: r'allExpensesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allExpensesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AllExpenses = AutoDisposeAsyncNotifier<List<Expense>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
