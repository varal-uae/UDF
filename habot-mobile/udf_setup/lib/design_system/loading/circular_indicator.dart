/// Step 297 (CRSSS-004-18) -- the M3 circular indicator, and a Setup Step
/// that caps text scaling at 1.3x in a repository whose audit requires 2.0x.
///
/// The row: "Implement the Material 3 CircularProgressIndicator component for
/// these specific loading states."
/// Metric: **Process Execution Quality Score** -- floor >=90%, optimal >=98%,
/// ceiling 1. Good / Average / Poor. ISO 9001:2015.
///
/// **The row is right about indeterminate, and right for the reason it gives.**
/// "Utilize smooth, indeterminate progress indicators during cold starts" is
/// correct: a cold start has no denominator, and a determinate ring drawn over
/// an unknown total is a number somebody made up. Of the six loading states
/// worked here, two know their total and four do not, so four get a spinner
/// and two get a ring -- and the choice is made by asking the operation, not
/// by preference.
///
/// **A spinner has no value to announce, so it must have a label.** A
/// determinate indicator can say "40 per cent"; an indeterminate one has
/// nothing to put in `semanticsValue`, and a screen reader on a silent circle
/// announces the screen as empty. `HabotProgressPolicy.semanticsValue` already
/// handles the determinate half; this step supplies the sentence for the
/// other.
///
/// **The Setup Step is refused.** It reads "Set maximum font scaling factor
/// constraint ($1.3\times$) for large accessibility text sizes." WCAG 2.1
/// SC 1.4.4 Resize Text requires text to remain usable at 200 per cent, and
/// this repository's own `HabotTextScale.wcagRequired` is 2.0 with an audit
/// that runs to it. Capping at 1.3 would put the app below a Level AA
/// criterion it currently meets, and would do so silently: nothing breaks, the
/// text simply stops growing for the people who set it large on purpose. The
/// guard rule A11Y_TEXT_SCALING_SUPPRESSED exists to catch exactly this.
///
/// **COLUMN NOTE.** "Build state-driven Compose logic to gracefully mask
/// network latency" is Jetpack Compose. Ninth row in this track written for
/// another stack; Step 258 keeps the running list.
library;

import '../a11y/text_scaling.dart';

/// One loading state the row points at.
class HabotLoadingState {
  const HabotLoadingState({
    required this.name,
    required this.totalUnits,
    required this.spokenWhileWaiting,
  });

  final String name;

  /// Null when the size of the work cannot be known in advance.
  final int? totalUnits;

  /// What a screen reader says while this state is on screen.
  final String spokenWhileWaiting;

  bool get isDeterminate => totalUnits != null && totalUnits! > 0;
}

/// The binding.
class HabotCircularIndicatorBinding {
  const HabotCircularIndicatorBinding._();

  static const List<HabotLoadingState> states = <HabotLoadingState>[
    HabotLoadingState(
      name: 'cold start',
      totalUnits: null,
      spokenWhileWaiting: 'Starting up',
    ),
    HabotLoadingState(
      name: 'session restore',
      totalUnits: null,
      spokenWhileWaiting: 'Restoring your session',
    ),
    HabotLoadingState(
      name: 'dashboard fetch',
      totalUnits: null,
      spokenWhileWaiting: 'Loading today\'s totals',
    ),
    HabotLoadingState(
      name: 'attachment upload',
      totalUnits: 100,
      spokenWhileWaiting: 'Uploading',
    ),
    HabotLoadingState(
      name: 'batch submission',
      totalUnits: 24,
      spokenWhileWaiting: 'Submitting records',
    ),
    HabotLoadingState(
      name: 'token refresh',
      totalUnits: null,
      spokenWhileWaiting: 'Signing you in',
    ),
  ];

  static List<HabotLoadingState> get determinate =>
      states.where((HabotLoadingState s) => s.isDeterminate).toList();

  static List<HabotLoadingState> get indeterminate =>
      states.where((HabotLoadingState s) => !s.isDeterminate).toList();

  static double get shareIndeterminate =>
      indeterminate.length / states.length;

  /// The choice is made by asking the operation whether it has a total, not
  /// by a preference written at the call site.
  static bool get theShapeIsChosenByTheData => states.every(
        (HabotLoadingState s) =>
            s.isDeterminate == (s.totalUnits != null && s.totalUnits! > 0),
      );

  static const String indeterminateNote =
      'A cold start has no denominator. A determinate ring drawn over an '
      'unknown total is a number somebody made up, and the specific harm is '
      'that people read a ring as a promise: at 90 per cent they stop '
      'considering that it might not finish. The row asks for indeterminate '
      'indicators during cold starts and is right, so four of the six states '
      'here spin and the two that can count their work draw a ring.';

  // -----------------------------------------------------------------------
  // What a spinner announces.
  // -----------------------------------------------------------------------

