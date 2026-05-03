import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/domain/entities/expense.dart';
import 'package:hisabi/presentation/screens/add_expense_screen.dart';
import 'package:hisabi/presentation/screens/analytics_screen.dart';
import 'package:hisabi/presentation/screens/edit_expense_screen.dart';
import 'package:hisabi/presentation/screens/home_screen.dart';
import 'package:hisabi/presentation/screens/onboarding_screen.dart';
import 'package:hisabi/presentation/screens/settings_screen.dart';

GoRouter createRouter(String initialRoute) => GoRouter(
  initialLocation: initialRoute,
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/add-expense', builder: (_, __) => const AddExpenseScreen()),
    GoRoute(
      path: '/edit-expense',
      builder: (_, state) => EditExpenseScreen(expense: state.extra! as Expense),
    ),
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithNavBar(state: state, child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
      ],
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.state, required this.child});
  final GoRouterState state;
  final Widget child;

  bool get _isHome => state.uri.path == '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: _isHome
          ? FloatingActionButton(
              onPressed: () => context.push('/add-expense'),
              elevation: 0,
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _isHome ? 0 : 1,
        onDestinationSelected: (i) => i == 0 ? context.go('/') : context.go('/analytics'),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Analytics'),
        ],
      ),
    );
  }
}
