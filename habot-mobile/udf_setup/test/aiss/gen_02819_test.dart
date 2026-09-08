/// AISS GATE -- Step 117 of 135
/// Global Reference ID:       GEN-02819
/// Atomic Steps Reference ID: GEN-02819
/// Atomic Step: "Deploy local SQLite fallback queue for offline mobile
///               telemetry when devices lose connectivity."
/// Metric: Task Completion Status -- Floor 0.8, Optimal 1, Ceiling 1.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// SUBSTITUTION RECORDED: SQLite -> the Step 113 HabotLocalStore contract.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotMemoryStore store;
  late HabotOutbox outbox;

  void gate(
    String id,
    String source,
    String description,
    Future<bool> Function() run,
  ) {
    test('[$id] $description', () async {
      bool passed = false;
      try {
        passed = await run();
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

  setUp(() {
    store = HabotMemoryStore();
    outbox = HabotOutbox(store: store, maxAttempts: 3);
  });

  Future<void> enqueueThree() async {
    for (final String id in <String>['t1', 't2', 't3']) {
      await outbox.enqueue(
        id: id,
        kind: 'telemetry',
        payload: <String, Object?>{'event': id},
      );
    }
  }

  group('GEN-02819 :: the queue', () {
    gate(
      'GEN-02819-G1',
      'Atomic Step: a "fallback QUEUE for offline mobile telemetry WHEN '
          'DEVICES LOSE CONNECTIVITY".',
      'Work put on the queue while offline is still there afterwards, in the '
          'order it was done -- a queue that drains in hash order silently '
          'rewrites a worker day',
      () async {
        await enqueueThree();
        final List<HabotOutboxEntry> pending = await outbox.pending();
        return pending.length == 3 &&
            pending.map((HabotOutboxEntry e) => e.id).join(',') == 't1,t2,t3' &&
            pending.first.sequence < pending.last.sequence &&
            (await outbox.next())!.id == 't1';
      },
    );

    gate(
      'GEN-02819-G2',
      'Two taps on Submit is one submission, and that has to be true at the '
          'queue as well as at the wire (Step 122).',
      'Enqueuing an id that is already queued returns the existing entry '
          'untouched rather than adding a second copy',
      () async {
        final HabotOutboxEntry first = await outbox.enqueue(
          id: 't1',
          kind: 'telemetry',
          payload: <String, Object?>{'event': 'first'},
        );
        final HabotOutboxEntry again = await outbox.enqueue(
          id: 't1',
          kind: 'telemetry',
          payload: <String, Object?>{'event': 'second'},
        );
        return (await outbox.pendingCount) == 1 &&
            again.sequence == first.sequence &&
            again.payload['event'] == 'first';
      },
    );

    gate(
      'GEN-02819-G3',
      'A restart that restarts the numbering would let two entries claim the '
          'same place in the order.',
      'The sequence counter is rebuilt from what is on disk, so a queue '
          'reopened after a restart carries on numbering rather than colliding',
      () async {
        await enqueueThree();
        // A "restart": a fresh queue object over the same store.
        final HabotOutbox reopened = HabotOutbox(store: store);
        await reopened.restore();
        final HabotOutboxEntry next = await reopened.enqueue(
          id: 't4',
          kind: 'telemetry',
          payload: <String, Object?>{'event': 't4'},
        );
        final List<HabotOutboxEntry> all = await reopened.pending();
        return next.sequence == 4 &&
            all.length == 4 &&
            all.map((HabotOutboxEntry e) => e.sequence).toSet().length == 4;
      },
    );
  });

  group('GEN-02819 :: failure, and the third option', () {
    gate(
      'GEN-02819-G4',
      'An entry that is sent but still queued is the same bug as one that is '
          'queued but never sent, pointed the other way.',
      'Marking sent removes the entry through the store, so the removal is as '
          'durable as the write was',
      () async {
        await enqueueThree();
        final HabotOutboxEntry first = (await outbox.next())!;
        await outbox.markSent(first);
        return (await outbox.pendingCount) == 2 &&
            (await store.keys(HabotOutbox.collection)).length == 2 &&
            (await outbox.next())!.id == 't2';
      },
    );

    gate(
      'GEN-02819-G5',
      'Retrying forever drains a battery in a dead-signal area; dropping loses '
          'the user work with no record. A dead letter is the third option.',
      'An entry that exhausts its attempts is moved aside -- kept, countable, '
          'carrying why it died, and out of the drain path',
      () async {
        await outbox.enqueue(
          id: 'bad',
          kind: 'telemetry',
          payload: <String, Object?>{'event': 'bad'},
        );
        HabotOutboxEntry? e = await outbox.next();
        for (int i = 0; i < 3; i++) {
          e = await outbox.markInFlight(e!);
          e = await outbox.markFailed(e, 'server said 422');
        }
        final List<HabotOutboxEntry> dead = await outbox.dead();
        return dead.length == 1 &&
            dead.single.id == 'bad' &&
            dead.single.state == HabotOutboxState.dead &&
            dead.single.lastError == 'server said 422' &&
            await outbox.next() == null &&
            (await store.keys(HabotOutbox.collection)).isEmpty;
      },
    );

    gate(
      'GEN-02819-G6',
      'The operator action for "the server was broken, not the payload".',
      'A dead letter can be revived with its attempts reset, and returns to '
          'the queue rather than being recreated',
      () async {
        await outbox.enqueue(
          id: 'bad',
          kind: 'telemetry',
          payload: <String, Object?>{'event': 'bad'},
        );
        HabotOutboxEntry? e = await outbox.next();
        for (int i = 0; i < 3; i++) {
          e = await outbox.markInFlight(e!);
          e = await outbox.markFailed(e, 'server down');
        }
        final HabotOutboxEntry? revived = await outbox.revive('bad');
        return revived != null &&
            revived.attempts == 0 &&
            revived.state == HabotOutboxState.pending &&
            (await outbox.dead()).isEmpty &&
            (await outbox.next())!.id == 'bad';
      },
    );

    gate(
      'GEN-02819-G7',
      'Metric: Task Completion Status, floor 0.8. A dead letter is work the '
          'user did that the server has not got.',
      'The completion figure counts a dead letter as NOT complete, so the '
          'number stays useful exactly when it matters, and the SQLite '
          'substitution is recorded in the code rather than alongside it',
      () async {
        return outbox.completionFor(enqueued: 10, sent: 8) == 0.8 &&
            outbox.completionFor(enqueued: 10, sent: 10) == 1.0 &&
            outbox.completionFor(enqueued: 0, sent: 0) == 1.0 &&
            HabotOutbox.engineSubstitution.contains('SQLite') &&
            HabotOutbox.engineSubstitution.contains('HabotLocalStore') &&
            !outbox.isDurable &&
            outbox.engineName.contains('NOT durable');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02819',
        atomicStepReferenceId: 'GEN-02819',
        setupStepAction:
            'Deploy local SQLite fallback queue for offline mobile telemetry '
            'when devices lose connectivity.',
        implementationOrder: 117,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotOutbox / HabotOutboxEntry',
          'Component Properties':
              '${HabotOutboxState.values.length} entry states; drain in '
              'insertion order; duplicate ids coalesced at enqueue; dead '
              'letters after the attempt limit, revivable',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row. The row names '
              'SQLite, which this environment cannot add; the substitution is '
              'recorded in HabotOutbox.engineSubstitution.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Task Completion Status (queued work reaching the '
                'server)',
            observed:
                'Computed from enqueued vs sent, with dead letters counted as '
                'NOT complete. The queue itself was verified to preserve '
                'order across a simulated restart, to coalesce a duplicate id '
                'rather than queue it twice, and to move an exhausted entry '
                'aside rather than retrying it forever or dropping it.',
            floor: '0.8',
            optimal: '1',
            ceiling: '1',
          ),
          const AissMeasurement(
            metricName: 'Durability of this configuration',
            observed:
                'FALSE, and reported rather than hidden. The gate runs against '
                'HabotMemoryStore, which does not survive process death. The '
                'queue reports isDurable = false, and Step 128 refuses to '
                'detach a socket over a queue in that state. A real engine '
                'behind the same interface makes it true without a code '
                'change here.',
            floor: 'durable in production',
            optimal: 'durable in production',
            ceiling: 'durable in production',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/outbox.dart',
        ],
      ),
    );
  });
}
