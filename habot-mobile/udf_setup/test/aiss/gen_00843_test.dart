/// AISS GATE -- Step 94 of 95
/// Global Reference ID:       GEN-00843
/// Atomic Steps Reference ID: GEN-00843-A01
/// Setup Step (Action):       "Deploy Automated MTO Task Allocation &
///                             Exception Ranking Engine"
/// Setup Step Description:    "Program auto-reallocation logic RE-ASSIGNING
///                             TASKS IF UNCOMPLETED WITHIN 5 MINUTES."
/// Metric: Auto-Reallocation Timer -- Floor 5 mins, Optimal 5 mins,
///         Ceiling 5 mins.
///
/// THE METRIC IS THE REQUIREMENT. Floor, optimal and ceiling are the same
/// number, and that number is the rule the Description states. So there is no
/// range to check: the gate asserts the window IS five minutes, that it comes
/// from the token file rather than being written in the queue, and that a task
/// crossing it is actually reassigned while one just short of it is not.
///
/// RANKING IS STEP 78's, NOT A SECOND ORDERING. HC-BOG-0018 built the P1-P4
/// scale and the priority-then-oldest rule, and gated it. An exception queue
/// that ordered differently would be a second answer to "what is most urgent",
/// so G2 runs the same input through both and requires the same order out.
///
/// A GENERATED ROW OTHERWISE: Expected Output is the template restatement,
/// Completion Measures is "100% CI/CD pass rate", and the Material Design
/// columns are the shared boilerplate. None gated.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/task_queue.dart';
import 'package:udf_setup/design_system/notifications/alert_priority.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

HabotByt _byt(String id) => HabotByt.fromDelivery(
  id: id,
  box: _box,
  snippet: Uri.parse(
    'https://assets.habot.internal/crops/$id.png'
    '?crop=${HabotCropContract.signatureFor(_box)}',
  ),
  prompt: 'Read the invoice total',
  expectedFormat: 'digits and a decimal point',
)!;

final DateTime _base = DateTime(2026, 8, 18, 9);

class _Clock {
  _Clock(this.now);
  DateTime now;
  DateTime call() => now;
  void advance(Duration by) => now = now.add(by);
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  String rankedOrder = '';
  int measuredReallocations = -1;

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

