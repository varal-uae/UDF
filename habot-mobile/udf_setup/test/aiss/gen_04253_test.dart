/// AISS GATE -- Step 164 of 175
/// Global Reference ID:       GEN-04253
/// Atomic Steps Reference ID: GEN-04253
/// Setup Step (Action) / Atomic Step: "Capture mobile app cold start times and
///   page interactivity load times (target < 2s on 3G)."
/// Metric: UI/System Response Latency (RAIL Model) -- Floor "300 ms
///         (Perceptible Delay)", Optimal "< 100 ms (Instantaneous, RAIL
///         Standard)", Ceiling "1,000 ms (User Attention-Loss Threshold)".
///         Good / Average / Poor.
///
/// THE ROW MIXES TWO BUDGETS IN ONE SENTENCE: RAIL's 100ms, which is the budget
/// for a response to an input, and "< 2s on 3G", which is not. Applying the
/// first to a cold start would report every launch this app will ever make as a
/// failure against a bound that was never meant for it. G2 shows exactly that
/// happening, on the same number.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/event_schema.dart';
import 'package:udf_setup/design_system/telemetry/rail_timings.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  Duration reportedColdStart = Duration.zero;
  Duration meanColdStart = Duration.zero;

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

  /// Ten usable cold starts. The tail is the three-year-old handset in a depot.
  const List<int> coldStartSamplesMs = <int>[
    100,
    120,
    130,
    150,
    160,
    170,
    180,
    190,
    200,
    1100,
  ];

  HabotTiming timing(
    HabotTimingKind kind,
    int ms, {
    bool foreground = true,
    bool firstLaunch = false,
    int ordinal = 0,
  }) =>
      HabotTiming(
        kind: kind,
        elapsed: Duration(milliseconds: ms),
        at: DateTime.utc(2026, 8, 24, 10).add(Duration(seconds: ordinal)),
        traceId: 'trace-$ordinal',
        foregroundThroughout: foreground,
        firstLaunchAfterInstall: firstLaunch,
      );

  HabotRailTimings withColdStarts() {
    final HabotRailTimings t = HabotRailTimings();
    for (int i = 0; i < coldStartSamplesMs.length; i++) {
      t.capture(
        timing(HabotTimingKind.coldStart, coldStartSamplesMs[i], ordinal: i),
      );
    }
    return t;
  }

  group('GEN-04253 :: two budgets, kept apart', () {
    gate(
      'GEN-04253-G1',
      'Metric: RAIL Model, optimal "< 100 ms (Instantaneous)". Setup text: '
          '"cold start times and page interactivity load times (target < 2s on '
          '3G)".',
      'Every timing kind is mapped to exactly one budget family by a total '
          'mapping, so a new kind cannot be added without somebody deciding '
          'what it is judged against -- and only an input response is judged '
          'by RAIL',
      () =>
          HabotTimingKind.values.length == 4 &&
          HabotRailTimings.familyOf(HabotTimingKind.inputResponse) ==
              HabotBudgetFamily.rail &&
          HabotRailTimings.familyOf(HabotTimingKind.coldStart) ==
              HabotBudgetFamily.startup &&
          HabotRailTimings.familyOf(HabotTimingKind.warmStart) ==
              HabotBudgetFamily.startup &&
          HabotRailTimings.familyOf(HabotTimingKind.interactivity) ==
              HabotBudgetFamily.interactive &&
          HabotRailTimings.railOptimal == HabotMotion.railInstant &&
          HabotRailTimings.railFloor == HabotMotion.railPerceptible &&
          HabotRailTimings.railCeiling == HabotMotion.railAttentionLoss &&
          HabotRailTimings.startupBudget == const Duration(milliseconds: 1200) &&
          HabotRailTimings.interactiveBudget == const Duration(seconds: 2),
    );

    gate(
      'GEN-04253-G2',
      '"A cold start is not a response to an input; it is an app being built '
          'from nothing, and no mobile app has ever done it in 100ms."',
      'The SAME observed figure -- 1,100ms -- bands as Good against the '
          'startup budget and as Poor against the RAIL bands, which is the '
          'mistake this step exists to prevent, demonstrated rather than '
          'asserted',
      () {
        const Duration observed = Duration(milliseconds: 1100);
        return HabotRailTimings.bandFor(HabotTimingKind.coldStart, observed) ==
                'Good' &&
            HabotRailTimings.bandFor(
                  HabotTimingKind.inputResponse,
                  observed,
                ) ==
                'Poor' &&
            observed <= HabotRailTimings.startupBudget &&
            observed > HabotRailTimings.railCeiling &&
            HabotRailTimings.twoBudgetsNote.contains('technically derived');
      },
    );

    gate(
      'GEN-04253-G3',
      'Floor 300ms (Perceptible Delay), ceiling 1,000ms (Attention Loss). '
          'A band that never reports Poor is not a band.',
      'The RAIL vocabulary reaches every state on an input response, and the '
          'startup and interactivity families are judged against their own '
          'budgets including the "< 2s on 3G" target the setup text names',
      () =>
          HabotRailTimings.bandFor(
                HabotTimingKind.inputResponse,
                const Duration(milliseconds: 80),
              ) ==
              'Good' &&
          HabotRailTimings.bandFor(
                HabotTimingKind.inputResponse,
                const Duration(milliseconds: 250),
              ) ==
              'Average' &&
          HabotRailTimings.bandFor(
                HabotTimingKind.inputResponse,
                const Duration(milliseconds: 900),
              ) ==
              'Average' &&
          HabotRailTimings.bandFor(
                HabotTimingKind.inputResponse,
                const Duration(milliseconds: 1500),
              ) ==
              'Poor' &&
          HabotRailTimings.bandFor(
                HabotTimingKind.interactivity,
                const Duration(milliseconds: 1800),
              ) ==
              'Good' &&
          HabotRailTimings.bandFor(
                HabotTimingKind.interactivity,
                const Duration(milliseconds: 2500),
              ) ==
              'Poor',
    );
  });

  group('GEN-04253 :: what gets reported, and what gets excluded', () {
    gate(
      'GEN-04253-G4',
      '"The p50 is the device the developer tests on and the p95 is the '
          'three-year-old handset in a depot."',
      'The reported figure is a nearest-rank p95 rather than a mean, and on '
          'this sample the two differ by a factor of four -- so the choice is '
          'demonstrated on real arithmetic rather than stated as a preference',
      () {
        final HabotRailTimings t = withColdStarts();
        final HabotTimingSet set = t.setOf(HabotTimingKind.coldStart);
        reportedColdStart = t.reportedFor(HabotTimingKind.coldStart);
        meanColdStart = set.mean;
        return set.samples.length == 10 &&
            set.p95 == const Duration(milliseconds: 1100) &&
            set.p50 == const Duration(milliseconds: 160) &&
            set.mean == const Duration(milliseconds: 250) &&
            reportedColdStart == set.p95 &&
            reportedColdStart > meanColdStart &&
            t.bandOf(HabotTimingKind.coldStart) == 'Good' &&
            HabotRailTimings.percentileNote.contains('deliberately not');
      },
    );

    gate(
      'GEN-04253-G5',
      '"A timing without its conditions is not a measurement." A first launch '
          'pays for one-time setup; a part-background window includes seconds '
          'the process spent suspended.',
      'A first launch and a timing that was not wholly in the foreground are '
          'both excluded from the reported set -- the first launch reported '
          'separately rather than discarded -- so neither poisons the p95',
      () {
        final HabotRailTimings t = withColdStarts()
          ..capture(
            timing(
              HabotTimingKind.coldStart,
              3000,
              firstLaunch: true,
              ordinal: 20,
            ),
          )
          ..capture(
            timing(
              HabotTimingKind.coldStart,
              9000,
              foreground: false,
              ordinal: 21,
            ),
          );
        final HabotTimingSet reported = t.setOf(HabotTimingKind.coldStart);
        final HabotTimingSet firstLaunches =
            t.firstLaunchSetOf(HabotTimingKind.coldStart);
        return t.captured.length == 12 &&
            reported.samples.length == 10 &&
            reported.p95 == const Duration(milliseconds: 1100) &&
            firstLaunches.samples.length == 1 &&
            firstLaunches.p95 == const Duration(milliseconds: 3000) &&
            t.bandOf(HabotTimingKind.coldStart) == 'Good' &&
            HabotRailTimings.conditionsNote.contains('Step 166');
      },
    );

    gate(
      'GEN-04253-G6',
      '"Zero bands as Good, which is how a metric that is not being collected '
          'ends up looking like a metric that is passing."',
      'A timing kind with no usable sample is named in unmeasuredKinds rather '
          'than reported as zero -- and the trap is shown: the zero it would '
          'otherwise report does band as Good',
      () {
        final HabotRailTimings t = withColdStarts();
        final List<HabotTimingKind> unmeasured = t.unmeasuredKinds;
        return unmeasured.length == 3 &&
            !unmeasured.contains(HabotTimingKind.coldStart) &&
            unmeasured.contains(HabotTimingKind.warmStart) &&
            unmeasured.contains(HabotTimingKind.interactivity) &&
            unmeasured.contains(HabotTimingKind.inputResponse) &&
            t.reportedFor(HabotTimingKind.warmStart) == Duration.zero &&
            // The trap, made visible.
            t.bandOf(HabotTimingKind.warmStart) == 'Good' &&
            HabotRailTimings().unmeasuredKinds.length == 4 &&
            HabotRailTimings.noSampleNote.contains('NAMED');
      },
    );

    gate(
      'GEN-04253-G7',
      'GCP alignment: events stream partitioned by event_date, clustered by '
          'trace_id.',
      'A captured timing becomes a Step 156 event that passes the schema and '
          'carries the foreground flag Step 166 filters on, so a slow launch '
          'and the session it happened in can be joined',
      () {
        final HabotTiming t = timing(HabotTimingKind.coldStart, 1100);
        final HabotEvent e =
            t.toEvent(view: 'launch', sessionOrdinal: 0);
        final HabotTiming background = timing(
          HabotTimingKind.coldStart,
          9000,
          foreground: false,
          ordinal: 1,
        );
        return HabotEventSchema.matches(e) &&
            e.kind == HabotEventKind.timingCaptured &&
            e.payload['timing_kind'] == 'coldStart' &&
            e.payload['elapsed_ms'] == 1100 &&
            e.payload['foreground'] == true &&
            background.toEvent(view: 'launch', sessionOrdinal: 1)
                    .payload['foreground'] ==
                false &&
            e.toRow()['event_date'] == '2026-08-24';
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04253',
        atomicStepReferenceId: 'GEN-04253',
        setupStepAction:
            'Capture mobile app cold start times and page interactivity load '
            'times (target < 2s on 3G).',
        implementationOrder: 164,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotRailTimings / HabotTimingSet',
          'Component Properties':
              '${HabotTimingKind.values.length} timing kinds mapped to '
              '${HabotBudgetFamily.values.length} budget families by a total '
              'mapping; RAIL 100/300/1000ms applied only to input responses; '
              'startup budget ${HabotRailTimings.startupBudget.inMilliseconds}'
              'ms; interactivity budget '
              '${HabotRailTimings.interactiveBudget.inSeconds}s on 3G; '
              'nearest-rank percentiles',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'READING RECORDED: the row names the RAIL bands and, in the same '
              'sentence, a startup target of 2s on 3G. RAIL\'s 100ms is the '
              'budget for a response to an input; a cold start is not one. '
              'Applying the RAIL bands to a cold start would report every '
              'launch as a failure -- gate G2 shows the same 1,100ms figure '
              'banding Good against the startup budget and Poor against RAIL. '
              'The samples here are fixtures; real device figures require the '
              'profile-mode run named at Step 165.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI/System Response Latency (RAIL Model)',
            observed:
                'RAIL bands implemented verbatim and applied only to input '
                'responses: Good under 100ms, Average to 1,000ms, Poor beyond. '
                'Cold and warm starts are judged against the 1,200ms startup '
                'budget and interactivity against 2s on 3G.',
            floor: '300 ms (Perceptible Delay)',
            optimal: '< 100 ms (Instantaneous, RAIL Standard)',
            ceiling: '1,000 ms (User Attention-Loss Threshold)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Reported cold start (p95 over the fixture set)',
            observed:
                '${reportedColdStart.inMilliseconds}ms at p95 against a mean '
                'of ${meanColdStart.inMilliseconds}ms over the same ten '
                'samples -- a factor of four. The p95 is what is reported; the '
                'mean is available and deliberately not what the band is '
                'computed from. First launches and part-background windows are '
                'excluded, and a kind with no sample is named rather than '
                'reported as zero, which would band as Good.',
            floor: '1,200 ms (startup budget)',
            optimal: '< 1,200 ms on the floor device',
            ceiling: '1,200 ms',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/rail_timings.dart',
        ],
      ),
    );
  });
}
