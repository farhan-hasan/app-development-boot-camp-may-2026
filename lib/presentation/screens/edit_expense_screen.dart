import 'package:flutter/material.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/presentation/screens/add_expense_screen.dart';

class EditExpenseScreen extends StatelessWidget {
  const EditExpenseScreen({super.key, required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return AddExpenseScreen(existingExpense: expense);
  }
}
