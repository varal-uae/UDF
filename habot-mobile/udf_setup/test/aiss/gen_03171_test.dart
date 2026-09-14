/// AISS GATE -- Step 165 of 175
/// Global Reference ID:       GEN-03171
/// Atomic Steps Reference ID: GEN-03171
/// Setup Step (Action) / Atomic Step: "Execute full mobile performance
///   verification confirming cold start time below 1.2 seconds."
/// Metric: Task Completion Status -- Floor 0.8, Optimal 1.0, Ceiling 1.0.
///         Complete / Partial / Not Complete.
///
/// **THIS STEP REPORTS PARTIAL, ON PURPOSE.** A cold-start figure cannot be
/// produced by a unit test on a CI host: cold start is process creation, asset
/// loading and first frame on a real device under a real OS scheduler, and a
/// test host measures a Dart VM that is already warm. Five of the eight checks
/// run here; three are recorded as DEFERRED, with the reason, rather than being
/// quietly dropped or reported green. Completion status is 0.625 -- below the
/// row's own floor of 0.8, and that is the honest number.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/performance_verification.dart';
import 'package:udf_setup/design_system/telemetry/rail_timings.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completion = 0;

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

  /// A check this suite cannot execute. Recorded as a reviewable open item:
  /// the gate runner stays green so a genuine regression is still visible,
  /// and the step still reports Partial.
  void deferredGate(
    String id,
    String checkId,
    String source,
    String description,
  ) {
    test('[$id] DEFERRED -- $description', () {
      final HabotPerformanceCheck check = HabotPerformanceVerification.checks
          .firstWhere((HabotPerformanceCheck c) => c.id == checkId);
      // What CAN be asserted here: that the check is declared, that it is
      // classified as device-only, and that it carries a reason for being so.
      expect(check.runsInCi, isFalse);
      expect(check.why.length, greaterThan(40));
      gates.add(
        AissGate(
          id: id,
          requirementSource: source,
          description: description,
          passed: false,
          deferred: true,
          detail:
              '$checkId requires a profile-mode build on a physical handset. '
              '${check.why} The check is declared, classified and carries its '
              'reason; what is missing is a device to run it on. Reporting it '
              'as passing would put the release decision on a measurement of '
              'nothing.',
        ),
      );
    });
  }

  HabotTimingSet setOf(List<int> ms) => HabotTimingSet(
        HabotTimingKind.coldStart,
        ms.map((int v) => Duration(milliseconds: v)).toList(),
      );

  group('GEN-03171 :: the verification, and where each check can run', () {
    gate(
      'GEN-03171-G1',
      'Atomic Step: "...confirming cold start time below 1.2 seconds."',
      'The verification is a declared list of checks, each classified by where '
          'it can actually run and each carrying the reason -- a check marked '
          '"device" with no reason is a check somebody could not be bothered '
          'to automate',
      () =>
          HabotPerformanceVerification.checks.length == 8 &&
          HabotPerformanceVerification.ciChecks.length == 5 &&
          HabotPerformanceVerification.deviceChecks.length == 3 &&
          HabotPerformanceVerification.checks.every(
            (HabotPerformanceCheck c) =>
                c.statement.length > 30 && c.why.length > 20,
          ) &&
          HabotPerformanceVerification.checks
              .map((HabotPerformanceCheck c) => c.id)
              .toSet()
              .length ==
              8,
    );

    gate(
      'GEN-03171-G2',
      'PV-1: "The cold-start budget is declared as a single token and is the '
          '1.2s the row names."',
      'The budget is one token, it holds the figure the row names, and Step '
          '164 judges cold starts against that same token rather than against '
          'a second opinion',
      () =>
          HabotPerformanceVerification.coldStartBudget ==
              const Duration(milliseconds: 1200) &&
          HabotPerformanceVerification.coldStartBudget ==
              HabotMotion.coldStartBudget &&
          HabotRailTimings.startupBudget ==
              HabotPerformanceVerification.coldStartBudget,
    );

    gate(
      'GEN-03171-G3',
      'PV-2: "Cold start is judged against the startup budget, not against the '
          'RAIL response bands." The Step 164 finding.',
      'A cold start is classified into the startup budget family and an input '
          'response into the RAIL family, so a launch is never reported as a '
          'RAIL failure against a bound that was never meant for it',
      () =>
          HabotRailTimings.familyOf(HabotTimingKind.coldStart) ==
              HabotBudgetFamily.startup &&
          HabotRailTimings.familyOf(HabotTimingKind.inputResponse) ==
              HabotBudgetFamily.rail &&
          HabotRailTimings.bandFor(
                HabotTimingKind.coldStart,
                const Duration(milliseconds: 1100),
              ) ==
              'Good' &&
          HabotRailTimings.bandFor(
                HabotTimingKind.inputResponse,
                const Duration(milliseconds: 1100),
              ) ==
              'Poor',
    );

    gate(
      'GEN-03171-G4',
      'PV-3: "The reported figure is a p95 across samples, not a mean." '
          'PV-5: "A timing kind with no sample is named rather than reported '
          'as zero."',
      'The budget check is made against a p95 over a non-empty sample set, so '
          'a set with a slow tail fails even when its mean is comfortable, and '
          'an EMPTY set does not pass by default',
      () {
        // Mean 300ms, p95 1,900ms: comfortable on average, over budget where
        // it matters.
        final HabotTimingSet tailHeavy = setOf(<int>[
          100,
          110,
          120,
          130,
          140,
          150,
          160,
          170,
          180,
          1900,
        ]);
        final HabotTimingSet withinBudget = setOf(<int>[
          100,
          200,
          300,
          400,
          1100,
        ]);
        return tailHeavy.mean == const Duration(milliseconds: 316) &&
            tailHeavy.p95 == const Duration(milliseconds: 1900) &&
            !HabotPerformanceVerification.meetsBudget(tailHeavy) &&
            tailHeavy.mean < HabotPerformanceVerification.coldStartBudget &&
            HabotPerformanceVerification.meetsBudget(withinBudget) &&
            !HabotPerformanceVerification.meetsBudget(setOf(<int>[])) &&
            setOf(<int>[]).isEmpty;
      },
    );

    gate(
      'GEN-03171-G5',
      '"A plan with no device list is not a verification. Cold start below '
          '1.2s on WHICH phone?"',
      'The device classes are declared, exactly one is the floor device, and '
          'the one the team actually tests on is on the list so the gap '
          'between it and the floor device is visible rather than assumed',
      () {
        final Iterable<HabotDeviceClass> floors = HabotPerformanceVerification
            .deviceClasses
            .where((HabotDeviceClass d) => d.isFloorDevice);
        return HabotPerformanceVerification.deviceClasses.length == 3 &&
            floors.length == 1 &&
            HabotPerformanceVerification.floorDevice.name.contains('budget') &&
            HabotPerformanceVerification.floorDevice.rationale
                .contains('nobody has on their desk') &&
            HabotPerformanceVerification.deviceClasses.every(
              (HabotDeviceClass d) => d.rationale.length > 20,
            ) &&
            HabotPerformanceVerification.ceilingNotMeanNote
                .contains('no user experiences');
      },
    );
  });

  group('GEN-03171 :: what cannot be run here', () {
    deferredGate(
      'GEN-03171-G6',
      'PV-6',
      'PV-6: "Observed cold start on the floor device is below 1.2s."',
      'Observed cold start on the floor device -- process creation, asset '
          'loading and first frame under a real OS scheduler. A CI host '
          'measures an already-warm Dart VM, so a figure produced here would '
          'be a measurement of nothing',
    );

    deferredGate(
      'GEN-03171-G7',
      'PV-7',
      'PV-7: "Observed cold start is below 1.2s on every declared device '
          'class, individually."',
      'The budget holds on every declared device class on its own, because it '
          'is a ceiling for the slowest device rather than a mean across the '
          'fleet -- averaging a fast phone and a slow one produces a number no '
          'user experiences',
    );

    deferredGate(
      'GEN-03171-G8',
      'PV-8',
      'PV-8: "Page interactivity is below 2s on a throttled 3G profile."',
      'Page interactivity under the 2s-on-3G target the setup text names. A '
          'test host has no radio to throttle',
    );
  });

  group('GEN-03171 :: the metric, reported honestly', () {
    gate(
      'GEN-03171-G9',
      'Metric: Task Completion Status -- floor 0.8, optimal 1.0. '
          '"A verification that skips the hard half and reports 1.0 on the '
          'easy half is the failure this step is most at risk of."',
      'Completion status is the share of the verification actually executable '
          'here -- 5 of 8, which is 0.625 and BELOW the row\'s own floor of '
          '0.8 -- the qualitative output is Partial, and the three outstanding '
          'checks are named with their reasons rather than dropped',
      () {
        completion = HabotPerformanceVerification.completionStatus;
        return completion == 0.625 &&
            completion < HabotPerformanceVerification.floor &&
            completion < HabotPerformanceVerification.optimal &&
            HabotPerformanceVerification.qualitativeOutput == 'Partial' &&
            HabotPerformanceVerification.outstanding.length == 3 &&
            HabotPerformanceVerification.outstanding
                .every((String o) => o.startsWith('PV-')) &&
            HabotPerformanceVerification.outstanding
                .any((String o) => o.contains('floor device')) &&
            HabotPerformanceVerification.partialOnPurposeNote
                .contains('measurement of nothing');
      },
    );

    gate(
      'GEN-03171-G10',
      '"Reporting a green number here would be the single most misleading '
          'thing in this batch, because the release decision would rest on a '
          'measurement of nothing."',
      'The completion figure counts what was EXECUTED rather than what passed, '
          'so skipping the hard half cannot raise it -- and the reasoning is '
          'recorded in the code where somebody can argue with it',
      () =>
          HabotPerformanceVerification.completionStatus ==
              HabotPerformanceVerification.ciChecks.length /
                  HabotPerformanceVerification.checks.length &&
          HabotPerformanceVerification.deviceChecks.every(
            (HabotPerformanceCheck c) => !c.runsInCi,
          ) &&
          HabotPerformanceVerification.ciChecks.every(
            (HabotPerformanceCheck c) => c.runsInCi,
          ) &&
          HabotPerformanceVerification.deviceListNote
              .contains('verified nothing about the fleet'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03171',
        atomicStepReferenceId: 'GEN-03171',
        setupStepAction:
            'Execute full mobile performance verification confirming cold '
            'start time below 1.2 seconds.',
        implementationOrder: 165,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPerformanceVerification',
          'Component Properties':
              '${HabotPerformanceVerification.checks.length} declared checks '
              '(${HabotPerformanceVerification.ciChecks.length} executable in '
              'CI, ${HabotPerformanceVerification.deviceChecks.length} '
              'requiring a profile-mode build on a handset); '
              '${HabotPerformanceVerification.deviceClasses.length} device '
              'classes with "${HabotPerformanceVerification.floorDevice.name}" '
              'declared as the floor device; budget '
              '${HabotPerformanceVerification.coldStartBudget.inMilliseconds}ms',
          'Completion Status': 'Partial -- deliberately, see the note',
          'Data Quality Note':
              'THIS STEP REPORTS PARTIAL ON PURPOSE. A cold-start figure '
              'cannot be produced by a unit test on a CI host: cold start is '
              'process creation, asset loading and first frame on a real '
              'device under a real OS scheduler, and a test host measures an '
              'already-warm Dart VM. PV-6, PV-7 and PV-8 are recorded as '
              'DEFERRED gates with their reasons; the gate runner stays green '
              'so a genuine regression is still visible, and the step reports '
              'Partial rather than a green number a release decision would '
              'then rest on.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Completion Status',
            observed:
                '${completion.toStringAsFixed(3)} '
                '(${HabotPerformanceVerification.ciChecks.length} of '
                '${HabotPerformanceVerification.checks.length} checks '
                'executable here). BELOW the row\'s floor of 0.8. The figure '
                'counts what was executed rather than what passed, '
                'deliberately: a verification that skips the hard half and '
                'reports 1.0 on the easy half is the failure this step is most '
                'at risk of.',
            floor: '0.8',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Cold start on the floor device',
            observed:
                'NOT MEASURED. Requires a profile-mode build on '
                '"${HabotPerformanceVerification.floorDevice.name}". The '
                'budget is a ceiling for the slowest device, not a mean across '
                'the fleet, so every declared device class must pass on its '
                'own. Outstanding: '
                '${HabotPerformanceVerification.outstanding.length} checks, '
                'named in the deferred gates.',
            floor: '< 1.2 s on the floor device',
            optimal: '< 1.2 s on every declared device class',
            ceiling: '1.2 s',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/performance_verification.dart',
        ],
      ),
    );
  });
}
