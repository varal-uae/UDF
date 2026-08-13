import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'app_theme.dart';

enum AppThemeMode {
  system,
  light,
  dark,
  dynamicLight,
  dynamicDark,
}

class AppThemeController extends InheritedWidget {
  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeModeChanged;

  const AppThemeController({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required super.child,
  });

  static AppThemeController of(BuildContext context) {
    final controller = context.dependOnInheritedWidgetOfExactType<AppThemeController>();
    assert(controller != null, 'No AppThemeController found in context');
    return controller!;
  }

  @override
  bool updateShouldNotify(AppThemeController oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

class AppThemeWrapper extends StatefulWidget {
  final Widget Function(BuildContext context, ThemeData lightTheme, ThemeData darkTheme, ThemeMode mode) builder;
  final AppThemeMode initialMode;

  const AppThemeWrapper({
    super.key,
    required this.builder,
    this.initialMode = AppThemeMode.system,
  });

  @override
  State<AppThemeWrapper> createState() => _AppThemeWrapperState();
}

class _AppThemeWrapperState extends State<AppThemeWrapper> {
  late AppThemeMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
  }

  void _setThemeMode(AppThemeMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ThemeData lightTheme;
        ThemeData darkTheme;
        ThemeMode mode;

        switch (_currentMode) {
          case AppThemeMode.light:
            lightTheme = AppTheme.light();
            darkTheme = AppTheme.dark();
            mode = ThemeMode.light;
            break;
          case AppThemeMode.dark:
            lightTheme = AppTheme.light();
            darkTheme = AppTheme.dark();
            mode = ThemeMode.dark;
            break;
          case AppThemeMode.dynamicLight:
            lightTheme = AppTheme.light(dynamicLight: lightDynamic);
            darkTheme = AppTheme.dark(dynamicDark: darkDynamic);
            mode = ThemeMode.light;
            break;
          case AppThemeMode.dynamicDark:
            lightTheme = AppTheme.light(dynamicLight: lightDynamic);
            darkTheme = AppTheme.dark(dynamicDark: darkDynamic);
            mode = ThemeMode.dark;
            break;
          case AppThemeMode.system:
            lightTheme = AppTheme.light(dynamicLight: lightDynamic);
            darkTheme = AppTheme.dark(dynamicDark: darkDynamic);
            mode = ThemeMode.system;
            break;
        }

        return AppThemeController(
          themeMode: _currentMode,
          onThemeModeChanged: _setThemeMode,
          child: widget.builder(context, lightTheme, darkTheme, mode),
        );
      },
    );
  }
}
