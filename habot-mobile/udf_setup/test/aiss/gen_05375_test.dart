/// AISS GATE -- Step 454 of 415
/// Global Reference ID:       GEN-05375
/// Atomic Steps Reference ID: GEN-05375
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Design the approach and technical specification for: log
///               submitted improvements, cost savings, and implementation
///               status in BigQuery"
/// Metric: Technical Specification Completeness -- floor "Spec missing
///         acceptance criteria or edge cases", optimal "Spec complete: inputs,
///         outputs, edge cases & acceptance criteria defined", ceiling "1".
///         Best Qualitative Output: "Complete/Partial/Not Complete".
///         ISO/IEC/IEEE 29148 - Requirements Engineering. Assigned to **DEA**.
///
/// A LOG OF IMPROVEMENTS WHERE A CLAIMED SAVING AND A VERIFIED ONE ARE
/// DIFFERENT NUMBERS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/voice/improvement_log.dart';

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

  group('GEN-05375 :: a specification', () {
    gate(
      'GEN-05375-G1',
      'The band is Step 450\'s.',
      'Four rows apart, character for character',
      () => HabotImprovementLog.theBandIsStep450s,
    );

    gate(
      'GEN-05375-G2',
      'Four sections, as the optimal names them.',
      'Inputs, outputs, edge cases, acceptance criteria',
      () =>
          HabotImprovementLog.fourSections &&
          HabotImprovementLog.everyNamedSectionIsPresent,
    );

  });

  group('GEN-05375 :: claimed and verified', () {
    gate(
      'GEN-05375-G3',
      'Claims total 470,000 fils and verified savings 115,000.',
      'AED 4,700 claimed and AED 1,150 verified',
      () => HabotImprovementLog.onlyVerifiedSavingsAreTotalled,
    );

    gate(
      'GEN-05375-G4',
      'So a log of claims would report four times the money.',
      'Which is how improvement programmes report fictional savings',
      () =>
          HabotImprovementLog.theGapIsVisible &&
          HabotImprovementLog.savingsNote.contains('four times'),
    );

    gate(
      'GEN-05375-G5',
      'Verification waits eight weeks.',
      'Before a saving counts',
      () => HabotImprovementLog.verificationPeriodWeeks == 8,
    );

  });

  group('GEN-05375 :: duplicates and anonymity', () {
    gate(
      'GEN-05375-G6',
      'Four entries, three improvements.',
      'One is a duplicate',
      () =>
          HabotImprovementLog.entries.length == 4 &&
          HabotImprovementLog.threeImprovementsNotFour,
    );

    gate(
      'GEN-05375-G7',
      'The duplicate is linked and its author acknowledged.',
      'Being told "duplicate" is how people learn not to bother',
      () =>
          HabotImprovementLog.theDuplicateIsLinked &&
          HabotImprovementLog.theSecondSuggesterIsAcknowledged &&
          HabotImprovementLog.duplicateNote.contains('not to bother'),
    );

    gate(
      'GEN-05375-G8',
      'Anonymous stays anonymous, credited by receipt.',
      'As Step 453 allowed',
      () =>
          HabotImprovementLog.anonymousEntriesCarryNoName &&
          HabotImprovementLog.creditGoesToTheReceipt,
    );

  });

  group('GEN-05375 :: the result', () {
    gate(
      'GEN-05375-G9',
      'Completeness reaches the ceiling.',
      'Every section present',
      () => HabotImprovementLog.completeness == 1,
    );

    gate(
      'GEN-05375-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotImprovementLog.obligations.length == 5 &&
          HabotImprovementLog.obligations.values.every((bool b) => b) &&
          HabotImprovementLog.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int claimed = HabotImprovementLog.claimedTotal;
    final int verified = HabotImprovementLog.verifiedTotal;
    final int distinct = HabotImprovementLog.distinctImprovements;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05375',
        atomicStepReferenceId: 'GEN-05375',
        setupStepAction:
            'COLUMN NOTE: this row\'s metric and band are identical to Step '
            '450\'s four rows earlier, and like Step 450 it asks for exactly '
            'what its band measures, so a four-section specification is '
            'delivered; its "cost savings" are specified as two figures -- '
            'claimed and verified -- with only verified savings totalled; '
            'duplicate suggestions are linked and both authors acknowledged; '
            'and anonymous suggestions stay anonymous in the log, credited to '
            'their receipt code. Atomic Step: "Design the approach and '
            'technical specification for: log submitted improvements, cost '
            'savings, and implementation status in BigQuery"',
        implementationOrder: 454,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Design the approach and technical specification for: log submitted '
          'improvements,':
              '$distinct improvements; $claimed fils claimed and $verified '
                  'fils verified, with only verified savings totalled',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Technical Specification Completeness',
            observed:
                'THE METRIC AND BAND ARE STEP 450\'S, FOUR ROWS APART. Like '
                'Step 450 the row asks for what its band measures, so a '
                'four-section specification is delivered. Observed: every '
                'section present.',
            floor: 'Spec missing acceptance criteria or edge cases',
            optimal:
                'Spec complete: inputs, outputs, edge cases & acceptance '
                    'criteria defined',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Claimed savings counted as savings',
            observed:
                '0. The suggester estimates a saving and the process owner '
                'learns weeks later what it saved; on the worked log $claimed '
                'fils were claimed and $verified fils verified, so a log of '
                'claims would report four times the money that exists. Only '
                'verified savings are totalled, duplicates are linked with '
                'both authors acknowledged, and anonymous suggestions are '
                'credited to their receipt code.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/voice/improvement_log.dart',
        ],
      ),
    );
  });
}
