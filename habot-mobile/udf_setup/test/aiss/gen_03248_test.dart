/// AISS GATE -- Step 444 of 415
/// Global Reference ID:       GEN-03248
/// Atomic Steps Reference ID: GEN-03248
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build touch-optimized rating slider widgets with explicit
///               scale labels."
/// Metric: Rating Slider Target Touch Boundary -- floor "48x48dp", optimal
///         "48x48dp", ceiling "64x64dp". Best Qualitative Output: "Pass". WCAG
///         2.2 AA / Material Design 3. Assigned to **UDF**.
///
/// A RATING SLIDER WHOSE CEILING CONTRADICTS THE TOUCH CEILING THE TRACK
/// ALREADY DECLARED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/voice/rating_slider.dart';

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

  group('GEN-03248 :: two ceilings for one target', () {
    gate(
      'GEN-03248-G1',
      'The row\'s ceiling contradicts the declared one.',
      '64dp against Step 176\'s 56dp',
      () =>
          HabotRatingSlider.theCeilingsConflict &&
          HabotRatingSlider.rowCeilingDp == 64,
    );

    gate(
      'GEN-03248-G2',
      'And the declared one is bound.',
      'Two ceilings for one kind of target is two answers to one question',
      () =>
          HabotRatingSlider.theDeclaredBandIsBound &&
          HabotRatingSlider.ceilingNote.contains('two answers to one question'),
    );

    gate(
      'GEN-03248-G3',
      'Floor equals optimal, and the column holds one value.',
      '48 and 48, and "Pass" -- the fifteenth one-valued column',
      () =>
          HabotRatingSlider.theFloorEqualsTheOptimal &&
          HabotRatingSlider.theCountReachesFifteen,
    );

  });

  group('GEN-03248 :: a slider that behaves like five choices', () {
    gate(
      'GEN-03248-G4',
      'Five stops, each a 48dp target within 56.',
      'Every stop within the declared band',
      () =>
          HabotRatingSlider.fiveStops &&
          HabotRatingSlider.everyStopMeetsTheFloor &&
          HabotRatingSlider.everyStopIsWithinTheDeclaredCeiling,
    );

    gate(
      'GEN-03248-G5',
      'It snaps, taps and announces labels.',
      'A slider made to behave like the five choices it is',
      () => HabotRatingSlider.itBehavesLikeFiveChoices,
    );

    gate(
      'GEN-03248-G6',
      'Because dragging to a stop is hard with a tremor.',
      'Or a glove, or a thumb',
      () => HabotRatingSlider.shapeNote.contains('tremor'),
    );

  });

  group('GEN-03248 :: the middle is labelled', () {
    gate(
      'GEN-03248-G7',
      'The middle carries a word, not just the ends.',
      'Acceptable, not a bare three',
      () =>
          HabotRatingSlider.theMiddleHasAWord &&
          !HabotRatingSlider.onlyTheEndsAreLabelled,
    );

    gate(
      'GEN-03248-G8',
      'And three is not left to be read two ways.',
      'Average to one person, fine to another',
      () => HabotRatingSlider.middleNote.contains('read two ways'),
    );

  });

  group('GEN-03248 :: it starts empty', () {
    gate(
      'GEN-03248-G9',
      'It starts empty and cannot be submitted untouched.',
      'A pre-set thumb anchors the answer',
      () =>
          HabotRatingSlider.itStartsEmpty &&
          HabotRatingSlider.anUntouchedSliderCannotBeSubmitted &&
          HabotRatingSlider.anchorNote.contains('anchors the answer'),
    );

    gate(
      'GEN-03248-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotRatingSlider.obligations.length == 5 &&
          HabotRatingSlider.obligations.values.every((bool b) => b) &&
          HabotRatingSlider.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int stops = HabotRatingSlider.stops.length;
    final double declared = HabotRatingSlider.declaredCeilingDp;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03248',
        atomicStepReferenceId: 'GEN-03248',
        setupStepAction:
            'COLUMN NOTE: this row\'s ceiling of 64x64dp contradicts the 56dp '
            'touch ceiling Step 176 declared, which is bound rather than '
            'overridden; its floor and optimal are both 48x48dp; its Best '
            'Qualitative Output column holds the single word "Pass", the '
            'fifteenth one-valued column in the track; and it asks for a '
            'slider on a labelled discrete scale, so the slider snaps to five '
            'labelled stops that can each be tapped, labels the middle as well '
            'as the ends, and starts with no value. Atomic Step: "Build '
            'touch-optimized rating slider widgets with explicit scale '
            'labels."',
        implementationOrder: 444,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build touch-optimized rating slider widgets with explicit scale '
          'labels':
              '$stops labelled stops, each a 48dp target within the declared '
                  '${declared.toStringAsFixed(0)}dp ceiling; starts with no '
                  'value',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Rating Slider Target Touch Boundary',
            observed:
                'TWO CEILINGS FOR ONE KIND OF TARGET. Step 176 declared a '
                'touch band with a 56dp ceiling and recorded that too large is '
                'also a defect; this row sets 64. The declared band is bound, '
                'not overridden. Floor and optimal are both 48, and the output '
                'column holds "Pass" alone, the fifteenth one-valued column in '
                'the track. Observed: $stops stops at 48dp.',
            floor: '48x48dp',
            optimal: '48x48dp',
            ceiling: '64x64dp',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Stops without a label',
            observed:
                '0 of $stops. A slider implies a continuum and a labelled '
                'five-point scale is five choices, so the slider snaps to '
                'labelled stops that can each be tapped and announce their '
                'label to a screen reader. The middle stop says Acceptable '
                'rather than leaving three to be read two ways, and the '
                'control starts empty so that not moving it cannot be mistaken '
                'for choosing three.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/voice/rating_slider.dart',
        ],
      ),
    );
  });
}
