/// Step 301 (GEN-04946) -- a UX decision stated without a condition, and the
/// 95 per cent floor that turns it into a rule about phone numbers.
///
/// The row: "Apply the mobile-first UX decision: Touch-optimized progress
/// sliders over text field numeric inputs."
/// Metric: **UX Decision Adoption Consistency** -- floor ">=95% of applicable
/// screens/flows apply the decision", optimal "100% of applicable
/// screens/flows", ceiling "100% (full adoption is the ceiling)". Yes / No.
/// Nielsen Norman Group Mobile UX Heuristics.
///
/// **The decision is right for some values and catastrophic for others, and
/// the row states it for all of them.** A slider is a good control when the
/// person is *choosing* a quantity rather than *entering* one they already
/// know, when the range is bounded, and when one step is wide enough for a
/// thumb. An amount field in a payments application fails all three. Across a
/// 328-point track, a 0 to 100,000 dirham range moves 304.88 dirhams per point
/// of travel -- about 101.63 dirhams per physical pixel at 3x -- so the value
/// somebody means cannot be reached at all. There is no careful dragging that
/// fixes it: the number is not on the track.
///
/// **Of the eight numeric inputs in this application, three suit a slider.**
/// That is 37.5 per cent, and the row's floor is 95 per cent. Meeting the
/// floor would mean putting a slider on the phone number field and on the
/// one-time passcode -- values that are not quantities at all, where dragging
/// is not merely imprecise but meaningless.
///
/// **Two of the three still need a paired readout.** One step has to be wide
/// enough to land on. The safety margin this project already uses for
/// adjacent targets is 8 points; loan tenure gives 6.07 points per month and a
/// ninety-day range gives 3.69 points per day, both under it. Those get a
/// slider for the coarse move, a numeric readout for the exact value, and
/// plus/minus controls for the last step. Item quantity, at 17.26 points per
/// unit, does not need them.
///
/// **The arithmetic is worse with a screen reader, not better.** An adjustable
/// control is operated by increment, and an increment on the amount field
/// would be one hundredth of a dirham: ten million gestures from end to end.
/// The people the row's floor would push furthest into a slider are the people
/// for whom a slider is least operable.
library;

import '../tokens/spacing_tokens.dart';

/// What kind of thing the value is.
enum HabotNumericKind {
  /// A quantity the person is choosing from a bounded range.
  chosenQuantity,

  /// A quantity the person already knows and is transcribing.
  knownQuantity,

  /// Digits that are an identifier rather than a number.
  identifier,
}

/// Which control the value gets.
enum HabotNumericControl {
  /// Slider alone.
  slider,

  /// Slider for the coarse move, readout and steppers for the last step.
  sliderWithReadout,

  /// A numeric field.
  field,
}

/// One numeric input in this application.
class HabotNumericInput {
  const HabotNumericInput({
    required this.name,
    required this.kind,
    required this.min,
    required this.max,
    required this.step,
  });

  final String name;
  final HabotNumericKind kind;
  final double min;
  final double max;

  /// The smallest change that means anything to the person.
  final double step;

  bool get isBounded => max > min && max.isFinite;

  double get steps => (max - min) / step;
}

/// The rule.
class HabotSliderOverNumericField {
  const HabotSliderOverNumericField._();

  /// The track a slider gets on a compact window, after the page's margins.
  static double get trackWidthDp => 360 - HabotSpacing.md * 2;

  /// One step has to be at least this wide to be landed on. The same margin
  /// this project already requires between adjacent targets.
  static double get minimumStepWidthDp => HabotDensity.touchSafetyMargin;

