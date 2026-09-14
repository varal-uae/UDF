/// AISS GATE -- Step 244 of 255
/// Global Reference ID:       GEN-03281
/// Atomic Steps Reference ID: GEN-03281
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Add automated document validation filters checkingForm I-9
///               and Tax ID formatting."
/// Metric: Doc Validation Pass Rate -- Floor 0.999, Optimal 1, Ceiling 1.
///         Pass. Standard cited: Form I-9 / Tax ID Format Rules.
///
/// A FORM IS NOT AN IDENTIFIER, THIS IS A US ROW IN AN APPLICATION THAT IS NOT
/// US, AND THREE IDENTIFIERS GIVE A CLIENT THREE DIFFERENT AMOUNTS OF
/// CERTAINTY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/identity_document_rules.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double rate = 0;

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

  group('GEN-03281 :: what the row is asking about', () {
    gate(
      'GEN-03281-G1',
      'Atomic Step: "checking Form I-9 ... formatting."',
      'Form I-9 is a form and has no format to validate; what has formats are '
          'the identifiers on it, so the row resolves to validating those and '
          'treating the form as a checklist of which are required together',
      () =>
          HabotIdentityDocumentRules.formIsNotAnIdentifierNote
              .contains('category error') &&
          HabotIdentityDocumentRules.rowConcept
              .contains('Form I-9 and Tax ID'),
    );

    gate(
      'GEN-03281-G2',
      'Step 236 recorded two jurisdictions already assumed; this row adds a '
          'third.',
      'Every identifier rule names the authority whose rules it encodes, and '
          'the Emirates ID -- the identifier this application\'s own market '
          'issues, which the row does not mention -- is declared beside the '
          'two the row asks for',
      () =>
          HabotIdentityDocumentRules.rules.length == 3 &&
          HabotIdentityDocumentRules.everyRuleNamesItsJurisdiction &&
          HabotIdentityDocumentRules.ruleNamed('Emirates ID')
              .jurisdiction
              .contains('United Arab') &&
          HabotIdentityDocumentRules.jurisdictionNote.contains('Kenyan'),
    );

    gate(
      'GEN-03281-G3',
      'Step 243: an IBAN carries a published, permanent check digit.',
      'None of these three does. The EIN prefix list moves and the Emirates ID '
          'algorithm is unpublished, so no rule here claims certainty it does '
          'not have and each names what the server must still do',
      () =>
          HabotClientCertainty.values.length == 3 &&
          HabotIdentityDocumentRules.rules.every(
            (HabotIdentifierRule r) => !r.clientCanBeCertain,
          ) &&
          HabotIdentityDocumentRules.noRuleClaimsCertaintyItDoesNotHave &&
          HabotIdentityDocumentRules.threeCertaintiesNote
              .contains('means nothing'),
    );

    gate(
      'GEN-03281-G4',
      '"The SSA publishes ranges that are never issued, not ranges that are."',
      'The predicate is named for what it can actually assert -- a client can '
          'say this cannot be a Social Security number and can never say this '
          'is one -- because the field label and the error message follow the '
          'method name eventually',
      () =>
          HabotIdentityDocumentRules.plausibleNotValidNote
              .contains('never say') &&
          HabotIdentityDocumentRules.ruleNamed('Social Security')
              .serverSideCheck
              .isNotEmpty,
    );
  });

  group('GEN-03281 :: the filters', () {
    gate(
      'GEN-03281-G5',
      'Form I-9 / Tax ID Format Rules.',
      'The five never-issued rules classify a ten-vector suite, and the '
          'boundary is tested at both ends -- 899 is plausible and 999 is not '
          '-- so the range check is not off by one',
      () =>
          HabotIdentityDocumentRules.ssnSuiteClassifiesCorrectly &&
          HabotIdentityDocumentRules.ssnSuite.length == 10 &&
          HabotIdentityDocumentRules.ssnIsPlausible('899-45-6789') &&
          !HabotIdentityDocumentRules.ssnIsPlausible('999-45-6789') &&
          HabotIdentityDocumentRules.neverIssuedReasonsFor('000-45-6789')
              .single
              .contains('000'),
    );

    gate(
      'GEN-03281-G6',
      'A shape check is not a rule set.',
      'Shape alone -- three digits, two digits, four digits -- classifies '
          'fewer of the same suite correctly than the published ranges do, so '
          'the ranges are earning their place rather than decorating a regex',
      () =>
          HabotIdentityDocumentRules.ssnShapeOnlyAccuracy <
              HabotIdentityDocumentRules.ssnStructureAccuracy &&
          (HabotIdentityDocumentRules.ssnShapeOnlyAccuracy - 0.4).abs() <
              1e-9 &&
          HabotIdentityDocumentRules.ssnStructureAccuracy == 1.0,
    );

    gate(
      'GEN-03281-G7',
      'Doc Validation Pass Rate -- floor 0.999, Pass.',
      'All ten checks hold and all sixteen vectors across the three suites are '
          'classified correctly, giving 1.0 -- reported over classification '
          'rather than over confidence, because the three identifiers do not '
          'offer the same kind of it',
      () {
        rate = HabotIdentityDocumentRules.docValidationPassRate;
        return HabotIdentityDocumentRules.checks.length == 10 &&
            HabotIdentityDocumentRules.checks.values.every((bool b) => b) &&
            rate == 1.0 &&
            rate >= HabotIdentityDocumentRules.floor &&
            HabotIdentityDocumentRules.einSuiteClassifiesCorrectly &&
            HabotIdentityDocumentRules.emiratesSuiteClassifiesCorrectly &&
            HabotIdentityDocumentRules.qualitativeOutput == 'Pass' &&
            HabotIdentityDocumentRules.columnNote.contains('checkingForm');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03281',
        atomicStepReferenceId: 'GEN-03281',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row and the '
            'Data Collected column reads only "checkingForm" -- the tail of a '
            'missing space in the Atomic Step. Atomic Step: "Add automated '
            'document validation filters checkingForm I-9 and Tax ID '
            'formatting."',
        implementationOrder: 244,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotIdentityDocumentRules / HabotIdentifierRule / '
              'HabotClientCertainty',
          'Component Properties':
              '${HabotIdentityDocumentRules.rules.length} identifier rules, '
              'each naming its jurisdiction, its structure, how sure a client '
              'can be and what the server must still do; '
              '${HabotIdentityDocumentRules.ssnSuite.length} SSN vectors, '
              '${HabotIdentityDocumentRules.einSuite.length} EIN and '
              '${HabotIdentityDocumentRules.emiratesSuite.length} Emirates ID',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'CATEGORY: '
              '${HabotIdentityDocumentRules.formIsNotAnIdentifierNote} '
              'JURISDICTION: ${HabotIdentityDocumentRules.jurisdictionNote} '
              'FINDING: ${HabotIdentityDocumentRules.threeCertaintiesNote} '
              'NAMING: ${HabotIdentityDocumentRules.plausibleNotValidNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Doc Validation Pass Rate',
            observed:
                '${rate.toStringAsFixed(3)} over sixteen vectors across three '
                'identifiers. Reported over classification rather than over '
                'confidence: the three do not offer the same kind of it, and '
                'averaging them would produce a number about nothing.',
            floor: '0.999',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Identifiers a client can be certain about',
            observed:
                '0 of ${HabotIdentityDocumentRules.rules.length}. An IBAN '
                'carries a published, permanent check digit and none of these '
                'three does -- the EIN prefix list moves and the Emirates ID '
                'algorithm is unpublished -- so each names its server-side '
                'obligation instead.',
            floor: 'n/a -- descriptive',
            optimal: 'n/a -- descriptive',
            ceiling: 'n/a -- descriptive',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/identity_document_rules.dart',
        ],
      ),
    );
  });
}
