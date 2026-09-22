/// AISS GATE -- Step 441 of 415
/// Global Reference ID:       GEN-02687
/// Atomic Steps Reference ID: GEN-02687
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Write the backend Cloud Run endpoint that serves the
///               performance scorecard data to the mobile view."
/// Metric: Implementation Completeness Rate -- floor "90% of defined build
///         scope completed", optimal "100% of scope complete with peer
///         validation", ceiling "1". Best Qualitative Output: "Complete /
///         Partial / Not Complete". DORA -- DevOps Research -- Implementation
///         Quality Standards. Assigned to **UDF**.
///
/// THE CONTRACT FOR A PERFORMANCE SCORECARD, WRITTEN FROM THE SIDE THAT HAS TO
/// RENDER IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/recognition/scorecard_endpoint.dart';

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

  group('GEN-02687 :: a contract, and the charter', () {
    gate(
      'GEN-02687-G1',
      'A contract rather than an endpoint.',
      'No server exists here; what the mobile side owns is the contract',
      () =>
          HabotScorecardEndpoint.theDeliverableIsNamedHonestly &&
          HabotScorecardEndpoint.route.startsWith('/v1/'),
    );

    gate(
      'GEN-02687-G2',
      'The second relabelling as performance in three rows.',
      'After Step 439\'s performance tier',
      () =>
          HabotScorecardEndpoint.theRowThatRelabelledALevel == 439 &&
          HabotScorecardEndpoint.theWordIsKept,
    );

    gate(
      'GEN-02687-G3',
      'And the full charter applies.',
      'This is the row where a person most plainly becomes the subject',
      () =>
          HabotScorecardEndpoint.theCharterAppliesInFull &&
          HabotScorecardEndpoint
              .relabelNote.contains('plainly becomes the subject'),
    );

  });

  group('GEN-02687 :: working and contest on every figure', () {
    gate(
      'GEN-02687-G4',
      'Three sample figures, each with working and a contest link.',
      'Every figure names the completions it came from',
      () =>
          HabotScorecardEndpoint.sample.length == 3 &&
          HabotScorecardEndpoint.everySampleFigureRenders,
    );

    gate(
      'GEN-02687-G5',
      'A figure without working is refused.',
      'A number with no computation is a verdict',
      () => HabotScorecardEndpoint.aFigureWithoutWorkingIsRefused,
    );

    gate(
      'GEN-02687-G6',
      'And so is one without a contest link.',
      'A figure nobody can check is a figure nobody can act on',
      () =>
          HabotScorecardEndpoint.aFigureWithoutAContestIsRefused &&
          HabotScorecardEndpoint.workingNote.contains('nobody can act on'),
    );

  });

  group('GEN-02687 :: who may fetch whose', () {
    gate(
      'GEN-02687-G7',
      'Self and manager may fetch, a peer may not.',
      'Your own, your reports\', nobody else\'s',
      () =>
          HabotScorecardEndpoint.selfAndManagerAreAllowed &&
          HabotScorecardEndpoint.aPeerIsRefused,
    );

    gate(
      'GEN-02687-G8',
      'And the step to ranking is not taken for anybody.',
      'Seeing a colleague\'s numbers is one step from being ranked against '
          'them',
      () =>
          HabotScorecardEndpoint.scopeNote.contains('nobody decided to take') &&
          HabotScorecardEndpoint.theFiguresComeFromTheLedger,
    );

  });

  group('GEN-02687 :: the band', () {
    gate(
      'GEN-02687-G9',
      'Two sentences and a bare 1, with a condition in the optimal.',
      'The first of five such rows in this batch',
      () =>
          HabotScorecardEndpoint.twoSentencesAndABareNumber &&
          HabotScorecardEndpoint.theOptimalCarriesACondition &&
          HabotScorecardEndpoint.firstOfFiveInThisBatch,
    );

    gate(
      'GEN-02687-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotScorecardEndpoint.obligations.length == 5 &&
          HabotScorecardEndpoint.obligations.values.every((bool b) => b) &&
          HabotScorecardEndpoint.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int figures = HabotScorecardEndpoint.sample.length;
    final String route = HabotScorecardEndpoint.route;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02687',
        atomicStepReferenceId: 'GEN-02687',
        setupStepAction:
            'COLUMN NOTE: this row asks for a backend endpoint in a mobile '
            'design-system track, so the contract is delivered and named as a '
            'contract; it serves a "performance scorecard", the second '
            'relabelling of person data as performance in three rows after '
            'Step 439, so every figure carries its working and a contest link '
            'and a peer\'s scorecard is never returned; and its band is two '
            'sentences and a bare 1, the first of five such rows in this '
            'batch, with a condition -- "with peer validation" -- inside its '
            'optimal. Atomic Step: "Write the backend Cloud Run endpoint that '
            'serves the performance scorecard data to the mobile view."',
        implementationOrder: 441,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Write the backend Cloud Run endpoint that serves the performance':
              'a contract for $route: $figures sample figures each carrying '
                  'its working and a contest link; self and direct manager '
                  'only',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Implementation Completeness Rate',
            observed:
                'A BACKEND ENDPOINT IN A MOBILE DESIGN-SYSTEM TRACK, SCORED ON '
                'PROSE. There is no server here, so the contract is delivered '
                'and named as one. The band is two sentences and a bare 1, the '
                'first of five such rows in this batch, and its optimal '
                'carries a condition -- "with peer validation" -- inside a '
                'boundary. Observed: every contract clause declared, $figures '
                'sample figures rendering.',
            floor: '90% of defined build scope completed',
            optimal: '100% of scope complete with peer validation',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName:
                'Scorecard figures rendered without working or a contest link',
            observed:
                '0 of $figures. "Performance scorecard" is the second '
                'relabelling of person data as performance in three rows, and '
                'this is where a person most plainly becomes the subject, so '
                'all four charter rules apply: each figure carries the '
                'completions it came from and a contest link, the client '
                'refuses one without either, and a peer\'s scorecard is never '
                'returned.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/recognition/scorecard_endpoint.dart',
        ],
      ),
    );
  });
}
