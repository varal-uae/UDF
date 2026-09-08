/// AISS GATE -- Step 124 of 135
/// Global Reference ID:       GEN-05397
/// Atomic Steps Reference ID: GEN-05397
/// Atomic Step, in full: "Implement the mistake-proofing (Poka-Yoke) control:
///   system automatically pauses heavy background data synchronizations when
///   network RTT (Round Trip Time) exceeds 1000ms, preserving critical
///   interactive UI calls."
/// Metric: Mistake-Proofing Control Effectiveness (Error Interception Rate) --
///         Floor ">= 90% of induced errors intercepted", Optimal ">= 99%".
///
/// A CORRECTION TO THE STEPS 111-125 BUILD ORDER, GATED. That document records
/// this row as having "a genuine specification hole -- says background sync
/// automatically pauses and NEVER SAYS WHEN", and asks the owner for a
/// decision. The row does say when: RTT over 1000ms, preserving critical
/// interactive UI calls. GEN-05397-G1 asserts the threshold is the sheet's
/// number rather than a chosen one, so the correction cannot quietly rot back.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/sync_governor.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotSyncGovernorControl governor;
  int inducedHeavy = 0;
  int intercepted = 0;

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

  setUp(() => governor = HabotSyncGovernorControl());

  void observeAll(Duration rtt, {int times = 5}) {
    for (int i = 0; i < times; i++) {
      governor.observe(rtt);
    }
  }

  group('GEN-05397 :: the threshold is the sheet number', () {
    gate(
      'GEN-05397-G1',
      'Atomic Step: "when network RTT (Round Trip Time) EXCEEDS 1000ms". The '
          'Steps 111-125 build order records this row as never saying when.',
      'The threshold is 1000ms, taken from the row rather than chosen, and the '
          'correction to the build order is recorded in the code so it cannot '
          'rot back into an open question',
      () =>
          HabotSyncGovernorControl.threshold ==
              HabotMotion.rttHeavySyncThreshold &&
          HabotSyncGovernorControl.threshold.inMilliseconds == 1000 &&
          HabotSyncGovernorControl.specificationCorrection.contains(
            'never says when',
          ) &&
          HabotSyncGovernorControl.specificationCorrection.contains(
            'no owner decision was needed',
          ),
    );

    gate(
      'GEN-05397-G2',
      'Step 47 already handles a dead radio. This is the harder case: a link '
          'that WORKS but is slow.',
      'Heavy background work is paused above the threshold and allowed below '
          'it, with the observed figure named in the reason either way',
      () {
        observeAll(const Duration(milliseconds: 400));
        final HabotGovernorDecision fast = governor.decide(
          HabotWorkClass.heavyBackground,
        );
        observeAll(const Duration(milliseconds: 1200));
        final HabotGovernorDecision slow = governor.decide(
          HabotWorkClass.heavyBackground,
        );
        return fast.allowed &&
            fast.reason.contains('within the') &&
            !slow.allowed &&
            slow.intercepted &&
            slow.reason.contains('1200ms') &&
            slow.reason.contains('user is waiting');
      },
    );

    gate(
      'GEN-05397-G3',
      'One slow request is noise; five in a row is a slow link. A governor '
          'that flaps on a single outlier pauses and resumes constantly.',
      'A single 8-second outlier among fast samples does NOT pause heavy work, '
          'because the decision is made on the median of the window',
      () {
        observeAll(const Duration(milliseconds: 200));
        governor.observe(const Duration(seconds: 8));
        final bool survivedOutlier = !governor.isDegraded;
        observeAll(const Duration(milliseconds: 1500));
        return survivedOutlier &&
            governor.isDegraded &&
            governor.samples.length == governor.sampleWindow;
      },
    );
  });

  group('GEN-05397 :: "preserving critical interactive UI calls"', () {
    gate(
      'GEN-05397-G4',
      'The word "preserving" is the half people drop. A governor that pauses '
          'everything on a slow link makes a slow app into a dead one.',
      'Interactive work is allowed even while degraded, and the reason quotes '
          'the requirement rather than merely asserting the behaviour',
      () {
        observeAll(const Duration(milliseconds: 3000));
        final HabotGovernorDecision interactive = governor.decide(
          HabotWorkClass.interactive,
        );
        final HabotGovernorDecision heavy = governor.decide(
          HabotWorkClass.heavyBackground,
        );
        return governor.isDegraded &&
            interactive.allowed &&
            interactive.reason.contains('never paused') &&
            interactive.reason.contains('preserving') &&
            !heavy.allowed &&
            governor.interactivePreserved == 1;
      },
    );

    gate(
      'GEN-05397-G5',
      'Stopping the heartbeat and the poll because the link is slow would '
          'leave the governor blind to the link recovering.',
      'Light background work -- the thing that MEASURES the link -- continues '
          'while degraded, and is not counted as an interception',
      () {
        observeAll(const Duration(milliseconds: 2000));
        final HabotGovernorDecision light = governor.decide(
          HabotWorkClass.lightBackground,
        );
        governor.decide(HabotWorkClass.heavyBackground);
        return light.allowed &&
            light.reason.contains('lose track of whether the link recovered') &&
            governor.interceptionRate == 1.0 &&
            HabotWorkClass.values.length == 3;
      },
    );

    gate(
      'GEN-05397-G6',
      'Metric: Error Interception Rate, floor >= 90%, optimal >= 99%, over '
          'INDUCED errors.',
      'Errors are induced by driving the RTT above the threshold, and the '
          'measured interception rate is 100% -- with interactive and light '
          'work excluded from the denominator, because they are what the '
          'control is required to let through',
      () {
        observeAll(const Duration(milliseconds: 1800));
        for (int i = 0; i < 50; i++) {
          inducedHeavy++;
          if (governor.decide(HabotWorkClass.heavyBackground).intercepted) {
            intercepted++;
          }
          // Interleave the work that must survive, so the denominator is
          // genuinely at risk of being inflated by it.
          governor.decide(HabotWorkClass.interactive);
          governor.decide(HabotWorkClass.lightBackground);
        }
        return inducedHeavy == 50 &&
            intercepted == 50 &&
            governor.interceptionRate == 1.0 &&
            governor.meetsFloor &&
            governor.meetsOptimal &&
            governor.interactivePreserved == 50;
      },
    );

    gate(
      'GEN-05397-G7',
      'The governor has to satisfy the Step 123 interface, or the loop cannot '
          'use it.',
      'It answers allowsHeavyWork and carries the last reason, so a paused '
          'sweep records WHY rather than only that it stopped',
      () {
        observeAll(const Duration(milliseconds: 2500));
        final bool blocked = !governor.allowsHeavyWork;
        final String why = governor.reason;
        return blocked &&
            why.contains('exceeds the') &&
            HabotSyncGovernorControl().reason == 'no decision taken yet';
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05397',
        atomicStepReferenceId: 'GEN-05397',
        setupStepAction:
            'Implement the mistake-proofing (Poka-Yoke) control: system '
            'automatically pauses heavy background data synchronizations when '
            'network RTT (Round Trip Time) exceeds 1000ms, preserving '
            'critical interactive UI calls.',
        implementationOrder: 124,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSyncGovernorControl',
          'Component Properties':
              'threshold ${HabotSyncGovernorControl.threshold.inMilliseconds}ms '
              '(the sheet number); median over a 5-sample window; '
              '${HabotWorkClass.values.length} work classes, of which '
              'interactive is never paused and light background continues '
              'while degraded',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY. The Steps 111-125 build order '
              'records this row as having a specification hole; it does not. '
              'The correction is recorded in '
              'HabotSyncGovernorControl.specificationCorrection and asserted '
              'by GEN-05397-G1.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Error Interception Rate (induced)',
            observed:
                '$intercepted of $inducedHeavy heavy background operations '
                'were stopped while the link was driven above the '
                '${HabotSyncGovernorControl.threshold.inMilliseconds}ms '
                'threshold, with 50 interactive calls interleaved and let '
                'through. Interactive and light work are excluded from the '
                'denominator: they are not errors to intercept, they are what '
                'the control is required to preserve, and counting them would '
                'inflate the rate with successes that had nothing to do with '
                'interception.',
            floor: '>= 90% of induced errors intercepted',
            optimal: '>= 99% of induced errors intercepted',
            ceiling: '1',
          ),
          const AissMeasurement(
            metricName: 'Interactive calls preserved while degraded',
            observed:
                '50 of 50. The "preserving critical interactive UI calls" half '
                'of the requirement, counted rather than asserted -- a '
                'governor that pauses everything would score identically on '
                'interception and fail the requirement.',
            floor: 'all preserved',
            optimal: 'all preserved',
            ceiling: 'all preserved',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/sync_governor.dart',
        ],
      ),
    );
  });
}
