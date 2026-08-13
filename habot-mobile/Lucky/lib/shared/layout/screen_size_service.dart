import 'package:flutter/material.dart';
import 'size_class.dart';
import 'breakpoints.dart';

// SSELC-025-A01 — Screen size detection service.
// Singleton ChangeNotifier. Owns the current SizeClass and orientation.
// Updated by OrientationListener on every didChangeMetrics() call.
// Consumed by ScreenSizeProvider throughout the widget tree.

class ScreenSizeService extends ChangeNotifier {
  ScreenSizeService._();
  static final ScreenSizeService instance = ScreenSizeService._();

  // Always boot in compact — spec: initialise strictly on compact 4-column viewport.
  SizeClass _sizeClass = SizeClass.compact;
  Orientation _orientation = Orientation.portrait;
  double _width = 0;
  double _height = 0;

  SizeClass  get sizeClass   => _sizeClass;
  Orientation get orientation => _orientation;
  double get width           => _width;
  double get height          => _height;

  /// Called by [OrientationListener] on every [didChangeMetrics].
  /// Falls back to compact if dimensions are zero or unclear.
  void update(double width, double height) {
    if (width <= 0 || height <= 0) {
      // Spec: fall back to compact when dimensions are unclear.
      _applyCompactFallback();
      return;
    }

    final newClass       = HabotBreakpoints.fromWidth(width);
    final newOrientation = width > height
        ? Orientation.landscape
        : Orientation.portrait;

    if (newClass == _sizeClass &&
        newOrientation == _orientation &&
        width == _width) return; // no change — skip rebuild

    _sizeClass   = newClass;
    _orientation = newOrientation;
    _width       = width;
    _height      = height;

    notifyListeners();
  }

  void _applyCompactFallback() {
    if (_sizeClass == SizeClass.compact) return;
    _sizeClass = SizeClass.compact;
    notifyListeners();
  }
}
