import 'package:flutter/material.dart';

const pubScoutPrimary = Color(0xFF2D6A4F);
const pubScoutSecondary = Color(0xFFD4A373);

final pubScoutTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: pubScoutPrimary,
    secondary: pubScoutSecondary,
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
  ),
);
