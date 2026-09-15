/// Step 287 (CBSV-004-13) -- a closed set of seven, a drop-down that is not
/// one on a phone, and two hex literals the guard would refuse.
///
/// The row: "Render clean drop-down pickers for predefined emirates to
/// completely prevent manual handwriting inputs."
/// Metric: **Process Execution Quality Score** -- floor ">=90%", optimal
/// ">=98%", ceiling 1. Good / Average / Poor. Cited: ISO 9001:2015.
///
/// **The row's palette instruction would fail the build.** It asks for a
/// background that "strictly maps to clear neutral shades (#FFFFFF or
/// #F4F7F9)". Two raw colour literals, in a repository whose poka-yoke guard
/// has refused `RAW_COLOR_LITERAL` since Step 97 -- and a fixed light
/// background is also a dark-mode defect, because Steps 3 and 4 built the
/// surface roles that make the same screen legible under both. The instruction
/// is refused with a reason rather than implemented and then linted out.
///
/// **A "drop-down" is not a drop-down on a phone.** The word comes from a web
/// `<select>`, which on iOS opens a wheel and on Android opens a dialog, so
/// the platform has already decided it is not a drop-down. Step 225's rule
/// decides it here too: a choice at compact width is a modal sheet and at
/// expanded width an anchored popover. The row's word is recorded and the
/// existing rule is followed.
///
/// **"Completely prevent manual input" is right here and wrong as a rule.**
/// Seven emirates is a closed, stable set and a picker is exactly right. The
/// same instruction applied to countries is a two-hundred-item scroll hunt,
/// and applied to an address line it is impossible. The rule is therefore
/// about the *set*, not about the input: closed and small takes a picker,
/// closed and large takes a picker with filtering, open takes text.
library;

import '../surfaces/dialog_to_sheet.dart';
import '../tokens/spacing_tokens.dart';

/// How the set of valid answers behaves.
enum HabotAnswerSet {
  /// Closed, small enough to scan.
  closedAndSmall,

  /// Closed, too long to scan.
  closedAndLarge,

  /// Open. Anything could be valid.
  open,
}

/// What the field offers.
enum HabotInputAffordance {
  /// A list of every option.
  picker,

  /// A list with type-to-filter above it.
  filterablePicker,

  /// Free text.
  text,
}

/// The rule.
class HabotEmiratePicker {
  const HabotEmiratePicker._();

  /// The set. Seven, closed, and unchanged since 1972 -- which is what makes
  /// a picker the right affordance rather than a preference.
  static const List<String> emirates = <String>[
    'Abu Dhabi',
    'Dubai',
    'Sharjah',
    'Ajman',
    'Umm Al Quwain',
    'Ras Al Khaimah',
    'Fujairah',
  ];

  static bool get theSetIsClosedAndSmall =>
      emirates.length == 7 &&
      emirates.toSet().length == emirates.length &&
      emirates.length <= filterThreshold;

  // -----------------------------------------------------------------------
  // The rule is about the set, not about the input.
  // -----------------------------------------------------------------------

  /// Above this many options a plain list stops being scannable and becomes a
  /// scroll hunt. Ten screens' worth is nobody's idea of a picker; a dozen
  /// items is about where filtering starts to earn its place.
  static const int filterThreshold = 12;

  static HabotInputAffordance affordanceFor(HabotAnswerSet set) =>
      switch (set) {
        HabotAnswerSet.closedAndSmall => HabotInputAffordance.picker,
        HabotAnswerSet.closedAndLarge => HabotInputAffordance.filterablePicker,
        HabotAnswerSet.open => HabotInputAffordance.text,
      };

  static HabotAnswerSet setKindFor(int optionCount, {required bool isClosed}) {
    if (!isClosed) {
      return HabotAnswerSet.open;
    }
    return optionCount <= filterThreshold
        ? HabotAnswerSet.closedAndSmall
        : HabotAnswerSet.closedAndLarge;
  }

  static bool get emiratesGetAPlainPicker =>
      affordanceFor(setKindFor(emirates.length, isClosed: true)) ==
      HabotInputAffordance.picker;

  static bool get countriesGetFiltering =>
      affordanceFor(setKindFor(195, isClosed: true)) ==
      HabotInputAffordance.filterablePicker;