  group('GEN-00843-A01 :: the engine', () {
    gate(
      'GEN-00843-G1',
      'Setup Step Description AND Metric: "re-assigning tasks if uncompleted '
          'WITHIN 5 MINUTES", with 5 mins as floor, optimal and ceiling.',
      'The window is exactly five minutes and comes from the token file; a '
          'task held four minutes stays put, one held five is reclaimed, and '
          'the hand-back is recorded rather than silent',
      () {
        final _Clock clock = _Clock(_base);
        final HabotTaskQueue queue = HabotTaskQueue(clock: clock.call);
        addTearDown(queue.dispose);
        queue.enqueue(
          HabotMtoTask(
            byt: _byt('byt-1'),
            priority: HabotAlertPriority.p2,
            queuedAt: _base,
          ),
        );
        queue.allocate('worker-a');

        clock.advance(const Duration(minutes: 4));
        final List<HabotMtoTask> early = queue.reclaimStale();

        clock.advance(const Duration(minutes: 1));
        final List<HabotMtoTask> due = queue.reclaimStale();
        measuredReallocations = queue.reallocations.length;

        return HabotTaskQueue.reallocationWindow ==
                const Duration(minutes: 5) &&
            HabotTaskQueue.reallocationWindow ==
                HabotMotion.mtoReallocationWindow &&
            early.isEmpty &&
            due.length == 1 &&
            due.single.isWaiting &&
            due.single.reallocationCount == 1 &&
            measuredReallocations == 1 &&
            queue.reallocations.single.from == 'worker-a' &&
            queue.reallocations.single.heldFor >=
                HabotTaskQueue.reallocationWindow;
      },
    );

    gate(
      'GEN-00843-G2',
      'Setup Step (Action): "Exception RANKING Engine" -- read against '
          'HC-BOG-0018 (Step 78), which already built the P1-P4 scale and the '
          'priority-then-oldest ordering.',
      'The queue ranks by priority and then by age, and on the same five '
          'items it produces exactly the order the Step 78 sorter produces -- '
          'so there is one ordering in this app, not two',
      () {
        final HabotTaskQueue queue = HabotTaskQueue();
        addTearDown(queue.dispose);
        final List<List<Object>> seeds = <List<Object>>[
          <Object>['t1', HabotAlertPriority.p2, 0],
          <Object>['t2', HabotAlertPriority.p1, 30],
          <Object>['t3', HabotAlertPriority.p1, 5],
          <Object>['t4', HabotAlertPriority.p4, 1],
          <Object>['t5', HabotAlertPriority.p2, 2],
        ];
        final List<HabotPrioritisedAlert> equivalents =
            <HabotPrioritisedAlert>[];
        for (final List<Object> seed in seeds) {
          final String id = seed[0] as String;
          final HabotAlertPriority priority = seed[1] as HabotAlertPriority;
          final DateTime at = _base.add(Duration(minutes: seed[2] as int));
          queue.enqueue(
            HabotMtoTask(byt: _byt(id), priority: priority, queuedAt: at),
          );
          equivalents.add(
            HabotPrioritisedAlert(
              id: id,
              priority: priority,
              title: id,
              cause: HabotRecordCause(
                summary: 'queued task',
                detectedAt: at,
                source: 'mto.queue',
              ),
              raisedAt: at,
            ),
          );
        }
        final List<String> queueOrder = queue
            .ranked()
            .map((HabotMtoTask t) => t.id)
            .toList();
        final List<String> alertOrder = HabotAlertSorting.sort(equivalents)
            .map((HabotPrioritisedAlert a) => a.id)
            .toList();
        rankedOrder = queueOrder.join(' ');
        return queueOrder.join() == alertOrder.join() &&
            queueOrder.first == 't3' &&
            queueOrder.last == 't4';
      },
    );

    gate(
      'GEN-00843-G3',
      'Setup Step (Action): "Automated TASK ALLOCATION" -- allocation is the '
          'other half, and it must take the ranked head rather than whatever '
          'happens to be first in the list.',
      'Allocation hands out the top-ranked waiting task, marks it in '
          'progress, and returns null when there is nothing waiting instead of '
          'inventing one',
      () {
        final _Clock clock = _Clock(_base);
        final HabotTaskQueue queue = HabotTaskQueue(clock: clock.call);
        addTearDown(queue.dispose);
        queue
          ..enqueue(
            HabotMtoTask(
              byt: _byt('low'),
              priority: HabotAlertPriority.p4,
              queuedAt: _base,
            ),
          )
          ..enqueue(
            HabotMtoTask(
              byt: _byt('high'),
              priority: HabotAlertPriority.p1,
              queuedAt: _base.add(const Duration(minutes: 10)),
            ),
          );
        final HabotMtoTask? first = queue.allocate('worker-a');
        final HabotMtoTask? second = queue.allocate('worker-b');
        final HabotMtoTask? third = queue.allocate('worker-c');
        return first?.id == 'high' &&
            second?.id == 'low' &&
            third == null &&
            queue.inProgressCount == 2 &&
            queue.waitingCount == 0;
      },
    );

    gate(
      'GEN-00843-G4',
      'A queue that loses work is worse than no queue. Read against '
          'GEN-02455 (Step 75), where the notification centre had to account '
          'for every item it was offered.',
      'Every task is waiting, in progress or complete at all times -- through '
          'allocation, reclamation and completion -- and a completed task is '
          'never reclaimed by the five-minute rule',
      () {
        final _Clock clock = _Clock(_base);
        final HabotTaskQueue queue = HabotTaskQueue(clock: clock.call);
        addTearDown(queue.dispose);
        for (int i = 0; i < 3; i++) {
          queue.enqueue(
            HabotMtoTask(
              byt: _byt('t$i'),
              priority: HabotAlertPriority.p2,
              queuedAt: _base,
            ),
          );
        }
        queue
          ..allocate('worker-a')
          ..allocate('worker-b');
        queue.complete('t0');
        clock.advance(const Duration(minutes: 6));
        final List<HabotMtoTask> reclaimed = queue.reclaimStale();
        return queue.isAccountedFor &&
            queue.tasks.length == 3 &&
            queue.completedCount == 1 &&
            reclaimed.length == 1 &&
            reclaimed.single.id != 't0' &&
            queue.waitingCount == 2;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00843',
        atomicStepReferenceId: 'GEN-00843-A01',
        setupStepAction:
            'Deploy Automated MTO Task Allocation & Exception Ranking Engine',
        implementationOrder: 94,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Program auto-reallocation logic re-assigning tasks if uncompleted '
                  'within 5 minutes':
              'window '
              '${HabotTaskQueue.reallocationWindow.inMinutes} minutes, from '
              'HabotMotion.mtoReallocationWindow',
          'Ranking': rankedOrder.isEmpty
              ? 'not measured'
              : 'priority then oldest: $rankedOrder',
          'Reallocations recorded': measuredReallocations < 0
              ? 'not measured'
              : '$measuredReallocations, each with the worker it came back '
                    'from and how long they held it',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'GENERATED ROW -- Expected Output and Completion Measures are '
              'template prose and the Material Design columns are the shared '
              'boilerplate. Not gated. THE METRIC IS THE REQUIREMENT: floor, '
              'optimal and ceiling are all "5 mins", which is the rule the '
              'Description states, so it is asserted as an equality rather '
              'than a range. RANKING REUSED: the ordering is HC-BOG-0018\'s '
              '(Step 78), proved by running the same input through both.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Auto-Reallocation Timer',
            observed:
                '${HabotTaskQueue.reallocationWindow.inMinutes} minutes, read '
                'from the token file. A task held 4 minutes was not reclaimed; '
                'at 5 minutes it was, its hand-back recorded with the worker '
                'and the hold time, and its reallocation count incremented. '
                'Completed tasks are never reclaimed.',
            floor: '5 mins',
            optimal: '5 mins',
            ceiling: '5 mins',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/task_queue.dart',
          'lib/design_system/tokens/motion_tokens.dart',
        ],
      ),
    );
  });
}
