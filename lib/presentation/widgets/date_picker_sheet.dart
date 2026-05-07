import 'package:flutter/material.dart';
import 'package:hisabi/config/theme.dart';

Future<DateTime?> showCustomDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DatePickerSheet(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _DatePickerSheet extends StatefulWidget {
  const _DatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _previousMonth() {
    final newMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    if (newMonth.isAfter(widget.firstDate) ||
        newMonth.year == widget.firstDate.year &&
            newMonth.month == widget.firstDate.month) {
      setState(() => _displayedMonth = newMonth);
    }
  }

  void _nextMonth() {
    final newMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    if (newMonth.isBefore(widget.lastDate) ||
        newMonth.year == widget.lastDate.year &&
            newMonth.month == widget.lastDate.month) {
      setState(() => _displayedMonth = newMonth);
    }
  }

  bool _canGoPrevious() {
    final previousMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    return previousMonth.isAfter(widget.firstDate) ||
        previousMonth.year == widget.firstDate.year &&
            previousMonth.month == widget.firstDate.month;
  }

  bool _canGoNext() {
    final nextMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    return nextMonth.isBefore(widget.lastDate) ||
        nextMonth.year == widget.lastDate.year &&
            nextMonth.month == widget.lastDate.month;
  }

  List<DateTime?> _getDaysInMonth() {
    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);

    final List<DateTime?> days = [];

    // Add empty cells for days before the first day of month
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    // Add all days in the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(_displayedMonth.year, _displayedMonth.month, day));
    }

    return days;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime? date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  bool _isSelectable(DateTime? date) {
    if (date == null) return false;
    return !date.isBefore(widget.firstDate) &&
        !date.isAfter(widget.lastDate);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final days = _getDaysInMonth();
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Month/Year navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _canGoPrevious() ? _previousMonth : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _canGoPrevious()
                        ? colors.cardAlt
                        : colors.cardAlt.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: _canGoPrevious() ? colors.textPrimary : colors.border,
                  ),
                ),
              ),
              Text(
                '${monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: _canGoNext() ? _nextMonth : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _canGoNext()
                        ? colors.cardAlt
                        : colors.cardAlt.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: _canGoNext() ? colors.textPrimary : colors.border,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textSec,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              if (date == null) {
                return const SizedBox();
              }

              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isToday(date);
              final isSelectable = _isSelectable(date);

              return GestureDetector(
                onTap: isSelectable
                    ? () {
                        setState(() => _selectedDate = date);
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: kPrimary, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : isSelectable
                                ? colors.textPrimary
                                : colors.textSec,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Confirm button
          GestureDetector(
            onTap: () => Navigator.pop(context, _selectedDate),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimaryLight, kPrimary],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
