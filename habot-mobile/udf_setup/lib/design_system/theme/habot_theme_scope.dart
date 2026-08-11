/// AISS: TTMCS-004-A01 -- substep 3 "Build a performance-optimized theme
/// container that switches modes cleanly without triggering full component
/// reflows."
///
/// [InheritedNotifier] is the mechanism: when the controller notifies, only
/// widgets that actually called [HabotThemeScope.of] rebuild. Widgets that read
/// nothing from the scope are untouched. `test/aiss/ttmcs_004_test.dart` proves
/// this with rebuild counters rather than asserting it in a comment.
library;

import 'package:flutter/material.dart';

import 'theme_controller.dart';

class HabotThemeScope extends InheritedNotifier<HabotThemeController> {
  const HabotThemeScope({
    required HabotThemeController super.notifier,
    required super.child,
    super.key,
  });

  /// The controller this scope carries. Non-null by construction.
  HabotThemeController get controller => notifier!;

  /// Subscribing read -- the caller rebuilds when the theme mode changes.
  static HabotThemeController of(BuildContext context) {
    final HabotThemeScope? scope = context
        .dependOnInheritedWidgetOfExactType<HabotThemeScope>();
    if (scope == null) {
      throw FlutterError(
        'HabotThemeScope.of() called with a context that does not contain a '
        'HabotThemeScope. Wrap the app in HabotApp.',
      );
    }
    return scope.controller;
  }

  /// Non-subscribing read -- for event handlers that need to *set* the mode
  /// without signing the calling widget up for rebuilds.
  static HabotThemeController read(BuildContext context) {
    final HabotThemeScope? scope = context
        .getInheritedWidgetOfExactType<HabotThemeScope>();
    if (scope == null) {
      throw FlutterError(
        'HabotThemeScope.read() called with a context that does not contain a '
        'HabotThemeScope. Wrap the app in HabotApp.',
      );
    }
    return scope.controller;
  }
}
