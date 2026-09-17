/// AISS GATE -- Step 417 of 415
/// Global Reference ID:       UFHT-019
/// Atomic Steps Reference ID: UFHT-019
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Define the friction indicators to be silently logged."
/// Metric: -- floor "0.8", optimal "0.95", ceiling "1". Best Qualitative
///         Output: "Not Complete / Partial / Complete". IIBA BABOK v3
///         requirements-elicitation completeness benchmark; contextual
///         standard: Google SRE 'Four Golden Signals' / ISO/IEC 25010
///         performance-efficiency characteristic. Assigned to **ADFA**.
///
/// NO METRIC NAME AT ALL, AN OUTPUT COLUMN WRITTEN BACKWARDS, AND A LOWER HALF
/// ABOUT REMOVING PEOPLE'S ACCESS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/friction_indicators.dart';

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

  group('UFHT-019 :: a band with no quantity', () {
    gate(
      'UFHT-019-G1',
      'The Metric Name cell is empty and the band is not.',
      'Floor 0.8, optimal 0.95, ceiling 1, measuring nothing the row names',
      () =>
          HabotFrictionIndicators.theMetricCellIsEmpty &&
          HabotFrictionIndicators.thereIsABandAnyway &&
          HabotFrictionIndicators.aBandWithNoQuantity,
    );

    gate(
      'UFHT-019-G2',
      'The first row in the track with no metric.',
      'Four hundred and sixteen rows in; a band with no quantity can be '
          'satisfied by any number put under it',
      () =>
          HabotFrictionIndicators.thisIsTheFirstRowWithNoMetric &&
          HabotFrictionIndicators.metricNote.contains('not being satisfiable'),
    );

  });

  group('UFHT-019 :: an output column running the wrong way', () {
    gate(
      'UFHT-019-G3',
      'The output column is written backwards.',
      '"Not Complete / Partial / Complete" where every other row in the track '
          'reads best-first',
      () =>
          HabotFrictionIndicators.theColumnIsReversed &&
          HabotFrictionIndicators.theRowContradictsItself,
    );

    gate(
      'UFHT-019-G4',
      'Which shows the column is read by position.',
      'Six rows carry an arrow declaring the first value best, so a row listed '
          'in an unusual order is silently mis-scored',
      () =>
          HabotFrictionIndicators.theConventionIsPositional &&
          HabotFrictionIndicators.reversalNote.contains('silently mis-scored'),
    );

  });

  group('UFHT-019 :: five cells from a row about dismissal', () {
    gate(
      'UFHT-019-G5',
      'Five cells belong to a row about removing access.',
      'A scheduled script that strips a low performer\'s IAM access, with '
          'managers explicitly prevented from intervening',
      () =>
          HabotFrictionIndicators.fiveCellsBelongElsewhere &&
          HabotFrictionIndicators.thisIsTheFifthSplicedRow,
    );

    gate(
      'UFHT-019-G6',
      'And the behaviour is refused, not built.',
      'Step 416 fixed the unit of analysis at a screen and forbade attributing '
          'an indicator to an individual; that limit was written for this case',
      () =>
          HabotFrictionIndicators.theSpliceIsRecordedAndRefused &&
          HabotFrictionIndicators.theFrameworkAlreadyForbidsIt,
    );

  });

  group('UFHT-019 :: two readings of "silently"', () {
    gate(
      'UFHT-019-G7',
      'Silence as an engineering property is built.',
      'Passive events, no layout shift, no main-thread work -- which is what '
          'the row\'s own design cells ask for',
      () =>
          HabotFrictionIndicators.theEngineeringReadingIsImplemented &&
          HabotFrictionIndicators.theTwoReadingsDiffer,
    );

    gate(
      'UFHT-019-G8',
      'Silence as secrecy is refused.',
      'Every indicator appears on a disclosure surface in plain words with '
          'what it is for',
      () =>
          HabotFrictionIndicators.theSecrecyReadingIsRefused &&
          HabotFrictionIndicators.disclosureSurface.contains('Privacy'),
    );

    gate(
      'UFHT-019-G9',
      'Every indicator has a scope and a disclosure line.',
      'And none of them joins to an individual',
      () =>
          HabotFrictionIndicators.everyIndicatorHasAJoinScope &&
          HabotFrictionIndicators.everyIndicatorHasADisclosureLine &&
          HabotFrictionIndicators.noIndicatorJoinsToAnIndividual,
    );

    gate(
      'UFHT-019-G10',
      'Six obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotFrictionIndicators.obligations.length == 6 &&
          HabotFrictionIndicators.obligations.values.every((bool b) => b) &&
          HabotFrictionIndicators.qualitativeOutput ==
              HabotFrictionIndicators.bestOutputActuallyMeant &&
          HabotFrictionIndicators.theSuppliedMetricReachesTheCeiling,
    );
  });

  tearDownAll(() {
    final int kinds = HabotFrictionKind.values.length;
    final int spliced = HabotFrictionIndicators.cellsFromTheOtherRow.length;
    final String surface = HabotFrictionIndicators.disclosureSurface;
    final double completeness = HabotFrictionIndicators.definitionCompleteness;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'UFHT-019',
        atomicStepReferenceId: 'UFHT-019',
        setupStepAction:
            'COLUMN NOTE: the Metric Name cell on this row is empty -- the '
            'first row in four hundred and sixteen with no metric at all -- '
            'while the band still reads 0.8, 0.95, 1; its Best Qualitative '
            'Output column reads "Not Complete / Partial / Complete", the only '
            'row in the track written worst-first, which under the positional '
            'convention six other rows declare outright would make failure its '
            'best outcome; and its Poka-Yoke, Completion Measures, Expected '
            'Output, Common Library and Decision Group cells all belong to a '
            'row about a scheduled script that automatically removes a low '
            'performer\'s access, making this the fifth spliced row in the '
            'track. Those five cells are recorded and the behaviour is '
            'refused. Atomic Step: "Define the friction indicators to be '
            'silently logged."',
        implementationOrder: 417,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Definition Name':
              '$kinds friction indicators, each with a join scope and a '
                  'disclosure line',
          'Definition Parameters':
              'thresholds inherited from the Step 416 framework rather than '
                  'restated here',
          'Definition Type':
              'passive observation only; no indicator joins to an individual',
          'Validation Status':
              'definition completeness $completeness against a band whose '
                  'metric name cell is empty',
          'Definition ID':
              'disclosed at "$surface"; $spliced cells from a row about '
                  'automatically removing a low performer\'s access are '
                  'recorded and refused',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Share of declared friction indicators carrying a threshold, a '
                'join scope and a disclosure line',
            observed:
                'THE METRIC NAME CELL ON THIS ROW IS EMPTY. Four hundred and '
                'sixteen rows into the track this is the first with no metric '
                'at all, and the band still reads 0.8, 0.95, 1 -- a scale with '
                'no quantity behind it, satisfiable by whatever number is put '
                'under it. The metric named here is a substitution and is '
                'named as one. Its Best Qualitative Output column reads "Not '
                'Complete / Partial / Complete", the only row in the track '
                'written worst-first, which under the positional convention '
                'six other rows state outright would make failure its best '
                'outcome. Observed: $completeness across $kinds indicators.',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Cells on this row belonging to a row about dismissal',
            observed:
                '$spliced. The Poka-Yoke, Completion Measures, Expected '
                'Output, Common Library and Decision Group cells all describe '
                'a Cloud Scheduler script that removes a worker\'s IAM access '
                'when they fall below a threshold, with managers explicitly '
                'unable to intervene. It is the fifth spliced row in the track '
                'and the first whose halves fit together into something '
                'coherent -- friction telemetry wired to automatic dismissal '
                '-- which is exactly why it is recorded and refused rather '
                'than built. The word "silently" is split: no layout shift and '
                'no main-thread work are implemented; secrecy is not, and '
                'every indicator is listed at "$surface".',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/friction_indicators.dart',
        ],
      ),
    );
  });
}
