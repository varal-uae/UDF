/// AISS GATE -- Step 290 of 295
/// Global Reference ID:       GEN-00101
/// Atomic Steps Reference ID: GEN-00101
/// Setup Step (Action): (EMPTY -- the populated Setup Step column reads
///                      "Register the type-to-component mappings in the
///                      FormatterRegistry singleton")
/// Atomic Step: "Define dwell-time and hesitation threshold limits for all
///               mobile form inputs."
/// Metric: Schema Field Definition Accuracy -- Floor "Field typed and
///         documented, minor gaps allowed pre-review", Optimal "100% field
///         type/constraint match to schema contract", Ceiling 1.
///         Complete / Partial / Not Complete.
///
/// DWELL AND HESITATION ARE DIFFERENT MEASUREMENTS, AND A THRESHOLD IS NOT A
/// RULE UNTIL SOMEBODY SAYS WHAT CROSSING IT DOES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/dwell_thresholds.dart';

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

  group('GEN-00101 :: two signals, and a per-kind band', () {
    gate(
      'GEN-00101-G1',
      'Atomic Step: "dwell-time and hesitation threshold limits".',
      'Three timing signals are distinguished -- total dwell, hesitation '
          'before starting, and the longest pause within -- rather than the '
          'one the row\'s phrase implies',
      () =>
          HabotDwellThresholds.allThreeSignalsAreDistinguished &&
          HabotTimingSignal.values.length == 3,
    );

    gate(
      'GEN-00101-G2',
      'Atomic Step: "for all mobile form inputs".',
      'Five thresholds across four input kinds, every kind covered and every '
          'threshold carrying its reason',
      () =>
          HabotDwellThresholds.thresholds.length == 5 &&
          HabotDwellThresholds.everyKindHasAtLeastOneThreshold &&
          HabotDwellThresholds.everyThresholdGivesAReason &&
          HabotInputKind.values.length == 4,
    );

    gate(
      'GEN-00101-G3',
      'One number could not have served them all.',
      'The declared limits span a factor of forty-five, from four seconds on '
          'an empty numeric field to three minutes on a free-text note, which '
          'is the measurable form of the objection',
      () =>
          HabotDwellThresholds.spread == 45 &&
          HabotDwellThresholds.oneNumberCouldNotServeThemAll &&
          HabotDwellThresholds.twoSignalsNote
              .contains('factor of forty-five'),
    );

    gate(
      'GEN-00101-G4',
      'Two of these thresholds were declared before this row.',
      'Step 248 set a dwell band and Step 247 a correction window, so the '
          'definition step arrives after two of its own uses -- recorded, '
          'because the next reader will look for the definitions here',
      () =>
          HabotDwellThresholds.someThresholdsAlreadyExist &&
          HabotDwellThresholds.definitionAfterUseNote
              .contains('somewhere else'),
    );
  });

  group('GEN-00101 :: what crossing one does, and what it emits', () {
    gate(
      'GEN-00101-G5',
      'A help panel that opens on a timer interrupts the person thinking.',
      'Crossing a threshold emits and does not act; the one acting form '
          'allowed is passive, taking no focus and moving nothing',
      () =>
          HabotDwellThresholds.nothingIsInterrupted &&
          HabotDwellThresholds.interruptionNote
              .contains('closest to finishing'),
    );

    gate(
      'GEN-00101-G6',
      'A dwell measurement is behavioural data about a person.',
      'The observation carries the field, the signal and a duration and never '
          'the value being typed, and it is emittable only because durationMs '
          'is one of the five declared field types',
      () =>
          HabotDwellThresholds.theObservationCarriesNoValue &&
          HabotDwellThresholds.durationIsADeclaredFieldType &&
          HabotDwellThresholds.emissionNote.contains('nobody tests'),
    );

    gate(
      'GEN-00101-G7',
      'Floor: "Field typed and documented, minor gaps allowed pre-review".',
      'A prose floor with "minor gaps allowed" is unmeasurable -- there is no '
          'scale on which a gap is minor -- and the step reports against the '
          'optimal instead',
      () =>
          HabotDwellThresholds.theFloorIsUnmeasurable &&
          HabotDwellThresholds.bandNote.contains('no scale'),
    );

    gate(
      'GEN-00101-G8',
      'Output: Complete / Partial / Not Complete.',
      'Six definition checks, all holding, giving 1.0 and a Complete; all ten '
          'declared checks pass',
      () =>
          HabotDwellThresholds.definitionChecks.length == 6 &&
          HabotDwellThresholds.definitionChecks.values.every((bool b) => b) &&
          HabotDwellThresholds.definitionAccuracy == 1.0 &&
          HabotDwellThresholds.qualitativeOutput == 'Complete' &&
          HabotDwellThresholds.checks.length == 10 &&
          HabotDwellThresholds.checks.values.every((bool b) => b) &&
          HabotDwellThresholds.columnNote.contains('FormatterRegistry'),
    );
  });

  tearDownAll(() {
    final String shortest = '${HabotDwellThresholds.shortestLimit}';
    final String longest = '${HabotDwellThresholds.longestLimit}';
    final String spread = '${HabotDwellThresholds.spread}';
    final String existing =
        '${HabotDwellThresholds.declaredFrictionFloorSeconds}/'
        '${HabotDwellThresholds.declaredFrictionOptimalSeconds}/'
        '${HabotDwellThresholds.declaredFrictionCeilingSeconds}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00101',
        atomicStepReferenceId: 'GEN-00101',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row and the '
            'populated Setup Step column reads "Register the '
            'type-to-component mappings in the FormatterRegistry singleton". '
            'Atomic Step: "Define dwell-time and hesitation threshold limits '
            'for all mobile form inputs."',
        implementationOrder: 290,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDwellThresholds / HabotDwellThreshold',
          'Component Properties':
              '${HabotDwellThresholds.thresholds.length} thresholds across '
              '${HabotInputKind.values.length} input kinds and '
              '${HabotTimingSignal.values.length} timing signals, from '
              '${shortest}s to ${longest}s (a spread of ${spread}x); the '
              'existing friction dwell band is ${existing}s and the '
              'correction window '
              '${HabotDwellThresholds.declaredCorrectionWindowSeconds}s',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotDwellThresholds.twoSignalsNote} '
              'BEHAVIOUR: ${HabotDwellThresholds.interruptionNote} '
              'EMISSION: ${HabotDwellThresholds.emissionNote} '
              'BAND: ${HabotDwellThresholds.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Schema Field Definition Accuracy',
            observed:
                '1.0 over ${HabotDwellThresholds.definitionChecks.length} '
                'definition checks. The row\'s own floor is prose with "minor '
                'gaps allowed" in it and cannot be measured, so the optimal '
                'is what this step reports against.',
            floor: 'Field typed and documented, minor gaps allowed pre-review',
            optimal: '100% field type/constraint match to schema contract',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Spread between the shortest and longest threshold',
            observed:
                '${spread}x -- ${shortest}s before the first character of a '
                'numeric field against ${longest}s of dwell in a free-text '
                'note. A single threshold for "all mobile form inputs" would '
                'be wrong for one end or the other by that factor.',
            floor: 'per input kind',
            optimal: 'per input kind',
            ceiling: 'per input kind',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/dwell_thresholds.dart',
        ],
      ),
    );
  });
}
