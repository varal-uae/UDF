/// AISS GATE -- Step 453 of 415
/// Global Reference ID:       GEN-05364
/// Atomic Steps Reference ID: GEN-05364
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Review the step objective: deploy a touch-friendly employee
///               suggestion portal allowing team members to submit zero-cost
///               process improvement (ZII Kaizen) ideas, automatically routing
///               them for fast review and reward"
/// Metric: Requirement/Objective Comprehension Completeness -- floor "Partial
///         understanding; unresolved ambiguities", optimal "Objective fully
///         documented & stakeholder-confirmed", ceiling "1". Best Qualitative
///         Output: "Complete/Partial/Not Complete". BABOK v3 - Requirements
///         Elicitation & Analysis. Assigned to **PDG**.
///
/// A REVIEW OF A SUGGESTION PORTAL'S OBJECTIVE, REPORTED PARTIAL BECAUSE NOBODY
/// HERE CAN CONFIRM IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/voice/suggestion_portal.dart';

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

  group('GEN-05364 :: four ambiguities', () {
    gate(
      'GEN-05364-G1',
      'Four ambiguities, each with a proposal and a confirmer.',
      'ZII, fast review, routing and reward',
      () =>
          HabotSuggestionPortal.fourAmbiguities &&
          HabotSuggestionPortal.everyAmbiguityHasAProposalAndAConfirmer,
    );

    gate(
      'GEN-05364-G2',
      'ZII is never expanded.',
      'Zero-investment improvement, probably; a guess is not a definition',
      () =>
          HabotSuggestionPortal.ambiguities.first.phrase == 'ZII' &&
          HabotSuggestionPortal.ambiguities.first.proposal.contains('Zero'),
    );

    gate(
      'GEN-05364-G3',
      'And reward is a different decision from Step 442\'s.',
      'Peer thanks is worth nothing; an adopted improvement has not been '
          'decided',
      () =>
          HabotSuggestionPortal.theRewardQuestionIsNotStep442s &&
          HabotSuggestionPortal.ambiguityNote.contains('nobody has taken'),
    );

  });

  group('GEN-05364 :: documented, not confirmed', () {
    gate(
      'GEN-05364-G4',
      'The objective is documented and not confirmed.',
      'There is no stakeholder in this session',
      () =>
          HabotSuggestionPortal.theObjectiveIsDocumented &&
          !HabotSuggestionPortal.aStakeholderHasConfirmed,
    );

    gate(
      'GEN-05364-G5',
      'So no sign-off is claimed.',
      'Complete would claim a confirmation that did not happen',
      () =>
          !HabotSuggestionPortal.aSignOffIsClaimed &&
          HabotSuggestionPortal.partialNote.contains('did not happen'),
    );

  });

  group('GEN-05364 :: closing the loop', () {
    gate(
      'GEN-05364-G6',
      'Four outcomes, a decline carries its reason.',
      'Received, trialled, adopted, declined',
      () =>
          HabotSuggestionPortal.theAuthorSeesEveryOutcome &&
          HabotSuggestionPortal.aDeclineCarriesAReason,
    );

    gate(
      'GEN-05364-G7',
      'Anonymous authors follow theirs by receipt.',
      'A suggestion scheme whose ideas vanish stops getting ideas',
      () =>
          HabotSuggestionPortal.anonymousSuggestionsAreAllowed &&
          HabotSuggestionPortal.anAnonymousAuthorCanFollowByReceipt &&
          HabotSuggestionPortal.loopNote.contains('stop suggesting'),
    );

  });

  group('GEN-05364 :: the band', () {
    gate(
      'GEN-05364-G8',
      'The floor describes the failure.',
      'The third in this batch',
      () => HabotSuggestionPortal.theFloorDescribesTheFailure,
    );

    gate(
      'GEN-05364-G9',
      'Comprehension is half, not whole.',
      'Documented but unconfirmed',
      () => HabotSuggestionPortal.comprehension == 0.5,
    );

    gate(
      'GEN-05364-G10',
      'Five obligations met, and the row reports Partial.',
      'The gates verify the evidence; the band says Partial',
      () =>
          HabotSuggestionPortal.obligations.length == 5 &&
          HabotSuggestionPortal.obligations.values.every((bool b) => b) &&
          HabotSuggestionPortal.qualitativeOutput == 'Partial',
    );
  });

  tearDownAll(() {
    final int open = HabotSuggestionPortal.ambiguities.length;
    final int outcomes = HabotSuggestionOutcome.values.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05364',
        atomicStepReferenceId: 'GEN-05364',
        setupStepAction:
            'COLUMN NOTE: this is a review row whose subject is in the row '
            'itself, so the review documents the objective and its four '
            'unresolved ambiguities -- ZII unexpanded, fast review unnumbered, '
            'routing unaddressed, and reward undefined -- each with a proposal '
            'and a named confirmer; its optimal requires stakeholder '
            'confirmation, which cannot happen in this session, so it reports '
            'Partial rather than claim a sign-off; its floor describes the '
            'failure, the third in this batch; and its ceiling is a bare 1 '
            'beneath two prose cells. Atomic Step: "Review the step objective: '
            'deploy a touch-friendly employee suggestion portal allowing team '
            'members to submit zero-cost process improvement (ZII Kaizen) '
            'ideas, automatically routing them for fast review and reward"',
        implementationOrder: 453,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Review the step objective: deploy a touch-friendly employee '
          'suggestion portal':
              'the objective documented with $open unresolved ambiguities, '
                  'each with a proposal and a confirmer; not '
                  'stakeholder-confirmed',
          'Completion Status': 'Partial',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirement/Objective Comprehension Completeness',
            observed:
                'PARTIAL. The optimal is "objective fully documented and '
                'stakeholder-confirmed"; the documenting is done and the '
                'confirming cannot be, because there is no stakeholder in this '
                'session. Reporting Complete would claim a sign-off that did '
                'not happen. $open ambiguities are recorded -- ZII unexpanded, '
                'fast review unnumbered, routing unaddressed, reward '
                'undefined. The floor describes the failure, the third in this '
                'batch.',
            floor: 'Partial understanding; unresolved ambiguities',
            optimal: 'Objective fully documented & stakeholder-confirmed',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Suggestion outcomes hidden from their author',
            observed:
                '0 of $outcomes. A suggestion scheme whose ideas disappear '
                'teaches people to stop suggesting within a quarter, so the '
                'author sees every outcome, a decline carries its reason, and '
                'somebody who suggested anonymously follows theirs by a '
                'receipt code.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/voice/suggestion_portal.dart',
        ],
      ),
    );
  });
}
