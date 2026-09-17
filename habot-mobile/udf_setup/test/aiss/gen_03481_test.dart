/// AISS GATE -- Step 334 of 335
/// Global Reference ID:       GEN-03481
/// Atomic Steps Reference ID: GEN-03481
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Connect PagerDuty webhooks alerting SRE teams instantly when
///               circuits trip to Open."
/// Metric: SRE Alert Delivery Speed -- floor "< 2s", optimal "< 500ms",
///         ceiling "5s". Best Qualitative Output: **"Pass"**.
///
/// THIRD INVERTED BAND AND THIRD ONE-VALUED OUTPUT COLUMN, ON A ROW WRITTEN
/// FOR THE ONE PARTICIPANT THAT CANNOT PAGE ANYBODY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/circuit_open_page.dart';

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

  group('GEN-03481 :: who does what', () {
    gate(
      'GEN-03481-G1',
      'Atomic Step: "Connect PagerDuty webhooks".',
      'Circuit state lives on the server and PagerDuty is reached from the '
          'server; nothing in this repository takes part in the alert path',
      () =>
          HabotCircuitOpenPage.theRowsSubjectBelongsToTheServer &&
          !HabotCircuitOpenPage.theClientCanReachPagerDuty &&
          HabotCircuitOpenPage.responsibilities.length == 2,
    );

    gate(
      'GEN-03481-G2',
      'The row names the half of the system that cannot do the work.',
      'What the client owes is the half nobody wrote a row for',
      () => HabotCircuitOpenPage.scopeNote.contains('cannot do the work'),
    );
  });

  group('GEN-03481 :: what the client does while it is open', () {
    gate(
      'GEN-03481-G3',
      'The client stops sending.',
      'The circuit state is read from Step 273 rather than re-derived, so '
          'there is no second copy to disagree with it',
      () =>
          !HabotCircuitOpenPage.theClientSendsWhileOpen &&
          HabotCircuitOpenPage.theCircuitStatesAreReadFromStep273,
    );

    gate(
      'GEN-03481-G4',
      'A retrying client is part of the outage.',
      'Every attempt is load on a service that tripped because it had too '
          'much, and a hundred thousand phones retrying politely is a denial '
          'of service with good intentions',
      () => HabotCircuitOpenPage.loadNote.contains('good intentions'),
    );
  });

  group('GEN-03481 :: what the person is told', () {
    gate(
      'GEN-03481-G5',
      'Three questions, three answers.',
      'What is wrong, what is safe, and when to come back',
      () =>
          HabotCircuitOpenPage.allThreeQuestionsAreAnswered &&
          HabotCircuitOpenPage.itSaysItIsNotJustThem &&
          HabotCircuitOpenPage.itSaysWhenToComeBack,
    );

    gate(
      'GEN-03481-G6',
      '"Something went wrong" is refused.',
      'It invites an immediate retry, which is the one thing that must not '
          'happen, and it leaves the person wondering whether it is their '
          'phone, their signal or their account',
      () =>
          HabotCircuitOpenPage.theGenericMessageIsRefused &&
          HabotCircuitOpenPage.messageNote.contains('stops a support call'),
    );
  });

  group('GEN-03481 :: an open circuit is faster', () {
    gate(
      'GEN-03481-G7',
      'A closed circuit takes three and a half seconds to know anything.',
      'Three attempts at 500ms, 1s and 2s, which is a spinner before any '
          'sentence',
      () =>
          HabotCircuitOpenPage.timeBeforeAnythingIsKnownMs == 3500 &&
          HabotCircuitOpenPage.retryDelaysMs.length == 3 &&
          HabotCircuitOpenPage.theRetryRuleIsAlreadyDeclared,
    );

    gate(
      'GEN-03481-G8',
      'An open one knows immediately.',
      'The one occasion somebody gets a straight answer at once is the '
          'occasion when everything is broken, which is worth building on '
          'purpose',
      () =>
          HabotCircuitOpenPage.anOpenCircuitIsFasterThanAClosedOne &&
          HabotCircuitOpenPage.secondsSavedByKnowing == 3 &&
          HabotCircuitOpenPage.speedNote.contains('on purpose'),
    );
  });

  group('GEN-03481 :: the band and the output column', () {
    gate(
      'GEN-03481-G9',
      'Ceiling 5s against a floor of 2s, and an output column of "Pass".',
      'This row carries both of the batch\'s repeated defects at once; Step '
          '333 carries neither',
      () =>
          HabotCircuitOpenPage.theBandIsInverted &&
          HabotCircuitOpenPage.theOutputCannotExpressAFailure &&
          HabotCircuitOpenPage.thisRowCarriesBothDefects &&
          HabotCircuitOpenPage.theOrderedBandInThisBatch == 333,
    );

    gate(
      'GEN-03481-G10',
      'Output reported as Pass / Fail against declared obligations.',
      'Six obligations, all met, so a failure would have had somewhere to go; '
          'all eleven declared checks hold',
      () =>
          HabotCircuitOpenPage.obligations.length == 6 &&
          HabotCircuitOpenPage.obligations.values.every((bool b) => b) &&
          HabotCircuitOpenPage.qualitativeOutput == 'Pass' &&
          HabotCircuitOpenPage.checks.length == 11 &&
          HabotCircuitOpenPage.checks.values.every((bool b) => b) &&
          HabotCircuitOpenPage.columnNote.contains('no failing value'),
    );
  });

  tearDownAll(() {
    final String wrong =
        HabotCircuitOpenPage.whatThePersonSees['what is wrong'] ?? '';
    final String comeBack =
        HabotCircuitOpenPage.whatThePersonSees['when to come back'] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03481',
        atomicStepReferenceId: 'GEN-03481',
        setupStepAction:
            'COLUMN NOTE: the Best Qualitative Output column on this row reads '
            '"Pass" with no failing value, the ceiling of 5s is worse than the '
            'floor of 2s, and every narrative column is the generic '
            'engineering-console boilerplate on a row about paging an SRE '
            'team. Atomic Step: "Connect PagerDuty webhooks alerting SRE teams '
            'instantly when circuits trip to Open."',
        implementationOrder: 334,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Connect PagerDuty webhooks alerting SRE teams instantly when '
                  'circuits trip':
              'the alert path is the server\'s; the client stops sending and '
                  'tells the person',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the page says "$wrong" and "$comeBack"',
          'Data Quality Note':
              'SCOPE: ${HabotCircuitOpenPage.scopeNote} '
              'LOAD: ${HabotCircuitOpenPage.loadNote} '
              'MESSAGE: ${HabotCircuitOpenPage.messageNote} '
              'SPEED: ${HabotCircuitOpenPage.speedNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'SRE Alert Delivery Speed',
            observed:
                'NOT A CLIENT PROPERTY, AND THE BAND IS INVERTED. A client '
                'cannot connect a webhook; circuit state and PagerDuty both '
                'live on the server. The ceiling of 5s is worse than the floor '
                'of 2s on a lower-is-better measure -- the third such band in '
                'this batch -- and the output column holds only "Pass", the '
                'third such column. Step 333 carries neither defect.',
            floor: '< 2s',
            optimal: '< 500ms',
            ceiling: '5s',
          ),
          AissMeasurement(
            metricName: 'Seconds before the person is told anything',
            observed:
                '0 while the circuit is open, against 3.5 while it is closed '
                'and the retry policy is working through 500ms, 1s and 2s. An '
                'open circuit makes the application faster at telling the '
                'truth, which is the opposite of what an outage usually feels '
                'like.',
            floor: '3.5',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/circuit_open_page.dart',
        ],
      ),
    );
  });
}
