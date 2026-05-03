import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/constants.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';
import 'package:hisabi/presentation/widgets/category_chip.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.existingExpense});
  final Expense? existingExpense;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;
  String? _amountError;
  String? _titleError;
  String? _categoryError;

  bool get _isEdit => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.existingExpense!;
      _amountCtrl.text = e.amount.toStringAsFixed(0);
      _titleCtrl.text = e.title;
      _noteCtrl.text = e.note ?? '';
      _selectedCategory = e.category;
      _selectedDate = e.date;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    return amount > 0 && _titleCtrl.text.trim().isNotEmpty && _selectedCategory != null;
  }

  Future<void> _save() async {
    // Clear previous errors
    setState(() { _amountError = null; _titleError = null; _categoryError = null; });

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    bool hasError = false;
    if (amount <= 0) { setState(() => _amountError = 'Enter a valid amount'); hasError = true; }
    if (_titleCtrl.text.trim().isEmpty) { setState(() => _titleError = 'Title is required'); hasError = true; }
    if (_selectedCategory == null) { setState(() => _categoryError = 'Select a category'); hasError = true; }
    if (hasError) return;

    setState(() => _saving = true);
    try {
      final expense = Expense(
        id: _isEdit ? widget.existingExpense!.id : const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        amount: amount,
        category: _selectedCategory!,
        date: _selectedDate,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );

      if (_isEdit) {
        await ref.read(expenseListProvider.notifier).deleteExpense(widget.existingExpense!.id);
      }
      await ref.read(expenseListProvider.notifier).addExpense(expense);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Expense updated ✓' : 'Expense added ✓'),
            backgroundColor: kSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: kPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: colors.cardAlt, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: colors.textPrimary),
          ),
        ),
        title: Text(_isEdit ? 'Edit Expense' : 'Add Expense',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        actions: [
          GestureDetector(
            onTap: _isValid && !_saving ? _save : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                _isEdit ? 'Save Changes' : 'Save',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _isValid ? kPrimary : colors.textSec,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            // Amount card
            _FormCard(
              child: Column(
                children: [
                  Text('Amount', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textSec)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(currency, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: colors.textSec)),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 180,
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          onChanged: (_) => setState(() => _amountError = null),
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: colors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_amountError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(_amountError!, style: const TextStyle(color: kDanger, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Title field
            _FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('TITLE', colors),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    onChanged: (_) => setState(() => _titleError = null),
                    style: TextStyle(fontSize: 15, color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'What did you spend on?',
                      hintStyle: TextStyle(color: colors.textSec),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (_titleError != null)
                    Text(_titleError!, style: const TextStyle(color: kDanger, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Category selector
            _FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('CATEGORY', colors),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.categories.map((cat) {
                      final name = cat['name'] as String;
                      return CategoryChip(
                        name: name,
                        emoji: cat['emoji'] as String,
                        color: cat['color'] as Color,
                        selected: _selectedCategory == name,
                        onTap: () => setState(() { _selectedCategory = name; _categoryError = null; }),
                      );
                    }).toList(),
                  ),
                  if (_categoryError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_categoryError!, style: const TextStyle(color: kDanger, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Date field
            _FormCard(
              child: GestureDetector(
                onTap: _pickDate,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('DATE', colors),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                          style: TextStyle(fontSize: 15, color: colors.textPrimary),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today_outlined, size: 18, color: colors.textSec),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Note field
            _FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('NOTE (OPTIONAL)', colors),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    style: TextStyle(fontSize: 14, color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle: TextStyle(color: colors.textSec),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  gradient: _isValid
                      ? const LinearGradient(colors: [kPrimaryLight, kPrimary])
                      : null,
                  color: _isValid ? null : colors.cardAlt,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isValid
                      ? [BoxShadow(color: kPrimary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))]
                      : null,
                ),
                alignment: Alignment.center,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _isEdit ? 'Save Changes' : 'Add Expense',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _isValid ? Colors.white : colors.textSec,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.appColors.card,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: child,
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, this.colors);
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSec, letterSpacing: 0.6),
  );
}
