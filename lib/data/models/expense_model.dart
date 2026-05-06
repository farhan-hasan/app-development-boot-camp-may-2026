import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hisabi/domain/entities/expense.dart';

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.items,
  });

  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final List<ExpenseItem>? items;

  factory ExpenseModel.fromJson(Map<String, dynamic> json, String id) {
    final rawItems = json['items'] as List<dynamic>?;
    return ExpenseModel(
      id: id,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: (json['date'] as Timestamp).toDate(),
      note: json['note'] as String?,
      items: rawItems
          ?.map((e) => ExpenseItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'category': category,
    'date': Timestamp.fromDate(date),
    'note': note,
    if (items != null) 'items': items!.map((e) => e.toMap()).toList(),
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory ExpenseModel.fromEntity(Expense expense) => ExpenseModel(
    id: expense.id,
    title: expense.title,
    amount: expense.amount,
    category: expense.category,
    date: expense.date,
    note: expense.note,
    items: expense.items,
  );

  Expense toEntity() => Expense(
    id: id,
    title: title,
    amount: amount,
    category: category,
    date: date,
    note: note,
    items: items,
  );
}
