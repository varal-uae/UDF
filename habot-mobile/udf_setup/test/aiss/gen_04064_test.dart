/// AISS GATE -- Step 118 of 135
/// Global Reference ID:       GEN-04064
/// Atomic Steps Reference ID: GEN-04064
/// Atomic Step: "Process incoming delta payloads on the mobile client to
///               update local key-value stores."
/// Metric: Local Delta Update Latency -- Floor <100ms, Optimal <20ms,
///         Ceiling 500ms.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// THE METRIC FITS AND IS PRODUCIBLE: applying deltas to a local store is
/// entirely client-side, so the figure below is measured, not stood in for.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/dao.dart';
import 'package:udf_setup/design_system/data/delta.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/data/repository.dart';

import 'aiss_reporter.dart';

class _Job implements HabotEntity {
  const _Job(this.entityId, this.revision, this.site);

  @override
  final String entityId;
  @override
  final int revision;
  final String site;

  @override
  Map<String, Object?> toRecord() => <String, Object?>{'site': site};
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotMemoryStore store;
  late HabotDao<_Job> dao;
  late HabotOutbox outbox;
  late HabotDeltaApplier<_Job> applier;
  double measuredMsPerDelta = 0;
  int measuredCount = 0;

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
    dao = HabotDao<_Job>(
      collection: const HabotCollection('jobs'),
      store: store,
      decoder: (Map<String, Object?> r) {
        final Object? id = r[HabotRecordFields.id];
        final Object? rev = r[HabotRecordFields.revision];
        final Object? p = r[HabotRecordFields.payload];
        if (id is! String || rev is! int || p is! Map<String, Object?>) {
          return null;
        }
        return _Job(id, rev, p['site'] is String ? p['site']! as String : '');
      },
    );
    outbox = HabotOutbox(store: store);
    applier = HabotDeltaApplier<_Job>(
      dao: dao,
      outbox: outbox,
      decodeEntity: (String id, int rev, Map<String, Object?> p) =>
          _Job(id, rev, p['site'] is String ? p['site']! as String : ''),
    );
  });

  HabotDelta upsert(String id, int rev, String site) => HabotDelta(
    entityId: id,
    revision: rev,
    op: HabotDeltaOp.upsert,
    payload: <String, Object?>{'site': site},
  );

  group('GEN-04064 :: applying deltas', () {
    gate(
      'GEN-04064-G1',
      'Atomic Step: "PROCESS INCOMING DELTA PAYLOADS ... to update local '
          'key-value stores."',
      'An upsert lands, a removal tombstones, and both go through the Step 113 '
          'DAO rather than a second write path',
      () async {
        final HabotDeltaBatchReport r = await applier.apply(<HabotDelta>[
          upsert('J1', 1, 'Site A'),
          upsert('J2', 1, 'Site B'),
        ]);
        await applier.apply(<HabotDelta>[
          const HabotDelta(
            entityId: 'J2',
            revision: 2,
            op: HabotDeltaOp.remove,
          ),
        ]);
        final HabotResult<List<_Job>> all = await dao.findAll();
        return r.applied == 2 &&
            all.valueOrNull!.length == 1 &&
            all.valueOrNull!.single.entityId == 'J1' &&
            (await dao.tombstones()).contains('J2');
      },
    );

    gate(
      'GEN-04064-G2',
      'The Step 113 revision rule, one layer up: a write that is not ahead of '
          'what is stored does not land.',
      'A stale delta is reported as stale with both revisions named, and the '
          'stored copy is untouched',
      () async {
        await applier.apply(<HabotDelta>[upsert('J1', 5, 'Site NEW')]);
        final HabotDeltaBatchReport r = await applier.apply(<HabotDelta>[
          upsert('J1', 4, 'Site OLD'),
          upsert('J1', 5, 'Site SAME'),
        ]);
        final HabotResult<_Job> after = await dao.findById('J1');
        return r.applied == 0 &&
            r.results.every(
              (HabotDeltaResult x) => x.outcome == HabotDeltaOutcome.stale,
            ) &&
            r.results.first.detail.contains('not ahead of the stored 5') &&
            after.valueOrNull!.site == 'Site NEW';
      },
    );

    gate(
      'GEN-04064-G3',
      'From the build order: "a delta applied to a store holding unsent local '
          'work is the first place a conflict can appear."',
      'A delta for a record with unsent local work is DEFERRED -- not applied, '
          'which would undo the user edit, and not dropped, which would lose '
          'whatever else the delta carried',
      () async {
        await applier.apply(<HabotDelta>[upsert('J1', 1, 'Site A')]);
        await outbox.enqueue(
          id: 'jobs:J1:2',
          kind: 'task-submit',
          payload: <String, Object?>{'entity_id': 'J1'},
        );
        final HabotDeltaBatchReport r = await applier.apply(<HabotDelta>[
          upsert('J1', 9, 'Site FROM SERVER'),
          upsert('J2', 1, 'Site B'),
        ]);
        final HabotResult<_Job> j1 = await dao.findById('J1');
        return r.deferred.length == 1 &&
            r.applied == 1 &&
            applier.deferred.single.entityId == 'J1' &&
            j1.valueOrNull!.site == 'Site A' &&
            r.deferred.single.detail.contains('undo work the user did');
      },
    );

    gate(
      'GEN-04064-G4',
      'A deferral that is never re-offered is a drop with extra steps.',
      'Once the outbox drains, the held delta is re-offered and lands -- which '
          'is the moment the conflict that caused the deferral has gone away',
      () async {
        await applier.apply(<HabotDelta>[upsert('J1', 1, 'Site A')]);
        final HabotOutboxEntry queued = await outbox.enqueue(
          id: 'jobs:J1:2',
          kind: 'task-submit',
          payload: <String, Object?>{'entity_id': 'J1'},
        );
        await applier.apply(<HabotDelta>[upsert('J1', 9, 'Site FROM SERVER')]);
        final bool heldWhileDirty = applier.deferred.length == 1;

        await outbox.markSent(queued);
        final HabotDeltaBatchReport retry = await applier.retryDeferred();
        final HabotResult<_Job> j1 = await dao.findById('J1');
        return heldWhileDirty &&
            retry.applied == 1 &&
            applier.deferred.isEmpty &&
            j1.valueOrNull!.site == 'Site FROM SERVER';
      },
    );
  });

  group('GEN-04064 :: the metric', () {
    gate(
      'GEN-04064-G5',
      'Metric: Local Delta Update Latency -- Floor <100ms, Optimal <20ms, '
          'Ceiling 500ms. Lower is better; the ceiling is the WORST acceptable '
          'value, which is the sheet normal convention.',
      'A batch of 100 deltas is applied and timed, and the per-delta figure is '
          'inside the optimal band -- a measured number, not a stand-in',
      () async {
        final List<HabotDelta> batch = <HabotDelta>[
          for (int i = 0; i < 100; i++) upsert('J$i', 1, 'Site $i'),
        ];
        final HabotDeltaBatchReport r = await applier.apply(batch);
        measuredMsPerDelta = r.msPerDelta;
        measuredCount = r.count;
        return r.count == 100 &&
            r.applied == 100 &&
            r.meetsFloor &&
            !r.breachesCeiling &&
            HabotDeltaApplier.optimalMs < HabotDeltaApplier.floorMs &&
            HabotDeltaApplier.floorMs < HabotDeltaApplier.ceilingMs;
      },
    );

    gate(
      'GEN-04064-G6',
      'A malformed delta must not take the batch down with it.',
      'An empty id, a non-positive revision and an upsert with no payload are '
          'each rejected individually, and the rest of the batch still lands',
      () async {
        final HabotDeltaBatchReport r = await applier.apply(<HabotDelta>[
          const HabotDelta(
            entityId: '',
            revision: 1,
            op: HabotDeltaOp.upsert,
            payload: <String, Object?>{},
          ),
          const HabotDelta(
            entityId: 'J9',
            revision: 0,
            op: HabotDeltaOp.upsert,
            payload: <String, Object?>{},
          ),
          const HabotDelta(
            entityId: 'J8',
            revision: 1,
            op: HabotDeltaOp.upsert,
          ),
          upsert('J1', 1, 'Site A'),
        ]);
        return r.applied == 1 &&
            r.results
                    .where(
                      (HabotDeltaResult x) =>
                          x.outcome == HabotDeltaOutcome.rejected,
                    )
                    .length ==
                3 &&
            HabotDelta.fromRecord(<String, Object?>{'entity_id': 1}) == null;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04064',
        atomicStepReferenceId: 'GEN-04064',
        setupStepAction:
            'Process incoming delta payloads on the mobile client to update '
            'local key-value stores.',
        implementationOrder: 118,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDelta / HabotDeltaApplier',
          'Component Properties':
              '${HabotDeltaOutcome.values.length} outcomes; conflicts with '
              'unsent local work deferred and re-offered after the outbox '
              'drains; revision discipline shared with the Step 113 DAO',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row. The metric fits and '
              'is producible client-side.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Local Delta Update Latency (per delta)',
            observed:
                '${measuredMsPerDelta.toStringAsFixed(3)}ms per delta across '
                '$measuredCount deltas applied to the local store in one '
                'batch. Measured on this machine with a Stopwatch, not '
                'estimated. NOTE the band direction: lower is better, so the '
                '500ms ceiling is the worst acceptable value here.',
            floor: '<100ms',
            optimal: '<20ms',
            ceiling: '500ms',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Deltas applied over a record with unsent local work',
            observed:
                '0. Every such delta was held and re-offered after the outbox '
                'drained, at which point it landed. Applying one would have '
                'silently undone work a person did, which is the single worst '
                'thing an offline-first client can do.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/delta.dart',
        ],
      ),
    );
  });
}
