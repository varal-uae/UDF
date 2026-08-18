/// AISS GATE -- Step 68 of 80
/// Global Reference ID:       GEN-00699
/// Atomic Steps Reference ID: GEN-00699-A01
/// Setup Step (Action):       "Configure Mobile Push Notifications & Real-Time
///                             Alert Triggers."
/// Setup Step Description:    "Write client-side push notification receiver
///                             handler onMessageReceived."
/// Metric: Client Handler Speed -- Floor <= 10 ms, Optimal <= 2 ms,
///         Ceiling 20 ms.
///
/// DUPLICATE SETUP STEP, RECORDED: byte-identical to S.No 13985 (Step 66).
/// Told apart by the Setup Step Description: that step is the FCM/dispatch
/// engine, this is the client receiver.
///
/// THE METRIC DICTATES THE DESIGN. Two milliseconds is not enough to touch
/// storage, render a widget or await anything -- so the handler parses,
/// deduplicates and enqueues, and nothing else. G4 measures a thousand
/// messages through it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/notifications/message_receiver.dart';
import 'package:udf_setup/design_system/notifications/notification_payload.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

Map<String, Object?> _wire({
  required String id,
  String kind = 'informational',
  String route = '/tasks',
  String title = 'Job ready',
  String body = 'Tap to accept.',
}) => <String, Object?>{
  'notification': <String, Object?>{'title': title, 'body': body},
  'data': <String, Object?>{'id': id, 'kind': kind, 'route': route},
};

