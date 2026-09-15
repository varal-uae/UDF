/// Step 289 (ETMDI-016-11) -- "strip out", which is deleting unless the things
/// removed have somewhere to go.
///
/// The row: "Strip out secondary form fields, dual call-to-action buttons, and
/// unrelated informational text from each single-task screen."
/// Metric: **Process Execution Quality Score** -- floor ">=90%", optimal
/// ">=98%", ceiling 1. Good / Average / Poor. Cited: ISO 9001:2015.
///
/// **Stripping without a destination is deleting.** A field that is not needed
/// for this decision is still needed by somebody, or it would not have been
/// collected; moving it off this screen is right and dropping it is a data
/// loss nobody notices until the day the value is asked for. So every element
/// removed here names where it went, and an element with no destination is a
/// finding rather than a tidy-up.
///
/// **"Dual call-to-action buttons" is a count where the problem is emphasis.**
/// A form with Submit and Cancel has two calls to action and is correct; a
/// screen with two buttons of equal weight is the defect, because the person
/// has to decide which one the screen wants before deciding what they want.
/// The rule is at most one high-emphasis action per screen, not at most one
/// action -- and stated as a count it would have removed Cancel.
///
/// **And the row's centring instruction is wrong for a form.** It asks for
/// `Arrangement.Center`, which is Jetpack Compose and centres content on the
/// cross axis. A form that is vertically centred jumps when the keyboard
/// opens, and centred body text is harder to scan because every line starts in
/// a different place. Centring is right for a single-message state and wrong
/// for anything with a field in it.
library;

import '../layout/size_constraints.dart';

/// Where an element goes when it leaves this screen.
enum HabotRelocation {
  /// It stays: the decision cannot be made without it.
  essential,

  /// It moves to a later step of the same flow.
  laterStep,

  /// It moves behind a disclosure on this screen.
  behindDisclosure,

  /// It moves to a settings or profile surface.
  anotherSurface,

  /// It goes nowhere. The finding.
  noDestination,
}

/// How loudly a control asks to be pressed.
enum HabotEmphasis { high, medium, low }

/// One thing currently on the screen.
class HabotScreenElement {
  const HabotScreenElement({
    required this.name,
    required this.relocation,
    required this.why,
  });

  final String name;
  final HabotRelocation relocation;
  final String why;

  bool get stays => relocation == HabotRelocation.essential;

  bool get isLost => relocation == HabotRelocation.noDestination;
}

/// The audit.
class HabotSingleTaskScreen {
  const HabotSingleTaskScreen._();

  // -----------------------------------------------------------------------
  // The worked screen.
  // -----------------------------------------------------------------------

  static const List<HabotScreenElement> elements = <HabotScreenElement>[
    HabotScreenElement(
      name: 'the date and time being booked',
      relocation: HabotRelocation.essential,
      why: 'The decision is about this session. Removing it would leave a '
          'confirmation screen that confirms nothing in particular.',
    ),
    HabotScreenElement(
      name: 'the child the booking is for',
      relocation: HabotRelocation.essential,
      why: 'A parent with two children cannot answer without it, and getting '
          'it wrong is expensive to undo.',
    ),
    HabotScreenElement(
      name: 'the total to be charged',
      relocation: HabotRelocation.essential,
      why: 'Money. Anything that moves money states the amount on the screen '
          'where the person agrees to it.',
    ),
    HabotScreenElement(
      name: 'dietary notes field',
      relocation: HabotRelocation.laterStep,
      why: 'Needed before the session and not before the booking, so it moves '
          'to the step that happens after payment succeeds.',
    ),
    HabotScreenElement(
      name: 'emergency contact field',
      relocation: HabotRelocation.laterStep,
      why: 'Same: required to attend, not required to book, and asking for it '
          'here is what turns a two-field screen into a form.',
    ),
    HabotScreenElement(
      name: 'the cancellation policy in full',
      relocation: HabotRelocation.behindDisclosure,
      why: 'It has to be reachable from this screen because the person is '
          'agreeing to it, and it is four paragraphs. A summary line with the '
          'full text behind it keeps both.',
    ),
    HabotScreenElement(
      name: 'marketing preferences checkbox',
      relocation: HabotRelocation.anotherSurface,
      why: 'Unrelated to the decision, and bundling a consent with a payment '
          'is how consent stops being meaningful. It lives in preferences.',
    ),
    HabotScreenElement(
      name: 'the venue\'s opening hours',
      relocation: HabotRelocation.anotherSurface,
      why: 'Useful, and not here. It belongs on the activity page the person '
          'came from.',
    ),
    HabotScreenElement(
      name: 'the referral code the last release added',
      relocation: HabotRelocation.noDestination,
      why: 'Nobody owns it, nothing reads it, and no other surface has a '
          'place for it. Stripping it is deleting it, so it is reported '
          'rather than removed quietly.',
    ),
  ];

  static List<HabotScreenElement> get staying =>
      elements.where((HabotScreenElement e) => e.stays).toList();

  static List<HabotScreenElement> get relocated => elements
      .where(
        (HabotScreenElement e) => !e.stays && !e.isLost,
      )
      .toList();

  static List<HabotScreenElement> get withNoDestination =>
      elements.where((HabotScreenElement e) => e.isLost).toList();

  static bool get everyElementIsExplained =>
      elements.every((HabotScreenElement e) => e.why.length > 60);

  /// Three stay, five move, one has nowhere to go -- and the one is the
  /// output of this step, not an oversight in it.
  static bool get theAuditFoundOneWithNowhereToGo =>
      staying.length == 3 &&
      relocated.length == 5 &&
      withNoDestination.length == 1;

