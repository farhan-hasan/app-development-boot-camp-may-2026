import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/constants.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _index = 0;
  final _pageCtrl = PageController();

  void _goTo(int i) {
    _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    setState(() => _index = i);
  }

  Future<void> _complete() async {
    await ref.read(onboardingCompletedProvider.notifier).complete();
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = AppConstants.onboardingSlides;
    final slide = slides[_index];
    final accent = slide['accent'] as Color;

    return Scaffold(
      body: Column(
        children: [
          // Hero area (~65%)
          Expanded(
            flex: 65,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: List<Color>.from(slide['gradient'] as List),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: -40, left: -60, child: _Circle(opacity: 0.06)),
                  Positioned(bottom: -60, right: -40, child: _Circle(opacity: 0.06, size: 240)),
                  SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FloatingEmoji(emoji: slide['emoji'] as String),
                            const SizedBox(height: 24),
                            Text(
                              slide['title'] as String,
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.25),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              slide['description'] as String,
                              style: const TextStyle(fontSize: 15, color: Color(0xCCFFFFFF), height: 1.6),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom panel (~35%)
          Expanded(
            flex: 35,
            child: Container(
              color: context.appColors.bg,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Column(
                children: [
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = i == _index;
                      return GestureDetector(
                        onTap: () => _goTo(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: active ? accent : context.appColors.border,
                          ),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (_index < 2) ...[
                        Expanded(
                          child: _OBButton(label: 'Skip', isSecondary: true, onTap: _complete),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: _index < 2 ? 2 : 1,
                        child: _OBButton(
                          label: _index < 2 ? 'Next' : 'Get Started',
                          accent: accent,
                          onTap: _index < 2 ? () => _goTo(_index + 1) : _complete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({this.opacity = 0.06, this.size = 200});
  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)),
  );
}

class _FloatingEmoji extends StatefulWidget {
  const _FloatingEmoji({required this.emoji});
  final String emoji;

  @override
  State<_FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<_FloatingEmoji> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: -8).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, child) => Transform.translate(offset: Offset(0, _anim.value), child: child),
    child: Text(widget.emoji, style: const TextStyle(fontSize: 80)),
  );
}

class _OBButton extends StatelessWidget {
  const _OBButton({required this.label, required this.onTap, this.isSecondary = false, this.accent});
  final String label;
  final VoidCallback onTap;
  final bool isSecondary;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(color: context.appColors.cardAlt, borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.appColors.textSec)),
        ),
      );
    }
    final c = accent ?? kPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c.withOpacity(0.85), c]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}
