/// AISS Step 184 -- GEN-01043
/// Setup Step (Action): "Define the payload structure for the health
///                       confirmation ping request and response messages."
/// Atomic Step: "Set structural touch target size tokens to a mandatory
///               minimum parameter of 48x48dp."
/// Metric: Touch Target Size -- Floor ">=44x44dp", Optimal "48x48dp",
///         Ceiling "<=56x56dp". Pass / Fail.
///
/// **COLUMN NOTE, RECORDED: the Setup Step names a health-ping payload and the
/// Atomic Step names touch target tokens.** They share no vocabulary. The
/// Atomic Step is the unit of work.
///
/// **THE MINIMUM IS ALREADY IN PLACE. THE CEILING IS THE NEW PART, AND IT IS
/// THE HALF THAT GETS LEFT OUT.** `HabotDensity.minTouchTarget` has been 48dp
/// since Step 3, and Step 108 audits components against it. Nothing in this
/// repository has ever checked the *upper* bound the row gives, and a bound
/// that is only enforced downwards is half a specification.
///
/// **A TOO-LARGE TARGET IS A REAL DEFECT, NOT A HARMLESS EXCESS.** Three
/// symptoms, in order of how often they bite:
///   1. **Mis-attributed taps.** A 72dp hit box around a 24dp icon fires when
///      the user taps 24dp away from anything visible. The user did not tap
///      that control and does not believe they did, which is the worst
///      category of bug to report.
///   2. **Stolen clearance.** Targets grow into the 8dp gap between them
///      (Step 185), so two oversized neighbours touch and the boundary between
///      them stops existing.
///   3. **No room left.** Four 64dp targets in a row on a 360dp screen leave
///      48dp for every margin and gutter combined.
///
/// **THE BAND APPLIES TO THE MINOR DIMENSION, NOT TO BOTH.** This is the
/// distinction that makes the ceiling usable at all. A full-width submit button
/// is 48dp tall and 328dp wide; bounding *both* axes at 56dp would fail every
/// primary action in the product. What a finger has to hit accurately is the
/// SHORT side — so the floor and the ceiling both constrain
/// [HabotTouchBand.minorOf], and the long side is deliberately unbounded.
library;

import 'package:flutter/widgets.dart';

import '../interaction/touch_standards.dart';
import 'spacing_tokens.dart';
import 'token_package.dart';

/// Where a measured target sits against the row's band.
enum HabotTouchVerdict {
  /// At or better than the optimal.
  optimal,

  /// At least the floor, below the optimal.
  withinFloor,

  /// Above the optimal, not past the ceiling.
  withinCeiling,

  /// Below the floor. A target a finger misses.
  tooSmall,

  /// Past the ceiling. A target that fires when nothing was aimed at.
  tooLarge,
}

/// One measured control.
class HabotTouchFinding {
  const HabotTouchFinding({
    required this.label,
    required this.size,
    required this.verdict,
  });

  final String label;
  final Size size;
  final HabotTouchVerdict verdict;

  bool get isFailure =>
      verdict == HabotTouchVerdict.tooSmall ||
      verdict == HabotTouchVerdict.tooLarge;

  @override
  String toString() {
    final double minor = HabotTouchBand.minorOf(size);
    switch (verdict) {
      case HabotTouchVerdict.tooSmall:
        return '$label: ${minor.toStringAsFixed(0)}dp on its short side, '
            'below the ${HabotTouchBand.floorDp.toStringAsFixed(0)}dp floor. '
            'A finger misses it.';
      case HabotTouchVerdict.tooLarge:
        return '$label: ${minor.toStringAsFixed(0)}dp on its short side, past '
            'the ${HabotTouchBand.ceilingDp.toStringAsFixed(0)}dp ceiling. It '
            'fires when the user taps '
            '${(minor - HabotTouchBand.optimalDp).toStringAsFixed(0)}dp away '
            'from anything visible.';
      case HabotTouchVerdict.optimal:
      case HabotTouchVerdict.withinFloor:
      case HabotTouchVerdict.withinCeiling:
        return '$label: ${minor.toStringAsFixed(0)}dp, ${verdict.name}.';
    }
  }
}

/// The row's band, enforced in both directions.
class HabotTouchBand {
  const HabotTouchBand._();

  /// WCAG 2.1 SC 2.5.5 at AAA is 44dp; the row uses it as the floor.
  static const double floorDp = 44;

  /// MD3's recommendation, and the token this project already declares.
  static double get optimalDp => HabotDensity.minTouchTarget;

  /// The new half. Above this a target is a mis-hit zone.
  static const double ceilingDp = 56;

