import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/presentation/screens/add_expense_screen.dart';
import 'package:hisabi/presentation/screens/analytics_screen.dart';
import 'package:hisabi/presentation/screens/edit_expense_screen.dart';
import 'package:hisabi/presentation/screens/home_screen.dart';
import 'package:hisabi/presentation/screens/onboarding_screen.dart';
import 'package:hisabi/presentation/screens/settings_screen.dart';
import 'package:hisabi/presentation/screens/sign_in_screen.dart';
import 'package:hisabi/presentation/screens/verify_email_screen.dart';

GoRouter createRouter(ValueGetter<bool> isOnboardingDone) {
  final notifier = _AuthChangeNotifier();
  return GoRouter(
    initialLocation: _initialLocation(isOnboardingDone()),
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loc = state.matchedLocation;
      final isAuthPage = loc == '/sign-in' || loc == '/sign-up';
      final isVerifyPage = loc == '/verify-email';

      if (user == null) {
        return isAuthPage ? null : '/sign-in';
      }
      if (!user.emailVerified) {
        return isVerifyPage ? null : '/verify-email';
      }
      if (isAuthPage || isVerifyPage) {
        return isOnboardingDone() ? '/' : '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        pageBuilder: (_, state) =>
            NoTransitionPage(key: state.pageKey, child: const SignInScreen()),
      ),
      GoRoute(
        path: '/sign-up',
        pageBuilder: (_, state) => _slideRightPage(state, const SignUpScreen()),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (_, state) =>
            NoTransitionPage(key: state.pageKey, child: const VerifyEmailScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, state) =>
            NoTransitionPage(key: state.pageKey, child: const OnboardingScreen()),
      ),
    GoRoute(
      path: '/settings',
      pageBuilder: (_, state) => _slideRightPage(state, const SettingsScreen()),
    ),
    GoRoute(
      path: '/add-expense',
      pageBuilder: (_, state) =>
          _slideRightPage(state, const AddExpenseScreen()),
    ),
    GoRoute(
      path: '/edit-expense',
      pageBuilder: (_, state) => _slideRightPage(
        state,
        EditExpenseScreen(expense: state.extra! as Expense),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          _ScaffoldWithNavBar(state: state, child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/analytics',
          builder: (_, __) => const AnalyticsScreen(),
        ),
      ],
    ),
  ],
  );
}

String _initialLocation(bool onboardingDone) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return '/sign-in';
  if (!user.emailVerified) return '/verify-email';
  return onboardingDone ? '/' : '/onboarding';
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    _sub = FirebaseAuth.instance.userChanges().listen((_) => notifyListeners());
  }
  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

CustomTransitionPage<void> _slideRightPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5),
        ),
        child: SlideTransition(position: animation.drive(tween), child: child),
      );
    },
  );
}

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.state, required this.child});
  final GoRouterState state;
  // ignore: unused_field
  final Widget child;

  bool get _isHome => state.uri.path == '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _isHome ? 0 : 1,
        children: const [HomeScreen(), AnalyticsScreen()],
      ),
      bottomNavigationBar: _FloatingNavBar(
        isHome: _isHome,
        onHome: () => context.go('/'),
        onAdd: () => context.push('/add-expense'),
        onAnalytics: () => context.go('/analytics'),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.isHome,
    required this.onHome,
    required this.onAdd,
    required this.onAnalytics,
  });
  final bool isHome;
  final VoidCallback onHome;
  final VoidCallback onAdd;
  final VoidCallback onAnalytics;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 220,
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavIcon(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    selected: isHome,
                    onTap: onHome,
                  ),
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  _NavIcon(
                    icon: Icons.pie_chart_outline,
                    selectedIcon: Icons.pie_chart_rounded,
                    selected: !isHome,
                    onTap: onAnalytics,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? kPrimary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          selected ? selectedIcon : icon,
          color: selected ? kPrimary : context.appColors.textSec,
          size: 24,
        ),
      ),
    );
  }
}
