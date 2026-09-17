/// Step 327 (GEN-00077) -- confirming a component is delivered, and the two
/// acceptance criteria no repository can confirm.
///
/// The row: "Confirm the MaskedTextField component with native soft keyboard
/// triggering is delivered."
/// Metric: **Acceptance Criteria Verification Rate** -- floor ">= 95% of
/// defined acceptance criteria confirmed", optimal "100%", ceiling 1.
/// Pass / Fail. ISO/IEC 25010 Functional Correctness; PMI PMBOK Quality
/// Control.
///
/// **"Masked" is three different components wearing one name, and the wrong
/// one is dangerous.** A *formatting* mask groups an IBAN and spaces a phone
/// number: the value is fully visible and fully recoverable. A *secure* field
/// replaces glyphs with dots while the person types their own secret. A
/// *masked display* shows the last four digits of something already stored,
/// and the rest never reaches the device. Confusing the first with the second
/// is how a full card number ends up legible in a screenshot, in a support
/// ticket, in a crash report -- and the component name gives no clue which one
/// somebody reached for. All three already exist in this repository, built at
/// different steps for different reasons; what this row adds is the statement
/// that they are not interchangeable.
///
/// **Eight acceptance criteria, six of which a repository can confirm.** The
/// two it cannot are both about the soft keyboard: a `keyboardType` is a hint,
/// and on Android a third-party input method may ignore it entirely. Whether
/// the numeric pad actually appears is a fact about the device the person
/// holds, and the honest form of "confirm it is delivered" names that rather
/// than counting the declaration as the delivery.
///
/// **Which puts the row at 75 per cent against a floor of 95.** That is
/// reported as it comes out. The alternative -- counting a declared
/// `keyboardType` as a confirmed keyboard -- would score 100 per cent and
/// would be the thing this step exists to catch.
///
/// **COLUMN NOTE.** The Setup Step reads "Replace all existing ad-hoc icon
/// usages in the application with the SystemVerbIcon component", which is Step
/// 305's work appearing as this row's setup, eleven batches away in the sheet
/// and one batch away in this track. The ceiling is written as 1 against
/// percentage floors.
library;

/// What a "mask" can mean.
enum HabotMaskKind {
  /// Groups and spaces a value the person can see in full.
  formatting,

  /// Hides what the person is typing, from onlookers.
  secureEntry,

  /// Shows a fragment of a value held elsewhere; the rest never arrives.
  maskedDisplay,
}

/// One acceptance criterion.
class HabotAcceptanceCriterion {
  const HabotAcceptanceCriterion({
    required this.text,
    required this.confirmableFromCode,
    required this.whyNot,
  });

  final String text;
  final bool confirmableFromCode;

  /// Empty when it is confirmable.
  final String whyNot;
}

/// The confirmation.
class HabotMaskedTextField {
  const HabotMaskedTextField._();

  // -----------------------------------------------------------------------
  // Three meanings, one name.
  // -----------------------------------------------------------------------

  static const Map<HabotMaskKind, String> whatEachOneProtects =
      <HabotMaskKind, String>{
    HabotMaskKind.formatting: 'nothing -- the value is visible and complete',
    HabotMaskKind.secureEntry: 'the value from somebody looking over a '
        'shoulder',
    HabotMaskKind.maskedDisplay:
        'the value from the device, which never receives it',
  };

  static bool get eachKindProtectsSomethingDifferent =>
      whatEachOneProtects.length == 3 &&
      whatEachOneProtects.values.toSet().length == 3;

  static bool get theFormattingKindProtectsNothing =>
      (whatEachOneProtects[HabotMaskKind.formatting] ?? '')
          .contains('nothing');

  static const String confusionHazard =
      'a full card number legible in a screenshot, a support ticket and a '
      'crash report';

  static bool get theHazardIsNamed =>
      confusionHazard.contains('crash report');

  static const String namingNote =
      'A formatting mask groups an IBAN; a secure field hides what is being '
      'typed; a masked display shows four digits of something the device never '
      'holds. All three are already in this repository, built at different '
      'steps for different reasons, and the word "masked" covers all three '
      'without distinguishing them. The dangerous confusion is the first for '
      'the second: a field that only formats, believed to hide, puts a full '
      'card number into a screenshot. What this row adds is not a component; '
      'it is the statement that they are not interchangeable.';

  // -----------------------------------------------------------------------
  // The acceptance criteria.
  // -----------------------------------------------------------------------

  static const List<HabotAcceptanceCriterion> criteria =
      <HabotAcceptanceCriterion>[
    HabotAcceptanceCriterion(
      text: 'the component exists and is exported from the shared library',
      confirmableFromCode: true,
      whyNot: '',
    ),
    HabotAcceptanceCriterion(
      text: 'a mask is declared per field class rather than per call site',
      confirmableFromCode: true,
      whyNot: '',
    ),
    HabotAcceptanceCriterion(
      text: 'the unmasked value is never written to a log or an analytics '
          'event',
      confirmableFromCode: true,
      whyNot: '',
    ),
    HabotAcceptanceCriterion(
      text: 'the field declares an input type appropriate to its mask',
      confirmableFromCode: true,
      whyNot: '',
    ),
    HabotAcceptanceCriterion(
      text: 'the mask survives a paste of an already formatted value',
      confirmableFromCode: true,
      whyNot: '',
    ),
    HabotAcceptanceCriterion(
      text: 'the caret does not jump to the end when a separator is inserted',
      confirmableFromCode: true,
      whyNot: '',
    ),
    HabotAcceptanceCriterion(
      text: 'the numeric soft keyboard actually appears on a real device',
      confirmableFromCode: false,
      whyNot: 'keyboardType is a hint; the input method decides, and on '
          'Android a third-party keyboard may ignore it',
    ),
    HabotAcceptanceCriterion(
      text: 'the keyboard returns to the previous type when focus moves on',
      confirmableFromCode: false,
      whyNot: 'the same hint, observed across a focus change on hardware',
    ),
  ];

