/// AISS: TTMCS-004-A01 -- "Map semantic tokens clearly to avoid mixing up
/// distinct component background definitions."
///
/// Design tokens that have no native `ThemeData` slot (the elevation ladder,
/// grid metrics, density band, page-frame gradient) travel with the theme as a
/// typed [ThemeExtension] so a widget reads them through the normal
/// `Theme.of(context)` path and they lerp correctly on theme change.
library;

import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/elevation_tokens.dart';

@immutable
class HabotTokens extends ThemeExtension<HabotTokens> {
  const HabotTokens({
    required this.brightness,
    required this.surfaceLadder,
    required this.pageFrameStart,
    required this.pageFrameEnd,
  });

  final Brightness brightness;

  /// Elevation level -> the surface colour a component at that level paints.
  final Map<HabotElevationLevel, Color> surfaceLadder;

  /// TTMCS-001 page-frame gradient stops.
  final Color pageFrameStart;
  final Color pageFrameEnd;

  bool get isDark => brightness == Brightness.dark;

  Color surfaceAt(HabotElevationLevel level) => surfaceLadder[level]!;

  static HabotTokens forBrightness(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return HabotTokens(
      brightness: brightness,
      surfaceLadder: isDark
          ? HabotElevation.darkSurfaceLadder
          : HabotElevation.lightSurfaceLadder,
      // In dark mode the frame is flat -- a light gradient there would defeat
      // the OLED power saving TTMCS-005 is chasing.
      pageFrameStart: isDark
          ? HabotColors.dark.surface
          : HabotColors.pageFrameLightStart,
      pageFrameEnd: isDark
          ? HabotColors.dark.surface
          : HabotColors.pageFrameLightEnd,
    );
  }

  /// Convenience accessor. Throws a readable error rather than a null deref if
  /// a widget is built outside a Habot theme.
  static HabotTokens of(BuildContext context) {
    final HabotTokens? tokens = Theme.of(context).extension<HabotTokens>();
    if (tokens == null) {
      throw FlutterError(
        'HabotTokens not found in the ambient Theme.\n'
        'Wrap the app in HabotApp, or build ThemeData with '
        'HabotTheme.light() / HabotTheme.dark().',
      );
    }
    return tokens;
  }

  @override
  HabotTokens copyWith({
    Brightness? brightness,
    Map<HabotElevationLevel, Color>? surfaceLadder,
    Color? pageFrameStart,
    Color? pageFrameEnd,
  }) {
    return HabotTokens(
      brightness: brightness ?? this.brightness,
      surfaceLadder: surfaceLadder ?? this.surfaceLadder,
      pageFrameStart: pageFrameStart ?? this.pageFrameStart,
      pageFrameEnd: pageFrameEnd ?? this.pageFrameEnd,
    );
  }

  @override
  HabotTokens lerp(covariant HabotTokens? other, double t) {
    if (other == null) {
      return this;
    }
    final Map<HabotElevationLevel, Color> ladder = <HabotElevationLevel, Color>{
      for (final HabotElevationLevel level in HabotElevationLevel.values)
        level:
            Color.lerp(surfaceLadder[level], other.surfaceLadder[level], t) ??
            surfaceLadder[level]!,
    };
    return HabotTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      surfaceLadder: ladder,
      pageFrameStart:
          Color.lerp(pageFrameStart, other.pageFrameStart, t) ?? pageFrameStart,
      pageFrameEnd:
          Color.lerp(pageFrameEnd, other.pageFrameEnd, t) ?? pageFrameEnd,
    );
  }
}
