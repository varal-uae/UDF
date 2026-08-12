/// AISS: IS02-CSIVW-005-AS01-A01 substep 2 -- "Lock message text strings to
/// display in high-contrast red parameters directly below affected input
/// containers."
///
/// Decision recorded (the step's "Decision to be Made Before Setup Step" asks
/// for "the precise text size parameters required for inline descriptive error
/// messages"): **bodySmall, 12sp on a 16sp line**, taken from the existing type
/// scale rather than invented. Rationale: it is the smallest role in the scale
/// that still clears WCAG at 12sp, it leaves the field label visually dominant,
/// and reusing a scale role means an error message can never drift out of the
/// type system. Gated by IS02-CSIVW-005-G2.
///
/// "High-contrast red" is `colorScheme.error` -- audited in TTMCS-004 at
/// 6.54:1 light / 7.72:1 dark against its container, comfortably past the
/// 4.5:1 floor. It is not a new colour.
///
/// The message is always accompanied by an icon and by real text, never colour
/// alone: IS12-CSIVW-011's standard says "never relying on color changes alone",
/// which is also WCAG 2.1 SC 1.4.1 (Use of Color).
library;

import 'package:flutter/material.dart';

import '../interaction/touch_standards.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

class InlineFieldError extends StatelessWidget {
  const InlineFieldError({required this.message, super.key});

  final String message;

  /// The recorded decision, as a testable constant.
  static const String textRole = 'bodySmall';
  static double get textSizeSp => HabotTypography.bodySmall.sizeSp;
  static double get lineHeightSp => HabotTypography.bodySmall.lineHeightSp;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        left: HabotSpacing.md,
        top: HabotSpacing.xxs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Not colour alone: an icon carries the same meaning.
          Icon(
            Icons.error_outline,
            size: TouchStandards.iconDense,
            color: scheme.error,
          ),
          const SizedBox(width: HabotSpacing.xxs),
          Flexible(
            child: Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: HabotTypography.bodySmall
                    .toTextStyle(HabotTypography.fontName)
                    .copyWith(color: scheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
