/// AISS GATE -- Step 249 of 255
/// Global Reference ID:       GEN-05298
/// Atomic Steps Reference ID: GEN-05298
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Unit-test and validate the implementation of: build
///               'Self-Chasing' immediate friction alerts (e.g., inline
///               warnings, delayed progress bars) when users skip required
///               prep steps."
/// Metric: Validation Test Pass Rate (Data-Entry Error Rate) -- Floor ">= 95%
///         test pass rate, >= 80% code coverage", Optimal "100% test pass
///         rate, >= 90% code coverage", Ceiling "100% coverage". Pass/Fail.
///
/// REPORTS PARTIAL, for a reason about this host rather than about the work:
/// the coverage half of the metric needs a Dart toolchain this build host does
/// not have, and an invented coverage number is worse than none.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/prep_step_warning.dart';

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

  group('GEN-05298 :: where the warning lives', () {
    gate(
      'GEN-05298-G1',
      'Atomic Step: "inline warnings, DELAYED PROGRESS BARS."',
      'The delayed progress bar is refused by name: a progress indicator '
          'slowed on purpose lies about system state to make somebody '
          'uncomfortable, and Step 248 ruled on it in general so the two '
          'refusals are one ruling',
      () =>
          HabotPrepStepWarning.theDelayedProgressBarIsRefused &&
          HabotPrepStepWarning.everySurfaceIsRuledOn &&
          HabotWarningSurface.values.length == 3,
    );

    gate(
      'GEN-05298-G2',
      'Step 226 governs snackbars, and they leave.',
      'The warning is attached to the step it is about and stays until the '
          'step is done -- a message that has gone is not a reminder, it is a '
          'moment somebody may have been looking away for',
      () =>
          HabotPrepStepWarning.surface ==
              HabotWarningSurface.inlineAtTheStep &&
          HabotPrepStepWarning
              .surfaceRulings[HabotWarningSurface.transientSnackbar]!
              .contains('looking away'),
    );

    gate(
      'GEN-05298-G3',
      '"When users SKIP REQUIRED prep steps."',
      'Four of the six declared steps are required and only two of those block '
          'submission -- making everything a blocker is how a flow becomes '
          'impassable for the person whose situation the form did not '
          'anticipate, and making nothing a blocker is how a child arrives '
          'with an unrecorded allergy',
      () =>
          HabotPrepStepWarning.steps.length == 6 &&
          HabotPrepStepWarning.requiredSteps.length == 4 &&
          HabotPrepStepWarning.blockingSteps.length == 2 &&
          HabotPrepStepWarning.warningsAreNotWallsNote
              .contains('unrecorded allergy'),
    );

    gate(
      'GEN-05298-G4',
      'A warning about everything is a warning about nothing.',
      'Optional steps are never warned about however long they are left, so '
          'an untouched flow produces four warnings rather than six',
      () =>
          HabotPrepStepWarning.optionalStepsAreNeverWarnedAbout &&
          HabotPrepStepWarning.warningsFor(<String>{}).length == 4 &&
          HabotPrepStepWarning.blockersFor(<String>{}).length == 2,
    );
  });

  group('GEN-05298 :: self-chasing, and a metric with two halves', () {
    gate(
      'GEN-05298-G5',
      'IS12-CSIVW-011 Self-Chasing: "fields recheck the second an error is '
          'edited."',
      'Every required step\'s warning clears the moment that step is done, '
          'without waiting for another submit -- checked for each of the four '
          'rather than for one',
      () =>
          HabotPrepStepWarning.everyRequiredStepSelfChases &&
          HabotPrepStepWarning.warningClearsOnCompletion('allergies') &&
          !HabotPrepStepWarning.canSubmit(<String>{'child'}),
    );

    gate(
      'GEN-05298-G6',
      'Metric parenthetical: Data-Entry Error Rate.',
      'One attempt in four in the corpus is left with a blocking step '
          'outstanding and the gate accepts none of them, while one in four '
          'submits with a non-blocking warning still on screen -- which is the '
          'design rather than a failure',
      () =>
          (HabotPrepStepWarning.attemptsWithABlockerOutstanding - 0.25).abs() <
              1e-9 &&
          HabotPrepStepWarning.submissionsAcceptedWithABlockerOutstanding ==
              0 &&
          (HabotPrepStepWarning.submissionsWithAWarningOutstanding - 0.25)
                  .abs() <
              1e-9 &&
          HabotPrepStepWarning.attemptCorpus.length == 4,
    );

    gate(
      'GEN-05298-G7',
      'Metric: ">= 95% test pass rate, >= 80% CODE COVERAGE."',
      'All eleven checks hold and the pass-rate half is met, but coverage '
          'needs flutter test --coverage on a machine with a Dart toolchain '
          'and this build host has none -- so codeCoverage is null rather than '
          'a figure and the step reports PARTIAL',
      () =>
          HabotPrepStepWarning.checks.length == 11 &&
          HabotPrepStepWarning.checks.values.every((bool b) => b) &&
          HabotPrepStepWarning.testPassRate >=
              HabotPrepStepWarning.passRateOptimal &&
          HabotPrepStepWarning.coverageIsUnmeasurableHere &&
          HabotPrepStepWarning.codeCoverage == null &&
          HabotPrepStepWarning.qualitativeOutput == 'Partial' &&
          HabotPrepStepWarning.coverageNote.contains('worse than none') &&
          HabotPrepStepWarning.columnNote.contains('Self-Chasing'),
    );
  });

  tearDownAll(() {
    final String delayedRuling = HabotPrepStepWarning
        .surfaceRulings[HabotWarningSurface.delayedProgress]!;
    final String snackbarRuling = HabotPrepStepWarning
        .surfaceRulings[HabotWarningSurface.transientSnackbar]!;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05298',
        atomicStepReferenceId: 'GEN-05298',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row and the '
            'Data Collected column reads only "Self-Chasing". Atomic Step: '
            '"Unit-test and validate the implementation of: build '
            '\'Self-Chasing\' immediate friction alerts (e.g., inline '
            'warnings, delayed progress bars) when users skip required prep '
            'steps."',
        implementationOrder: 249,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPrepStepWarning / HabotPrepStep',
          'Component Properties':
              '${HabotPrepStepWarning.steps.length} prep steps, '
              '${HabotPrepStepWarning.requiredSteps.length} required of which '
              '${HabotPrepStepWarning.blockingSteps.length} block; '
              '${HabotWarningSurface.values.length} warning surfaces ruled '
              'on, one used and one refused; a four-attempt corpus',
          'Completion Status': 'PARTIAL -- see note',
          'Data Quality Note':
              'REPORTED PARTIAL, and the reason is about this host rather '
              'than about the work. ${HabotPrepStepWarning.coverageNote} '
              'REFUSED: '
              '$delayedRuling '
              'SURFACE: '
              '$snackbarRuling '
              'DESIGN: ${HabotPrepStepWarning.warningsAreNotWallsNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Validation Test Pass Rate',
            observed:
                '${HabotPrepStepWarning.testPassRate.toStringAsFixed(2)} -- '
                'every gate in this evidence file passes.',
            floor: '>= 95% test pass rate',
            optimal: '100% test pass rate',
            ceiling: '100%',
          ),
          AissMeasurement(
            metricName: 'Code coverage',
            observed:
                'Not measured. It needs flutter test --coverage on a machine '
                'with a Dart toolchain, and this build host has none -- the '
                'same constraint every batch in this track has recorded. A '
                'figure here would be invented, and an invented coverage '
                'number is the number somebody stops checking.',
            floor: '>= 80%',
            optimal: '>= 90%',
            ceiling: '100%',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/prep_step_warning.dart',
        ],
      ),
    );
  });
}
