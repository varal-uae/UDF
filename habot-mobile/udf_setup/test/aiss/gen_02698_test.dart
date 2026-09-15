/// AISS GATE -- Step 275 of 275
/// Global Reference ID:       GEN-02698
/// Atomic Steps Reference ID: GEN-02698
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure Sentry to monitor both variants independently and
///               trigger automatic rollback if the experimental variant shows
///               elevated error rates."
/// Metric: WCAG 2.2 AA Compliance Rate -- Floor "All critical violations
///         fixed", Optimal "100% axe-core pass rate with zero WCAG AA
///         violations", Ceiling 1. Pass / Fail.
///
/// TWO MISMATCHES IN ONE CELL: AN ACCESSIBILITY METRIC ON AN ERROR-MONITORING
/// ROW, AND A BROWSER TOOL NAMED IN AN APPLICATION WITH NO DOM.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/preferences/feature_flags.dart';
import 'package:udf_setup/design_system/telemetry/variant_rollback.dart';

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

  group('GEN-02698 :: what "elevated" has to mean before it is automated', () {
    gate(
      'GEN-02698-G1',
      'Atomic Step: "if the experimental variant shows elevated error rates".',
      'Four observations are decided and no two the same way: too soon, too '
          'small, not elevated, and rolled back',
      () =>
          HabotVariantRollback.everyCorpusCaseIsDecidedDifferently &&
          HabotRollbackDecision.values.length == 4,
    );

    gate(
      'GEN-02698-G2',
      'A canary arm at one percent is three people.',
      'An arm whose error rate is four and a half times the control\'s is not '
          'acted on because it has forty sessions and three unhappy ones -- '
          'the case that would fire a naive rule',
      () =>
          HabotVariantRollback.theAlarmingCanaryIsNotActedOn &&
          HabotVariantRollback.canaryDecision ==
              HabotRollbackDecision.insufficientSample &&
          HabotVariantRollback.minimumSessionsPerArm == 500,
    );

    gate(
      'GEN-02698-G3',
      'A ratio between rates, not a difference between counts.',
      'A 1.9x elevation over three thousand sessions rolls back and a 1.1x '
          'difference over the same population holds, and both ratios are the '
          'ones computed rather than asserted',
      () =>
          HabotVariantRollback.elevatedDecision ==
              HabotRollbackDecision.rollBack &&
          HabotVariantRollback.noisyDecision == HabotRollbackDecision.hold &&
          HabotVariantRollback.theRatiosAreWhatWasComputed &&
          HabotVariantRollback.elevationFactor == 1.5,
    );

    gate(
      'GEN-02698-G4',
      'Nothing is decided before the window closes.',
      'The observation window is read from a declared token, and an arm '
          'observed for a sixth of it returns insufficient window rather than '
          'a verdict',
      () =>
          HabotVariantRollback.tooSoonDecision ==
              HabotRollbackDecision.insufficientWindow &&
          HabotVariantRollback.observationWindow.inHours == 1,
    );

    gate(
      'GEN-02698-G5',
      'A rule that rolls back and forward automatically oscillates.',
      'Going back is automatic and going forward is not, so the feature does '
          'not ship and unship every hour while nobody learns anything',
      () =>
          HabotVariantRollback.rollsBackAutomatically &&
          !HabotVariantRollback.rollsForwardAutomatically &&
          HabotVariantRollback.oscillationNote.contains('oscillates'),
    );
  });

  group('GEN-02698 :: the client half, and the metric cell', () {
    gate(
      'GEN-02698-G6',
      '"Monitor both variants independently" needs the arm in the report.',
      'The assignment already serialised by Step 133 carries the flag, the '
          'variant, the source and whether it was an exposure, so the error '
          'reports can be grouped by arm at all',
      () => HabotVariantRollback.theErrorReportCanTellTheArmsApart,
    );

    gate(
      'GEN-02698-G7',
      'A rollback leaves units assigned to a variant that is gone.',
      'The state that creates was declared at Step 133 before anything needed '
          'it, and the flag flip itself is named as the server\'s',
      () =>
          HabotVariantRollback.theStateARollbackCreatesWasAlreadyDeclared &&
          HabotVariantRollback.sourceAfterRollback ==
              HabotVariantSource.fallbackFromRemovedVariant &&
          HabotVariantRollback.whoRollsBackNote.contains('honour the next '
              'value'),
    );

    gate(
      'GEN-02698-G8',
      'Metric: WCAG 2.2 AA Compliance Rate, on an error-monitoring row.',
      'Both mismatches are recorded -- the wrong subject, and a browser tool '
          'named in an application whose widget tree is not a document -- '
          'rather than the easy number being reported as if it settled the '
          'hard one',
      () =>
          !HabotVariantRollback.axeCoreCanRunHere &&
          HabotVariantRollback.metricMismatchNote.contains('TWO '
              'MISMATCHES') &&
          HabotVariantRollback.metricMismatchNote.contains('not a document'),
    );

    gate(
      'GEN-02698-G9',
      'The accessibility obligation is answered where it can be.',
      'The Step 266 census scores 100 with nothing non-conformant, which is '
          'the honest equivalent of the tool the cell asks for',
      () => HabotVariantRollback.theAccessibilityHalfIsAlreadyMet &&
          HabotVariantRollback.accessibilityConformance == 100,
    );

    gate(
      'GEN-02698-G10',
      'The band is three incompatible forms of thing.',
      'A sentence, a tool output and the bare number 1 cannot all be '
          'satisfied by one measurement, and the ceiling read as 100% is '
          'equal to the optimal; all fifteen declared checks hold and the '
          'step reports Pass',
      () =>
          HabotVariantRollback.ceilingNote.contains('a percentage, a '
              'checklist and a ratio') &&
          HabotVariantRollback.checks.length == 15 &&
          HabotVariantRollback.checks.values.every((bool b) => b) &&
          HabotVariantRollback.qualitativeOutput == 'Pass' &&
          HabotVariantRollback.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String canary =
        HabotVariantRollback.canaryRateRatio.toStringAsFixed(1);
    final String elevated =
        HabotVariantRollback.elevatedRateRatio.toStringAsFixed(1);
    final String noisy =
        HabotVariantRollback.noisyRateRatio.toStringAsFixed(1);
    final String minimum = '${HabotVariantRollback.minimumSessionsPerArm}';
    final String window = '${HabotVariantRollback.observationWindow.inHours}h';
    final String score =
        HabotVariantRollback.accessibilityConformance.toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02698',
        atomicStepReferenceId: 'GEN-02698',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Floor '
            'Boundary is a sentence, Optimal Target names a browser tool, '
            'and Ceiling Boundary is the bare number 1. Atomic Step: '
            '"Configure Sentry to monitor both variants independently and '
            'trigger automatic rollback if the experimental variant shows '
            'elevated error rates."',
        implementationOrder: 275,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotVariantRollback / HabotArmObservation / '
                  'HabotRollbackDecision',
          'Component Properties':
              'four decisions over a $window window with a $minimum-session '
              'floor per arm and an elevation factor of '
              '${HabotVariantRollback.elevationFactor}; rates over sessions '
              'rather than events; rollback automatic and roll-forward not; '
              'the arm carried in the error report by Step 133\'s existing '
              'assignment',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotVariantRollback.thresholdNote} '
              'OSCILLATION: ${HabotVariantRollback.oscillationNote} '
              'CLIENT: ${HabotVariantRollback.clientHalfNote} '
              'METRIC: ${HabotVariantRollback.metricMismatchNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Error-rate ratios in the worked corpus',
            observed:
                'Canary ${canary}x on 40 sessions -- not acted on, because '
                'three unhappy sessions is not evidence. Elevated '
                '${elevated}x on 3000 -- rolled back. Noisy ${noisy}x on '
                '3000 -- held. A ratio between rates rather than a '
                'difference between counts, because counts mostly measure '
                'how big the arms are.',
            floor: '1.5x with $minimum sessions per arm',
            optimal: '1.5x with $minimum sessions per arm',
            ceiling: '1.5x with $minimum sessions per arm',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'WCAG 2.2 AA Compliance Rate',
            observed:
                'WRONG ROW, AND AN IMPOSSIBLE TOOL. The metric belongs to an '
                'accessibility subject and its optimal names axe-core, which '
                'walks a DOM; a Flutter widget tree is not a document. The '
                'obligation is answered by the Step 266 census, which scores '
                '$score with nothing non-conformant, and by the six a11y '
                'rules enforced since Step 97.',
            floor: 'All critical violations fixed',
            optimal: '100% axe-core pass rate with zero WCAG AA violations',
            ceiling: '1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/variant_rollback.dart',
        ],
      ),
    );
  });
}
