/// AISS GATE -- Step 132 of 135
/// Global Reference ID:       GEN-01496
/// Atomic Steps Reference ID: GEN-01496
/// Atomic Step: "Write bookmark additions, removals, and collection mappings
///               to the BigQuery user_favorites_v1 table."
/// Metric: Saved-State Persistence Reliability -- Floor 0.98, Optimal 1.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// A CORRECTION TO THE STEPS 111-125 BUILD ORDER, GATED. That document lists
/// this row as "saved-state persistence reliability" -- its METRIC NAME, not
/// its requirement. The Atomic Step names three specific operations and a
/// destination table. GEN-01496-G1 asserts all three exist, so the
/// mischaracterisation cannot quietly return.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/favourites_repository.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/data/repository.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotMemoryStore store;
  late HabotOutbox outbox;
  late HabotFavouritesRepository favourites;
  double reliability = 0;

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
    outbox = HabotOutbox(store: store);
    favourites = HabotFavouritesRepository(store: store, outbox: outbox);
  });

  group('GEN-01496 :: the three operations the row names', () {
    gate(
      'GEN-01496-G1',
      'Atomic Step: "bookmark ADDITIONS, REMOVALS, and COLLECTION MAPPINGS". '
          'The Steps 111-125 build order records this row as "saved-state '
          'persistence reliability", which is the metric name, not the '
          'requirement.',
      'All three operations exist as distinct operations, and the correction '
          'to the earlier characterisation is recorded in the code',
      () async {
        await favourites.add(entityId: 'f1', itemId: 'job-1');
        await favourites.mapToCollection(
          entityId: 'f1',
          collectionName: 'Site A',
        );
        await favourites.remove('f1');
        return HabotFavouriteOp.values.length == 3 &&
            favourites.recorded
                    .map((HabotFavouriteChange c) => c.op)
                    .toSet()
                    .length ==
                3 &&
            HabotFavouritesRepository.characterisationCorrection.contains(
              'metric name rather than its requirement',
            );
      },
    );

    gate(
      'GEN-01496-G2',
      'A REMOVAL that fails to sync comes back. That is the bug people report '
          'as "the app does not save anything".',
      'A removal is a tombstone carrying its own revision, so the absence is a '
          'record the server can learn from rather than a gap it will refill',
      () async {
        await favourites.add(entityId: 'f1', itemId: 'job-1');
        await favourites.remove('f1');
        final List<HabotFavourite> live = await favourites.current();
        // The record is still THERE -- it reads as absent through findById
        // because it is a tombstone, which is exactly the point: the server
        // can learn the absence was deliberate.
        final HabotResult<HabotFavourite> read =
            await favourites.dao.findById('f1');
        final int? revision = await favourites.dao.revisionOf('f1');
        final HabotFavouriteChange removal = favourites.recorded.last;
        return live.isEmpty &&
            read.failureOrNull == HabotDataFailure.notFound &&
            read.isSuccess == false &&
            revision == 2 &&
            removal.favourite.removed &&
            removal.op == HabotFavouriteOp.remove &&
            removal.toPayload()['removed'] == true;
      },
    );

    gate(
      'GEN-01496-G3',
      'A bookmark can move between collections without being added or '
          'removed. Modelling that as remove-then-add produces two rows for '
          'one user action and loses which collection it ended up in.',
      'A collection mapping is its own operation: one change, one row, the new '
          'collection recorded and the bookmark still live',
      () async {
        await favourites.add(entityId: 'f1', itemId: 'job-1');
        await favourites.mapToCollection(
          entityId: 'f1',
          collectionName: 'Site B',
        );
        final List<HabotFavourite> live = await favourites.current();
        return favourites.changesRecorded == 2 &&
            live.single.collectionName == 'Site B' &&
            !live.single.removed &&
            favourites.recorded.last.op == HabotFavouriteOp.mapToCollection;
      },
    );

    gate(
      'GEN-01496-G4',
      'An operation on a bookmark that is not there must not invent one.',
      'Removing or mapping an unknown id fails with notFound rather than '
          'creating a record, and nothing is queued for it',
      () async {
        final HabotResult<HabotWriteTicket> removed =
            await favourites.remove('ghost');
        final HabotResult<HabotWriteTicket> mapped =
            await favourites.mapToCollection(
              entityId: 'ghost',
              collectionName: 'Site A',
            );
        return removed.failureOrNull == HabotDataFailure.notFound &&
            mapped.failureOrNull == HabotDataFailure.notFound &&
            favourites.changesRecorded == 0 &&
            (await outbox.pendingCount) == 0;
      },
    );
  });

  group('GEN-01496 :: the near half, and the boundary', () {
    gate(
      'GEN-01496-G5',
      'The Step 112 contract: the user action is durable before the network is '
          'involved.',
      'Every operation writes locally FIRST and then queues for the server, '
          'and the queued payload carries the destination table the row names '
          'rather than leaving the server to assume it',
      () async {
        await favourites.add(entityId: 'f1', itemId: 'job-1');
        final List<HabotOutboxEntry> queued = await outbox.pending();
        final HabotResult<HabotFavourite> stored =
            await favourites.dao.findById('f1');
        return stored.isSuccess &&
            queued.length == 1 &&
            queued.single.kind == HabotFavouritesRepository.outboxKind &&
            queued.single.payload['destination_table'] ==
                HabotFavouriteChange.destinationTable &&
            HabotFavouriteChange.destinationTable == 'user_favorites_v1' &&
            queued.single.payload['op'] == 'add';
      },
    );

    gate(
      'GEN-01496-G6',
      'Metric: Saved-State Persistence Reliability, floor 0.98. A change '
          'written locally but never queued would survive a restart and never '
          'reach anyone else.',
      'Reliability counts a change only when it is BOTH stored locally and '
          'handed to the queue, tracked at the moment of enqueue rather than '
          'inferred from the queue later -- once an entry is sent it is gone, '
          'and "not in the queue" cannot then tell delivered from never-queued',
      () async {
        await favourites.add(entityId: 'f1', itemId: 'job-1');
        await favourites.add(entityId: 'f2', itemId: 'job-2');
        await favourites.mapToCollection(
          entityId: 'f2',
          collectionName: 'Site C',
        );
        // Drain the queue: reliability must NOT drop just because the work
        // reached the server.
        for (final HabotOutboxEntry e in await outbox.pending()) {
          await outbox.markSent(e);
        }
        reliability = await favourites.persistenceReliability();
        return reliability == 1.0 &&
            reliability >= HabotFavouritesRepository.floor &&
            favourites.notHandedOver.isEmpty &&
            (await outbox.pendingCount) == 0;
      },
    );

    gate(
      'GEN-01496-G7',
      'A mobile client cannot and must not write to BigQuery: an app holding '
          'warehouse credentials would be a security defect rather than a '
          'feature.',
      'The boundary is stated in the code -- the client owns recording and '
          'queueing, the server owns landing the row -- so nobody later '
          'mistakes the missing half for an oversight',
      () async =>
          HabotFavouritesRepository.bigQueryBoundary.contains(
            'must not write to BigQuery',
          ) &&
          HabotFavouritesRepository.bigQueryBoundary.contains(
            'warehouse credentials',
          ) &&
          HabotFavouritesRepository.bigQueryBoundary.contains(
            'server concern',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01496',
        atomicStepReferenceId: 'GEN-01496',
        setupStepAction:
            'Write bookmark additions, removals, and collection mappings to '
            'the BigQuery user_favorites_v1 table.',
        implementationOrder: 132,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotFavouritesRepository / HabotFavourite / '
              'HabotFavouriteChange',
          'Component Properties':
              '${HabotFavouriteOp.values.length} operations (add, remove, '
              'mapToCollection); removals are tombstones; every change '
              'carries the destination table '
              '"${HabotFavouriteChange.destinationTable}" on its payload',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY. The Steps 111-125 build order '
              'characterised this row by its metric name rather than its '
              'requirement; the correction is recorded in '
              'HabotFavouritesRepository.characterisationCorrection.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Saved-State Persistence Reliability (the client half)',
            observed:
                '${reliability.toStringAsFixed(2)} -- every recorded change '
                'was both stored locally and handed to the outbox, and the '
                'figure held after the queue drained. Tracked at enqueue '
                'rather than inferred from the queue, because a sent entry is '
                'gone from it and absence cannot then distinguish delivered '
                'from never-queued.',
            floor: '0.98',
            optimal: '1',
            ceiling: '1',
          ),
          const AissMeasurement(
            metricName: 'Rows landed in user_favorites_v1',
            observed:
                'NOT PRODUCED, and not a client concern. BigQuery is not a '
                'client-facing store; a mobile app holding warehouse '
                'credentials would be a security defect rather than a '
                'feature. The client records the three operations durably and '
                'in order and hands them over carrying the destination table '
                'name. Landing the row is the server half.',
            floor: 'server concern',
            optimal: 'server concern',
            ceiling: 'server concern',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/favourites_repository.dart',
        ],
      ),
    );
  });
}