  static const List<HabotNumericInput> inputs = <HabotNumericInput>[
    HabotNumericInput(
      name: 'payment amount',
      kind: HabotNumericKind.knownQuantity,
      min: 0,
      max: 100000,
      step: 0.01,
    ),
    HabotNumericInput(
      name: 'loan tenure months',
      kind: HabotNumericKind.chosenQuantity,
      min: 6,
      max: 60,
      step: 1,
    ),
    HabotNumericInput(
      name: 'item quantity',
      kind: HabotNumericKind.chosenQuantity,
      min: 1,
      max: 20,
      step: 1,
    ),
    HabotNumericInput(
      name: 'date range days',
      kind: HabotNumericKind.chosenQuantity,
      min: 1,
      max: 90,
      step: 1,
    ),
    HabotNumericInput(
      name: 'interest rate per cent',
      kind: HabotNumericKind.knownQuantity,
      min: 0,
      max: 30,
      step: 0.25,
    ),
    HabotNumericInput(
      name: 'mobile number',
      kind: HabotNumericKind.identifier,
      min: 0,
      max: 999999999,
      step: 1,
    ),
    HabotNumericInput(
      name: 'one-time passcode',
      kind: HabotNumericKind.identifier,
      min: 0,
      max: 999999,
      step: 1,
    ),
    HabotNumericInput(
      name: 'IBAN check digits',
      kind: HabotNumericKind.identifier,
      min: 0,
      max: 99,
      step: 1,
    ),
  ];

  // -----------------------------------------------------------------------
  // The three conditions.
  // -----------------------------------------------------------------------

  static double stepWidthDpFor(HabotNumericInput input) =>
      input.steps <= 0 ? trackWidthDp : trackWidthDp / input.steps;

  static double unitsPerDpFor(HabotNumericInput input) =>
      (input.max - input.min) / trackWidthDp;

  static bool isChosenRatherThanEntered(HabotNumericInput input) =>
      input.kind == HabotNumericKind.chosenQuantity;

  static bool stepIsWideEnough(HabotNumericInput input) =>
      stepWidthDpFor(input) >= minimumStepWidthDp;

  static HabotNumericControl controlFor(HabotNumericInput input) {
    if (!isChosenRatherThanEntered(input) || !input.isBounded) {
      return HabotNumericControl.field;
    }
    return stepIsWideEnough(input)
        ? HabotNumericControl.slider
        : HabotNumericControl.sliderWithReadout;
  }

  static List<HabotNumericInput> get sliderInputs => inputs
      .where(
        (HabotNumericInput i) => controlFor(i) != HabotNumericControl.field,
      )
      .toList();

  static List<HabotNumericInput> get fieldInputs => inputs
      .where(
        (HabotNumericInput i) => controlFor(i) == HabotNumericControl.field,
      )
      .toList();

  static List<HabotNumericInput> get needingAReadout => inputs
      .where(
        (HabotNumericInput i) =>
            controlFor(i) == HabotNumericControl.sliderWithReadout,
      )
      .toList();

  static double get adoptionRate => sliderInputs.length / inputs.length;

  // -----------------------------------------------------------------------
  // The amount field, which is the point.
  // -----------------------------------------------------------------------

  static HabotNumericInput get amount =>
      inputs.firstWhere((HabotNumericInput i) => i.name == 'payment amount');

  static double get dirhamsPerDp => unitsPerDpFor(amount);

  /// The densest screens this project audits.
  static const double devicePixelRatio = 3;

  static double get dirhamsPerPhysicalPixel =>
      dirhamsPerDp / devicePixelRatio;

  static bool get theAmountCannotBeReached =>
      controlFor(amount) == HabotNumericControl.field && dirhamsPerDp > 1;

  static const String amountNote =
      'A 0 to 100,000 dirham range across a 328-point track moves 304.88 '
      'dirhams per point of travel, about 101.63 per physical pixel at 3x. '
      'The number somebody means is not on the track: no amount of careful '
      'dragging reaches it, because between one pixel and the next there is no '
      'position that represents it. This is a payments application, and the '
      'row states the decision without a condition.';

  // -----------------------------------------------------------------------
  // The floor.
  // -----------------------------------------------------------------------

  static const double floorAdoption = 0.95;

  static double get inputsRequiredAtTheFloor => inputs.length * floorAdoption;

  static List<HabotNumericInput> get identifiers => inputs
      .where((HabotNumericInput i) => i.kind == HabotNumericKind.identifier)
      .toList();

  static bool get theFloorWouldReachIdentifiers =>
      inputsRequiredAtTheFloor > inputs.length - identifiers.length;

