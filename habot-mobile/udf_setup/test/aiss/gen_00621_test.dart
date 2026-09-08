/// AISS GATE -- Step 142 of 155
/// Global Reference ID:       GEN-00621
/// Atomic Steps Reference ID: GEN-00621
/// Setup Step (Action): "Implement Strict Mobile Input Masking (Poka-Yoke)
///                       for Data Entry"
/// Atomic Step: "Create CurrencyAEDMaskFormatter restricting input strictly to
///               numeric decimal formats."
/// Metric: Decimal Format Mask Match -- Floor "Numeric", Optimal "Numeric",
///         Ceiling "Numeric". Pass / Fail.
///
/// THE TRAP: "strictly numeric decimal" means something different on a Polish
/// keyboard, and the obvious implementation locks out the users this batch
/// exists for.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/currency_aed_mask.dart';
import 'package:udf_setup/design_system/forms/input_mask.dart';
import 'package:udf_setup/design_system/i18n/fixed_precision.dart';

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

  HabotCurrencyAedFormatter formatter(String locale) =>
      HabotCurrencyAedFormatter(activeLocale: () => locale);

  group('GEN-00621 :: strictly numeric decimal', () {
    gate(
      'GEN-00621-G1',
      'Metric: Decimal Format Mask Match -- Numeric, at floor, optimal and '
          'ceiling alike.',
      'Every declared mask case reduces exactly as stated, across all the '
          'offered locales, and a mismatch would name the locale and the '
          'input rather than only lowering a fraction',
      () =>
          HabotCurrencyAedFormatter.maskMatchRate == 1.0 &&
          HabotCurrencyAedFormatter.maskMismatches.isEmpty &&
          HabotCurrencyAedFormatter.maskCases.length >= 12,
    );

    gate(
      'GEN-00621-G2',
      'A formatter that accepts only "." is "strictly numeric decimal" in '
          'English and unusable in Polish, whose decimal key produces a comma '
          '-- in the same release whose objective is equitable access for '
          'non-English speakers.',
      'The active locale decides which character is the decimal point, the '
          'same typed string produces different results in the two locales, '
          'and both store an unambiguous "." form',
      () {
        final String? pl = formatter('pl').sanitise('45,00');
        final String? en = formatter('en').sanitise('45,00');
        return pl == '45.00' &&
            en == '4500' &&
            pl != en &&
            formatter('pl').localeSeparator == ',' &&
            formatter('en').localeSeparator == '.' &&
            HabotCurrencyAedFormatter.localeSeparatorNote.contains(
              'silently refused their keypresses',
            );
      },
    );

    gate(
      'GEN-00621-G3',
      'A user typing "1,000.50" in English means one thousand. Keeping the '
          'comma and parsing "1.000" would be wrong by a factor of a thousand, '
          'and wrong quietly.',
      'A separator character that is not the active locale decimal point is '
          'dropped as a thousands separator, and a SECOND decimal point is '
          'dropped as a mis-key',
      () =>
          formatter('en').sanitise('1,000.50') == '1000.50' &&
          formatter('pl').sanitise('1 234,56') == '1234.56' &&
          formatter('en').sanitise('45.00.25') == '45.00' &&
          HabotCurrencyAedFormatter.groupSeparatorNote.contains(
            'a factor of a thousand',
          ),
    );

    gate(
      'GEN-00621-G4',
      'The field holds an amount a person types, not a computed one.',
      'Decimal places are capped at the DISPLAY scale rather than the storage '
          'scale, everything that is not a digit or a separator is dropped, '
          'and the integer part is bounded',
      () =>
          HabotCurrencyAedFormatter.maxDecimalDigits ==
              HabotPrecision.displayScale &&
          HabotCurrencyAedFormatter.maxDecimalDigits <
              HabotPrecision.storageScale &&
          formatter('en').sanitise('45.999') == '45.99' &&
          formatter('en').sanitise('AED 45.00') == '45.00' &&
          formatter('en').sanitise('-45.00') == '45.00' &&
          formatter('en').sanitise('abc') == '' &&
          HabotCurrencyAedFormatter(
                activeLocale: () => 'en',
                maxIntegerDigits: 3,
              ).sanitise('123456.78') ==
              '123.78',
    );
  });

  group('GEN-00621 :: what the field hands on', () {
    gate(
      'GEN-00621-G5',
      'Refusing a leading separator would stop someone typing ".50", which is '
          'a normal way to enter fifty fils.',
      'A leading separator is accepted while typing and normalised on read, a '
          'trailing one is dropped, and an empty field reads as absent rather '
          'than as zero',
      () =>
          formatter('en').sanitise('.5') == '.5' &&
          HabotCurrencyAedFormatter.normalise('.50') == '0.50' &&
          HabotCurrencyAedFormatter.normalise('12.') == '12' &&
          HabotCurrencyAedFormatter.normalise('') == null &&
          HabotCurrencyAedFormatter.valueOf('.50')!.toPlainString() ==
              '0.5000' &&
          HabotCurrencyAedFormatter.valueOf('') == null,
    );

    gate(
      'GEN-00621-G6',
      'A second definition of "decimal" would be the drift these steps exist '
          'to prevent. HabotMaskKind.decimal (Step 44) already means digits '
          'and a single separator.',
      'The formatter names the existing mask as the one it constrains, and the '
          'value it produces is the Step 140 exact type rather than a double',
      () =>
          HabotCurrencyAedFormatter.baseMask == HabotMaskKind.decimal &&
          HabotCurrencyAedFormatter.reusesExistingMaskNote.contains(
            'rather than declaring a second one',
          ) &&
          HabotCurrencyAedFormatter.valueOf('45.00')!.scale ==
              HabotPrecision.storageScale &&
          HabotCurrencyAedFormatter.valueOf('45.00')!.units == 450000,
    );

    gate(
      'GEN-00621-G7',
      'A formatter that resets the caret to the end makes correcting a typo in '
          'the middle of an amount impossible.',
      'Editing through the real TextInputFormatter entry point keeps the '
          'cleaned text and a caret inside it, and an already-clean value is '
          'passed through untouched',
      () {
        final HabotCurrencyAedFormatter f = formatter('en');
        final TextEditingValue clean = f.formatEditUpdate(
          const TextEditingValue(text: '4'),
          const TextEditingValue(
            text: '45.00',
            selection: TextSelection.collapsed(offset: 5),
          ),
        );
        final TextEditingValue dirty = f.formatEditUpdate(
          const TextEditingValue(text: '45'),
          const TextEditingValue(
            text: '45x.0',
            selection: TextSelection.collapsed(offset: 3),
          ),
        );
        return clean.text == '45.00' &&
            clean.selection.baseOffset == 5 &&
            dirty.text == '45.0' &&
            dirty.selection.baseOffset >= 0 &&
            dirty.selection.baseOffset <= dirty.text.length;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00621',
        atomicStepReferenceId: 'GEN-00621',
        setupStepAction:
            'Implement Strict Mobile Input Masking (Poka-Yoke) for Data Entry',
        implementationOrder: 142,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCurrencyAedFormatter',
          'Component Properties':
              'active-locale decimal separator, '
              '${HabotCurrencyAedFormatter.maxDecimalDigits} decimal places, '
              '${HabotCurrencyAedFormatter.defaultMaxIntegerDigits} integer '
              'digits, constrains HabotMaskKind.decimal rather than replacing '
              'it',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The locale-separator behaviour is a '
              'consequence of Step 139 and would have been a defect without '
              'it: an English-only decimal point makes the field unusable in '
              'Polish.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Decimal Format Mask Match',
            observed:
                'Numeric -- '
                '${(HabotCurrencyAedFormatter.maskMatchRate * 100).toStringAsFixed(0)}'
                '% of ${HabotCurrencyAedFormatter.maskCases.length} declared '
                'cases reduce exactly as stated, including the Polish decimal '
                'comma, an English thousands comma, a second decimal point, a '
                'currency symbol and a leading separator.',
            floor: 'Numeric',
            optimal: 'Numeric',
            ceiling: 'Numeric',
          ),
          const AissMeasurement(
            metricName: 'Locales in which an amount cannot be typed',
            observed:
                '0. The obvious implementation -- digits and a full stop -- '
                'would have been 1: a Polish keyboard\'s decimal key produces '
                'a comma, so the field would have refused every keypress with '
                'no error, in the release whose objective is equitable access '
                'for non-English speakers.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/currency_aed_mask.dart',
        ],
      ),
    );
  });
}
