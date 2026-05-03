// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyTotalHash() => r'06d6132d209b74203faf2b1ad403c8ea21f7f076';

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
String _$todayTotalHash() => r'105e9daaa76881a95fcd9472e5a36cdfd56025e0';

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
String _$expenseListHash() => r'fef3997df0349c3e40b4a485bdc26646e81b09ca';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