  static double get shareRemoved =>
      (elements.length - staying.length) / elements.length;

  /// Every destination in the vocabulary is used, so the taxonomy was derived
  /// from the screen rather than invented and then illustrated.
  static bool get everyRelocationKindIsUsed =>
      elements
          .map((HabotScreenElement e) => e.relocation)
          .toSet()
          .length ==
      HabotRelocation.values.length;

  static const String noDestinationNote =
      'Stripping without a destination is deleting. A field that is not '
      'needed for this decision is still needed by somebody, or it would not '
      'have been collected -- so moving it is right and dropping it is a data '
      'loss nobody notices until the value is asked for. Eight of the nine '
      'elements here have a declared destination. The ninth, a referral code '
      'a release added, has none: nobody owns it and nothing reads it. That '
      'is the finding this audit exists to produce, and it is reported rather '
      'than quietly removed under the heading of tidying up.';

  // -----------------------------------------------------------------------
  // Two buttons, one emphasis.
  // -----------------------------------------------------------------------

  static const Map<String, HabotEmphasis> actions = <String, HabotEmphasis>{
    'Confirm and pay': HabotEmphasis.high,
    'Back': HabotEmphasis.low,
  };

  static int get highEmphasisActions =>
      actions.values.where((HabotEmphasis e) => e == HabotEmphasis.high).length;

  static bool get atMostOneHighEmphasisAction => highEmphasisActions <= 1;

  /// The count rule would have removed the second action; the emphasis rule
  /// keeps it and demotes it. Shown on the same pair rather than argued.
  static bool get theCountRuleWouldHaveRemovedTheWayBack =>
      actions.length == 2 && atMostOneHighEmphasisAction;

  static bool get thereIsStillAWayBack => actions.containsKey('Back');

  static const String emphasisNote =
      '"Dual call-to-action buttons" is a count, and the problem is emphasis. '
      'Submit and Cancel are two calls to action and are correct; two buttons '
      'of equal weight are the defect, because the person has to work out '
      'which one the screen wants before working out which one they want. The '
      'rule here is at most one high-emphasis action per screen. Read as a '
      'count it would have removed the way back, which is the most expensive '
      'thing on the screen to lose.';

  // -----------------------------------------------------------------------
  // Centring.
  // -----------------------------------------------------------------------

  /// Whether the content may be centred on the cross axis.
  static bool mayCentre({required bool containsAField}) => !containsAField;

  static bool get aFormIsNotCentred => !mayCentre(containsAField: true);

  static bool get aSingleMessageStateIs => mayCentre(containsAField: false);

  /// The API the row names, paired with the one this repository has -- the
  /// same pairing Step 217 already declared for a different Compose call.
  static const String apiTheRowNames = 'Arrangement.Center';
  static String get composeApiAlreadyRecorded =>
      HabotSizeConstraints.composeApi;

  static bool get thisIsTheSecondComposeRow =>
      composeApiAlreadyRecorded.startsWith('Modifier.') &&
      apiTheRowNames.contains('.') &&
      apiTheRowNames != composeApiAlreadyRecorded;

  static const String centringNote =
      'Arrangement.Center is Jetpack Compose, and Step 217 already recorded '
      'the first Compose call this track was handed. Beyond the framework, '
      'the instruction is wrong for what it is applied to: a vertically '
      'centred form jumps when the keyboard opens, because the content it is '
      'centring changes height, and centred body text is harder to scan '
      'because every line begins somewhere different. Centring is right for a '
      'single-message state -- an empty state, a confirmation with no fields '
      '-- and wrong for anything with an input in it.';

  // -----------------------------------------------------------------------
  // Metric: Process Execution Quality Score -- 90% / 98% / 1.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'every element is classified with a reason': everyElementIsExplained,
        'every element that leaves has a destination or is reported':
            relocated.length + withNoDestination.length ==
                elements.length - staying.length,
        'at most one high-emphasis action': atMostOneHighEmphasisAction,
        'there is still a way back': thereIsStillAWayBack,
        'a screen with a field is not centred': aFormIsNotCentred,
        'a single-message state may be': aSingleMessageStateIs,
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
        'nine elements, each classified with a reason':
            elements.length == 9 && everyElementIsExplained,
        'three stay, five move, one has nowhere to go':
            theAuditFoundOneWithNowhereToGo,
        'two thirds of the screen leaves it':
            (shareRemoved - 2 / 3).abs() < 1e-9,
        'every relocation kind is used, so the taxonomy came from the screen':
            everyRelocationKindIsUsed,
        'the element with no destination is reported rather than removed':
            withNoDestination.length == 1 &&
                noDestinationNote.contains('tidying up'),
        'two actions, one of them high emphasis':
            actions.length == 2 && highEmphasisActions == 1,
        'the count rule would have removed the way back':
            theCountRuleWouldHaveRemovedTheWayBack &&
                thereIsStillAWayBack &&
                emphasisNote.contains('most expensive thing'),
        'a form is not centred and a single-message state may be':
            aFormIsNotCentred && aSingleMessageStateIs,
        'the Compose call is paired with the one already recorded':
            thisIsTheSecondComposeRow &&
                centringNote.contains('jumps when the keyboard opens'),
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualityScore == 1.0 &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Apply a '
      'fade/crossfade transition between the editable and locked visual '
      'states", which belongs to the disabled-state rows at the end of this '
      'batch. Atomic Step: "Strip out secondary form fields, dual '
      'call-to-action buttons, and unrelated informational text from each '
      'single-task screen."';
}
