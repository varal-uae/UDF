/// AISS GATE -- Step 139 of 155
/// Global Reference ID:       GEN-03470
/// Atomic Steps Reference ID: GEN-03470
/// Setup Step (Action) / Atomic Step: "Implement locale-specific formatters
///   for dates, times, currencies, and numbers."
/// Metric: Locale Formatter Precision -- Floor 1.0, Optimal 1.0, Ceiling 1.0.
///
/// A METRIC WITH NO TOLERANCE IN IT. Every case formats exactly right or the
/// step fails, so the implementation is checked against a golden table rather
/// than by inspection.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/locale_formatters.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';

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

  group('GEN-03470 :: the four kinds the row names', () {
    gate(
      'GEN-03470-G1',
      'Metric: Locale Formatter Precision -- floor, optimal and ceiling all '
          '1.0. A date rendered in the wrong order is not 95% right, it is a '
          'different date.',
      'Every golden case reproduces exactly, across all four kinds the row '
          'names, and a mismatch would name the locale and the value rather '
          'than only lowering a fraction',
      () =>
          HabotLocaleFormatters.precision == 1.0 &&
          HabotLocaleFormatters.precision >= HabotLocaleFormatters.floor &&
          HabotLocaleFormatters.mismatches.isEmpty &&
          HabotLocaleFormatters.goldens.length >= 20 &&
          HabotLocaleFormatters.goldens
              .map((HabotFormatCase c) => c.kind)
              .toSet()
              .containsAll(<String>{'number', 'currency', 'date', 'time'}),
    );

    gate(
      'GEN-03470-G2',
      'THE TRAP: formatting is not translation. A team that translates every '
          'string and leaves the numbers alone ships an app that reads as '
          'broken to a Polish speaker, and no string audit finds it because '
          'there is no string to audit.',
      'Polish uses a comma for the decimal point and a non-breaking space for '
          'the thousands group, and the formatter produces exactly that -- '
          'differently from English on the same input',
      () {
        const int value = 1234550;
        final String en =
            HabotLocaleFormatters.formatScaled(value, 'en', decimals: 2);
        final String pl =
            HabotLocaleFormatters.formatScaled(value, 'pl', decimals: 2);
        return en == '12,345.50' &&
            pl == '12${HabotLocaleFormatters.nonBreakingSpace}345,50' &&
            en != pl &&
            HabotLocaleFormatters.rulesFor('pl').numbers.decimalSeparator ==
                ',' &&
            HabotLocaleFormatters.rulesFor('en').numbers.decimalSeparator ==
                '.';
      },
    );

    gate(
      'GEN-03470-G3',
      'The currency symbol does not sit on the same side in every language, '
          'and a formatter that hardcodes one side is wrong in the other.',
      'The symbol leads in English and trails in Polish, and both are produced '
          'from a declared rule rather than from a branch',
      () =>
          HabotLocaleFormatters.formatCurrencyScaled(4500, 'en', decimals: 2) ==
              'AED${HabotLocaleFormatters.nonBreakingSpace}45.00' &&
          HabotLocaleFormatters.formatCurrencyScaled(4500, 'pl', decimals: 2) ==
              '45,00${HabotLocaleFormatters.nonBreakingSpace}AED' &&
          HabotLocaleFormatters.rulesFor('en').currencySymbolLeads &&
          !HabotLocaleFormatters.rulesFor('pl').currencySymbolLeads,
    );

    gate(
      'GEN-03470-G4',
      'A 12-hour clock has two edges everybody gets wrong: noon and midnight.',
      'Midnight renders as 12 AM and afternoon as a PM hour in the 12-hour '
          'locales, while the 24-hour locales render the same instants as a '
          'zero-padded hour',
      () =>
          HabotLocaleFormatters.formatTime(
                DateTime(2026, 9, 8, 0, 30),
                'pa',
              ) ==
              '12:30${HabotLocaleFormatters.nonBreakingSpace}AM' &&
          HabotLocaleFormatters.formatTime(
                DateTime(2026, 9, 8, 14, 5),
                'ur',
              ) ==
              '2:05${HabotLocaleFormatters.nonBreakingSpace}PM' &&
          HabotLocaleFormatters.formatTime(
                DateTime(2026, 9, 8, 0, 30),
                'pl',
              ) ==
              '00:30' &&
          HabotLocaleFormatters.formatTime(
                DateTime(2026, 9, 8, 14, 5),
                'en',
              ) ==
              '14:05',
    );
  });

  group('GEN-03470 :: the decisions behind the formatter', () {
    gate(
      'GEN-03470-G5',
      'A money formatter that starts from a double has already lost before it '
          'formats anything: 0.1 + 0.2 is not 0.3 in binary floating point.',
      'Every amount enters as an integer of minor units with a declared scale, '
          'display precision is separate from storage precision, and rounding '
          'from four places to two goes half away from zero',
      () =>
          HabotLocaleFormatters.formatCurrencyScaled(
                451250,
                'en',
                decimals: 4,
              ) ==
              'AED${HabotLocaleFormatters.nonBreakingSpace}45.13' &&
          HabotLocaleFormatters.formatCurrencyScaled(
                451249,
                'en',
                decimals: 4,
              ) ==
              'AED${HabotLocaleFormatters.nonBreakingSpace}45.12' &&
          HabotLocaleFormatters.integerArithmeticNote.contains(
            'has already lost before it formats anything',
          ),
    );

    gate(
      'GEN-03470-G6',
      'Step 138 F-1: Urdu runs right-to-left, but its digits do not. A number '
          'in an RTL sentence is reordered by the bidi algorithm and its '
          'currency symbol moves to the wrong end.',
      'A formatted value can be isolated with the Unicode isolate characters, '
          'and a locale for every language the objective names has a rule '
          'rather than silently falling back',
      () {
        final String amount = HabotLocaleFormatters.formatCurrencyScaled(
          4500,
          'ur',
          decimals: 2,
        );
        final String isolated = HabotLocaleFormatters.isolate(amount);
        return isolated.startsWith(HabotLocaleFormatters.firstStrongIsolate) &&
            isolated.endsWith(HabotLocaleFormatters.popDirectionalIsolate) &&
            isolated.contains(amount) &&
            HabotLocalizationObjective.languages.every(
              (HabotLanguage l) =>
                  HabotLocaleFormatters.rules.containsKey(l.code),
            );
      },
    );

    gate(
      'GEN-03470-G7',
      'package:intl is the obvious implementation, and the reason it was not '
          'used has to be defensible rather than incidental.',
      'The decision is recorded with both of its reasons, and an unknown '
          'locale falls back rather than throwing -- a locale the app does not '
          'offer should render in English, not crash',
      () =>
          HabotLocaleFormatters.noIntlNote.contains('install size') &&
          HabotLocaleFormatters.noIntlNote.contains(
            'can change between package versions',
          ) &&
          HabotLocaleFormatters.rulesFor('zz').code == 'en' &&
          HabotLocaleFormatters.formatDate(
                DateTime(2026, 9, 8),
                'zz',
              ) ==
              '08/09/2026',
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03470',
        atomicStepReferenceId: 'GEN-03470',
        setupStepAction:
            'Implement locale-specific formatters for dates, times, '
            'currencies, and numbers.',
        implementationOrder: 139,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotLocaleFormatters',
          'Component Properties':
              '${HabotLocaleFormatters.rules.length} locales, four value kinds '
              '(number, currency, date, time), '
              '${HabotLocaleFormatters.goldens.length} golden cases, no intl '
              'dependency',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The formatter consumes the exact fixed '
              'type declared at Step 140 rather than a double.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Locale Formatter Precision',
            observed:
                '${HabotLocaleFormatters.precision.toStringAsFixed(2)} over '
                '${HabotLocaleFormatters.goldens.length} golden cases across '
                '${HabotLocaleFormatters.rules.length} locales -- including '
                'the Polish decimal comma and group space, the trailing '
                'currency symbol, and both 12-hour clock edges.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          const AissMeasurement(
            metricName: 'Floating-point money paths',
            observed:
                '0. Every amount enters as an integer of minor units with a '
                'declared scale. Display precision and storage precision are '
                'separate, and rescaling rounds half away from zero -- stated '
                'rather than inherited from whatever a library happened to do.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/i18n/locale_formatters.dart',
        ],
      ),
    );
  });
}
