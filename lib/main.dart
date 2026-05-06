import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisabi/config/router.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/firebase_options.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';
import 'package:hisabi/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load prefs first (fast) so splash uses the correct saved theme.
  final prefs = await SharedPreferences.getInstance();
  final themeStr = prefs.getString('theme_mode');
  ThemeMode initialTheme = ThemeMode.dark;
  if (themeStr == 'light') initialTheme = ThemeMode.light;
  if (themeStr == 'dark') initialTheme = ThemeMode.dark;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(isDark: initialTheme != ThemeMode.light),
  ));

  final startTime = DateTime.now();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final onboardingDone = prefs.getBool('onboarding_completed') ?? false;

  // Guarantee at least 2 seconds of splash.
  final elapsed = DateTime.now().difference(startTime);
  const minDuration = Duration(seconds: 2);
  if (elapsed < minDuration) {
    await Future.delayed(minDuration - elapsed);
  }

  runApp(ProviderScope(
    overrides: [
      onboardingCompletedProvider.overrideWith((_) => OnboardingNotifier(onboardingDone)),
      themeModeProvider.overrideWith((_) => ThemeModeNotifier(initialTheme)),
    ],
    child: HisabiApp(onboardingDone: onboardingDone),
  ));
}

class HisabiApp extends ConsumerStatefulWidget {
  const HisabiApp({super.key, required this.onboardingDone});
  final bool onboardingDone;

  @override
  ConsumerState<HisabiApp> createState() => _HisabiAppState();
}

class _HisabiAppState extends ConsumerState<HisabiApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(() => ref.read(onboardingCompletedProvider));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Hisabi',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
