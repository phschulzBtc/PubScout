import 'package:flutter/material.dart';

// Brand colors
const pubScoutGreen = Color(0xFF2D6A4F);
const pubScoutGreenDark = Color(0xFF1B4332);
const pubScoutAmber = Color(0xFFD4A373);
const pubScoutCoral = Color(0xFFE76F51);
const pubScoutCream = Color(0xFFFEFAE0);

final pubScoutTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: pubScoutGreen,
    primary: pubScoutGreen,
    secondary: pubScoutAmber,
    tertiary: pubScoutCoral,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    centerTitle: false,
    elevation: 0,
    backgroundColor: pubScoutGreenDark,
    foregroundColor: pubScoutCream,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: pubScoutCream,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: pubScoutGreen,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: BorderSide.none,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    showDragHandle: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
