import 'package:flutter/material.dart';
import 'screen_size_service.dart';
import 'screen_size_analytics.dart';

// SSELC-025-A01 — Background orientation & metrics listener.
// Registers with WidgetsBinding to receive didChangeMetrics() callbacks.
// Covers: device rotation, split-screen activation, window resize (desktop/tablet).
// Mount once at app root — see app.dart.

class OrientationListener extends StatefulWidget {
  const OrientationListener({super.key, required this.child});

  final Widget child;

  @override
  State<OrientationListener> createState() => _OrientationListenerState();
}

class _OrientationListenerState extends State<OrientationListener>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Seed initial dimensions after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Fires on rotation, split-screen, window resize.
  @override
  void didChangeMetrics() => _measure();

  void _measure() {
    final view = View.of(context);
    final size = view.physicalSize / view.devicePixelRatio;

    final previous = ScreenSizeService.instance.sizeClass;
    ScreenSizeService.instance.update(size.width, size.height);
    final current = ScreenSizeService.instance.sizeClass;

    // Log to analytics on every size class change.
    if (previous != current) {
      ScreenSizeAnalytics.log(
        width:      size.width,
        height:     size.height,
        sizeClass:  current,
        orientation: ScreenSizeService.instance.orientation,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