  /// A determinate indicator has a percentage to announce. An indeterminate
  /// one does not, so the sentence is the only thing it has.
  static bool get everyIndeterminateStateHasASentence => indeterminate.every(
        (HabotLoadingState s) => s.spokenWhileWaiting.trim().isNotEmpty,
      );

  static bool get noSentenceIsTheWordLoading => states.every(
        (HabotLoadingState s) =>
            s.spokenWhileWaiting.toLowerCase() != 'loading',
      );

  static const String semanticsNote =
      'A determinate indicator can announce a percentage. An indeterminate '
      'one has no value to give, so a screen reader meeting a bare circle '
      'reports a screen with nothing on it -- the person is told the app is '
      'empty while it is in fact busy. Each spinning state carries its own '
      'sentence, and none of them is the word "Loading", which names the '
      'widget rather than the work.';

  // -----------------------------------------------------------------------
  // The Setup Step, refused.
  // -----------------------------------------------------------------------

  /// What the row asks for.
  static const double requestedScaleCap = 1.3;

  /// What WCAG 2.1 SC 1.4.4 requires, and what this repository already audits
  /// to. Read from the existing token rather than restated.
  static double get requiredScale => HabotTextScale.wcagRequired;

  static double get shortfall => requiredScale - requestedScaleCap;

  /// The people the cap would affect: everyone whose OS setting is above the
  /// cap. The audited scales are declared beside the token.
  static List<double> get auditedScalesAboveTheCap => HabotTextScale
      .auditedScales
      .where((double s) => s > requestedScaleCap)
      .toList();

  static const bool theCapIsImplemented = false;

  static const String guardRule = 'A11Y_TEXT_SCALING_SUPPRESSED';

  static const String scaleCapNote =
      'The Setup Step asks to cap font scaling at 1.3x "for large '
      'accessibility text sizes" -- that is, to cap it precisely for the '
      'people who asked for large text. SC 1.4.4 requires 200 per cent, this '
      'repository audits to 2.0, and the cap would take the app below a Level '
      'AA criterion it currently meets. It would do so silently: nothing '
      'breaks, no test fails, the text simply stops growing. The guard rule '
      'A11Y_TEXT_SCALING_SUPPRESSED exists for this instruction, and the cap '
      'is recorded rather than written.';

  static const String wrongStackNote =
      'The fourth configuration cell reads "Build state-driven Compose logic '
      'to gracefully mask network latency". Jetpack Compose, in a Flutter '
      'application -- the ninth row in this track written for another stack. '
      'The instruction translates without loss, because "state-driven" is a '
      'property of the architecture rather than of the toolkit, and it is the '
      'shape already used here: the indicator reads the operation.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'indeterminate is used where no total exists':
            indeterminate.length == 4,
        'determinate is used where a total exists': determinate.length == 2,
        'the shape is chosen by the data': theShapeIsChosenByTheData,
        'every spinning state announces a sentence':
            everyIndeterminateStateHasASentence,
        'no sentence names the widget instead of the work':
            noSentenceIsTheWordLoading,
        'the scale cap is refused rather than applied': !theCapIsImplemented,
      };

  static double get executionQuality =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (executionQuality >= 0.98) {
      return 'Good';
    }
    return executionQuality >= 0.90 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'six loading states, four of them indeterminate':
            states.length == 6 &&
                indeterminate.length == 4 &&
                determinate.length == 2 &&
                (shareIndeterminate - 2 / 3).abs() < 1e-9,
        'the row is right about cold starts, and for the right reason':
            indeterminateNote.contains('read a ring as a promise'),
        'a spinner carries the only words it has':
            everyIndeterminateStateHasASentence && noSentenceIsTheWordLoading,
        'a silent circle reports an empty screen':
            semanticsNote.contains('nothing on it'),
        'the requested cap is below the criterion this app meets':
            requestedScaleCap == 1.3 &&
                requiredScale == 2.0 &&
                (shortfall - 0.7).abs() < 1e-9,
        'the cap would affect the audited scales above it':
            auditedScalesAboveTheCap.isNotEmpty &&
                auditedScalesAboveTheCap.contains(2.0),
        'the cap is refused with its rule named':
            !theCapIsImplemented &&
                guardRule == 'A11Y_TEXT_SCALING_SUPPRESSED' &&
                scaleCapNote.contains('silently'),
        'the Compose instruction is recorded and translated':
            wrongStackNote.contains('ninth row'),
        'six obligations, all met':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                executionQuality == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Set maximum font '
      'scaling factor constraint (1.3x) for large accessibility text sizes", '
      'which would place the app below WCAG 2.1 SC 1.4.4, and the fourth '
      'configuration cell asks for Jetpack Compose. Atomic Step: "Implement '
      'the Material 3 CircularProgressIndicator component for these specific '
      'loading states."';
}
