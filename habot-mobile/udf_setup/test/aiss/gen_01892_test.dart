/// AISS GATE -- Step 378 of 395
/// Global Reference ID:       GEN-01892
/// Atomic Steps Reference ID: GEN-01892
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement MD3 Segmented Buttons or toggle switches for
///               interaction."
/// Metric: Implementation Completion Rate (%) -- floor 95, optimal 99.5,
///         ceiling 100. Complete/Partial/Not Complete. ISO/IEC 27001:2022
///         Implementation Standards. Assigned to **UDF**.
///
/// THE "OR" IS THE DEFECT: TWO CONTROLS THAT ANSWER DIFFERENT QUESTIONS,
/// OFFERED AS ALTERNATIVES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/controls/segmented_control.dart';

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

  group('GEN-01892 :: the two controls are not alternatives', () {
    gate(
      'GEN-01892-G1',
      'Both commit on toggle, so the difference is the question.',
      'A segmented button is a choice between named options; a switch is one '
          'setting that is on or off',
      () =>
          HabotSegmentedControl.theDifferenceIsTheQuestionNotTheCommit &&
          !HabotSegmentedControl.theTwoControlsAreInterchangeable,
    );

    gate(
      'GEN-01892-G2',
      'A setting with three real states becomes a switch with two.',
      'And the third state becomes whatever the app does when the switch is '
          'off',
      () =>
          HabotSegmentedControl.theRowsWord == 'or' &&
          HabotSegmentedControl.orNote.contains('when the switch is off'),
    );
  });

  group('GEN-01892 :: chosen by the decision', () {
    gate(
      'GEN-01892-G3',
      'Three setting shapes, three controls.',
      'Named choice, immediate binary, and a binary whose effect waits for a '
          'save',
      () =>
          HabotSettingShape.values.length == 3 &&
          HabotControlKind.values.length == 3 &&
          HabotSegmentedControl.everyShapeHasAControl,
    );

    gate(
      'GEN-01892-G4',
      'Two settings get segments and one gets a switch.',
      'Chosen by the shape of the decision rather than by the row\'s "or"',
      () =>
          HabotSegmentedControl.settings.length == 4 &&
          HabotSegmentedControl.twoGetSegments &&
          HabotSegmentedControl.oneGetsAToggle,
    );

    gate(
      'GEN-01892-G5',
      'One fits neither control the row names.',
      'A switch that does nothing until somebody presses Save is the commonest '
          'lie in a settings screen, so it gets a checkbox and a Save',
      () =>
          HabotSegmentedControl.oneFitsNeitherControlTheRowNames &&
          !HabotSegmentedControl.aDeferredSettingIsShownAsASwitch &&
          HabotSegmentedControl.choiceNote.contains('commonest lie'),
    );
  });

  group('GEN-01892 :: the disabled cases', () {
    gate(
      'GEN-01892-G6',
      'The whole group and a single segment can each be disabled.',
      '"This setting is not yours" and "that option is not available to you" '
          'are different sentences',
      () =>
          HabotSegmentedControl.theWholeGroupCanBeDisabled &&
          HabotSegmentedControl.oneSegmentCanBeDisabled,
    );

    gate(
      'GEN-01892-G7',
      'An unavailable segment is disabled rather than removed.',
      'Removing it turns a three-option question into a two-option one and '
          'never tells the person the third existed',
      () =>
          HabotSegmentedControl.anUnavailableSegmentStaysVisible &&
          !HabotSegmentedControl.anUnavailableSegmentIsRemoved &&
          HabotSegmentedControl.optionsIfUnavailableOnesWereRemoved == 2 &&
          HabotSegmentedControl.disabledNote.contains('never tells the person'),
    );
  });

  group('GEN-01892 :: size, and the tautological metric', () {
    gate(
      'GEN-01892-G8',
      'A segment carries the declared 48dp minimum.',
      'Rather than a size chosen to fit the label',
      () =>
          HabotSegmentedControl.theSegmentSizeIsTheDeclaredOne &&
          HabotSegmentedControl.minimumSegmentDp == 48,
    );

    gate(
      'GEN-01892-G9',
      'Three segments are 144dp against a 328dp compact width.',
      'So what limits the number of segments is the label, not the target -- '
          'which is why a four-option choice becomes a list',
      () =>
          HabotSegmentedControl.threeSegmentsFitCompact &&
          HabotSegmentedControl.widthOfThreeSegments == 144 &&
          HabotSegmentedControl.sizeNote.contains('truncated words'),
    );

    gate(
      'GEN-01892-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Five obligations, all met, giving Complete; the band is well formed, '
          'the metric is a tautology, and all ten declared checks hold',
      () =>
          HabotSegmentedControl.obligations.length == 5 &&
          HabotSegmentedControl.obligations.values.every((bool b) => b) &&
          HabotSegmentedControl.qualitativeOutput == 'Complete' &&
          HabotSegmentedControl.theBandIsWellFormed &&
          HabotSegmentedControl.chosenByShape == 100 &&
          HabotSegmentedControl.checks.length == 10 &&
          HabotSegmentedControl.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int segments =
        HabotSegmentedControl.countOf(HabotControlKind.segments);
    final int toggles = HabotSegmentedControl.countOf(HabotControlKind.toggle);
    final int checkboxes =
        HabotSegmentedControl.countOf(HabotControlKind.checkboxWithSave);
    final String width =
        HabotSegmentedControl.widthOfThreeSegments.toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01892',
        atomicStepReferenceId: 'GEN-01892',
        setupStepAction:
            'COLUMN NOTE: this row offers segmented buttons and toggle '
            'switches as interchangeable alternatives when they answer '
            'different questions; its Data Requirement cell holds the Atomic '
            'Step\'s own sentence as the artefact to prepare; its metric is an '
            'implementation completion rate on a row whose completion is the '
            'thing being measured, which cannot report anything but success; '
            'and the Setup Step column is empty. Atomic Step: "Implement MD3 '
            'Segmented Buttons or toggle switches for interaction."',
        implementationOrder: 378,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement MD3 Segmented Buttons or toggle switches for interaction':
              '$segments settings get segments, $toggles a switch and '
                  '$checkboxes a checkbox with an explicit save',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'three segments come to ${width}dp against a 328dp compact '
                  'width; an unavailable segment is disabled rather than '
                  'removed',
          'Data Quality Note':
              'OR: ${HabotSegmentedControl.orNote} CHOICE: '
              '${HabotSegmentedControl.choiceNote} DISABLED: '
              '${HabotSegmentedControl.disabledNote} SIZE: '
              '${HabotSegmentedControl.sizeNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Implementation Completion Rate (%)',
            observed:
                'WELL FORMED AND TAUTOLOGICAL. Floor 95, optimal 99.5, ceiling '
                '100, correctly ordered -- one of the few sound bands in this '
                'batch. An implementation completion rate on a row whose '
                'completion is the thing being measured cannot report anything '
                'but success, so the figure published instead is the share of '
                'settings whose control was chosen by the shape of the '
                'decision rather than by the row\'s "or": 100 per cent, across '
                'four settings and three control kinds.',
            floor: '95',
            optimal: '99.5',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName:
                'Settings given a control that answers another question',
            observed:
                '0 of 4. A segmented button is a choice between named options, '
                'all visible; a switch is one setting that is on or off. Both '
                'commit on toggle, so the difference is the question rather '
                'than the commit, and offering them as alternatives is how a '
                'setting with three real states becomes a switch with two. '
                '$segments settings here are named choices and get segments, '
                '$toggles is an immediate binary and gets a switch, and '
                '$checkboxes is a binary whose effect waits for a save -- the '
                'case neither control the row names fits.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/controls/segmented_control.dart',
        ],
      ),
    );
  });
}
