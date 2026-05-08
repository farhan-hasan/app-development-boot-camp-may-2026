import 'package:flutter/material.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';

const _pickerEmojis = [
  '🍔', '🍕', '🍜', '☕', '🥗', '🍦', '🍣', '🥩',
  '🚗', '✈️', '🚌', '🚇', '🛵', '🚕', '🛳️', '🚲',
  '🛍️', '👗', '👟', '💄', '🧴', '🛒', '👜', '💍',
  '💡', '🏠', '📱', '💻', '🎮', '📺', '🔌', '🖨️',
  '🎬', '🎵', '🎭', '🎨', '📚', '🎪', '🎤', '🎧',
  '💊', '🏥', '🏃', '🧘', '💪', '🩺', '🧬', '🏋️',
  '💰', '💳', '💵', '🎁', '💎', '🏦', '📈', '🪙',
  '🌿', '🌟', '✨', '🔥', '❤️', '🎯', '⚡', '🌈',
];

void showCategoryFormSheet(
  BuildContext context, {
  required void Function(CustomCategory) onSave,
  CustomCategory? initialCategory,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryFormSheet(onSave: onSave, initialCategory: initialCategory),
  );
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({required this.onSave, this.initialCategory});
  final void Function(CustomCategory) onSave;
  final CustomCategory? initialCategory;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final TextEditingController _nameCtrl;
  late final ValueNotifier<String> _selectedEmoji;
  late final ValueNotifier<int> _colorIndex;
  final _showEmojiPicker = ValueNotifier<bool>(false);

  bool get _isEdit => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialCategory?.name ?? '');
    _selectedEmoji = ValueNotifier(widget.initialCategory?.emoji ?? '');
    _colorIndex = ValueNotifier(widget.initialCategory?.colorIndex ?? 0);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _selectedEmoji.dispose();
    _colorIndex.dispose();
    _showEmojiPicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isEdit ? 'Edit Category' : 'New Category',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: _selectedEmoji,
                    builder: (context, emoji, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _showEmojiPicker,
                        builder: (context, showPicker, _) {
                          return GestureDetector(
                            onTap: () => _showEmojiPicker.value = !showPicker,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 60,
                              height: 52,
                              decoration: BoxDecoration(
                                color: showPicker ? kPrimary.withValues(alpha: 0.1) : colors.cardAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: showPicker ? Border.all(color: kPrimary.withValues(alpha: 0.4)) : null,
                              ),
                              alignment: Alignment.center,
                              child: emoji.isEmpty
                                  ? Icon(Icons.add_reaction_outlined, size: 22, color: colors.textSec)
                                  : Text(emoji, style: const TextStyle(fontSize: 26)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: colors.cardAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _nameCtrl,
                        style: TextStyle(fontSize: 15, color: colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Category name',
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
                  ),
                ],
              ),

              ValueListenableBuilder<bool>(
                valueListenable: _showEmojiPicker,
                builder: (context, showPicker, _) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: showPicker
                        ? Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.cardAlt,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Wrap(
                              spacing: 2,
                              runSpacing: 2,
                              children: _pickerEmojis.map((e) {
                                return GestureDetector(
                                  onTap: () {
                                    _selectedEmoji.value = e;
                                    _showEmojiPicker.value = false;
                                  },
                                  child: Container(
                                    width: 38, height: 38,
                                    alignment: Alignment.center,
                                    child: Text(e, style: const TextStyle(fontSize: 22)),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),

              const SizedBox(height: 16),

              Text('Color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSec, letterSpacing: 0.6)),
              const SizedBox(height: 10),
              ValueListenableBuilder<int>(
                valueListenable: _colorIndex,
                builder: (context, idx, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(CustomCategory.presetColors.length, (i) {
                      final selected = i == idx;
                      return GestureDetector(
                        onTap: () => _colorIndex.value = i,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: CustomCategory.presetColors[i],
                            shape: BoxShape.circle,
                            border: selected ? Border.all(color: colors.textPrimary, width: 2.5) : null,
                            boxShadow: selected
                                ? [BoxShadow(color: CustomCategory.presetColors[i].withValues(alpha: 0.5), blurRadius: 8)]
                                : null,
                          ),
                          child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 24),

              ListenableBuilder(
                listenable: Listenable.merge([_nameCtrl, _selectedEmoji]),
                builder: (context, _) {
                  final canSave = _nameCtrl.text.trim().isNotEmpty && _selectedEmoji.value.isNotEmpty;
                  return GestureDetector(
                    onTap: canSave
                        ? () {
                            widget.onSave(CustomCategory(
                              name: _nameCtrl.text.trim(),
                              emoji: _selectedEmoji.value,
                              colorIndex: _colorIndex.value,
                            ));
                            Navigator.pop(context);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: canSave ? const LinearGradient(colors: [kPrimaryLight, kPrimary]) : null,
                        color: canSave ? null : colors.cardAlt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _isEdit ? 'Save Changes' : 'Add Category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: canSave ? Colors.white : colors.textSec,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
