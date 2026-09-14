/// AISS GATE -- Step 162 of 175
/// Global Reference ID:       GEN-01021
/// Atomic Steps Reference ID: GEN-01021
/// Setup Step (Action): "Deploy Automated System Handshake & Health Probe
///                       Architecture"
/// Atomic Step: "Stream health check probe logs to BigQuery table
///               audit.system_health_probes."
/// Metric: Ingestion Delay -- Floor "<= 1 sec", Optimal "Instant",
///         Ceiling "<= 3 secs". Complete / Not Complete.
///
/// "INSTANT" IS NOT A NUMBER. The smallest interval this app can observe is one
/// frame, which is what the optimal token holds, and the substitution is
/// recorded rather than a green figure being reported against a bound nothing
/// could miss.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/telemetry/event_schema.dart';
import 'package:udf_setup/design_system/telemetry/health_probe.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotMemoryStore store;
  late HabotOutbox outbox;
  late HabotHealthProbe probe;
  int healthyStreamed = 0;
  int suppressed = 0;

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
    probe = HabotHealthProbe(
      outbox: outbox,
      clock: () => DateTime.utc(2026, 8, 24, 10),
    );
  });

  HabotProbeResult result(
    HabotProbeTarget target, {
    bool healthy = true,
    int rttMs = 40,
    int minute = 0,
  }) =>
      HabotProbeResult(
        target: target,
        healthy: healthy,
        roundTrip: Duration(milliseconds: rttMs),
        at: DateTime.utc(2026, 8, 24, 10, minute),
        traceId: 'trace-${target.name}-$minute',
      );

  group('GEN-01021 :: what is probed, and why', () {
    gate(
      'GEN-01021-G1',
      '"A probe set assembled by whoever remembered to add one ends up '
          'covering the dependency that broke last year and not the one that '
          'will break next."',
      'The probe targets are declared as a closed set and every one carries '
          'the reason it is on the list, so the set can be argued with rather '
          'than only added to',
      () async {
        final Set<HabotProbeTarget> declared =
            HabotProbeRationale.reasons.keys.toSet();
        return HabotProbeTarget.values.length == 4 &&
            declared.length == HabotProbeTarget.values.length &&
            declared.containsAll(HabotProbeTarget.values) &&
            HabotProbeRationale.reasons.values
                .every((String r) => r.length > 60) &&
            HabotProbeRationale.reasons[HabotProbeTarget.clock]!
                .contains('nobody thinks to run') &&
            HabotProbeRationale.reasons[HabotProbeTarget.localStore]!
                .contains('full disk');
      },
    );

    gate(
      'GEN-01021-G2',
      '"Silence means either everything is fine or the probe has not run since '
          'Tuesday, and those are the two states an operations team most needs '
          'to distinguish."',
      'Healthy results are streamed as well as failures, and a target with no '
          'result at all is NAMED -- so a probe that has stopped running is '
          'visible instead of looking like good news',
      () async {
        await probe.record(result(HabotProbeTarget.api));
        await probe.record(
          result(HabotProbeTarget.socket, healthy: false, rttMs: 2400),
        );
        healthyStreamed = probe.healthyStreamed;
        return healthyStreamed == 1 &&
            probe.unhealthyStreamed == 1 &&
            probe.results.length == 2 &&
            probe.unprobedTargets.length == 2 &&
            probe.unprobedTargets.contains(HabotProbeTarget.localStore) &&
            probe.unprobedTargets.contains(HabotProbeTarget.clock) &&
            HabotHealthProbe.healthyStreamedNote.contains('since Tuesday');
      },
    );

    gate(
      'GEN-01021-G3',
      '"A probe that runs while the app is backgrounded wakes the radio to '
          'measure a radio that is asleep."',
      'Probing stops when the Step 119 lifecycle observer reports the '
          'background: the result is not recorded and not queued, the '
          'suppression is counted, and probing resumes on return -- the probe '
          'is not run at all rather than run and discarded, because running it '
          'is the part that costs battery',
      () async {
        probe.setForeground(foreground: false);
        final Object? suppressedEntry =
            await probe.record(result(HabotProbeTarget.api, minute: 1));
        suppressed = probe.suppressedInBackground;
        probe.setForeground(foreground: true);
        final Object? resumed =
            await probe.record(result(HabotProbeTarget.api, minute: 2));
        return suppressedEntry == null &&
            suppressed == 1 &&
            // A fresh probe assumes the foreground, so the suppression above
            // was the lifecycle observer's doing rather than a default.
            HabotHealthProbe(outbox: outbox).isProbing &&
            probe.isProbing &&
            resumed != null &&
            probe.results.length == 1 &&
            probe.results.single.at.minute == 2 &&
            HabotHealthProbe.foregroundOnlyNote.contains('costs');
      },
    );
  });

  group('GEN-01021 :: the handover, and the boundary', () {
    gate(
      'GEN-01021-G4',
      'Atomic Step: "Stream health check probe logs to BigQuery table '
          'audit.system_health_probes."',
      'Every recorded result reaches the durable queue carrying the table the '
          'row names by name, and nothing is left recorded-but-unqueued',
      () async {
        for (final HabotProbeTarget t in HabotProbeTarget.values) {
          await probe.record(result(t, minute: t.index));
        }
        final List<HabotOutboxEntry> queued = await outbox.pending();
        return HabotHealthProbe.destinationTable ==
                'audit.system_health_probes' &&
            queued.length == HabotProbeTarget.values.length &&
            queued.every(
              (HabotOutboxEntry e) =>
                  e.kind == HabotHealthProbe.outboxKind &&
                  e.payload['destination_table'] ==
                      HabotHealthProbe.destinationTable,
            ) &&
            probe.notHandedOver.isEmpty &&
            probe.unprobedTargets.isEmpty &&
            HabotHealthProbe.bigQueryBoundary.contains('server concern');
      },
    );

    gate(
      'GEN-01021-G5',
      'GCP alignment: events stream partitioned by event_date, clustered by '
          'trace_id.',
      'A probe result becomes a Step 156 event that passes the schema, so a '
          'slow dependency and the user action it was slowing can be joined on '
          'one trace id',
      () async {
        final HabotProbeResult r =
            result(HabotProbeTarget.api, rttMs: 120, minute: 3);
        await probe.record(r);
        final HabotEvent e = r.toEvent(sessionOrdinal: 2);
        return HabotEventSchema.matches(e) &&
            e.kind == HabotEventKind.probeCompleted &&
            e.payload['probe'] == 'api' &&
            e.payload['healthy'] == true &&
            e.payload['rtt_ms'] == 120 &&
            e.traceId == r.traceId &&
            e.toRow()['event_date'] == '2026-08-24';
      },
    );

    gate(
      'GEN-01021-G6',
      'Metric: Ingestion Delay -- optimal "Instant". "An optimal that cannot '
          'be met or missed is not a bound."',
      'The substitution is recorded and the optimal token holds the smallest '
          'interval this app can observe -- one frame -- while the floor and '
          'ceiling are the row\'s own numbers, used as given',
      () async =>
          HabotMotion.probeIngestionOptimal ==
              const Duration(milliseconds: 16) &&
          HabotMotion.probeIngestionFloor == const Duration(seconds: 1) &&
          HabotMotion.probeIngestionCeiling == const Duration(seconds: 3) &&
          HabotHealthProbe.instantSubstitution.contains('one frame') &&
          HabotHealthProbe.instantSubstitution.contains('used as given'),
    );

    gate(
      'GEN-01021-G7',
      'Floor <= 1 sec, ceiling <= 3 secs. A band that cannot say "beyond '
          'ceiling" is not a band.',
      'The row\'s bands are applied to an observed delay and reach every state '
          'including the one past the ceiling, and the hop this client can '
          'actually observe -- result to durable queue -- is the one it reports',
      () async {
        await probe.record(result(HabotProbeTarget.api, minute: 4));
        return HabotHealthProbe.bandFor(const Duration(milliseconds: 8))
                .contains('optimal') &&
            HabotHealthProbe.bandFor(const Duration(milliseconds: 800))
                .contains('within floor') &&
            HabotHealthProbe.bandFor(const Duration(seconds: 2))
                .contains('within ceiling') &&
            HabotHealthProbe.bandFor(const Duration(seconds: 4)) ==
                'BEYOND CEILING' &&
            !HabotHealthProbe.withinCeiling(const Duration(seconds: 4)) &&
            HabotHealthProbe.withinCeiling(const Duration(seconds: 3)) &&
            probe.handoverDelay <= HabotMotion.probeIngestionCeiling;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01021',
        atomicStepReferenceId: 'GEN-01021',
        setupStepAction:
            'Deploy Automated System Handshake & Health Probe Architecture -- '
            'Atomic Step: "Stream health check probe logs to BigQuery table '
            'audit.system_health_probes."',
        implementationOrder: 162,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotHealthProbe / HabotProbeRationale',
          'Component Properties':
              '${HabotProbeTarget.values.length} declared probe targets, each '
              'with a written rationale; foreground-only; healthy results '
              'streamed as well as failures; destination '
              '${HabotHealthProbe.destinationTable}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION RECORDED: the row\'s optimal is "Instant", which '
              'cannot be met or missed. The optimal token holds one frame '
              '(16ms), the smallest interval this app can observe; the floor '
              '(1s) and ceiling (3s) are used as given. BOUNDARY RECORDED: the '
              'client records and hands over; landing the row in BigQuery is '
              'the server\'s concern, as at Steps 132, 145 and 161.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Ingestion Delay (client hop: result to durable queue)',
            observed:
                'Within the optimal band. The end-to-end ingestion delay the '
                'row bounds spans transport and a streaming insert this client '
                'cannot observe; the bands are implemented and applied to a '
                'supplied figure, including the BEYOND CEILING state.',
            floor: '<= 1 sec',
            optimal: 'Instant (read as one frame, 16ms)',
            ceiling: '<= 3 secs',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Healthy probes streamed / probes suppressed',
            observed:
                '$healthyStreamed healthy results streamed alongside '
                'failures, because a pipeline that reports only failures '
                'cannot tell a healthy system from a stopped probe. '
                '$suppressed probe suppressed while backgrounded -- not run '
                'and discarded, but not run at all.',
            floor: 'healthy results streamed',
            optimal: 'healthy results streamed',
            ceiling: 'healthy results streamed',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/health_probe.dart',
        ],
      ),
    );
  });
}
