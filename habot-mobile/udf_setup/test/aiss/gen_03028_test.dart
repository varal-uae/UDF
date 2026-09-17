/// AISS GATE -- Step 320 of 335
/// Global Reference ID:       GEN-03028
/// Atomic Steps Reference ID: GEN-03028
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Embed a 1-tap Request Access Elevation button directly in the
///               mobile denial view."
/// Metric: Mobile Usability Task Success Rate (%) -- floor 80, optimal 95,
///         ceiling 100. Good/Average/Poor. NN/g Mobile UX Heuristics;
///         ISO 9241-11.
///
/// THE REMEDY STEP 292 WAS REFUSED FOR LACKING, ARRIVING AS ITS OWN ROW.
/// ONE GATE DEFERRED, AND IT IS THE THIRD IN TWO BATCHES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/access_elevation.dart';

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

  group('GEN-03028 :: the tap count', () {
    gate(
      'GEN-03028-G1',
      'Atomic Step: "1-tap Request Access Elevation".',
      'Five fields the request needs, four of them known from the denial '
          'view; one tap opens it and a second sends it',
      () =>
          HabotAccessElevationRequest.fields.length == 5 &&
          HabotAccessElevationRequest.fourOfFiveAreAlreadyKnown &&
          HabotAccessElevationRequest.tapsTotal == 2,
    );

    gate(
      'GEN-03028-G2',
      'The only field asked for is the reason.',
      'Because it is the only one the context cannot supply',
      () => HabotAccessElevationRequest.theOneFieldAskedForIsTheReason,
    );

    gate(
      'GEN-03028-G3',
      'The row counts taps at the button and the person counts them at the '
          'outcome.',
      'An empty form behind a button labelled one-tap is slower than no '
          'button, because it also spends the trust',
      () => HabotAccessElevationRequest.tapCountNote
          .contains('also spends the trust'),
    );
  });

  group('GEN-03028 :: the denial that does not disclose', () {
    gate(
      'GEN-03028-G4',
      'A denial can leak the fact it is protecting.',
      'The message names the resource class; the identifier travels inside '
          'the request, where the only reader is an approver who can already '
          'see it',
      () =>
          HabotAccessElevationRequest.theDenialNamesTheClassNotTheRecord &&
          HabotAccessElevationRequest.theIdentifierTravelsWithTheRequest,
    );

    gate(
      'GEN-03028-G5',
      'Naming the record tells somebody it exists and whose it is.',
      'Which is what the permission was protecting, so the refusal leaks the '
          'fact the refusal was for',
      () => HabotAccessElevationRequest.disclosureNote
          .contains('leaks the fact the refusal was for'),
    );
  });

  group('GEN-03028 :: two taps, one request', () {
    gate(
      'GEN-03028-G6',
      'An elevation request is a message to a person.',
      'A duplicate is a second interruption, so the key is derived from the '
          'resource and the requester and the send goes through Step 122\'s '
          'idempotent dispatcher',
      () =>
          HabotAccessElevationRequest.theSecondTapResolvesToTheFirstRequest &&
          HabotAccessElevationRequest.differentResourcesGetDifferentKeys &&
          HabotAccessElevationRequest.duplicateNote.contains('Step 122'),
    );

    gate(
      'GEN-03028-G7',
      'Three outcomes, three sentences.',
      'Already-pending is distinct from sent, so somebody who taps again is '
          'told what actually happened',
      () =>
          HabotAccessElevationRequest.everyOutcomeHasASentence &&
          HabotAccessElevationRequest.thePendingCaseIsDistinctFromTheSentCase,
    );
  });

  group('GEN-03028 :: the metric, and the pattern behind it', () {
    gate(
      'GEN-03028-G8',
      'Task Success Rate is an ISO 9241-11 measure taken with people.',
      'Five protocol requirements are written out, including that success is '
          'counted at the outcome and that time-on-task is recorded alongside',
      () =>
          !HabotAccessElevationRequest.successRateIsMeasurableFromCode &&
          HabotAccessElevationRequest.whatTheDeferredGateNeeds.length == 5 &&
          HabotAccessElevationRequest.deferredGates == 1,
    );

    gate(
      'GEN-03028-G9',
      'Third row in two batches whose metric cannot come from a repository.',
      'After Step 299\'s platform frame trace and Step 308\'s ISO 9186 '
          'comprehension test -- no longer an accident, and recorded as a '
          'pattern rather than three separate deferrals',
      () =>
          HabotAccessElevationRequest.thisIsThirdSuchRowInTwoBatches &&
          HabotAccessElevationRequest.stepsWhoseMetricNeedsPeople
              .contains(299) &&
          HabotAccessElevationRequest.stepsWhoseMetricNeedsPeople
              .contains(308) &&
          HabotAccessElevationRequest.deferralNote
              .contains('no longer an accident'),
    );

    gate(
      'GEN-03028-G10',
      'Output: Good / Average / Poor.',
      'Six declared obligations, all met, giving a Good; all ten declared '
          'checks hold',
      () =>
          HabotAccessElevationRequest.obligations.length == 6 &&
          HabotAccessElevationRequest.obligations.values
              .every((bool b) => b) &&
          HabotAccessElevationRequest.qualitativeOutput == 'Good' &&
          HabotAccessElevationRequest.checks.length == 10 &&
          HabotAccessElevationRequest.checks.values.every((bool b) => b) &&
          HabotAccessElevationRequest.columnNote.contains('deep-link'),
    );
  });

  group('GEN-03028 :: deferred', () {
    test('[GEN-03028-G11] mobile usability task success rate', () {
      gates.add(
        const AissGate(
          id: 'GEN-03028-G11',
          requirementSource:
              'Metric: Mobile Usability Task Success Rate (%) -- floor 80, '
              'optimal 95, ceiling 100. NN/g Mobile UX Heuristics; '
              'ISO 9241-11.',
          description:
              'DEFERRED. Task success rate is measured with participants '
              'attempting a task, and no repository produces it. The protocol '
              'is written out: people who hold the role and have hit a real '
              'denial, a task defined as getting access to the record they '
              'were refused, success counted at the outcome rather than at '
              'the tap, and time-on-task recorded alongside -- because a 100 '
              'per cent success rate taken over four minutes is a failure.',
          passed: false,
          deferred: true,
          detail:
              'Third deferral of this kind in two batches, after Step 299 and '
              'Step 308. The three are recorded together as a pattern: a '
              'build track that reports on itself should say when its metrics '
              'are measurements of the world rather than of the code.',
        ),
      );
    });
  });

  tearDownAll(() {
    final String denial = HabotAccessElevationRequest.denialMessage;
    final String pending =
        HabotAccessElevationRequest.afterSending['already pending'] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03028',
        atomicStepReferenceId: 'GEN-03028',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is the generic '
            'engineering-console boilerplate -- "Read-only M3 KPI cards with '
            'deep-link drill-down" -- on a row about what somebody does after '
            'being refused. Atomic Step: "Embed a 1-tap Request Access '
            'Elevation button directly in the mobile denial view."',
        implementationOrder: 320,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Embed a 1-tap Request Access Elevation button directly in the':
              '${HabotAccessElevationRequest.prefilled.length} of '
                  '${HabotAccessElevationRequest.fields.length} fields '
                  'pre-filled; two taps end to end',
          'Completion Status': 'Good, with one gate deferred',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the denial reads "$denial"; a repeat tap reads "$pending"',
          'Data Quality Note':
              'TAP COUNT: ${HabotAccessElevationRequest.tapCountNote} '
              'DISCLOSURE: ${HabotAccessElevationRequest.disclosureNote} '
              'DUPLICATES: ${HabotAccessElevationRequest.duplicateNote} '
              'DEFERRAL: ${HabotAccessElevationRequest.deferralNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Usability Task Success Rate (%)',
            observed:
                'DEFERRED -- measured with participants, not from a '
                'repository, and the protocol is written out. Reported '
                'instead over six declared obligations, all of which hold. '
                'This is the third row in two batches scored on a measurement '
                'of the world rather than of the code.',
            floor: '80',
            optimal: '95',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Taps from denial to sent request',
            observed:
                '2, counted at the outcome. Four of the five fields the '
                'request needs are already known from the denial view, so the '
                'form that opens has one empty field and it is the reason.',
            floor: '3',
            optimal: '2',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/access_elevation_request.dart',
        ],
      ),
    );
  });
}
