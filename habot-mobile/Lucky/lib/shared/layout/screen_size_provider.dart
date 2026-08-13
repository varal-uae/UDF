import 'package:flutter/material.dart';
import 'screen_size_service.dart';
import 'size_class.dart';

// SSELC-025-A01 — Screen size provider.
// InheritedNotifier wrapping ScreenSizeService.
// Sits above MaterialApp so every widget in the tree can read the current
// SizeClass via ScreenSizeProvider.of(context) without its own MediaQuery call.

class ScreenSizeProvider extends InheritedNotifier<ScreenSizeService> {
  const ScreenSizeProvider({
    super.key,
    required super.child,
  }) : super(notifier: ScreenSizeService.instance);

  /// Returns the current [SizeClass].
  /// Falls back to [SizeClass.compact] if provider is not in tree.
  static SizeClass of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ScreenSizeProvider>();
    return provider?.notifier?.sizeClass ?? SizeClass.compact;
  }

  /// Returns the current [Orientation].
  static Orientation orientationOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ScreenSizeProvider>();
    return provider?.notifier?.orientation ?? Orientation.portrait;
  }

  @override
  bool updateShouldNotify(ScreenSizeProvider oldWidget) => true;
}
