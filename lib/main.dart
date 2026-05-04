import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  runApp(ProviderScope(
    overrides: [
      onboardingCompletedProvider.overrideWith((_) => OnboardingNotifier(onboardingDone)),
    ],
    child: HisabiApp(initialRoute: onboardingDone ? '/' : '/onboarding'),
  ));
}

class HisabiApp extends ConsumerWidget {
  const HisabiApp({super.key, required this.initialRoute});
  final String initialRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Hisabi',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: createRouter(initialRoute),
      debugShowCheckedModeBanner: false,
    );
  }
}
