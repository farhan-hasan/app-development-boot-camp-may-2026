import 'package:hisabi/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpensesForMonth(DateTime month);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> deleteAll();
  Future<double> getTotalForMonth(DateTime month);
}
