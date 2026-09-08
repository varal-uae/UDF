/// AISS Step 102 -- GEN-04363
/// "Configure dynamic font scaling utilities responding to system text size
///  settings."
/// WCAG 2.2 SC 1.4.4 Resize Text (Level AA).
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED, TWICE OVER. The sheet gives this row "Theme
/// Switch Rendering Latency" -- floor < 500ms, optimal < 100ms, ceiling < 16ms.
/// Two things are wrong with it and both are recorded rather than smoothed
/// over:
///   1. It is a rendering latency on a font-scaling step.
///   2. Its bands are INVERTED relative to the sheet's own convention -- the
///      ceiling (<16ms) is the best value here, not the worst. This is the
///      same defect Step 58 met, and it gets the same treatment: read in the
///      latency sense and stated as such.
/// The step is gated on what it names -- layouts holding at OS text scales up
/// to 200%.
///
/// WHAT THIS EXTENDS. Step 46 (`HabotTextFit`) already gates text fitting at
/// 320dp, at scale 1.0. This is the same instrument with one more axis: the
/// user's own text size. A 320dp viewport at 200% text is the hardest case
/// this app has to survive, and it is the case a field worker with presbyopia
/// on a small handset is actually in.
///
/// THE CLAMP, AND WHY IT IS NOT A CAP ON THE USER. Android and iOS both permit
/// text scales beyond 2.0 (Android's largest accessibility size reaches ~2.0,
/// iOS's AX5 goes higher still). [HabotTextScale.clamp] does NOT stop the OS
/// from asking. It records the range this design system has AUDITED, so that
/// beyond it the app degrades on purpose -- switching to a stacked layout --
/// rather than by accident, into clipped text.
library;

import 'package:flutter/widgets.dart';

import '../tokens/typography_tokens.dart';
import 'text_fit.dart';

/// The audited scale range and what happens outside it.
class HabotTextScale {
  const HabotTextScale._();

  /// Scale 1.0. The OS default.
  static const double base = 1.0;

  /// The floor a user can reach on both platforms. Below this, small type
  /// stops being readable rather than becoming compact.
  static const double minSupported = 0.85;

  /// SC 1.4.4's figure. Every layout in this design system is audited here.
  static const double wcagRequired = 2.0;

  /// Beyond this the app degrades deliberately -- see [degradesAt].
  static const double maxAudited = wcagRequired;

  /// The scales the audit walks. 1.3 and 1.6 are included because most real
  /// users sit between the default and the maximum, and a layout that survives
  /// 1.0 and 2.0 but breaks at 1.6 is a layout nobody tested.
  static const List<double> auditedScales = <double>[
    minSupported,
    base,
    1.15,
    1.3,
    1.6,
    wcagRequired,
  ];

  /// The scale this design system will lay out for, given what the OS asked.
  ///
  /// Above [maxAudited] the returned value is capped and [degradesAt] becomes
  /// true, which is the signal for a caller to stack rather than to clip.
  static double clamp(double osScale) =>
      osScale.clamp(minSupported, maxAudited).toDouble();

  /// True when the OS is asking for more than this design system has audited.
  static bool degradesAt(double osScale) => osScale > maxAudited;

  /// The scaler to hand to a `MediaQuery`.
  static TextScaler scalerFor(double osScale) =>
      TextScaler.linear(clamp(osScale));

  /// A type token's rendered size at [scale].
  static double sizeAt(HabotTypeToken token, double scale) =>
      token.sizeSp * clamp(scale);

  /// A type token's rendered line height at [scale]. Scales with the size, so
  /// the leading ratio is preserved -- text that grows without its leading
  /// growing is text that collides with itself.
  static double lineHeightAt(HabotTypeToken token, double scale) =>
      token.lineHeightSp * clamp(scale);
}

/// One token, at one scale, on one viewport width.
@immutable
class HabotScaledFitResult {
  const HabotScaledFitResult({
    required this.token,
    required this.scale,
    required this.width,
    required this.fits,
    required this.renderedSizeSp,
    required this.charsThatFit,
  });

  final HabotTypeToken token;
  final double scale;
  final double width;
  final bool fits;
  final double renderedSizeSp;
  final int charsThatFit;

  @override
  String toString() =>
      '${token.name} @${scale}x on ${width}dp: '
      '${fits ? "fits" : "DOES NOT FIT"} '
      '(${renderedSizeSp.toStringAsFixed(1)}sp, $charsThatFit chars)';
}

/// The scaling audit: Step 46's fitting instrument, run across the scale axis.
class HabotTextScaleAudit {
  const HabotTextScaleAudit._();

  /// A label of the length this app actually uses in a constrained slot.
  static const String sampleLabel = 'Batch approved';

