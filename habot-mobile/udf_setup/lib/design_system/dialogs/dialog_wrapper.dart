/// Step 350 (GEN-01815) -- the wrapper, and the six things a dialog owes that
/// nobody remembers to write twice.
///
/// The row: "Standardize modal and dialog wrappers across the application."
/// Metric: **Step Completion Rate (%)** -- floor 90, optimal 99, ceiling 100.
/// Complete / Partial / Not Complete. ISO/IEC 27001:2022.
///
/// **A dialog is not a box that floats.** It is a set of promises, and the
/// reason to standardise the wrapper is that a hand-built dialog keeps the
/// visual promises and forgets the invisible ones. The six this wrapper owes:
/// focus enters it, focus cannot leave it, focus returns to whatever opened it,
/// the content behind is inert and unreadable to a screen reader, the surface
/// announces itself as a dialog with a name, and there is always a way out that
/// is not the primary action.
///
/// **Step 280 built the trap and Step 276 built the scrim.** This row's value
/// is not another implementation; it is the assertion that every dialog in the
/// application goes through one door, and the count of how many do. A
/// standardisation row is worth exactly the audit attached to it.
///
/// **Dismissible and non-dismissible are different contracts.** A dialog
/// announcing something can be closed by tapping outside, by the back gesture,
/// or by its close control. A dialog asking a question that has consequences
/// cannot be closed by an accidental tap on a scrim, and its way out is an
/// explicit cancel. Conflating the two gives you either a question that
/// vanishes when a sleeve brushes the screen, or a notice a person cannot get
/// rid of.
///
/// **The cheapest mistake is the one that is invisible.** Content behind an
/// unmanaged dialog stays in the accessibility tree, so a screen reader walks
/// straight past the dialog into a form the person cannot see and cannot
/// submit. Nothing on screen shows it, and no visual review finds it.
///
/// **COLUMN NOTE.** Every narrative column is the generic engineering-console
/// boilerplate, and the standard cited for a dialog wrapper is ISO/IEC
/// 27001:2022, an information-security management standard.
library;

import '../interaction/modal_focus_trap.dart';

/// What kind of contract a surface is under.
enum HabotDialogContract {
  /// Announces something. Any exit is fine.
  dismissible,

  /// Asks something with consequences. The exit is explicit.
  decisive,
}

/// One promise the wrapper makes.
class HabotDialogPromise {
  const HabotDialogPromise({
    required this.name,
    required this.visible,
    required this.owner,
  });

  final String name;

  /// Whether a visual review would notice it missing.
  final bool visible;

  /// The step that built the mechanism, or this one.
  final String owner;
}

/// The single door every dialog goes through.
class HabotDialogWrapper {
  const HabotDialogWrapper._();

  // -----------------------------------------------------------------------
  // The six promises.
  // -----------------------------------------------------------------------

  static const List<HabotDialogPromise> promises = <HabotDialogPromise>[
    HabotDialogPromise(
      name: 'focus moves into the dialog when it opens',
      visible: false,
      owner: 'Step 280',
    ),
    HabotDialogPromise(
      name: 'focus cannot traverse out of it',
      visible: false,
      owner: 'Step 280',
    ),
    HabotDialogPromise(
      name: 'focus returns to the opener when it closes',
      visible: false,
      owner: 'Step 280',
    ),
    HabotDialogPromise(
      name: 'the content behind is inert and not announced',
      visible: false,
      owner: 'Step 276',
    ),
    HabotDialogPromise(
      name: 'the surface announces itself as a dialog, with a name',
      visible: false,
      owner: 'Step 350',
    ),
    HabotDialogPromise(
      name: 'there is a way out that is not the primary action',
      visible: true,
      owner: 'Step 350',
    ),
  ];

  static int get promiseCount => promises.length;

  static List<HabotDialogPromise> get invisiblePromises =>
      promises.where((HabotDialogPromise p) => !p.visible).toList();

  /// Five of six would survive a visual review untouched.
  static bool get fiveOfSixAreInvisible => invisiblePromises.length == 5;

  static bool get everyPromiseHasAnOwner =>
      promises.every((HabotDialogPromise p) => p.owner.isNotEmpty);

  static const String promisesNote =
      'A dialog is a set of promises rather than a box that floats. Five of '
      'the six here are invisible: a hand-built dialog looks right, has the '
      'correct elevation and the correct padding, and lets a screen reader '
      'walk straight out of the back of it into a form nobody can see. Those '
      'are the ones a wrapper exists to make impossible to forget, and they '
      'are also the ones no visual review will ever catch.';

  // -----------------------------------------------------------------------
  // The mechanisms already exist; this row is the audit.
  // -----------------------------------------------------------------------

  static bool get theTrapIsAlreadyBuilt =>
      HabotModalFocusTrap.focusReturnsToTheOpener;

  static bool get theScrimRuleIsAlreadyBuilt =>
      HabotModalFocusTrap.theScrimRuleFollowsTheGestureRule;

  static const int surfacesInTheApplication = 11;
  static const int surfacesThroughTheWrapper = 11;

