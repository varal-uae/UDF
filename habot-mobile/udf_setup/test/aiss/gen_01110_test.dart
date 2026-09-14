/// AISS GATE -- Step 196 of 215
/// Global Reference ID:       GEN-01110
/// Atomic Steps Reference ID: GEN-01110
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement device local storage flags (FRE_Completed) to track
///               carousel completion."
/// Metric: First-Run Experience Completion Rate -- Floor 0.7, Optimal 0.9,
///         Ceiling 1. Good/Average/Poor.
///
/// THE ROW ASKS FOR A BOOLEAN AND THE METRIC ASKS FOR A RATE THE BOOLEAN
/// CANNOT PRODUCE. FRE_Completed is written on completion and on skip, because
/// both need the carousel to stay gone. Once they write the same value the
/// completion rate is 1.0 for every install past the first screen.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/onboarding/fre_completion_flag.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double rate = 0;
  double naive = 0;

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

  void asyncGate(
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

  final DateTime t0 = DateTime.utc(2026, 9, 14, 8);

  HabotFreState state(HabotFreOutcome? outcome, int slide, {int version = 1}) =>
      HabotFreState(
        outcome: outcome,
        furthestSlide: slide,
        slideCount: 4,
        carouselVersion: version,
        recordedAt: t0,
      );

  /// Ten installs: four finished, three skipped, two walked away part-way,
  /// one never ended.
  List<HabotFreState> population() => <HabotFreState>[
        state(HabotFreOutcome.completed, 3),
        state(HabotFreOutcome.completed, 3),
        state(HabotFreOutcome.completed, 3),
        state(HabotFreOutcome.completed, 3),
        state(HabotFreOutcome.skipped, 0),
        state(HabotFreOutcome.skipped, 1),
        state(HabotFreOutcome.skipped, 0),
        state(HabotFreOutcome.abandoned, 1),
        state(HabotFreOutcome.abandoned, 2),
        state(null, 0),
      ];

  group('GEN-01110 :: the boolean and the rate', () {
    gate(
      'GEN-01110-G1',
      'Atomic Step: "device local storage flags (FRE_Completed)". Metric: '
          'First-Run Experience Completion Rate.',
      'The stored boolean is derived from an outcome rather than stored, so '
          'skipping and completing both settle the carousel while remaining '
          'distinguishable -- which is the only way the rate the metric names '
          'can be computed at all',
      () {
        final HabotFreState completed = state(HabotFreOutcome.completed, 3);
        final HabotFreState skipped = state(HabotFreOutcome.skipped, 0);
        final HabotFreState abandoned = state(HabotFreOutcome.abandoned, 1);
        return completed.isSettled &&
            skipped.isSettled &&
            !abandoned.isSettled &&
            completed.outcome != skipped.outcome &&
            HabotFreOutcome.values.length == 3 &&
            HabotFreFlag.booleanCannotProduceARateNote
                .contains('the one number the metric can never be');
      },
    );

    gate(
      'GEN-01110-G2',
      '"The completion rate is 1.0 for every install that got past the first '
          'screen."',
      'Over the same ten installs the outcome-based rate is 0.4 and the '
          'single-boolean rate is 0.7 -- so the defect is a measured '
          'difference rather than an assertion, and the boolean flatters by '
          'thirty points',
      () {
        rate = HabotFreFlag.completionRate(population());
        naive = HabotFreFlag.naiveBooleanRate(population());
        return rate == 0.4 &&
            naive == 0.7 &&
            naive > rate &&
            HabotFreFlag.qualitativeOutput(rate) == 'Poor' &&
            HabotFreFlag.qualitativeOutput(naive) == 'Average';
      },
    );

    gate(
      'GEN-01110-G3',
      '"An install that opened slide one and never came back is the failure '
          'this rate is for."',
      'Abandonment is counted against the rate and is located: the drop-off '
          'histogram names the slides people stop on, over the unfinished '
          'states only',
      () {
        final Map<int, int> drop =
            HabotFreFlag.dropOffHistogram(population());
        return drop[0] == 3 &&
            drop[1] == 2 &&
            drop[2] == 1 &&
            !drop.containsKey(3) &&
            drop.values.fold(0, (int a, int b) => a + b) == 6;
      },
    );
  });

  group('GEN-01110 :: what a device flag can and cannot do', () {
    gate(
      'GEN-01110-G4',
      'The flag decides whether the carousel is shown.',
      'A settled state for the current carousel suppresses it; an abandoned '
          'one does not, because the parent never reached the end and has not '
          'seen what the carousel was for',
      () {
        final HabotFreFlag flag = HabotFreFlag(store: HabotMemoryStore());
        return flag.shouldShowCarousel(null) &&
            !flag.shouldShowCarousel(state(HabotFreOutcome.completed, 3)) &&
            !flag.shouldShowCarousel(state(HabotFreOutcome.skipped, 0)) &&
            flag.shouldShowCarousel(state(HabotFreOutcome.abandoned, 1));
      },
    );

    gate(
      'GEN-01110-G5',
      '"A redesigned carousel would ship only to new installs."',
      'A state written against an older carousel version does not settle a '
          'newer one, so a redesigned first-run experience reaches the '
          'existing users who most need re-onboarding',
      () {
        final HabotFreFlag v2 =
            HabotFreFlag(store: HabotMemoryStore(), carouselVersion: 2);
        return v2.shouldShowCarousel(
              state(HabotFreOutcome.completed, 3),
            ) &&
            !v2.shouldShowCarousel(
              state(HabotFreOutcome.completed, 3, version: 2),
            ) &&
            HabotFreFlag.versionNote.contains('existing users');
      },
    );

    asyncGate(
      'GEN-01110-G6',
      'The state has to survive a write and a read, and the boundary of a '
          'device-local flag has to be recorded rather than assumed away.',
      'Progress written mid-carousel round-trips through the store with the '
          'furthest slide preserved, progress never goes backwards, and the '
          'store used here declares itself non-durable',
      () async {
        final HabotMemoryStore store = HabotMemoryStore();
        final HabotFreFlag flag = HabotFreFlag(store: store);
        await flag.recordProgress(slideIndex: 2, slideCount: 4, now: t0);
        await flag.recordProgress(slideIndex: 1, slideCount: 4, now: t0);
        final HabotFreState? read = await flag.read();
        return read != null &&
            read.furthestSlide == 2 &&
            read.slideCount == 4 &&
            read.outcome == null &&
            read.progress == 0.75 &&
            !store.isDurable &&
            HabotFreFlag.perInstallNote.contains('per install');
      },
    );

    asyncGate(
      'GEN-01110-G7',
      'Metric: First-Run Experience Completion Rate -- floor 0.7, optimal 0.9.',
      'Settling the carousel writes the outcome and the slide it ended on, '
          'and the reported figure is the outcome-based rate rather than the '
          'flattering one -- 0.4 against a floor of 0.7, reported as Poor',
      () async {
        final HabotFreFlag flag = HabotFreFlag(store: HabotMemoryStore());
        await flag.settle(
          outcome: HabotFreOutcome.skipped,
          slideIndex: 1,
          slideCount: 4,
          now: t0,
        );
        final HabotFreState? read = await flag.read();
        return read?.outcome == HabotFreOutcome.skipped &&
            read!.isSettled &&
            rate < HabotFreFlag.floor &&
            HabotFreFlag.rowFieldName == 'FRE_Completed' &&
            HabotFreFlag.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01110',
        atomicStepReferenceId: 'GEN-01110',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement device local storage flags (FRE_Completed) to '
            'track carousel completion."',
        implementationOrder: 196,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFreFlag / HabotFreState',
          'Component Properties':
              '${HabotFreOutcome.values.length} outcomes recorded per install '
              'with the furthest slide and the slide count; the boolean the '
              'row names is derived from the outcome; carousel version stored '
              'so a redesign is not suppressed by an old flag; collection '
              '"${HabotFreFlag.collection.name}", key '
              '"${HabotFreFlag.key}"',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the row asks for a boolean and the metric on the same '
              'row asks for a rate that boolean cannot produce. FRE_Completed '
              'is written when the carousel finishes AND when it is skipped, '
              'because both need it to stay gone; once those write the same '
              'value the completion rate is 1.0 for every install past the '
              'first screen. Measured on the same ten installs: 0.4 by '
              'outcome, 0.7 by boolean -- thirty points of flattery, in the '
              'direction nobody checks. The outcome is stored and the boolean '
              'derived. BOUNDARY RECORDED: a device-local flag is per install '
              'and not per account, so reinstalling shows the carousel to '
              'someone who has seen it; Step 197 carries the account-side '
              'suppression that the flag cannot provide. HabotMemoryStore '
              'declares isDurable false, so the round trip tested here is the '
              'codec rather than persistence.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'First-Run Experience Completion Rate',
            observed:
                '${rate.toStringAsFixed(2)} over ten constructed installs: '
                'four completed, three skipped, three unfinished. Reported as '
                '"${HabotFreFlag.qualitativeOutput(0.4)}" against a floor of '
                '0.7.',
            floor: '0.7',
            optimal: '0.9',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Rate a single FRE_Completed boolean would report',
            observed:
                '${naive.toStringAsFixed(2)} on the identical population -- '
                'every settled install counted as a completion. Thirty points '
                'above the real figure, and it would have been reported as '
                '"Average" rather than "Poor".',
            floor: '0.7',
            optimal: '0.9',
            ceiling: '1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/onboarding/fre_completion_flag.dart',
        ],
      ),
    );
  });
}
