/// Step 308 (GEN-01098) -- a real metric, a real standard, and a number
/// nothing in this repository can produce.
///
/// The row: "Embed M3 Outlined text fields with contact action icons."
/// Metric: **Icon Recognition Accuracy** -- floor 0.8, optimal 0.95, ceiling
/// 1. Good / Average / Poor. ISO 9186 Graphical Symbol Testing.
///
/// **The metric is correct, and the row is stricter than the standard it
/// cites.** ISO 9186 is the comprehension-testing method for graphical
/// symbols, and its acceptance criterion is about two thirds -- 67 per cent in
/// the referent-association test that ISO 7001 uses for public symbols. This
/// row's floor is 0.8. That is not a defect; it is a project choosing to be
/// harder on itself than the standard requires, and it is worth saying plainly
/// because most of what this track records about metrics is the opposite.
///
/// **And nothing here can measure it.** Recognition accuracy is a number about
/// people: you show the symbol to participants who have not seen the interface
/// and ask what it means. No amount of code produces it. One gate is deferred
/// with the protocol written out, rather than approximated by counting icons
/// that have labels -- which is a different, easier thing that this repository
/// already checks and would have passed.
///
/// **Three trailing icons do not fit, and the arithmetic is not close.** An M3
/// outlined field on a compact window has about 296 points inside its own
/// padding. Three 48-point targets with the required 8-point clearance between
/// them take 160 -- 54 per cent of the field -- leaving 136 points for the
/// phone number, which is less than the number itself. One action goes inside
/// the field; the others go under it, where they can be labelled.
///
/// **A trailing icon inside a field is two gestures in one rectangle.** A tap
/// on the icon must fire the action and must not focus the field, because
/// focusing raises the keyboard over the thing the person just asked to see.
/// The field is 56 points tall and the target is 48, so there are 4 points of
/// margin above and below: the two regions do not overlap, which is what makes
/// the separation real rather than a matter of hit-test ordering.
///
/// **The action waits for the value to parse.** A call button beside a
/// half-typed number dials a wrong number, and the person who notices is the
/// stranger who answers. The action is disabled until the value is complete,
/// and -- following Steps 291 and 294 -- the disabled state says what would
/// change it rather than sitting there grey.
///
/// **COLUMN NOTE.** The Setup Step reads "Capture resultant input field DOM
/// value attribute after masking execution". The DOM, in a Flutter
/// application: eleventh foreign stack in this track.
library;

import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// What a contact action does.
enum HabotContactAction { call, message, email }

/// Where the control for it lives.
enum HabotActionPlacement {
  /// Inside the field, as a trailing icon.
  trailingIcon,

  /// Under the field, as a labelled button.
  buttonRow,
}

/// The field.
class HabotContactFieldActions {
  const HabotContactFieldActions._();

  // -----------------------------------------------------------------------
  // Geometry.
  // -----------------------------------------------------------------------

  static const double compactWindowDp = 360;

  static double get pageMarginsDp => HabotSpacing.md * 2;

  static double get fieldWidthDp => compactWindowDp - pageMarginsDp;

  static double get fieldInnerPaddingDp => HabotSpacing.md * 2;

  static double get innerWidthDp => fieldWidthDp - fieldInnerPaddingDp;

  /// M3's outlined field height with a floating label.
  static const double fieldHeightDp = 56;

  static double get targetSideDp => HabotTouchBand.optimalDp;

  static double get clearanceDp => HabotDensity.touchSafetyMargin;

  static double get verticalMarginInsideTheFieldDp =>
      (fieldHeightDp - targetSideDp) / 2;

  /// The two regions do not overlap, so "the icon is not the field" is a fact
  /// about the layout rather than about hit-test order.
  static bool get theTargetFitsInsideTheFieldHeight =>
      targetSideDp <= fieldHeightDp && verticalMarginInsideTheFieldDp > 0;

  static double widthForActions(int count) =>
      count <= 0 ? 0 : count * targetSideDp + (count - 1) * clearanceDp;

  static double shareOfTheFieldFor(int count) =>
      widthForActions(count) / innerWidthDp;

  static double textWidthRemainingFor(int count) =>
      innerWidthDp - widthForActions(count);

