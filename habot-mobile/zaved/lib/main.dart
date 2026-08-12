import 'package:flutter/material.dart';
import 'theme/payment_status_theme.dart';
import 'theme/semantic_status_colors.dart';
import 'ui/master_menu_page.dart';

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
    return MaterialApp(
      title: 'Design System Master Catalog',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        extensions: const <ThemeExtension<dynamic>>[
          PaymentStatusTheme.light,
          SemanticStatusColors.light,
        ],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        extensions: const <ThemeExtension<dynamic>>[
          PaymentStatusTheme.light,
          SemanticStatusColors.dark,
        ],
      ),
      home: const MasterMenuPage(),
    );
  }
}
