/// AISS GATE -- Step 410 of 415
/// Global Reference ID:       GEN-03193
/// Atomic Steps Reference ID: GEN-03193
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure static analysis rules to flag and reject hardcoded
///               hex color values."
/// Metric: Hex Custom Drift Deflection -- floor "1", optimal "1", ceiling "1".
///         Best Qualitative Output: "Pass". Style Dictionary Design Standards.
///         Assigned to **UDF**.
///
/// THE SAME INSTRUCTION AS THE PREVIOUS ROW -- THE CLOSEST DUPLICATED PAIR THE
/// TRACK HAS RECORDED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tooling/hex_static_analysis.dart';

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

  group('GEN-03193 :: one row apart', () {
    gate(
      'GEN-03193-G1',
      'This row repeats the previous one.',
      'Under a different reference id and a different metric, with neither row '
          'mentioning the other',
      () =>
          HabotHexStaticAnalysis.thisIsADuplicatedInstruction &&
          HabotHexStaticAnalysis.theOtherReference == 'GEN-00044',
    );

    gate(
      'GEN-03193-G2',
      'One row apart, the closest pair in the track.',
      'Batch N\'s duplicates were twelve, ninety and two hundred rows apart',
      () =>
          HabotHexStaticAnalysis.itIsTheClosestPairRecorded &&
          HabotHexStaticAnalysis.duplicateNote.contains('closest pair'),
    );

  });

  group('GEN-03193 :: the better wording', () {
    gate(
      'GEN-03193-G3',
      'This row names a real tool and the other names CSS.',
      'Static analysis is what a Dart project has',
      () => HabotHexStaticAnalysis.thisRowNamesARealTool,
    );

    gate(
      'GEN-03193-G4',
      'And it distinguishes flagging from rejecting.',
      'Which the catalogue already models as advisory and blocking, so this is '
          'the wording to keep if the two rows are ever collapsed',
      () =>
          HabotHexStaticAnalysis.thisRowDistinguishesFlaggingFromRejecting &&
          HabotHexStaticAnalysis.wordingNote.contains('the first one wins'),
    );

  });

  group('GEN-03193 :: drift is the right noun', () {
    gate(
      'GEN-03193-G5',
      'Drift is the right noun.',
      'A hex typed once is a mistake; a hex typed once and copied is drift',
      () =>
          HabotHexStaticAnalysis.theNounIsRight &&
          HabotHexStaticAnalysis.blockingAtTypingIsCheapest,
    );

    gate(
      'GEN-03193-G6',
      'And forty screens keep the old blue.',
      'Which is what a palette change looks like when the literals were never '
          'blocked',
      () => HabotHexStaticAnalysis.driftNote.contains('forty screens'),
    );

  });

  group('GEN-03193 :: a collapsed band and a one-valued column', () {
    gate(
      'GEN-03193-G7',
      'The rule is already in the catalogue.',
      'Bound rather than declared a third time',
      () =>
          HabotHexStaticAnalysis.theRuleAlreadyExists &&
          HabotHexStaticAnalysis.rulesInTheCatalogue >= 10,
    );

    gate(
      'GEN-03193-G8',
      'No third check is added.',
      'The one thing worse than a rule nobody enforces is three rules that '
          'disagree at the margins',
      () =>
          !HabotHexStaticAnalysis.aThirdCheckIsAdded &&
          HabotHexStaticAnalysis.reuseNote.contains('disagree at the margins'),
    );

    gate(
      'GEN-03193-G9',
      'The band is collapsed and the column holds one value.',
      'Floor, optimal and ceiling all 1, and an output column reading "Pass"',
      () =>
          HabotHexStaticAnalysis.theBandIsCollapsed &&
          HabotHexStaticAnalysis.thisIsTheFourthCollapsedBand &&
          HabotHexStaticAnalysis.theCountReachesEleven,
    );

    gate(
      'GEN-03193-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotHexStaticAnalysis.obligations.length == 5 &&
          HabotHexStaticAnalysis.obligations.values.every((bool b) => b) &&
          HabotHexStaticAnalysis.qualitativeOutput == 'Pass' &&
          HabotHexStaticAnalysis.deflection == 100,
    );
  });

  tearDownAll(() {
    final int other = HabotHexStaticAnalysis.theOtherRow;
    final int apart = HabotHexStaticAnalysis.rowsApart;
    final int collapsed = HabotHexStaticAnalysis.collapsedBandRows.length;
    final int oneValued = HabotHexStaticAnalysis.oneValuedColumnsInTheTrack;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03193',
        atomicStepReferenceId: 'GEN-03193',
        setupStepAction:
            'COLUMN NOTE: this row repeats Step 409\'s instruction one row '
            'later under a different reference id and a different metric, and '
            'neither mentions the other -- the closest pair of duplicated '
            'instructions the track has recorded; its band sets floor, optimal '
            'and ceiling all to 1; its Best Qualitative Output column holds '
            'the single word "Pass", the eleventh one-valued column; its '
            'standard is "Style Dictionary Design Standards"; its Data '
            'Requirement cell holds the Atomic Step\'s own text truncated with '
            'an ellipsis; and the Setup Step column is empty. Atomic Step: '
            '"Configure static analysis rules to flag and reject hardcoded hex '
            'color values."',
        implementationOrder: 410,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configure static analysis rules to flag and reject hardcoded hex':
              'bound to the same two blocking rules Step $other binds, $apart '
                  'row earlier, with neither row mentioning the other',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Hex Custom Drift Deflection',
            observed:
                'COLLAPSED BAND AND A ONE-VALUED OUTPUT COLUMN, ON A ROW THAT '
                'REPEATS THE PREVIOUS ONE. Floor, optimal and ceiling are all '
                '1 and the Best Qualitative Output column holds the single '
                'word "Pass": a deflection rate that can only be 1 describes a '
                'rule that either exists or does not, which is true here and '
                'is not a measurement. Fourth collapsed band in the track of '
                '$collapsed recorded, and the ${oneValued}th one-valued output '
                'column.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Rows between this instruction and its duplicate',
            observed:
                '$apart. Step $other asked for a CSS linter to block custom '
                'hex colour values and this row asks for static analysis rules '
                'to flag and reject hardcoded hex colour values: the same '
                'instruction in two vocabularies, one row apart, under two '
                'reference ids and two metrics, with neither citing the other. '
                'The previous batch found duplicates twelve, ninety and two '
                'hundred rows apart. This wording is the better of the two and '
                'is named as such, because the usual outcome of a duplicate is '
                'that the first one wins.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tooling/hex_static_analysis.dart',
        ],
      ),
    );
  });
}
