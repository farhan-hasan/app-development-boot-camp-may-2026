import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hisabi/data/models/expense_model.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/domain/repositories/expense_repository.dart';
import 'package:hisabi/config/constants.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.firestoreCollection);

  @override
  Future<List<Expense>> getExpensesForMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ExpenseModel.fromJson(doc.data(), doc.id).toEntity())
        .toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _collection.add(model.toJson());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<double> getTotalForMonth(DateTime month) async {
    final expenses = await getExpensesForMonth(month);
    return expenses.fold<double>(0.0, (acc, e) => acc + e.amount);
  }
}
