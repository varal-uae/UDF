/// AISS GATE -- Step 93 of 95
/// Global Reference ID:       GEN-03866
/// Atomic Steps Reference ID: GEN-03866-A01
/// Setup Step (Action):       "Add an INTERACTION TIMER tracking worker
///                             execution duration on the mobile screen."
/// Metric: Interaction Timer Resolution Drift --
///         Floor "<10 ms", Optimal "<1 ms", Ceiling "50 ms".
/// Standard: W3C User Timing / High Resolution Time.
///
/// WHAT THE DRIFT MEASURE CAN AND CANNOT SEE, stated rather than glossed:
///
///   ARITHMETIC DRIFT -- the accumulated total against the sum of the recorded
///   intervals, across every start, pause and resume. That is exactly what a
///   pause/resume implementation gets wrong, it is observable in a suite, and
///   G2 reports it.
///
///   WALL-CLOCK DRIFT -- what `DateTime.now()` on a specific handset does
///   against a reference clock under thermal load. No test host produces that
///   figure and none is invented here.
///
/// WHY THERE ARE TWO DURATIONS. Worked time excludes pauses -- a phone call
/// mid-task is not the worker working. Elapsed time does not, because Step
/// 94's five-minute reallocation rule is about wall clock: a task nobody has
/// touched goes back to the queue whether or not the app was open. Conflating
/// them would either punish a worker for a phone call or let a stalled task
/// sit forever.
library;

import 'dart:io';

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/mto/interaction_timer.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

/// A clock the test drives, so drift is a property of the accumulator rather
/// than of how long the test host took to run a line.
class _Clock {
  _Clock(this.now);
  DateTime now;
  DateTime call() => now;
  void advance(Duration by) => now = now.add(by);
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  int measuredDriftUs = -1;
  String measuredReadout = '';

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

