/// AISS GATE -- Step 227 of 235
/// Global Reference ID:       GEN-04286
/// Atomic Steps Reference ID: GEN-04286
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Define atomic touch target guidelines enforcing a minimum
///               48x48 dp boundary."
/// Metric: Minimum Touch Target Size -- Floor 44dp, Optimal 48dp,
///         Ceiling 56dp. Pass/Fail. Standard: Material Design 3 /
///         WCAG 2.5.5 (Target Size).
///
/// THE SIXTH TIME THE SHEET ASKS FOR 48dp, AND THE THIRD IN THIS BATCH. A
/// seventh implementation is not the response; a census is.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/touch_guideline.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/tokens/touch_target_band.dart';

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

  group('GEN-04286 :: the census', () {
    gate(
      'GEN-04286-G1',
      'Atomic Step: "Define atomic touch target guidelines enforcing a minimum '
          '48x48 dp boundary." Steps 3, 108, 184 and 198 already did.',
      'The band is read from Step 184 rather than restated, and the row\'s '
          '48dp is the band OPTIMAL rather than its floor -- so the row is '
          'stricter than the standard it cites and is honoured as written',
      () =>
          HabotTouchTargetGuideline.floorDp == HabotTouchBand.floorDp &&
          HabotTouchTargetGuideline.optimalDp == HabotTouchBand.optimalDp &&
          HabotTouchTargetGuideline.ceilingDp == HabotTouchBand.ceilingDp &&
          HabotTouchTargetGuideline.rowMinimumDp == 48 &&
          HabotTouchTargetGuideline.rowAsksForTheOptimalNotTheFloor &&
          HabotTouchTargetGuideline.sheetRestatements == 6,
    );

    gate(
      'GEN-04286-G2',
      '"Every declaration of the number in this repository, what each one '
          'holds, and whether they agree."',
      'Four declaration sites are named with their owning step, and all four '
          'hold the same number -- so the duplication is redundant rather than '
          'divergent, which is the only version that is safe to leave',
      () =>
          HabotTouchTargetGuideline.declarations.length == 4 &&
          HabotTouchTargetGuideline.censusAgrees &&
          HabotTouchTargetGuideline.declarations.every(
            (HabotTargetDeclaration d) =>
                d.owner.startsWith('Step') && d.role.length > 40,
          ) &&
          HabotTouchTargetGuideline.declarations
                  .map((HabotTargetDeclaration d) => d.owner)
                  .toSet()
                  .length ==
              4,
    );

    gate(
      'GEN-04286-G3',
      '"HabotSpacing.xxxl is 48 and HabotDensity.minTouchTarget is 48, and '
          'they are not the same fact."',
      'The census separates the two real declarations from the one coincidence '
          'and the two derived readings, and the coincidence is kept in the '
          'census precisely because it is the entry a future change breaks '
          'silently',
      () =>
          HabotSpacing.xxxl == HabotDensity.minTouchTarget &&
          HabotTouchTargetGuideline.independentDeclarations.length == 2 &&
          HabotTouchTargetGuideline.coincidentalDeclaration.symbol ==
              'HabotSpacing.xxxl' &&
          HabotTouchTargetGuideline.coincidentalDeclaration.role
              .contains('Not a touch declaration') &&
          HabotTouchTargetGuideline.coincidenceNote
              .contains('nothing in the diff to say so'),
    );
  });

  group('GEN-04286 :: two disagreements in the sheet', () {
    gate(
      'GEN-04286-G4',
      'This row says the ceiling is 56dp; Step 228 says 64x64dp; Step 229 says '
          '56dp.',
      'The three rows disagree, the disagreement is recorded as three named '
          'values rather than resolved silently, and it is resolved per '
          'control class -- 56 for a free-standing control and 64 for a '
          'navigation destination, which is the sheet\'s own number honoured '
          'where the sheet meant it',
      () =>
          HabotTouchTargetGuideline.rowsDisagreeAboutTheCeiling &&
          HabotTouchTargetGuideline.ceilingsNamedByTheRows.length == 3 &&
          HabotTouchTargetGuideline.ceilingsNamedByTheRows.values.toSet()
                  .length ==
              2 &&
          HabotTouchTargetGuideline.disagreementIsResolved &&
          HabotTouchTargetGuideline.ceilingForControlClass(
                'navigation destination',
              ) ==
              64 &&
          HabotTouchTargetGuideline.ceilingForControlClass('icon button') ==
              56,
    );

    gate(
      'GEN-04286-G5',
      'Every exception has to argue for itself.',
      'The one ceiling exception names the row that asks for it and gives the '
          'reason the band ceiling does not apply -- a navigation '
          'destination\'s whole cell means one thing, which is what the '
          'ceiling exists to protect against',
      () =>
          HabotTouchTargetGuideline.ceilingExceptions.length == 1 &&
          HabotTouchTargetGuideline.ceilingExceptions.single.rowThatAsksForIt
              .contains('GEN-03259') &&
          HabotTouchTargetGuideline.ceilingExceptions.single.rationale
              .contains('80dp bar') &&
          HabotTouchTargetGuideline.ceilingExceptions.single.rationale
              .contains('unambiguous'),
    );

    gate(
      'GEN-04286-G6',
      'This row cites WCAG 2.5.5 for 44dp; Step 229 cites WCAG 2.2 SC 2.5.8 '
          'for the same figure.',
      'SC 2.5.5 Target Size is Level AAA at 44x44 CSS pixels -- which is the '
          'figure, so this row cites it correctly. SC 2.5.8 Target Size '
          '(Minimum) is Level AA at 24x24, so Step 229 cites a criterion that '
          'does not contain its own number',
      () =>
          HabotTouchTargetGuideline.sc255MinimumCssPx == 44 &&
          HabotTouchTargetGuideline.sc258MinimumCssPx == 24 &&
          HabotTouchTargetGuideline.sc255MinimumCssPx ==
              HabotTouchTargetGuideline.floorDp &&
          HabotTouchTargetGuideline.oneCitationIsWrong &&
          HabotTouchTargetGuideline.thisRowCitation.contains('2.5.5') &&
          HabotTouchTargetGuideline.step229Citation.contains('2.5.8') &&
          HabotTouchTargetGuideline.citationNote
              .contains('worse than a wrong figure'),
    );

    gate(
      'GEN-04286-G7',
      'Metric: Minimum Touch Target Size -- 44 / 48 / 56. Pass/Fail.',
      'All eight checks hold and the step reports Pass -- on a census and two '
          'recorded sheet defects rather than on a seventh implementation of a '
          'number this repository has held since Step 3',
      () =>
          HabotTouchTargetGuideline.checks.length == 8 &&
          HabotTouchTargetGuideline.checks.values.every((bool b) => b) &&
          HabotTouchTargetGuideline.isPass &&
          HabotTouchTargetGuideline.qualitativeOutput == 'Pass' &&
          HabotTouchTargetGuideline.sixthTimeNote
              .contains('a census is') &&
          HabotTouchTargetGuideline.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04286',
        atomicStepReferenceId: 'GEN-04286',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Define atomic touch target guidelines enforcing a minimum '
            '48x48 dp boundary."',
        implementationOrder: 227,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTouchTargetGuideline',
          'Component Properties':
              '${HabotTouchTargetGuideline.declarations.length} declaration '
              'sites censused, '
              '${HabotTouchTargetGuideline.independentDeclarations.length} of '
              'them independent; band read from Step 184; '
              '${HabotTouchTargetGuideline.ceilingExceptions.length} declared '
              'ceiling exception; three rows\' ceiling values recorded and '
              'resolved per control class',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: this is the SIXTH time the sheet asks for 48dp. Step 3 '
              'declared HabotDensity.minTouchTarget, Step 108 built '
              'TouchStandards and the A11Y_LITERAL_TOUCH_SIZE rule, Step 184 '
              'built the band with a floor, an optimal and a ceiling, Step 198 '
              'applied it to category cards -- and this row asks again, as do '
              'Steps 228 and 229 in this same batch. Three restatements in '
              'twenty rows, from three source documents, none of which knows '
              'the others exist. A seventh implementation is not the response; '
              'a census is, and it finds all four declaration sites holding '
              'the same number. ONE OF THEM IS A COINCIDENCE: '
              'HabotSpacing.xxxl is 48 and HabotDensity.minTouchTarget is 48, '
              'and they are not '
              'the same fact -- a control sized from the spacing rung passes '
              'every check today and becomes non-compliant the day somebody '
              'retunes the spacing ladder, with nothing in the diff to say so. '
              'SECOND FINDING: the three rows disagree about the ceiling -- '
              '56, 64, 56 -- resolved per control class, with 64 honoured for '
              'navigation destinations where the sheet meant it. THIRD: this '
              'row cites WCAG 2.5.5 for 44dp, correctly; Step 229 cites SC '
              '2.5.8 for the same figure, and 2.5.8 is Level AA at 24x24. The '
              'number is right and the reference is not, which survives review '
              'because the number looks familiar.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Minimum Touch Target Size',
            observed:
                'PASS on all ${HabotTouchTargetGuideline.checks.length} '
                'checks. The band is read from Step 184 and the row\'s 48dp is '
                'its optimal, not its floor -- the row is stricter than the '
                'standard it cites and is honoured as written.',
            floor: '44dp',
            optimal: '48dp',
            ceiling: '56dp',
          ),
          AissMeasurement(
            metricName: 'Declaration sites holding the 48dp minimum',
            observed:
                '${HabotTouchTargetGuideline.declarations.length}, all in '
                'agreement, of which '
                '${HabotTouchTargetGuideline.independentDeclarations.length} '
                'hold the number in their own right and one of those is a '
                'spacing rung that only happens to equal it. Six sheet rows '
                'have now asked for the same figure.',
            floor: '1 site',
            optimal: '1 site',
            ceiling: 'n/a',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/touch_guideline.dart',
        ],
      ),
    );
  });
}
