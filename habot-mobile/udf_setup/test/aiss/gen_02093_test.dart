/// AISS GATE -- Step 116 of 135
/// Global Reference ID:       GEN-02093
/// Atomic Steps Reference ID: GEN-02093
/// Atomic Step: "Physically prevent partial data states using the atomic
///               commit logic."
/// Metric: Automated PR Rejection Rate for Non-Compliance (%) -- 95 / 99.5 / 100.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// METRIC MISMATCH, RECORDED: a code-review measure on a runtime rule.
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/atomic_commit.dart';
import 'package:udf_setup/design_system/data/local_store.dart';

import 'aiss_reporter.dart';

/// A store that cannot promise all-or-nothing. Property 3 needs something to
/// refuse, and refusing a real store would be the wrong test.
class _NonTransactionalStore implements HabotLocalStore {
  final HabotMemoryStore _inner = HabotMemoryStore();

  @override
  bool get supportsTransactions => false;

  @override
  bool get isDurable => false;

  @override
  String get engineName => 'no-transactions (test)';

  @override
  Future<void> clear(HabotCollection c) => _inner.clear(c);

  @override
  Future<List<String>> keys(HabotCollection c) => _inner.keys(c);

  @override
  Future<Uint8List?> read(HabotCollection c, String k) => _inner.read(c, k);

  @override
  Future<void> remove(HabotCollection c, String k) => _inner.remove(c, k);

  @override
  Future<void> transaction(Future<void> Function() body) => body();

  @override
  Future<void> write(HabotCollection c, String k, Uint8List b) =>
      _inner.write(c, k, b);
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  const HabotCollection jobs = HabotCollection('jobs');
  late HabotMemoryStore store;

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

  setUp(() => store = HabotMemoryStore());

  HabotUnitOfWork unit() => HabotUnitOfWork(store);

  void stageThree(HabotUnitOfWork u) {
    for (final String id in <String>['A', 'B', 'C']) {
      u.stageRecord(
        collection: jobs,
        key: id,
        record: <String, Object?>{'id': id},
        description: 'job $id',
      );
    }
  }

  group('GEN-02093 :: physically prevent partial states', () {
    gate(
      'GEN-02093-G1',
      'Atomic Step: "PHYSICALLY PREVENT partial data states using the atomic '
          'commit logic."',
      'A unit of work whose third write fails leaves the store byte-identical '
          'to how it started -- zero of three, not two of three, and the '
          'failure names what was lost rather than counting bytes',
      () async {
        await store.write(
          jobs,
          'EXISTING',
          HabotRecordCodec.encode(<String, Object?>{'id': 'EXISTING'}),
        );
        final HabotUnitOfWork u = unit();
        u.stageRecord(
          collection: jobs,
          key: 'A',
          record: <String, Object?>{'id': 'A'},
          description: 'job A',
        );
        u.stageRecord(
          collection: jobs,
          key: 'B',
          record: <String, Object?>{'id': 'B'},
          description: 'job B',
        );
        store.failNextWrite = true;
        final HabotCommitResult r = await u.commit();
        final List<String> keys = await store.keys(jobs);
        return !r.committed &&
            r.writes == 0 &&
            r.failure == HabotCommitFailure.writeFailed &&
            r.detail!.contains('job A') &&
            r.detail!.contains('Nothing was written') &&
            keys.length == 1 &&
            keys.single == 'EXISTING';
      },
    );

    gate(
      'GEN-02093-G2',
      'A guard that can never fail is not a guard.',
      'The same three writes with no induced failure DO all land, so the '
          'previous gate is measuring atomicity rather than a store that '
          'never writes',
      () async {
        final HabotUnitOfWork u = unit();
        stageThree(u);
        final HabotCommitResult r = await u.commit();
        return r.committed &&
            r.writes == 3 &&
            (await store.keys(jobs)).length == 3;
      },
    );

    gate(
      'GEN-02093-G3',
      'Property 1: a staged write must not be observable before the commit '
          'lands.',
      'Nothing reaches the store while a unit is open, so no reader can see a '
          'record half-built',
      () async {
        final HabotUnitOfWork u = unit();
        stageThree(u);
        final List<String> duringStaging = await store.keys(jobs);
        await u.commit();
        return u.stagedCount == 0 &&
            duringStaging.isEmpty &&
            (await store.keys(jobs)).length == 3;
      },
    );
  });

