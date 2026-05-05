import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Brand tokens
const Color kPrimary = Color(0xFF0D9488);
const Color kPrimaryLight = Color(0xFF14B8A6);
const Color kPrimaryDark = Color(0xFF0F766E);
const Color kExpense = Color(0xFFF97316);
const Color kSuccess = Color(0xFF22C55E);
const Color kDanger = Color(0xFFEF4444);

/// Custom design-token colors exposed via ThemeExtension.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.card,
    required this.cardAlt,
    required this.textPrimary,
    required this.textSec,
    required this.border,
    required this.navBg,
    required this.inputBg,
  });

  final Color bg;
  final Color card;
  final Color cardAlt;
  final Color textPrimary;
  final Color textSec;
  final Color border;
  final Color navBg;
  final Color inputBg;

  static const light = AppColors(
    bg: Color(0xFFFAFAFA),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF111827),
    textSec: Color(0xFF6B7280),
    border: Color(0xFFE5E7EB),
    navBg: Color(0xFFFFFFFF),
    inputBg: Color(0xFFF9FAFB),
  );

  static const dark = AppColors(
    bg: Color(0xFF0F172A),
    card: Color(0xFF1E293B),
    cardAlt: Color(0xFF162032),
    textPrimary: Color(0xFFF8FAFC),
    textSec: Color(0xFF94A3B8),
    border: Color(0xFF334155),
    navBg: Color(0xFF1E293B),
    inputBg: Color(0xFF0F172A),
  );

  @override
  AppColors copyWith({
    Color? bg, Color? card, Color? cardAlt,
    Color? textPrimary, Color? textSec, Color? border,
    Color? navBg, Color? inputBg,
  }) => AppColors(
    bg: bg ?? this.bg, card: card ?? this.card, cardAlt: cardAlt ?? this.cardAlt,
    textPrimary: textPrimary ?? this.textPrimary, textSec: textSec ?? this.textSec,
    border: border ?? this.border, navBg: navBg ?? this.navBg, inputBg: inputBg ?? this.inputBg,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSec: Color.lerp(textSec, other.textSec, t)!,
      border: Color.lerp(border, other.border, t)!,
      navBg: Color.lerp(navBg, other.navBg, t)!,
      inputBg: Color.lerp(inputBg, other.inputBg, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.light).textTheme),
  colorScheme: const ColorScheme.light(
    primary: kPrimary,
    primaryContainer: Color(0xFFCCFBF1),
    secondary: kExpense,
    error: kDanger,
    surface: Color(0xFFFFFFFF),
    onPrimary: Colors.white,
    onSurface: Color(0xFF111827),
  ),
  scaffoldBackgroundColor: const Color(0xFFFAFAFA),
  extensions: const [AppColors.light],
  cardTheme: const CardThemeData(
    elevation: 0,
    color: Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kDanger)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kDanger, width: 2)),
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    shape: CircleBorder(),
    backgroundColor: kPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFFFFFFFF),
    height: 64,
    elevation: 8,
    shadowColor: Colors.black12,
    indicatorColor: const Color(0x1F0D9488),
    labelTextStyle: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
        ? GoogleFonts.inter(color: kPrimary, fontSize: 12, fontWeight: FontWeight.w600)
        : GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 12)),
    iconTheme: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
        ? const IconThemeData(color: kPrimary, size: 22)
        : const IconThemeData(color: Color(0xFF6B7280), size: 22)),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
  colorScheme: const ColorScheme.dark(
    primary: kPrimary,
    primaryContainer: kPrimaryDark,
    secondary: kExpense,
    error: kDanger,
    surface: Color(0xFF1E293B),
    onPrimary: Colors.white,
    onSurface: Color(0xFFF8FAFC),
  ),
  scaffoldBackgroundColor: const Color(0xFF0F172A),
  extensions: const [AppColors.dark],
  cardTheme: const CardThemeData(
    elevation: 0,
    color: Color(0xFF1E293B),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kDanger)),
    filled: true,
    fillColor: const Color(0xFF0F172A),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    shape: CircleBorder(),
    backgroundColor: kPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF1E293B),
    height: 64,
    elevation: 8,
    shadowColor: Colors.black38,
    indicatorColor: const Color(0x330D9488),
    labelTextStyle: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
        ? GoogleFonts.inter(color: kPrimary, fontSize: 12, fontWeight: FontWeight.w600)
        : GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12)),
    iconTheme: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
        ? const IconThemeData(color: kPrimary, size: 22)
        : const IconThemeData(color: Color(0xFF94A3B8), size: 22)),
  ),
);
