import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'text_theme.dart';
import 'design_tokens.dart';

// BPTR-0237-A01 — App theme assembly.
// Composes habotLightColorScheme + habotDarkColorScheme + habotTextTheme
// into ready-to-use ThemeData instances.
// Wire into MaterialApp: theme: habotLightTheme, darkTheme: habotDarkTheme.

final ThemeData habotLightTheme = ThemeData(
  useMaterial3:  true,
  colorScheme:   habotLightColorScheme,
  textTheme:     habotTextTheme,

  // — Spacing & Shape —
  cardTheme: CardTheme(
    elevation:    HabotElevation.level1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(HabotRadius.md),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(HabotRadius.sm),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: HabotSpacing.md,
      vertical:   HabotSpacing.sm,
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize:    const Size(0, 48), // 48dp touch target
      padding: const EdgeInsets.symmetric(horizontal: HabotSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HabotRadius.full),
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: HabotSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HabotRadius.full),
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: HabotSpacing.md),
    ),
  ),

  appBarTheme: const AppBarTheme(
    elevation:       HabotElevation.level0,
    scrolledUnderElevation: HabotElevation.level2,
    centerTitle:     false,
  ),

  navigationBarTheme: NavigationBarThemeData(
    elevation: HabotElevation.level2,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
  ),

  dividerTheme: const DividerThemeData(
    space:     1,
    thickness: 1,
  ),
);

final ThemeData habotDarkTheme = habotLightTheme.copyWith(
  colorScheme: habotDarkColorScheme,
);
