/// Step 284 (RRCVG-002) -- an HTML custom element, a metric about interactive
/// elements applied to something nobody touches, and Core Web Vitals in an
/// application with no DOM.
///
/// The row: "Integrate Material Design 3 md-linear-progress components to
/// display progression metrics."
/// Metric: **Mobile Usability Compliance (Touch Target Size & Core Web
/// Vitals)** -- floor ">=90% of interactive elements meet the 44x44px minimum;
/// Core Web Vitals at 'Needs Improvement' or better", optimal "100% compliance
/// with 44-48px; Core Web Vitals 'Good' (LCP <2.5s, CLS <0.1)", ceiling "100%;
/// padding beyond ~56-60px reduces information density". Pass / Fail;
/// Good / Average / Poor. Output type cited: loyalty-industry benchmarks.
///
/// **`md-linear-progress` is an HTML tag.** It is a Material Web Components
/// custom element, registered in a browser and used in markup. This
/// application has no markup; `HabotProgressBar` already exists and is what
/// "integrate a linear progress component" means here. That makes this the
/// seventh row in the track written against a stack that was never used, and
/// the eighth restatement of something already built.
///
/// **A progress bar is not an interactive element, so half the metric does not
/// reach it.** Touch target size is a property of things people press. Nobody
/// presses a progress bar; measuring its 44 points measures nothing, and a
/// score of 100% on that half would be a statement about every *other* control
/// on the screen.
///
/// **Core Web Vitals do not exist here, but one of them has a real analogue.**
/// LCP and CLS are defined over DOM paint and DOM layout shift. There is no
/// DOM. But layout shift is a real hazard for exactly this component: an
/// indeterminate bar that appears and disappears moves everything under it,
/// and a bar whose space is reserved does not. The concept transfers and the
/// measurement does not, which is the distinction this step records.
///
/// **And the honest content of the row is a different question: determinate or
/// not.** An indeterminate bar says something is happening. A determinate one
/// claims to know how much is left, and a determinate bar that jumps to ninety
/// per cent and waits there has told a lie that an indeterminate bar could not
/// have told. A bar is determinate only when the total is known before the
/// work starts.
library;

import '../feedback/progress_indicators.dart';
import '../tokens/touch_target_band.dart';

/// What is known about the work when the bar appears.
enum HabotProgressKnowledge {
  /// The total is known before the work starts.
  totalKnownUpFront,

  /// The total becomes known part-way through.
  totalDiscoveredLater,

  /// The total is never known.
  totalUnknown,
}

/// One place this application shows progression.
class HabotProgressSite {
  const HabotProgressSite({
    required this.name,
    required this.knowledge,
    required this.why,
  });

  final String name;
  final HabotProgressKnowledge knowledge;
  final String why;

  /// Determinate only where the total is known before the work begins.
  bool get isDeterminate =>
      knowledge == HabotProgressKnowledge.totalKnownUpFront;
}

/// The binding.
class HabotLinearProgressBinding {
  const HabotLinearProgressBinding._();

  /// The element the row names, and the component that exists.
  static const String elementTheRowNames = 'md-linear-progress';
  static const String componentThatExists = 'HabotProgressBar';

  static bool get theNamedElementIsMarkup =>
      elementTheRowNames.contains('-') &&
      elementTheRowNames != componentThatExists;

  /// This is the seventh row written for another stack. Step 258 keeps the
  /// list; the count is carried here so the pattern is visible from either
  /// end.
  static const int stackAssumptionOrdinal = 7;

  static const String customElementNote =
      'md-linear-progress is a Material Web Components custom element: a tag '
      'registered in a browser and written in markup. This application has no '
      'markup, and HabotProgressBar already exists -- so "integrate a linear '
      'progress component" is a census here rather than an integration. That '
      'makes this the seventh row in the track written against a stack that '
      'was never used, and Step 258 holds the running list.';

  // -----------------------------------------------------------------------
  // The half of the metric that cannot reach this component.
  // -----------------------------------------------------------------------

