/// AISS GATE -- Step 467 of 1,314
/// Global Reference ID:       GEN-05056
/// Atomic Steps Reference ID: GEN-05056
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the mobile UX performance requirement: Touch drawing
///               stroke latency <16ms."
/// Metric: UI Response / Interaction Latency -- floor "<=100ms
///         perceived-instant response threshold", optimal "<=50ms (matches or
///         exceeds the stated requirement)", ceiling ">100ms begins to feel
///         laggy to users (Nielsen response-time limit)". Best Qualitative
///         Output: "Pass / Fail". Nielsen Norman Group response-time limits
///         (0.1s 'instant', 1s 'uninterrupted flow'). Assigned to **UDF**.
///
/// A BAND THAT CLAIMS IN WORDS TO MATCH ITS INSTRUCTION, AT MORE THAN THREE
/// TIMES THE NUMBER.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/capture/stroke_latency.dart';

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

  group('GEN-05056 :: an asserted agreement', () {
    gate(
      'GEN-05056-G1',
      'The optimal claims to match the stated requirement.',
      '"<=50ms (matches or exceeds the stated requirement)"',
      () => HabotStrokeLatency.theOptimalClaimsToMatch,
    );

    gate(
      'GEN-05056-G2',
      'And is more than three times looser than it.',
      '50 ms against an instruction of 16; Step 432 disagreed by five and said '
          'nothing',
      () =>
          HabotStrokeLatency.itIsMoreThanThreeTimesLooser &&
          HabotStrokeLatency.theFirstToAssertTheAgreement,
    );

  });

  group('GEN-05056 :: a frame, not a response time', () {
    gate(
      'GEN-05056-G3',
      'Sixteen milliseconds is a frame at sixty hertz.',
      'A frame budget, not a response-time band',
      () => HabotStrokeLatency.theRequirementIsAFrameBudget,
    );

    gate(
      'GEN-05056-G4',
      'So the two measurements are kept apart.',
      'The same distinction Step 455 drew between a frame and an animation',
      () =>
          HabotStrokeLatency.bothAreKept &&
          HabotStrokeLatency.theRowThatDrewThisDistinctionFirst == 455,
    );

  });

  group('GEN-05056 :: the worst frame, not the median', () {
    gate(
      'GEN-05056-G5',
      'Two strokes, nine frames, worst frame under 16 ms.',
      'Because a missed frame is seen, not felt',
      () =>
          HabotStrokeLatency.strokes.length == 2 &&
          HabotStrokeLatency.theFrameBudgetIsMet,
    );

    gate(
      'GEN-05056-G6',
      'The first mark is inside the response band.',
      'Which is what Nielsen\'s 100 ms actually measures',
      () => HabotStrokeLatency.theResponseBandIsMet,
    );

    gate(
      'GEN-05056-G7',
      'And the median is not reported alone.',
      'A median hides exactly the frame that broke the line',
      () =>
          !HabotStrokeLatency.theMedianIsReportedAlone &&
          HabotStrokeLatency.frameNote.contains('break in the line'),
    );

  });

  group('GEN-05056 :: hands on the screen', () {
    gate(
      'GEN-05056-G8',
      'Palm contact is rejected without dropping the stroke.',
      'Children draw with their hands on the screen',
      () => HabotStrokeLatency.aChildCanRestTheirHand,
    );

    gate(
      'GEN-05056-G9',
      'And pressure does not change the mark.',
      'A pressure threshold turns a drawing tool into a strength test',
      () =>
          HabotStrokeLatency.aLightTouchMakesTheSameMark &&
          HabotStrokeLatency.handsNote.contains('strength test'),
    );

    gate(
      'GEN-05056-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotStrokeLatency.obligations.length == 5 &&
          HabotStrokeLatency.obligations.values.every((bool b) => b) &&
          HabotStrokeLatency.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final double worst = HabotStrokeLatency.worstFrame;
    final double looser = HabotStrokeLatency.howManyTimesLooser;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05056',
        atomicStepReferenceId: 'GEN-05056',
        setupStepAction:
            'COLUMN NOTE: this row\'s optimal of 50 ms asserts in its own '
            'parenthesis that it matches the instruction\'s 16 ms, which is '
            'more than three times looser, making it the first row in the '
            'track whose band claims an agreement its numbers deny; 16 ms is a '
            'frame at sixty hertz rather than a response time, so the frame '
            'budget and the Nielsen band are measured separately; the worst '
            'frame in a stroke is kept rather than the median, because a '
            'missed frame is seen as a gap in the line; and palm contact is '
            'rejected without dropping the running stroke. Atomic Step: '
            '"Implement the mobile UX performance requirement: Touch drawing '
            'stroke latency <16ms."',
        implementationOrder: 467,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement the mobile UX performance requirement: Touch drawing '
          'stroke latency':
              'the frame budget measured as a frame budget at worst '
                  '${worst.toStringAsFixed(1)} ms against 16, the Nielsen band '
                  'kept separately, and the optimal recorded as '
                  '${looser.toStringAsFixed(2)} times looser than the '
                  'instruction',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Response / Interaction Latency',
            observed:
                'THE OPTIMAL ASSERTS AN AGREEMENT ITS NUMBERS DENY. The '
                'instruction says under 16 ms and the optimal says 50 ms while '
                'claiming, in its own parenthesis, to match or exceed the '
                'stated requirement: ${looser.toStringAsFixed(2)} times '
                'looser. Step 432 disagreed with its instruction by a factor '
                'of five and said nothing; this is the first row to state the '
                'agreement in words. Observed: worst frame '
                '${worst.toStringAsFixed(1)} ms.',
            floor: '<=100ms perceived-instant response threshold',
            optimal: '<=50ms (matches or exceeds the stated requirement)',
            ceiling:
                '>100ms begins to feel laggy to users (Nielsen response-time '
                    'limit)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName:
                'Strokes measured by their median rather than their worst '
                'frame',
            observed:
                '0. Sixteen milliseconds is a frame at sixty hertz, so the '
                'requirement is a frame budget: the ink has to reach the '
                'screen in the frame the finger moved in. A response-time band '
                'tolerates an occasional slow event; a drawing surface cannot, '
                'because the failure is seen as a break in the line. The worst '
                'frame in each stroke is kept, palm contact is rejected '
                'without dropping the running stroke, and a light touch makes '
                'the same mark as a heavy one.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/capture/stroke_latency.dart',
        ],
      ),
    );
  });
}
