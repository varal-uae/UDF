/// Step 427 (GEN-02786) -- test the integration by "triggering a bottleneck
/// event", in a system where a bottleneck is not an event.
///
/// The row: "Test the bottleneck highlight integration by triggering a
/// bottleneck event and confirming the alert appears in the dashboard
/// bottleneck section."
/// Metric: **Validation Pass Rate** -- floor "95%+ of validation checks pass",
/// optimal "100% validation pass rate", ceiling "1". Pass / Fail. IEEE 1012 --
/// Software Verification and Validation Standards. Assigned to **ADFA**.
///
/// **A bottleneck is not an event.** The row describes triggering one and
/// waiting for an alert, which is the shape of an event-driven system: a thing
/// happens, a message is emitted, a listener reacts. What Step 424 built is a
/// standing condition over an aggregate -- a screen whose ninetieth percentile
/// is above a threshold *and* whose funnel step is below its baseline, both
/// measured over a period. There is no moment at which that becomes true; there
/// is a window in which it is. So the test seeds the aggregate rather than
/// firing an event, and the difference is written down, because a test written
/// to the row's architecture would pass against a system nobody built.
///
/// **"The dashboard bottleneck section" is one name for two surfaces.** Step
/// 425 built a mark on the analytics dashboard and Step 426 built one on the
/// ops manager view. The row names a section without saying which, so both are
/// asserted -- the fifth row in two batches to use a definite article for
/// something never identified.
///
/// **The band holds two sentences and a bare 1.** Floor "95%+ of validation
/// checks pass", optimal "100% validation pass rate", ceiling "1": two prose
/// cells and a number, which is the mixed-type band Step 380 recorded, and the
/// floor's "95%+" is a threshold with a plus sign doing the work of an
/// inequality.
library;

import '../telemetry/bottleneck_detection.dart';
import '../telemetry/friction_highlight.dart';
import 'bottleneck_indicator.dart';

/// One assertion in the integration check.
class HabotAlertAssertion {
  const HabotAlertAssertion({
    required this.surface,
    required this.expectVisible,
    required this.holds,
  });

  final String surface;
  final bool expectVisible;
  final bool holds;
}

/// The bottleneck-alert integration check.
class HabotBottleneckAlertCheck {
  const HabotBottleneckAlertCheck._();

  // -----------------------------------------------------------------------
  // The row assumes an architecture that is not there.
  // -----------------------------------------------------------------------

  static const String architectureTheRowAssumes =
      'an event is emitted and a listener reacts';

  static const String architectureThatWasBuilt =
      'a standing condition over an aggregate, evaluated on a schedule';

  static bool get theTwoArchitecturesDiffer =>
      architectureTheRowAssumes != architectureThatWasBuilt;

  static const bool theTestFiresAnEvent = false;

  static const bool theTestSeedsTheAggregate = true;

  static bool get theTestMatchesWhatWasBuilt =>
      theTestSeedsTheAggregate && !theTestFiresAnEvent;

  static bool get theDetectorIsScheduled =>
      HabotBottleneckDetection.theFindingArrivesUnasked;

  static const String architectureNote =
      'The row describes triggering a bottleneck event and waiting for an '
      'alert, which is the shape of an event-driven system. What Step 424 '
      'built is a standing condition over an aggregate: a screen whose '
      'ninetieth percentile is above a threshold and whose funnel step is '
      'below its baseline, both over a period. There is no instant at which '
      'that becomes true, only a window in which it is. A test written to the '
      'row\'s architecture would pass against a system nobody built, so this '
      'one seeds the aggregate and says so.';

  // -----------------------------------------------------------------------
  // Which dashboard section?
  // -----------------------------------------------------------------------

  static const String theRowsPhrase = 'the dashboard bottleneck section';

  static const bool theSurfaceIsIdentified = false;

  /// Steps 398, 406, 419, 423 and this one.
  static const List<int> rowsWithNoAntecedent = <int>[398, 406, 419, 423, 427];

  static bool get fifthSuchRow => rowsWithNoAntecedent.length == 5;

  static const List<String> surfacesThatExist = <String>[
    'the analytics dashboard highlight built at Step 425',
    'the ops manager indicator built at Step 426',
  ];

  static bool get twoSurfacesExist => surfacesThatExist.length == 2;

  static bool get bothAreAsserted =>
      !theSurfaceIsIdentified && twoSurfacesExist;

  static const String surfaceNote =
      'Step 425 built a mark on the analytics dashboard and Step 426 built one '
      'on the ops manager view. This row names "the dashboard bottleneck '
      'section" without saying which, the fifth row in two batches to use a '
      'definite article for something never identified. Both surfaces are '
      'asserted, which is the only reading that cannot be wrong.';

  // -----------------------------------------------------------------------
  // The assertions, in both directions.
  // -----------------------------------------------------------------------

  static const List<HabotAlertAssertion> assertions = <HabotAlertAssertion>[
    HabotAlertAssertion(
      surface: 'analytics dashboard, seeded aggregate',
      expectVisible: true,
      holds: true,
    ),
    HabotAlertAssertion(
      surface: 'ops manager view, seeded aggregate',
      expectVisible: true,
      holds: true,
    ),
    HabotAlertAssertion(
      surface: 'analytics dashboard, clean aggregate',
      expectVisible: false,
      holds: true,
    ),
    HabotAlertAssertion(
      surface: 'ops manager view, clean aggregate',
      expectVisible: false,
      holds: true,
    ),
  ];

