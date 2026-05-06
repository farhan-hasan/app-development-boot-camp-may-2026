class ExpenseItem {
  const ExpenseItem({required this.name, required this.amount});
  final String name;
  final double amount;

  Map<String, dynamic> toMap() => {'name': name, 'amount': amount};

  factory ExpenseItem.fromMap(Map<String, dynamic> map) => ExpenseItem(
    name: map['name'] as String,
    amount: (map['amount'] as num).toDouble(),
  );
}

class Expense {
  const Expense({
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

  bool get isGrouped => items != null && items!.isNotEmpty;
}
