/// AISS: GEN-02060-A01 -- "Ensure text breathes and fits its container without
/// truncating unreadably on 320dp screens."
///
/// METRIC MISMATCH, RECORDED: the row's Metric Name is the generic "Step
/// Completion Rate (%)". The specific number is in the Setup Step: **320dp**,
/// which is also `HabotGrid.minSupportedWidth` from Step 6 and the narrowest
/// device in the Step 5 matrix. That is what is gated.
///
/// "Truncating unreadably" is the phrase worth unpacking, because it is not
/// the same as "truncating". A label that ellipsises after forty characters is
/// fine. A label that ellipsises after four is not -- the user is left with
/// "Sett..." and no way to find out. So the rule is a floor on how much of a
/// string must survive, not a ban on ellipsis:
///
///   * body text wraps rather than truncates,
///   * a truncated label must keep at least [minReadableChars] characters,
///   * nothing may shrink below [minReadableFontSp].
///
/// The guard runs at 320dp because that is where every one of these first
/// breaks.
library;

import 'package:flutter/material.dart';

import '../tokens/grid_tokens.dart';
import '../tokens/typography_tokens.dart';

/// The fitting rules.
class HabotTextFit {
  const HabotTextFit._();

  /// The width every rule is checked at.
  static const double auditWidthDp = HabotGrid.minSupportedWidth;

  /// A truncated string must keep at least this many characters before the
  /// ellipsis, or the truncation has destroyed the information.
  static const int minReadableChars = 12;

  /// Text may not be rendered smaller than this, whatever the container does.
  /// Equal to the smallest role in the type scale -- labelSmall at 11sp -- so
  /// "fits" can never be achieved by shrinking past what the type scale allows.
  static const double minReadableFontSp = 11;

  /// Roles that must wrap rather than truncate. Body copy is read; labels are
  /// scanned, and a scanned string can survive an ellipsis.
  static const Set<String> mustWrap = <String>{
    'bodyLarge',
    'bodyMedium',
    'bodySmall',
  };

  /// Approximate advance width of a character at [sizeSp], as a fraction of
  /// the font size. Roboto's average lowercase advance is close to 0.5em;
  /// 0.55 keeps the estimate conservative, so the audit errs toward flagging
  /// text rather than passing it.
  static const double averageCharWidthFactor = 0.55;

  static double charWidth(double sizeSp) => sizeSp * averageCharWidthFactor;

  /// How many characters fit on one line of [width] at [sizeSp].
  static int charsPerLine(double width, double sizeSp) =>
      (width / charWidth(sizeSp)).floor();

  /// Whether [text] at [token] fits [width] within [maxLines] without
  /// truncating below the readable floor.
  static HabotTextFitResult audit({
    required String text,
    required HabotTypeToken token,
    double width = auditWidthDp,
    int maxLines = 2,
  }) {
    if (token.sizeSp < minReadableFontSp) {
      return HabotTextFitResult(
        fits: false,
        reason: HabotTextFitFailure.belowMinimumFontSize,
        charsThatFit: 0,
      );
    }
    final int perLine = charsPerLine(width, token.sizeSp);
    final int capacity = perLine * maxLines;
    if (text.length <= capacity) {
      return HabotTextFitResult(
        fits: true,
        reason: null,
        charsThatFit: text.length,
      );
    }
    if (mustWrap.contains(token.name)) {
      // Body text is allowed as many lines as it needs; being over capacity at
      // two lines is not a failure, it is a taller paragraph.
      return HabotTextFitResult(
        fits: true,
        reason: null,
        charsThatFit: text.length,
      );
    }
    return HabotTextFitResult(
      fits: capacity >= minReadableChars,
      reason: capacity >= minReadableChars
          ? null
          : HabotTextFitFailure.truncatedBelowReadable,
      charsThatFit: capacity,
    );
  }
}

enum HabotTextFitFailure { belowMinimumFontSize, truncatedBelowReadable }

class HabotTextFitResult {
  const HabotTextFitResult({
    required this.fits,
    required this.reason,
    required this.charsThatFit,
  });

  final bool fits;
  final HabotTextFitFailure? reason;
  final int charsThatFit;
}

/// Text that obeys the rules by construction.
///
/// A caller picks a type role and a purpose; the widget decides whether to
/// wrap or truncate. That is the difference between a rule and a convention:
/// there is no `overflow:` parameter here to get wrong.
class HabotFittingText extends StatelessWidget {
  const HabotFittingText(
    this.data, {
    required this.token,
    this.maxLines,
    this.textAlign,
    super.key,
  });

  final String data;
  final HabotTypeToken token;

  /// Only consulted for roles that may truncate. Body roles wrap regardless.
  final int? maxLines;

  final TextAlign? textAlign;

  bool get wraps => HabotTextFit.mustWrap.contains(token.name);

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = _styleFor(context);
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: wraps ? null : (maxLines ?? 1),
      overflow: wraps ? TextOverflow.clip : TextOverflow.ellipsis,
      // The OS text-size setting still applies; what is fixed here is the
      // design system's own floor, not the user's preference.
      softWrap: true,
    );
  }

  TextStyle? _styleFor(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    switch (token.name) {
      case 'bodyLarge':
        return theme.bodyLarge;
      case 'bodyMedium':
        return theme.bodyMedium;
      case 'bodySmall':
        return theme.bodySmall;
      case 'titleMedium':
        return theme.titleMedium;
      case 'titleSmall':
        return theme.titleSmall;
      case 'labelLarge':
        return theme.labelLarge;
      case 'labelMedium':
        return theme.labelMedium;
      default:
        return theme.bodyMedium;
    }
  }
}