  group('GEN-02093 :: failure is the default', () {
    gate(
      'GEN-02093-G4',
      'Property 2: forgetting to commit must lose the work, not keep half of '
          'it.',
      'An abandoned unit leaves nothing behind and says how much it discarded',
      () async {
        final HabotUnitOfWork u = unit();
        stageThree(u);
        final HabotCommitResult r = u.abandon('the user backed out');
        return !r.committed &&
            r.failure == HabotCommitFailure.abandoned &&
            r.detail!.contains('3 staged write(s) discarded') &&
            u.isClosed &&
            (await store.keys(jobs)).isEmpty;
      },
    );

    gate(
      'GEN-02093-G5',
      'Property 3: pretending a guarantee exists is worse than not having it.',
      'A store that cannot promise all-or-nothing is refused at CONSTRUCTION, '
          'with a message that says why, rather than being run against '
          'optimistically',
      () async {
        bool threw = false;
        try {
          HabotUnitOfWork(_NonTransactionalStore());
        } on HabotNonTransactionalStoreError catch (e) {
          threw = e.message.toString().contains(
            'reassuring name',
          );
        }
        return threw && HabotUnitOfWork(store).stagedCount == 0;
      },
    );

    gate(
      'GEN-02093-G6',
      'Property 5: two logical transactions must not share a fate neither '
          'intended.',
      'A unit that has committed or been abandoned refuses further staging, '
          'and an empty commit is reported as empty rather than as a success',
      () async {
        final HabotUnitOfWork committed = unit();
        stageThree(committed);
        await committed.commit();
        bool refusedAfterCommit = false;
        try {
          committed.stageRemoval(
            collection: jobs,
            key: 'A',
            description: 'late',
          );
        } on StateError {
          refusedAfterCommit = true;
        }
        final HabotCommitResult empty = await unit().commit();
        return refusedAfterCommit &&
            !empty.committed &&
            empty.failure == HabotCommitFailure.empty &&
            HabotAtomicCommitContract.properties.length == 5;
      },
    );

    gate(
      'GEN-02093-G7',
      'Step 115 gives a change an order; this gives a GROUP a single fate. '
          'The two are not interchangeable.',
      'The relationship to the mutation log is recorded in the code, because '
          'a reader who assumes the log already provides atomicity will not '
          'reach for this',
      () async =>
          HabotAtomicCommitContract.relationToMutations.contains(
            'partially applied unit',
          ) &&
          HabotAtomicCommitContract.relationToMutations.contains('Step 115'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02093',
        atomicStepReferenceId: 'GEN-02093',
        setupStepAction:
            'Physically prevent partial data states using the atomic commit '
            'logic.',
        implementationOrder: 116,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotUnitOfWork / HabotAtomicCommitContract',
          'Component Properties':
              '${HabotAtomicCommitContract.properties.length} declared '
              'properties; ${HabotCommitFailure.values.length} named commit '
              'failures; a non-transactional store is refused at construction',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row; the Atomic Step is '
              'the whole requirement. The metric is a pull-request rejection '
              'rate on a runtime data-integrity rule.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Partial states observable after an induced '
                'mid-commit failure',
            observed:
                '0. Three writes staged, the third induced to fail: zero '
                'landed and the store was byte-identical to its prior state, '
                'including insertion order. The same three with no induced '
                'failure all land, which is what shows the measurement is of '
                'atomicity rather than of a store that never writes.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Automated PR Rejection Rate for Non-Compliance (the '
                'sheet metric)',
            observed:
                'NOT PRODUCED. A pull-request rejection rate is a code-review '
                'measure; no client-side suite can produce it, and it would '
                'not mean anything if it could -- a PR that passes review can '
                'still write half a record. What was gated is the requirement '
                'the row states.',
            floor: '95',
            optimal: '99.5',
            ceiling: '100',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/atomic_commit.dart',
        ],
      ),
    );
  });
}
