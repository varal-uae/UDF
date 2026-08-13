import 'package:flutter/material.dart';
import '../tokens/density_tokens.dart';

abstract class AppAccessibilityUtils {
  static bool meetsMinTouchTarget(Size size) {
    return size.width >= AppDensityTokens.minTouchTargetSize &&
        size.height >= AppDensityTokens.minTouchTargetSize;
  }

  static bool isAccessiblePadding(EdgeInsets padding) {
    return padding.left >= AppDensityTokens.minItemPadding &&
        padding.right >= AppDensityTokens.minItemPadding &&
        padding.top >= AppDensityTokens.minItemPadding &&
        padding.bottom >= AppDensityTokens.minItemPadding;
  }

  static Widget wrapWithMinTouchTarget({required Widget child, Size minSize = const Size(48.0, 48.0)}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize.width,
        minHeight: minSize.height,
      ),
      child: Center(
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: child,
      ),
    );
  }
}
