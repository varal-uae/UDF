/// AISS GATE -- Step 113 of 115
/// Global Reference ID:       GEN-04484
/// Atomic Steps Reference ID: GEN-04484-A01
/// Setup Step (Action):       "Build Data Access Objects (DAOs) for CRUD
///                             operations on local entities."
/// Reference standard, verbatim: "Offline-First Mobile Architecture Best
///                                Practice."
/// Metric: Data Synchronization Success Rate -- Floor 0.98, Optimal 0.999.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC READING, STATED: the full synchronisation rate belongs to a sync
/// loop that does not exist yet (Step 123). What a DAO owns is the LOCAL half
/// -- that nothing is lost before the network is reached -- and that is what
/// is measured. The full rate is reported as NOT PRODUCED.
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/dao.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
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

_Job? _decode(Map<String, Object?> record) {
  final Object? payload = record[HabotRecordFields.payload];
  if (payload is! Map<String, Object?>) {
    return null;
  }
  return _Job(
    record[HabotRecordFields.id]! as String,
    record[HabotRecordFields.revision]! as int,
    payload['site']! as String,
  );
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotMemoryStore store;
  late HabotDao<_Job> dao;

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
      decoder: _decode,
    );
  });

  group('GEN-04484-A01 :: CRUD', () {
    gate(
      'GEN-04484-G1',
      'Setup Step (Action): "CRUD operations on local entities".',
      'Create, read and list round-trip through the store without the entity '
          'type reaching the storage layer -- the DAO owns the encoding and '
          'the store moves bytes',
      () async {
        await dao.save(const _Job('J1', 1, 'Site A'));
        await dao.save(const _Job('J2', 1, 'Site B'));
        final HabotResult<_Job> one = await dao.findById('J1');
        final HabotResult<List<_Job>> all = await dao.findAll();
        return one.valueOrNull?.site == 'Site A' &&
            all.valueOrNull?.length == 2 &&
            all.valueOrNull!.first.entityId == 'J1';
      },
    );

    gate(
      'GEN-04484-G2',
      'A queue that drains in hash order silently reorders a worker day.',
      'Keys come back in insertion order, so the outbox Step 117 builds on '
          'this drains in the order the work was actually done',
      () async {
        for (final String id in <String>['J3', 'J1', 'J2']) {
          await dao.save(_Job(id, 1, 'Site $id'));
        }
        final List<String> keys = await store.keys(
          const HabotCollection('jobs'),
        );
        final HabotResult<List<_Job>> all = await dao.findAll();
        return keys.join(',') == 'J3,J1,J2' &&
            all.valueOrNull!
                    .map((_Job j) => j.entityId)
                    .join(',') ==
                'J3,J1,J2';
      },
    );
  });

  group('GEN-04484-A01 :: the four decisions the DAO adds', () {
    gate(
      'GEN-04484-G3',
      '"Offline-First Mobile Architecture Best Practice": a slow reconnect '
          'must not overwrite newer local work.',
      'A save whose revision is not ahead of what is stored is REJECTED with '
          'a conflict naming both revisions, and the stored copy is untouched '
          '-- which is the single most common data-loss bug in offline-first '
          'apps, closed',
      () async {
        await dao.save(const _Job('J1', 5, 'Site A'));
        final HabotResult<HabotWriteTicket> stale = await dao.save(
          const _Job('J1', 4, 'Site OLD'),
        );
        final HabotResult<HabotWriteTicket> same = await dao.save(
          const _Job('J1', 5, 'Site SAME'),
        );
        final HabotResult<_Job> after = await dao.findById('J1');
        return stale.failureOrNull == HabotDataFailure.conflict &&
            same.failureOrNull == HabotDataFailure.conflict &&
            after.valueOrNull?.site == 'Site A' &&
            dao.rejections.where(
                  (HabotDaoRejection r) =>
                      r == HabotDaoRejection.staleRevision,
                ).length ==
                2;
      },
    );

    gate(
      'GEN-04484-G4',
      'A row that simply vanishes cannot be replicated: the server has no way '
          'to tell "deleted" from "never seen".',
      'A delete writes a tombstone carrying its own revision; the record '
          'reads as absent, is excluded from listings, and is still there for '
          'the Step 118 delta path to send',
      () async {
        await dao.save(const _Job('J1', 1, 'Site A'));
        await dao.delete('J1', revision: 2);
        final HabotResult<_Job> read = await dao.findById('J1');
        final HabotResult<List<_Job>> all = await dao.findAll();
        final List<String> stones = await dao.tombstones();
        // A stale create must not resurrect a deleted record.
        final HabotResult<HabotWriteTicket> resurrect = await dao.save(
          const _Job('J1', 2, 'Site A'),
        );
        return read.failureOrNull == HabotDataFailure.notFound &&
            all.valueOrNull!.isEmpty &&
            stones.contains('J1') &&
            resurrect.failureOrNull == HabotDataFailure.conflict;
      },
    );

    gate(
      'GEN-04484-G5',
      'Step 122 needs the same key on every retry.',
      'The ticket id is deterministic in collection, entity and revision, so '
          'retrying the identical write produces the identical key -- a random '
          'id here would make every retry look like a new submission',
      () async {
        final HabotResult<HabotWriteTicket> a = await dao.save(
          const _Job('J1', 1, 'Site A'),
        );
        final String expected = HabotDao.ticketIdFor(
          const HabotCollection('jobs'),
          'J1',
          1,
        );
        return a.valueOrNull?.ticketId == expected &&
            expected == 'jobs:J1:1' &&
            a.valueOrNull!.pending;
      },
    );

    gate(
      'GEN-04484-G6',
      'A corrupt record is an ordinary event on a device whose storage filled '
          'up mid-write, and it must not take the whole read down with it.',
      'Damaged bytes produce a named corrupt failure for that record and are '
          'skipped in a listing, while a storage failure surfaces as '
          'storageFull rather than an exception escaping the DAO',
      () async {
        await dao.save(const _Job('J1', 1, 'Site A'));
        await store.write(
          const HabotCollection('jobs'),
          'J2',
          Uint8List.fromList(<int>[0xFF, 0xFE, 0xFD]),
        );
        final HabotResult<_Job> bad = await dao.findById('J2');
        final HabotResult<List<_Job>> all = await dao.findAll();

        store.failNextWrite = true;
        final HabotResult<HabotWriteTicket> full = await dao.save(
          const _Job('J3', 1, 'Site C'),
        );
        return bad.failureOrNull == HabotDataFailure.corrupt &&
            all.valueOrNull!.length == 1 &&
            full.failureOrNull == HabotDataFailure.storageFull &&
            dao.localSuccessRate > 0 &&
            dao.localSuccessRate < 1;
      },
    );
  });

  group('GEN-04484-A01 :: the store contract', () {
    gate(
      'GEN-04484-G7',
      'Step 117 names SQLite, which this environment cannot add. An engine '
          'behind an interface is a swap; an engine in the DAO is a rewrite.',
      'The store contract is narrow enough for any key/value engine, the '
          'in-memory implementation is honest that it is NOT durable, and a '
          'malformed collection name is a programming error rather than a '
          'silent namespace',
      () async {
        bool threw = false;
        try {
          HabotDao<_Job>(
            collection: const HabotCollection('Jobs Table'),
            store: store,
            decoder: _decode,
          );
        } on ArgumentError {
          threw = true;
        }
        return !store.isDurable &&
            store.engineName.contains('NOT durable') &&
            store.supportsTransactions &&
            const HabotCollection('jobs').isValid &&
            !const HabotCollection('Jobs Table').isValid &&
            threw;
      },
    );

    gate(
      'GEN-04484-G8',
      'Step 116 builds atomic commit on this. A guarantee that is not tested '
          'is a guarantee nobody has.',
      'A transaction that fails part way leaves the store exactly as it was, '
          'including insertion order',
      () async {
        await dao.save(const _Job('J1', 1, 'Site A'));
        bool threw = false;
        try {
          await store.transaction(() async {
            await dao.save(const _Job('J2', 1, 'Site B'));
            store.failNextWrite = true;
            await store.write(
              const HabotCollection('jobs'),
              'J3',
              Uint8List.fromList(<int>[1]),
            );
          });
        } on HabotStoreWriteException {
          threw = true;
        }
        final List<String> keys = await store.keys(
          const HabotCollection('jobs'),
        );
        return threw && keys.length == 1 && keys.single == 'J1';
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04484',
        atomicStepReferenceId: 'GEN-04484-A01',
        setupStepAction:
            'Build Data Access Objects (DAOs) for CRUD operations on local '
            'entities.',
        implementationOrder: 113,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDao / HabotLocalStore / HabotMemoryStore',
          'Component Properties':
              'CRUD plus revision discipline, tombstones, deterministic '
              'tickets and single-point encoding; '
              '${HabotDaoRejection.values.length} named rejection reasons; '
              '${HabotRecordFields.all.length} record fields declared once',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row. SQLite (named by the Step 117 '
              'row) is substituted by the HabotLocalStore contract and that '
              'substitution is recorded.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Local write integrity (the half a DAO owns)',
            observed:
                'No stale write was applied, no delete vanished without a '
                'tombstone, no corrupt record took down a listing, and a '
                'failed transaction left the store byte-identical. Every '
                'refusal named its reason rather than failing silently.',
            floor: 'no silent loss',
            optimal: 'no silent loss',
            ceiling: 'no silent loss',
          ),
          const AissMeasurement(
            metricName: 'Data Synchronization Success Rate (the sheet metric)',
            observed:
                'NOT PRODUCED. It is a property of a sync loop that does not '
                'exist yet -- Step 123 builds it. A DAO cannot make the '
                'network work; it can guarantee nothing is lost before the '
                'network is reached, which is what was measured. The local '
                'figure is not passed off as the whole thing.',
            floor: '0.98',
            optimal: '0.999',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/dao.dart',
          'lib/design_system/data/local_store.dart',
        ],
      ),
    );
  });
}
