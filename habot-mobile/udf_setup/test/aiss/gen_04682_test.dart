/// AISS GATE -- Step 493 of 1,314
/// Global Reference ID:       GEN-04682
/// Atomic Steps Reference ID: GEN-04682
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Establish continuous improvement roadmaps mapping future
///               feature enhancements."
/// Metric: Continuous Improvement Backlog Closure Rate -- floor "0.6", optimal
///         "0.8", ceiling "95% (diminishing returns)". Best Qualitative Output:
///         "Good/Average/Poor". Agile Retrospective / Kaizen Continuous
///         Improvement Standard. Assigned to **ADFA**.
///
/// ONE QUANTITY WRITTEN TWO WAYS INSIDE A SINGLE BAND.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/field/improvement_roadmap.dart';

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

  group('GEN-04682 :: two notations, one quantity', () {
    gate(
      'GEN-04682-G1',
      'The floor and optimal are decimals.',
      '0.6 and 0.8',
      () => HabotImprovementRoadmap.theFloorAndOptimalAreDecimals,
    );

    gate(
      'GEN-04682-G2',
      'And the ceiling is a percentage.',
      '95 per cent, in the same three cells',
      () => HabotImprovementRoadmap.theCeilingIsAPercentage,
    );

    gate(
      'GEN-04682-G3',
      'One quantity written two ways, a first in the track.',
      'Anybody reading quickly sees a ceiling ten times its own optimal',
      () =>
          HabotImprovementRoadmap.oneQuantityTwoNotations &&
          HabotImprovementRoadmap.notationNote
              .contains('ten times its own optimal'),
    );

    gate(
      'GEN-04682-G4',
      'Read as proportions the band ascends.',
      'Which is the reading used, and it is declared',
      () =>
          HabotImprovementRoadmap.readAsProportionsItAscends &&
          HabotImprovementRoadmap.annotatedBoundaryCount == 15,
    );

  });

  group('GEN-04682 :: intentions measured by closure', () {
    gate(
      'GEN-04682-G5',
      'The row asks for a roadmap and the band scores closure.',
      'An admission rather than a defect: a roadmap nobody closes is a '
      'document',
      () =>
          HabotImprovementRoadmap.theRowAndTheBandDiffer &&
          HabotImprovementRoadmap.admissionNote.contains('tell the difference'),
    );

  });

  group('GEN-04682 :: three rules against gaming', () {
    gate(
      'GEN-04682-G6',
      'Five items, every one naming its source.',
      'A backlog with no sources becomes what the team already wanted to build',
      () =>
          HabotImprovementRoadmap.items.length == 5 &&
          HabotImprovementRoadmap.everyItemNamesItsSource,
    );

    gate(
      'GEN-04682-G7',
      'The declined item counts as closed and says why.',
      'Otherwise the rate rewards silence',
      () =>
          HabotImprovementRoadmap.aDeclinedItemCountsAsClosed &&
          HabotImprovementRoadmap.everyClosedItemSaysWhy,
    );

    gate(
      'GEN-04682-G8',
      'The item added this period is excluded.',
      'Otherwise listening to people lowers your score',
      () =>
          HabotImprovementRoadmap.itemsAddedThisPeriodAreExcluded &&
          HabotImprovementRoadmap.gamingNote.contains('lowers your score'),
    );

    gate(
      'GEN-04682-G9',
      'Every item comes from a defect this track already found.',
      'A backlog without the known defects is not a backlog',
      () => HabotImprovementRoadmap.theBacklogHoldsKnownDefects,
    );

  });

  group('GEN-04682 :: the result', () {
    gate(
      'GEN-04682-G10',
      'Five obligations met, and three of four closed reports Average.',
      'Above the floor of 0.6 and below the optimal of 0.8',
      () =>
          HabotImprovementRoadmap.obligations.length == 5 &&
          HabotImprovementRoadmap.obligations.values.every((bool b) => b) &&
          HabotImprovementRoadmap.closureRate == 0.75 &&
          HabotImprovementRoadmap.qualitativeOutput == 'Average',
    );
  });

  tearDownAll(() {
    final int items = HabotImprovementRoadmap.items.length;
    final double rate = HabotImprovementRoadmap.closureRate;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04682',
        atomicStepReferenceId: 'GEN-04682',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor and optimal are decimals and its '
            'ceiling is a percentage, the first band in the track to write one '
            'quantity two ways inside itself, so it is read as proportions '
            'throughout; the row asks for a roadmap and the band scores '
            'closure, which is an admission rather than a defect; declined '
            'items count as closed and record why, items added this period are '
            'excluded, and every item names who asked; and all five items cite '
            'the steps in this track that raised them. Atomic Step: "Establish '
            'continuous improvement roadmaps mapping future feature '
            'enhancements."',
        implementationOrder: 493,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Establish continuous improvement roadmaps mapping future feature '
          'enhancements.':
              '$items items each naming the steps that raised it, a closure '
              'rate of ${rate.toStringAsFixed(2)} over the four in period, '
              'with declined counting as closed',
          'Completion Status': 'Average',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Continuous Improvement Backlog Closure Rate',
            observed:
                'ONE QUANTITY, TWO NOTATIONS, INSIDE ONE BAND. The floor and '
                'optimal are 0.6 and 0.8 and the ceiling is 95 per cent, so a '
                'quick reader sees a ceiling ten times its own optimal. Step '
                '474 mixed percentages with a bare 1; this is the first band '
                'in the track to write one quantity two ways inside itself. '
                'Read as proportions: ${rate.toStringAsFixed(2)} closed, which '
                'is Average.',
            floor: '0.6',
            optimal: '0.8',
            ceiling: '95% (diminishing returns)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Items closed without a reason',
            observed:
                '0 of $items. An item closed as "we are not doing this" counts '
                'as closed and records why, because otherwise the rate rewards '
                'silence; items added during the period are excluded, because '
                'otherwise listening to people lowers the score; and every '
                'item records who asked. All $items cite the steps in this '
                'track that raised them, from the lost comparison signs to the '
                'two registries nobody has chosen between.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/field/improvement_roadmap.dart',
        ],
      ),
    );
  });
}
