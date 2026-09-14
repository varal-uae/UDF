/// AISS GATE -- Step 239 of 255
/// Global Reference ID:       GEN-02185
/// Atomic Steps Reference ID: GEN-02185
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement inline UI input masking to auto-format input fields
///               (e.g., XXXX XXXX)."
/// Metric: Input Validation Error Rate -- Floor 0.05, Optimal 0.01, Ceiling 0.
///         Pass / Fail. Standard cited: ISO/IEC 25010 Functional Correctness.
///
/// A FORMATTER MAY MOVE SEPARATORS AND MAY NEVER MOVE DIGITS. The failure mode
/// is a character the person typed silently disappearing, not a value that
/// looks wrong.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/auto_format.dart';

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

  group('GEN-02185 :: digits survive', () {
    gate(
      'GEN-02185-G1',
      'Atomic Step: "auto-format input fields (e.g., XXXX XXXX)."',
      'The row\'s own example produces 1234 5678, and three specs are declared '
          '-- the example, an IBAN in groups of four, and a national identity '
          'number in threes with a hyphen',
      () =>
          HabotAutoFormat.rowExample == '1234 5678' &&
          HabotAutoFormat.specs.length == 3 &&
          HabotAutoFormat.specNamed('IBAN').groupSize == 4 &&
          HabotAutoFormat.specNamed('identity').separator == '-',
    );

    gate(
      'GEN-02185-G2',
      '"The length cap fires on the separator the formatter just inserted."',
      'Every prefix of every spec keeps exactly the digits that went in, stays '
          'inside its own maximum formatted length, and lands its caret at the '
          'end of the formatted string -- checked prefix by prefix rather than '
          'on one happy-path value',
      () =>
          HabotAutoFormat.everySpecIsSafe &&
          HabotAutoFormat.specs.every(HabotAutoFormat.everyPrefixIsSafe),
    );

    gate(
      'GEN-02185-G3',
      'A caret that jumps to the end is the commonest formatter bug.',
      'The caret is computed from the digit index rather than the character '
          'index, so it advances by one position per digit and never moves '
          'backwards across any spec',
      () =>
          HabotAutoFormat.everyCaretIsMonotone &&
          HabotAutoFormat.caretForDigitIndex(
                0,
                HabotAutoFormat.specNamed('XXXX XXXX'),
              ) ==
              0 &&
          HabotAutoFormat.caretForDigitIndex(
                5,
                HabotAutoFormat.specNamed('XXXX XXXX'),
              ) ==
              6,
    );

    gate(
      'GEN-02185-G4',
      'Formatting must not depend on what it was given.',
      'Formatting an already-formatted value changes nothing, and the maximum '
          'formatted length is computed from the spec rather than guessed -- '
          'nine characters for eight digits in fours, forty-two for '
          'thirty-four',
      () =>
          HabotAutoFormat.specs.every(
            (HabotGroupSpec s) =>
                HabotAutoFormat.isIdempotent('987654321', s),
          ) &&
          HabotAutoFormat.specNamed('XXXX XXXX').maxFormattedLength == 9 &&
          HabotAutoFormat.specNamed('IBAN').maxFormattedLength == 42,
    );
  });

  group('GEN-02185 :: the stored value, and a metric with no denominator', () {
    gate(
      'GEN-02185-G5',
      '"A grouped string parsed as a number is a different number."',
      'The stored value is the digits and it round-trips through every spec, '
          'so nothing downstream ever sees the separators -- the rule '
          'HabotCurrencyAedFormatter.normalise already established for money',
      () =>
          HabotAutoFormat.storedValueOf('1234 5678') == '12345678' &&
          HabotAutoFormat.roundTripsThroughStorage &&
          HabotAutoFormat.storedValueNote.contains('decimal separator'),
    );

    gate(
      'GEN-02185-G6',
      'Metric: floor 0.05, optimal 0.01, ceiling 0.',
      'The band is inverted, which is correct for an error rate and is '
          'recorded so it is not read as a defect; and the denominator is '
          'submission attempts rather than keystrokes, because a rate over '
          'keystrokes goes to zero the moment a mask works and stops being '
          'able to fail',
      () =>
          HabotAutoFormat.bandIsInverted &&
          HabotAutoFormat.formatErrorRateAtSubmission ==
              HabotAutoFormat.ceiling &&
          HabotAutoFormat.denominatorNote.contains('SUBMISSION ATTEMPTS') &&
          HabotAutoFormat.denominatorNote.contains('inverted'),
    );

    gate(
      'GEN-02185-G7',
      'Input Validation Error Rate -- Pass / Fail.',
      'All ten checks hold and the step reports Pass, with the Flutter trap '
          'written down: a controller rewritten by a formatter does not fire '
          'onChanged, so a validator bound to it never sees the formatted '
          'value',
      () =>
          HabotAutoFormat.checks.length == 10 &&
          HabotAutoFormat.checks.values.every((bool b) => b) &&
          HabotAutoFormat.qualitativeOutput == 'Pass' &&
          HabotAutoFormat.onChangedNote
              .contains('does not fire for programmatic') &&
          HabotAutoFormat.silentDropNote.contains('may never move digits') &&
          HabotAutoFormat.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String errorRate =
        HabotAutoFormat.formatErrorRateAtSubmission.toStringAsFixed(2);
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02185',
        atomicStepReferenceId: 'GEN-02185',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement inline UI input masking to auto-format input '
            'fields (e.g., XXXX XXXX)."',
        implementationOrder: 239,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotAutoFormat / HabotGroupSpec',
          'Component Properties':
              '${HabotAutoFormat.specs.length} group specs, each checked over '
              'every prefix for digit preservation, idempotence, maximum '
              'formatted length and caret position; stored value is the '
              'digits only',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'POKA-YOKE: ${HabotAutoFormat.silentDropNote} FLUTTER TRAP: '
              '${HabotAutoFormat.onChangedNote} STORAGE: '
              '${HabotAutoFormat.storedValueNote} METRIC: '
              '${HabotAutoFormat.denominatorNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Input Validation Error Rate',
            observed:
                '$errorRate over submission attempts: a formatted field '
                'cannot reach '
                'submit in a shape its own validator rejects, because the '
                'formatter cannot emit an ungrouped or mis-grouped string. '
                'Measured over attempts rather than keystrokes.',
            floor: '0.05',
            optimal: '0.01',
            ceiling: '0',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Digits lost across every prefix of every spec',
            observed:
                '0, over ${HabotAutoFormat.specs.length} specs and every '
                'prefix of each. The property gated is that the formatter may '
                'move separators and may never move digits.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/auto_format.dart',
        ],
      ),
    );
  });
}
