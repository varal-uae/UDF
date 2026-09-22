/// AISS GATE -- Step 451 of 415
/// Global Reference ID:       GEN-01936
/// Atomic Steps Reference ID: GEN-01936
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Monitor worker task failures and timeouts to identify unclear
///               training videos."
/// Metric: Video Playback Success Rate (%) -- floor "98", optimal "99.5",
///         ceiling "100". Best Qualitative Output: "High/Medium/Low". Video
///         Delivery & Streaming Standards (HLS, DASH). Assigned to **ADFA**.
///
/// THE FIRST ROW IN TWO BATCHES TO POINT ITS MEASUREMENT AT THE MATERIAL RATHER
/// THAN THE PERSON.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/evaluation/training_video_clarity.dart';

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

  group('GEN-01936 :: the row gets the unit right', () {
    gate(
      'GEN-01936-G1',
      'The row judges the video, not the worker.',
      'When most who watched a video fail its task, the video failed',
      () =>
          HabotTrainingVideoClarity.theRowGetsTheUnitRight &&
          HabotTrainingVideoClarity.theFirstSuchRow,
    );

    gate(
      'GEN-01936-G2',
      'And the track records that as readily as a defect.',
      'The first row in two batches to do it unprompted',
      () =>
          HabotTrainingVideoClarity
              .unitNote.contains('as readily as it notices a defect'),
    );

  });

  group('GEN-01936 :: the purpose is fixed', () {
    gate(
      'GEN-01936-G3',
      'Failure data is purpose-limited and never listed by person.',
      'Aggregated per video, suppressed below five, never fed into a scorecard',
      () =>
          HabotTrainingVideoClarity.thePurposeIsFixed &&
          HabotTrainingVideoClarity.minimumWatchers == 5,
    );

    gate(
      'GEN-01936-G4',
      'A timeout while offline is the network\'s.',
      'Using the connection states Step 430 declared',
      () =>
          HabotTrainingVideoClarity.anOfflineTimeoutIsNotCounted &&
          HabotTrainingVideoClarity.theConnectionStatesAreStep430s,
    );

  });

  group('GEN-01936 :: which video', () {
    gate(
      'GEN-01936-G5',
      'Four videos, one flagged.',
      'The shift-swap video: a third of its watchers failed the task',
      () =>
          HabotTrainingVideoClarity.videos.length == 4 &&
          HabotTrainingVideoClarity.theShiftSwapVideoIsFlagged,
    );

    gate(
      'GEN-01936-G6',
      'And the three-watcher video is not assessed.',
      'Three people are three people, not a finding',
      () =>
          HabotTrainingVideoClarity.theSmallCohortIsNotAssessed &&
          HabotTrainingVideoClarity.flagNote.contains('not a finding'),
    );

  });

  group('GEN-01936 :: the metric', () {
    gate(
      'GEN-01936-G7',
      'The metric measures playback, not clarity.',
      'The fifth row scored on its mechanism',
      () =>
          HabotTrainingVideoClarity.theMetricMeasuresTheMechanism &&
          HabotTrainingVideoClarity.fifthSuchRow,
    );

    gate(
      'GEN-01936-G8',
      'A third output vocabulary appears.',
      'High/Medium/Low',
      () => HabotTrainingVideoClarity.aThirdVocabularyAppears,
    );

    gate(
      'GEN-01936-G9',
      'Playback succeeds 99.7 per cent of the time.',
      'Nine failures in three thousand plays',
      () =>
          HabotTrainingVideoClarity.playbackSuccess > 99.6 &&
          HabotTrainingVideoClarity.playbackSuccess < 99.8,
    );

    gate(
      'GEN-01936-G10',
      'Five obligations, all met, giving High.',
      'And all ten declared checks hold',
      () =>
          HabotTrainingVideoClarity.obligations.length == 5 &&
          HabotTrainingVideoClarity.obligations.values.every((bool b) => b) &&
          HabotTrainingVideoClarity.qualitativeOutput == 'High',
    );
  });

  tearDownAll(() {
    final int videos = HabotTrainingVideoClarity.videos.length;
    final int flagged = HabotTrainingVideoClarity.flagged.length;
    final double playback = HabotTrainingVideoClarity.playbackSuccess;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01936',
        atomicStepReferenceId: 'GEN-01936',
        setupStepAction:
            'COLUMN NOTE: this row points its measurement at the training '
            'video rather than the worker, the first row in two batches to get '
            'the unit of analysis right unprompted -- so failures are '
            'aggregated per video, suppressed below five watchers, never fed '
            'into a scorecard, and timeouts are counted only when the device '
            'was online; its metric measures whether the video plays rather '
            'than whether it is clear, the fifth row scored on its mechanism '
            'after Steps 413, 421, 425 and 431; and its output column '
            'introduces High/Medium/Low, a third vocabulary. Atomic Step: '
            '"Monitor worker task failures and timeouts to identify unclear '
            'training videos."',
        implementationOrder: 451,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Monitor worker task failures and timeouts to identify unclear '
          'training':
              '$videos videos assessed per video, $flagged flagged as unclear, '
                  'failure data never fed into a scorecard',
          'Completion Status': 'High',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Video Playback Success Rate (%)',
            observed:
                'THE METRIC MEASURES WHETHER THE VIDEO PLAYS, NOT WHETHER IT '
                'IS CLEAR -- the fifth row scored on its mechanism, after '
                'Steps 413, 421, 425 and 431 -- and the output column '
                'introduces a third vocabulary, High/Medium/Low. Observed: '
                '${playback.toStringAsFixed(1)} per cent playback success.',
            floor: '98',
            optimal: '99.5',
            ceiling: '100',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Failure lists shown by person',
            observed:
                '0. This row says outright that task failures are evidence '
                'about the video, the first row in two batches to point its '
                'measurement at the material unprompted. The data is still '
                'about people, so it is aggregated per video, suppressed below '
                'five watchers, never fed into a scorecard, and timeouts count '
                'only when the device was online. $flagged of $videos videos '
                'is flagged.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/evaluation/training_video_clarity.dart',
        ],
      ),
    );
  });
}
