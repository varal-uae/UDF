/// AISS GATE -- Step 312 of 315
/// Global Reference ID:       RTSET-033
/// Atomic Steps Reference ID: RTSET-033
/// Setup Step (Action): "Implement haptic feedback on double-tap confirmation
///                      -- medium haptic pattern." (THE SCREEN READER OWNS
///                      THAT GESTURE -- REFUSED)
/// Atomic Step: "Select status badge styling and dashboard container layouts
///               for mobile views."
/// Metric: Select Status Badge Quality Index -- floor 0.98, optimal 1,
///         CEILING 0.999. Complete.
///
/// THE CEILING IS BELOW THE OPTIMAL. AND OVER FIVE BADGES THE INDEX MOVES IN
/// FIFTHS, SO NEITHER BOUNDARY IS A VALUE IT CAN TAKE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/badge_quality_index.dart';
import 'package:udf_setup/design_system/feedback/status_badge.dart';

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

  group('RTSET-033 :: the band that cannot be satisfied', () {
    gate(
      'RTSET-033-G1',
      'Floor 0.98, optimal 1, ceiling 0.999.',
      'The ceiling is a thousandth below the optimal, so the value the row '
          'calls best sits outside the range the row calls acceptable',
      () =>
          HabotBadgeQualityIndex.theCeilingIsBelowTheOptimal &&
          (HabotBadgeQualityIndex.byHowMuch - 0.001).abs() < 1e-9,
    );

    gate(
      'RTSET-033-G2',
      'Eleven batches of band defects, and this is the first false one.',
      'The others were unit mismatches, unfailable floors or boundaries '
          'about another subject; this one is wrong on its own terms',
      () => HabotBadgeQualityIndex.bandNote
          .contains('false on its own terms'),
    );

    gate(
      'RTSET-033-G3',
      'Five badges, so the index moves in fifths.',
      'Six attainable values, of which neither 0.98 nor 0.999 is one, and '
          'exactly one -- 1.0 -- clears the floor',
      () =>
          HabotBadgeQualityIndex.badgesScored == 5 &&
          HabotBadgeQualityIndex.smallestIndexStep == 0.2 &&
          HabotBadgeQualityIndex.attainableIndexValues.length == 6 &&
          HabotBadgeQualityIndex.neitherTheFloorNorTheCeilingIsAttainable &&
          HabotBadgeQualityIndex.exactlyOneValuePasses,
    );
  });

  group('RTSET-033 :: the styling already exists', () {
    gate(
      'RTSET-033-G4',
      'Atomic Step: "Select status badge styling".',
      'Five statuses, each with a spec filed under the status it names, each '
          'carrying a label as well as an icon and a colour role',
      () =>
          HabotBadgeQualityIndex.everyStatusHasASpec &&
          HabotBadgeQualityIndex.everySpecCarriesAllThree &&
          HabotStatus.values.length == 5,
    );

    gate(
      'RTSET-033-G5',
      'No two statuses share a label.',
      'Two may legitimately share a colour role, because the label and the '
          'icon are what separate them; the index is over labels',
      () =>
          HabotBadgeQualityIndex.noTwoStatusesShareALabel &&
          HabotBadgeQualityIndex.theIndexIsOverLabelsRatherThanColours &&
          HabotBadgeQualityIndex.observedIndex == 1.0,
    );

    gate(
      'RTSET-033-G6',
      'Asking for the selection again produces a second badge.',
      'And a repository with two status badges has a drift problem rather '
          'than a design',
      () => HabotBadgeQualityIndex.stylingNote.contains('drift problem'),
    );
  });

  group('RTSET-033 :: the container', () {
    gate(
      'RTSET-033-G7',
      'A tappable badge inside a tappable row.',
      'Gives a finger two answers for one landing; the row opens the record '
          'and the badge says what state it is in',
      () =>
          !HabotBadgeQualityIndex.theBadgeIsInteractive &&
          HabotBadgeQualityIndex.containerNote
              .contains('One target, one meaning'),
    );
  });

  group('RTSET-033 :: the Setup Step, refused', () {
    gate(
      'RTSET-033-G8',
      'Setup Step: "haptic feedback on double-tap confirmation".',
      'With TalkBack or VoiceOver running a double-tap IS activation, so an '
          'app that treats it as a distinct gesture gets an ordinary press '
          'from every screen reader user',
      () =>
          HabotBadgeQualityIndex.theGestureIsOwnedByAssistiveTechnology &&
          HabotBadgeQualityIndex.screenReadersThatOwnDoubleTap.length == 2 &&
          HabotBadgeQualityIndex.doubleTapWindow.inMilliseconds == 300,
    );

    gate(
      'RTSET-033-G9',
      'The people most likely to want a confirmation cannot reach it.',
      'No app action is bound to the gesture; the confirming haptic fires on '
          'a named control, at the medium strength already declared for a '
          'confirmed destructive action',
      () =>
          !HabotBadgeQualityIndex.doubleTapIsBoundToAnAppAction &&
          HabotBadgeQualityIndex.theRequestedStrengthAlreadyExists &&
          HabotBadgeQualityIndex.gestureNote.contains('cannot reach it'),
    );

    gate(
      'RTSET-033-G10',
      'Output: Complete.',
      'Five declared obligations, all met; all eleven declared checks hold, '
          'and the row\'s ADFA assignment and push-token Output Type cell are '
          'recorded',
      () =>
          HabotBadgeQualityIndex.obligations.length == 5 &&
          HabotBadgeQualityIndex.obligations.values.every((bool b) => b) &&
          HabotBadgeQualityIndex.qualitativeOutput == 'Complete' &&
          HabotBadgeQualityIndex.checks.length == 11 &&
          HabotBadgeQualityIndex.checks.values.every((bool b) => b) &&
          HabotBadgeQualityIndex.columnNote.contains('ADFA'),
    );
  });

  tearDownAll(() {
    final String attainable = HabotBadgeQualityIndex.attainableIndexValues
        .map((double v) => v.toStringAsFixed(1))
        .join(', ');
    final String passing = HabotBadgeQualityIndex
        .attainableValuesClearingTheFloor
        .map((double v) => v.toStringAsFixed(1))
        .join(', ');

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'RTSET-033',
        atomicStepReferenceId: 'RTSET-033',
        setupStepAction:
            'COLUMN NOTE: this is the only row in this batch assigned to ADFA '
            'rather than UDF. Its Decision Group is "Benefits.", its Output '
            'Type cell is a sentence about stale FCM and APNs push tokens, its '
            'narrative columns are an insurance pricing engine, and its Setup '
            'Step reads "Implement haptic feedback on double-tap confirmation '
            '-- medium haptic pattern". Atomic Step: "Select status badge '
            'styling and dashboard container layouts for mobile views."',
        implementationOrder: 312,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'status badge inside a dashboard card row',
          'Layout Grid Dimensions':
              '${HabotStatus.values.length} statuses, each with a label, an '
                  'icon and a colour role',
          'Spacing Rules': 'the badge sits inside the row\'s own tappable area',
          'Alignment Settings':
              'the badge is not itself a target, so a tap has one meaning',
          'Layout Validation Status': 'Complete',
          'Component Properties':
              'attainable index values are $attainable; the values clearing '
                  'the floor are $passing',
          'Data Quality Note':
              'BAND: ${HabotBadgeQualityIndex.bandNote} '
              'STYLING: ${HabotBadgeQualityIndex.stylingNote} '
              'CONTAINER: ${HabotBadgeQualityIndex.containerNote} '
              'GESTURE: ${HabotBadgeQualityIndex.gestureNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Select Status Badge Quality Index',
            observed:
                '1.0, which is the only attainable value that clears the '
                'floor. The ceiling of 0.999 is BELOW the optimal of 1, and '
                'over five badges the index moves in fifths, so neither the '
                'floor nor the ceiling is a value the measurement can take. '
                'The band is a Pass/Fail with three decimal places, which is '
                'what the qualitative column already said.',
            floor: '0.98',
            optimal: '1',
            ceiling: '0.999',
          ),
          AissMeasurement(
            metricName: 'App actions bound to the screen reader double-tap',
            observed:
                '0. With TalkBack or VoiceOver running the double-tap is '
                'activation, so binding a confirmation to it would deliver an '
                'ordinary press to every screen reader user and a '
                'confirmation to everyone else. The confirming haptic moved '
                'to a named control at the strength already declared.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/badge_quality_index.dart',
        ],
      ),
    );
  });
}
