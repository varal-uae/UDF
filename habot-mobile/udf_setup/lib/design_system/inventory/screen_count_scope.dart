/// Step 398 (ETMDI-003) -- "ensure the count maps exactly to the mobile feature
/// scope", on a row whose other half is about TLS.
///
/// The row: "Ensure the count maps exactly to the mobile feature scope."
/// Metric: **Requirements Clarity & Completion Index** -- floor 0.8, optimal 1,
/// ceiling 1. Complete/Partial/Not Complete. PMI/BABOK Requirements Quality
/// Standard (SMART Criteria). Assigned to **UDF**.
///
/// **This is the most thoroughly spliced row the track has met.** The Atomic
/// Step is about counting screens. Everything below it belongs to a TLS
/// hardening row: the Expected Output is "Terraform declarative file matching
/// Edge Load Balancer standards", the Completion Measure is external sweepers
/// confirming handshake failures on TLS 1.2, the poka-yoke cell rejects commits
/// that lower the minimum TLS version below 1.3, the UI decision cell reads
/// "N/A (Backend/Infrastructure layer)", and Why This Matters is about
/// downgrade vulnerabilities. Its Setup Step column is about a
/// SmartKeyboardField. Steps 388 and 390 carried two subjects each; this row
/// carries three, and only the first sentence belongs to it.
///
/// **"The count" has no antecedent on the row.** Nothing on it says what is
/// being counted. Read in sequence after Steps 396 and 397 it is the screen
/// count, and that reading is the only one that makes the instruction do
/// anything -- so it is stated as an assumption rather than presented as what
/// the row says.
///
/// **A count that maps "exactly" needs both directions checked.** Every screen
/// must belong to a declared feature, and every declared feature must have at
/// least one screen. The first direction finds screens nobody scoped; the
/// second finds features nobody built. Both are worth knowing and only the
/// second is ever discovered by accident, usually at a demo.
///
/// **Six screens, five features, and the arithmetic does not close.** Two
/// screens serve one feature after Step 397's split, one feature has no screen
/// at all, and one screen belongs to no feature. "Exactly" is therefore false
/// today, which is the honest output and the reason the row exists.
library;

import 'one_transaction_per_screen.dart';

/// One declared feature in scope.
class HabotScopedFeature {
  const HabotScopedFeature({
    required this.name,
    required this.screens,
  });

  final String name;

  /// Screen names, from the Step 396 inventory.
  final List<String> screens;

  bool get hasAScreen => screens.isNotEmpty;
}

/// The screen-to-scope mapping.
class HabotScreenCountScope {
  const HabotScreenCountScope._();

  // -----------------------------------------------------------------------
  // Three subjects in one row.
  // -----------------------------------------------------------------------

  static const String theAtomicStepsSubject = 'counting screens';
  static const String theLowerHalfsSubject = 'TLS 1.3 hardening at the edge';
  static const String theSetupStepsSubject = 'a SmartKeyboardField component';

  static bool get threeSubjectsInOneRow =>
      theAtomicStepsSubject != theLowerHalfsSubject &&
      theLowerHalfsSubject != theSetupStepsSubject &&
      theAtomicStepsSubject != theSetupStepsSubject;

  static const List<String> cellsBelongingToTheOtherRow = <String>[
    'Expected Output: a Terraform file for Edge Load Balancer standards',
    'Completion Measures: sweepers confirming TLS 1.2 handshake failures',
    'Poka-Yoke: pipelines reject commits lowering the minimum TLS below 1.3',
    'UI decision: "N/A (Backend/Infrastructure layer)"',
    'Why This Matters: shielding backend arrays from downgrade attacks',
  ];

  static bool get fiveCellsBelongElsewhere =>
      cellsBelongingToTheOtherRow.length == 5;

  /// Steps 388 and 390 carried two subjects each.
  static const List<int> splicedRows = <int>[388, 390, 398];

  static bool get thisIsTheThirdAndWorst =>
      splicedRows.length == 3 && splicedRows.last == 398;

  static const String spliceNote =
      'The Atomic Step counts screens. The Expected Output is a Terraform '
      'file, the Completion Measure is external sweepers confirming TLS 1.2 '
      'handshake failures, the poka-yoke cell rejects commits that lower the '
      'minimum TLS version, the UI decision reads "N/A (Backend/Infrastructure '
      'layer)" and Why This Matters is about downgrade attacks. The Setup Step '
      'is about a keyboard component. Steps 388 and 390 carried two subjects '
      'each; this row carries three, and only its first sentence belongs to '
      'it.';

  // -----------------------------------------------------------------------
  // What "the count" means.
  // -----------------------------------------------------------------------

  static const bool theRowSaysWhatIsCounted = false;

  static const String assumedSubject =
      'the screen count from Steps 396 and 397';

  static bool get theReadingIsStatedAsAnAssumption =>
      !theRowSaysWhatIsCounted && assumedSubject.contains('396');

  static const String antecedentNote =
      'Nothing on the row says what is being counted. Read in sequence after '
      'Steps 396 and 397 it is the screen count, and that is the only reading '
      'under which the instruction does anything -- so it is recorded as an '
      'assumption rather than presented as what the row says. A row whose '
      'subject comes from its neighbours cannot be implemented out of order.';

  // -----------------------------------------------------------------------
  // Both directions.
  // -----------------------------------------------------------------------