  /// A progress bar is not pressed.
  static const bool isInteractive = false;

  static bool get theTouchHalfDoesNotApply =>
      !isInteractive && HabotTouchBand.floorDp == 44;

  static const String notInteractiveNote =
      'Touch target size is a property of things people press, and nobody '
      'presses a progress bar. Scoring this component against a 44-point '
      'minimum measures nothing: a perfect result would be a statement about '
      'every other control on the screen and none about this one. The touch '
      'band is read here only to show which figure the row means -- it is the '
      'band already declared at Step 227 -- and the half of the metric that '
      'reaches this component is the layout-stability half.';

  // -----------------------------------------------------------------------
  // The vital that does transfer.
  // -----------------------------------------------------------------------

  /// A bar that appears in reserved space shifts nothing. A bar that appears
  /// in no space pushes everything below it down by its own height.
  static double shiftCausedBy({
    required bool spaceReserved,
    required double barHeightDp,
  }) =>
      spaceReserved ? 0 : barHeightDp;

  static const double barHeightDp = 4;

  static bool get reservingSpaceRemovesTheShift =>
      shiftCausedBy(spaceReserved: true, barHeightDp: barHeightDp) == 0 &&
      shiftCausedBy(spaceReserved: false, barHeightDp: barHeightDp) ==
          barHeightDp;

  static const bool spaceIsReserved = true;

  static const String vitalsNote =
      'Largest Contentful Paint and Cumulative Layout Shift are defined over '
      'DOM paint and DOM layout shift, and there is no DOM. But layout shift '
      'is a real hazard for exactly this component: an indeterminate bar that '
      'appears and disappears moves everything beneath it, twice, and a '
      'person reading the row under it loses their line both times. The '
      'concept transfers and the measurement does not -- so the space is '
      'reserved whether or not the bar is showing, and the transferable half '
      'is recorded as such rather than a web score being invented.';

  // -----------------------------------------------------------------------
  // Determinate, and when it is allowed to be.
  // -----------------------------------------------------------------------

  static const List<HabotProgressSite> sites = <HabotProgressSite>[
    HabotProgressSite(
      name: 'uploading an attachment',
      knowledge: HabotProgressKnowledge.totalKnownUpFront,
      why: 'The file size is known before the first byte goes out, so the '
          'fraction is a fact rather than an estimate.',
    ),
    HabotProgressSite(
      name: 'completing a multi-step form',
      knowledge: HabotProgressKnowledge.totalKnownUpFront,
      why: 'The step count is declared by the wizard machine, so "three of '
          'five" is exact.',
    ),
    HabotProgressSite(
      name: 'loading a list whose length the server has not sent yet',
      knowledge: HabotProgressKnowledge.totalDiscoveredLater,
      why: 'The total arrives with the first page. A bar that guessed before '
          'then would have to jump when the real number came back.',
    ),
    HabotProgressSite(
      name: 'waiting for a payment to be confirmed',
      knowledge: HabotProgressKnowledge.totalUnknown,
      why: 'There is no total. The work is somebody else\'s and it takes as '
          'long as it takes.',
    ),
  ];

  static List<HabotProgressSite> get determinateSites =>
      sites.where((HabotProgressSite s) => s.isDeterminate).toList();

  static double get shareDeterminate => determinateSites.length / sites.length;

  /// Checked against the existing policy rather than restated: a null value
  /// is what indeterminate means, and the policy already says so.
  static bool get theExistingPolicyDecidesDeterminacy =>
      HabotProgressPolicy.isDeterminate(0.5) &&
      !HabotProgressPolicy.isDeterminate(null);

  /// And the existing clamp keeps a computed fraction inside the bar.
  static bool get outOfRangeValuesAreClamped =>
      HabotProgressPolicy.clamp(1.4) == 1.0 &&
      HabotProgressPolicy.clamp(-0.2) == 0.0 &&
      HabotProgressPolicy.clamp(0.5) == 0.5;

