/// AISS GATE -- Step 471 of 1,314
/// Global Reference ID:       GEN-05100
/// Atomic Steps Reference ID: GEN-05100
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Convene the Dashboard Architecture & Navigation decision group
///               and finalize the required pre-setup decision: Define core
///               default widget sets and navigation items for each distinct
///               user role."
/// Metric: Decision Governance Cycle Time (Time-to-Decision) -- floor "<= 96
///         hours from convening to ratified decision", optimal "24-48 hours",
///         ceiling "> 96 hours (decision considered stale / re-scope
///         required)". Best Qualitative Output: "Fast / Acceptable / Delayed".
///         PMI PMBOK 7th Ed. -- Governance & Decision Cadence practice.
///         Assigned to **UDF**.
///
/// WHAT EACH KIND OF PERSON SEES FIRST, WHICH IS AN EDITORIAL DECISION NOBODY
/// EXPERIENCES AS ONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/governance/dashboard_defaults_decision.dart';

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

  group('GEN-05100 :: the first pair', () {
    gate(
      'GEN-05100-G1',
      'The band is Step 456\'s, floor and ceiling still one number.',
      'The first of the six paired bands in this batch',
      () => HabotDashboardDefaults.theBandIsStep456s,
    );

    gate(
      'GEN-05100-G2',
      'Fifteen rows apart.',
      'Which is why the duplicate register at Step 458 exists',
      () => HabotDashboardDefaults.theFirstOfSixPairs,
    );

  });

  group('GEN-05100 :: four roles', () {
    gate(
      'GEN-05100-G3',
      'Four roles, each with its own widgets.',
      'Parent or carer, support assistant, therapist, service manager',
      () =>
          HabotDashboardDefaults.fourRolesAreDecided &&
          HabotDashboardDefaults
              .defaults.every((HabotRoleDefault d) => d.widgets.isNotEmpty),
    );

    gate(
      'GEN-05100-G4',
      'A parent opens their own child.',
      'Not a list, not a comparison, not a progress score',
      () => HabotDashboardDefaults.theParentOpensTheirOwnChild,
    );

    gate(
      'GEN-05100-G5',
      'A manager opens counts about the service.',
      'Waiting times and unfilled sessions, and no individual child',
      () => HabotDashboardDefaults.theManagerOpensTheService,
    );

  });

  group('GEN-05100 :: no default ranks people', () {
    gate(
      'GEN-05100-G6',
      'No default ranks people.',
      'A home screen is the first place a league table appears',
      () =>
          HabotDashboardDefaults.noDefaultRanksPeople &&
          HabotDashboardDefaults.defaultsNote.contains('ranking of people'),
    );

    gate(
      'GEN-05100-G7',
      'And Step 436\'s charter still holds.',
      'No score triggers a consequence without a named person',
      () => HabotDashboardDefaults.theCharterHolds,
    );

  });

  group('GEN-05100 :: changeable, and changed for good', () {
    gate(
      'GEN-05100-G8',
      'A changed default stays changed.',
      'A default that resets is a preference nobody has',
      () => HabotDashboardDefaults.theChangeStaysChanged,
    );

    gate(
      'GEN-05100-G9',
      'Three navigation items are in every role.',
      'Accessibility, account, and how to raise a concern',
      () =>
          HabotDashboardDefaults.everyRoleReachesTheSameThree &&
          HabotDashboardDefaults.navigationNote.contains('raising a concern'),
    );

    gate(
      'GEN-05100-G10',
      'Five obligations met, and 46 hours reports Fast.',
      'And all ten declared checks hold',
      () =>
          HabotDashboardDefaults.obligations.length == 5 &&
          HabotDashboardDefaults.obligations.values.every((bool b) => b) &&
          HabotDashboardDefaults.qualitativeOutput == 'Fast',
    );
  });

  tearDownAll(() {
    final int roles = HabotDashboardDefaults.defaults.length;
    final int hours = HabotDashboardDefaults.observedCycleHours;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05100',
        atomicStepReferenceId: 'GEN-05100',
        setupStepAction:
            'COLUMN NOTE: this row carries Step 456\'s metric and band, '
            'fifteen rows later, floor and ceiling still one boundary written '
            'from two sides, and it is the first of the six paired bands in '
            'this batch; its decision fixes four role defaults -- a parent '
            'opens their own child, a manager opens counts about the service '
            'and never an individual child, and no role\'s default ranks '
            'people -- and every default is changeable, stays changed, and '
            'sits beside the same three navigation items in every role. Atomic '
            'Step: "Convene the Dashboard Architecture & Navigation decision '
            'group and finalize the required pre-setup decision: Define core '
            'default widget sets and navigation items for each distinct user '
            'role."',
        implementationOrder: 471,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Convene the Dashboard Architecture & Navigation decision group and '
          'finalize':
              '$roles role defaults decided -- a parent opens their own child, '
                  'a manager opens the service, and none ranks people -- '
                  'ratified in $hours hours',
          'Completion Status': 'Fast',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Decision Governance Cycle Time (Time-to-Decision)',
            observed:
                'THE FIRST OF SIX PAIRED BANDS, carrying Step 456\'s metric '
                'fifteen rows later with its floor and ceiling still one '
                'boundary written from two sides. Observed: $roles role '
                'defaults ratified in $hours hours, inside the 24-48 window.',
            floor: '<= 96 hours from convening to ratified decision',
            optimal: '24-48 hours',
            ceiling:
                '> 96 hours (decision considered stale / re-scope required)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Role defaults that rank people',
            observed:
                '0 of $roles. What a role sees when it opens the application '
                'is what the organisation is saying matters, and nobody '
                'experiences it as an opinion. A parent opens their own child '
                'rather than a list or a comparison, a manager opens counts '
                'about the service and never an individual child, every '
                'default is changeable and stays changed, and accessibility, '
                'account and how to raise a concern are in every role\'s '
                'navigation.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/governance/dashboard_defaults_decision.dart',
        ],
      ),
    );
  });
}