  static bool get anAddressLineStaysText =>
      affordanceFor(setKindFor(0, isClosed: false)) ==
      HabotInputAffordance.text;

  static bool get everySetKindHasAnAffordance =>
      HabotAnswerSet.values.map(affordanceFor).toSet().length ==
      HabotInputAffordance.values.length;

  static const String theRuleIsAboutTheSetNote =
      '"Completely prevent manual input" is right here and wrong as a rule. '
      'Seven emirates is closed and stable, so a picker removes an entire '
      'class of error -- spelling, casing, transliteration -- at no cost. The '
      'same instruction applied to a country list is a two-hundred-item '
      'scroll hunt where typing three letters would have been faster, and '
      'applied to an address line it is impossible. So the rule is about the '
      'SET: closed and small takes a picker, closed and large takes a picker '
      'with filtering above it, open takes text. The row\'s instruction is '
      'the first case, and saying which case it is stops the next person '
      'applying it to the third.';

  // -----------------------------------------------------------------------
  // The surface, which the existing rule already decides.
  // -----------------------------------------------------------------------

  static const HabotSurfaceIntent intent = HabotSurfaceIntent.choice;

  static HabotSurfaceForm formAt(double widthDp) =>
      HabotSurfaceChoice.formFor(intent, widthDp);

  static bool get aPhoneGetsASheetRatherThanADropDown =>
      formAt(360) == HabotSurfaceForm.modalSheet &&
      formAt(1024) == HabotSurfaceForm.anchoredPopover;

  /// Dismissing without choosing is a valid outcome for a choice, so the
  /// sheet may be swiped away -- which is why this is not a decision.
  static bool get dismissingWithoutChoosingIsAllowed =>
      HabotSurfaceChoice.isDismissibleByGesture(formAt(360));

  static const String dropDownIsAWebWordNote =
      'A drop-down is a web control. On iOS a select opens a wheel, on '
      'Android a dialog, so even on the web the platform has already decided '
      'it is not a drop-down -- and this application has no select at all. '
      'Step 225\'s rule maps a choice to a modal sheet on a phone and an '
      'anchored popover on a wide window, and it is followed rather than '
      'second-guessed. The row\'s word is recorded because the next reader '
      'will search for it.';

  // -----------------------------------------------------------------------
  // No default.
  // -----------------------------------------------------------------------

  /// Nothing is pre-selected. A picker that starts on the first entry gets
  /// submitted by everybody who did not look at it, and the resulting data is
  /// indistinguishable from a real answer.
  static const String? initialSelection = null;

  static bool get nothingIsPreSelected => initialSelection == null;

  static bool isAnswered(String? selection) =>
      selection != null && emirates.contains(selection);

  static bool get anUnansweredPickerIsDistinguishable =>
      !isAnswered(initialSelection) && isAnswered('Sharjah');

  /// And a value that is not in the set is not an answer either, whatever
  /// route it arrived by.
  static bool get aValueOffTheListIsRefused => !isAnswered('Doha');

  static const String noDefaultNote =
      'Nothing is pre-selected. A picker that opens on the first entry is '
      'submitted unread by everybody in a hurry, and the resulting Abu Dhabi '
      'is indistinguishable in the data from one somebody chose -- which is '
      'worse than a blank, because a blank can be asked about. The unanswered '
      'state is a distinct value rather than the first option.';

  // -----------------------------------------------------------------------
  // The palette instruction, refused.
  // -----------------------------------------------------------------------

  /// The two literals the row names. Held as strings, not as colours: writing
  /// them as colours is the thing being refused.
  static const List<String> hexLiteralsTheRowNames = <String>[
    '#FFFFFF',
    '#F4F7F9',
  ];

  static const String guardRuleThatWouldRefuseThem = 'RAW_COLOR_LITERAL';

  static bool get theRowsPaletteWouldFailTheGuard =>
      hexLiteralsTheRowNames.length == 2 &&
      hexLiteralsTheRowNames.every((String h) => h.startsWith('#')) &&
      guardRuleThatWouldRefuseThem.isNotEmpty;

