/// AISS: TTMCS-004-A01 -- substep 2 "Write an atomic preference hook listening
/// directly to system dark preferences."
/// AISS: TTMCS-005-A01 -- substep 4 "System theme listeners."
///
/// Flutter translation note: the spec is written for a web client
/// ("browser system dark preferences", "root CSS custom properties"). The
/// equivalent on Flutter is [PlatformDispatcher.platformBrightness] plus the
/// [WidgetsBindingObserver.didChangePlatformBrightness] callback. Same
/// contract, native transport.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Holds the user's theme choice and mirrors the OS preference when the user
/// has not made an explicit choice.
///
/// A [ChangeNotifier] rather than a full state-management dependency: the theme
/// is one enum, and keeping it dependency-free means this package stays liftable
/// into `shared/` later without dragging a state library along.
class HabotThemeController extends ChangeNotifier with WidgetsBindingObserver {
  HabotThemeController({
    ThemeMode initialMode = ThemeMode.system,
    PlatformDispatcher? dispatcher,
  }) : _mode = initialMode,
       _dispatcher = dispatcher ?? PlatformDispatcher.instance {
    _platformBrightness = _dispatcher.platformBrightness;
  }

  final PlatformDispatcher _dispatcher;
  ThemeMode _mode;
  late Brightness _platformBrightness;
  bool _observing = false;

  ThemeMode get mode => _mode;

  /// The OS-level preference, regardless of the user's in-app override.
  Brightness get platformBrightness => _platformBrightness;

  /// The brightness that will actually be painted.
  Brightness get effectiveBrightness {
    switch (_mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return _platformBrightness;
    }
  }

  bool get isDark => effectiveBrightness == Brightness.dark;

  /// Start listening to OS brightness changes. Idempotent.
  void startListening() {
    if (_observing) {
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  void stopListening() {
    if (!_observing) {
      return;
    }
    WidgetsBinding.instance.removeObserver(this);
    _observing = false;
  }

  /// Called by the framework when the OS light/dark setting flips.
  @override
  void didChangePlatformBrightness() {
    syncPlatformBrightness(_dispatcher.platformBrightness);
  }

  /// Pull the current OS preference in. Exposed (rather than private) so the
  /// TTMCS-004 gate can drive it deterministically without a real OS event.
  @visibleForTesting
  void syncPlatformBrightness(Brightness brightness) {
    if (_platformBrightness == brightness) {
      return;
    }
    _platformBrightness = brightness;
    // Only notify if the change is actually visible to the user. When the user
    // has pinned light or dark, an OS flip must not churn the widget tree.
    if (_mode == ThemeMode.system) {
      notifyListeners();
    }
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
  }

  /// Cycle light -> dark -> system, the order used by the settings control.
  void toggle() {
    switch (_mode) {
      case ThemeMode.light:
        setMode(ThemeMode.dark);
      case ThemeMode.dark:
        setMode(ThemeMode.system);
      case ThemeMode.system:
        setMode(ThemeMode.light);
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
