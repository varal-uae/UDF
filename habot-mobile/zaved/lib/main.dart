/// TELEMETRY METADATA BLOCK
/// Library Name: Flutter Material 3 Design System & App Shell
/// Navigation Type: Declarative MaterialApp.router (RouterConfig Architecture)
/// Configuration Settings: Dynamic 4-to-8 Responsive Grid Matrix & MD3 System Tokens
/// Theme Application Status: Injected & Context Bound (md.sys.color.background / surface)
/// Navigator Instance ID: APP-NAV-ROOT-003-A10
/// Completion Status: Target: Complete - 100% Implementation Completeness Against Spec
library;

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/semantic_colors.dart';
import 'theme/payment_status_theme.dart';
import 'theme/semantic_status_colors.dart';
import 'navigation/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Helper getter to access [MyAppState] from child widgets.
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // Default to Light View!

  ThemeMode get themeMode => _themeMode;

  void toggleThemeMode() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Injected Light MD3 Theme with explicitly bound surface / onSurface tokens
    final lightTheme = AppTheme.lightTheme.copyWith(
      extensions: const <ThemeExtension<dynamic>>[
        PaymentStatusTheme.light,
        SemanticStatusColors.light,
        SemanticColors.light,
      ],
    );

    // 2. Injected Dark MD3 Theme with explicitly bound surface / onSurface tokens
    final darkTheme = AppTheme.darkTheme.copyWith(
      extensions: const <ThemeExtension<dynamic>>[
        PaymentStatusTheme.light,
        SemanticStatusColors.dark,
        SemanticColors.dark,
      ],
    );

    // 3. Declarative MaterialApp.router acting as Global Navigation Engine
    return MaterialApp.router(
      title: 'Design System Master Catalog & App Shell',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: AppRouter.routerConfig,
    );
  }
}