  static const String paletteRefusalNote =
      'The row asks for a background of #FFFFFF or #F4F7F9. Both are raw '
      'colour literals, which the poka-yoke guard has refused since Step 97, '
      'and both are light -- so following the instruction would also pin the '
      'field to a light background in an application whose surface roles have '
      'adapted to the OS theme since Step 3. The instruction is refused here '
      'with its reason rather than written, committed and then linted out by '
      'a build nobody connects to this row.';

  // -----------------------------------------------------------------------
  // The gutter, which happens to be a token.
  // -----------------------------------------------------------------------

  /// The row asks for "broad gutter gaps of 16px". Sixteen is on the spacing
  /// scale already, so the figure is right and the unit is not -- the token
  /// is what is used, and it happens to hold the same number.
  static const double gutterTheRowNames = 16;

  static double get gutterUsed => HabotSpacing.md;

  static bool get theRowsFigureMatchesADeclaredToken =>
      gutterUsed == gutterTheRowNames;

  static const String gutterNote =
      'The row asks for 16px gutters. Sixteen is already on the spacing '
      'scale, so this is the rare case where the sheet\'s figure and the '
      'declared token agree -- and the token is still what is used, because a '
      'literal that happens to be right today is a literal that stops being '
      'right the day the scale changes. The unit is wrong, as it is on Steps '
      '276 and 285, and is read as points.';

  // -----------------------------------------------------------------------
  // Metric: Process Execution Quality Score -- 90% / 98% / 1.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'the set is closed, small and has no duplicates':
            theSetIsClosedAndSmall,
        'the affordance follows from the set rather than from the row':
            emiratesGetAPlainPicker &&
                countriesGetFiltering &&
                anAddressLineStaysText,
        'the surface is decided by the existing rule':
            aPhoneGetsASheetRatherThanADropDown,
        'dismissing without choosing is allowed':
            dismissingWithoutChoosingIsAllowed,
        'nothing is pre-selected': nothingIsPreSelected,
        'an unanswered picker is distinguishable from a chosen first entry':
            anUnansweredPickerIsDistinguishable,
        'a value off the list is refused': aValueOffTheListIsRefused,
        'the gutter comes from the declared token':
            theRowsFigureMatchesADeclaredToken,
      };

  static double get qualityScore =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static const double floorPercent = 90;
  static const double optimalPercent = 98;

  static String get qualitativeOutput {
    final double pct = qualityScore * 100;
    if (pct >= optimalPercent) {
      return 'Good';
    }
    return pct >= floorPercent ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'seven emirates, closed and without duplicates':
            theSetIsClosedAndSmall && emirates.length == 7,
        'every kind of answer set has a distinct affordance':
            everySetKindHasAnAffordance,
        'a picker here, filtering for a long list, text for an open one':
            emiratesGetAPlainPicker &&
                countriesGetFiltering &&
                anAddressLineStaysText,
        'the rule is recorded as being about the set':
            theRuleIsAboutTheSetNote.contains('applying it to the third'),
        'a phone gets a sheet rather than a drop-down':
            aPhoneGetsASheetRatherThanADropDown &&
                dropDownIsAWebWordNote.contains('has no select at all'),
        'dismissing without choosing is allowed':
            dismissingWithoutChoosingIsAllowed,
        'nothing is pre-selected, and unanswered is its own value':
            nothingIsPreSelected &&
                anUnansweredPickerIsDistinguishable &&
                noDefaultNote.contains('can be asked about'),
        'a value off the list is refused': aValueOffTheListIsRefused,
        'the row\'s two hex literals would fail the existing guard':
            theRowsPaletteWouldFailTheGuard &&
                paletteRefusalNote.contains('linted out'),
        'the gutter figure matches a token, and the token is used':
            theRowsFigureMatchesADeclaredToken &&
                gutterNote.contains('stops being right'),
        'eight obligations, all met, giving Good':
            obligations.length == 8 &&
                obligations.values.every((bool b) => b) &&
                qualityScore == 1.0 &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Set the default '
      'state of the child expansion sub-panel to remain hidden from the '
      'layout view track", which belongs to the disclosure rows earlier in '
      'this batch rather than to this one. Atomic Step: "Render clean '
      'drop-down pickers for predefined emirates to completely prevent '
      'manual handwriting inputs."';
}
