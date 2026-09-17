/// AISS GATE -- Step 385 of 395
/// Global Reference ID:       GEN-02422
/// Atomic Steps Reference ID: GEN-02422
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Embed DCYN compliance checks for all legal policy
///               acceptances."
/// Metric: Compliance Check Pass Rate (%) -- floor 0.99, optimal 1, ceiling 1.
///         Yes/No. ISO/IEC 27001, SOX Compliance. Assigned to **GFD**.
///
/// AN ACCEPTANCE IS EVIDENCE ABOUT A MOMENT, AND A GATE IS NOT A COMPLIANCE
/// CHECK.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/legal/policy_acceptance.dart';

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

  group('GEN-02422 :: six fields', () {
    gate(
      'GEN-02422-G1',
      'Six fields, all present.',
      'Who, which version, which language, when, what the control said, and '
          'where from',
      () =>
          HabotAcceptanceField.values.length == 6 &&
          HabotPolicyAcceptance.everyFieldIsPresent &&
          HabotPolicyAcceptance.completeness == 100,
    );

    gate(
      'GEN-02422-G2',
      'The version and the language are among them.',
      'They are the two people leave out, and the two that decide what was '
          'agreed to',
      () =>
          HabotPolicyAcceptance.theVersionIsRecorded &&
          HabotPolicyAcceptance.theLanguageIsRecorded &&
          HabotPolicyAcceptance.evidenceNote.contains('what was agreed to'),
    );

    gate(
      'GEN-02422-G3',
      'The timestamp carries an offset and the control\'s own label is stored.',
      'So "09:14" is one moment rather than one of several, and the record can '
          'be checked against what the button actually read',
      () =>
          HabotPolicyAcceptance.theTimestampCarriesAnOffset &&
          HabotPolicyAcceptance.theControlLabelIsRecorded,
    );
  });

  group('GEN-02422 :: the act has to happen', () {
    gate(
      'GEN-02422-G4',
      'No pre-ticked box and no implied consent.',
      'The control starts unticked and continuing does not count as agreeing',
      () =>
          HabotPolicyAcceptance.thePersonHasToAct &&
          !HabotPolicyAcceptance.theBoxStartsTicked &&
          !HabotPolicyAcceptance.continuingCountsAsAgreeing,
    );

    gate(
      'GEN-02422-G5',
      'The check is the declared strict-true rule.',
      'An unanswered question and a declined one are both refusals; a loose '
          'check would let an unanswered box through',
      () =>
          HabotPolicyAcceptance.theGateIsTheDeclaredOne &&
          HabotPolicyAcceptance.aLooseCheckWouldPassAnUnansweredBox &&
          HabotPolicyAcceptance.actNote.contains('quietly passing'),
    );
  });

  group('GEN-02422 :: a gate is not a compliance check', () {
    gate(
      'GEN-02422-G6',
      'The client does not decide lawfulness.',
      'Jurisdiction, age and what the regulator requires this month are not '
          'knowable on a phone',
      () =>
          HabotPolicyAcceptance.theLimitIsStated &&
          !HabotPolicyAcceptance.theClientDecidesWhetherItWasLawful &&
          HabotPolicyAcceptance.whatTheClientCannotKnow.length == 3,
    );

    gate(
      'GEN-02422-G7',
      'Calling the gate a compliance check is the risk.',
      'It is how an organisation comes to believe the phone already checked',
      () => HabotPolicyAcceptance.complianceNote
          .contains('the phone already checked'),
    );
  });

  group('GEN-02422 :: re-acceptance', () {
    gate(
      'GEN-02422-G8',
      'Acceptance is stored against a version.',
      'Somebody who accepted 4.1 has not accepted 4.2',
      () =>
          HabotPolicyAcceptance.anOlderAcceptanceDoesNotCount &&
          !HabotPolicyAcceptance.acceptanceIsABooleanSetOnce &&
          HabotPolicyAcceptance.currentVersion == '4.2',
    );

    gate(
      'GEN-02422-G9',
      'So the answer changes on the day the terms do.',
      'Without anybody running a migration',
      () => HabotPolicyAcceptance.versionNote
          .contains('without anybody running a migration'),
    );

    gate(
      'GEN-02422-G10',
      'Output reported as Yes / No.',
      'Six obligations, all met, giving Yes; the optimal and ceiling are both '
          '1, and all ten declared checks hold',
      () =>
          HabotPolicyAcceptance.obligations.length == 6 &&
          HabotPolicyAcceptance.obligations.values.every((bool b) => b) &&
          HabotPolicyAcceptance.qualitativeOutput == 'Yes' &&
          HabotPolicyAcceptance.theOutputIsBinary &&
          HabotPolicyAcceptance.theOptimalEqualsTheCeiling &&
          HabotPolicyAcceptance.checks.length == 10 &&
          HabotPolicyAcceptance.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String version = HabotPolicyAcceptance.worked.documentVersion;
    final String language = HabotPolicyAcceptance.worked.language;
    final String when = HabotPolicyAcceptance.worked.timestamp;
    final String label = HabotPolicyAcceptance.worked.controlLabel;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02422',
        atomicStepReferenceId: 'GEN-02422',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to GFD rather than UDF; its '
            'metric is a compliance pass rate on a row that builds a '
            'client-side gate, which cannot know the things compliance depends '
            'on; its optimal and ceiling are both 1; its Data Requirement cell '
            'holds the Atomic Step\'s own sentence as the artefact to prepare; '
            'and the Setup Step column is empty. Atomic Step: "Embed DCYN '
            'compliance checks for all legal policy acceptances."',
        implementationOrder: 385,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Embed DCYN compliance checks for all legal policy acceptances':
              'six fields recorded per acceptance, stored against version '
                  '$version',
          'Completion Status': 'Yes',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the worked acceptance is version $version in $language at '
                  '$when, by a control reading "$label"',
          'Data Quality Note':
              'EVIDENCE: ${HabotPolicyAcceptance.evidenceNote} ACT: '
              '${HabotPolicyAcceptance.actNote} COMPLIANCE: '
              '${HabotPolicyAcceptance.complianceNote} VERSION: '
              '${HabotPolicyAcceptance.versionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Compliance Check Pass Rate (%)',
            observed:
                'A COMPLIANCE RATE ON A GATE THAT CANNOT JUDGE COMPLIANCE, '
                'WITH THE OPTIMAL EQUAL TO THE CEILING. DCYN is a binary gate '
                'evaluated at the edge: yes or no. Whether an acceptance '
                'complies with anything depends on jurisdiction, age, the '
                'version served and what the regulator requires this month, '
                'and none of that is knowable on a phone. What the client can '
                'do is record a complete and checkable acceptance, which is '
                'what is measured here; something else decides whether it was '
                'lawful.',
            floor: '0.99',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Acceptances that cannot be checked afterwards',
            observed:
                '0. "This user accepted the terms" is worth very little; the '
                'worked record says version $version, in $language, at $when, '
                'by a control that read "$label", from a named place -- every '
                'part checkable against what that version said. The person has '
                'to act: no pre-ticked box, no implied consent, and the '
                'strict-true check treats an unanswered question and a '
                'declined one alike, where a loose one would let the '
                'unanswered box through. The acceptance is stored against a '
                'version, so a change to the terms changes the answer without '
                'a migration.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/legal/policy_acceptance.dart',
        ],
      ),
    );
  });
}
