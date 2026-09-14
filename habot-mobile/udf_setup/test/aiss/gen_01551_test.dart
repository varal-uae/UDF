/// AISS GATE -- Step 208 of 215
/// Global Reference ID:       GEN-01551
/// Atomic Steps Reference ID: GEN-01551
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Attach visual card brand detection logic to render Visa,
///               Mastercard, or AMEX icons dynamically upon card entry."
/// Metric: Icon Recognition Accuracy -- Floor 0.8, Optimal 0.95, Ceiling 1.
///         Good/Average/Poor.
///
/// THIS ROW AND STEP 207 POINT IN OPPOSITE DIRECTIONS. Brand detection reads
/// the first digits of the account number; Step 207 requires the app never
/// see any of them. The brand comes from the hosted field, which is already
/// looking, telling the app what it found.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/payments/card_brand.dart';
import 'package:udf_setup/design_system/payments/card_form_contract.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double recognition = 0;

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

  group('GEN-01551 :: where the brand comes from', () {
    gate(
      'GEN-01551-G1',
      'Atomic Step: "brand detection logic ... UPON CARD ENTRY." Step 207: the '
          'app is never in a position to hold a card number.',
      'The app\'s path takes a provider-supplied brand identifier rather than '
          'digits, and the payload Step 207 permits already carries a brand '
          'field for exactly this -- so the two steps meet rather than '
          'contradict',
      () =>
          HabotCardBrandDetection.fromProviderIdentifier('visa') ==
              HabotCardBrand.visa &&
          HabotCardFormContract.payloadFields.contains('brand') &&
          !HabotCardFormContract.payloadFields.contains('cardNumber') &&
          HabotCardBrandDetection.tensionWithStep207Note
              .contains('every real card SDK emits'),
    );

    gate(
      'GEN-01551-G2',
      'Different SDKs spell the same brand differently.',
      'Casing and spacing variations all resolve, and an identifier the table '
          'does not know resolves to unknown rather than to a guess -- twelve '
          'provider spellings, all correct',
      () =>
          HabotCardBrandDetection.fromProviderIdentifier('MasterCard') ==
              HabotCardBrand.mastercard &&
          HabotCardBrandDetection.fromProviderIdentifier('master card') ==
              HabotCardBrand.mastercard &&
          HabotCardBrandDetection.fromProviderIdentifier(
                'American Express',
              ) ==
              HabotCardBrand.amex &&
          HabotCardBrandDetection.fromProviderIdentifier('elo') ==
              HabotCardBrand.unknown &&
          HabotCardBrandDetection.fromProviderIdentifier(null) ==
              HabotCardBrand.unknown &&
          HabotCardBrandDetection.identifierAccuracy == 1.0 &&
          HabotCardBrandDetection.providerIdentifierCases.length == 12,
    );

    gate(
      'GEN-01551-G3',
      '"The IIN table is the contract handed to the provider, not a code path '
          'in this app."',
      'The table is executable, so the contract can be checked rather than '
          'described: the published ranges resolve the four networks with '
          'test numbers, longest prefix wins, and the function that takes '
          'digits is named as not for use in this app',
      () =>
          HabotCardBrandDetection.fromIinForProviderSide(
                HabotCardFormContract.visaTestPan,
              ) ==
              HabotCardBrand.visa &&
          HabotCardBrandDetection.fromIinForProviderSide(
                HabotCardFormContract.amexTestPan,
              ) ==
              HabotCardBrand.amex &&
          HabotCardBrandDetection.fromIinForProviderSide('3528000000000000') ==
              HabotCardBrand.jcb &&
          HabotCardBrandDetection.fromIinForProviderSide('3612345678901') ==
              HabotCardBrand.diners &&
          HabotCardBrandDetection.fromIinForProviderSide('9999') ==
              HabotCardBrand.unknown &&
          HabotCardBrandDetection.notForAppUseNote
              .contains('the single thing Step 207 exists to prevent'),
    );

    gate(
      'GEN-01551-G4',
      'Luhn belongs on the provider side too, and belongs in the contract so '
          'it is not reimplemented at three call sites.',
      'The published test numbers pass and a number with one digit changed '
          'fails, so the check is doing arithmetic rather than matching a list',
      () =>
          HabotCardBrandDetection.luhnIsValid(
            HabotCardFormContract.visaTestPan,
          ) &&
          HabotCardBrandDetection.luhnIsValid(
            HabotCardFormContract.amexTestPan,
          ) &&
          HabotCardBrandDetection.luhnIsValid('5555555555554444') &&
          !HabotCardBrandDetection.luhnIsValid('4111111111111112') &&
          !HabotCardBrandDetection.luhnIsValid('41111111111111x1'),
    );
  });

  group('GEN-01551 :: what gets drawn', () {
    gate(
      'GEN-01551-G5',
      '"An empty slot reads as a broken field; a nearest guess is worse than '
          'nothing."',
      'An unrecognised brand renders a neutral card glyph with the accessible '
          'name "Card", so the field always shows something and never shows '
          'the wrong network',
      () =>
          HabotCardBrandDetection.unknownFallsBackToGeneric &&
          HabotCardBrandDetection.rendersSomething(HabotCardBrand.unknown) &&
          HabotCardBrandDetection.semanticLabelFor(
                HabotCardBrand.unknown,
              ) ==
              'Card' &&
          HabotCardBrandDetection.assetKeyFor(HabotCardBrand.unknown) ==
              'brand/generic' &&
          HabotCardBrandDetection.unknownIsARenderNote
              .contains('confidently wrong'),
    );

    gate(
      'GEN-01551-G6',
      'The row names three brands. UnionPay and Diners are accepted in this '
          'market and JCB arrives on visiting cards.',
      'Six real brands are in the table, the three the row named are marked as '
          'such and the three beyond it are marked as beyond it -- so the '
          'difference between what was asked for and what ships is visible '
          'rather than quietly added; and every brand carries a name, because '
          'an icon alone says nothing to a screen reader',
      () =>
          HabotCardBrandDetection.specs.length == 7 &&
          HabotCardBrandDetection.beyondTheRow.length == 3 &&
          HabotCardBrandDetection.specs
                  .where((HabotCardBrandSpec s) => s.namedInRow)
                  .length ==
              3 &&
          HabotCardBrandDetection.specs.every(
            (HabotCardBrandSpec s) =>
                HabotCardBrandDetection.semanticLabelFor(s.brand).isNotEmpty,
          ) &&
          HabotCardBrandDetection.threeBrandsIsNotTheMarketNote
              .contains('quietly added'),
    );

    gate(
      'GEN-01551-G7',
      'Metric: Icon Recognition Accuracy -- floor 0.8, optimal 0.95.',
      'Identifier mapping and render coverage each reach 1.0, giving 1.0 '
          'overall and a Good -- and the artwork dependency is recorded as a '
          'delivery item rather than satisfied with a redrawn approximation, '
          'which would be a trademark problem and a recognition problem at '
          'once',
      () {
        recognition = HabotCardBrandDetection.iconRecognitionAccuracy;
        return recognition == 1.0 &&
            HabotCardBrandDetection.renderAccuracy == 1.0 &&
            recognition >= HabotCardBrandDetection.optimal &&
            HabotCardBrandDetection.qualitativeOutput == 'Good' &&
            HabotCardBrandDetection.trademarkedArtworkNote
                .contains('brand kit') &&
            HabotCardBrandDetection.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01551',
        atomicStepReferenceId: 'GEN-01551',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Attach visual card brand detection logic to render Visa, '
            'Mastercard, or AMEX icons dynamically upon card entry."',
        implementationOrder: 208,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCardBrandDetection / HabotCardBrandSpec',
          'Component Properties':
              '${HabotCardBrandDetection.specs.length} declared brands '
              'including the generic fallback, '
              '${HabotCardBrandDetection.beyondTheRow.length} of them beyond '
              'the row; app path takes a provider identifier and never '
              'digits; IIN ranges and Luhn published as the provider-side '
              'contract; every brand carries an accessible name',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: this row and Step 207 point in opposite directions. '
              'Brand detection conventionally reads the first six to eight '
              'digits of the account number; Step 207\'s requirement is that '
              'the app is never in a position to see any of them. Both are '
              'right. The reconciliation is that the brand arrives from the '
              'hosted field, which is already looking, through the callback '
              'every real card SDK emits for exactly this reason -- and Step '
              '207\'s permitted payload already carries a brand field. The IIN '
              'table here is the contract handed to the provider, kept '
              'executable so the contract can be checked, with the function '
              'that accepts digits marked as not for use in this app. SECOND '
              'FINDING: three brands is not this market. UnionPay and Diners '
              'are accepted here and JCB arrives on visiting cards; they are '
              'in the table and marked as beyond the row. An unrecognised '
              'brand renders a neutral glyph named "Card" -- an empty slot '
              'reads as a broken field and a nearest guess is confidently '
              'wrong at the moment someone is entering their card. DELIVERY '
              'DEPENDENCY: brand marks are trademarks and a redrawn '
              'approximation is a legal problem and a recognition problem at '
              'once; each asset key points at artwork from that network\'s own '
              'brand kit.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Icon Recognition Accuracy',
            observed:
                '${recognition.toStringAsFixed(2)} -- the mean of identifier '
                'mapping (12 of 12 provider spellings, including casing and '
                'spacing variants and two that must resolve to unknown) and '
                'render coverage (7 of 7 brands render a mark with an '
                'accessible name).',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Account-number digits read by this app',
            observed:
                '0. The brand arrives as an identifier string. The IIN table '
                'and the Luhn check are published for the provider side and '
                'are exercised here against the networks\' own test numbers, '
                'which is the only place digits appear in this repository.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/payments/card_brand.dart',
        ],
      ),
    );
  });
}
