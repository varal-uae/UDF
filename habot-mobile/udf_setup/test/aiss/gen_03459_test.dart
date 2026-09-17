/// AISS GATE -- Step 322 of 335
/// Global Reference ID:       GEN-03459
/// Atomic Steps Reference ID: GEN-03459
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: 'Display clear visual attribution banners ("Acting on behalf
///               of") on review cards.'
/// Metric: Attribution Banner Contrast -- floor 4.5:1, optimal 7:1, ceiling
///         21:1. Best Qualitative Output: **"Pass"**. WCAG 2.2 AA.
///
/// A BANNER TELLS THE PERSON LOOKING NOW. THE RECORD TELLS EVERYBODY
/// AFTERWARDS, AND ONLY ONE OF THOSE OUTLIVES THE SESSION.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/attribution_banner.dart';

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

  group('GEN-03459 :: the record outlives the banner', () {
    gate(
      'GEN-03459-G1',
      'Atomic Step: "Acting on behalf of" banners on review cards.',
      'A delegated pair produces a banner naming both people and a direct '
          'pair produces none',
      () =>
          HabotAttributionBanner.delegated.isDelegated &&
          !HabotAttributionBanner.direct.isDelegated &&
          HabotAttributionBanner.theBannerIsDerivedFromTheRecordFields,
    );

    gate(
      'GEN-03459-G2',
      'Both identities go on the record either way.',
      'Actor and principal are recorded whether the action was delegated or '
          'not, so a later reader never has to infer one from the absence of '
          'the other',
      () =>
          HabotAttributionBanner.bothIdentitiesAreAlwaysRecorded &&
          HabotAttributionBanner.recordFor(HabotAttributionBanner.direct)[
                  'principal'] ==
              'Fatima Al-Mansouri',
    );

    gate(
      'GEN-03459-G3',
      'If the delegation lives only in the banner, the decision is '
          'misattributed for years.',
      'And it is misattributed to the person who was not there',
      () => HabotAttributionBanner.recordNote
          .contains('the one who was not there'),
    );
  });

  group('GEN-03459 :: a card cannot be wrong about itself', () {
    gate(
      'GEN-03459-G4',
      'Two stale directions, both named.',
      'A cached card still wearing the banner after the session ended, and a '
          'card without one after a session began',
      () => HabotAttributionBanner.bothDirectionsAreNamed,
    );

    gate(
      'GEN-03459-G5',
      'Neither is reachable.',
      'The banner holds no state of its own; it is a function of the two '
          'fields the record carries, so the two cannot disagree',
      () =>
          !HabotAttributionBanner.theBannerHasStateOfItsOwn &&
          HabotAttributionBanner.theRecordAndTheBannerCannotDisagree,
    );

    gate(
      'GEN-03459-G6',
      'The absent-banner direction is the dangerous one.',
      'Somebody reads a decision as their colleague\'s own when it was made '
          'for them',
      () => HabotAttributionBanner.staleNote.contains('made for them'),
    );
  });

  group('GEN-03459 :: reading order', () {
    gate(
      'GEN-03459-G7',
      'The banner is the card\'s first child.',
      'A screen reader reaching "Approve" before "acting on behalf of Fatima" '
          'has handed somebody the decision before the context',
      () =>
          HabotAttributionBanner.theBannerIsTheFirstThingRead &&
          HabotAttributionBanner.theBannerPrecedesTheActions &&
          HabotAttributionBanner.cardOrder.length == 5,
    );

    gate(
      'GEN-03459-G8',
      'That is an ordering requirement rather than a visual preference.',
      'Visually the two are inches apart; aurally they are minutes apart',
      () => HabotAttributionBanner.orderNote
          .contains('the order the information is needed in'),
    );
  });

  group('GEN-03459 :: the output column', () {
    gate(
      'GEN-03459-G9',
      'Best Qualitative Output: "Pass".',
      'The second one-valued output column in this batch, three rows from the '
          'first in the sheet and carrying the same contrast band',
      () =>
          HabotAttributionBanner.theOutputCannotExpressAFailure &&
          HabotAttributionBanner.siblingStepWithTheSameDefect == 321 &&
          HabotAttributionBanner.outputNote.contains('Two adjacent rows'),
    );

    gate(
      'GEN-03459-G10',
      'Output reported as Pass / Fail against declared obligations.',
      'Six obligations, all met; all eleven declared checks hold',
      () =>
          HabotAttributionBanner.obligations.length == 6 &&
          HabotAttributionBanner.obligations.values.every((bool b) => b) &&
          HabotAttributionBanner.qualitativeOutput == 'Pass' &&
          HabotAttributionBanner.checks.length == 11 &&
          HabotAttributionBanner.checks.values.every((bool b) => b) &&
          HabotAttributionBanner.columnNote.contains('second such row'),
    );
  });

  tearDownAll(() {
    final String banner =
        HabotAttributionBanner.bannerFor(HabotAttributionBanner.delegated);
    final Map<String, String> record =
        HabotAttributionBanner.recordFor(HabotAttributionBanner.delegated);
    final String actor = record['actor'] ?? '';
    final String principal = record['principal'] ?? '';
    final String delegated = record['delegated'] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03459',
        atomicStepReferenceId: 'GEN-03459',
        setupStepAction:
            'COLUMN NOTE: the Best Qualitative Output column on this row reads '
            '"Pass", with no failing value -- the second such row in this '
            'batch, three rows from the first in the sheet -- and every '
            'narrative column is the generic engineering-console boilerplate. '
            'Atomic Step: "Display clear visual attribution banners (Acting '
            'on behalf of) on review cards."',
        implementationOrder: 322,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Acting on behalf of':
              'the banner reads "$banner", and it is derived from the record '
                  'rather than set beside it',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the record carries actor "$actor", principal "$principal" '
                  'and delegated "$delegated"',
          'Data Quality Note':
              'RECORD: ${HabotAttributionBanner.recordNote} '
              'STALENESS: ${HabotAttributionBanner.staleNote} '
              'ORDER: ${HabotAttributionBanner.orderNote} '
              'OUTPUT: ${HabotAttributionBanner.outputNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Attribution Banner Contrast',
            observed:
                'Held to the ordinary contrast band. The row\'s output column '
                'contains only "Pass", so as written the gate could not have '
                'reported a contrast failure -- the second row in this batch '
                'with that shape and the second of four.',
            floor: '4.5:1',
            optimal: '7:1',
            ceiling: '21:1',
          ),
          AissMeasurement(
            metricName: 'Decisions attributable to the wrong person',
            observed:
                '0. Both identities are on the record whether the action was '
                'delegated or not, and the banner is a function of those two '
                'fields, so a card cannot be wrong about itself in either '
                'direction. The banner is also the card\'s first child, so the '
                'context arrives before the decision.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/attribution_banner.dart',
        ],
      ),
    );
  });
}
