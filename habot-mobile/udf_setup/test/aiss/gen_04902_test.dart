/// AISS GATE -- Step 270 of 275
/// Global Reference ID:       GEN-04902
/// Atomic Steps Reference ID: GEN-04902
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Convene the Consent & Privacy Governance decision group and
///               finalize the required pre-setup decision: Establish legal
///               consent retention rules and identity verification standards
///               for digital signatures."
/// Metric: Decision Governance Cycle Time -- Floor "<= 96 hours", Optimal
///         "24-48 hours", Ceiling "> 96 hours (stale)". Fast / Acceptable /
///         Delayed.
///
/// THIS STEP REPORTS PARTIAL. A CYCLE TIME FROM CONVENING TO RATIFICATION
/// MEASURES A MEETING, AND NO BUILD HOST CAN CONVENE OR TIME ONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/preferences/consent_retention.dart';

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

  group('GEN-04902 :: the decision record', () {
    gate(
      'GEN-04902-G1',
      'Atomic Step: "finalize the required pre-setup decision".',
      'Five clauses are recorded, each with a reason: two settled here and '
          'three left open with what each of them needs',
      () =>
          HabotConsentRetention.clauses.length == 5 &&
          HabotConsentRetention.settledClauses.length == 2 &&
          HabotConsentRetention.openClauses.length == 3 &&
          HabotConsentRetention.everyClauseGivesAReason,
    );

    gate(
      'GEN-04902-G2',
      'A settled clause with no position is not settled.',
      'Every settled clause takes a position, and the open clauses take none '
          'they are not in a position to take',
      () =>
          HabotConsentRetention.everySettledClauseTakesAPosition &&
          HabotConsentRetention.noOpenClauseTakesAPositionItCannot,
    );

    gate(
      'GEN-04902-G3',
      'Withdrawing consent and deleting the consent record are opposites.',
      'The counter-intuitive clause is first rather than a footnote: the '
          'record of consent survives its own withdrawal, because deleting it '
          'destroys the evidence that the collection was lawful',
      () =>
          HabotConsentRetention.clauses.first.question.contains('withdrawn') &&
          HabotConsentRetention.withdrawalNote.contains('opposites'),
    );

    gate(
      'GEN-04902-G4',
      'A drawn signature identifies nobody.',
      'The identity-verification clause is left open with the honest reason: '
          'a drawn mark is a record of assent bound to a session and a '
          'timestamp, and calling it identity verification would be a claim '
          'nothing here supports',
      () =>
          HabotConsentRetention.signatureNote.contains('identifies nobody') &&
          HabotConsentRetention.openClauses.any(
            (HabotConsentClause c) => c.question.contains('signs'),
          ),
    );

    gate(
      'GEN-04902-G5',
      'A decision record with an invented owner is one nobody checks.',
      'No owner is named for a group that cannot be convened from here, and '
          'no retention duration is invented either -- the absence is left '
          'visible so the first person who needs the figure has to get it',
      () =>
          HabotConsentRetention.openClauses.any(
            (HabotConsentClause c) => c.question.contains('owns this '
                'decision'),
          ) &&
          HabotConsentRetention.noRetentionDurationIsDeclaredHere &&
          HabotConsentRetention.noDurationNote.contains('has to go and get '
              'it'),
    );
  });

  group('GEN-04902 :: the metric that measures a meeting', () {
    gate(
      'GEN-04902-G6',
      'Metric: Decision Governance Cycle Time.',
      'The cycle time is null rather than a figure somebody invented, and the '
          'reason -- nothing was convened, so nothing can be timed -- is the '
          'same position Step 249 took about code coverage',
      () =>
          HabotConsentRetention.hoursToDecision == null &&
          HabotConsentRetention.theCycleTimeIsUnmeasurableHere,
    );

    gate(
      'GEN-04902-G7',
      'Floor "<= 96 hours", optimal "24-48 hours", and a hole between.',
      'A decision taken in an hour lands in Acceptable while one taken in '
          'thirty lands in Fast, so the band rewards taking longer -- '
          'recorded rather than smoothed, like Step 248\'s dwell band',
      () =>
          HabotConsentRetention.theBandRewardsTakingLonger &&
          HabotConsentRetention.bandFor(1) == 'Acceptable' &&
          HabotConsentRetention.bandFor(30) == 'Fast' &&
          HabotConsentRetention.bandFor(120) == 'Delayed' &&
          HabotConsentRetention.bandNote.contains('hole in it'),
    );

    gate(
      'GEN-04902-G8',
      'Output: Fast / Acceptable / Delayed -- none of which applies.',
      'All twelve declared checks hold and the step reports Partial: the '
          'decision record the meeting would have been for is produced, and '
          'the cycle time is not',
      () =>
          HabotConsentRetention.checks.length == 12 &&
          HabotConsentRetention.checks.values.every((bool b) => b) &&
          HabotConsentRetention.qualitativeOutput == 'Partial' &&
          HabotConsentRetention.partialNote.contains('Step 235') &&
          HabotConsentRetention.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String settled = '${HabotConsentRetention.settledClauses.length}';
    final String open = '${HabotConsentRetention.openClauses.length}';
    final String share =
        HabotConsentRetention.shareSettled.toStringAsFixed(2);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04902',
        atomicStepReferenceId: 'GEN-04902',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Convene the Consent & Privacy Governance decision group '
            'and finalize the required pre-setup decision: Establish legal '
            'consent retention rules and identity verification standards for '
            'digital signatures."',
        implementationOrder: 270,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotConsentRetention / HabotConsentClause',
          'Component Properties':
              '${HabotConsentRetention.clauses.length} clauses -- $settled '
              'settled with positions and reasons, $open left open with what '
              'each needs and who would have to give it; share settled '
              '$share; no retention duration and no owner invented',
          'Completion Status': 'Derived from gate outcomes -- step reports '
              'Partial',
          'Data Quality Note':
              'FINDING: ${HabotConsentRetention.withdrawalNote} '
              'SIGNATURE: ${HabotConsentRetention.signatureNote} '
              'PARTIAL: ${HabotConsentRetention.partialNote} '
              'BAND: ${HabotConsentRetention.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Decision Governance Cycle Time (Time-to-Decision)',
            observed:
                'NOT MEASURABLE HERE. The band times the interval between '
                'convening a group and ratifying its decision; no build host '
                'can convene one and none can time one, so the figure is '
                'null rather than invented. The band also has a hole in it: '
                'an hour reads as Acceptable and thirty hours as Fast.',
            floor: '<= 96 hours from convening to ratified decision',
            optimal: '24-48 hours',
            ceiling: '> 96 hours (decision considered stale)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Clauses settled without an authority',
            observed:
                '$settled of ${HabotConsentRetention.clauses.length}. The '
                'other $open need a retention schedule, an identity standard '
                'and an owner -- each a decision with a cost, and none '
                'available from a build host.',
            floor: 'stated',
            optimal: 'stated',
            ceiling: 'stated',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/preferences/consent_retention.dart',
        ],
      ),
    );
  });
}