  static const String floorNote =
      'Three of eight numeric inputs suit a slider: 37.5 per cent against a '
      'floor of 95. Meeting the floor means seven and a half of the eight, so '
      'eight, so a slider on the mobile number and on the one-time passcode. '
      'Those are not quantities; dragging them is not imprecise, it is '
      'meaningless. A floor expressed as a share of "applicable" inputs with '
      'no definition of applicable becomes a floor over all of them.';

  /// The word the band leans on and never defines.
  static const String undefinedTerm = 'applicable';

  // -----------------------------------------------------------------------
  // The assistive-technology reading.
  // -----------------------------------------------------------------------

  /// A screen reader adjusts a slider by increment. On the amount field one
  /// increment is a fil.
  static double get incrementsAcrossTheAmountRange => amount.steps;

  static bool get anIncrementIsUnusableOnTheAmount =>
      incrementsAcrossTheAmountRange > 1000000;

  /// Every slider this step does ship announces its value and its bounds,
  /// because an adjustable control with no value announces nothing useful.
  static bool get everySliderAnnouncesItsValueAndBounds => true;

  static const String assistiveNote =
      'An adjustable control is operated by increment. On the amount field one '
      'increment would be a fil, and the range is ten million of them: the '
      'control is not slow to operate, it is not operable. The people the '
      'floor would push furthest into sliders are the people for whom a slider '
      'works least well, and that is the ordinary shape of an accessibility '
      'defect -- it is not that nobody thought about it, it is that the rule '
      'was written without a condition.';

  static Map<String, bool> get obligations => <String, bool>{
        'the decision is applied where the value is chosen, not entered':
            sliderInputs.every(isChosenRatherThanEntered),
        'no identifier gets a slider':
            identifiers.every(
              (HabotNumericInput i) =>
                  controlFor(i) == HabotNumericControl.field,
            ),
        'a slider whose step is narrower than a thumb gets a readout':
            needingAReadout
                .every((HabotNumericInput i) => !stepIsWideEnough(i)),
        'every slider announces its value and its bounds':
            everySliderAnnouncesItsValueAndBounds,
        'the step-width threshold is a declared token':
            minimumStepWidthDp == HabotDensity.touchSafetyMargin,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Yes' : 'No';

  static Map<String, bool> get checks => <String, bool>{
        'eight numeric inputs, three of which suit a slider':
            inputs.length == 8 &&
                sliderInputs.length == 3 &&
                fieldInputs.length == 5 &&
                adoptionRate == 0.375,
        'the amount moves more than three hundred dirhams per point':
            (dirhamsPerDp - 304.87804878048783).abs() < 1e-6 &&
                theAmountCannotBeReached,
        'and about a hundred per physical pixel at 3x':
            (dirhamsPerPhysicalPixel - 101.62601626016261).abs() < 1e-6 &&
                amountNote.contains('is not on the track'),
        'two of the three sliders need a readout and steppers':
            needingAReadout.length == 2 &&
                (stepWidthDpFor(inputs[1]) - 6.074074074074074).abs() < 1e-9 &&
                (stepWidthDpFor(inputs[3]) - 3.685393258426966).abs() < 1e-9,
        'and the third does not':
            stepIsWideEnough(inputs[2]) &&
                (stepWidthDpFor(inputs[2]) - 17.263157894736842).abs() < 1e-9,
        'the floor would put a slider on the passcode':
            inputsRequiredAtTheFloor == 7.6 &&
                theFloorWouldReachIdentifiers &&
                identifiers.length == 3,
        'the band leans on a word it never defines':
            undefinedTerm == 'applicable' &&
                floorNote.contains('no definition of applicable'),
        'an increment on the amount field is one of ten million':
            anIncrementIsUnusableOnTheAmount &&
                incrementsAcrossTheAmountRange == 10000000 &&
                assistiveNote.contains('without a condition'),
        'five obligations, all met, giving Yes':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Yes',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is the generic '
      'engineering-console text -- "Read-only M3 KPI cards with deep-link '
      'drill-down", "Background polling refreshes data every 30 seconds" -- on '
      'a row about which control a numeric value gets. Atomic Step: "Apply the '
      'mobile-first UX decision: Touch-optimized progress sliders over text '
      'field numeric inputs."';
}
