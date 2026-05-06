import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/constants.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';
import 'package:hisabi/presentation/widgets/category_chip.dart';
import 'package:hisabi/presentation/widgets/category_form_sheet.dart';
import 'package:hisabi/utils/network_utils.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.existingExpense});
  final Expense? existingExpense;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  bool get _isEdit => widget.existingExpense != null;

  AutoDisposeStateNotifierProvider<AddExpenseFormNotifier, AddExpenseFormState>
      get _formProvider => addExpenseFormProvider(widget.existingExpense);

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);

    if (widget.existingExpense != null) {
      final e = widget.existingExpense!;
      _amountCtrl.text = e.amount.toStringAsFixed(0);
      _titleCtrl.text = e.title;
      _noteCtrl.text = e.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final formState = ref.read(_formProvider);
    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    String? amountErr, titleErr, categoryErr;
    if (amount <= 0) amountErr = 'invalid';
    if (_titleCtrl.text.trim().isEmpty) titleErr = 'required';
    if (formState.selectedCategory == null) categoryErr = 'required';

    if (amountErr != null || titleErr != null || categoryErr != null) {
      ref.read(_formProvider.notifier).setErrors(
        amount: amountErr, title: titleErr, category: categoryErr,
      );
      _shakeCtrl.forward(from: 0);
      return;
    }

    // Connectivity pre-flight check — fast feedback before touching Firestore
    if (!await isConnected()) {
      if (mounted) showNetworkSnackBar(context, const NetworkException.offline());
      return;
    }

    ref.read(_formProvider.notifier).setSaving(true);
    try {
      final expense = Expense(
        id: _isEdit ? widget.existingExpense!.id : const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        amount: amount,
        category: formState.selectedCategory!,
        date: formState.selectedDate,
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
    } catch (e) {
      if (mounted) showNetworkSnackBar(context, e);
    } finally {
      if (mounted) ref.read(_formProvider.notifier).setSaving(false);
    }
  }

  Future<void> _pickDate() async {
    final currentDate = ref.read(_formProvider).selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: kPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) ref.read(_formProvider.notifier).selectDate(picked);
  }

  void _showAddCategorySheet() {
    showCategoryFormSheet(
      context,
      onSave: (cat) => ref.read(customCategoriesProvider.notifier).add(cat),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final currency = ref.watch(currencyProvider);
    final formState = ref.watch(_formProvider);
    final customCats = ref.watch(customCategoriesProvider);
    final isValid = formState.isValid;
    final allCategories = [
      ...AppConstants.categories,
      ...customCats.map((c) => c.toMap()),
    ];

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
        title: Text(
          _isEdit ? 'Edit Expense' : 'Add Expense',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        actions: [
          GestureDetector(
            onTap: formState.saving ? null : _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                _isEdit ? 'Save Changes' : 'Save',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isValid ? kPrimary : colors.textSec,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // Amount card
          _FormCard(
            hasError: formState.amountError != null,
            child: Column(
              children: [
                Text('Amount', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textSec)),
                const SizedBox(height: 8),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 4),
                        child: Text(
                          currency,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: colors.textSec),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 60, maxWidth: 160),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: _amountCtrl,
                            autofocus: true,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.start,
                            onChanged: (v) => ref.read(_formProvider.notifier).updateAmount(v),
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: colors.textPrimary, height: 1.1),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 48, fontWeight: FontWeight.w800,
                                color: colors.textSec.withValues(alpha: 0.25), height: 1.1,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Title field
          _FormCard(
            hasError: formState.titleError != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('TITLE', colors),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  onChanged: (v) => ref.read(_formProvider.notifier).updateTitle(v),
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
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Category selector
          _FormCard(
            hasError: formState.categoryError != null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('CATEGORY', colors),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...allCategories.map((cat) {
                      final name = cat['name'] as String;
                      return CategoryChip(
                        name: name,
                        emoji: cat['emoji'] as String,
                        color: cat['color'] as Color,
                        selected: formState.selectedCategory == name,
                        onTap: () => ref.read(_formProvider.notifier).selectCategory(name),
                      );
                    }),
                    // + Add category chip
                    GestureDetector(
                      onTap: _showAddCategorySheet,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.cardAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 14, color: colors.textSec),
                            const SizedBox(width: 4),
                            Text('New', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textSec)),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                        DateFormat('EEE, MMM d, yyyy').format(formState.selectedDate),
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

          // Save button — shakes when tapped with missing fields
          AnimatedBuilder(
            animation: _shakeAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(_shakeAnim.value, 0),
              child: child,
            ),
            child: GestureDetector(
              onTap: formState.saving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  gradient: isValid
                      ? const LinearGradient(colors: [kPrimaryLight, kPrimary])
                      : null,
                  color: isValid ? null : colors.cardAlt,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isValid
                      ? [BoxShadow(color: kPrimary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))]
                      : null,
                ),
                alignment: Alignment.center,
                child: formState.saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _isEdit ? 'Save Changes' : 'Add Expense',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isValid ? Colors.white : colors.textSec,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared form widgets
// ---------------------------------------------------------------------------

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child, this.hasError = false});
  final Widget child;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: hasError
            ? Border.all(color: kDanger.withValues(alpha: 0.6), width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
        boxShadow: hasError
            ? [BoxShadow(color: kDanger.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
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
