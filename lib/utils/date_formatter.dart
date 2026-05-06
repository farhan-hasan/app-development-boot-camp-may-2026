import 'package:intl/intl.dart';

String formatMonthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime getMonthStart(DateTime date) => DateTime(date.year, date.month, 1);

DateTime getMonthEnd(DateTime date) =>
    DateTime(date.year, date.month + 1, 0, 23, 59, 59);

String formatCompact(double amount, String currency) {
  if (amount >= 1000000) {
    final s = (amount / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    return '$currency${s}M';
  }
  if (amount >= 1000) {
    final s = (amount / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    return '$currency${s}K';
  }
  return NumberFormat.currency(symbol: currency, decimalDigits: 0).format(amount);
}
