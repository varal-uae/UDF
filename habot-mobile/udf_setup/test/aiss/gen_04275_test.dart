/// AISS GATE -- Step 181 of 195
/// Global Reference ID:       GEN-04275
/// Atomic Steps Reference ID: GEN-04275
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Produce and confirm the expected output: Fully Tokenized
///               Mobile Application Codebase & NPM Token Integration."
/// Metric: Deliverable/Output Verification -- Floor "N/A - Binary Governance
///         Gate", Optimal "100% - Expected Output Produced & Confirmed",
///         Ceiling "N/A - Binary Governance Gate". Pass / Fail.
///
/// **THIS STEP REPORTS FAIL.** The row is a binary governance gate with no
/// partial credit by construction, and three of its eight criteria do not
/// hold: the palette is provisional, the body type face does not match the
/// specification, and NPM integration has no meaning in this ecosystem. The
/// three are recorded as DEFERRED gates with their reasons; the structural
/// five are gated normally.
///
/// A sign-off step that passes because the work leading to it was substantial
/// is not a gate, it is a formality -- and everything after it then rests on a
/// confirmation nobody could have withheld.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tokens/tokenisation_milestone.dart';

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

  /// A criterion the milestone does not meet. Recorded as a reviewable open
  /// item: the runner stays green so a genuine regression is still visible,
  /// and the step still reports Fail.
  void deferredCriterion(String gateId, String criterionId) {
    test('[$gateId] DEFERRED -- $criterionId', () {
      final HabotMilestoneCriterion c = HabotTokenisationMilestone.criteria
          .firstWhere((HabotMilestoneCriterion c) => c.id == criterionId);
      // What CAN be asserted: the criterion is declared, it is genuinely
      // unmet, and it says why.
      expect(c.isMet, isFalse);
      expect(c.blocker, isNotNull);
      expect(c.blocker!.length, greaterThan(60));
      gates.add(
        AissGate(
          id: gateId,
          requirementSource: '${c.owner} -- ${c.statement}',
          description: c.statement,
          passed: false,
          deferred: true,
          detail: c.blocker,
        ),
      );
    });
  }

  group('GEN-04275 :: the structural half, which holds', () {
    gate(
      'GEN-04275-G1',
      'Atomic Step: "Produce and CONFIRM the expected output." A gate is only '
          'worth anything if it can say no.',
      'The milestone is a declared list of decidable criteria, each naming the '
          'step accountable for it, and every criterion that fails carries a '
          'reason -- a red light nobody can act on is not a gate either',
      () =>
          HabotTokenisationMilestone.criteria.length == 8 &&
          HabotTokenisationMilestone.criteria.every(
            (HabotMilestoneCriterion c) =>
                c.id.startsWith('FT-') &&
                c.owner.contains('Step') &&
                c.statement.length > 40,
          ) &&
          HabotTokenisationMilestone.everyFailureExplained &&
          HabotTokenisationMilestone.binaryGateNote.contains('formality'),
    );

    gate(
      'GEN-04275-G2',
      'FT-1 (Step 176): one declaration site per family, every value const.',
      'The token package has a single declaration site per family and costs '
          'nothing at startup',
      () => HabotTokenisationMilestone.criteria
          .firstWhere((HabotMilestoneCriterion c) => c.id == 'FT-1')
          .isMet,
    );

    gate(
      'GEN-04275-G3',
      'FT-2 (Step 177): canonical MD3 names, every departure declared.',
      'Every declared token maps to a conformant MD3 name and every brand '
          'extension is written down',
      () => HabotTokenisationMilestone.criteria
          .firstWhere((HabotMilestoneCriterion c) => c.id == 'FT-2')
          .isMet,
    );

    gate(
      'GEN-04275-G4',
      'FT-3 (Step 178): the token a widget is handed is the token that was '
          'declared.',
      'Parity holds in every scheme the app ships',
      () => HabotTokenisationMilestone.criteria
          .firstWhere((HabotMilestoneCriterion c) => c.id == 'FT-3')
          .isMet,
    );

    gate(
      'GEN-04275-G5',
      'FT-4 (Step 179) and FT-5 (Step 180): the rule set is packaged as data '
          'and untokenised code fails the build before the tests.',
      'Both governance criteria hold, which is what makes "tokenized" a '
          'property of the codebase rather than a habit',
      () {
        final HabotMilestoneCriterion packaged = HabotTokenisationMilestone
            .criteria
            .firstWhere((HabotMilestoneCriterion c) => c.id == 'FT-4');
        final HabotMilestoneCriterion enforced = HabotTokenisationMilestone
            .criteria
            .firstWhere((HabotMilestoneCriterion c) => c.id == 'FT-5');
        return packaged.isMet && enforced.isMet;
      },
    );
  });

  group('GEN-04275 :: what blocks the sign-off', () {
    deferredCriterion('GEN-04275-G6', 'FT-6');
    deferredCriterion('GEN-04275-G7', 'FT-7');
    deferredCriterion('GEN-04275-G8', 'FT-8');
  });

  group('GEN-04275 :: the verdict', () {
    gate(
      'GEN-04275-G9',
      'Metric: Deliverable/Output Verification -- Pass/Fail, with "N/A - '
          'Binary Governance Gate" at both boundaries.',
      'The verdict is Fail, five of eight criteria are met, and the count is '
          'reported for context rather than as a score -- reading '
          'five-eighths as a grade would invent a scale the row deliberately '
          'does not have',
      () =>
          !HabotTokenisationMilestone.isConfirmed &&
          HabotTokenisationMilestone.qualitativeOutput == 'Fail' &&
          HabotTokenisationMilestone.met.length == 5 &&
          HabotTokenisationMilestone.unmet.length == 3 &&
          HabotTokenisationMilestone.progressForContext ==
              '5 of 8 criteria met' &&
          HabotTokenisationMilestone.noPartialCreditNote
              .contains('inventing a scale'),
    );

    gate(
      'GEN-04275-G10',
      '"A red light nobody can act on is not a gate either."',
      'Each of the three blockers names its owning step and gives a reason '
          'specific enough to act on, and they are about CONTENT rather than '
          'structure -- an unapproved palette, a type face that does not match '
          'the spec, and an integration in an ecosystem this app is not built '
          'in',
      () {
        final List<String> blockers = HabotTokenisationMilestone.blockers;
        return blockers.length == 3 &&
            blockers.every((String b) => b.contains('Step')) &&
            blockers.every((String b) => b.length > 120) &&
            blockers.any((String b) => b.contains('PROVISIONAL')) &&
            blockers.any((String b) => b.contains('Inter')) &&
            blockers.any((String b) => b.contains('NPM')) &&
            HabotTokenisationMilestone.structuralVsContentNote
                .contains('CONTENT rather than structure');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04275',
        atomicStepReferenceId: 'GEN-04275',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Produce and confirm the expected output: Fully Tokenized '
            'Mobile Application Codebase & NPM Token Integration."',
        implementationOrder: 181,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTokenisationMilestone',
          'Component Properties':
              '${HabotTokenisationMilestone.criteria.length} declared '
              'criteria, ${HabotTokenisationMilestone.met.length} met and '
              '${HabotTokenisationMilestone.unmet.length} unmet, each naming '
              'the step accountable for it and each failure carrying a reason',
          'Completion Status': 'Fail -- deliberately, see the note',
          'Data Quality Note':
              'THIS STEP REPORTS FAIL AND THAT IS THE CORRECT ANSWER TODAY. '
              'The row is a binary governance gate: no partial credit by '
              'construction, and its floor and ceiling both say so. Three '
              'criteria do not hold -- the palette has been PROVISIONAL since '
              'Step 1, the body type face is Roboto where the specification '
              'asks for Inter (Step 182 declines to swap the name without the '
              'asset), and "NPM Token Integration" has no meaning in this '
              'ecosystem and no network on this host. The five that do hold '
              'are the structural half. A sign-off that passes because the '
              'work leading to it was substantial is a formality, and '
              'everything after it then rests on a confirmation nobody could '
              'have withheld.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Deliverable/Output Verification',
            observed:
                'FAIL. ${HabotTokenisationMilestone.progressForContext}, '
                'reported for context and not as a score. Blockers: FT-6 the '
                'palette is unapproved; FT-7 body typography does not match '
                'the specified family; FT-8 NPM token integration is not '
                'producible in this ecosystem. Each is recorded as a deferred '
                'gate with its reason.',
            floor: 'N/A - Binary Governance Gate',
            optimal: '100% - Expected Output Produced & Confirmed',
            ceiling: 'N/A - Binary Governance Gate',
          ),
          AissMeasurement(
            metricName: 'Structural criteria met',
            observed:
                '5 of 5. One declaration site per family, canonical MD3 names '
                'with declared extensions, declared-equals-delivered parity, a '
                'packaged rule catalogue, and a blocking build intercept '
                'within its exemption budget. The three that fail are about '
                'content rather than structure, which is why they are named '
                'individually rather than reported as one red light.',
            floor: '5',
            optimal: '5',
            ceiling: '5',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/tokenisation_milestone.dart',
        ],
      ),
    );
  });
}