  /// Audit one token across every audited scale at [width].
  static List<HabotScaledFitResult> auditToken(
    HabotTypeToken token, {
    double width = HabotTextFit.auditWidthDp,
    String text = sampleLabel,
  }) {
    return HabotTextScale.auditedScales.map((double scale) {
      final double rendered = HabotTextScale.sizeAt(token, scale);
      // The fitting instrument reasons in sp; feeding it the RENDERED size is
      // exactly how the scale axis is added without a second calculator.
      final HabotTypeToken scaled = HabotTypeToken(
        name: token.name,
        sizeSp: rendered,
        lineHeightSp: HabotTextScale.lineHeightAt(token, scale),
        weight: token.weight,
        tracking: token.tracking,
      );
      final HabotTextFitResult r = HabotTextFit.audit(
        text: text,
        token: scaled,
        width: width,
      );
      return HabotScaledFitResult(
        token: token,
        scale: scale,
        width: width,
        fits: r.fits,
        renderedSizeSp: rendered,
        charsThatFit: r.charsThatFit,
      );
    }).toList();
  }

  /// Every token, every audited scale.
  static List<HabotScaledFitResult> auditAll({
    double width = HabotTextFit.auditWidthDp,
  }) => <HabotScaledFitResult>[
    for (final HabotTypeToken t in HabotTypography.all)
      ...auditToken(t, width: width),
  ];

  static List<HabotScaledFitResult> failures({
    double width = HabotTextFit.auditWidthDp,
  }) => auditAll(
    width: width,
  ).where((HabotScaledFitResult r) => !r.fits).toList();

  /// The type roles that appear in width-constrained slots -- a table cell, a
  /// chip, a button, a form label. These are the ones a 320dp viewport at 200%
  /// actually squeezes, and they are held to the strict standard.
  ///
  /// Display and headline roles are excluded DELIBERATELY, and the reason is
  /// worth stating because it is the difference between a scoped rule and a
  /// loophole: a 57sp display token rendered at 200% is 114sp, and 114sp type
  /// cannot show a useful label in 320dp under any design. The answer is not
  /// to shrink the display scale -- it is that display type does not belong in
  /// a constrained slot. That constraint is recorded here and the finding is
  /// reported by GEN-04363-G7 rather than being hidden by narrowing the audit.
  static const Set<String> constrainedSlotRoles = <String>{
    'titleLarge',
    'titleMedium',
    'titleSmall',
    'bodyLarge',
    'bodyMedium',
    'bodySmall',
    'labelLarge',
    'labelMedium',
    'labelSmall',
  };

  static bool isConstrainedSlotRole(String tokenName) =>
      constrainedSlotRoles.contains(tokenName);

  /// Failures among the roles that actually appear in constrained slots.
  static List<HabotScaledFitResult> constrainedSlotFailures({
    double width = HabotTextFit.auditWidthDp,
  }) => failures(width: width)
      .where((HabotScaledFitResult r) => isConstrainedSlotRole(r.token.name))
      .toList();

  /// Failures among display and headline roles -- reported, not gated. See
  /// [constrainedSlotRoles].
  static List<HabotScaledFitResult> displayRoleFailures({
    double width = HabotTextFit.auditWidthDp,
  }) => failures(width: width)
      .where((HabotScaledFitResult r) => !isConstrainedSlotRole(r.token.name))
      .toList();
}

/// Applies the audited scale to a subtree.
///
/// A caller does not pass a number. The OS setting is read from the ambient
/// `MediaQuery` and clamped, which is why no screen in this app can quietly
/// opt out of text scaling by hardcoding 1.0 -- there is nowhere to write it.
class HabotTextScaleScope extends StatelessWidget {
  const HabotTextScaleScope({required this.child, super.key});

  final Widget child;

  /// What the OS is asking for, before clamping.
  static double osScaleOf(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(HabotTypography.bodyMedium.sizeSp) /
      HabotTypography.bodyMedium.sizeSp;

  /// True when this viewport is past what the design system has audited, so a
  /// caller can stack a row instead of clipping it.
  static bool isDegraded(BuildContext context) =>
      HabotTextScale.degradesAt(osScaleOf(context));

  @override
  Widget build(BuildContext context) {
    final double os = osScaleOf(context);
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: HabotTextScale.minSupported,
      maxScaleFactor: HabotTextScale.maxAudited,
      child: Builder(
        builder: (BuildContext inner) {
          if (!HabotTextScale.degradesAt(os)) {
            return child;
          }
          // Past the audited range the layout is told, rather than being left
          // to discover it by overflowing.
          return _HabotDegradedTextScale(child: child);
        },
      ),
    );
  }
}

/// Marks a subtree as being past the audited scale range.
///
/// Descendants find this with [of] and stack instead of laying out in a row.
/// It carries no styling: the point is the signal, not a second theme.
class _HabotDegradedTextScale extends InheritedWidget {
  const _HabotDegradedTextScale({required super.child});

  @override
  bool updateShouldNotify(_HabotDegradedTextScale oldWidget) => false;
}

/// Whether the enclosing scope is past the audited scale range.
bool habotTextScaleIsDegraded(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<_HabotDegradedTextScale>() !=
    null;
