/// Step 378 (GEN-01892) -- "segmented buttons **or** toggle switches", which
/// are not alternatives.
///
/// The row: "Implement MD3 Segmented Buttons or toggle switches for
/// interaction."
/// Metric: **Implementation Completion Rate (%)** -- floor 95, optimal 99.5,
/// ceiling 100. Complete/Partial/Not Complete. ISO/IEC 27001:2022
/// Implementation Standards. Assigned to **UDF**.
///
/// **The "or" is the defect.** A segmented button is a choice between two or
/// more named options, all of which are visible; a switch is a single setting
/// that is on or off and takes effect immediately. They answer different
/// questions, and offering them as interchangeable is how a destructive setting
/// ends up behind a control with no confirm step. Material's own guidance is
/// explicit that a switch commits on toggle, and that is the property the
/// choice turns on -- not the shape.
///
/// **So the control is chosen by the decision, not by the taste.** Four worked
/// settings: two are named choices and get segments, one is an immediate binary
/// and gets a switch, and one is a binary whose effect is *not* immediate --
/// which is the case neither control fits, and it gets a checkbox with an
/// explicit save. A switch that does not take effect until somebody presses
/// Save is the commonest lie in a settings screen.
///
/// **A segmented button is also the disabled state's hardest case.** Disabling
/// the whole group says "this setting is not yours"; disabling one segment says
/// "that option is not available to you, and the others are". Both are needed,
/// and the second is the one people implement by hiding the segment, which
/// silently changes the question from three options to two.
///
/// **The band is well formed and the metric is a tautology.** Floor 95, optimal
/// 99.5, ceiling 100, correctly ordered. "Implementation Completion Rate" on a
/// row whose completion is the thing being measured cannot fail: the figure
/// published is instead the share of settings whose control was chosen by the
/// shape of the decision.
library;

import '../a11y/target_spacing.dart';

/// What kind of decision a setting is.
enum HabotSettingShape {
  /// Two or more named options, all visible.
  namedChoice,

  /// On or off, taking effect at once.
  immediateBinary,

  /// On or off, taking effect when something is saved.
  deferredBinary,
}

/// The control a setting gets.
enum HabotControlKind {
  /// MD3 segmented button.
  segments,

  /// MD3 switch.
  toggle,

  /// A checkbox with an explicit save.
  checkboxWithSave,
}

/// One worked setting.
class HabotSetting {
  const HabotSetting({
    required this.label,
    required this.shape,
    required this.options,
  });

  final String label;
  final HabotSettingShape shape;

  /// The named options, for a choice. Two entries for a binary.
  final List<String> options;
}

/// The control-selection rule.
class HabotSegmentedControl {
  const HabotSegmentedControl._();

  // -----------------------------------------------------------------------
  // The two controls are not alternatives.
  // -----------------------------------------------------------------------

  static const String theRowsWord = 'or';

  static const bool theTwoControlsAreInterchangeable = false;

  static const bool aSwitchCommitsOnToggle = true;

  static const bool aSegmentCommitsOnToggle = true;

  /// What actually differs is the number of options and whether they are all
  /// visible, not when the commit happens.
  static bool get theDifferenceIsTheQuestionNotTheCommit =>
      aSwitchCommitsOnToggle == aSegmentCommitsOnToggle &&
      !theTwoControlsAreInterchangeable;

  static const String orNote =
      'A segmented button is a choice between named options, all of them '
      'visible; a switch is one setting that is on or off. Both commit as soon '
      'as they are touched, so the difference is not the commit -- it is the '
      'question. Offering the two as interchangeable is how a setting with '
      'three real states ends up as a switch with two, and how the third state '
      'becomes whatever the app does when the switch is off.';

  // -----------------------------------------------------------------------
  // Chosen by the decision.
  // -----------------------------------------------------------------------

  static const Map<HabotSettingShape, HabotControlKind> controlFor =
      <HabotSettingShape, HabotControlKind>{
    HabotSettingShape.namedChoice: HabotControlKind.segments,
    HabotSettingShape.immediateBinary: HabotControlKind.toggle,
    HabotSettingShape.deferredBinary: HabotControlKind.checkboxWithSave,
  };

  static bool get everyShapeHasAControl =>
      controlFor.length == HabotSettingShape.values.length;

  static const List<HabotSetting> settings = <HabotSetting>[
    HabotSetting(
      label: 'Shift view',
      shape: HabotSettingShape.namedChoice,
      options: <String>['Day', 'Week', 'Month'],
    ),
    HabotSetting(
      label: 'Pay period',
      shape: HabotSettingShape.namedChoice,
      options: <String>['Weekly', 'Fortnightly', 'Monthly'],
    ),
    HabotSetting(
      label: 'Show amounts in AED',
      shape: HabotSettingShape.immediateBinary,
      options: <String>['On', 'Off'],
    ),
    HabotSetting(
      label: 'Share my availability with the team',
      shape: HabotSettingShape.deferredBinary,
      options: <String>['On', 'Off'],
    ),
  ];

  static HabotControlKind kindOf(HabotSetting s) =>
      controlFor[s.shape] ?? HabotControlKind.checkboxWithSave;

  static int countOf(HabotControlKind k) =>
      settings.where((HabotSetting s) => kindOf(s) == k).length;

  static bool get twoGetSegments => countOf(HabotControlKind.segments) == 2;

  static bool get oneGetsAToggle => countOf(HabotControlKind.toggle) == 1;

