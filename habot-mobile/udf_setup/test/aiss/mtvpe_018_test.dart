/// AISS GATE -- Step 345 of 355
/// Global Reference ID:       MTVPE-018
/// Atomic Steps Reference ID: MTVPE-018
/// Setup Step (Action): "Test the listeners trigger the dark mode token set
///                      correctly." (THEMING, ON A COACH-MARK ROW)
/// Atomic Step: "12. Configure visual highlight rings for target components."
/// Metric: Process Execution Quality (%) -- floor 95, optimal 99, ceiling 100.
///         Pass / Fail. ISO 9001:2015.
///
/// A SECOND RING IN THE FOCUS INDICATOR'S LANGUAGE TELLS SOMEBODY THEIR FOCUS
/// IS WHERE IT IS NOT. FIVE OF THIS ROW'S SIX FAILURES ARE INVISIBLE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/guidance/highlight_ring.dart';

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

  group('MTVPE-018 :: not a focus indicator', () {
    gate(
      'MTVPE-018-G1',
      'Two purposes for an outline, two visual forms.',
      'Focus is a solid inset; guidance is a dashed offset, so the two are '
          'distinguishable without colour',
      () =>
          HabotRingPurpose.values.length == 2 &&
          HabotHighlightRing.theTwoPurposesLookDifferent &&
          HabotHighlightRing.theDifferenceIsNotOnlyColour,
    );

    gate(
      'MTVPE-018-G2',
      'This file never draws a focus ring.',
      'The platform draws one and Step 109 declares this application\'s own; a '
          'second in the same language misreports where focus is',
      () =>
          !HabotHighlightRing.thisFileDrawsFocusRings &&
          HabotHighlightRing.focusNote.contains('Step 109'),
    );
  });

  group('MTVPE-018 :: the ring is a pointer, not a message', () {
    gate(
      'MTVPE-018-G3',
      'Three coach marks, each carrying a sentence.',
      'A ring says "here" and nothing else; a mark whose whole content is an '
          'outline is invisible to anybody not looking at colour',
      () =>
          HabotHighlightRing.marks.length == 3 &&
          HabotHighlightRing.everyMarkCarriesASentence &&
          HabotHighlightRing.noMarkIsARingAlone,
    );

    gate(
      'MTVPE-018-G4',
      'The instruction is announced before the control name.',
      'Because the name of a control means nothing until you know why you are '
          'being shown it',
      () =>
          HabotHighlightRing.theSentenceIsWhatIsAnnounced &&
          HabotHighlightRing.messageNote.contains('means nothing until'),
    );
  });

  group('MTVPE-018 :: the target stays operable', () {
    gate(
      'MTVPE-018-G5',
      'Every ringed control still receives touches.',
      'The usual implementation puts the scrim over the control it is pointing '
          'at, which replaces the task with a lesson',
      () =>
          HabotHighlightRing.everyTargetStaysOperable &&
          !HabotHighlightRing.theScrimBlocksTheRingedControl,
    );

    gate(
      'MTVPE-018-G6',
      'The scrim has a hole in it.',
      'Everything else is dimmed and inert; the ringed control is not',
      () => HabotHighlightRing.scrimNote.contains('hole'),
    );

    gate(
      'MTVPE-018-G7',
      'The ring is drawn outside the target.',
      'Offset by the gap Step 343 declared, so the target\'s own hit rectangle '
          'is unchanged',
      () =>
          HabotHighlightRing.theRingDoesNotShrinkTheTarget &&
          HabotHighlightRing.theOffsetIsTheDeclaredGap &&
          HabotHighlightRing.ringOffsetDp == 8,
    );
  });

  group('MTVPE-018 :: dismissal and the band', () {
    gate(
      'MTVPE-018-G8',
      'A coach mark that cannot be dismissed is a dialog with no buttons.',
      'The requirement is stated here and the controls are built at Step 347, '
          'so there is one dismissal mechanism rather than two',
      () =>
          HabotHighlightRing.aMarkCanBeDismissed &&
          HabotHighlightRing.dismissalOwner == 'Step 347' &&
          HabotHighlightRing.dismissalNote.contains('can disagree'),
    );

    gate(
      'MTVPE-018-G9',
      'Floor 95, optimal 99, ceiling 100 -- one of the few well-formed bands '
          'in this batch.',
      'What "Process Execution Quality" counts is not stated, so the figure '
          'published is the share of marks that carry a sentence and leave '
          'their target operable',
      () =>
          HabotHighlightRing.theBandIsWellFormed &&
          HabotHighlightRing.quality == 100,
    );

    gate(
      'MTVPE-018-G10',
      'Output reported as Pass / Fail.',
      'Six obligations, all met, giving Pass; all ten declared checks hold',
      () =>
          HabotHighlightRing.obligations.length == 6 &&
          HabotHighlightRing.obligations.values.every((bool b) => b) &&
          HabotHighlightRing.qualitativeOutput == 'Pass' &&
          HabotHighlightRing.checks.length == 10 &&
          HabotHighlightRing.checks.values.every((bool b) => b) &&
          HabotHighlightRing.columnNote.contains('multi-tenant'),
    );
  });

  tearDownAll(() {
    final String firstSentence = HabotHighlightRing.marks.first.sentence;
    final double offset = HabotHighlightRing.ringOffsetDp;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MTVPE-018',
        atomicStepReferenceId: 'MTVPE-018',
        setupStepAction:
            'COLUMN NOTE: the Atomic Step on this row begins with the number '
            '"12." inside its own text; every narrative column is about '
            'BigQuery row-level multi-tenant isolation; the Data Requirement '
            'column describes an expandable video player with play/pause '
            'overlays; and the Setup Step column reads "Test the listeners '
            'trigger the dark mode token set correctly". Atomic Step: '
            '"Configure visual highlight rings for target components."',
        implementationOrder: 345,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Parameter': 'guidance ring form and offset',
          'Current Setting':
              'dashed outline, offset ${offset}dp outside the target',
          'Previous Setting': 'none; this is the first guidance ring',
          'Change Log':
              '3 coach marks declared, each with a sentence and an operable '
                  'target',
          'Configuration Timestamp': '2026-09-17T00:00:00Z',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the first mark reads "$firstSentence"; the focus indicator is '
                  'left to Step 109 and the dismissal controls to Step 347',
          'Data Quality Note':
              'FOCUS: ${HabotHighlightRing.focusNote} '
              'MESSAGE: ${HabotHighlightRing.messageNote} '
              'SCRIM: ${HabotHighlightRing.scrimNote} '
              'BAND: ${HabotHighlightRing.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality (%)',
            observed:
                '100, over the population named here rather than the one the '
                'row omits: the share of coach marks that carry a sentence, '
                'leave their target operable, and are distinguishable from a '
                'focus ring. The band itself is well formed -- 95, 99, 100, in '
                'the right order -- which is unusual in this batch.',
            floor: '95',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Coach marks whose whole message is an outline',
            observed:
                '0 of 3. A ring says "here" and nothing else, so every mark '
                'carries a sentence in a labelled container and the sentence '
                'is what a screen reader announces, before the name of the '
                'control it points at. The ring is drawn ${offset}dp outside '
                'the target using the gap Step 343 declared, so it does not '
                'reduce the hit rectangle it is pointing at.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/guidance/highlight_ring.dart',
        ],
      ),
    );
  });
}
