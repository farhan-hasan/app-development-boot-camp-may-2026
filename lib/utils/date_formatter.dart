import 'package:intl/intl.dart';

String formatMonthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime getMonthStart(DateTime date) => DateTime(date.year, date.month, 1);

DateTime getMonthEnd(DateTime date) =>
    DateTime(date.year, date.month + 1, 0, 23, 59, 59);