HabotIncomingMessage _msg(
  Map<String, Object?> raw, {
  HabotMessageSource source = HabotMessageSource.foreground,
}) => HabotIncomingMessage(
  source: source,
  receivedAt: DateTime(2026, 8, 14, 9),
  raw: raw,
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double optimalRate = 0;
  Duration worst = Duration.zero;
  Duration median = Duration.zero;
  int measured = 0;

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

  group('GEN-00699-A01 :: the handler', () {
    gate(
      'GEN-00699-G1',
      'Metric: Client Handler Speed -- Floor <= 10 ms, Optimal <= 2 ms, '
          'Ceiling 20 ms.',
      'All three bands are the sheet\'s own numbers, held in the motion tokens '
          'rather than restated, and they are ordered optimal < floor < ceiling '
          'as a latency metric should be',
      () =>
          HabotMessageReceiver.handlerFloor ==
              const Duration(milliseconds: 10) &&
          HabotMessageReceiver.handlerOptimal ==
              const Duration(milliseconds: 2) &&
          HabotMessageReceiver.handlerCeiling ==
              const Duration(milliseconds: 20) &&
          HabotMessageReceiver.handlerOptimal <
              HabotMessageReceiver.handlerFloor &&
          HabotMessageReceiver.handlerFloor <
              HabotMessageReceiver.handlerCeiling &&
          HabotMessageReceiver.handlerFloor == HabotMotion.messageHandlerFloor,
    );

    gate(
      'GEN-00699-G2',
      'Setup Step Description: "Write client-side push notification receiver '
          'handler ONMESSAGERECEIVED." The same notification can arrive twice '
          '-- once in the foreground and once as a tap.',
      'A repeated id is suppressed rather than shown twice, and the '
          'suppression is counted rather than silent',
      () {
        final HabotMessageReceiver receiver = HabotMessageReceiver();
        for (final String id in <String>['a', 'b', 'a', 'c', 'b', 'a']) {
          receiver.onMessageReceived(_msg(_wire(id: id)));
        }
        return receiver.queueDepth == 3 &&
            receiver.duplicateCount == 3 &&
            receiver.malformedCount == 0;
      },
    );

    gate(
      'GEN-00699-G3',
      'A handler that throws takes out the next message too, so malformed '
          'input must be an outcome rather than an exception.',
      'Six differently-broken messages all return null, none throws, each is '
          'counted, and an unknown kind degrades to informational rather than '
          'failing',
      () {
        final HabotMessageReceiver receiver = HabotMessageReceiver();
        final List<Map<String, Object?>> broken = <Map<String, Object?>>[
          <String, Object?>{},
          <String, Object?>{'data': 'not a map', 'notification': <String, Object?>{}},
          <String, Object?>{
            'notification': <String, Object?>{'title': 'x', 'body': 'y'},
            'data': <String, Object?>{'route': '/tasks'},
          },
          <String, Object?>{
            'notification': <String, Object?>{'title': 'x', 'body': 'y'},
            'data': <String, Object?>{'id': 'z'},
          },
          <String, Object?>{
            'notification': <String, Object?>{'title': 42, 'body': 'y'},
            'data': <String, Object?>{'id': 'z', 'route': '/tasks'},
          },
          <String, Object?>{
            'notification': <String, Object?>{'title': 'x', 'body': 'y'},
            'data': <String, Object?>{'id': '', 'route': '/tasks'},
          },
        ];
        for (final Map<String, Object?> raw in broken) {
          if (receiver.onMessageReceived(_msg(raw)) != null) {
            return false;
          }
        }
        final HabotParsedMessage? unknownKind = receiver.onMessageReceived(
          _msg(_wire(id: 'k', kind: 'a-kind-from-the-future')),
        );
        return receiver.malformedCount == broken.length &&
            unknownKind != null &&
            unknownKind.kind == HabotNotificationKind.informational &&
            receiver.onRawMessage('{ not json') == null;
      },
    );

    gate(
      'GEN-00699-G4',
      'Metric: Client Handler Speed -- Optimal <= 2 ms. Two milliseconds is '
          'not enough to touch storage or render a widget, which is why the '
          'handler only parses and enqueues.',
      'A thousand messages through the handler stay inside the optimal band, '
          'and the pass rate, median and worst case are all reported rather '
          'than a single number asserted',
      () {
        final HabotMessageReceiver receiver =
            HabotMessageReceiver(queueLimit: 2000);
        for (int i = 0; i < 1000; i++) {
          receiver.onMessageReceived(_msg(_wire(id: 'm$i')));
        }
        measured = receiver.handlerTimings.length;
        optimalRate = receiver.optimalPassRate;
        worst = receiver.worstHandlerTime;
        median = receiver.medianHandlerTime;
        return measured == 1000 &&
            receiver.queueDepth == 1000 &&
            worst <= HabotMessageReceiver.handlerCeiling &&
            median <= HabotMessageReceiver.handlerOptimal;
      },
    );

    gate(
      'GEN-00699-G5',
      'Setup Step Description -- an unbounded queue is a memory leak wearing '
          'a buffer\'s clothes.',
      'The queue is capped, the message evicted under pressure is always an '
          'informational one, and an urgent message is never dropped to make '
          'room for another -- the eviction is counted either way',
      () {
        final HabotMessageReceiver receiver = HabotMessageReceiver(queueLimit: 4);
        receiver.onMessageReceived(_msg(_wire(id: 'i1')));
        receiver.onMessageReceived(_msg(_wire(id: 'i2')));
        receiver.onMessageReceived(_msg(_wire(id: 'ap', kind: 'approval')));
        receiver.onMessageReceived(_msg(_wire(id: 'cr', kind: 'critical')));
        // At capacity. The next three should evict informational ones only.
        receiver.onMessageReceived(_msg(_wire(id: 'i3')));
        receiver.onMessageReceived(_msg(_wire(id: 'i4')));

        final List<HabotParsedMessage> queued = receiver.queued;
        final bool urgentSurvived =
            queued.any((HabotParsedMessage m) => m.id == 'ap') &&
                queued.any((HabotParsedMessage m) => m.id == 'cr');
        return queued.length == 4 &&
            urgentSurvived &&
            receiver.droppedCount == 2 &&
            !queued.any((HabotParsedMessage m) => m.id == 'i1');
      },
    );

    gate(
      'GEN-00699-G6',
      'The 2ms budget only holds if the slow work happens somewhere else.',
      'Draining returns everything queued and empties it, so the expensive '
          'half runs off the delivery path -- and the source of each message '
          'survives, because a tap and a foreground arrival are routed '
          'differently in Step 76',
      () {
        final HabotMessageReceiver receiver = HabotMessageReceiver();
        receiver.onMessageReceived(_msg(_wire(id: 'x')));
        receiver.onMessageReceived(
          _msg(_wire(id: 'y'), source: HabotMessageSource.tapped),
        );
        final List<HabotParsedMessage> drained = receiver.drain();
        return drained.length == 2 &&
            receiver.queueDepth == 0 &&
            drained[0].source == HabotMessageSource.foreground &&
            drained[1].source == HabotMessageSource.tapped &&
            drained[1].route == '/tasks';
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00699',
        atomicStepReferenceId: 'GEN-00699-A01',
        setupStepAction:
            'Configure Mobile Push Notifications & Real-Time Alert Triggers.',
        implementationOrder: 68,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'onMessageReceived':
              'Implemented as HabotMessageReceiver.onMessageReceived -- parse, '
              'deduplicate, enqueue, and nothing else',
          'Component Properties':
              'queue limit ${HabotMessageReceiver.defaultQueueLimit}; '
              'informational messages evicted first; urgent never evicted',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'DUPLICATE SETUP STEP -- byte-identical to S.No 13985 (Step 66). '
              'Told apart by the Setup Step Description.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Client Handler Speed',
            observed:
                'Over $measured messages: median '
                '${median.inMicroseconds / 1000}ms, worst '
                '${worst.inMicroseconds / 1000}ms, '
                '${optimalRate.toStringAsFixed(1)}% inside the 2ms optimal. '
                'Measured on the test host, not on a handset.',
            floor: '<= 10 ms',
            optimal: '<= 2 ms',
            ceiling: '20 ms',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/message_receiver.dart',
        ],
      ),
    );
  });
}