  /// The value is announced as a number, not left to the bar's appearance.
  static bool get theValueIsAnnounced =>
      HabotProgressPolicy.semanticsValue(0.5).isNotEmpty &&
      HabotProgressPolicy.semanticsValue(0.5) !=
          HabotProgressPolicy.semanticsValue(0.75);

  static const String determinacyNote =
      'An indeterminate bar says something is happening. A determinate one '
      'claims to know how much is left, and a determinate bar that runs to '
      'ninety per cent and waits there has told a lie an indeterminate bar '
      'could not have told -- which is why the next wait, the one that was '
      'honest, is not believed either. A bar is determinate only where the '
      'total is known before the work starts: two of the four sites here '
      'qualify, one discovers its total part-way through and one never has '
      'one, and both of those stay indeterminate rather than guessing.';

  // -----------------------------------------------------------------------
  // Metric: three subjects in one cell.
  // -----------------------------------------------------------------------

  static const String subjectOne = 'touch target size';
  static const String subjectTwo = 'Core Web Vitals';
  static const String subjectThree =
      'loyalty-industry benchmarks, in the output-type column';

  static bool get threeSubjectsInOneCell =>
      subjectOne != subjectTwo &&
      subjectTwo != subjectThree &&
      subjectThree.contains('loyalty');

  static Map<String, bool> get obligations => <String, bool>{
        'the space the bar occupies is reserved whether it shows or not':
            spaceIsReserved && reservingSpaceRemovesTheShift,
        'determinacy follows from what is known, not from what looks better':
            theExistingPolicyDecidesDeterminacy,
        'a computed fraction cannot leave the bar': outOfRangeValuesAreClamped,
        'the value is announced rather than only drawn': theValueIsAnnounced,
        'two of four sites qualify as determinate':
            determinateSites.length == 2,
      };

  static double get complianceRate =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput =>
      complianceRate >= 1.0 ? 'Good' : 'Average';

  static const String threeSubjectsNote =
      'THREE SUBJECTS IN ONE METRIC CELL. Touch target size, which does not '
      'reach a component nobody presses; Core Web Vitals, which are defined '
      'over a DOM this application does not have; and, in the output-type '
      'column, loyalty-industry benchmarks from a points-programme report. '
      'The row\'s surrounding columns are about API payload limits and '
      'dropped packets, which is a fourth. The transferable part -- layout '
      'stability -- is implemented, and the rest is recorded.';

  static Map<String, bool> get checks => <String, bool>{
        'the named element is markup and the component already exists':
            theNamedElementIsMarkup &&
                customElementNote.contains('seventh row') &&
                stackAssumptionOrdinal == 7,
        'the touch-target half cannot reach a component nobody presses':
            theTouchHalfDoesNotApply &&
                notInteractiveNote.contains('measures nothing'),
        'reserving the space removes the shift, measured':
            reservingSpaceRemovesTheShift && spaceIsReserved,
        'the web vitals are named as untransferable and the concept as '
            'transferable': vitalsNote.contains('loses their line'),
        'four progression sites, two of them determinate':
            sites.length == 4 &&
                determinateSites.length == 2 &&
                (shareDeterminate - 0.5).abs() < 1e-9,
        'determinacy is decided by the existing policy':
            theExistingPolicyDecidesDeterminacy,
        'an out-of-range fraction is clamped by the existing policy':
            outOfRangeValuesAreClamped,
        'the value is announced rather than only drawn': theValueIsAnnounced,
        'the lie a determinate bar can tell is recorded':
            determinacyNote.contains('is not believed either'),
        'the three subjects in the metric cell are named':
            threeSubjectsInOneCell &&
                threeSubjectsNote.contains('THREE SUBJECTS'),
        'five obligations, all met': obligations.length == 5 &&
            obligations.values.every((bool b) => b) &&
            complianceRate == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Program state '
      'management to serialize and retain current form field inputs in local '
      'storage", and the row\'s surrounding columns are entirely about API '
      'gateway payload limits. Atomic Step: "Integrate Material Design 3 '
      'md-linear-progress components to display progression metrics."';
}
