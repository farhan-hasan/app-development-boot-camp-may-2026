import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.isDark = true});
  final bool isDark;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA);
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF0F172A).withValues(alpha: 0.45);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icon/app_icon.png',
                  width: 128,
                  height: 128,
                ),
                Text(
                  'HISABI',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Expense Tracker',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: subtitleColor,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
