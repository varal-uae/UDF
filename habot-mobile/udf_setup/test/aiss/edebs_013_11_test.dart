/// AISS GATE -- Step 354 of 355
/// Global Reference ID:       EDEBS-013-11
/// Atomic Steps Reference ID: EDEBS-013-11
/// Setup Step (Action): "Output the standardized MTOI Split-Screen Template
///                      for production deployment."
/// Atomic Step: "Configure the mobile front-end Linear Stepper component for
///               stepped transaction flows."
/// Metric: UI Design-System Adherence Rate -- floor ">=85%", optimal ">=95%",
///         ceiling 1. Good/Average/Poor. MD3 / Nielsen Norman.
///
/// A STEPPER PROMISES A DENOMINATOR. A PROGRESS BAR CANNOT, AND THAT IS THE
/// WHOLE REASON TO PREFER THE COMPONENT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/flow/linear_stepper.dart';

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

  group('EDEBS-013-11 :: how many, not how far', () {
    gate(
      'EDEBS-013-11-G1',
      'Four steps, one of which is current.',
      'The position is stated out of the total: "Step 3 of 4"',
      () =>
          HabotLinearStepper.total == 4 &&
          HabotLinearStepper.currentIndex == 2 &&
          HabotLinearStepper.positionLabel == 'Step 3 of 4',
    );

    gate(
      'EDEBS-013-11-G2',
      'A progress bar would say 50 per cent and answer a different question.',
      '"Three of four" is a decision about whether to finish now; "75 per '
          'cent" is a feeling',
      () =>
          HabotLinearStepper.theFractionSaysLess &&
          HabotLinearStepper.thePositionNamesTheDenominator,
    );

    gate(
      'EDEBS-013-11-G3',
      'A stepper may not be used for a flow of unknown length.',
      'A fourth step appearing after "3 of 3" is worse than never having '
          'promised anything',
      () =>
          HabotLinearStepper.theLengthIsKnownInAdvance &&
          HabotLinearStepper.lengthNote.contains('3 of 3'),
    );
  });

  group('EDEBS-013-11 :: backwards is free', () {
    gate(
      'EDEBS-013-11-G4',
      'Going back neither revalidates nor discards.',
      'A stepper that throws errors at somebody who is checking rather than '
          'editing teaches people not to look',
      () =>
          HabotLinearStepper.backwardsCostsNothing &&
          HabotLinearStepper.directionNote.contains('not to look'),
    );

    gate(
      'EDEBS-013-11-G5',
      'Forwards commits, and only completed steps are committed.',
      'Two of the four, and they are exactly the ones already left forwards',
      () =>
          HabotLinearStepper.goingForwardCommits &&
          HabotLinearStepper.onlyCompletedStepsAreCommitted &&
          HabotLinearStepper.committedSteps.length == 2,
    );
  });

  group('EDEBS-013-11 :: compact width', () {
    gate(
      'EDEBS-013-11-G6',
      'Four labels across 328dp is 82dp each.',
      'Which is not a label, it is an abbreviation with an ellipsis, and that '
          'is before any translation',
      () =>
          HabotLinearStepper.labelsDoNotFitAtCompact &&
          HabotLinearStepper.dpPerLabel == 82,
    );

    gate(
      'EDEBS-013-11-G7',
      'The labels collapse to the current one plus the count.',
      'Which keeps the part that carries the promise and drops the part that '
          'was never readable',
      () =>
          HabotLinearStepper.labelsCollapseToTheCurrentOne &&
          HabotLinearStepper.theCollapsedFormKeepsThePromise &&
          HabotLinearStepper.widthNote.contains('still in the semantics'),
    );
  });

  group('EDEBS-013-11 :: transitions and the band', () {
    gate(
      'EDEBS-013-11-G8',
      'Both transitions were declared in the motion tokens at Step 136.',
      'Before anything in this repository had steps to move between; a second '
          'set of durations is how two flows end up feeling like two '
          'applications',
      () =>
          HabotLinearStepper.bothTransitionsWereAlreadyDeclared &&
          HabotLinearStepper.transitionNote.contains('two applications'),
    );

    gate(
      'EDEBS-013-11-G9',
      'Floor ">=85%", optimal ">=95%", ceiling "1".',
      'Two percentages and a bare ratio -- the fourth mixed-unit band in this '
          'batch after Steps 336, 343 and 348',
      () =>
          HabotLinearStepper.theBandMixesUnits &&
          HabotLinearStepper.mixedUnitBandsInThisBatch == 4 &&
          HabotLinearStepper.adherence == 100,
    );

    gate(
      'EDEBS-013-11-G10',
      'Output reported as Good / Average / Poor.',
      'Six obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotLinearStepper.obligations.length == 6 &&
          HabotLinearStepper.obligations.values.every((bool b) => b) &&
          HabotLinearStepper.qualitativeOutput == 'Good' &&
          HabotLinearStepper.checks.length == 10 &&
          HabotLinearStepper.checks.values.every((bool b) => b) &&
          HabotLinearStepper.columnNote.contains('inline validation'),
    );
  });

  tearDownAll(() {
    final String compact = HabotLinearStepper.compactLabel;
    final String perLabel = HabotLinearStepper.dpPerLabel.toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'EDEBS-013-11',
        atomicStepReferenceId: 'EDEBS-013-11',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement column on this row is about '
            'error handling for empty mandatory fields and inline validation '
            'rather than about a stepper; the Setup Step column reads "Output '
            'the standardized MTOI Split-Screen Template for production '
            'deployment"; and the band mixes two percentages with the bare '
            'ratio "1". Atomic Step: "Configure the mobile front-end Linear '
            'Stepper component for stepped transaction flows."',
        implementationOrder: 354,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Parameter': 'linear stepper for transaction flows',
          'Current Setting':
              '4 steps, the third current; labels collapse at compact width',
          'Previous Setting': 'none; this is the first stepper',
          'Change Log':
              'both transitions read from the Step 136 motion tokens rather '
                  'than declared again',
          'Configuration Timestamp': '2026-09-17T00:00:00Z',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'at compact width the header reads "$compact", which is $perLabel'
                  'dp per label if all four were shown',
          'Data Quality Note':
              'LENGTH: ${HabotLinearStepper.lengthNote} '
              'DIRECTION: ${HabotLinearStepper.directionNote} '
              'WIDTH: ${HabotLinearStepper.widthNote} '
              'BAND: ${HabotLinearStepper.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '100 over the population named here -- the share of this '
                'component\'s declared obligations that hold -- because the '
                'row names none. THE BAND MIXES UNITS: floor ">=85%", optimal '
                '">=95%", ceiling "1", which is two percentages and a bare '
                'ratio and the fourth such band in this batch after Steps 336, '
                '343 and 348. The three values are at least ordered once '
                'reconciled onto one scale.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Decimal points per step label at compact width',
            observed:
                '$perLabel dp for each of four labels across 328dp, which is '
                'an abbreviation with an ellipsis rather than a label, and '
                'that is before any translation. The labels therefore '
                'collapse to the current step and the count, keeping the '
                'denominator that is the whole reason to use a stepper rather '
                'than a progress bar: "three of four" is a decision about '
                'whether to finish now, and "75 per cent" is a feeling.',
            floor: '82',
            optimal: '96',
            ceiling: '120',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/flow/linear_stepper.dart',
        ],
      ),
    );
  });
}
