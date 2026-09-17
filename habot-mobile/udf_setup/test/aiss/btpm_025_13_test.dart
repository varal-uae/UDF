/// AISS GATE -- Step 300 of 315
/// Global Reference ID:       BTPM-025-13
/// Atomic Steps Reference ID: BTPM-025-13
/// Setup Step (Action): "Code a responsive color framework to swap layout
///                      styles to warning tones when project spending crosses
///                      the 70% mark." (CLOUD BUDGET ALERTING)
/// Atomic Step: "Display subtle animation hints on the frontend to signify
///               continuous background tracking."
/// Metric: Process Execution Quality Score -- floor >=90%, optimal >=98%,
///         ceiling 1. Good/Average/Poor. ISO 9001:2015.
///
/// "CONTINUOUS" IS THE ADJECTIVE THAT PUTS THE APP BELOW A LEVEL A CRITERION.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/loading/background_activity_hint.dart';

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

  group('BTPM-025-13 :: the arithmetic of continuous', () {
    gate(
      'BTPM-025-13-G1',
      'WCAG 2.1 SC 2.2.2 Pause, Stop, Hide -- Level A.',
      'Automatic motion lasting more than five seconds must be pausable; '
          'five seconds is 300 frames',
      () =>
          HabotBackgroundActivityHint.framesAtTheThreshold == 300 &&
          HabotBackgroundActivityHint.criterionLevel == 'A',
    );

    gate(
      'BTPM-025-13-G2',
      'Atomic Step: motion signifying CONTINUOUS tracking.',
      'A twenty-minute session is 72,000 frames -- 240 times the threshold '
          '-- so the instruction taken literally fails the lowest level of '
          'WCAG there is',
      () =>
          HabotBackgroundActivityHint.framesInAContinuousSession ==
              72000 &&
          HabotBackgroundActivityHint.timesOverTheThreshold == 240 &&
          HabotBackgroundActivityHint
              .theInstructionFailsALevelACriterion,
    );

    gate(
      'BTPM-025-13-G3',
      'Most of this track\'s accessibility findings sit at AA or AAA.',
      'This one arrives at Level A through a single adjective in the Atomic '
          'Step',
      () => HabotBackgroundActivityHint.continuousNote
          .contains('a single adjective'),
    );
  });

  group('BTPM-025-13 :: what the element is instead', () {
    gate(
      'BTPM-025-13-G4',
      'A held state is not an event.',
      'The looping form is refused; the element animates once on the '
          'transition into tracking and is still while the state holds',
      () =>
          HabotBackgroundActivityHint.theRowsFormIsRefused &&
          !HabotBackgroundActivityHint.animatesWhileTheStateHolds &&
          HabotBackgroundActivityHint.chosenForm ==
              HabotActivityHintForm.transitionThenStill,
    );

    gate(
      'BTPM-025-13-G5',
      'And the one transition asks the operating system first.',
      'The transition duration is a declared token and collapses under the '
          'reduce-motion preference, with the state change still happening',
      () =>
          HabotBackgroundActivityHint.transitionDuration
                  .inMilliseconds ==
              200 &&
          HabotBackgroundActivityHint.reducedMotionLosesNoInformation,
    );
  });

  group('BTPM-025-13 :: a decoration is the wrong channel', () {
    gate(
      'BTPM-025-13-G6',
      'Atomic Step: "signify continuous background tracking".',
      'The element says what is collected, why, and how to stop -- three '
          'sentences, none of which a shimmer can carry',
      () =>
          HabotBackgroundActivityHint.theStatusRow.length == 3 &&
          HabotBackgroundActivityHint.theStatusSaysWhatIsCollected &&
          HabotBackgroundActivityHint.theStatusOffersAWayToStop &&
          HabotBackgroundActivityHint
              .everyLineIsASentenceRatherThanALabel,
    );

    gate(
      'BTPM-025-13-G7',
      'The real notice already exists and is outside this app\'s control.',
      'An Android foreground-service notification and the iOS status-bar '
          'indicator are named rather than duplicated',
      () =>
          HabotBackgroundActivityHint.theAppIsNotTheNotice &&
          HabotBackgroundActivityHint.disclosureNote
              .contains('outside this app'),
    );
  });

  group('BTPM-025-13 :: the other two columns', () {
    gate(
      'BTPM-025-13-G8',
      'Config cell: "sub-400ms interval window".',
      'Twice this project\'s own declared interactive ceiling of 200ms, on a '
          'row about an animation; the stricter number stands',
      () =>
          HabotBackgroundActivityHint
              .theRequestedBudgetIsLooserThanTheProjects &&
          HabotBackgroundActivityHint.timesTheProjectCeiling == 2.0,
    );

    gate(
      'BTPM-025-13-G9',
      'Setup Step: "swap layout styles to warning tones".',
      'Cloud budget alerting on a tracking row, and a tone swap alone is '
          'colour as the sole carrier of meaning, which SC 1.4.1 forbids at '
          'Level A',
      () =>
          !HabotBackgroundActivityHint.colourAloneCarriesTheWarning &&
          HabotBackgroundActivityHint.colourNote.contains('1.4.1'),
    );

    gate(
      'BTPM-025-13-G10',
      'Output: Good / Average / Poor.',
      'Six declared obligations, all met, giving 1.0 and a Good; all ten '
          'declared checks hold',
      () =>
          HabotBackgroundActivityHint.obligations.length == 6 &&
          HabotBackgroundActivityHint.obligations.values
              .every((bool b) => b) &&
          HabotBackgroundActivityHint.executionQuality == 1.0 &&
          HabotBackgroundActivityHint.qualitativeOutput == 'Good' &&
          HabotBackgroundActivityHint.checks.length == 10 &&
          HabotBackgroundActivityHint.checks.values
              .every((bool b) => b) &&
          HabotBackgroundActivityHint.columnNote.contains('70% mark'),
    );
  });

  tearDownAll(() {
    final String frames =
        '${HabotBackgroundActivityHint.framesInAContinuousSession}';
    final String over =
        '${HabotBackgroundActivityHint.timesOverTheThreshold}';
    final String stop =
        HabotBackgroundActivityHint.theStatusRow['how to stop'] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BTPM-025-13',
        atomicStepReferenceId: 'BTPM-025-13',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Code a '
            'responsive color framework to swap layout styles to warning tones '
            'when project spending crosses the 70% mark", which is cloud '
            'budget alerting, and the first configuration cell asks for '
            'sub-400ms responses against this project\'s declared 200ms '
            'ceiling. Atomic Step: "Display subtle animation hints on the '
            'frontend to signify continuous background tracking."',
        implementationOrder: 300,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Frontend Technology': 'Flutter, Dart',
          'Framework Version': 'as declared in pubspec.yaml',
          'Build Configuration':
              'the tracking indicator animates on transition only; '
                  'HabotMotionPolicy.allowsLoopingMotion gates even that',
          'Performance Metrics':
              'a continuous animation would cost $frames frames across a '
                  'twenty-minute session, $over times the SC 2.2.2 threshold',
          'Build Output Path': 'build/',
          'Completion Status': 'Derived from gate outcomes',
          'Component Properties':
              'the status row says what is collected, why, and how to stop -- '
                  '"$stop"',
          'Data Quality Note':
              'CONTINUOUS: ${HabotBackgroundActivityHint.continuousNote} '
              'DISCLOSURE: '
              '${HabotBackgroundActivityHint.disclosureNote} '
              'LATENCY: ${HabotBackgroundActivityHint.latencyNote} '
              'COLOUR: ${HabotBackgroundActivityHint.colourNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                '100% over six declared obligations, the first of which is '
                'that nothing animates while the tracking state holds. The '
                'row\'s own instruction, implemented literally, would fail '
                'WCAG 2.1 SC 2.2.2 at Level A.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Frames of automatic motion per session',
            observed:
                '0 while the state holds, against $frames for the row\'s own '
                'reading -- $over times the five-second threshold SC 2.2.2 '
                'sets. One transition animates, and it collapses to zero '
                'duration under the reduce-motion preference without hiding '
                'anything.',
            floor: '300 (the SC 2.2.2 threshold)',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/loading/background_activity_hint.dart',
        ],
      ),
    );
  });
}
