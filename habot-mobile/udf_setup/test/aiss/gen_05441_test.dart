/// AISS GATE -- Step 235 of 235
/// Global Reference ID:       GEN-05441
/// Atomic Steps Reference ID: GEN-05441
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Make and document the required upfront decision: establish
///               hard performance SLAs (FCP <= 1.2s, TTI <= 2.0s, API latency
///               <= 200ms)."
/// Metric: Decision Documentation Completeness -- Floor "Decision undocumented
///         or verbal only", Optimal "Decision documented with rationale & owner
///         sign-off", Ceiling 1. Complete/Partial/Not Complete.
///
/// TWO OF THE THREE SLAs ALREADY EXIST, TO THE MILLISECOND. They were declared
/// at Step 165 and never written down as a decision. REPORTS PARTIAL: a
/// sign-off is a person, and one cannot be obtained from a build host.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/performance/performance_sla.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completeness = 0;

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

  group('GEN-05441 :: figures that were already in force', () {
    gate(
      'GEN-05441-G1',
      'Atomic Step: "ESTABLISH hard performance SLAs (FCP <= 1.2s, TTI <= '
          '2.0s)."',
      'The cold-start budget is 1200ms and the interactive budget is 2000ms, '
          'both declared at Step 165 -- so two of the three figures the row '
          'asks to establish have been in force for seventy steps and what was '
          'missing was the record, the same shape as Step 180',
      () =>
          HabotPerformanceSla.fcpMatchesColdStartBudget &&
          HabotPerformanceSla.ttiMatchesInteractiveBudget &&
          HabotPerformanceSla.preExistingTokens.length == 2 &&
          HabotPerformanceSla.slaNamed('FCP <= 1.2s').budget ==
              HabotMotion.coldStartBudget &&
          HabotPerformanceSla.slaNamed('TTI <= 2.0s').budget ==
              HabotMotion.interactiveOn3g &&
          HabotPerformanceSla.alreadyDeclaredNote
              .contains('missing was the record'),
    );

    gate(
      'GEN-05441-G2',
      '"API latency <= 200ms" is the one figure this repository did not hold.',
      'The API budget is introduced here as a declared token rather than as a '
          'literal, so all three SLAs read a token and none of them holds a '
          'number of its own',
      () =>
          HabotPerformanceSla.slaNamed('API latency <= 200ms').budget ==
              HabotMotion.apiLatencySla &&
          HabotMotion.apiLatencySla.inMilliseconds == 200 &&
          HabotPerformanceSla.tokenBacked.length == 3 &&
          HabotPerformanceSla.slas
              .every((HabotSla s) => s.readsAnExistingToken),
    );

    gate(
      'GEN-05441-G3',
      '"FCP and TTI are web vitals and this is not a web application."',
      'Each of the three carries a translated name distinct from the row\'s '
          'wording -- first frame rendered, interactive, server response at '
          'the 95th percentile -- so nobody goes looking for a Lighthouse '
          'number that will never exist',
      () =>
          HabotPerformanceSla.slas.every(
            (HabotSla s) => s.translatedName != s.rowName,
          ) &&
          HabotPerformanceSla.slaNamed('FCP <= 1.2s').translatedName
              .contains('First frame rendered') &&
          HabotPerformanceSla.webVitalsNote.contains('has no FCP') &&
          HabotPerformanceSla.webVitalsNote.contains('Lighthouse'),
    );

    gate(
      'GEN-05441-G4',
      'A budget with no stated conditions is a number somebody will measure on '
          'a different phone.',
      'Every figure names the conditions it holds under, and the API one goes '
          'further: it is a SERVER property the client can measure and cannot '
          'meet, so the obligation recorded on this side is to report honestly '
          'rather than to comply',
      () =>
          HabotPerformanceSla.slas.every(
            (HabotSla s) => s.conditions.length > 40,
          ) &&
          HabotPerformanceSla.slaNamed('API latency <= 200ms')
              .rationale
              .contains('SERVER') &&
          HabotPerformanceSla.slaNamed('API latency <= 200ms')
              .conditions
              .contains('95th percentile') &&
          HabotPerformanceSla.slaNamed('FCP <= 1.2s')
              .conditions
              .contains('floor device'),
    );
  });

  group('GEN-05441 :: what the record cannot supply', () {
    gate(
      'GEN-05441-G5',
      'An SLA with no consequence is a target.',
      'A breach on the floor device blocks the release, and the row that acts '
          'on these figures -- GEN-05452, the performance alert subroutine -- '
          'is named and is NOT in this batch, so the record exists and the '
          'alerting does not',
      () =>
          HabotPerformanceSla.breachConsequence
              .contains('blocks the release') &&
          HabotPerformanceSla.successorRow == 'GEN-05452' &&
          HabotPerformanceSla.successorNote
              .contains('the record exists and the alerting does not'),
    );

    gate(
      'GEN-05441-G6',
      'Metric optimal: "Decision documented with rationale & OWNER SIGN-OFF."',
      'Two of the three criteria hold -- the decision is documented and every '
          'figure carries its rationale and conditions -- and the third does '
          'not, because no owner is recorded on any of the three; the absent '
          'sign-off is named rather than assumed',
      () {
        completeness = HabotPerformanceSla.documentationCompleteness;
        return HabotPerformanceSla.documentationCriteria.length == 3 &&
            HabotPerformanceSla.documentationCriteria[
                'the decision is documented rather than verbal']! &&
            HabotPerformanceSla.documentationCriteria[
                'each figure carries a rationale and its conditions']! &&
            !HabotPerformanceSla.documentationCriteria['owner sign-off']! &&
            HabotPerformanceSla.slas
                .every((HabotSla s) => !s.isSignedOff) &&
            (completeness - 2 / 3).abs() < 1e-9;
      },
    );

    gate(
      'GEN-05441-G7',
      'Metric: Decision Documentation Completeness -- ceiling 1. '
          'Complete/Partial/Not Complete.',
      'All twelve checks hold and the step still reports PARTIAL, because a '
          'sign-off is a person and one cannot be obtained from a build host '
          '-- the gap is reported rather than the criterion quietly redefined '
          'into something a test could satisfy',
      () =>
          HabotPerformanceSla.checks.length == 12 &&
          HabotPerformanceSla.checks.values.every((bool b) => b) &&
          HabotPerformanceSla.qualitativeOutput == 'Partial' &&
          HabotPerformanceSla.signOffNote.contains('cannot be') &&
          HabotPerformanceSla.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05441',
        atomicStepReferenceId: 'GEN-05441',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Make and document the required upfront decision: establish '
            'hard performance SLAs (FCP <= 1.2s, TTI <= 2.0s, API latency <= '
            '200ms)."',
        implementationOrder: 235,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPerformanceSla / HabotSla',
          'Component Properties':
              '${HabotPerformanceSla.slas.length} service-level objectives, '
              'each reading a declared motion token, each with a translated '
              'name, a rationale and the conditions it holds under; '
              '${HabotPerformanceSla.preExistingTokens.length} of the tokens '
              'existed before this step; breach consequence declared; '
              'successor row ${HabotPerformanceSla.successorRow} named; '
              'owners recorded: 0',
          'Completion Status': 'Partial -- see Data Quality Note',
          'Data Quality Note':
              'FINDING: ${HabotPerformanceSla.alreadyDeclaredNote} SECOND: '
              'FCP and TTI are web vitals measured by a browser. A Flutter '
              'application has no FCP -- there is no document and no paint '
              'event to observe. The translations are exact rather than '
              'approximate: FCP becomes first frame rendered, TTI becomes '
              'interactive, and the API figure becomes a server response time '
              'at the 95th percentile. They are written down so nobody goes '
              'looking for a Lighthouse number that will never exist. THIRD: '
              'the API budget is the only one of the three this repository did '
              'not already hold, and it is a SERVER property -- the client can '
              'measure it and cannot meet it, so the obligation recorded on '
              'this side is to report honestly rather than to comply. FOURTH: '
              'an SLA with no consequence is a target, so the consequence is '
              'declared -- a breach on the floor device blocks the release -- '
              'and GEN-05452, the row that actually alerts on these figures, '
              'is named and is not in this batch. The record exists and the '
              'alerting does not. PARTIAL: '
              '${HabotPerformanceSla.signOffNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Decision Documentation Completeness',
            observed:
                '${completeness.toStringAsFixed(2)} -- two of '
                '${HabotPerformanceSla.documentationCriteria.length} criteria. '
                'The decision is documented and every figure carries its '
                'rationale and conditions; no owner has signed, and no owner '
                'can be obtained from a build host. Reported Partial rather '
                'than rounded to Complete.',
            floor: 'Decision undocumented or verbal only',
            optimal: 'Decision documented with rationale & owner sign-off',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'SLA figures this step had to invent',
            observed:
                '1 of ${HabotPerformanceSla.slas.length}. '
                '${HabotPerformanceSla.preExistingTokens.length} were already '
                'declared at Step 165 to the millisecond -- '
                '${HabotMotion.coldStartBudget.inMilliseconds}ms and '
                '${HabotMotion.interactiveOn3g.inMilliseconds}ms -- and the '
                'API budget of ${HabotMotion.apiLatencySla.inMilliseconds}ms '
                'is the one addition.',
            floor: '0',
            optimal: '0',
            ceiling: '3',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/performance/performance_sla.dart',
        ],
      ),
    );
  });
}
