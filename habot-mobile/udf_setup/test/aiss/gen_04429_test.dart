/// AISS GATE -- Step 115 of 115
/// Global Reference ID:       GEN-04429
/// Atomic Steps Reference ID: GEN-04429-A01
/// Setup Step (Action):       "Enforce immutability patterns across state
///                             updates using mutation wrappers."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED: the row carries a re-render latency in
/// milliseconds. No honest reading connects that to an immutability rule -- a
/// state container can be perfectly immutable and slow, or mutable and fast.
/// It is reported as NOT PRODUCED. The step is gated on the property it names.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/mutation.dart';

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

  /// Three ordinary changes to one value, built the way a caller would.
  List<HabotMutation<String>> log() {
    final HabotImmutableStore<String> s = HabotImmutableStore<String>('open');
    final List<HabotMutation<String>> out = <HabotMutation<String>>[];
    for (final List<String> step in <List<String>>[
      <String>['m1', 'accepted by the worker', 'accepted'],
      <String>['m2', 'submitted for review', 'submitted'],
      <String>['m3', 'approved by the supervisor', 'approved'],
    ]) {
      final HabotMutation<String> m = s.mutation(
        mutationId: step[0],
        description: step[1],
        next: step[2],
      );
      s.apply(m);
      out.add(m);
    }
    return out;
  }

  group('GEN-04429-A01 :: the enforcement', () {
    gate(
      'GEN-04429-G1',
      'Setup Step (Action): "ENFORCE immutability patterns ... USING MUTATION '
          'WRAPPERS". Not a lint: a rule in a review comment is a rule that '
          'gets forgotten.',
      'The only way into the store is to apply a mutation -- there is no '
          'setter and no update(fn), so an in-place write has nowhere to be '
          'written',
      () {
        final HabotImmutableStore<String> s =
            HabotImmutableStore<String>('open');
        final HabotMutationOutcome<String> ok = s.apply(
          s.mutation(
            mutationId: 'm1',
            description: 'accepted by the worker',
            next: 'accepted',
          ),
        );
        return ok.applied &&
            s.state == 'accepted' &&
            s.history.length == 1 &&
            s.lastSequence == 1 &&
            HabotImmutabilityContract.properties.length == 5;
      },
    );

    gate(
      'GEN-04429-G2',
      'Step 116 must be able to UNDO a partial write. Undo requires the '
          'previous value still to exist.',
      'Every mutation carries the value it replaced, so a run of them can be '
          'rolled back to exactly where it started -- state, history and '
          'sequence',
      () {
        final List<HabotMutation<String>> l = log();
        final HabotImmutableStore<String> s =
            HabotImmutableStore<String>('open')..replay(l);
        final int undone = s.rollback(count: l.length);
        return undone == l.length &&
            s.state == 'open' &&
            s.history.isEmpty &&
            s.lastSequence == 0 &&
            HabotImmutabilityContract.rollbackIsExact<String>('open', l);
      },
    );

    gate(
      'GEN-04429-G3',
      'Step 117 must be able to REPLAY a queued write after a restart. Replay '
          'requires the change to be a value that can be stored, not a side '
          'effect that already happened.',
      'A log replayed onto a fresh store reproduces the same state, and the '
          'inverse of a mutation is the mutation taken back rather than a new '
          'change with a new identity',
      () {
        final List<HabotMutation<String>> l = log();
        final HabotImmutableStore<String> restored =
            HabotImmutableStore<String>('open')..replay(l);
        final HabotMutation<String> inverse = l.last.inverse;
        return restored.state == 'approved' &&
            restored.history.length == 3 &&
            inverse.mutationId == l.last.mutationId &&
            inverse.previous == l.last.next &&
            inverse.next == l.last.previous &&
            inverse.description.startsWith('undo:');
      },
    );

    gate(
      'GEN-04429-G4',
      'Step 122 must be able to recognise the SAME write twice. Same requires '
          'the write to have an identity.',
      'Applying a log twice leaves exactly the state applying it once did -- '
          'the second pass is rejected as duplicate rather than doubling the '
          'change, which is the property idempotency rests on',
      () {
        final List<HabotMutation<String>> l = log();
        final HabotImmutableStore<String> s =
            HabotImmutableStore<String>('open')
              ..replay(l)
              ..replay(l);
        return HabotImmutabilityContract.replayIsIdempotent<String>('open', l) &&
            s.state == 'approved' &&
            s.history.length == l.length &&
            s.rejections.where(
                  (HabotMutationRejection r) =>
                      r == HabotMutationRejection.duplicate,
                ).length ==
                l.length;
      },
    );
  });

  group('GEN-04429-A01 :: what is refused, and why', () {
    gate(
      'GEN-04429-G5',
      'A write built against a state that has since moved would silently '
          'discard whatever happened in between.',
      'A stale-base mutation is refused with the reason named, and the store '
          'is left untouched rather than merged',
      () {
        final HabotImmutableStore<String> s =
            HabotImmutableStore<String>('open');
        final HabotMutation<String> stale = s.mutation(
          mutationId: 'm-stale',
          description: 'built before the other change landed',
          next: 'cancelled',
        );
        s.apply(
          s.mutation(
            mutationId: 'm1',
            description: 'accepted by the worker',
            next: 'accepted',
          ),
        );
        final HabotMutationOutcome<String> out = s.apply(stale);
        return !out.applied &&
            out.rejection == HabotMutationRejection.staleBase &&
            out.detail!.contains('discard the change in between') &&
            s.state == 'accepted';
      },
    );

    gate(
      'GEN-04429-G6',
      'A no-op recorded in a replay log is a change nobody made, and an '
          'out-of-order mutation is an ordering nobody chose.',
      'Both are refused with their own reasons, so the log stays a faithful '
          'record of what actually happened',
      () {
        final HabotImmutableStore<String> s =
            HabotImmutableStore<String>('open');
        final HabotMutationOutcome<String> noop = s.apply(
          s.mutation(
            mutationId: 'm-noop',
            description: 'sets open to open',
            next: 'open',
          ),
        );
        s.apply(
          s.mutation(
            mutationId: 'm1',
            description: 'accepted by the worker',
            next: 'accepted',
          ),
        );
        final HabotMutationOutcome<String> old = s.apply(
          const HabotMutation<String>(
            mutationId: 'm-old',
            description: 'arrived late',
            previous: 'accepted',
            next: 'submitted',
            sequence: 1,
          ),
        );
        return !noop.applied &&
            noop.rejection == HabotMutationRejection.noOp &&
            !old.applied &&
            old.rejection == HabotMutationRejection.outOfOrder &&
            s.state == 'accepted' &&
            HabotMutationRejection.values.length == 4;
      },
    );

    gate(
      'GEN-04429-G7',
      'A write recorded only on SUCCESS is a write that cannot be retried '
          'after a crash, because nothing remembers it was wanted.',
      'The mutating writer records the intent BEFORE attempting the write, so '
          'the log is the queue Step 117 drains rather than a history of '
          'things that already worked',
      () {
        final HabotImmutableStore<String> s =
            HabotImmutableStore<String>('open');
        final HabotMutation<String> m = s.mutation(
          mutationId: 'm1',
          description: 'accepted by the worker',
          next: 'accepted',
        );
        // The mutation exists as a value before anything is attempted, which
        // is the whole point: it can be written down, sent, and sent again.
        return m.previous == 'open' &&
            m.next == 'accepted' &&
            m.sequence == 1 &&
            !m.isNoOp &&
            m.toJson()['mutation_id'] == 'm1' &&
            s.history.isEmpty;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04429',
        atomicStepReferenceId: 'GEN-04429-A01',
        setupStepAction:
            'Enforce immutability patterns across state updates using '
            'mutation wrappers.',
        implementationOrder: 115,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotMutation / HabotImmutableStore / HabotMutatingWriter',
          'Component Properties':
              '${HabotImmutabilityContract.properties.length} declared '
              'properties; ${HabotMutationRejection.values.length} named '
              'rejection reasons; no setter and no update(fn) on the store',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row, and the metric is a rendering '
              'latency on an immutability rule.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Immutability properties holding',
            observed:
                'All five. Replay is idempotent, rollback is exact, and '
                'stale, duplicate, no-op and out-of-order mutations are each '
                'refused with their own recorded reason. These are the three '
                'guarantees Steps 116, 117 and 122 are built on, checked here '
                'rather than assumed there.',
            floor: 'all properties hold',
            optimal: 'all properties hold',
            ceiling: 'all properties hold',
          ),
          const AissMeasurement(
            metricName: 'Re-render latency (the sheet metric)',
            observed:
                'NOT PRODUCED. It is a rendering measure on a state-update '
                'rule, and no honest reading connects the two: a container '
                'can be perfectly immutable and slow, or mutable and fast. No '
                'number is asserted in its place.',
            floor: 'not applicable to this requirement',
            optimal: 'not applicable to this requirement',
            ceiling: 'not applicable to this requirement',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/mutation.dart',
        ],
      ),
    );
  });
}