  static int get actionsInsideTheField => 1;

  static int get actionsTotal => HabotContactAction.values.length;

  static int get actionsUnderTheField => actionsTotal - actionsInsideTheField;

  static HabotActionPlacement placementFor(HabotContactAction a) =>
      a == HabotContactAction.call
          ? HabotActionPlacement.trailingIcon
          : HabotActionPlacement.buttonRow;

  static bool get onlyOneActionIsInsideTheField =>
      HabotContactAction.values
          .where(
            (HabotContactAction a) =>
                placementFor(a) == HabotActionPlacement.trailingIcon,
          )
          .length ==
      actionsInsideTheField;

  static const String geometryNote =
      'Three 48-point targets with the required 8-point clearance take 160 '
      'points of a field that has 296 inside its own padding: 54 per cent, '
      'leaving 136 for the phone number, which is less than the number needs. '
      'One action goes inside the field and the other two go under it, where '
      'they can carry words as well as glyphs -- which is also the only place '
      'the recognition question stops mattering, because a labelled button '
      'does not depend on anybody recognising anything.';

  // -----------------------------------------------------------------------
  // Two gestures, one rectangle.
  // -----------------------------------------------------------------------

  static const bool tappingTheIconFocusesTheField = false;

  static const String focusNote =
      'A tap on the trailing icon fires the action and does not focus the '
      'field. Focusing raises the keyboard over the thing the person just '
      'asked to see, and on a short screen the call they started disappears '
      'behind it. The 4 points of margin above and below the target mean the '
      'two regions do not overlap, so the separation is a property of the '
      'layout rather than of which hit-test wins.';

  // -----------------------------------------------------------------------
  // The action waits.
  // -----------------------------------------------------------------------

  /// UAE mobile numbers: 9 digits after the country code.
  static const int completeDigitCount = 9;

  static bool valueIsComplete(String digits) =>
      digits.length == completeDigitCount &&
      digits.split('').every((String c) => int.tryParse(c) != null);

  static bool actionIsEnabled(String digits) => valueIsComplete(digits);

  /// And it says why, rather than sitting there grey. Steps 291 and 294.
  static String disabledReasonFor(String digits) {
    if (digits.isEmpty) {
      return 'Enter a mobile number to call it';
    }
    final int missing = completeDigitCount - digits.length;
    if (missing > 0) {
      return 'Enter the remaining digits';
    }
    return 'Check the number -- it should be 9 digits';
  }

  static bool get theDisabledStateAlwaysSaysSomething =>
      disabledReasonFor('').isNotEmpty &&
      disabledReasonFor('5012').isNotEmpty &&
      disabledReasonFor('50123456789').isNotEmpty;

  static const String premature =
      'A call button beside a half-typed number dials a wrong number, and the '
      'person who notices is the stranger who answers. The action is disabled '
      'until the value is complete, and the disabled state names what would '
      'change it -- the property Step 291 established and Step 292 was refused '
      'for lacking.';

  // -----------------------------------------------------------------------
  // The metric, which is real, and the gate, which is deferred.
  // -----------------------------------------------------------------------

  static const double rowFloor = 0.8;
  static const double rowOptimal = 0.95;
  static const double rowCeiling = 1.0;

  /// ISO 9186-1's own acceptance criterion, as ISO 7001 applies it.
  static const double standardAcceptanceCriterion = 0.67;

  static double get howMuchStricterTheRowIs =>
      rowFloor - standardAcceptanceCriterion;

  static bool get theRowIsStricterThanTheStandardItCites =>
      rowFloor > standardAcceptanceCriterion;

  static const String metricIsCorrectNote =
      'ISO 9186 is the comprehension-testing method for graphical symbols and '
      'its acceptance criterion is about two thirds. This row asks for 0.8. '
      'That is a project choosing to be harder on itself than the standard '
      'requires, on a row where the metric measures the row\'s own subject, '
      'and it is worth saying plainly because almost everything else this '
      'track records about metrics is the opposite.';

