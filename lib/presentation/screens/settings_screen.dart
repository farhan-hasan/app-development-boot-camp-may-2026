import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/constants.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/presentation/providers/auth_provider.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';
import 'package:hisabi/presentation/widgets/category_form_sheet.dart';
import 'package:hisabi/utils/network_utils.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);
    final customCats = ref.watch(customCategoriesProvider);
    final isDark = themeMode == ThemeMode.dark;
    final user = FirebaseAuth.instance.currentUser;

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
        title: Text('Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Profile card
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kPrimaryLight, kPrimary]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text('💳', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'My Wallet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Personal expense tracker',
                        style: TextStyle(fontSize: 13, color: colors.textSec),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _SectionHeader('APPEARANCE', colors),
          _SettingsCard(colors: colors, children: [
            _SettingsRow(
              icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              iconBg: colors.cardAlt,
              label: 'Dark Mode',
              colors: colors,
              trailing: _Toggle(
                value: isDark,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
              ),
            ),
          ]),

          _SectionHeader('PREFERENCES', colors),
          _SettingsCard(colors: colors, children: [
            _SettingsRow(
              icon: Icons.language_outlined,
              iconBg: colors.cardAlt,
              label: 'Currency',
              sublabel: currency,
              colors: colors,
              onTap: () => _showCurrencyPicker(context, ref, colors, currency),
            ),
          ]),

          _SectionHeader('ABOUT', colors),
          _SettingsCard(colors: colors, children: [
            _SettingsRow(
              icon: Icons.info_outline,
              iconBg: colors.cardAlt,
              label: 'App Version',
              sublabel: '1.0.0',
              colors: colors,
            ),
          ]),

          _SectionHeader('CATEGORIES', colors),
          if (customCats.isEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text('No custom categories yet', style: TextStyle(fontSize: 13, color: colors.textSec)),
              ),
            )
          else
            _SettingsCard(
              colors: colors,
              children: customCats.asMap().entries.expand((entry) {
                final i = entry.key;
                final cat = entry.value;
                return [
                  if (i > 0) Divider(color: colors.border, height: 1, indent: 68, endIndent: 16),
                  _CategorySettingsRow(
                    cat: cat,
                    colors: colors,
                    onEdit: () => showCategoryFormSheet(
                      context,
                      initialCategory: cat,
                      onSave: (updated) =>
                          ref.read(customCategoriesProvider.notifier).update(cat.name, updated),
                    ),
                    onDelete: () => _confirmDeleteCategory(context, ref, cat, colors),
                  ),
                ];
              }).toList(),
            ),

          _SectionHeader('DATA', colors),
          _SettingsCard(colors: colors, children: [
            _ClearDataRow(colors: colors),
          ]),

          _SectionHeader('ACCOUNT', colors),
          _SettingsCard(colors: colors, children: [
            _SettingsRow(
              icon: Icons.logout_rounded,
              iconBg: kDanger.withValues(alpha: 0.1),
              label: 'Sign Out',
              colors: colors,
              isDestructive: true,
              onTap: () => _confirmSignOut(context, ref, colors),
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref, AppColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be returned to the sign in screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, WidgetRef ref, CustomCategory cat, AppColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Remove "${cat.name}"? Existing expenses won\'t be affected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(customCategoriesProvider.notifier).remove(cat.name);
            },
            child: const Text('Delete', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, AppColors colors, String current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(color: colors.card, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Select Currency', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            const SizedBox(height: 16),
            ...AppConstants.currencies.map((c) {
              final isSelected = c['symbol'] == current;
              return ListTile(
                onTap: () {
                  ref.read(currencyProvider.notifier).setCurrency(c['symbol']!);
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary.withValues(alpha: 0.1) : colors.cardAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(c['symbol']!, style: TextStyle(fontSize: 18, color: isSelected ? kPrimary : colors.textPrimary, fontWeight: FontWeight.w600)),
                ),
                title: Text(c['name']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                trailing: isSelected ? const Icon(Icons.check, color: kPrimary) : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text, this.colors);
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textSec, letterSpacing: 0.8)),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.colors, required this.children});
  final AppColors colors;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(16)),
    child: Column(children: children),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon, required this.iconBg, required this.label, required this.colors,
    this.sublabel, this.trailing, this.onTap, this.isDestructive = false,
  });
  final IconData icon;
  final Color iconBg;
  final String label;
  final AppColors colors;
  final String? sublabel;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: isDestructive ? kDanger : colors.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDestructive ? kDanger : colors.textPrimary)),
                if (sublabel != null) Text(sublabel!, style: TextStyle(fontSize: 12, color: colors.textSec)),
              ],
            ),
          ),
          if (trailing != null) trailing!
          else if (onTap != null) Icon(Icons.chevron_right, size: 18, color: colors.textSec),
        ],
      ),
    ),
  );
}

class _ClearDataRow extends ConsumerStatefulWidget {
  const _ClearDataRow({required this.colors});
  final AppColors colors;

  @override
  ConsumerState<_ClearDataRow> createState() => _ClearDataRowState();
}

class _ClearDataRowState extends ConsumerState<_ClearDataRow> {
  final _confirming = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _confirming.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _confirming,
      builder: (context, confirming, _) {
        return _SettingsRow(
          icon: Icons.delete_sweep_outlined,
          iconBg: kDanger.withValues(alpha: 0.1),
          label: confirming ? 'Tap again to confirm' : 'Clear All Data',
          colors: widget.colors,
          isDestructive: true,
          onTap: () async {
            if (confirming) {
              _confirming.value = false;
              try {
                await ref.read(expenseListProvider.notifier).clearAll();
                await ref.read(customCategoriesProvider.notifier).clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All data cleared'),
                      backgroundColor: kDanger,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) showNetworkSnackBar(context, e);
              }
            } else {
              _confirming.value = true;
              Future.delayed(const Duration(seconds: 3), () {
                if (context.mounted) _confirming.value = false;
              });
            }
          },
        );
      },
    );
  }
}

class _CategorySettingsRow extends StatelessWidget {
  const _CategorySettingsRow({
    required this.cat,
    required this.colors,
    required this.onEdit,
    required this.onDelete,
  });
  final CustomCategory cat;
  final AppColors colors;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(cat.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(cat.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: colors.cardAlt, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.edit_outlined, size: 15, color: colors.textSec),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: kDanger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.delete_outline, size: 15, color: kDanger),
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46, height: 26,
      decoration: BoxDecoration(
        color: value ? kPrimary : context.appColors.border,
        borderRadius: BorderRadius.circular(13),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(3),
          width: 20, height: 20,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    ),
  );
}
