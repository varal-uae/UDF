/// TELEMETRY METADATA BLOCK
/// Font Name: Inter, Roboto (Material Design 3 Typography Engine)
/// Font Size: Clamped MD3 Token Scale (0.8x - 1.2x Viewport Defensive Bounds)
/// Line Height: Dynamic MD3 Proportional Token Metric
/// Font Weight: MD3 Token Bound (w400 - w700)
/// Font File Path: lib/widgets/dynamic_typography_wrapper.dart
/// Completion Status: Target: Complete - 100% Typography Token Scale Adherence
library;

import 'package:flutter/material.dart';

/// Enum representing authorized Material Design 3 Typography Tokens
enum MD3TypographyToken {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

/// A globally reusable responsive text wrapper widget that enforces:
/// 1. Defensive Text Scaling Clamping (0.8x to 1.2x) via [MediaQuery.withClampedTextScaling].
/// 2. Strict Material Design 3 Typography token locking.
/// 3. Automated text-shadow purging for maximum GPU rendering performance.
/// 4. Hardcoded single-line overflow restrictions ([maxLines] = 1, [overflow] = [TextOverflow.ellipsis]).
class DynamicTypographyWrapper extends StatelessWidget {
  /// The string of text to display.
  final String text;

  /// Explicitly defined Material 3 [TextStyle] token (e.g. `Theme.of(context).textTheme.labelLarge`).
  final TextStyle? style;

  /// Optional MD3 Typography token selector for strict token adherence.
  final MD3TypographyToken? token;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// An alternative semantics label for accessibility.
  final String? semanticsLabel;

  /// The locale used to select region-specific glyphs.
  final Locale? locale;

  /// Directionality of the text.
  final TextDirection? textDirection;

  /// Min scale factor clamp limit.
  static const double minScaleLimit = 0.8;

  /// Max scale factor clamp limit.
  static const double maxScaleLimit = 1.2;

  const DynamicTypographyWrapper({
    super.key,
    required this.text,
    this.style,
    this.token,
    this.textAlign,
    this.semanticsLabel,
    this.locale,
    this.textDirection,
  });

  /// Factory constructor for MD3 `labelLarge` token
  factory DynamicTypographyWrapper.labelLarge({
    Key? key,
    required String text,
    Color? color,
    TextAlign? textAlign,
    String? semanticsLabel,
  }) {
    return DynamicTypographyWrapper(
      key: key,
      text: text,
      token: MD3TypographyToken.labelLarge,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Factory constructor for MD3 `bodyMedium` token
  factory DynamicTypographyWrapper.bodyMedium({
    Key? key,
    required String text,
    TextAlign? textAlign,
    String? semanticsLabel,
  }) {
    return DynamicTypographyWrapper(
      key: key,
      text: text,
      token: MD3TypographyToken.bodyMedium,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Factory constructor for MD3 `titleMedium` token
  factory DynamicTypographyWrapper.titleMedium({
    Key? key,
    required String text,
    TextAlign? textAlign,
    String? semanticsLabel,
  }) {
    return DynamicTypographyWrapper(
      key: key,
      text: text,
      token: MD3TypographyToken.titleMedium,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Factory constructor for MD3 `headlineSmall` token
  factory DynamicTypographyWrapper.headlineSmall({
    Key? key,
    required String text,
    TextAlign? textAlign,
    String? semanticsLabel,
  }) {
    return DynamicTypographyWrapper(
      key: key,
      text: text,
      token: MD3TypographyToken.headlineSmall,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Resolves the corresponding MD3 token style from the active [ThemeData].
  TextStyle _resolveTokenStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (token != null) {
      switch (token!) {
        case MD3TypographyToken.displayLarge:
          return textTheme.displayLarge ?? const TextStyle();
        case MD3TypographyToken.displayMedium:
          return textTheme.displayMedium ?? const TextStyle();
        case MD3TypographyToken.displaySmall:
          return textTheme.displaySmall ?? const TextStyle();
        case MD3TypographyToken.headlineLarge:
          return textTheme.headlineLarge ?? const TextStyle();
        case MD3TypographyToken.headlineMedium:
          return textTheme.headlineMedium ?? const TextStyle();
        case MD3TypographyToken.headlineSmall:
          return textTheme.headlineSmall ?? const TextStyle();
        case MD3TypographyToken.titleLarge:
          return textTheme.titleLarge ?? const TextStyle();
        case MD3TypographyToken.titleMedium:
          return textTheme.titleMedium ?? const TextStyle();
        case MD3TypographyToken.titleSmall:
          return textTheme.titleSmall ?? const TextStyle();
        case MD3TypographyToken.bodyLarge:
          return textTheme.bodyLarge ?? const TextStyle();
        case MD3TypographyToken.bodyMedium:
          return textTheme.bodyMedium ?? const TextStyle();
        case MD3TypographyToken.bodySmall:
          return textTheme.bodySmall ?? const TextStyle();
        case MD3TypographyToken.labelLarge:
          return textTheme.labelLarge ?? const TextStyle();
        case MD3TypographyToken.labelMedium:
          return textTheme.labelMedium ?? const TextStyle();
        case MD3TypographyToken.labelSmall:
          return textTheme.labelSmall ?? const TextStyle();
      }
    }

    return style ?? textTheme.bodyMedium ?? const TextStyle();
  }

  /// Purges all shadows from the provided [TextStyle] to maximize mobile GPU rendering.
  static TextStyle purgeShadows(TextStyle rawStyle) {
    return rawStyle.copyWith(
      shadows: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Resolve MD3 TextStyle token and purge all unmapped shadows
    final baseStyle = _resolveTokenStyle(context);
    final sanitizedStyle = purgeShadows(baseStyle);

    // 2. Wrap child with defensive clamping limits (0.8x to 1.2x)
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: minScaleLimit,
      maxScaleFactor: maxScaleLimit,
      child: Text(
        text,
        style: sanitizedStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
