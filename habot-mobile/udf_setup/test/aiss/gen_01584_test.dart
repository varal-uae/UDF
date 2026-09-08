/// AISS GATE -- Step 152 of 155
/// Global Reference ID:       GEN-01584
/// Atomic Steps Reference ID: GEN-01584
/// Setup Step (Action) / Atomic Step: "Implement auto-scroll focus routines
///   that center the view on the active progress node upon status changes."
/// Metric: Real-Time Status Update Latency -- Floor "<30s", Optimal "<5s",
///         Ceiling "<60s". Good / Average / Poor.
///
/// A MISMATCHED METRIC, READ HONESTLY: centring takes one 200ms transition, so
/// treating that as an answer to a five-second requirement would let a broken
/// status pipeline hide behind a fast animation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/motion/stepper_transition.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/wizard/progress_autoscroll.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  /// Twelve nodes of 24dp with 12dp gaps in a 200dp viewport: content is
  /// 420dp, so the track scrolls.
  const HabotProgressTrack track = HabotProgressTrack(
    nodeCount: 12,
    nodeExtent: 24,
    nodeSpacing: 12,
    viewportExtent: 200,
  );

  const HabotProgressTrack shortTrack = HabotProgressTrack(
    nodeCount: 3,
    nodeExtent: 24,
    nodeSpacing: 12,
    viewportExtent: 200,
  );

  group('GEN-01584 :: centring', () {
    gate(
      'GEN-01584-G1',
      'Atomic Step: "auto-scroll focus routines that CENTER the view on the '
          'active progress node".',
      'The offset that centres a node is computed from the track geometry and '
          'clamped at both ends, so the first and last nodes do not scroll the '
          'track past itself',
      () {
        // Node 6 starts at 6 * 36 = 216, centre 228; viewport 200 -> 128.
        final double middle =
            HabotProgressAutoscroll.centeredOffset(track, 6);
        final double first =
            HabotProgressAutoscroll.centeredOffset(track, 0);
        final double last = HabotProgressAutoscroll.centeredOffset(
          track,
          track.nodeCount - 1,
        );
        return middle == 128 &&
            first == 0 &&
            last == track.maxScrollExtent &&
            track.contentExtent == 420 &&
            track.maxScrollExtent == 220 &&
            !track.fitsWithoutScrolling;
      },
    );

    gate(
      'GEN-01584-G2',
      'An auto-scroll that fires on every status change moves the view while '
          'someone is reading it, which is a worse failure than not centring '
          'at all.',
      'Nothing scrolls when the whole track is already on screen, when the '
          'active node is already fully visible, or while the user has a '
          'finger on the track -- and each decision says why it was made',
      () {
        final HabotScrollDecision fits = HabotProgressAutoscroll.decide(
          track: shortTrack,
          activeIndex: 2,
          currentOffset: 0,
          userIsDragging: false,
          reducedMotion: false,
        );
        final HabotScrollDecision visible = HabotProgressAutoscroll.decide(
          track: track,
          activeIndex: 1,
          currentOffset: 0,
          userIsDragging: false,
          reducedMotion: false,
        );
        final HabotScrollDecision dragging = HabotProgressAutoscroll.decide(
          track: track,
          activeIndex: 11,
          currentOffset: 0,
          userIsDragging: true,
          reducedMotion: false,
        );
        return !fits.shouldScroll &&
            fits.reason.contains('already shows everything') &&
            !visible.shouldScroll &&
            visible.reason.contains('already fully visible') &&
            HabotProgressAutoscroll.isFullyVisible(track, 1, 0) &&
            !dragging.shouldScroll &&
            dragging.reason.contains('finger on the track') &&
            dragging.targetOffset == 0;
      },
    );

    gate(
      'GEN-01584-G3',
      'When the active node IS off screen, the view has to move -- otherwise '
          'the user cannot see which step they are on, which is the whole '
          'point.',
      'An off-screen active node produces a scroll to the centred offset over '
          'the Step 137 global transition',
      () {
        final HabotScrollDecision d = HabotProgressAutoscroll.decide(
          track: track,
          activeIndex: 9,
          currentOffset: 0,
          userIsDragging: false,
          reducedMotion: false,
        );
        return d.shouldScroll &&
            d.targetOffset ==
                HabotProgressAutoscroll.centeredOffset(track, 9) &&
            d.duration == HabotStepperTransition.duration &&
            d.duration == HabotMotion.stepperTransition &&
            !HabotProgressAutoscroll.isFullyVisible(track, 9, 0);
      },
    );

    gate(
      'GEN-01584-G4',
      'Step 146 finding F-4 and Step 137: skipping the centring under reduced '
          'motion would leave a motion-sensitive user unable to see which step '
          'they are on.',
      'Under reduced motion the ANIMATION collapses and the behaviour does '
          'not: the node still ends up centred, it simply arrives immediately',
      () {
        final HabotScrollDecision reduced = HabotProgressAutoscroll.decide(
          track: track,
          activeIndex: 9,
          currentOffset: 0,
          userIsDragging: false,
          reducedMotion: true,
        );
        return reduced.shouldScroll &&
            reduced.duration == Duration.zero &&
            reduced.targetOffset ==
                HabotProgressAutoscroll.centeredOffset(track, 9) &&
            reduced.reason.contains('reduced motion') &&
            HabotProgressAutoscroll.centringLatency(reducedMotion: true) ==
                Duration.zero &&
            HabotProgressAutoscroll.reducedMotionNote.contains(
              'not the behaviour',
            );
      },
    );
  });

  group('GEN-01584 :: the metric, read honestly', () {
    gate(
      'GEN-01584-G5',
      'Metric: Real-Time Status Update Latency -- floor <30s, optimal <5s, '
          'ceiling <60s. Centring takes 200ms.',
      'The client reports the term it owns, bands a full '
          'status-change-to-visible figure it is given, and the reading is '
          'recorded rather than 200ms being presented as an answer to a '
          'five-second requirement',
      () =>
          HabotProgressAutoscroll.centringLatency(reducedMotion: false) ==
              HabotMotion.stepperTransition &&
          HabotProgressAutoscroll.centringLatency(reducedMotion: false) <
              HabotMotion.statusUpdateOptimal &&
          HabotProgressAutoscroll.bandFor(const Duration(seconds: 3)) ==
              'Good' &&
          HabotProgressAutoscroll.bandFor(const Duration(seconds: 20)) ==
              'Average' &&
          HabotProgressAutoscroll.bandFor(const Duration(seconds: 45)) ==
              'Average' &&
          HabotProgressAutoscroll.bandFor(const Duration(seconds: 90)) ==
              'Poor' &&
          HabotProgressAutoscroll.withinCeiling(
            HabotMotion.statusUpdateCeiling,
          ) &&
          !HabotProgressAutoscroll.withinCeiling(const Duration(seconds: 61)),
    );

    gate(
      'GEN-01584-G6',
      'Treating a fast animation as the answer to a slow requirement is how a '
          'broken status pipeline goes unnoticed.',
      'The reading taken is recorded in the code, naming which term this step '
          'owns and which it does not',
      () =>
          HabotProgressAutoscroll.metricReadingNote.contains(
            'reporting the wrong thing well',
          ) &&
          HabotProgressAutoscroll.metricReadingNote.contains(
            'hide behind a fast animation',
          ) &&
          HabotProgressAutoscroll.doesNotFightTheUserNote.contains(
            'while someone is reading it',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01584',
        atomicStepReferenceId: 'GEN-01584',
        setupStepAction:
            'Implement auto-scroll focus routines that center the view on the '
            'active progress node upon status changes.',
        implementationOrder: 152,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotProgressAutoscroll / HabotProgressTrack / '
              'HabotScrollDecision',
          'Component Properties':
              'centred offset clamped to the track; three declared reasons not '
              'to scroll; animation collapses under reduced motion while the '
              'centring still happens',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The metric is a status-feed latency in '
              'seconds on a scroll animation; the reading is in '
              'HabotProgressAutoscroll.metricReadingNote.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Real-Time Status Update Latency (centring term only)',
            observed:
                '${HabotMotion.stepperTransition.inMilliseconds}ms from the '
                'active node changing to the view having centred on it, and '
                'zero under reduced motion. This is ONE TERM of the figure the '
                'row bounds; the other is how long the status took to arrive, '
                'which Steps 121-128 own. Presenting 200ms as an answer to a '
                'five-second requirement would let a broken status pipeline '
                'hide behind a fast animation.',
            floor: '<30s',
            optimal: '<5s',
            ceiling: '<60s',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Scrolls that move the view under the user',
            observed:
                '0. Nothing scrolls when the track already fits, when the '
                'active node is already fully visible, or while a finger is on '
                'the track -- and each decision carries the reason it was '
                'made, so a decision NOT to scroll is evidence rather than '
                'absence.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/wizard/progress_autoscroll.dart',
        ],
      ),
    );
  });
}
