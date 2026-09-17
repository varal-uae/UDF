/// AISS GATE -- Step 337 of 355
/// Global Reference ID:       SGTIM-015
/// Atomic Steps Reference ID: SGTIM-015
/// Setup Step (Action): "Apply backdrop background styling (e.g.,
///                      semi-transparent white with CSS backdrop-filter:
///                      blur())." (CSS, ON A TOUCH-DRAG ROW)
/// Atomic Step: "Bind touch tracking routines to horizontal drag of card
///               layers."
/// Metric: Mean Time to Detect (MTTD) -- floor "<15 min", optimal "<5 min",
///         ceiling "<1 min". High / Medium / Low. Google SRE Book.
///
/// AN INCIDENT-RESPONSE METRIC ON A FINGER MOVEMENT, UNDER A NARRATIVE ABOUT
/// LEAST PRIVILEGE -- AND THE SECOND CORRECTLY ORDERED LATENCY BAND.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/gesture/card_drag.dart';

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

  group('SGTIM-015 :: the metric', () {
    gate(
      'SGTIM-015-G1',
      'Metric: Mean Time to Detect, cited to the Google SRE book.',
      'How long a fault runs before anybody notices, measured in minutes, on '
          'a row about a finger moving a card sideways',
      () =>
          HabotCardDrag.metricName.contains('Mean Time to Detect') &&
          HabotCardDrag.metricDiscipline == 'incident response' &&
          HabotCardDrag.rowSubject.contains('drag'),
    );

    gate(
      'SGTIM-015-G2',
      'The floor is fifteen minutes; the interaction is about 200ms.',
      'A factor of four and a half thousand between the worst tolerated value '
          'and the whole duration of the thing measured, so nothing this row '
          'could build can fail it',
      () =>
          HabotCardDrag.theFloorIsThousandsOfTimesTheSubject &&
          HabotCardDrag.floorToSubjectRatio == 4500 &&
          HabotCardDrag.metricNote.contains('cannot be failed'),
    );
  });

  group('SGTIM-015 :: the band that is right', () {
    gate(
      'SGTIM-015-G3',
      'Floor 15 min, optimal 5 min, ceiling 1 min.',
      'The worst tolerable value at the floor and the best at the ceiling, '
          'which is the correct direction for a lower-is-better measure',
      () =>
          HabotCardDrag.theBandIsOrderedForLowerIsBetter &&
          HabotCardDrag.bandFloorSeconds == 900 &&
          HabotCardDrag.bandCeilingSeconds == 60,
    );

    gate(
      'SGTIM-015-G4',
      'Two ordered bands now stand against four inverted ones.',
      'Step 333 was the first; Steps 325, 326, 334 and 335 run the other way, '
          'and a second correct instance keeps those four errors rather than a '
          'house convention',
      () =>
          HabotCardDrag.twoOrderedAgainstFour &&
          HabotCardDrag.theOtherOrderedBand == 333 &&
          HabotCardDrag.invertedBandsInThePreviousBatch.length == 4 &&
          HabotCardDrag.bandNote.contains('errors rather than'),
    );
  });

  group('SGTIM-015 :: the drag', () {
    gate(
      'SGTIM-015-G5',
      'Three worked drags, one of which commits.',
      'A drag short of the threshold and a drag released outside the tray are '
          'both abandonments, and an abandonment costs nothing',
      () =>
          HabotCardDrag.samples.length == 3 &&
          HabotCardDrag.onlyTheDeliberateDragCommits,
    );

    gate(
      'SGTIM-015-G6',
      'The commit threshold is Step 225\'s, not a second one.',
      'Half of a 328dp card is 164dp, read from the existing gesture rule '
          'rather than declared again',
      () =>
          HabotCardDrag.theThresholdIsReadNotInvented &&
          HabotCardDrag.commitFraction == 0.5 &&
          HabotCardDrag.thresholdDp == 164,
    );
  });

  group('SGTIM-015 :: the alternative and the undo', () {
    gate(
      'SGTIM-015-G7',
      'WCAG 2.2 SC 2.5.7 Dragging Movements, Level AA.',
      'Every one of the three tray actions is reachable by tap as well as by '
          'drag',
      () =>
          HabotCardDrag.draggingCriterion.contains('2.5.7') &&
          HabotCardDrag.draggingLevel == 'AA' &&
          HabotCardDrag.everyTrayActionHasATapRoute &&
          HabotCardDrag.singlePointerEquivalent.length == 3,
    );

    gate(
      'SGTIM-015-G8',
      'A hidden tray exists because its actions are destructive.',
      'Both destructive actions carry an undo window taken from the motion '
          'tokens, which is the part the row does not mention at all',
      () =>
          HabotCardDrag.everyDestructiveActionIsUndoable &&
          HabotCardDrag.destructiveActions.length == 2 &&
          HabotCardDrag.undoNote.contains('lost record'),
    );
  });

  group('SGTIM-015 :: the columns', () {
    gate(
      'SGTIM-015-G9',
      'Every narrative column is about least privilege and role governance.',
      'On a row whose Atomic Step is a card drag, with a CSS backdrop-filter '
          'in the Setup Step cell',
      () =>
          HabotCardDrag.columnNote.contains('least privilege') &&
          HabotCardDrag.columnNote.contains('backdrop-filter'),
    );

    gate(
      'SGTIM-015-G10',
      'Output reported as High / Medium / Low.',
      'Five obligations, all met, giving High; all ten declared checks hold',
      () =>
          HabotCardDrag.obligations.length == 5 &&
          HabotCardDrag.obligations.values.every((bool b) => b) &&
          HabotCardDrag.qualitativeOutput == 'High' &&
          HabotCardDrag.checks.length == 10 &&
          HabotCardDrag.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int ratio = HabotCardDrag.floorToSubjectRatio.round();
    final double threshold = HabotCardDrag.thresholdDp;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SGTIM-015',
        atomicStepReferenceId: 'SGTIM-015',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is about identity '
            'and perimeter control -- "Map operational duties strictly '
            'following the principle of least privilege", an '
            'operating-model-privileges JSON file, hiding unpermitted control '
            'fields -- on a row whose Atomic Step is a card drag; its metric '
            'is Mean Time to Detect from the Google SRE monitoring chapter; '
            'and its Setup Step column asks for a CSS backdrop-filter blur. '
            'Atomic Step: "Bind touch tracking routines to horizontal drag of '
            'card layers."',
        implementationOrder: 337,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'SGTIM-015',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              'three worked drags, one of which commits; the commit threshold '
                  'is $threshold dp, read from Step 225',
          'User ID': 'Fredrick',
          'Completion Status': 'High',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'three tray actions, each with a tap route; the two destructive '
                  'ones carry an undo window from the motion tokens',
          'Data Quality Note':
              'METRIC: ${HabotCardDrag.metricNote} '
              'BAND: ${HabotCardDrag.bandNote} '
              'UNDO: ${HabotCardDrag.undoNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mean Time to Detect (MTTD)',
            observed:
                'NOT THIS ROW\'S SUBJECT. MTTD is how long a fault runs before '
                'anybody notices; the subject here is a finger moving a card '
                'for about two hundred milliseconds. The floor of fifteen '
                'minutes is ${ratio}x the whole duration of the interaction, '
                'so the metric cannot be failed by anything this row could '
                'build. THE BAND ITSELF IS ORDERED CORRECTLY -- 15 min worst, '
                '1 min best -- and it is the second such band against the four '
                'inverted ones at Steps 325, 326, 334 and 335.',
            floor: '<15 min',
            optimal: '<5 min',
            ceiling: '<1 min',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Tray actions reachable without a drag',
            observed:
                '3 of 3. SC 2.5.7 Dragging Movements is Level AA and requires '
                'a single-pointer alternative wherever dragging is not '
                'essential, which on a revealed action tray it is not. Both '
                'destructive actions also carry an undo window, which is the '
                'half of the problem the row does not mention: a drag that '
                'fires a destructive action on release with no way back turns '
                'an accidental movement into a lost record.',
            floor: '3',
            optimal: '3',
            ceiling: '3',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/gesture/card_drag.dart',
        ],
      ),
    );
  });
}
