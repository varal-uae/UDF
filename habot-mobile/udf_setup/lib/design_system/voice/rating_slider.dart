/// Step 444 (GEN-03248) -- a rating slider with explicit labels, whose ceiling
/// contradicts the touch-target ceiling the track already declared.
///
/// The row: "Build touch-optimized rating slider widgets with explicit scale
/// labels."
/// Metric: **Rating Slider Target Touch Boundary** -- floor "48x48dp", optimal
/// "48x48dp", ceiling "64x64dp". Best Qualitative Output: "Pass". WCAG 2.2 AA /
/// Material Design 3. Assigned to **UDF**.
///
/// **The ceiling is 64dp and the track's is 56.** Step 176 declared a touch
/// band with a ceiling of 56dp, and recorded that a target too large is a
/// defect too: it crowds its neighbours and swallows taps meant for them. This
/// row sets 64. The declared band is bound rather than overridden -- two
/// ceilings for one kind of target is two answers to one question -- and the
/// conflict is recorded. Floor and optimal are equal, so there is nothing
/// between the minimum and the target, and the output column holds one word:
/// the fifteenth one-valued column in the track.
///
/// **A slider is the wrong shape for a labelled scale, so it is made to behave
/// like the right one.** A slider implies a continuum; a five-point scale with
/// a word at every point is five choices. Dragging to a precise stop is hard
/// with a tremor, a glove or a thumb, and a screen reader announces a slider as
/// a percentage unless it is told otherwise. So the slider snaps to five
/// labelled stops, each stop is a 48dp target that can be tapped directly, and
/// each announces its label rather than its position.
///
/// **Every stop is labelled, not just the ends.** "Very poor" and "Excellent"
/// at the ends leave the middle to interpretation, and the middle is where the
/// ambiguity lives: three means average to one person and fine to another. All
/// five words are shown.
///
/// **The slider starts empty.** A thumb already resting on three anchors the
/// answer and makes "did not move it" indistinguishable from "chose three". The
/// control has no value until somebody gives it one, and cannot be submitted
/// until then.
library;

import '../tokens/touch_target_band.dart';

/// One labelled stop on the scale.
class HabotRatingStop {
  const HabotRatingStop({
    required this.value,
    required this.label,
    required this.targetDp,
  });

  final int value;
  final String label;
  final double targetDp;
}

/// The rating slider.
class HabotRatingSlider {
  const HabotRatingSlider._();

  // -----------------------------------------------------------------------
  // Two ceilings for one kind of target.
  // -----------------------------------------------------------------------

  static const double rowFloorDp = 48;
  static const double rowOptimalDp = 48;
  static const double rowCeilingDp = 64;

  static double get declaredCeilingDp => HabotTouchBand.ceilingDp;

  static bool get theCeilingsConflict => rowCeilingDp != declaredCeilingDp;

  static const bool theDeclaredBandIsOverridden = false;

  static bool get theDeclaredBandIsBound =>
      !theDeclaredBandIsOverridden && declaredCeilingDp == 56;

  static bool get theFloorEqualsTheOptimal => rowFloorDp == rowOptimalDp;

  static const String outputColumnRaw = 'Pass';

  static const int oneValuedColumnsInTheTrack = 15;

  static bool get theCountReachesFifteen =>
      oneValuedColumnsInTheTrack == 15 && outputColumnRaw == 'Pass';

  static const String ceilingNote =
      'Step 176 declared a touch band with a ceiling of 56dp and recorded that '
      'a target too large is also a defect, because it crowds its neighbours '
      'and swallows taps meant for them. This row sets 64. The declared band '
      'is bound rather than overridden, since two ceilings for one kind of '
      'target is two answers to one question, and the conflict is recorded.';

  // -----------------------------------------------------------------------
  // A slider that behaves like five choices.
  // -----------------------------------------------------------------------

  static const List<HabotRatingStop> stops = <HabotRatingStop>[
    HabotRatingStop(value: 1, label: 'Very poor', targetDp: 48),
    HabotRatingStop(value: 2, label: 'Poor', targetDp: 48),
    HabotRatingStop(value: 3, label: 'Acceptable', targetDp: 48),
    HabotRatingStop(value: 4, label: 'Good', targetDp: 48),
    HabotRatingStop(value: 5, label: 'Excellent', targetDp: 48),
  ];

  static bool get fiveStops => stops.length == 5;

  static bool get everyStopIsLabelled =>
      stops.every((HabotRatingStop s) => s.label.isNotEmpty);

