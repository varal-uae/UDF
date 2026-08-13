import 'package:flutter/material.dart';
import 'router.dart';
import '../core/error/error_boundary.dart';
import '../core/theme/habot_theme.dart';
import '../shared/layout/screen_size_provider.dart';
import '../shared/layout/orientation_listener.dart';

class HabotApp extends StatelessWidget {
  const HabotApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenSizeProvider sits at the very top — makes SizeClass available
    // to every widget in the tree via ScreenSizeProvider.of(context).
    // OrientationListener fires didChangeMetrics on rotation / split-screen.
    return ScreenSizeProvider(
      child: OrientationListener(
        child: ErrorBoundary(
          module: 'app-root',
          child: MaterialApp.router(
            title: 'Habot',
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
            theme:     habotLightTheme,
            darkTheme: habotDarkTheme,
            themeMode: ThemeMode.system,
          ),
        ),
      ),
    );
  }
}
