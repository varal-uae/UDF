/// AISS GATE -- Step 166 of 175
/// Global Reference ID:       GEN-04539
/// Atomic Steps Reference ID: GEN-04539
/// Setup Step (Action) / Atomic Step: "Filter out performance trace data
///   collected during background execution states."
/// Metric: Form Field Validation Accuracy -- Floor 0.95, Optimal 0.99,
///         Ceiling 1.0. Good / Average / Poor.
///
/// A MISMATCHED METRIC, RECORDED: the Atomic Step is about performance traces
/// and the metric names form field validation. What the metric's SHAPE is good
/// for is an accuracy rate over a classification, and this step is a
/// classifier, so it is read as filter accuracy against a known-correct
/// labelling. The obvious implementation keeps exactly the wrong traces, and
/// G2 shows it doing so on the same data.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/rail_timings.dart';
import 'package:udf_setup/design_system/telemetry/trace_filter.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double filterAccuracy = 0;
  double naiveAccuracy = 0;

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

  DateTime at(int second) => DateTime.utc(2026, 8, 24, 10, 0, second);

  /// The app went to the background at :30 and came back at :40.
  HabotTraceFilter filter() => HabotTraceFilter(
        transitions: <HabotLifecycleTransition>[
          HabotLifecycleTransition(at: at(30), toForeground: false),
          HabotLifecycleTransition(at: at(40), toForeground: true),
        ],
      );

  HabotTiming timing({
    required int endSecond,
    required int elapsedMs,
    required bool capturedAsForeground,
    bool firstLaunch = false,
  }) =>
      HabotTiming(
        kind: HabotTimingKind.coldStart,
        elapsed: Duration(milliseconds: elapsedMs),
        at: at(endSecond),
        traceId: 'trace-$endSecond',
        foregroundThroughout: capturedAsForeground,
        firstLaunchAfterInstall: firstLaunch,
      );

  /// Five traces whose correct classification is known by construction.
  List<HabotTiming> fixture() => <HabotTiming>[
        // Wholly before the app went away.
        timing(endSecond: 20, elapsedMs: 5000, capturedAsForeground: true),
        // **The one that matters**: started at :25, finished at :35, and the
        // app went to the background at :30. Reads as foreground at capture
        // time; its elapsed time includes five suspended seconds.
        timing(endSecond: 35, elapsedMs: 10000, capturedAsForeground: true),
        // Entirely inside the background window.
        timing(endSecond: 38, elapsedMs: 2000, capturedAsForeground: false),
        // Not a window at all.
        timing(endSecond: 45, elapsedMs: 0, capturedAsForeground: true),
        // Foreground throughout, but a first launch.
        timing(
          endSecond: 50,
          elapsedMs: 3000,
          capturedAsForeground: true,
          firstLaunch: true,
        ),
      ];

  const List<HabotTraceVerdict> groundTruth = <HabotTraceVerdict>[
    HabotTraceVerdict.kept,
    HabotTraceVerdict.droppedBackgrounded,
    HabotTraceVerdict.droppedBackgrounded,
    HabotTraceVerdict.droppedImplausible,
    HabotTraceVerdict.divertedFirstLaunch,
  ];

  group('GEN-04539 :: the mid-window finding', () {
    gate(
      'GEN-04539-G1',
      'Atomic Step: "Filter out performance trace data collected during '
          'background execution states."',
      'A trace is kept only when the app was in the foreground for the WHOLE '
          'window: a transition to the background inside the window '
          'disqualifies it however briefly, because a two-second suspension is '
          'two seconds added to the measurement',
      () {
        final HabotTraceFilter f = filter();
        return f.foregroundThroughout(at(15), at(20)) &&
            !f.foregroundThroughout(at(25), at(35)) &&
            !f.foregroundThroughout(at(29), at(31)) &&
            f.foregroundThroughout(at(41), at(50)) &&
            HabotTraceFilter.midWindowNote.contains('p95 of eleven seconds');
      },
    );

    gate(
      'GEN-04539-G2',
      '"Checking \'was the app in the foreground?\' at the moment a trace is '
          'captured passes the case everyone tests and fails the case that '
          'matters."',
      'On the trace that started in the foreground and finished after the user '
          'backgrounded the app, the naive check keeps it and the filter drops '
          'it -- and the dropped trace is the one carrying five seconds of '
          'suspended process in its elapsed time',
      () {
        final HabotTiming midWindow = fixture()[1];
        final HabotTraceDecision decision = filter().classify(midWindow);
        return HabotTraceFilter.naiveKeeps(midWindow) &&
            !decision.isKept &&
            decision.verdict == HabotTraceVerdict.droppedBackgrounded &&
            decision.reason.contains('suspended') &&
            midWindow.elapsed == const Duration(seconds: 10);
      },
    );

    gate(
      'GEN-04539-G3',
      '"A window that begins while backgrounded is also disqualified."',
      'The state before the window matters as much as the transitions inside '
          'it: a trace wholly inside the background window is dropped even '
          'though no transition falls within it',
      () {
        final HabotTraceDecision d = filter().classify(fixture()[2]);
        return d.verdict == HabotTraceVerdict.droppedBackgrounded &&
            !filter().foregroundThroughout(at(36), at(38));
      },
    );

    gate(
      'GEN-04539-G4',
      'HabotTraceVerdict: kept, droppedBackgrounded, divertedFirstLaunch, '
          'droppedImplausible. "A first launch is real, and materially slower."',
      'The classifier reaches all four verdicts, and the two that are not '
          'failures are kept distinct: a first launch is DIVERTED for separate '
          'reporting rather than dropped, and a zero-length window is refused '
          'as implausible rather than counted as instant',
      () {
        final List<HabotTraceDecision> decisions =
            filter().classifyAll(fixture());
        final Map<HabotTraceVerdict, int> tally =
            HabotTraceFilter.tally(decisions);
        return decisions.length == 5 &&
            decisions.map((HabotTraceDecision d) => d.verdict).toList().join() ==
                groundTruth.join() &&
            tally[HabotTraceVerdict.kept] == 1 &&
            tally[HabotTraceVerdict.droppedBackgrounded] == 2 &&
            tally[HabotTraceVerdict.droppedImplausible] == 1 &&
            tally[HabotTraceVerdict.divertedFirstLaunch] == 1 &&
            HabotTraceVerdict.values.length == 4;
      },
    );
  });

  group('GEN-04539 :: the metric, read as filter accuracy', () {
    gate(
      'GEN-04539-G5',
      'Metric: floor 0.95, optimal 0.99, ceiling 1.0. "A rate computed from '
          'the filter\'s own output would be 1.0 by construction."',
      'Accuracy is measured against a known-correct labelling, the filter '
          'scores 1.0 on it, and the naive classifier scores 0.4 on the '
          'identical data -- which is what the metric is for and why it is '
          'measured against ground truth rather than against the filter itself',
      () {
        final List<HabotTiming> traces = fixture();
        final List<HabotTraceDecision> decisions =
            filter().classifyAll(traces);
        final List<HabotTraceDecision> naive = traces
            .map(
              (HabotTiming t) => HabotTraceDecision(
                timing: t,
                verdict: HabotTraceFilter.naiveKeeps(t)
                    ? HabotTraceVerdict.kept
                    : HabotTraceVerdict.droppedBackgrounded,
                reason: 'Trusted the flag on the trace.',
              ),
            )
            .toList();

        filterAccuracy = HabotTraceFilter.accuracy(decisions, groundTruth);
        naiveAccuracy = HabotTraceFilter.accuracy(naive, groundTruth);

        return filterAccuracy == 1.0 &&
            filterAccuracy >= HabotTraceFilter.optimal &&
            filterAccuracy == HabotTraceFilter.ceiling &&
            HabotTraceFilter.bandFor(filterAccuracy) == 'Good' &&
            naiveAccuracy == 0.4 &&
            naiveAccuracy < HabotTraceFilter.floor &&
            HabotTraceFilter.bandFor(naiveAccuracy) == 'Poor' &&
            HabotTraceFilter.groundTruthNote.contains('1.0 by construction');
      },
    );

    gate(
      'GEN-04539-G6',
      '"A filter that leaves no trace of what it removed cannot be told apart '
          'from one that removes nothing."',
      'Dropped traces are counted rather than discarded, so a rising drop rate '
          'is visible -- and it is either a finding about how the app is used '
          'or a bug in this filter, both of which are worth seeing',
      () {
        final List<HabotTraceDecision> decisions =
            filter().classifyAll(fixture());
        return HabotTraceFilter.dropRate(decisions) == 0.4 &&
            HabotTraceFilter.dropRate(const <HabotTraceDecision>[]) == 0 &&
            HabotTraceFilter.countedNotDiscardedNote
                .contains('removes nothing');
      },
    );

    gate(
      'GEN-04539-G7',
      'COLUMN NOTE: the Atomic Step is about performance traces; the metric '
          'names form field validation accuracy.',
      'The mismatch is recorded in the code with the reading taken and why, '
          'rather than the metric being ignored or a form-validation figure '
          'being invented for a step that has nothing to do with forms; the '
          'bands are the row\'s own and reach Average as well as Good and Poor',
      () =>
          HabotTraceFilter.metricMismatch.contains('nothing to do with each '
              'other') &&
          HabotTraceFilter.metricMismatch.contains('Recorded rather than') &&
          HabotTraceFilter.floor == 0.95 &&
          HabotTraceFilter.optimal == 0.99 &&
          HabotTraceFilter.ceiling == 1.0 &&
          HabotTraceFilter.bandFor(0.97) == 'Average' &&
          HabotTraceFilter.bandFor(0.90) == 'Poor' &&
          HabotTraceFilter.accuracy(
                const <HabotTraceDecision>[],
                const <HabotTraceVerdict>[],
              ) ==
              0,
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04539',
        atomicStepReferenceId: 'GEN-04539',
        setupStepAction:
            'Filter out performance trace data collected during background '
            'execution states.',
        implementationOrder: 166,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTraceFilter / HabotTraceDecision',
          'Component Properties':
              '${HabotTraceVerdict.values.length} verdicts; classification '
              'against the lifecycle transitions that occurred DURING the '
              'window and the state immediately before it, rather than against '
              'the state at capture time; drops counted by verdict',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'COLUMN NOTE RECORDED: the Atomic Step is about performance '
              'traces and the metric names Form Field Validation Accuracy. '
              'They have nothing to do with each other. The metric SHAPE -- an '
              'accuracy rate over a classification -- fits a classifier, so it '
              'is read as filter accuracy against a known-correct labelling. '
              'The reading is recorded rather than the metric being ignored.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Filter accuracy (metric read, see note)',
            observed:
                '${filterAccuracy.toStringAsFixed(2)} against a five-trace '
                'labelling built so that the correct verdict for each is known '
                'by construction. The naive classifier -- the one that trusts '
                'the foreground flag recorded at capture time -- scores '
                '${naiveAccuracy.toStringAsFixed(2)} on the identical data, '
                'keeping the trace that spans the backgrounding and carries '
                'five suspended seconds in its elapsed time.',
            floor: '0.95',
            optimal: '0.99',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Traces dropped for backgrounding',
            observed:
                '40% of the fixture set, counted by verdict rather than '
                'discarded. A rising drop rate is either a finding about how '
                'the app is used or a bug in this filter; a filter that leaves '
                'no record of what it removed cannot be told apart from one '
                'that removes nothing.',
            floor: 'counted',
            optimal: 'counted',
            ceiling: 'counted',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/trace_filter.dart',
        ],
      ),
    );
  });
}
