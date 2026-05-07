import 'package:flutter/material.dart';
import 'package:hisabi/config/theme.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({
    super.key,
    this.title = 'No expenses yet',
    this.subtitle = 'Tap + to add your first expense',
    this.icon = Icons.account_balance_wallet_outlined,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: -10).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, child) => Transform.translate(offset: Offset(0, _anim.value), child: child),
            child: Icon(widget.icon, size: 80, color: colors.border),
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              style: TextStyle(fontSize: 14, color: colors.textSec),
            ),
          ],
        ],
      ),
    );
  }
}
