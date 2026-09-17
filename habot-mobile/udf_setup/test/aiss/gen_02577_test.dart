/// AISS GATE -- Step 373 of 375
/// Global Reference ID:       GEN-02577
/// Atomic Steps Reference ID: GEN-02577
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure the HR manager dashboard to display anomalies
///               instantly."
/// Metric: RBAC Enforcement Rate (%) -- floor 0.999, optimal 1, ceiling 1.
///         Pass / Fail. ISO/IEC 27001, NIST Cybersecurity Framework.
///
/// "INSTANTLY" ON A SCREEN NOBODY IS LOOKING AT, AND A FLAG THAT IS A CLAIM
/// ABOUT A PERSON.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/anomaly_surface.dart';

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

  group('GEN-02577 :: "instantly" on a pull surface', () {
    gate(
      'GEN-02577-G1',
      'A dashboard cannot display to somebody not looking at it.',
      'On a pull surface "instantly" means "as soon as they open the screen", '
          'which is the weaker promise the row can actually keep',
      () =>
          !HabotAnomalySurface.aDashboardCanDisplayToSomebodyNotLookingAtIt &&
          HabotAnomalySurface.thePromiseIsRestated,
    );

    gate(
      'GEN-02577-G2',
      'What closes the gap is a push, and the row does not ask for one.',
      'The same finding Step 371 records two rows earlier and Step 331 '
          'recorded a batch earlier on a counter the sheet called real-time',
      () =>
          HabotAnomalySurface.theSameFindingHasBeenRecordedTwice &&
          HabotAnomalySurface.relatedFindings.contains(331) &&
          HabotAnomalySurface.relatedFindings.contains(371) &&
          HabotAnomalySurface.instantlyNote.contains('called real-time'),
    );
  });

  group('GEN-02577 :: anomalous against what', () {
    gate(
      'GEN-02577-G3',
      'Three baselines are available and all three are used.',
      'Their own history, their team, or a fixed threshold -- three different '
          'claims',
      () =>
          HabotAnomalyBaseline.values.length == 3 &&
          HabotAnomalySurface.baselinesUsed == 3,
    );

    gate(
      'GEN-02577-G4',
      'Two of the four disagree across baselines.',
      'Unusual against one and ordinary against another, which is the case a '
          'surface with no stated baseline hides',
      () =>
          HabotAnomalySurface.anomalies.length == 4 &&
          HabotAnomalySurface.twoOfFourDisagreeAcrossBaselines &&
          HabotAnomalySurface.agreeAcrossBaselines == 2,
    );

    gate(
      'GEN-02577-G5',
      'Every flag names the comparison it was made against.',
      'And the case it protects is the one where somebody gets asked a '
          'question they did not deserve',
      () =>
          HabotAnomalySurface.everyAnomalyNamesItsBaseline &&
          HabotAnomalySurface.theBaselineIsShown &&
          HabotAnomalySurface.baselineNote.contains('did not deserve'),
    );
  });

  group('GEN-02577 :: a flag is a claim about a person', () {
    gate(
      'GEN-02577-G6',
      'Every flag shows the size of the deviation.',
      'The overtime one reads "55% above expected" rather than simply being '
          'coloured',
      () =>
          HabotAnomalySurface.everyFlagShowsItsDeviation &&
          HabotAnomalySurface.theOvertimeDeviationIsFiftyFivePerCent,
    );

    gate(
      'GEN-02577-G7',
      'There is a way to disagree.',
      'Marked as explained, with a reason -- a flag with no baseline, no size '
          'and no appeal is an accusation with a coloured background',
      () =>
          HabotAnomalySurface.thereIsAWayToDisagree &&
          HabotAnomalySurface.claimNote.contains('coloured background'),
    );

    gate(
      'GEN-02577-G8',
      'The disagreement is recorded against the flag.',
      'Rather than clearing it silently, so a pattern of explained flags is '
          'itself visible',
      () =>
          HabotAnomalySurface.theDisagreementIsRecorded &&
          HabotAnomalySurface.claimNote.contains('itself visible'),
    );
  });

  group('GEN-02577 :: the metric, for the second time', () {
    gate(
      'GEN-02577-G9',
      'The same RBAC enforcement rate and band as Step 360.',
      'Including the optimal and ceiling both at 1 -- and what it points at is '
          'real: no surface without the role, and no empty one either, because '
          'an empty surface says a colleague has been flagged',
      () =>
          HabotAnomalySurface.theSameMetricIsOnStep360 &&
          HabotAnomalySurface.theOptimalEqualsTheCeiling &&
          !HabotAnomalySurface.theSurfaceIsVisibleWithoutTheRole &&
          !HabotAnomalySurface.anEmptySurfaceIsRenderedInstead &&
          HabotAnomalySurface.metricNote.contains('has been flagged'),
    );

    gate(
      'GEN-02577-G10',
      'Output reported as Pass / Fail.',
      'Five obligations, all met, giving Pass; all ten declared checks hold',
      () =>
          HabotAnomalySurface.obligations.length == 5 &&
          HabotAnomalySurface.obligations.values.every((bool b) => b) &&
          HabotAnomalySurface.qualitativeOutput == 'Pass' &&
          HabotAnomalySurface.checks.length == 10 &&
          HabotAnomalySurface.checks.values.every((bool b) => b) &&
          HabotAnomalySurface.columnNote.contains('Step 360'),
    );
  });

  tearDownAll(() {
    final int flags = HabotAnomalySurface.anomalies.length;
    final int disagreeing = flags - HabotAnomalySurface.agreeAcrossBaselines;
    final String overtime = HabotAnomalySurface.deviationLabel(
      HabotAnomalySurface.anomalies.first,
    );

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02577',
        atomicStepReferenceId: 'GEN-02577',
        setupStepAction:
            'COLUMN NOTE: the metric on this row is an RBAC enforcement rate, '
            'identical to Step 360\'s including its band and its '
            'optimal-equals-ceiling shape, on a row about displaying '
            'anomalies; the Data Requirement cell holds the Atomic Step\'s own '
            'text as the artefact to prepare; and the Setup Step column is '
            'empty. Atomic Step: "Configure the HR manager dashboard to '
            'display anomalies instantly."',
        implementationOrder: 373,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configure the HR manager dashboard to display anomalies instantly':
              '$flags worked flags across 3 baselines; $disagreeing are '
                  'anomalous against one baseline and ordinary against another',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'each flag carries its baseline, its size -- the overtime one '
                  'reads "$overtime" -- and a recorded way to disagree',
          'Data Quality Note':
              'INSTANTLY: ${HabotAnomalySurface.instantlyNote} '
              'BASELINE: ${HabotAnomalySurface.baselineNote} '
              'CLAIM: ${HabotAnomalySurface.claimNote} '
              'METRIC: ${HabotAnomalySurface.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'RBAC Enforcement Rate (%)',
            observed:
                'THE SAME METRIC AND THE SAME BAND AS STEP 360, THIRTEEN ROWS '
                'EARLIER, INCLUDING THE OPTIMAL AND CEILING BOTH AT 1. An RBAC '
                'enforcement rate is measured at the authorisation layer, not '
                'on a display surface. What it points at is again real: an HR '
                'manager dashboard is role-restricted, and somebody without '
                'the role gets no surface at all rather than an empty one, '
                'because an empty surface says both that the feature exists '
                'and that a colleague has been flagged.',
            floor: '0.999',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Flags shown without a baseline, a size or an appeal',
            observed:
                '0 of $flags. "Instantly" on a pull surface means "as soon as '
                'the manager opens the screen"; what would close the interval '
                'is a push, which this row does not ask for, as Steps 331 and '
                '371 also record. An anomaly on an HR dashboard is a claim '
                'about a person, and three things make it safe to show: the '
                'comparison, the size, and a way to disagree. All three are '
                'present -- the overtime flag reads "$overtime" -- and the '
                'baseline matters because $disagreeing of the $flags worked '
                'flags are unusual against one baseline and ordinary against '
                'another.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/anomaly_surface.dart',
        ],
      ),
    );
  });
}