  group('GEN-03866-A01 :: the timer', () {
    gate(
      'GEN-03866-G1',
      'Setup Step (Action): "tracking WORKER EXECUTION DURATION on the mobile '
          'screen" -- execution duration, not the time the task sat there.',
      'Worked time counts only the intervals the worker was on the task, '
          'elapsed time counts the whole span, and the difference is exactly '
          'the paused time -- so a phone call mid-task does not read as work',
      () {
        final _Clock clock = _Clock(DateTime(2026, 8, 18, 9));
        final HabotInteractionTimer timer = HabotInteractionTimer(
          taskId: 'byt-1',
          clock: clock.call,
        );
        addTearDown(timer.dispose);

        timer.start();
        clock.advance(const Duration(seconds: 4));
        timer.pause();
        clock.advance(const Duration(seconds: 5));
        timer.start();
        clock.advance(const Duration(milliseconds: 3500));
        timer.pause();
        clock.advance(const Duration(seconds: 7, milliseconds: 500));
        timer.start();
        clock.advance(const Duration(milliseconds: 750));
        timer.stop();

        measuredReadout = timer.readout;
        return timer.workedDuration ==
                const Duration(seconds: 8, milliseconds: 250) &&
            timer.elapsedSinceStart ==
                const Duration(seconds: 20, milliseconds: 750) &&
            timer.pausedDuration ==
                const Duration(seconds: 12, milliseconds: 500) &&
            timer.intervals.length == 3 &&
            timer.state == HabotTimerState.stopped &&
            measuredReadout == '0:08';
      },
    );

    gate(
      'GEN-03866-G2',
      'Metric: Interaction Timer Resolution Drift -- Floor "<10 ms", Optimal '
          '"<1 ms", Ceiling "50 ms".',
      'The accumulated total equals the sum of the recorded intervals to the '
          'microsecond across three start/pause cycles, so the accumulator '
          'loses nothing and double-counts nothing',
      () {
        final _Clock clock = _Clock(DateTime(2026, 8, 18, 9));
        final HabotInteractionTimer timer = HabotInteractionTimer(
          taskId: 'byt-1',
          clock: clock.call,
        );
        addTearDown(timer.dispose);
        for (int i = 0; i < 3; i++) {
          timer.start();
          clock.advance(const Duration(milliseconds: 1234));
          timer.pause();
          clock.advance(const Duration(milliseconds: 567));
        }
        measuredDriftUs = timer.accumulationDrift.inMicroseconds;
        return measuredDriftUs == 0 &&
            timer.meetsDriftFloor &&
            timer.meetsDriftOptimal &&
            HabotInteractionTimer.driftFloor == HabotMotion.mtoTimerDriftFloor &&
            HabotInteractionTimer.driftOptimal ==
                HabotMotion.mtoTimerDriftOptimal &&
            HabotInteractionTimer.driftCeiling ==
                HabotMotion.mtoTimerDriftCeiling;
      },
    );

    gate(
      'GEN-03866-G3',
      'Setup Step (Action) read with GEN-00843 (Step 94) and GEN-03591 (Step '
          '95): the queue reallocates on WALL CLOCK, the SLA is measured on '
          'wall clock, and the worker is credited with WORKED time.',
      'A task paused past the SLA still reports as over SLA on elapsed time '
          'while its worked time stays small -- the two clocks answer '
          'different questions and neither is derived from the other',
      () {
        final _Clock clock = _Clock(DateTime(2026, 8, 18, 9));
        final HabotInteractionTimer timer = HabotInteractionTimer(
          taskId: 'byt-1',
          clock: clock.call,
        );
        addTearDown(timer.dispose);
        timer.start();
        clock.advance(const Duration(minutes: 1));
        timer.pause();
        clock.advance(const Duration(minutes: 20));
        return timer.workedDuration == const Duration(minutes: 1) &&
            timer.elapsedSinceStart == const Duration(minutes: 21) &&
            timer.isOverSla &&
            timer.state == HabotTimerState.paused;
      },
    );

    test('[GEN-03866-G4] the timer bands match tokens.json, which is the '
        'source of truth', () {
      final Map<String, Object?> tokens =
          jsonDecode(
                File(
                  'lib/design_system/tokens/tokens.json',
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final Map<String, Object?> mto = tokens['mto']! as Map<String, Object?>;

      final Map<String, int> expected = <String, int>{
        'timer_drift_floor_ms': HabotMotion.mtoTimerDriftFloor.inMilliseconds,
        'timer_drift_optimal_ms':
            HabotMotion.mtoTimerDriftOptimal.inMilliseconds,
        'timer_drift_ceiling_ms':
            HabotMotion.mtoTimerDriftCeiling.inMilliseconds,
        'reallocation_window_minutes':
            HabotMotion.mtoReallocationWindow.inMinutes,
        'sla_target_minutes': HabotMotion.mtoSlaTarget.inMinutes,
      };
      final List<String> drifted = <String>[];
      expected.forEach((String key, int value) {
        if (mto[key] != value) {
          drifted.add('$key: json ${mto[key]} vs dart $value');
        }
      });
      expect(drifted, isEmpty, reason: drifted.join('; '));
      expect(mto['peripheral_element_count_allowed'], 0);
      expect(mto['evidence_pane_share'], 0.5);

      gates.add(
        AissGate(
          id: 'GEN-03866-G4',
          requirementSource:
              'RCGLA-001 (Step 2) made tokens.json the source of truth and the '
              'Dart constants its mirror. This batch adds an mto section.',
          description:
              'Every MTO timing constant matches tokens.json, so the policy '
              'numbers this batch introduced cannot drift from the file that '
              'declares them',
          passed: true,
          detail: '${expected.length} keys checked, 0 drifted',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03866',
        atomicStepReferenceId: 'GEN-03866-A01',
        setupStepAction:
            'Add an interaction timer tracking worker execution duration on '
            'the mobile screen.',
        implementationOrder: 93,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Add an interaction timer tracking worker execution duration':
              'worked, elapsed and paused durations kept apart; readout '
              '${measuredReadout.isEmpty ? "not measured" : measuredReadout}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'GENERATED ROW -- Setup Step and Description are identical; '
              'Expected Output and Completion Measures are template prose. Not '
              'gated. THE METRIC FITS and is measurable in one of its two '
              'halves: arithmetic drift is observable here and is reported; '
              'wall-clock drift on a handset under load is NOT PRODUCED and no '
              'figure is invented for it.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Interaction Timer Resolution Drift',
            observed: measuredDriftUs < 0
                ? 'not measured'
                : '${(measuredDriftUs / 1000).toStringAsFixed(3)}ms of '
                      'accumulation drift across three start/pause cycles on a '
                      'driven clock -- inside the <1ms optimal. SCOPE STATED: '
                      'this is the accumulator, not the device clock. '
                      'Wall-clock drift on a handset needs a profile-mode run '
                      'and is NOT PRODUCED here.',
            floor: '<10 ms',
            optimal: '<1 ms',
            ceiling: '50 ms',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/interaction_timer.dart',
          'lib/design_system/tokens/motion_tokens.dart',
        ],
      ),
    );
  });
}
