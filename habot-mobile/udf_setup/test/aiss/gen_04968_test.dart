/// AISS GATE -- Step 145 of 155
/// Global Reference ID:       GEN-04968
/// Atomic Steps Reference ID: GEN-04968
/// Setup Step (Action) / Atomic Step: "Wire data logging per the BigQuery/GCP
///   alignment requirement: Language usage telemetry streamed to BigQuery to
///   identify underserved demographic groups (data captured: log language
///   preference selections to BigQuery demographic tables)."
/// Metric: Event Logging Completeness & Streaming Latency -- Floor "<=5 min
///         latency, >=99% capture", Optimal "<=1 min, 100%", Ceiling "<=15 min
///         before stale". Complete / Partial / Not Complete.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/i18n/language_telemetry.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotMemoryStore store;
  late HabotOutbox outbox;
  late HabotLanguageTelemetry telemetry;
  double completeness = 0;

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
    telemetry = HabotLanguageTelemetry(outbox: outbox);
  });

  HabotLanguageEvent event({
    String selected = 'ur',
    String? previous = 'en',
    String device = 'en-GB',
    HabotLanguageSelectionSource source =
        HabotLanguageSelectionSource.userChoice,
    int minute = 0,
  }) =>
      HabotLanguageEvent(
        installId: 'install-1',
        selectedLocale: selected,
        previousLocale: previous,
        source: source,
        deviceLocale: device,
        occurredAt: DateTime.utc(2026, 9, 8, 9, minute),
      );

  group('GEN-04968 :: capture completeness', () {
    gate(
      'GEN-04968-G1',
      'The moment a language preference is set is disproportionately likely to '
          'be a moment with no network: it is one of the first things a new '
          'user does, often on a depot handset. A fire-and-forget post loses '
          'exactly the events this row exists to collect.',
      'The selection goes into the Step 117 outbox rather than out over the '
          'network, so it inherits whatever durability the installed store '
          'has instead of depending on a connection at that instant',
      () async {
        await telemetry.record(event());
        final List<HabotOutboxEntry> pending = await outbox.pending();
        // The gate runs against the in-memory store, which reports itself as
        // not durable -- correctly. What is checked here is that the event
        // goes through the OUTBOX rather than out over the network, so that
        // it inherits durability from whatever store the app installs.
        return pending.length == 1 &&
            pending.single.kind == HabotLanguageTelemetry.outboxKind &&
            pending.single.payload['selected_locale'] == 'ur' &&
            !store.isDurable &&
            store.engineName.contains('NOT durable') &&
            HabotLanguageTelemetry.offlineCaptureNote.contains(
              'whose events go missing',
            );
      },
    );

    gate(
      'GEN-04968-G2',
      'Metric floor: ">=99% event capture completeness"; optimal 100%.',
      'Completeness counts an event only when it has been handed to the '
          'queue, tracked at enqueue rather than inferred from the queue -- '
          'once an entry is sent it is gone, and absence cannot then tell '
          'delivered from never-queued',
      () async {
        await telemetry.record(event(minute: 0));
        await telemetry.record(event(selected: 'pl', minute: 1));
        await telemetry.record(event(selected: 'cy', minute: 2));
        for (final HabotOutboxEntry e in await outbox.pending()) {
          await outbox.markSent(e);
        }
        completeness = telemetry.captureCompleteness;
        return telemetry.eventsRecorded == 3 &&
            completeness == 1.0 &&
            completeness >= HabotLanguageTelemetry.captureFloor &&
            telemetry.notHandedOver.isEmpty &&
            (await outbox.pendingCount) == 0;
      },
    );

    gate(
      'GEN-04968-G3',
      'A double-tap on the same option must not become two events, or the '
          'counts this row exists to produce are wrong in the direction that '
          'looks like enthusiasm.',
      'The event id is derived from the install, the selection and the '
          'instant, so the Step 117 dedupe collapses a repeat -- while a '
          'genuinely later selection of the same language is its own event',
      () async {
        final HabotLanguageEvent e = event();
        await telemetry.record(e);
        await telemetry.record(e);
        final int afterRepeat = await outbox.pendingCount;
        await telemetry.record(event(minute: 5));
        return afterRepeat == 1 &&
            (await outbox.pendingCount) == 2 &&
            HabotLanguageTelemetry.idOf(e) ==
                HabotLanguageTelemetry.idOf(event()) &&
            HabotLanguageTelemetry.idOf(e) !=
                HabotLanguageTelemetry.idOf(event(minute: 5));
      },
    );
  });

  group('GEN-04968 :: what the event carries, and what it must not', () {
    gate(
      'GEN-04968-G4',
      'A language preference is a strong proxy for ethnicity and immigration '
          'status, and the row itself calls the destination a demographic '
          'table. The purpose it states -- finding underserved groups -- needs '
          'counts, not people.',
      'The payload carries an install-scoped id and nothing else identifying, '
          'the excluded fields are declared so adding one is a visible change '
          'to a list, and no excluded field is present',
      () async {
        final HabotLanguageEvent e = event();
        final Map<String, Object?> payload = e.toPayload();
        return HabotLanguageTelemetry.privacyViolations(e).isEmpty &&
            HabotLanguageEvent.excludedFields.length >= 6 &&
            payload.containsKey('install_id') &&
            !payload.containsKey('account_id') &&
            !payload.containsKey('device_id') &&
            HabotLanguageTelemetry.privacyNote.contains(
              'cannot later be repurposed',
            );
      },
    );

    gate(
      'GEN-04968-G5',
      'A switch away from a language looks identical to a switch toward it '
          'without the previous value -- and "underserved" is exactly that '
          'distinction. The gap between the OS locale and the chosen one is '
          'the actual signal.',
      'The event carries the previous locale, the device locale and how the '
          'selection was made, alongside the destination table the row names',
      () async {
        final Map<String, Object?> p = event().toPayload();
        return p['selected_locale'] == 'ur' &&
            p['previous_locale'] == 'en' &&
            p['device_locale'] == 'en-GB' &&
            p['source'] == HabotLanguageSelectionSource.userChoice.name &&
            p['destination_table'] ==
                HabotLanguageTelemetry.destinationTable &&
            HabotLanguageTelemetry.destinationTable.startsWith('demographics.')
            &&
            HabotLanguageSelectionSource.values.length == 3;
      },
    );

    gate(
      'GEN-04968-G6',
      'Metric: "<=5 min end-to-end event delivery latency", optimal "<=1 min", '
          'ceiling "<=15 min before stale". End-to-end spans a transport, an '
          'ingestion service and a streaming insert -- none of which this '
          'client can observe.',
      'The client reports the hop it owns and bands an end-to-end figure it is '
          'given, rather than fabricating a measurement it cannot make',
      () async {
        await telemetry.record(event());
        return telemetry.handoverLatency < HabotMotion.telemetryDeliveryOptimal &&
            HabotLanguageTelemetry.bandFor(const Duration(seconds: 30)) ==
                'optimal (<= 1 min)' &&
            HabotLanguageTelemetry.bandFor(const Duration(minutes: 3)) ==
                'within floor (<= 5 min)' &&
            HabotLanguageTelemetry.bandFor(const Duration(minutes: 10)) ==
                'late but usable (<= 15 min)' &&
            HabotLanguageTelemetry.bandFor(const Duration(minutes: 20)) ==
                'STALE (> 15 min)' &&
            HabotLanguageTelemetry.isStale(const Duration(minutes: 20)) &&
            !HabotLanguageTelemetry.isStale(HabotMotion.telemetryStale) &&
            HabotLanguageTelemetry.latencyBoundaryNote.contains(
              'fabricated measurement',
            );
      },
    );

    gate(
      'GEN-04968-G7',
      'A mobile client must not write to BigQuery: an app holding warehouse '
          'credentials would be a security defect rather than a feature.',
      'The boundary is stated in the code and matches the one Step 132 set, so '
          'nobody mistakes the missing half for an oversight',
      () async =>
          HabotLanguageTelemetry.bigQueryBoundary.contains(
            'must not write to BigQuery',
          ) &&
          HabotLanguageTelemetry.bigQueryBoundary.contains(
            'warehouse credentials',
          ) &&
          HabotLanguageTelemetry.bigQueryBoundary.contains('Same boundary as '
              'Step 132'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04968',
        atomicStepReferenceId: 'GEN-04968',
        setupStepAction:
            'Wire data logging per the BigQuery/GCP alignment requirement: '
            'Language usage telemetry streamed to BigQuery to identify '
            'underserved demographic groups.',
        implementationOrder: 145,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotLanguageTelemetry / HabotLanguageEvent',
          'Component Properties':
              'destination ${HabotLanguageTelemetry.destinationTable}; '
              '${HabotLanguageSelectionSource.values.length} selection '
              'sources; ${HabotLanguageEvent.excludedFields.length} fields '
              'explicitly excluded from the payload; queued through the Step '
              '117 durable outbox',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. End-to-end latency spans hops this client '
              'cannot observe; only the hop it owns is reported.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Event Logging Completeness',
            observed:
                '${(completeness * 100).toStringAsFixed(0)}% -- every recorded '
                'selection reached the durable queue, and the figure held '
                'after the queue drained because it is tracked at enqueue '
                'rather than inferred from the queue.',
            floor: '>=99% event capture completeness',
            optimal: '100% event capture completeness',
            ceiling: '100%',
          ),
          const AissMeasurement(
            metricName: 'Streaming latency (end to end)',
            observed:
                'NOT MEASURED HERE, and not measurable here. The figure spans '
                'client capture, transport, an ingestion service and a '
                'BigQuery streaming insert. The client reports the first hop '
                '-- selection to durable queue, sub-millisecond -- and bands '
                'an end-to-end figure it is given. Reporting a number this '
                'code cannot observe would be a fabricated measurement.',
            floor: '<=5 min (server-owned)',
            optimal: '<=1 min (server-owned)',
            ceiling: '<=15 min before stale',
          ),
          const AissMeasurement(
            metricName: 'Identifying fields in the payload',
            observed:
                '0. A language preference is a strong proxy for ethnicity and '
                'immigration status, and the row calls the destination a '
                'demographic table. Finding underserved groups needs counts, '
                'not people, so the event carries an install-scoped id and '
                'nothing else -- and an event that cannot be joined to a '
                'person cannot later be repurposed into one that is.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/i18n/language_telemetry.dart',
        ],
      ),
    );
  });
}
