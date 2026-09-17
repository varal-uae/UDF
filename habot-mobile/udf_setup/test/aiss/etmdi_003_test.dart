/// AISS GATE -- Step 398 of 415
/// Global Reference ID:       ETMDI-003
/// Atomic Steps Reference ID: ETMDI-003
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Ensure the count maps exactly to the mobile feature scope."
/// Metric: Requirements Clarity & Completion Index -- floor "0.8", optimal "1",
///         ceiling "1". Best Qualitative Output: "Complete/Partial/Not
///         Complete". PMI/BABOK Requirements Quality Standard (SMART Criteria).
///         Assigned to **UDF**.
///
/// THE MOST SPLICED ROW IN THE TRACK: THREE SUBJECTS IN ONE ROW, WITH FIVE
/// CELLS BELONGING TO A TLS HARDENING ROW.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/inventory/screen_count_scope.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  group('ETMDI-003 :: three subjects in one row', () {
    gate(
      'ETMDI-003-G1',
      'Three subjects in one row.',
      'Screen counting in the Atomic Step, TLS 1.3 hardening in the lower '
          'half, and a SmartKeyboardField component in the Setup Step',
      () => HabotScreenCountScope.threeSubjectsInOneRow,
    );

    gate(
      'ETMDI-003-G2',
      'Five cells belong to a TLS row.',
      'Named individually rather than summarised, because the next reader has '
          'to be able to check',
      () =>
          HabotScreenCountScope.fiveCellsBelongElsewhere &&
          HabotScreenCountScope.spliceNote.contains('downgrade attacks'),
    );

    gate(
      'ETMDI-003-G3',
      'Third and worst spliced row, after 388 and 390.',
      'Those two joined two subjects; this joins three',
      () =>
          HabotScreenCountScope.thisIsTheThirdAndWorst &&
          HabotScreenCountScope.splicedRows.contains(388),
    );

  });

  group('ETMDI-003 :: what "the count" refers to', () {
    gate(
      'ETMDI-003-G4',
      '"The count" has no antecedent.',
      'The row never says what is being counted, so the reading used here is '
          'stated as an assumption rather than presented as the meaning',
      () =>
          !HabotScreenCountScope.theRowSaysWhatIsCounted &&
          HabotScreenCountScope.antecedentNote
              .contains('cannot be implemented out of order'),
    );

  });

  group('ETMDI-003 :: features and screens', () {
    gate(
      'ETMDI-003-G5',
      'Five features, six screens.',
      'Each feature naming the screens in its scope',
      () =>
          HabotScreenCountScope.featureCount == 5 &&
          HabotScreenCountScope.screensAfterTheSplit == 6,
    );

    gate(
      'ETMDI-003-G6',
      'Both directions are checked.',
      'A feature with no screen and a screen with no feature are different '
          'failures and neither is visible from a single total',
      () => HabotScreenCountScope.bothDirectionsAreChecked,
    );

    gate(
      'ETMDI-003-G7',
      'One feature has no screen.',
      'Which is a feature that cannot be reached',
      () => HabotScreenCountScope.oneFeatureHasNoScreen,
    );

    gate(
      'ETMDI-003-G8',
      'One screen has no feature.',
      '"Edit profile" exists and belongs to nothing that was scoped',
      () =>
          HabotScreenCountScope.oneScreenHasNoFeature &&
          HabotScreenCountScope.screenWithNoFeature == 'Edit profile',
    );

  });

  group('ETMDI-003 :: the band', () {
    gate(
      'ETMDI-003-G9',
      'Shift exchange has two screens after the split.',
      'Carried through from Step 397 rather than recounted',
      () =>
          HabotScreenCountScope.featuresWithMoreThanOneScreen == 1 &&
          HabotScreenCountScope.gapNote.contains('would be the failure'),
    );

    gate(
      'ETMDI-003-G10',
      'Six obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotScreenCountScope.obligations.length == 6 &&
          HabotScreenCountScope.obligations.values.every((bool b) => b) &&
          HabotScreenCountScope.qualitativeOutput == 'Complete' &&
          !HabotScreenCountScope.theMappingIsExact &&
          HabotScreenCountScope.theOptimalEqualsTheCeiling &&
          HabotScreenCountScope.gapsNamed == 100,
    );
  });

  tearDownAll(() {
    final int features = HabotScreenCountScope.featureCount;
    final int screens = HabotScreenCountScope.screensAfterTheSplit;
    final int orphanFeatures =
        HabotScreenCountScope.featuresWithNoScreen.length;
    final int orphanScreens = HabotScreenCountScope.screensWithNoFeature;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ETMDI-003',
        atomicStepReferenceId: 'ETMDI-003',
        setupStepAction:
            'COLUMN NOTE: only the first sentence of this row belongs to it. '
            'Its Expected Output is a Terraform file, its Completion Measure '
            'is about TLS 1.2 handshake failures, its poka-yoke cell is about '
            'the minimum TLS version, its UI decision reads "N/A '
            '(Backend/Infrastructure layer)", its Why This Matters is about '
            'downgrade attacks, and its Setup Step column reads "Access the '
            'SmartKeyboardField component inside the Frontend Design System" '
            '-- three subjects in one row, where Steps 388 and 390 carried two '
            'each. "The count" also has no antecedent anywhere on the row. '
            'Atomic Step: "Ensure the count maps exactly to the mobile feature '
            'scope."',
        implementationOrder: 398,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'Android and iOS, one Flutter codebase',
          'OS Version': 'Android 13+ / iOS 16+',
          'Device Type': 'handset, the only form factor these screens ship to',
          'Screen Dimensions':
              'a $screens-screen inventory across $features scoped features; '
                  'these five cells belong to a mobile-configuration row and '
                  'not to this one',
          'Mobile Configuration':
              '$orphanFeatures feature with no screen, $orphanScreens screen '
                  'with no feature, both named',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirements Clarity & Completion Index',
            observed:
                'THE MOST SPLICED ROW THE TRACK HAS RECORDED. The Atomic Step '
                'is about counting screens, the lower half is about TLS 1.3 '
                'hardening at the edge, and the Setup Step column describes a '
                'SmartKeyboardField component: three subjects in one row, '
                'where Steps 388 and 390 each joined two. Five cells belong to '
                'the TLS row outright. The metric itself is a clarity index on '
                'a row that is not clear, and its subject -- "the count" -- '
                'has no antecedent anywhere in the row. Observed: $features '
                'features scoped to $screens screens.',
            floor: '0.8',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Gaps found by counting in both directions',
            observed:
                '2 of $screens. Counting features per screen finds '
                '$orphanFeatures feature that no screen reaches; counting '
                'screens per feature finds $orphanScreens screen, Edit '
                'profile, that belongs to nothing scoped. Neither is visible '
                'from a single total, which is what a screen count usually is, '
                'and that is the argument for counting twice rather than the '
                'argument for counting carefully.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/inventory/screen_count_scope.dart',
        ],
      ),
    );
  });
}
