/// AISS GATE -- Step 234 of 235
/// Global Reference ID:       GEN-04108
/// Atomic Steps Reference ID: GEN-04108
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Defer non-essential SDK initializations until after the
///               primary UI view renders."
/// Metric: Deferred SDK Initialization -- Floor 1, Optimal 1, Ceiling 1.
///         Pass/Fail.
///
/// A BLANKET DEFERRAL LOSES THE TELEMETRY FOR THE FAILURE IT WOULD CAUSE.
/// Deferring the crash reporter means crashes during startup go unreported,
/// and those are the ones that matter most: to the user they are not a crash,
/// they are an app that does not open.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/performance/startup_deferral.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double deferrable = 0;
  double overall = 0;

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

  group('GEN-04108 :: which moment', () {
    gate(
      'GEN-04108-G1',
      'Atomic Step: "until after the PRIMARY UI VIEW RENDERS."',
      'The first frame is often a skeleton and a skeleton is not a view, so '
          'the deferral point is the first USEFUL paint -- which is a later '
          'moment and a distinct declared phase, not a synonym',
      () =>
          HabotStartupDeferral.deferralPoint ==
              HabotStartupPhase.afterFirstUsefulPaint &&
          HabotStartupPhase.values.length == 4 &&
          HabotStartupPhase.values
              .contains(HabotStartupPhase.beforeFirstUsefulPaint) &&
          HabotStartupDeferral.twoMomentsNote.contains('skeleton is not a '
              'view'),
    );

    gate(
      'GEN-04108-G2',
      '"Deferring the crash reporter means crashes during startup go '
          'unreported."',
      'The crash reporter is marked must-not-defer, and so are the consent '
          'gate and the theme construction -- three entries that a blanket '
          'reading of the row would have moved off the critical path',
      () =>
          HabotStartupDeferral.crashReporterIsNotDeferred &&
          HabotStartupDeferral.mustNotDeferItems.length == 3 &&
          HabotStartupDeferral.mustNotDeferItems.any(
            (HabotStartupItem i) => i.name.contains('consent'),
          ) &&
          HabotStartupDeferral.crashReporterNote
              .contains('app that does not open'),
    );

    gate(
      'GEN-04108-G3',
      'Step 176 named ColorScheme.fromSeed on the cold-start path: work, not '
          'an SDK.',
      'Four startup items are not SDKs at all, and the theme construction is '
          'one of them -- listed so that "defer everything non-essential" does '
          'not read as a complete account of startup',
      () =>
          HabotStartupDeferral.nonSdkStartupWork.length == 4 &&
          HabotStartupDeferral.nonSdkStartupWork.any(
            (HabotStartupItem i) => i.name.contains('ColorScheme.fromSeed'),
          ) &&
          HabotStartupDeferral.items
              .firstWhere(
                (HabotStartupItem i) =>
                    i.name.contains('ColorScheme.fromSeed'),
              )
              .mustNotDefer &&
          HabotStartupDeferral.items
              .firstWhere(
                (HabotStartupItem i) =>
                    i.name.contains('ColorScheme.fromSeed'),
              )
              .rationale
              .contains('complete account of startup'),
    );

    gate(
      'GEN-04108-G4',
      '"A deferral list without reasons is a list somebody reorders when a '
          'launch is slow."',
      'Every one of the nine items gives a reason, and two go further than '
          'deferral -- the payment SDK and the QR renderer initialise on '
          'demand, because most sessions never reach the screens that need '
          'them',
      () =>
          HabotStartupDeferral.items.length == 9 &&
          HabotStartupDeferral.everyItemGivesAReason &&
          HabotStartupDeferral.onDemandItems.length == 2 &&
          HabotStartupDeferral.onDemandItems.any(
            (HabotStartupItem i) => i.name.contains('payment provider'),
          ) &&
          HabotStartupDeferral.onDemandItems.every(
            (HabotStartupItem i) =>
                i.phase == HabotStartupPhase.onDemand && i.isDeferred,
          ),
    );
  });

  group('GEN-04108 :: a binary metric over a population with an exception', () {
    gate(
      'GEN-04108-G5',
      'Metric: floor, optimal and ceiling are all 1.',
      'Over the SDKs that MAY be deferred the rate is 1.0; over all five SDKs '
          'it is 0.8, because the crash reporter is deliberately not '
          'deferred -- so the exclusion is declared and both figures are '
          'published, the same shape as Step 233',
      () {
        deferrable = HabotStartupDeferral.deferralRateExcludingMustNotDefer;
        overall = HabotStartupDeferral.sdkDeferralRate;
        return HabotStartupDeferral.sdks.length == 5 &&
            HabotStartupDeferral.deferredSdks.length == 4 &&
            deferrable == 1.0 &&
            (overall - 0.8).abs() < 1e-9 &&
            overall < HabotStartupDeferral.floor;
      },
    );

    gate(
      'GEN-04108-G6',
      'The deferral is in service of the Step 165 cold-start budget.',
      'The budget is read from the declared token rather than restated, and '
          'the overall deferral rate across everything at startup -- SDK or '
          'not -- is reported beside the SDK figure, because the row asks '
          'about SDKs and the budget does not care which is which',
      () =>
          HabotStartupDeferral.coldStartBudget ==
              HabotMotion.coldStartBudget &&
          HabotStartupDeferral.coldStartBudget.inMilliseconds == 1200 &&
          (HabotStartupDeferral.overallDeferralRate - 6 / 9).abs() < 1e-9,
    );

    gate(
      'GEN-04108-G7',
      'Deferred SDK Initialization -- Pass/Fail.',
      'All ten checks hold and the step reports Pass on the rate over '
          'deferrable SDKs, with the three must-not-defer entries named and '
          'argued rather than counted as failures',
      () =>
          HabotStartupDeferral.checks.length == 10 &&
          HabotStartupDeferral.checks.values.every((bool b) => b) &&
          HabotStartupDeferral.qualitativeOutput == 'Pass' &&
          HabotStartupDeferral.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final int deferrableSdks = HabotStartupDeferral.sdks.length -
        HabotStartupDeferral.mustNotDeferItems
            .where((HabotStartupItem i) => i.isAnSdk)
            .length;
    final String overallPct =
        (HabotStartupDeferral.overallDeferralRate * 100).toStringAsFixed(1);
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04108',
        atomicStepReferenceId: 'GEN-04108',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Defer non-essential SDK initializations until after the '
            'primary UI view renders."',
        implementationOrder: 234,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotStartupDeferral / HabotStartupItem',
          'Component Properties':
              '${HabotStartupDeferral.items.length} startup items across '
              '${HabotStartupPhase.values.length} phases, of which '
              '${HabotStartupDeferral.sdks.length} are SDKs and '
              '${HabotStartupDeferral.nonSdkStartupWork.length} are not; '
              '${HabotStartupDeferral.mustNotDeferItems.length} marked '
              'must-not-defer and ${HabotStartupDeferral.onDemandItems.length} '
              'initialised on demand; every entry carries a reason',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: "after the primary UI view renders" is two different '
              'moments. The first frame is often a skeleton, and a skeleton is '
              'not a view -- deferring to it moves the work into the exact '
              'window in which the user is looking at a placeholder and '
              'deciding whether the app is broken. The deferral point is the '
              'first USEFUL paint, which is later and is a distinct declared '
              'phase. SECOND FINDING, and the one that matters: a blanket '
              'deferral loses the telemetry for the failure it would cause. '
              'Deferring the crash reporter means crashes during startup go '
              'unreported, and those are the ones that matter most -- to the '
              'user they are not a crash, they are an app that does not open, '
              'and a deferred reporter is asleep for exactly that window. The '
              'consent gate is the same argument: nothing may be collected '
              'before consent state is known, so every other SDK\'s deferral '
              'depends on it having run. THIRD: a category the row does not '
              'have. Step 176 named ColorScheme.fromSeed on the cold-start '
              'path -- work, not an SDK, computing 28 colour roles the first '
              'frame needs. It cannot be deferred and cannot be dropped, and '
              'it is listed so that "defer everything non-essential" does not '
              'read as a complete account of startup. Two SDKs go further than '
              'deferral and initialise on demand, because most sessions never '
              'reach the screens that need them.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Deferred SDK Initialization',
            observed:
                '${deferrable.toStringAsFixed(2)} over the '
                '$deferrableSdks SDKs that may be deferred, and '
                '${overall.toStringAsFixed(1)} over all '
                '${HabotStartupDeferral.sdks.length}. The difference is the '
                'crash reporter, which is deliberately not deferred; the '
                'exclusion is declared rather than the figure rounded up.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Startup work off the pre-first-frame path',
            observed:
                '$overallPct% of all '
                '${HabotStartupDeferral.items.length} startup items, '
                'SDK or not. Reported beside the SDK figure because the Step '
                '165 cold-start budget of '
                '${HabotStartupDeferral.coldStartBudget.inMilliseconds}ms does '
                'not care which is which.',
            floor: 'n/a -- descriptive',
            optimal: 'n/a -- descriptive',
            ceiling: 'n/a -- descriptive',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/performance/startup_deferral.dart',
        ],
      ),
    );
  });
}