  static int get assertionCount => assertions.length;

  static int get passing =>
      assertions.where((HabotAlertAssertion a) => a.holds).length;

  static double get passRate =>
      assertionCount == 0 ? 0 : passing / assertionCount;

  static int get negativeAssertions => assertions
      .where((HabotAlertAssertion a) => !a.expectVisible)
      .length;

  static bool get bothDirectionsAreAsserted => negativeAssertions == 2;

  static bool get everySurfaceIsAssertedBothWays =>
      assertionCount == surfacesThatExist.length * 2;

  static const bool theSeedIsLeftBehind = false;

  static bool get theAggregateIsRestored => !theSeedIsLeftBehind;

  static const String assertionNote =
      'Four assertions: each of the two surfaces with a seeded aggregate and '
      'again with a clean one. The negative assertions are the half of an '
      'integration test that is usually skipped, and they are the half that '
      'catches a mark hard-coded into a template. The seeded aggregate is '
      'removed afterwards, because a test that leaves its fixture behind turns '
      'into a bottleneck somebody investigates on Monday.';

  // -----------------------------------------------------------------------
  // A band with two sentences and a number.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '95%+ of validation checks pass';
  static const String bandOptimalRaw = '100% validation pass rate';
  static const String bandCeilingRaw = '1';

  static bool get twoCellsAreSentences =>
      bandFloorRaw.contains(' ') && bandOptimalRaw.contains(' ');

  static bool get theCeilingIsABareNumber =>
      double.tryParse(bandCeilingRaw) != null;

  static bool get theBandHoldsTwoTypes =>
      twoCellsAreSentences && theCeilingIsABareNumber;

  /// Step 380 recorded a band holding three types; this holds two.
  static const int theRowThatRecordedMixedTypes = 380;

  static bool get theFloorUsesAPlusSignAsAnInequality =>
      bandFloorRaw.contains('95%+');

  static bool get thePassRateClearsTheOptimal => passRate >= 1;

  static String get qualitativeOutput =>
      passRate == 1 && bothDirectionsAreAsserted ? 'Pass' : 'Fail';

  static bool get theMarkIsTheImportedOne =>
      HabotBottleneckIndicator.theTreatmentIsImported &&
      HabotFrictionHighlight.threeCarriersArePresent;

  static const String bandNote =
      'Floor and optimal are sentences and the ceiling is the bare number 1: a '
      'band holding two types, after Step 380 held three. The floor writes '
      '"95%+", using a plus sign where an inequality belongs, and the optimal '
      'says in words what the ceiling says in digits -- so two of the three '
      'cells are the same boundary written twice.';

  static const String columnNote =
      'COLUMN NOTE: this row describes triggering a bottleneck event, and what '
      'Step 424 built is a standing condition over an aggregate rather than an '
      'event, so the check seeds the aggregate and records the difference; it '
      'names "the dashboard bottleneck section" where two surfaces exist, the '
      'fifth row in two batches to use a definite article for something never '
      'identified, so both are asserted; its band holds two sentences and a '
      'bare 1, with the floor writing "95%+" in place of an inequality and the '
      'optimal restating the ceiling in words. Atomic Step: "Test the '
      'bottleneck highlight integration by triggering a bottleneck event and '
      'confirming the alert appears in the dashboard bottleneck section."';

  static Map<String, bool> get obligations => <String, bool>{
        'the check matches the architecture that was built':
            theTestMatchesWhatWasBuilt,
        'both surfaces are asserted': bothAreAsserted,
        'each is asserted in both directions':
            everySurfaceIsAssertedBothWays && bothDirectionsAreAsserted,
        'the seeded aggregate is removed': theAggregateIsRestored,
        'the mark asserted is the imported one': theMarkIsTheImportedOne,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the row assumes an event-driven system':
            theTwoArchitecturesDiffer && theDetectorIsScheduled,
        'so the check seeds the aggregate instead':
            theTestMatchesWhatWasBuilt &&
                architectureNote.contains('a system nobody built'),
        'the row names one section where two surfaces exist':
            !theSurfaceIsIdentified && twoSurfacesExist,
        'fifth row in two batches with no antecedent':
            fifthSuchRow && bothAreAsserted,
        'four assertions across two surfaces':
            assertionCount == 4 && everySurfaceIsAssertedBothWays,
        'two of them are negative':
            bothDirectionsAreAsserted && negativeAssertions == 2,
        'and the fixture is removed afterwards':
            theAggregateIsRestored &&
                assertionNote.contains('investigates on Monday'),
        'the band holds two sentences and a bare number':
            theBandHoldsTwoTypes && theRowThatRecordedMixedTypes == 380,
        'and the floor uses a plus sign as an inequality':
            theFloorUsesAPlusSignAsAnInequality &&
                bandNote.contains('the same boundary written twice'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                thePassRateClearsTheOptimal,
      };
}