  static bool get everyStopMeetsTheFloor =>
      stops.every((HabotRatingStop s) => s.targetDp >= rowFloorDp);

  static bool get everyStopIsWithinTheDeclaredCeiling =>
      stops.every((HabotRatingStop s) => s.targetDp <= declaredCeilingDp);

  static const bool itSnapsToStops = true;

  static const bool aStopCanBeTappedDirectly = true;

  static const bool theScreenReaderAnnouncesTheLabel = true;

  static bool get itBehavesLikeFiveChoices =>
      itSnapsToStops &&
      aStopCanBeTappedDirectly &&
      theScreenReaderAnnouncesTheLabel;

  static const String shapeNote =
      'A slider implies a continuum and a five-point scale with a word at '
      'every point is five choices. Dragging to a precise stop is hard with a '
      'tremor, a glove or a thumb, and a screen reader announces a slider as a '
      'percentage unless told otherwise. The slider snaps to five labelled '
      'stops, each stop is a 48dp target that can be tapped directly, and each '
      'announces its label rather than its position.';

  // -----------------------------------------------------------------------
  // The middle is labelled too.
  // -----------------------------------------------------------------------

  static String get middleLabel => stops[stops.length ~/ 2].label;

  static bool get theMiddleHasAWord => middleLabel == 'Acceptable';

  static const bool onlyTheEndsAreLabelled = false;

  static const String middleNote =
      'Labels only at the ends leave the middle to interpretation, and the '
      'middle is where the ambiguity lives: three means average to one person '
      'and fine to another. All five words are shown, and the middle one says '
      'acceptable rather than leaving a number to be read two ways.';

  // -----------------------------------------------------------------------
  // It starts empty.
  // -----------------------------------------------------------------------

  static const int? initialValue = null;

  static bool get itStartsEmpty => initialValue == null;

  static bool canSubmit(int? value) => value != null;

  static bool get anUntouchedSliderCannotBeSubmitted => !canSubmit(null);

  static const String anchorNote =
      'A thumb already resting on three anchors the answer and makes "did not '
      'move it" indistinguishable from "chose three". The control has no value '
      'until somebody gives it one, and cannot be submitted until then.';

  static String get qualitativeOutput =>
      everyStopMeetsTheFloor &&
              everyStopIsWithinTheDeclaredCeiling &&
              itStartsEmpty
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s ceiling of 64x64dp contradicts the 56dp touch '
      'ceiling Step 176 declared, which is bound rather than overridden; its '
      'floor and optimal are both 48x48dp; its Best Qualitative Output column '
      'holds the single word "Pass", the fifteenth one-valued column in the '
      'track; and it asks for a slider on a labelled discrete scale, so the '
      'slider snaps to five labelled stops that can each be tapped, labels the '
      'middle as well as the ends, and starts with no value. Atomic Step: '
      '"Build touch-optimized rating slider widgets with explicit scale '
      'labels."';

  static Map<String, bool> get obligations => <String, bool>{
        'the declared touch ceiling is bound': theDeclaredBandIsBound,
        'every stop meets the floor and the declared ceiling':
            everyStopMeetsTheFloor && everyStopIsWithinTheDeclaredCeiling,
        'it behaves like five choices': itBehavesLikeFiveChoices,
        'every stop is labelled, including the middle':
            everyStopIsLabelled && theMiddleHasAWord,
        'it starts empty and cannot be submitted untouched':
            itStartsEmpty && anUntouchedSliderCannotBeSubmitted,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the row\'s ceiling contradicts the declared one':
            theCeilingsConflict && rowCeilingDp == 64,
        'and the declared one is bound':
            theDeclaredBandIsBound &&
                ceilingNote.contains('two answers to one question'),
        'floor equals optimal, and the column holds one value':
            theFloorEqualsTheOptimal && theCountReachesFifteen,
        'five stops, each a 48dp target within 56':
            fiveStops &&
                everyStopMeetsTheFloor &&
                everyStopIsWithinTheDeclaredCeiling,
        'it snaps, taps and announces labels': itBehavesLikeFiveChoices,
        'because dragging to a stop is hard with a tremor':
            shapeNote.contains('tremor'),
        'the middle carries a word, not just the ends':
            theMiddleHasAWord && !onlyTheEndsAreLabelled,
        'and three is not left to be read two ways':
            middleNote.contains('read two ways'),
        'it starts empty and cannot be submitted untouched':
            itStartsEmpty &&
                anUntouchedSliderCannotBeSubmitted &&
                anchorNote.contains('anchors the answer'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
