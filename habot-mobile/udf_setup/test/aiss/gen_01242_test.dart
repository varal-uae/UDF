/// AISS GATE -- Step 207 of 215
/// Global Reference ID:       GEN-01242
/// Atomic Steps Reference ID: GEN-01242
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Embed tokenized PCI-DSS compliant card input form fields
///               using @habot/payments/card-form."
/// Metric: PCI-DSS Field Tokenization Compliance -- Floor "Pass required",
///         Optimal "Pass (Level 1)", Ceiling "Pass (Level 1)". Pass/Fail.
///
/// THE COMPLIANCE PROPERTY IS A NEGATIVE ONE: the app is never in a position
/// to hold a card number. A declared field list is a statement a reviewer can
/// read and a test can assert on; an absence has to be noticed.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/payments/card_form_contract.dart';
import 'package:udf_setup/design_system/resilience/log_scrubber.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double scrubberCoverage = 0;

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

  void deferredGate(String id, String source, String description, String why) {
    test('[$id] (DEFERRED) $description', () {
      gates.add(
        AissGate(
          id: id,
          requirementSource: source,
          description: description,
          passed: false,
          deferred: true,
          detail: why,
        ),
      );
      expect(why.isNotEmpty, isTrue);
    });
  }

  group('GEN-01242 :: what the app may hold', () {
    gate(
      'GEN-01242-G1',
      'Atomic Step: "TOKENIZED PCI-DSS compliant card input form fields."',
      'The permitted payload is a declared list of five fields, none of which '
          'could hold cardholder data, and the ten field names that would mean '
          'it does are listed so a future addition has to be made deliberately',
      () =>
          HabotCardFormContract.payloadFields.length == 5 &&
          HabotCardFormContract.forbiddenFields.length == 10 &&
          HabotCardFormContract.payloadCarriesNoCardholderData &&
          HabotCardFormContract.payloadFields.contains('token') &&
          !HabotCardFormContract.payloadFields.contains('cardNumber') &&
          HabotCardFormContract.complianceIsANegativeNote
              .contains('never in a position to'),
    );

    gate(
      'GEN-01242-G2',
      '"Rendering a TextField and calling a tokenise API afterwards satisfies '
          'the row\'s wording and fails its intent."',
      'Only provider-hosted fields are admitted, and the two arrangements that '
          'are not admitted carry their consequences -- SAQ A-EP for '
          'app-rendered-then-tokenised, full DSS scope for app-rendered-then-'
          'posted -- so the difference is stated rather than glossed',
      () =>
          HabotCardFormContract.requiredHosting ==
              HabotCardFieldHosting.providerHosted &&
          HabotCardFormContract.hostingIsCompliant(
            HabotCardFieldHosting.providerHosted,
          ) &&
          !HabotCardFormContract.hostingIsCompliant(
            HabotCardFieldHosting.appRenderedThenTokenised,
          ) &&
          HabotCardFormContract.saqTypeFor(
                HabotCardFieldHosting.providerHosted,
              ) ==
              'SAQ A' &&
          HabotCardFormContract.saqTypeFor(
                HabotCardFieldHosting.appRenderedThenTokenised,
              ) ==
              'SAQ A-EP' &&
          HabotCardFieldHosting.values.length == 3,
    );

    gate(
      'GEN-01242-G3',
      'Metric: "Pass (Level 1)". Level 1 is a MERCHANT level set by annual '
          'transaction volume.',
      'The conflation is recorded: no client code makes an app Level 1, what '
          'client code decides is the validation type, and the four '
          'displayable digits are enforced rather than trusted',
      () =>
          HabotCardFormContract.levelIsNotAValidationTypeNote
              .contains('MERCHANT level') &&
          HabotCardFormContract.levelIsNotAValidationTypeNote
              .contains('fails its intent') &&
          HabotCardFormContract.permittedDigits == 4 &&
          HabotCardFormContract.lastFourIsWellFormed('4242') &&
          !HabotCardFormContract.lastFourIsWellFormed('42424') &&
          !HabotCardFormContract.lastFourIsWellFormed('42a2'),
    );

    gate(
      'GEN-01242-G4',
      'Substitution: "@habot/payments/card-form" is an NPM specifier.',
      'The specifier is kept so the sheet resolves, the substitution says why '
          'it cannot be a dependency here, and what is built is the contract '
          'that decides whether the compliance claim is true',
      () =>
          HabotCardFormContract.rowSpecifier ==
              '@habot/payments/card-form' &&
          HabotCardFormContract.substitution.contains('JavaScript') &&
          HabotCardFormContract.substitution
              .contains('no network on this host') &&
          HabotCardFormContract.isCompliant &&
          HabotCardFormContract.complianceChecks.length == 7 &&
          HabotCardFormContract.qualitativeOutput == 'Pass',
    );
  });

  group('GEN-01242 :: defence in depth, and a gap in it', () {
    gate(
      'GEN-01242-G5',
      'Step 68\'s log scrubber is the last line if a number ever reaches a '
          'log. Its coverage of card numbers was never stated.',
      'Measured: one of four PAN shapes is redacted. A 16-digit number is '
          'caught by the `hex` rule -- sixteen or more hexadecimal characters, '
          'and decimal digits are hexadecimal -- while a 15-digit American '
          'Express number and any PAN written with spaces or dashes match '
          'nothing at all',
      () {
        scrubberCoverage = HabotCardFormContract.scrubberCoverageRate;
        final Map<String, bool> c = HabotCardFormContract.scrubberCoverage;
        return c['16-digit PAN']! &&
            !c['15-digit AMEX PAN']! &&
            !c['PAN with spaces']! &&
            !c['PAN with dashes']! &&
            scrubberCoverage == 0.25 &&
            HabotLogScrubber.firedRules(
              HabotCardFormContract.visaTestPan,
            ).contains('hex') &&
            HabotLogScrubber.firedRules(
              HabotCardFormContract.amexTestPan,
            ).isEmpty &&
            HabotCardFormContract.incidentalCoverageNote
                .contains('real and accidental');
      },
    );

    gate(
      'GEN-01242-G6',
      'A rule is proposed rather than copied, because "two copies with only '
          'one of them executed is drift by construction" -- Step 179.',
      'The proposed rule covers all four shapes and is declared here as a '
          'proposal against the file that owns the rule set, not applied from '
          'a file that does not',
      () =>
          HabotCardFormContract.proposedRuleCoversEverything &&
          HabotCardFormContract.proposedPanRule.hasMatch(
            HabotCardFormContract.amexTestPan,
          ) &&
          HabotCardFormContract.proposedPanRule.hasMatch(
            HabotCardFormContract.dashedTestPan,
          ) &&
          !HabotCardFormContract.proposedPanRule.hasMatch('2026') &&
          HabotCardFormContract.openItemNote
              .contains('log_scrubber.dart'),
    );

    deferredGate(
      'GEN-01242-G7',
      'Step 68 owns lib/design_system/resilience/log_scrubber.dart.',
      'A PAN rule is added to the Step 68 scrubber so a 15-digit American '
          'Express number and a separator-formatted PAN are redacted rather '
          'than relying on the hex rule catching 16 digits by coincidence',
      'The rule set belongs to Step 68 and adding a second copy here would '
          'produce two rules with only one of them executed. Raised as an '
          'open item with the regular expression and the four test vectors '
          'ready. The contract above means no PAN should ever reach a log; '
          'this is the layer that assumes it did.',
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01242',
        atomicStepReferenceId: 'GEN-01242',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Embed tokenized PCI-DSS compliant card input form fields '
            'using @habot/payments/card-form."',
        implementationOrder: 207,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCardFormContract / HabotCardToken',
          'Component Properties':
              '${HabotCardFormContract.payloadFields.length} permitted payload '
              'fields and ${HabotCardFormContract.forbiddenFields.length} '
              'named forbidden ones; '
              '${HabotCardFieldHosting.values.length} hosting arrangements '
              'each with its SAQ consequence, one of them admitted; '
              '${HabotCardFormContract.permittedDigits} displayable digits, '
              'enforced',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION: @habot/payments/card-form is an NPM specifier; '
              'NPM is JavaScript\'s registry, a Dart package name may not '
              'contain @ or /, and there is no network on this host. What is '
              'built is the contract the hosted field must satisfy. FINDING: '
              '"Pass (Level 1)" joins two different things. Level 1 is a '
              'MERCHANT level set by annual transaction volume and no client '
              'code makes an app Level 1 or stops it being Level 1. What '
              'client code decides is the VALIDATION TYPE -- provider-hosted '
              'fields keep the merchant on SAQ A, while an app that renders '
              'its own inputs and tokenises them afterwards is SAQ A-EP '
              'however briefly it held the number. Rendering a TextField and '
              'calling a tokenise API satisfies the row\'s wording and fails '
              'its intent. DEFECT FOUND IN EXISTING CODE: the Step 68 log '
              'scrubber redacts a 16-digit PAN only incidentally, through its '
              '`hex` rule matching sixteen or more hexadecimal characters -- '
              'decimal digits are hexadecimal characters. A 15-digit American '
              'Express number is one character short of it and a PAN written '
              'with spaces or dashes, which is how a number arrives in a '
              'support message, matches nothing. Coverage measured at 0.25. '
              'A rule is proposed rather than applied: the rule set belongs to '
              'Step 68, and two copies with only one executed is the defect '
              'Step 179 wrote its catalogue to avoid. ONE DEFERRED GATE.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'PCI-DSS Field Tokenization Compliance',
            observed:
                'Pass on the contract: provider-hosted fields only, a payload '
                'of ${HabotCardFormContract.payloadFields.length} fields none '
                'of which can hold cardholder data, four displayable digits '
                'enforced, and the brand taken from the field rather than read '
                'from the number. The merchant level in the row is a volume '
                'band and is not claimed by client code.',
            floor: 'Pass required',
            optimal: 'Pass (Level 1)',
            ceiling: 'Pass (Level 1)',
          ),
          AissMeasurement(
            metricName: 'Log scrubber PAN coverage (defence in depth)',
            observed:
                '${scrubberCoverage.toStringAsFixed(2)} -- 1 of 4 shapes. '
                '16-digit redacted (incidentally, by the hex rule); 15-digit '
                'AMEX not; space-separated not; dash-separated not. Raised as '
                'a deferred open item against the file that owns the rule set.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/payments/card_form_contract.dart',
        ],
      ),
    );
  });
}
