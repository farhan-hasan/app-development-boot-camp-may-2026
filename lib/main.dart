import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisabi/config/router.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/firebase_options.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();

  final onboardingDone = prefs.getBool('onboarding_completed') ?? false;

  final themeStr = prefs.getString('theme_mode');
  ThemeMode initialTheme = ThemeMode.dark;
  if (themeStr == 'light') initialTheme = ThemeMode.light;
  if (themeStr == 'dark') initialTheme = ThemeMode.dark;

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
    _router = createRouter(widget.onboardingDone);
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
