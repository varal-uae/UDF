import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Applies Habot Material 3 theme tokens to the component catalog shell.
class AppThemeWrapper extends StatelessWidget {
  final Widget child;
  final ThemeMode themeMode;

  const AppThemeWrapper({
    super.key,
    required this.child,
    this.themeMode = ThemeMode.light,
  });

  @override
  Widget build(BuildContext context) {
    final lightScheme = AppTokens.colorScheme(Brightness.light);
    final darkScheme = AppTokens.colorScheme(Brightness.dark);

    return MaterialApp(
      title: 'Habot Mobile UI Component Library',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        textTheme: AppTokens.textTheme(lightScheme),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        textTheme: AppTokens.textTheme(darkScheme),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          ),
        ),
      ),
      home: child,
    );
  }
}