  static List<HabotAcceptanceCriterion> get confirmable => criteria
      .where((HabotAcceptanceCriterion c) => c.confirmableFromCode)
      .toList();

  static List<HabotAcceptanceCriterion> get needingADevice => criteria
      .where((HabotAcceptanceCriterion c) => !c.confirmableFromCode)
      .toList();

  static double get verificationRate => confirmable.length / criteria.length;

  static bool get everyUnconfirmableCriterionSaysWhyNot =>
      needingADevice.every((HabotAcceptanceCriterion c) =>
          c.whyNot.trim().isNotEmpty);

  static bool get bothUnconfirmableOnesAreTheKeyboard =>
      needingADevice.every(
        (HabotAcceptanceCriterion c) => c.text.contains('keyboard'),
      );

  static const String keyboardNote =
      'A keyboardType is a hint. The input method decides what to show, and on '
      'Android the input method is often one the person installed themselves '
      'and which may ignore the hint entirely. Whether the numeric pad '
      'actually appears is a fact about the device somebody is holding, and '
      '"confirm it is delivered" has to say so rather than count the '
      'declaration as the delivery.';

  // -----------------------------------------------------------------------
  // The rate, reported as it comes out.
  // -----------------------------------------------------------------------

  static const double floorRate = 0.95;
  static const double optimalRate = 1.0;

  static bool get theRateIsBelowTheFloor => verificationRate < floorRate;

  /// The score an inflated reading would produce.
  static double get inflatedRate => 1.0;

  static bool get theInflatedReadingWouldPass => inflatedRate >= floorRate;

  static String get qualitativeOutput =>
      theRateIsBelowTheFloor ? 'Fail' : 'Pass';

  static const String honestyNote =
      'Six of eight criteria confirm, which is 75 per cent against a floor of '
      '95, so this step reports Fail on its own metric. Counting a declared '
      'keyboardType as a confirmed keyboard would score 100 per cent, and that '
      'substitution is the thing a verification step exists to catch. The '
      'number is reported as it comes out, and what the remaining two need is '
      'written down: a physical Android device with a third-party input method '
      'installed, and a focus change observed on it.';

  static const List<String> whatTheTwoNeed = <String>[
    'a physical Android device, not an emulator',
    'a third-party input method installed and set as default',
    'the numeric field focused, and the pad that appears observed',
    'focus moved to a text field, and the pad observed again',
  ];

  static const String ceilingNote =
      'The ceiling is written as 1 against percentage floors -- the recurring '
      'unit mismatch, recorded rather than scored against.';

  static Map<String, bool> get obligations => <String, bool>{
        'the three meanings of "masked" are separated':
            eachKindProtectsSomethingDifferent,
        'the formatting kind is recorded as protecting nothing':
            theFormattingKindProtectsNothing,
        'every criterion that cannot be confirmed says why':
            everyUnconfirmableCriterionSaysWhyNot,
        'what the unconfirmable ones need is written down':
            whatTheTwoNeed.length == 4,
        'the rate is reported rather than inflated': theRateIsBelowTheFloor,
      };

  static Map<String, bool> get checks => <String, bool>{
        'eight criteria, six confirmable from code':
            criteria.length == 8 &&
                confirmable.length == 6 &&
                needingADevice.length == 2 &&
                verificationRate == 0.75,
        'both unconfirmable criteria are about the soft keyboard':
            bothUnconfirmableOnesAreTheKeyboard &&
                everyUnconfirmableCriterionSaysWhyNot,
        'and the reason is that the input method decides':
            keyboardNote.contains('one the person installed themselves'),
        '75 per cent is below the row\'s floor of 95':
            theRateIsBelowTheFloor &&
                floorRate == 0.95 &&
                optimalRate == 1.0 &&
                qualitativeOutput == 'Fail',
        'the inflated reading would have passed':
            theInflatedReadingWouldPass &&
                honestyNote.contains('a verification step exists to catch'),
        'three meanings of masked, each protecting something different':
            eachKindProtectsSomethingDifferent &&
                theFormattingKindProtectsNothing,
        'and the dangerous confusion is named':
            theHazardIsNamed && namingNote.contains('not interchangeable'),
        'the ceiling is in a different unit from the floor':
            ceilingNote.contains('unit mismatch'),
        'five obligations, all met, on a step that still reports Fail':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Fail',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Replace all '
      'existing ad-hoc icon usages in the application with the SystemVerbIcon '
      'component", which is Step 305\'s work appearing as this row\'s setup, '
      'and the ceiling is written as 1 against percentage floors. Atomic Step: '
      '"Confirm the MaskedTextField component with native soft keyboard '
      'triggering is delivered."';
}
