// DPNDL-002-A07 — Mobile-First Global Breakpoint Variable Set & Layout.
// Defines the 360dp mobile base, min-width scale-up breakpoints, and responsive layout helpers.

import 'package:flutter/material.dart';

class Dpndl002A07Breakpoints {
  Dpndl002A07Breakpoints._();

  static const double mobileBase = 360.0;
  static const double compactMin = mobileBase;
  static const double mediumMin = 600.0;
  static const double expandedMin = 840.0;
  static const double largeMin = 1200.0;
  static const double wideMin = 1440.0;
  static const double maxContentWidth = 1440.0;

  static Dpndl002A07WindowClass classify(double width) {
    if (width >= wideMin) return Dpndl002A07WindowClass.wide;
    if (width >= largeMin) return Dpndl002A07WindowClass.large;
    if (width >= expandedMin) return Dpndl002A07WindowClass.expanded;
    if (width >= mediumMin) return Dpndl002A07WindowClass.medium;
    return Dpndl002A07WindowClass.compact;
  }

  static T valueForWidth<T>(
    double width, {
    required T compact,
    T? medium,
    T? expanded,
    T? large,
    T? wide,
  }) {
    switch (classify(width)) {
      case Dpndl002A07WindowClass.wide:
        return wide ?? large ?? expanded ?? medium ?? compact;
      case Dpndl002A07WindowClass.large:
        return large ?? expanded ?? medium ?? compact;
      case Dpndl002A07WindowClass.expanded:
        return expanded ?? medium ?? compact;
      case Dpndl002A07WindowClass.medium:
        return medium ?? compact;
      case Dpndl002A07WindowClass.compact:
        return compact;
    }
  }
}

enum Dpndl002A07WindowClass {
  compact,
  medium,
  expanded,
  large,
  wide,
}

extension Dpndl002A07BuildContext on BuildContext {
  double get dpndl002A07Width => MediaQuery.of(this).size.width;

  Dpndl002A07WindowClass get dpndl002A07WindowClass =>
      Dpndl002A07Breakpoints.classify(dpndl002A07Width);

  bool get dpndl002A07IsMobile =>
      dpndl002A07Width < Dpndl002A07Breakpoints.mediumMin;

  bool get dpndl002A07IsTablet =>
      dpndl002A07Width >= Dpndl002A07Breakpoints.mediumMin &&
      dpndl002A07Width < Dpndl002A07Breakpoints.expandedMin;

  bool get dpndl002A07IsDesktop =>
      dpndl002A07Width >= Dpndl002A07Breakpoints.expandedMin;
}

class Dpndl002A07MobileFirstLayout extends StatelessWidget {
  const Dpndl002A07MobileFirstLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.wide,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final WidgetBuilder? large;
  final WidgetBuilder? wide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final windowClass =
            Dpndl002A07Breakpoints.classify(constraints.maxWidth);
        final builder = switch (windowClass) {
          Dpndl002A07WindowClass.wide =>
            wide ?? large ?? expanded ?? medium ?? compact,
          Dpndl002A07WindowClass.large =>
            large ?? expanded ?? medium ?? compact,
          Dpndl002A07WindowClass.expanded => expanded ?? medium ?? compact,
          Dpndl002A07WindowClass.medium => medium ?? compact,
          Dpndl002A07WindowClass.compact => compact,
        };
        return builder(context);
      },
    );
  }
}
