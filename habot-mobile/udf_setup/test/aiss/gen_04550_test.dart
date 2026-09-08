/// AISS GATE -- Step 127 of 135
/// Global Reference ID:       GEN-04550
/// Atomic Steps Reference ID: GEN-04550
/// Atomic Step: "Implement heartbeat ping/pong mechanisms maintaining
///               connection viability."
/// Metric: Real-Time Message Delivery Latency -- Floor < 2s, Optimal < 500ms,
///         Ceiling < 100ms (diminishing returns).
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// BAND INVERSION, RECORDED: lower is better and the sheet has written the
/// ceiling as the BEST value. Same inversion as Step 102's row.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/sync_governor.dart';
import 'package:udf_setup/design_system/resilience/heartbeat.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  DateTime now = DateTime(2026, 9, 8, 9);
  Duration? reportedMedian;
  double reportedAnswerRate = 0;

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

  HabotHeartbeat beat({
    void Function(Duration)? onRtt,
    void Function()? onDead,
    List<int>? sentSequences,
  }) => HabotHeartbeat(
    sendPing: (int seq) async => sentSequences?.add(seq),
    onRoundTrip: onRtt,
    onDeclaredDead: onDead,
    clock: () => now,
  );

  group('GEN-04550 :: ping, pong, and the judgement between', () {
    gate(
      'GEN-04550-G1',
      'Atomic Step: "heartbeat PING/PONG mechanisms MAINTAINING CONNECTION '
          'VIABILITY."',
      'A ping goes out with a sequence, the matching pong is measured, and the '
          'round trip is reported to whoever is listening',
      () async {
        final List<int> sent = <int>[];
        final List<Duration> rtts = <Duration>[];
        final HabotHeartbeat h = beat(
          onRtt: rtts.add,
          sentSequences: sent,
        );
        final HabotBeat b = await h.beat();
        now = now.add(const Duration(milliseconds: 120));
        final Duration? rtt = h.recordPong(b.sequence);
        return sent.single == 1 &&
            b.sequence == 1 &&
            rtt == const Duration(milliseconds: 120) &&
            rtts.single == rtt &&
            h.lastRtt == rtt &&
            h.liveness == HabotLiveness.live &&
            h.outstanding == null;
      },
    );

    gate(
      'GEN-04550-G2',
      'A TCP connection through a mobile NAT survives in the client memory '
          'long after the carrier dropped the mapping. The socket reports '
          'open, writes succeed into a buffer, and nothing arrives.',
      'Unanswered beats move the heartbeat from live to suspect to dead, and '
          'the drop is announced ONCE so Step 121 backoff starts once',
      () async {
        int deaths = 0;
        final HabotHeartbeat h = beat(onDead: () => deaths++);
        await h.beat();
        h.recordMissed();
        final bool suspectAfterOne =
            h.liveness == HabotLiveness.suspect && !h.isDeclaredDead;
        await h.beat();
        h.recordMissed();
        h.recordMissed();
        return suspectAfterOne &&
            HabotHeartbeat.missedBeatsBeforeDead == 2 &&
            h.isDeclaredDead &&
            h.liveness == HabotLiveness.dead &&
            deaths == 1;
      },
    );

    gate(
      'GEN-04550-G3',
      'A single missed beat is a phone switching from wifi to cellular '
          'mid-flight. Declaring the connection dead for it would mean '
          'reconnecting constantly on a train.',
      'One missed beat does not declare death, and a subsequent answer clears '
          'the suspicion and revives the connection',
      () async {
        final HabotHeartbeat h = beat();
        await h.beat();
        h.recordMissed();
        final HabotBeat second = await h.beat();
        now = now.add(const Duration(milliseconds: 90));
        h.recordPong(second.sequence);
        return !h.isDeclaredDead &&
            h.consecutiveMissed == 0 &&
            h.liveness == HabotLiveness.live;
      },
    );

    gate(
      'GEN-04550-G4',
      'A late answer is not evidence the link is healthy -- it is evidence it '
          'is slow. Counting it would let a dying connection look alive.',
      'A pong that arrives past the timeout is recorded for the latency figure '
          'but does NOT clear the missed-beat counter',
      () async {
        final HabotHeartbeat h = beat();
        final HabotBeat b = await h.beat();
        h.recordMissed();
        now = now.add(HabotHeartbeat.timeout + const Duration(seconds: 1));
        final Duration? late = h.recordPong(b.sequence);
        return late != null &&
            late > HabotHeartbeat.timeout &&
            h.consecutiveMissed == 1 &&
            h.liveness == HabotLiveness.suspect &&
            h.roundTrips.length == 1;
      },
    );
  });

  group('GEN-04550 :: what it produces for the rest of the batch', () {
    gate(
      'GEN-04550-G5',
      'Every pong is a round-trip measurement, and Step 124 governor needs '
          'exactly those.',
      'Round trips feed straight into the Step 124 governor, which reaches its '
          'degraded state from heartbeat data alone -- no second measurement '
          'path',
      () async {
        final HabotSyncGovernorControl governor = HabotSyncGovernorControl();
        final HabotHeartbeat h = beat(onRtt: governor.observe);
        for (int i = 0; i < 5; i++) {
          final HabotBeat b = await h.beat();
          now = now.add(const Duration(milliseconds: 1500));
          h.recordPong(b.sequence);
        }
        return governor.samples.length == 5 &&
            governor.isDegraded &&
            !governor.decide(HabotWorkClass.heavyBackground).allowed &&
            governor.decide(HabotWorkClass.lightBackground).allowed;
      },
    );

    gate(
      'GEN-04550-G6',
      'Pausing the thing that MEASURES the link, because the link is slow, '
          'would leave the governor blind.',
      'The heartbeat is classed as light background work, which Step 124 '
          'continues while degraded -- the two steps agree on this by '
          'construction rather than by coincidence',
      () async {
        final HabotSyncGovernorControl governor = HabotSyncGovernorControl();
        for (int i = 0; i < 5; i++) {
          governor.observe(const Duration(milliseconds: 4000));
        }
        return governor.isDegraded &&
            governor.decide(HabotWorkClass.lightBackground).allowed &&
            governor
                .decide(HabotWorkClass.lightBackground)
                .reason
                .contains('heartbeat');
      },
    );

    gate(
      'GEN-04550-G7',
      'Metric: Real-Time Message Delivery Latency. The bands are inverted -- '
          'the ceiling (<100ms) is the BEST value, the floor (<2s) the worst.',
      'The median round trip is measured over real beats and sits inside the '
          'optimal band, the answer rate is reported alongside it, and the '
          'inversion is recorded in the code',
      () async {
        final HabotHeartbeat h = beat();
        for (final int ms in <int>[80, 120, 95, 150, 110]) {
          final HabotBeat b = await h.beat();
          now = now.add(Duration(milliseconds: ms));
          h.recordPong(b.sequence);
        }
        // One beat that is never answered, so the rate is not trivially 1.
        await h.beat();
        h.recordMissed();
        reportedMedian = h.medianRtt;
        reportedAnswerRate = h.answerRate;
        return reportedMedian == const Duration(milliseconds: 110) &&
            reportedMedian! < HabotMotion.heartbeatSlowThreshold &&
            (reportedAnswerRate - 5 / 6).abs() < 0.0001 &&
            HabotHeartbeat.bandInversionNote.contains('CEILING is the best');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04550',
        atomicStepReferenceId: 'GEN-04550',
        setupStepAction:
            'Implement heartbeat ping/pong mechanisms maintaining connection '
            'viability.',
        implementationOrder: 127,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotHeartbeat / HabotBeat',
          'Component Properties':
              'interval ${HabotHeartbeat.interval.inSeconds}s, timeout '
              '${HabotHeartbeat.timeout.inSeconds}s, '
              '${HabotHeartbeat.missedBeatsBeforeDead} missed beats before '
              'death; ${HabotLiveness.values.length} liveness states; every '
              'pong feeds the Step 124 governor',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row. The metric bands are '
              'inverted relative to the sheet usual convention; recorded in '
              'HabotHeartbeat.bandInversionNote.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Real-Time Message Delivery Latency (median round '
                'trip)',
            observed:
                '${reportedMedian?.inMilliseconds ?? 0}ms median over five '
                'answered beats, with an answer rate of '
                '${(reportedAnswerRate * 100).toStringAsFixed(1)}% across six. '
                'Measured against an in-memory transport, so the number is '
                'the instrument working rather than a claim about a real '
                'network. NOTE the inversion: the <100ms ceiling is the BEST '
                'value in this row, not the worst.',
            floor: '< 2s',
            optimal: '< 500ms',
            ceiling: '< 100ms (diminishing returns)',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Connection viability detection',
            observed:
                'A dead NAT mapping is detected after two unanswered beats and '
                'announced once. A single missed beat -- a wifi-to-cellular '
                'handover -- does not declare death. A pong arriving after the '
                'timeout is measured but does not clear the suspicion, so a '
                'dying connection cannot look alive.',
            floor: 'detects an unresponsive link',
            optimal: 'detects it without false positives',
            ceiling: 'detects it without false positives',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/heartbeat.dart',
        ],
      ),
    );
  });
}
