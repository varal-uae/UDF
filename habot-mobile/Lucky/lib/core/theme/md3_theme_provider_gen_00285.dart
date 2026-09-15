// GEN-00285 — MD3 Theme Provider & Design Tokens Context.
// Provides reactive Material 3 theme management, dynamic color schemes, elevation tokens, and breakpoint metrics.

import 'package:flutter/material.dart';

/// Design token specifications adhering to Material Design 3 and ISO/IEC 25010 suitability.
class MD3DesignTokens {
  const MD3DesignTokens._();

  // Touch targets
  static const double minTouchTarget = 48.0;

  // Elevation levels according to M3 spec
  static const double elevationLevel0 = 0.0;
  static const double elevationLevel1 = 1.0;
  static const double elevationLevel2 = 3.0;
  static const double elevationLevel3 = 6.0;
  static const double elevationLevel4 = 8.0;
  static const double elevationLevel5 = 12.0;

  // Responsive Breakpoints
  static const double mobileCompactMax = 599.0;
  static const double tabletMediumMax = 839.0;
  static const double desktopExpandedMin = 840.0;

  // Default Seed Palette
  static const Color primarySeedColor = Color(0xFF006494);
  static const Color secondarySeedColor = Color(0xFF4C616B);
  static const Color tertiarySeedColor = Color(0xFF5B5B7E);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color successColor = Color(0xFF1E824C);
  static const Color warningColor = Color(0xFFD97706);
}

/// Dynamic Theme State Container for MD3.
class MD3ThemeState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = MD3DesignTokens.primarySeedColor;
  bool _useMaterialYouDynamic = true;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  bool get useMaterialYouDynamic => _useMaterialYouDynamic;

  /// EC: ToggleThemeMode
  void updateThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  /// EC: UpdateSeedColor
  void updateSeedColor(Color color) {
    if (_seedColor != color) {
      _seedColor = color;
      notifyListeners();
    }
  }

  /// EC: ToggleDynamicColor
  void toggleMaterialYou(bool enabled) {
    if (_useMaterialYouDynamic != enabled) {
      _useMaterialYouDynamic = enabled;
      notifyListeners();
    }
  }

  /// EC: GenerateLightTheme
  ThemeData buildLightTheme({ColorScheme? dynamicLight}) {
    final ColorScheme colorScheme = dynamicLight ??
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardTheme(
        elevation: MD3DesignTokens.elevationLevel2,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// EC: GenerateDarkTheme
  ThemeData buildDarkTheme({ColorScheme? dynamicDark}) {
    final ColorScheme colorScheme = dynamicDark ??
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardTheme(
        elevation: MD3DesignTokens.elevationLevel2,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

/// InheritedScope to expose theme actions and design tokens down the widget tree.
class _MD3InheritedThemeContext extends InheritedNotifier<MD3ThemeState> {
  const _MD3InheritedThemeContext({
    required MD3ThemeState state,
    required super.child,
  }) : super(notifier: state);
}

/// MD3ThemeProvider provides root access to Material 3 tokens, theme switching, and layout helpers.
class MD3ThemeProvider extends StatefulWidget {
  final Widget child;
  final Color initialSeedColor;
  final ThemeMode initialThemeMode;

  const MD3ThemeProvider({
    super.key,
    required this.child,
    this.initialSeedColor = MD3DesignTokens.primarySeedColor,
    this.initialThemeMode = ThemeMode.system,
  });

  /// Access theme controller state from descendant context.
  static MD3ThemeState of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_MD3InheritedThemeContext>();
    assert(inherited != null, 'No MD3ThemeProvider found in context');
    return inherited!.notifier!;
  }

  /// Check whether current viewport represents compact mobile width (< 600dp).
  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < MD3DesignTokens.mobileCompactMax;
  }

  /// Check whether current viewport represents expanded desktop width (>= 840dp).
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= MD3DesignTokens.desktopExpandedMin;
  }

  @override
  State<MD3ThemeProvider> createState() => _MD3ThemeProviderState();
}

class _MD3ThemeProviderState extends State<MD3ThemeProvider> {
  late final MD3ThemeState _state;

  @override
  void initState() {
    super.initState();
    _state = MD3ThemeState()
      ..updateSeedColor(widget.initialSeedColor)
      ..updateThemeMode(widget.initialThemeMode);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MD3InheritedThemeContext(
      state: _state,
      child: widget.child,
    );
  }
}
