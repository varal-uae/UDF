/// AISS GATE -- Step 79 of 80
/// Global Reference ID:       GEN-00335
/// Atomic Steps Reference ID: GEN-00335
/// Setup Step (Action):       "Bind Pub/Sub violation topic listeners to the
///                             alert panel component."
/// Metric: Telemetry Ingestion Latency -- Floor "<= 5 seconds batch window",
///         Optimal "<= 1 second streaming ingestion", Ceiling "10 seconds
///         (staleness ceiling before alerting)".
/// Standard: "Google Cloud Well-Architected Framework -- Data Analytics
///           Pillar".
///
/// METRIC MISMATCH, RECORDED. Ingestion latency is how long a Pub/Sub pipeline
/// took to move an event from publisher to subscriber. A widget that renders
/// what arrives cannot influence it, and this suite cannot observe it -- there
/// is no pipeline here to time. Reported as NOT PRODUCED. No stand-in number
/// is offered.
///
/// ONE BAND IS USABLE, AND IT IS USED. The Ceiling reads "10 seconds
/// (staleness ceiling BEFORE ALERTING)", which is not a latency the client
/// produces but a rule the client can obey: an event that is already older
/// than ten seconds when it arrives must not be raised as a breach happening
/// now. That is implementable, and G3 gates it.
///
/// A GENERATED ROW, RECORDED: Setup Step and Description are the same
/// sentence, Why This Matters is that sentence plus "is a critical
/// implementation step", Expected Output is "Fully configured and validated
/// implementation of:" plus the sentence, the substeps are the generic four,
/// and Completion Measures is "100% CI/CD pass rate ... committed to runbook".
/// The Material Design columns are the boilerplate shared with every GEN-* row
/// and describe an engineering console. None of that is gated.
///
/// WHAT THE BINDING OWNS, and therefore what is measured: every event that
/// reaches the listener reaches the panel, in the order it arrived, without
/// being dropped or delivered twice -- and a malformed event does not kill the
/// subscription and take every later event with it.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/notifications/alert_panel.dart';
import 'package:udf_setup/design_system/notifications/alert_priority.dart';
import 'package:udf_setup/design_system/notifications/notification_center.dart';

import 'aiss_reporter.dart';

final DateTime _now = DateTime(2026, 8, 14, 9, 30);

HabotViolationEvent _event(
  String id, {
  HabotAlertSeverity severity = HabotAlertSeverity.critical,
  Duration age = Duration.zero,
}) => HabotViolationEvent(
  id: id,
  topic: 'violations.ledger',
  summary: 'Violation $id',
  severity: severity,
  publishedAt: _now.subtract(age),
);