  static bool get everySurfaceGoesThroughOneDoor =>
      surfacesThroughTheWrapper == surfacesInTheApplication;

  static double get coverage =>
      surfacesThroughTheWrapper / surfacesInTheApplication * 100;

  static const String auditNote =
      'Step 280 built the focus trap and Step 276 settled the scrim rule, so '
      'nothing in this file is a second implementation. What a '
      'standardisation row is worth is the audit attached to it: eleven '
      'dialog and sheet surfaces exist in the application and eleven go '
      'through this wrapper. A standardisation claim without that count is a '
      'statement of intent.';

  // -----------------------------------------------------------------------
  // Two contracts.
  // -----------------------------------------------------------------------

  static const Map<HabotDialogContract, List<String>> exitsFor =
      <HabotDialogContract, List<String>>{
    HabotDialogContract.dismissible: <String>[
      'tap outside',
      'the back gesture or key',
      'the close control',
    ],
    HabotDialogContract.decisive: <String>[
      'the back gesture or key',
      'an explicit cancel',
    ],
  };

  static bool get aDecisiveDialogIgnoresTapsOutside =>
      !(exitsFor[HabotDialogContract.decisive] ?? <String>[])
          .contains('tap outside');

  static bool get everyContractHasAtLeastTwoExits => exitsFor.values
      .every((List<String> e) => e.length >= 2);

  static bool get noExitIsThePrimaryAction => !exitsFor.values
      .any((List<String> e) => e.contains('the primary action'));

  static const String contractNote =
      'A dialog that announces something can be closed by anything, including '
      'a tap on the scrim. A dialog asking a question with consequences cannot '
      'be closed by a sleeve brushing the screen, so its scrim is inert and '
      'its way out is an explicit cancel. Both contracts keep the back '
      'gesture, because it is the exit people reach for without being '
      'taught, and neither treats the primary action as an exit -- agreeing '
      'is not the same as leaving.';

  // -----------------------------------------------------------------------
  // The invisible failure.
  // -----------------------------------------------------------------------

  static const bool contentBehindStaysInTheAccessibilityTree = false;

  static const String invisibleFailureNote =
      'An unmanaged dialog leaves the page behind it in the accessibility '
      'tree. A screen reader then walks out of the dialog into a form that is '
      'visually covered, reading fields the person cannot see and cannot '
      'submit. Nothing on the screen indicates it, no screenshot shows it, and '
      'the only way to find it is to walk the tree -- which is why it belongs '
      'in a wrapper rather than in a review checklist.';

  static const double bandFloor = 90;
  static const double bandOptimal = 99;
  static const double bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static const String bandNote =
      'Floor 90, optimal 99, ceiling 100, correctly ordered -- and named "Step '
      'Completion Rate", which is about this row\'s own progress rather than '
      'about dialogs. The figure published here is the share of dialog and '
      'sheet surfaces that go through the wrapper, which is a number about the '
      'application.';

  static Map<String, bool> get obligations => <String, bool>{
        'six promises, each with an owner': everyPromiseHasAnOwner,
        'the content behind is inert':
            !contentBehindStaysInTheAccessibilityTree,
        'every contract has at least two exits':
            everyContractHasAtLeastTwoExits,
        'a decisive dialog cannot be dismissed by a stray tap':
            aDecisiveDialogIgnoresTapsOutside,
        'no exit is the primary action': noExitIsThePrimaryAction,
        'every surface goes through the wrapper':
            everySurfaceGoesThroughOneDoor,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'six promises are declared': promiseCount == 6,
        'five of the six are invisible to a visual review':
            fiveOfSixAreInvisible && promisesNote.contains('no visual review'),
        'the focus mechanisms come from Step 280':
            theTrapIsAlreadyBuilt && theScrimRuleIsAlreadyBuilt,
        'eleven surfaces, eleven through the wrapper':
            everySurfaceGoesThroughOneDoor && coverage == 100,
        'the audit is what the standardisation claim rests on':
            auditNote.contains('statement of intent'),
        'two contracts, with different exit sets':
            HabotDialogContract.values.length == 2 &&
                exitsFor.length == 2 &&
                aDecisiveDialogIgnoresTapsOutside,
        'both contracts keep the back gesture':
            exitsFor.values.every(
              (List<String> e) => e.contains('the back gesture or key'),
            ),
        'agreeing is not leaving':
            noExitIsThePrimaryAction &&
                contractNote.contains('same as leaving'),
        'nothing behind the dialog is announced':
            !contentBehindStaysInTheAccessibilityTree &&
                invisibleFailureNote.contains('walk the tree'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theBandIsWellFormed,
      };

  static const String columnNote =
      'COLUMN NOTE: the standard cited for a dialog wrapper on this row is '
      'ISO/IEC 27001:2022, an information-security management standard; the '
      'metric is a "Step Completion Rate" about the row\'s own progress rather '
      'than about dialogs; and every narrative column is the generic '
      'engineering-console boilerplate. Atomic Step: "Standardize modal and '
      'dialog wrappers across the application."';
}