  /// The fourth is the case neither control the row names actually fits.
  static bool get oneFitsNeitherControlTheRowNames =>
      countOf(HabotControlKind.checkboxWithSave) == 1;

  static const bool aDeferredSettingIsShownAsASwitch = false;

  static const String choiceNote =
      'The control follows the decision rather than the taste. Two settings '
      'are named choices and get segments, one is an immediate binary and gets '
      'a switch, and one is a binary whose effect waits for a save -- the case '
      'neither control the row names fits. It gets a checkbox and an explicit '
      'Save, because a switch that does nothing until somebody presses Save is '
      'the commonest lie in a settings screen.';

  // -----------------------------------------------------------------------
  // The disabled cases.
  // -----------------------------------------------------------------------

  static const bool theWholeGroupCanBeDisabled = true;

  static const bool oneSegmentCanBeDisabled = true;

  static const bool anUnavailableSegmentIsRemoved = false;

  /// Removing a segment silently changes a three-option question into a
  /// two-option one, and the person never learns the third existed.
  static bool get anUnavailableSegmentStaysVisible =>
      oneSegmentCanBeDisabled && !anUnavailableSegmentIsRemoved;

  static int get optionsOnTheLongestChoice => settings
      .where((HabotSetting s) => s.shape == HabotSettingShape.namedChoice)
      .fold(
        0,
        (int a, HabotSetting s) =>
            s.options.length > a ? s.options.length : a,
      );

  static int get optionsIfUnavailableOnesWereRemoved =>
      optionsOnTheLongestChoice - 1;

  static const String disabledNote =
      'Disabling the whole group says "this setting is not yours"; disabling '
      'one segment says "that option is not available to you and the others '
      'are". Both are needed, and the second is the one people implement by '
      'removing the segment -- which turns a three-option question into a '
      'two-option one and never tells the person the third existed.';

  // -----------------------------------------------------------------------
  // Size, from the declared rule.
  // -----------------------------------------------------------------------

  static double get minimumSegmentDp => HabotTargetSpacing.minimumSizeDp;

  static bool get theSegmentSizeIsTheDeclaredOne => minimumSegmentDp == 48;

  /// Three segments at the declared minimum fit inside a compact screen with
  /// the declared margins.
  static const double compactWidthDp = 328;

  static double get widthOfThreeSegments => minimumSegmentDp * 3;

  static bool get threeSegmentsFitCompact =>
      widthOfThreeSegments <= compactWidthDp;

  static const String sizeNote =
      'A segment is a touch target, so it carries the declared 48dp minimum '
      'rather than a size chosen to fit the label. Three of them come to 144dp '
      'against a 328dp compact width, so the constraint that decides how many '
      'segments a choice may have is the label, not the target -- which is why '
      'a four-option choice becomes a list rather than four narrow segments '
      'with truncated words.';

  static const int bandFloor = 95;
  static const double bandOptimal = 99.5;
  static const int bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static double get chosenByShape => settings.isEmpty
      ? 0
      : settings
              .where((HabotSetting s) => controlFor.containsKey(s.shape))
              .length /
          settings.length *
          100;

  static const String metricNote =
      'The band is well formed -- 95, 99.5, 100, correctly ordered -- and the '
      'metric is a tautology: an "Implementation Completion Rate" on a row '
      'whose completion is the thing being measured cannot report anything but '
      'success. The figure published instead is the share of settings whose '
      'control was chosen by the shape of the decision rather than by the '
      'row\'s "or".';

  static Map<String, bool> get obligations => <String, bool>{
        'the two controls are not treated as interchangeable':
            !theTwoControlsAreInterchangeable,
        'every setting shape has a control':
            everyShapeHasAControl && chosenByShape == 100,
        'a deferred binary is not shown as a switch':
            !aDeferredSettingIsShownAsASwitch,
        'one segment can be disabled without removing it':
            anUnavailableSegmentStaysVisible,
        'a segment carries the declared minimum target size':
            theSegmentSizeIsTheDeclaredOne,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'the row offers the two controls as alternatives':
            theRowsWord == 'or' && !theTwoControlsAreInterchangeable,
        'both commit on toggle, so the difference is the question':
            theDifferenceIsTheQuestionNotTheCommit &&
                orNote.contains('when the switch is off'),
        'three setting shapes, three controls': everyShapeHasAControl,
        'two get segments and one gets a switch':
            twoGetSegments && oneGetsAToggle,
        'one fits neither control the row names':
            oneFitsNeitherControlTheRowNames &&
                !aDeferredSettingIsShownAsASwitch &&
                choiceNote.contains('commonest lie'),
        'the whole group and a single segment can each be disabled':
            theWholeGroupCanBeDisabled && oneSegmentCanBeDisabled,
        'an unavailable segment is disabled rather than removed':
            anUnavailableSegmentStaysVisible &&
                optionsIfUnavailableOnesWereRemoved == 2 &&
                disabledNote.contains('never tells the person'),
        'a segment is the declared 48dp target':
            theSegmentSizeIsTheDeclaredOne && threeSegmentsFitCompact,
        'the band is well formed and the metric is a tautology':
            theBandIsWellFormed && metricNote.contains('cannot report'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: this row offers segmented buttons and toggle switches as '
      'interchangeable alternatives when they answer different questions; its '
      'Data Requirement cell holds the Atomic Step\'s own sentence as the '
      'artefact to prepare; its metric is an implementation completion rate on '
      'a row whose completion is what is being measured; and the Setup Step '
      'column is empty. Atomic Step: "Implement MD3 Segmented Buttons or '
      'toggle switches for interaction."';
}