/// Lets queued stream events run.
Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredDeliveryRate = -1;
  int measuredStale = -1;

  group('GEN-00335 :: the binding', () {
    test('[GEN-00335-G1] every event that arrives reaches the panel, in the '
        'order it arrived', () async {
      final StreamController<HabotViolationEvent> controller =
          StreamController<HabotViolationEvent>();
      final HabotAlertPanelController panel = HabotAlertPanelController();
      final HabotNotificationCenter centre = HabotNotificationCenter();
      final HabotViolationBinding binding = HabotViolationBinding(
        stream: controller.stream,
        panel: panel,
        centre: centre,
        clock: () => _now,
      );
      addTearDown(() async {
        await binding.dispose();
        await controller.close();
        panel.dispose();
        centre.dispose();
      });

      for (final String id in <String>['v1', 'v2', 'v3']) {
        controller.add(_event(id));
      }
      await _flush();

      expect(binding.receivedCount, 3);
      expect(binding.deliveredCount, 3);
      expect(binding.deliveredOrder, <String>['v1', 'v2', 'v3']);
      expect(
        panel.raisedCount,
        3,
        reason: 'the panel is what the topic is bound TO',
      );
      measuredDeliveryRate = binding.bindingDeliveryRate;
      expect(measuredDeliveryRate, 1.0);

      gates.add(
        AissGate(
          id: 'GEN-00335-G1',
          requirementSource:
              'Setup Step (Action): "BIND Pub/Sub violation topic LISTENERS to '
              'the ALERT PANEL COMPONENT" -- read against FLADE-011-10 '
              '(Step 73), which owns the panel.',
          description:
              'Three events published, three alerts on the panel, in order -- '
              'the binding neither drops nor reorders, which is the part of '
              'the pipeline a client actually owns',
          passed: true,
          detail:
              'delivery rate '
              '${measuredDeliveryRate.toStringAsFixed(2)}, order preserved',
        ),
      );
    });

    test('[GEN-00335-G2] a redelivered event is not a second alert', () async {
      final StreamController<HabotViolationEvent> controller =
          StreamController<HabotViolationEvent>();
      final HabotAlertPanelController panel = HabotAlertPanelController();
      final HabotNotificationCenter centre = HabotNotificationCenter();
      final HabotViolationBinding binding = HabotViolationBinding(
        stream: controller.stream,
        panel: panel,
        centre: centre,
        clock: () => _now,
      );
      addTearDown(() async {
        await binding.dispose();
        await controller.close();
        panel.dispose();
        centre.dispose();
      });

      controller
        ..add(_event('v1'))
        ..add(_event('v1'))
        ..add(_event('v2'));
      await _flush();

      // Pub/Sub delivers at least once. Twice is normal, not an error -- so
      // the duplicate is counted and swallowed rather than shown.
      expect(binding.receivedCount, 3);
      expect(binding.duplicateCount, 1);
      expect(binding.deliveredOrder, <String>['v1', 'v2']);
      expect(panel.raisedCount, 2);
      expect(
        binding.bindingDeliveryRate,
        1.0,
        reason: 'nothing was lost -- a duplicate is accounted for, not dropped',
      );

      gates.add(
        const AissGate(
          id: 'GEN-00335-G2',
          requirementSource:
              'Pub/Sub delivers AT LEAST ONCE -- a fact about the transport '
              'named in the Setup Step, which the binding has to absorb.',
          description:
              'The same violation delivered twice raises one alert, and the '
              'redelivery is counted rather than hidden, so the delivery rate '
              'still accounts for everything that arrived',
          passed: true,
        ),
      );
    });

    test('[GEN-00335-G3] an event already older than the staleness ceiling is '
        'recorded, not raised as current news', () async {
      final StreamController<HabotViolationEvent> controller =
          StreamController<HabotViolationEvent>();
      final HabotAlertPanelController panel = HabotAlertPanelController();
      final HabotNotificationCenter centre = HabotNotificationCenter();
      final HabotViolationBinding binding = HabotViolationBinding(
        stream: controller.stream,
        panel: panel,
        centre: centre,
        clock: () => _now,
      );
      addTearDown(() async {
        await binding.dispose();
        await controller.close();
        panel.dispose();
        centre.dispose();
      });

      controller
        ..add(_event('fresh', age: const Duration(seconds: 1)))
        ..add(
          _event(
            'stale',
            age: HabotViolationBinding.stalenessCeiling +
                const Duration(seconds: 5),
          ),
        );
      await _flush();

      measuredStale = binding.staleCount;
      expect(measuredStale, 1);
      expect(
        panel.raisedCount,
        1,
        reason: 'only the fresh one takes the screen',
      );
      expect(
        binding.deliveredOrder,
        <String>['fresh', 'stale'],
        reason: 'the stale one still arrived -- it was not thrown away',
      );
      expect(
        centre.entries.any((HabotNotificationEntry e) => e.id == 'stale'),
        isTrue,
        reason: 'it is in the centre, where an old fact belongs',
      );
      expect(HabotViolationBinding.stalenessCeiling.inSeconds, 10);

      gates.add(
        AissGate(
          id: 'GEN-00335-G3',
          requirementSource:
              'Metric Ceiling: "10 seconds (STALENESS CEILING BEFORE '
              'ALERTING)" -- the one band of this metric a client can obey.',
          description:
              'An event older than the ceiling when it arrives is stored in '
              'the notification centre rather than raised on the panel: a '
              'breach from a minute ago presented as happening now is '
              'misinformation, and neither is silently discarding it',
          passed: true,
          detail:
              'ceiling '
              '${HabotViolationBinding.stalenessCeiling.inSeconds}s, from '
              'HabotMotion.violationStalenessCeiling; $measuredStale of 2 '
              'events stale',
        ),
      );
    });

    test('[GEN-00335-G4] a stream error does not take the listener down',
        () async {
      final StreamController<HabotViolationEvent> controller =
          StreamController<HabotViolationEvent>();
      final HabotAlertPanelController panel = HabotAlertPanelController();
      final HabotNotificationCenter centre = HabotNotificationCenter();
      final HabotViolationBinding binding = HabotViolationBinding(
        stream: controller.stream,
        panel: panel,
        centre: centre,
        clock: () => _now,
      );
      addTearDown(() async {
        await binding.dispose();
        await controller.close();
        panel.dispose();
        centre.dispose();
      });

      controller.add(_event('v1'));
      await _flush();
      controller.addError(const FormatException('malformed envelope'));
      await _flush();
      controller.add(_event('v2'));
      await _flush();

      expect(binding.errorCount, 1);
      expect(
        binding.deliveredOrder,
        <String>['v1', 'v2'],
        reason:
            'a listener that dies on the first malformed event stops '
            'delivering every event after it -- which is how a breach goes '
            'unreported',
      );
      expect(panel.raisedCount, 2);

      gates.add(
        const AissGate(
          id: 'GEN-00335-G4',
          requirementSource:
              'Setup Step (Action): a LISTENER, which lives for the life of '
              'the app. Read against REF-197 (Step 19): a failure is handled, '
              'not propagated.',
          description:
              'A malformed event is counted as an error and the subscription '
              'survives it, so the event after the bad one still reaches the '
              'panel',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00335',
        atomicStepReferenceId: 'GEN-00335-A01',
        setupStepAction:
            'Bind Pub/Sub violation topic listeners to the alert panel '
            'component.',
        implementationOrder: 79,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Pub/Sub':
              'topic name carried on every event and shown as the alert '
              'detail, so an operator can see which listener produced what',
          'Delivery Accounting':
              'received / delivered / duplicates / stale / errors, each '
              'counted separately rather than rolled into one success figure',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC MISMATCH -- "Telemetry Ingestion Latency" measures a '
              'Pub/Sub pipeline, not the widget that renders what arrives. '
              'Recorded as NOT PRODUCED with no stand-in number. ONE BAND '
              'USED: the Ceiling names a 10-second staleness rule, which the '
              'client can and does obey (G3). GENERATED ROW -- Setup Step and '
              'Description are the same sentence; Why This Matters, Expected '
              'Output and the four substeps are template prose built from it; '
              'Completion Measures is CI/CD tracking; the Material Design '
              'columns are boilerplate describing an engineering console. '
              'None gated.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Telemetry Ingestion Latency',
            observed:
                'NOT PRODUCED -- publisher-to-subscriber latency is a property '
                'of the Pub/Sub pipeline. There is no pipeline in this suite '
                'to time, and no figure is asserted in its place. The one '
                'obeyable band, the 10-second staleness ceiling, is '
                'implemented and gated by GEN-00335-G3.',
            floor: '<= 5 seconds batch window',
            optimal: '<= 1 second streaming ingestion',
            ceiling: '10 seconds (staleness ceiling before alerting)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName:
                'Binding delivery rate (this step\'s own, not from the sheet)',
            observed: measuredDeliveryRate < 0
                ? 'not measured'
                : '${measuredDeliveryRate.toStringAsFixed(2)} -- everything '
                      'that reached the listener was accounted for: delivered, '
                      'deduplicated, or recorded as stale',
            floor: 'no sheet band',
            optimal: 'no sheet band',
            ceiling: 'no sheet band',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/alert_priority.dart',
        ],
      ),
    );
  });
}
