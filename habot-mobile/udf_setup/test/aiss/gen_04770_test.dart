/// AISS GATE -- Step 161 of 175
/// Global Reference ID:       GEN-04770
/// Atomic Steps Reference ID: GEN-04770
/// Setup Step (Action) / Atomic Step: "Wire data logging per the BigQuery/GCP
///   alignment requirement: Step completion events streamed to BigQuery funnel
///   analytics (data captured: Step transition timestamp, time-per-step, and
///   step drop-off rates logged)."
/// Metric: Event Logging Completeness & Streaming Latency -- Floor "<=5 min
///         latency, >=99% completeness", Optimal "<=1 min, 100%",
///         Ceiling "<=15 min before stale". Complete / Partial / Not Complete.
///
/// SAME BOUNDARY AS STEPS 132 AND 145, DIFFERENT VOLUME PROBLEM. A language
/// selection happens once in an install's life; a funnel emits an event per
/// step per flow. Events batch, and the batch goes through the durable outbox
/// rather than sitting in memory until it is full.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/telemetry/event_schema.dart';
import 'package:udf_setup/design_system/telemetry/funnel_stream.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotMemoryStore store;
  late HabotOutbox outbox;
  late HabotFunnelStream stream;
  double completeness = 0;
  double partialCompleteness = 1;

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
    stream = HabotFunnelStream(outbox: outbox);
  });

  HabotEvent stepEvent(int ordinal) => HabotEvent(
        kind: HabotEventKind.stepCompleted,
        view: 'referral_form',
        traceId: 'trace-$ordinal',
        occurredAt: DateTime.utc(2026, 8, 24, 10).add(
          Duration(seconds: ordinal),
        ),
        sessionOrdinal: ordinal,
        payload: <String, Object?>{
          'flow_id': 'f1',
          'step_index': ordinal % 5,
          'step_count': 5,
          'time_on_step_ms': 2000 + ordinal,
        },
      );

  group('GEN-04770 :: batching, and why', () {
    gate(
      'GEN-04770-G1',
      '"One outbox entry per event would mean hundreds of HTTP requests on a '
          'metered connection for data nobody is waiting on."',
      'Events accumulate and flush as ONE outbox entry at the declared batch '
          'size, so twenty-five funnel events cost the network one queued '
          'request rather than twenty-five',
      () async {
        HabotOutboxEntry? flushed;
        for (int i = 0; i < HabotFunnelStream.batchSize; i++) {
          flushed = await stream.addAndMaybeFlush(stepEvent(i)) ?? flushed;
        }
        final List<HabotOutboxEntry> queued = await outbox.pending();
        return HabotFunnelStream.batchSize == 25 &&
            flushed != null &&
            queued.length == 1 &&
            stream.batchesFlushed == 1 &&
            stream.pendingCount == 0 &&
            (flushed.payload['event_count'] as int) == 25 &&
            (flushed.payload['events']! as List<Object?>).length == 25 &&
            flushed.kind == HabotFunnelStream.outboxKind &&
            HabotFunnelStream.batchingNote.contains('Step 124 governor');
      },
    );

    gate(
      'GEN-04770-G2',
      'GCP alignment: "...streamed to BigQuery ... partitioned by event_date, '
          'clustered by trace_id."',
      'The batch carries the destination table, the partition field, the '
          'cluster field and the schema version the warehouse needs, and every '
          'row inside it carries event_date and trace_id -- the client hands '
          'over, the server lands the rows',
      () async {
        for (int i = 0; i < 3; i++) {
          stream.add(stepEvent(i));
        }
        final HabotOutboxEntry entry =
            (await stream.flush(reason: HabotFlushReason.lifecycle))!;
        final List<Object?> rows = entry.payload['events']! as List<Object?>;
        final Map<String, Object?> first =
            rows.first! as Map<String, Object?>;
        return entry.payload['destination_table'] ==
                HabotFunnelStream.destinationTable &&
            entry.payload['partition_field'] ==
                HabotEventSchema.partitionField &&
            entry.payload['cluster_field'] == HabotEventSchema.clusterField &&
            entry.payload['schema_version'] == HabotEventSchema.version &&
            entry.payload['flush_reason'] == 'lifecycle' &&
            first['event_date'] == '2026-08-24' &&
            first['trace_id'] == 'trace-0' &&
            HabotFunnelStream.bigQueryBoundary
                .contains('warehouse credentials');
      },
    );

    gate(
      'GEN-04770-G3',
      '"A batch lost is more events lost than a single entry, which is why the '
          'batch goes through the durable outbox rather than being held in '
          'memory until it is full."',
      'The batch is handed to the Step 117 outbox rather than kept in the '
          'stream, and the queue reports its own durability honestly -- on the '
          'in-memory store it says it is not durable rather than implying a '
          'guarantee it cannot give',
      () async {
        stream.add(stepEvent(0));
        await stream.flush();
        final List<HabotOutboxEntry> queued = await outbox.pending();
        return queued.length == 1 &&
            stream.pendingCount == 0 &&
            !outbox.isDurable &&
            outbox.engineName.contains('NOT durable') &&
            HabotFunnelStream.batchingNote.contains('durable outbox');
      },
    );

    gate(
      'GEN-04770-G4',
      'Step 117/122: "a retry of the same batch must dedupe at the queue '
          'rather than landing twice."',
      'The batch id is derived from the batch rather than generated, so '
          'flushing the same events again returns the entry already queued '
          'instead of enqueuing a second copy',
      () async {
        for (int i = 0; i < 3; i++) {
          stream.add(stepEvent(i));
        }
        final HabotOutboxEntry first = (await stream.flush())!;

        final HabotFunnelStream retry = HabotFunnelStream(outbox: outbox);
        for (int i = 0; i < 3; i++) {
          retry.add(stepEvent(i));
        }
        final HabotOutboxEntry second = (await retry.flush())!;
        final List<HabotOutboxEntry> queued = await outbox.pending();

        return first.id == second.id &&
            first.sequence == second.sequence &&
            queued.length == 1 &&
            first.id.endsWith('+3') &&
            await stream.flush() == null;
      },
    );
  });

  group('GEN-04770 :: what is refused, and what is measured', () {
    gate(
      'GEN-04770-G5',
      '"Refused -- not silently dropped -- if it fails the schema or if the '
          'sanitiser finds anything in it."',
      'An event with an undeclared field and an event carrying a bare hash the '
          'Step 157 sanitiser flags are both refused, each recorded with which '
          'of the two checks rejected it, and neither reaches the queue',
      () async {
        final HabotEvent undeclared = HabotEvent(
          kind: HabotEventKind.stepCompleted,
          view: 'referral_form',
          traceId: 'trace-x',
          occurredAt: DateTime.utc(2026, 8, 24, 10),
          sessionOrdinal: 90,
          payload: const <String, Object?>{
            'flow_id': 'f1',
            'step_index': 0,
            'step_count': 5,
            'time_on_step_ms': 2000,
            'operator_note': 'extra',
          },
        );
        // Schema-valid: an opaqueId field holding a String with no free-text
        // punctuation. The SANITISER is what objects, because a bare run of
        // sixteen hex characters is indistinguishable from a leaked token --
        // which is exactly why Step 157 prefixes the ids it mints.
        final HabotEvent bareHash = HabotEvent(
          kind: HabotEventKind.searchEmpty,
          view: 'catalogue',
          traceId: 'trace-y',
          occurredAt: DateTime.utc(2026, 8, 24, 10),
          sessionOrdinal: 91,
          payload: const <String, Object?>{
            'query_hash': 'a1b2c3d4e5f60718',
            'term_count': 2,
            'had_filters': false,
          },
        );

        final bool tookUndeclared = stream.add(undeclared);
        final bool tookBareHash = stream.add(bareHash);
        final bool tookGood = stream.add(stepEvent(0));

        return !tookUndeclared &&
            !tookBareHash &&
            tookGood &&
            HabotEventSchema.matches(bareHash) &&
            stream.refused.length == 2 &&
            stream.refused.any((String r) => r.endsWith(': schema')) &&
            stream.refused.any((String r) => r.endsWith(': sanitiser')) &&
            stream.eventsAccepted == 1 &&
            stream.pendingCount == 1;
      },
    );

    gate(
      'GEN-04770-G6',
      'Metric: Event Logging Completeness -- floor >=99%, optimal 100%. '
          '"Tracked at handover rather than inferred from the queue: a sent '
          'entry is gone from the queue, and absence cannot then distinguish '
          'delivered from never-queued."',
      'Completeness is 1.0 once the batch has been handed over, and is below '
          'the floor while events are still sitting in the stream -- so the '
          'figure measures handover rather than intent',
      () async {
        for (int i = 0; i < 3; i++) {
          stream.add(stepEvent(i));
        }
        partialCompleteness = stream.captureCompleteness;
        await stream.flush();
        completeness = stream.captureCompleteness;
        return partialCompleteness == 0.0 &&
            partialCompleteness < HabotFunnelStream.captureFloor &&
            stream.notHandedOver.isEmpty &&
            completeness == 1.0 &&
            completeness >= HabotFunnelStream.captureOptimal &&
            completeness >= HabotFunnelStream.captureFloor;
      },
    );

    gate(
      'GEN-04770-G7',
      'Metric: Streaming Latency -- floor <=5 min, optimal <=1 min, '
          'ceiling <=15 min before stale. The client owns handover only.',
      'The row\'s bands are carried and applied to an end-to-end figure the '
          'SERVER supplies, and the boundary is recorded rather than an '
          'unobservable end-to-end number being reported as measured',
      () async =>
          HabotFunnelStream.bandFor(const Duration(seconds: 30)) ==
              'Complete (<= 1 min)' &&
          HabotFunnelStream.bandFor(const Duration(minutes: 3)) ==
              'Complete (<= 5 min)' &&
          HabotFunnelStream.bandFor(const Duration(minutes: 12)) ==
              'Partial' &&
          HabotFunnelStream.bandFor(const Duration(minutes: 20)) ==
              'Not Complete' &&
          HabotFunnelStream.isStale(const Duration(minutes: 20)) &&
          !HabotFunnelStream.isStale(HabotMotion.telemetryStale) &&
          HabotFunnelStream.latencyBoundaryNote
              .contains('fabricated measurement'),
    );

    gate(
      'GEN-04770-G8',
      '"Step drop-off rates logged." A drop-off rate is a ratio across many '
          'users; one device knows only its own runs.',
      'The client sends the events a drop-off rate is computed FROM -- step '
          'index, step count, time on step -- and records that the rate itself '
          'is a query, rather than sending a ratio with a denominator of one',
      () async {
        stream.add(stepEvent(0));
        final HabotOutboxEntry entry = (await stream.flush())!;
        final Map<String, Object?> row =
            (entry.payload['events']! as List<Object?>).first!
                as Map<String, Object?>;
        return row.containsKey('step_index') &&
            row.containsKey('step_count') &&
            row.containsKey('time_on_step_ms') &&
            !row.keys.any((String k) => k.contains('rate')) &&
            !row.keys.any((String k) => k.contains('drop')) &&
            HabotFunnelStream.dropOffIsServerSide
                .contains('denominator of one');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04770',
        atomicStepReferenceId: 'GEN-04770',
        setupStepAction:
            'Wire data logging per the BigQuery/GCP alignment requirement: '
            'Step completion events streamed to BigQuery funnel analytics.',
        implementationOrder: 161,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFunnelStream',
          'Component Properties':
              '${HabotFunnelStream.batchSize} events per outbox entry, kind '
              '"${HabotFunnelStream.outboxKind}", destination '
              '${HabotFunnelStream.destinationTable}, partition field '
              '${HabotEventSchema.partitionField}, cluster field '
              '${HabotEventSchema.clusterField}; batch ids derived from the '
              'batch so a retry dedupes at the Step 117 queue',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'BOUNDARY RECORDED: the client records and hands over; '
              'transport, ingestion and the streaming insert are the server\'s '
              '-- a mobile app holding warehouse credentials would be a '
              'security defect rather than a feature. The end-to-end latency '
              'the row bounds is therefore NOT reported as measured; the bands '
              'are carried so a figure the server supplies can be banded. Same '
              'boundary as Steps 132 and 145. The queue in this run is backed '
              'by HabotMemoryStore, which reports itself as not durable.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Event Capture Completeness (handover)',
            observed:
                '${(completeness * 100).toStringAsFixed(0)}% of accepted '
                'events reached the durable queue. The same figure reads '
                '${(partialCompleteness * 100).toStringAsFixed(0)}% while a '
                'batch is still pending in the stream, so it measures handover '
                'rather than intent.',
            floor: '>=99% event capture completeness',
            optimal: '100% event capture completeness',
            ceiling: 'N/A',
          ),
          AissMeasurement(
            metricName: 'End-to-end streaming latency',
            observed:
                'NOT MEASURED HERE. The hop this client owns is event to '
                'durable queue; transport and the BigQuery streaming insert '
                'are the server\'s. The row\'s bands (<=1 min optimal, <=5 min '
                'floor, <=15 min before stale) are implemented and applied to '
                'a supplied figure. Reporting an end-to-end number this code '
                'cannot observe would be a fabricated measurement.',
            floor: '<=5 min end-to-end',
            optimal: '<=1 min',
            ceiling: '<=15 min before stale',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/funnel_stream.dart',
        ],
      ),
    );
  });
}
