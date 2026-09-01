import 'dart:math' as math;
import 'package:flutter/material.dart';

/// BPTR-0334-A15: Fluid Text Scaler mimicking CSS clamp(minRem, preferredVw, maxRem)
/// Calculates fluid scaling ratios to ensure text remains highly legible in stacked
/// mobile tables without manual pinching or zooming.
class FluidTextScaler extends TextScaler {
  final double minScale;
  final double maxScale;
  final double referenceWidth;
  final double currentWidth;

  const FluidTextScaler({
    this.minScale = 0.85,
    this.maxScale = 1.35,
    this.referenceWidth = 390.0, // Standard baseline mobile width (iPhone 14/15)
    required this.currentWidth,
  });

  /// Calculates dynamic clamped fluid scaling factor
  double get calculatedScaleFactor {
    if (currentWidth <= 0) return 1.0;
    final double ratio = currentWidth / referenceWidth;
    return ratio.clamp(minScale, maxScale);
  }

  @override
  double get textScaleFactor => calculatedScaleFactor;

  @override
  double scale(double fontSize) {
    return fontSize * calculatedScaleFactor;
  }

  @override
  TextScaler clamp({double minScaleFactor = 0.0, double maxScaleFactor = double.infinity}) {
    return FluidTextScaler(
      minScale: math.max(minScale, minScaleFactor),
      maxScale: math.min(maxScale, maxScaleFactor),
      referenceWidth: referenceWidth,
      currentWidth: currentWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FluidTextScaler &&
        other.minScale == minScale &&
        other.maxScale == maxScale &&
        other.referenceWidth == referenceWidth &&
        other.currentWidth == currentWidth;
  }

  @override
  int get hashCode => Object.hash(minScale, maxScale, referenceWidth, currentWidth);
}

/// Global MediaQuery Wrapper for Fluid Typography
class FluidTypographyScope extends StatelessWidget {
  final Widget child;

  const FluidTypographyScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final fluidScaler = FluidTextScaler(
      currentWidth: mediaQuery.size.width,
    );

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: fluidScaler,
      ),
      child: child,
    );
  }
}