  /// **The short side.** See the header: the band constrains the dimension a
  /// finger has to hit accurately, and the long side is unbounded.
  static double minorOf(Size s) => s.width < s.height ? s.width : s.height;

  static double majorOf(Size s) => s.width < s.height ? s.height : s.width;

  static HabotTouchVerdict verdictFor(Size s) {
    final double minor = minorOf(s);
    if (minor < floorDp) {
      return HabotTouchVerdict.tooSmall;
    }
    if (minor > ceilingDp) {
      return HabotTouchVerdict.tooLarge;
    }
    if (minor == optimalDp) {
      return HabotTouchVerdict.optimal;
    }
    return minor < optimalDp
        ? HabotTouchVerdict.withinFloor
        : HabotTouchVerdict.withinCeiling;
  }

  static bool isWithinBand(Size s) {
    final double minor = minorOf(s);
    return minor >= floorDp && minor <= ceilingDp;
  }

  static HabotTouchFinding measure(String label, Size size) =>
      HabotTouchFinding(label: label, size: size, verdict: verdictFor(size));

  static List<HabotTouchFinding> audit(Map<String, Size> controls) => controls
      .entries
      .map((MapEntry<String, Size> e) => measure(e.key, e.value))
      .toList();

  static List<HabotTouchFinding> violations(Map<String, Size> controls) =>
      audit(controls).where((HabotTouchFinding f) => f.isFailure).toList();

  /// The share of measured controls inside the band.
  static double complianceRate(Map<String, Size> controls) {
    if (controls.isEmpty) {
      return 1;
    }
    final List<HabotTouchFinding> all = audit(controls);
    return all.where((HabotTouchFinding f) => !f.isFailure).length / all.length;
  }

  /// The Step 3 sizing helper, checked against the row's band rather than
  /// against its own floor -- which is the whole point of adding a ceiling.
  ///
  /// A visual element is padded up to the target size; this asks whether that
  /// padding ever overshoots.
  static List<HabotTouchFinding> auditIconSizes() => <HabotTouchFinding>[
        for (final HabotIconSize size in HabotIconSize.values)
          measure(
            'icon.${size.name}',
            TouchStandards.targetFor(TouchStandards.iconSizeFor(size)),
          ),
      ];

  // ---- consistency with the token package ---------------------------------

  /// **A finding recorded here because this is the touch-token step.**
  ///
  /// `TouchStandards` declares metric values -- icon sizes, clearance,
  /// protective padding -- and the poka-yoke guard exempts it as a metric
  /// declaration site. It is not listed as a family in the Step 176 token
  /// package manifest, which means the manifest and the guard's exemption list
  /// disagree about what counts as a token file. Neither is wrong on its own;
  /// the disagreement is the thing.
  static const String declarationSiteInconsistency =
      'lib/design_system/interaction/touch_standards.dart is exempted by the '
      'poka-yoke guard as a metric declaration site but is not a declared '
      'family in the Step 176 token package manifest. The guard and the '
      'manifest disagree about what a token file is. Recorded rather than '
      'resolved by quietly adding it to one of them: the touch metrics may '
      'genuinely belong with the interaction code that uses them, and that is '
      'a decision rather than a tidy-up.';

  static bool get touchStandardsIsDeclaredFamily =>
      HabotTokenPackage.isDeclarationSite(
        'lib/design_system/interaction/touch_standards.dart',
      );

  // ---- the row's metric ---------------------------------------------------

  static bool get tokenSitsAtOptimal => optimalDp == 48;

  static String get qualitativeOutput =>
      tokenSitsAtOptimal ? 'Pass' : 'Fail';

  static const String ceilingIsTheNewPartNote =
      'The 48dp minimum has been in place since Step 3 and Step 108 audits '
      'against it. Nothing has ever checked the upper bound the row gives. A '
      'bound enforced only downwards is half a specification.';

  static const String tooLargeIsADefectNote =
      'A 72dp hit box around a 24dp icon fires when the user taps 24dp away '
      'from anything visible -- the user did not tap that control and does not '
      'believe they did, which is the worst category of bug to report. '
      'Oversized targets also grow into the 8dp clearance between them, so two '
      'neighbours touch and the boundary stops existing.';

  static const String minorAxisNote =
      'The band applies to the SHORT side. A full-width submit button is 48dp '
      'tall and 328dp wide; bounding both axes at 56dp would fail every '
      'primary action in the product. What a finger has to hit accurately is '
      'the minor dimension, so the long side is deliberately unbounded.';

  static const String columnNote =
      'The Setup Step on this row names a health-ping payload structure; the '
      'Atomic Step names touch target tokens. They share no vocabulary. The '
      'Atomic Step is the unit of work.';
}