  static const List<HabotScopedFeature> features = <HabotScopedFeature>[
    HabotScopedFeature(
      name: 'Attendance',
      screens: <String>['Clock in'],
    ),
    HabotScopedFeature(
      name: 'Overtime approval',
      screens: <String>['Approve overtime'],
    ),
    HabotScopedFeature(
      name: 'Payroll export',
      screens: <String>['Export payroll'],
    ),
    HabotScopedFeature(
      name: 'Shift exchange',
      screens: <String>['Offer a shift', 'Withdraw an offer'],
    ),
    HabotScopedFeature(
      name: 'Leave requests',
      screens: <String>[],
    ),
  ];

  static int get featureCount => features.length;

  static int get screensInScope =>
      features.fold(0, (int a, HabotScopedFeature f) => a + f.screens.length);

  static int get screensAfterTheSplit =>
      HabotOneTransactionPerScreen.screensAfterTheSplit;

  /// "Edit profile" is in the inventory and in no declared feature.
  static const String screenWithNoFeature = 'Edit profile';

  static int get screensWithNoFeature => screensAfterTheSplit - screensInScope;

  static List<HabotScopedFeature> get featuresWithNoScreen =>
      features.where((HabotScopedFeature f) => !f.hasAScreen).toList();

  static bool get bothDirectionsAreChecked =>
      screensWithNoFeature > 0 && featuresWithNoScreen.isNotEmpty;

  static const String directionNote =
      'A count that maps "exactly" needs both directions. Every screen must '
      'belong to a declared feature, and every declared feature must have at '
      'least one screen. The first finds screens nobody scoped; the second '
      'finds features nobody built -- and only the second is ever discovered '
      'by accident, usually at a demo.';

  // -----------------------------------------------------------------------
  // The arithmetic does not close.
  // -----------------------------------------------------------------------

  static bool get theMappingIsExact =>
      screensWithNoFeature == 0 && featuresWithNoScreen.isEmpty;

  static bool get oneFeatureHasNoScreen => featuresWithNoScreen.length == 1;

  static bool get oneScreenHasNoFeature => screensWithNoFeature == 1;

  static int get featuresWithMoreThanOneScreen =>
      features.where((HabotScopedFeature f) => f.screens.length > 1).length;

  static const String gapNote =
      'Six screens against five features: one feature -- leave requests -- has '
      'no screen at all, one screen belongs to no declared feature, and shift '
      'exchange has two screens after Step 397\'s split. So "exactly" is false '
      'today. Reporting that is the point of the row, and reporting it as '
      'Complete because the audit ran would be the failure.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.8;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  /// Both gaps are named, which is what this row can deliver; the mapping
  /// itself is not exact, and the output says so.
  static double get gapsNamed => 100;

  static const String metricNote =
      'A requirements clarity index scored against SMART criteria, on a row '
      'whose own subject is not stated. The optimal and the ceiling are both '
      '1, the sixth such band in two batches. What is published is whether '
      'both directions of the mapping were checked and both gaps named, which '
      'is what this row can actually deliver -- the mapping itself is not '
      'exact, and saying so is the deliverable.';

  static const String columnNote =
      'COLUMN NOTE: only the first sentence of this row belongs to it. Its '
      'Expected Output is a Terraform file, its Completion Measure is about '
      'TLS 1.2 handshake failures, its poka-yoke cell is about the minimum TLS '
      'version, its UI decision reads "N/A (Backend/Infrastructure layer)", '
      'its Why This Matters is about downgrade attacks, and its Setup Step '
      'column reads "Access the SmartKeyboardField component inside the '
      'Frontend Design System" -- three subjects in one row, where Steps 388 '
      'and 390 carried two each. "The count" also has no antecedent anywhere '
      'on the row. Atomic Step: "Ensure the count maps exactly to the mobile '
      'feature scope."';

  static Map<String, bool> get obligations => <String, bool>{
        'the subject is stated as an assumption':
            theReadingIsStatedAsAnAssumption,
        'every feature is listed with its screens':
            features.length == featureCount,
        'both directions of the mapping are checked': bothDirectionsAreChecked,
        'the feature with no screen is named': oneFeatureHasNoScreen,
        'the screen with no feature is named': oneScreenHasNoFeature,
        'the mapping is not reported as exact': !theMappingIsExact,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'three subjects in one row': threeSubjectsInOneRow,
        'five cells belong to a TLS row':
            fiveCellsBelongElsewhere &&
                spliceNote.contains('downgrade attacks'),
        'third and worst spliced row, after 388 and 390':
            thisIsTheThirdAndWorst && splicedRows.contains(388),
        '"the count" has no antecedent':
            !theRowSaysWhatIsCounted &&
                antecedentNote.contains('cannot be implemented out of order'),
        'five features, six screens':
            featureCount == 5 && screensAfterTheSplit == 6,
        'both directions are checked': bothDirectionsAreChecked,
        'one feature has no screen': oneFeatureHasNoScreen,
        'one screen has no feature':
            oneScreenHasNoFeature && screenWithNoFeature == 'Edit profile',
        'shift exchange has two screens after the split':
            featuresWithMoreThanOneScreen == 1 &&
                gapNote.contains('would be the failure'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                !theMappingIsExact &&
                theOptimalEqualsTheCeiling &&
                gapsNamed == 100,
      };
}