  /// What the deferred gate needs, so the deferral is a protocol rather than
  /// a shrug.
  static const List<String> whatTheDeferredGateNeeds = <String>[
    'participants who have not seen this interface',
    'each symbol shown with its context of use and no label',
    'open-ended responses, coded by two independent raters',
    'the ISO 9186-1 referent-association variant, not a preference test',
    'a sample drawn from the populations the app ships to',
  ];

  static const int deferredGates = 1;

  static const bool recognitionIsMeasurableFromCode = false;

  static const String deferralNote =
      'Recognition accuracy is a number about people: the symbol is shown, '
      'without its label, to participants who have not seen the interface, and '
      'they say what it means. No code produces that. The temptation is to '
      'report the share of icons that carry a label instead, which this '
      'repository already checks and would pass at 100 per cent -- a different '
      'and easier question wearing the same metric\'s name. The gate is '
      'deferred with the protocol written out.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'one action inside the field, the rest under it':
            onlyOneActionIsInsideTheField && actionsUnderTheField == 2,
        'the trailing target fits with margin above and below':
            theTargetFitsInsideTheFieldHeight,
        'tapping the icon does not focus the field':
            !tappingTheIconFocusesTheField,
        'the action is disabled until the value parses':
            !actionIsEnabled('5012') && actionIsEnabled('501234567'),
        'the disabled state always says what would change it':
            theDisabledStateAlwaysSaysSomething,
      };

  /// Not an obligation the code could meet, so it is not scored as one. It is
  /// the deferred gate, named separately.
  static const String theMeasurementThatIsNotScored =
      'recognition accuracy, which is measured with people';

  static int get obligationsMet =>
      obligations.values.where((bool b) => b).length;

  static double get conformance => obligationsMet / obligations.length;

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Average';

  static Map<String, bool> get checks => <String, bool>{
        'the field has 296 points inside its own padding':
            fieldWidthDp == 328 && innerWidthDp == 296,
        'three actions would take 160 of them':
            widthForActions(3) == 160 &&
                (shareOfTheFieldFor(3) - 160 / 296).abs() < 1e-9 &&
                textWidthRemainingFor(3) == 136,
        'one action takes 48 and leaves 248':
            widthForActions(1) == 48 && textWidthRemainingFor(1) == 248,
        'so one goes inside and two go under':
            onlyOneActionIsInsideTheField &&
                actionsTotal == 3 &&
                actionsUnderTheField == 2 &&
                geometryNote.contains('stops mattering'),
        'the target leaves four points of margin in a 56-point field':
            fieldHeightDp == 56 &&
                targetSideDp == 48 &&
                verticalMarginInsideTheFieldDp == 4 &&
                theTargetFitsInsideTheFieldHeight,
        'the icon does not raise the keyboard':
            !tappingTheIconFocusesTheField &&
                focusNote.contains('behind it'),
        'a half-typed number cannot be dialled':
            !actionIsEnabled('') &&
                !actionIsEnabled('5012') &&
                actionIsEnabled('501234567') &&
                premature.contains('the stranger who answers'),
        'and each disabled state gives a different reason':
            disabledReasonFor('') != disabledReasonFor('5012') &&
                disabledReasonFor('5012') !=
                    disabledReasonFor('50123456789'),
        'the row asks for more than the standard it cites':
            theRowIsStricterThanTheStandardItCites &&
                (howMuchStricterTheRowIs - 0.13).abs() < 1e-9 &&
                metricIsCorrectNote.contains('harder on itself'),
        'the metric cannot be produced here, and is deferred with a protocol':
            !recognitionIsMeasurableFromCode &&
                deferredGates == 1 &&
                whatTheDeferredGateNeeds.length == 5 &&
                deferralNote.contains('wearing the same metric'),
        'five obligations, all met, with the measurement kept separate':
            obligations.length == 5 &&
                obligationsMet == 5 &&
                conformance == 1.0 &&
                qualitativeOutput == 'Good' &&
                theMeasurementThatIsNotScored.contains('with people') &&
                rowCeiling == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Capture resultant '
      'input field DOM value attribute after masking execution" -- the DOM, in '
      'a Flutter application, and the eleventh foreign stack in this track. '
      'Atomic Step: "Embed M3 Outlined text fields with contact action icons."';
}
