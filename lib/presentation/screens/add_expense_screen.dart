import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/constants.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';
import 'package:hisabi/presentation/widgets/category_chip.dart';
import 'package:hisabi/presentation/widgets/category_form_sheet.dart';
import 'package:hisabi/utils/date_formatter.dart';
import 'package:hisabi/utils/network_utils.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.existingExpense});
  final Expense? existingExpense;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _ItemRow {
  _ItemRow([String n = '', String a = ''])
      : name = TextEditingController(text: n),
        amount = TextEditingController(text: a),
        nameFocus = FocusNode(),
        amountFocus = FocusNode();
  final TextEditingController name;
  final TextEditingController amount;
  final FocusNode nameFocus;
  final FocusNode amountFocus;
  void dispose() {
    name.dispose();
    amount.dispose();
    nameFocus.dispose();
    amountFocus.dispose();
  }
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _amountFocus = FocusNode();
  final _titleFocus = FocusNode();
  final _noteFocus = FocusNode();
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  final _itemRows = <_ItemRow>[];

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
      _titleCtrl.text = e.title;
      _noteCtrl.text = e.note ?? '';
      if (e.isGrouped) {
        for (final item in e.items!) {
          _addItemRow(name: item.name, amount: item.amount.toStringAsFixed(0));
        }
      } else {
        _amountCtrl.text = e.amount.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    _amountFocus.dispose();
    _titleFocus.dispose();
    _noteFocus.dispose();
    _shakeCtrl.dispose();
    for (final row in _itemRows) { row.dispose(); }
    super.dispose();
  }

  void _addItemRow({String name = '', String amount = '', bool requestFocus = false}) {
    final row = _ItemRow(name, amount);
    row.name.addListener(_onItemChanged);
    row.amount.addListener(_onItemChanged);
    setState(() => _itemRows.add(row));
    if (requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) row.nameFocus.requestFocus();
      });
    }
  }

  void _removeItemRow(int i) {
    final row = _itemRows[i];
    row.name.removeListener(_onItemChanged);
    row.amount.removeListener(_onItemChanged);
    row.dispose();
    setState(() => _itemRows.removeAt(i));
    _syncGroupValidity();
  }

  void _onItemChanged() {
    if (!mounted) return;
    setState(() {});
    _syncGroupValidity();
  }

  void _syncGroupValidity() {
    final hasValid = _itemRows.any((row) =>
        row.name.text.trim().isNotEmpty &&
        (double.tryParse(row.amount.text) ?? 0) > 0);
    ref.read(_formProvider.notifier).updateGroupValidity(hasValid);
  }

  void _setGrouped(bool toGrouped) {
    if (toGrouped == ref.read(_formProvider).isGrouped) return;
    if (toGrouped) {
      _addItemRow();
      _addItemRow();
    } else {
      for (final row in _itemRows) {
        row.name.removeListener(_onItemChanged);
        row.amount.removeListener(_onItemChanged);
        row.dispose();
      }
      setState(() => _itemRows.clear());
      ref.read(_formProvider.notifier).updateGroupValidity(false);
    }
    ref.read(_formProvider.notifier).setGrouped(toGrouped);
  }

  Future<void> _save() async {
    final formState = ref.read(_formProvider);

    if (formState.isGrouped) {
      final validItems = _itemRows
          .map((row) => ExpenseItem(
                name: row.name.text.trim(),
                amount: double.tryParse(row.amount.text) ?? 0,
              ))
          .where((item) => item.name.isNotEmpty && item.amount > 0)
          .toList();

      final titleErr = _titleCtrl.text.trim().isEmpty ? 'required' : null;
      final categoryErr = formState.selectedCategory == null ? 'required' : null;
      final itemsErr = validItems.isEmpty ? 'required' : null;

      if (titleErr != null || categoryErr != null || itemsErr != null) {
        ref.read(_formProvider.notifier).setErrors(
          title: titleErr,
          category: categoryErr,
          items: itemsErr,
        );
        _shakeCtrl.forward(from: 0);
        return;
      }

      if (!await isConnected()) {
        if (mounted) showNetworkSnackBar(context, const NetworkException.offline());
        return;
      }

      ref.read(_formProvider.notifier).setSaving(true);
      try {
        final totalAmount = validItems.fold<double>(0, (acc, e) => acc + e.amount);
        final expense = Expense(
          id: _isEdit ? widget.existingExpense!.id : const Uuid().v4(),
          title: _titleCtrl.text.trim(),
          amount: totalAmount,
          category: formState.selectedCategory!,
          date: formState.selectedDate,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          items: validItems,
        );
        if (_isEdit) {
          await ref.read(expenseListProvider.notifier).deleteExpense(widget.existingExpense!.id);
        }
        await ref.read(expenseListProvider.notifier).addExpense(expense);
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isEdit ? 'Expense updated ✓' : 'Expense list added ✓'),
            backgroundColor: kSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ));
        }
      } catch (e) {
        if (mounted) showNetworkSnackBar(context, e);
      } finally {
        if (mounted) ref.read(_formProvider.notifier).setSaving(false);
      }
      return;
    }

    // Single expense
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final amountErr = amount <= 0 ? 'invalid' : null;
    final titleErr = _titleCtrl.text.trim().isEmpty ? 'required' : null;
    final categoryErr = formState.selectedCategory == null ? 'required' : null;

    if (amountErr != null || titleErr != null || categoryErr != null) {
      ref.read(_formProvider.notifier).setErrors(
        amount: amountErr,
        title: titleErr,
        category: categoryErr,
      );
      _shakeCtrl.forward(from: 0);
      return;
    }

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Expense updated ✓' : 'Expense added ✓'),
          backgroundColor: kSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ));
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
    final isGrouped = formState.isGrouped;
    final allCategories = [
      ...AppConstants.categories,
      ...customCats.map((c) => c.toMap()),
    ];
    final itemsTotal = _itemRows.fold<double>(
      0,
      (acc, row) => acc + (double.tryParse(row.amount.text) ?? 0),
    );

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
          // Mode toggle — only on new expense
          if (!_isEdit) ...[
            _ModeToggle(
              isGrouped: isGrouped,
              colors: colors,
              onSingle: () => _setGrouped(false),
              onList: () => _setGrouped(true),
            ),
            const SizedBox(height: 8),
          ],

          // Amount card (single mode)
          if (!isGrouped)
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
                              focusNode: _amountFocus,
                              autofocus: !_isEdit,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                              textAlign: TextAlign.start,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _titleFocus.requestFocus(),
                              onChanged: (v) => ref.read(_formProvider.notifier).updateAmount(v),
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: colors.textPrimary, height: 1.1),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textSec.withValues(alpha: 0.25),
                                  height: 1.1,
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

          // Items card (list mode)
          if (isGrouped)
            _FormCard(
              hasError: formState.itemsError != null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _FieldLabel('ITEMS', colors),
                      const Spacer(),
                      if (itemsTotal > 0) ...[
                        Text(
                          formatCompact(itemsTotal, currency),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimary, letterSpacing: -0.3),
                        ),
                        const SizedBox(width: 10),
                      ],
                      GestureDetector(
                        onTap: () => _addItemRow(requestFocus: true),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline, size: 15, color: kPrimary),
                            SizedBox(width: 4),
                            Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _itemRows.length,
                    (i) => _buildItemRow(i, colors, currency),
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
                  focusNode: _titleFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _noteFocus.requestFocus(),
                  onChanged: (v) => ref.read(_formProvider.notifier).updateTitle(v),
                  style: TextStyle(fontSize: 15, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: isGrouped ? 'e.g. Weekly Groceries' : 'What did you spend on?',
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
                  focusNode: _noteFocus,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
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
                  gradient: isValid ? const LinearGradient(colors: [kPrimaryLight, kPrimary]) : null,
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
                        _isEdit
                            ? 'Save Changes'
                            : (isGrouped ? 'Add Expense List' : 'Add Expense'),
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

  Widget _buildItemRow(int i, AppColors colors, String currency) {
    final row = _itemRows[i];
    final isLast = i == _itemRows.length - 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: colors.border, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textSec),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: row.name,
                focusNode: row.nameFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => row.amountFocus.requestFocus(),
                style: TextStyle(fontSize: 14, color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Item name',
                  hintStyle: TextStyle(color: colors.textSec),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currency, style: TextStyle(fontSize: 13, color: colors.textSec)),
                const SizedBox(width: 3),
                SizedBox(
                  width: 72,
                  child: TextField(
                    controller: row.amount,
                    focusNode: row.amountFocus,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    textAlign: TextAlign.right,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      if (isLast) {
                        _titleFocus.requestFocus();
                      } else {
                        _itemRows[i + 1].nameFocus.requestFocus();
                      }
                    },
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: colors.textSec),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 24,
              child: _itemRows.length > 1
                  ? GestureDetector(
                      onTap: () => _removeItemRow(i),
                      child: Icon(Icons.close, size: 16, color: colors.textSec),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form widgets
// ---------------------------------------------------------------------------

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isGrouped,
    required this.colors,
    required this.onSingle,
    required this.onList,
  });
  final bool isGrouped;
  final AppColors colors;
  final VoidCallback onSingle;
  final VoidCallback onList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: colors.cardAlt, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(child: _ModeBtn(label: 'Single', icon: Icons.receipt_outlined, selected: !isGrouped, onTap: onSingle, colors: colors)),
          Expanded(child: _ModeBtn(label: 'List', icon: Icons.list_alt_outlined, selected: isGrouped, onTap: onList, colors: colors)),
        ],
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  const _ModeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: selected ? kPrimary : colors.textSec),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? kPrimary : colors.textSec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
