/// AISS GATE -- Step 247 of 255
/// Global Reference ID:       FLADE-006-03
/// Atomic Steps Reference ID: FLADE-006-03
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Attach keystroke monitoring event listeners to form input
///               fields to detect rapid consecutive backspace or clear
///               actions."
/// Metric: Observability / Alert Coverage -- Floor >=90%, Optimal 1, Ceiling
///         1. Good/Average/Poor. Standard cited: Google SRE Handbook.
///
/// WHAT IS ATTACHED COUNTS AND NEVER CAPTURES, AND IS REFUSED OUTRIGHT ON
/// THREE OF THE SIX DECLARED FIELDS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/correction_burst.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double coverage = 0;

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

  group('FLADE-006-03 :: counts, never captures', () {
    gate(
      'FLADE-006-03-G1',
      'Atomic Step: "Attach KEYSTROKE MONITORING event listeners."',
      'A listener that sees keystrokes sees content, and Step 207 established '
          'that this application must never be in a position to read a card '
          'number -- so the observation carries a time and whether it was a '
          'deletion, and there is nowhere to put a character even if somebody '
          'wanted to',
      () =>
          HabotKeystrokeKind.values.length == 3 &&
          HabotCorrectionBurstDetector.countsNeverCapturesNote
              .contains('COUNTS') &&
          HabotCorrectionBurstDetector.countsNeverCapturesNote
              .contains('no before-and-after'),
    );

    gate(
      'FLADE-006-03-G2',
      'HabotHesitationTracker already records corrections value-free.',
      'The burst shape sits on the existing record rather than opening a '
          'second stream, which would have been a second thing to keep clean',
      () =>
          HabotCorrectionBurstDetector.existingCorrectionKind ==
              HabotInteractionKind.correction &&
          HabotCorrectionBurstDetector.reusesTheExistingStreamNote
              .contains('second stream'),
    );

    gate(
      'FLADE-006-03-G3',
      '"Rapid consecutive backspace or clear actions."',
      'The worked trace of thirteen observations contains seven corrections '
          'and yields exactly one burst -- the run of four inside two seconds '
          '-- while the three spread over six seconds are a person editing '
          'rather than a person stuck',
      () =>
          HabotCorrectionBurstDetector.workedBursts.length == 1 &&
          HabotCorrectionBurstDetector.workedBursts.single.corrections == 4 &&
          HabotCorrectionBurstDetector.workedBursts.single.startMs == 1500 &&
          HabotCorrectionBurstDetector.workedBursts.single.endMs == 1880 &&
          HabotCorrectionBurstDetector.workedBursts.single.spanMs <=
              HabotCorrectionBurstDetector.windowMs &&
          HabotCorrectionBurstDetector.windowNote
              .contains('one long problem'),
    );

    gate(
      'FLADE-006-03-G4',
      'One tap of a clear button is not three backspaces and is the same '
          'intent.',
      'A clear counts as a correction on its own, so a trace of three clears '
          'inside the window is a burst -- the case a deletion-only detector '
          'misses entirely',
      () =>
          HabotCorrectionBurstDetector.burstsIn(
                HabotCorrectionBurstDetector.clearOnlyTrace,
              ).length ==
              1 &&
          (HabotCorrectionBurstDetector.correctionRatioOf(
                    HabotCorrectionBurstDetector.workedTrace,
                  ) -
                  7 / 13)
              .abs() <
              1e-9 &&
          HabotCorrectionBurstDetector.window ==
              HabotMotion.correctionBurstWindow &&
          HabotCorrectionBurstDetector.windowMs == 2000 &&
          HabotCorrectionBurstDetector.threshold == 3,
    );
  });

  group('FLADE-006-03 :: what may not be watched at all', () {
    gate(
      'FLADE-006-03-G5',
      'Step 207: the application must never be in a position to read a PAN.',
      'Three of the six declared fields are refused -- the card number, the '
          'security code and the IBAN -- because even a value-free count on a '
          'card field is a signal about a card number, and a count that exists '
          'can be joined to a session that exists',
      () =>
          HabotCorrectionBurstDetector.fields.length == 6 &&
          HabotCorrectionBurstDetector.refusedFields.length == 3 &&
          HabotCorrectionBurstDetector.refusedFields.every(
            (HabotWatchedField f) => f.why.length > 60,
          ) &&
          HabotCorrectionBurstDetector.refusalNote
              .contains('not merely anonymised'),
    );

    gate(
      'FLADE-006-03-G6',
      'A refusal that only exists in a comment is not a refusal.',
      'No sensitive field has the detector attached, the detector returns '
          'nothing for them given the same trace that produces a burst '
          'elsewhere, and the two facts are checked separately',
      () =>
          HabotCorrectionBurstDetector.violations.isEmpty &&
          HabotCorrectionBurstDetector.nothingIsWatchedOnASensitiveField &&
          HabotCorrectionBurstDetector.theSameTraceIsDetectedOnAWatchableField,
    );

    gate(
      'FLADE-006-03-G7',
      'Metric: Observability / Alert Coverage -- floor >=90%, optimal 1.',
      'All ten checks hold; coverage over the fields the detector may watch is '
          '1.0 and over all six is 0.5, with the exclusion declared rather '
          'than the denominator quietly reduced -- the same shape as Steps 233 '
          'and 234. Reports Good',
      () {
        coverage = HabotCorrectionBurstDetector.coverageOfWatchableFields;
        return HabotCorrectionBurstDetector.checks.length == 10 &&
            HabotCorrectionBurstDetector.checks.values.every((bool b) => b) &&
            coverage == 1.0 &&
            (HabotCorrectionBurstDetector.coverageOfAllFields - 0.5).abs() <
                1e-9 &&
            HabotCorrectionBurstDetector.qualitativeOutput == 'Good' &&
            HabotCorrectionBurstDetector.columnNote
                .contains('no Setup Step');
      },
    );
  });

  tearDownAll(() {
    final String allFieldsCoverage = HabotCorrectionBurstDetector
        .coverageOfAllFields
        .toStringAsFixed(2);
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'FLADE-006-03',
        atomicStepReferenceId: 'FLADE-006-03',
        setupStepAction:
            'COLUMN NOTE: this row carries no Setup Step, no Expected Output '
            'and no Completion Measures -- only a metric and a Data Collected '
            'list. Atomic Step: "Attach keystroke monitoring event listeners '
            'to form input fields to detect rapid consecutive backspace or '
            'clear actions."',
        implementationOrder: 247,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotCorrectionBurstDetector / HabotKeystroke / '
              'HabotWatchedField',
          'Component Properties':
              'A ${HabotCorrectionBurstDetector.windowMs}ms window with a '
              'threshold of ${HabotCorrectionBurstDetector.threshold}, over a '
              'value-free stream of time-and-kind; '
              '${HabotCorrectionBurstDetector.fields.length} declared fields '
              'of which ${HabotCorrectionBurstDetector.refusedFields.length} '
              'are refused and '
              '${HabotCorrectionBurstDetector.violations.length} have the '
              'detector attached where they should not',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'BOUNDARY: '
              '${HabotCorrectionBurstDetector.countsNeverCapturesNote} '
              'REFUSAL: ${HabotCorrectionBurstDetector.refusalNote} REUSE: '
              '${HabotCorrectionBurstDetector.reusesTheExistingStreamNote} '
              'WINDOW: ${HabotCorrectionBurstDetector.windowNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Observability / Alert Coverage',
            observed:
                '${coverage.toStringAsFixed(2)} over the '
                '${HabotCorrectionBurstDetector.watchableFields.length} '
                'fields the detector may watch, and '
                '$allFieldsCoverage over all '
                '${HabotCorrectionBurstDetector.fields.length}. The '
                'difference is three fields where even a count is a signal '
                'about something this application must not hold.',
            floor: '>=90%',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Content recorded by the detector',
            observed:
                'None. The observation is a time and whether the keystroke '
                'was a deletion; there is no field on HabotKeystroke that '
                'could hold a character, so a future change that wanted to '
                'record one would have to say so in a diff.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/correction_burst.dart',
        ],
      ),
    );
  });
}
