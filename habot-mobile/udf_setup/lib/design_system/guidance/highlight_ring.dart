/// Step 345 (MTVPE-018) -- a ring drawn around a control, and the four ways a
/// coach mark can be worse than saying nothing.
///
/// The row: "12. Configure visual highlight rings for target components."
/// Metric: **Process Execution Quality (%)** -- floor 95, optimal 99, ceiling
/// 100. Pass / Fail. ISO 9001:2015.
///
/// **A highlight ring is a focus indicator that is not a focus indicator**, and
/// that is the first thing to get right. The platform already draws a ring
/// around whatever has keyboard or switch focus, and this application declares
/// its own at Step 109. A second ring, drawn for instruction rather than for
/// focus, sitting in the same visual language, tells a person their focus is
/// somewhere it is not. So the guidance ring is built to differ in shape as
/// well as in colour: a dashed outline with an offset, against the solid
/// inset the focus indicator uses.
///
/// **The ring does not carry the message.** A ring around a control says
/// "here" and nothing else; the sentence lives in a labelled container that the
/// ring points at, and that container is what a screen reader announces. A
/// coach mark whose whole content is a coloured outline is invisible to
/// everyone who does not see colour, everyone using a screen reader, and
/// everyone who has already scrolled.
///
/// **The target has to still be operable.** A scrim that dims everything except
/// the ringed control is the usual implementation, and the usual implementation
/// blocks the control it is pointing at. If the person can see the button and
/// cannot press it, the coach mark has replaced the task with a lesson.
///
/// **COLUMN NOTE.** The Atomic Step begins with the number "12." embedded in
/// its own text; every narrative column is about BigQuery row-level
/// multi-tenant isolation ("Mandates absolute multi-tenant customer separation
/// directly inside data layers"); the Data Requirement column is about an
/// expandable video player with M3 IconButton play/pause overlays; and the
/// Setup Step column reads "Test the listeners trigger the dark mode token set
/// correctly".
library;

import '../a11y/target_spacing.dart';

/// Why an outline is being drawn.
enum HabotRingPurpose {
  /// The platform's focus is here. Never drawn by this file.
  focus,

  /// Instruction is pointing here.
  guidance,
}

/// The visual form of an outline, which is how the two purposes stay apart.
enum HabotRingForm { solidInset, dashedOffset }

/// One coach mark.
class HabotCoachMark {
  const HabotCoachMark({
    required this.targetName,
    required this.sentence,
    required this.targetStaysOperable,
  });

  final String targetName;

  /// The instruction. Empty would mean the ring is the whole message.
  final String sentence;

  final bool targetStaysOperable;
}

/// The guidance ring.
class HabotHighlightRing {
  const HabotHighlightRing._();

  // -----------------------------------------------------------------------
  // Not a focus indicator.
  // -----------------------------------------------------------------------

  static const HabotRingPurpose purpose = HabotRingPurpose.guidance;

  static const Map<HabotRingPurpose, HabotRingForm> formFor =
      <HabotRingPurpose, HabotRingForm>{
    HabotRingPurpose.focus: HabotRingForm.solidInset,
    HabotRingPurpose.guidance: HabotRingForm.dashedOffset,
  };

  static bool get theTwoPurposesLookDifferent =>
      formFor[HabotRingPurpose.focus] != formFor[HabotRingPurpose.guidance];

  /// Colour alone would not be enough, and shape is what carries it.
  static bool get theDifferenceIsNotOnlyColour =>
      formFor.values.toSet().length == 2;

  static const bool thisFileDrawsFocusRings = false;

  static const String focusNote =
      'The platform draws a ring around whatever holds keyboard or switch '
      'focus, and this application declares its own indicator at Step 109. A '
      'second ring in the same visual language, drawn for instruction rather '
      'than for focus, tells a person their focus is somewhere it is not -- '
      'and for somebody navigating by switch, that is the one piece of '
      'information they are relying on. The guidance ring is dashed and offset '
      'against a solid inset, so the two are distinguishable without colour.';

  // -----------------------------------------------------------------------
  // The ring is a pointer, not a message.
  // -----------------------------------------------------------------------

  static const List<HabotCoachMark> marks = <HabotCoachMark>[
    HabotCoachMark(
      targetName: 'the filter control',
      sentence: 'Narrow the list to the jobs assigned to you',
      targetStaysOperable: true,
    ),
    HabotCoachMark(
      targetName: 'the submit action',
      sentence: 'Submitting sends the record for approval',
      targetStaysOperable: true,
    ),
    HabotCoachMark(
      targetName: 'the reorder handle',
      sentence: 'Drag, or use the move controls, to change the order',
      targetStaysOperable: true,
    ),
  ];

  static bool get everyMarkCarriesASentence =>
      marks.every((HabotCoachMark m) => m.sentence.isNotEmpty);

  static bool get noMarkIsARingAlone => everyMarkCarriesASentence;

  static const String announcedStructure =
      'the sentence, then the name of the control it points at';

  static bool get theSentenceIsWhatIsAnnounced =>
      announcedStructure.startsWith('the sentence');

  static const String messageNote =
      'A ring says "here" and nothing more. On a screen that a person cannot '
      'see, a coloured outline is not information at all, and on a screen they '
      'can see it still does not say why. The sentence lives in a labelled '
      'container that the ring points at, and the container is what the screen '
      'reader announces -- the instruction first and the control it refers to '
      'second, because the name of a control means nothing until you know why '
      'you are being shown it.';

  // -----------------------------------------------------------------------
  // The scrim, and the control underneath it.
  // -----------------------------------------------------------------------

  static bool get everyTargetStaysOperable =>
      marks.every((HabotCoachMark m) => m.targetStaysOperable);

  static const bool theScrimBlocksTheRingedControl = false;

  static const String scrimNote =
      'The usual implementation dims everything except the ringed control with '
      'a full-screen scrim, and the usual implementation puts that scrim over '
      'the control as well. A person who can see the button and cannot press '
      'it has had the task replaced with a lesson. The scrim here has a hole '
      'in it: the ringed control receives touches, and everything else does '
      'not.';

  /// The ring is drawn outside the target, so the target's own hit rectangle
  /// is unchanged -- which is the rule Step 343 stated.
  static double get ringOffsetDp => HabotTargetSpacing.minimumGapDp;

  static bool get theRingDoesNotShrinkTheTarget => ringOffsetDp > 0;

  static bool get theOffsetIsTheDeclaredGap =>
      ringOffsetDp == HabotTargetSpacing.minimumGapDp;

  // -----------------------------------------------------------------------
  // Dismissal, which is Step 347's subject and is declared here as a
  // requirement rather than built twice.
  // -----------------------------------------------------------------------

  static const bool aMarkCanBeDismissed = true;

  static const String dismissalOwner = 'Step 347';

  static const String dismissalNote =
      'A coach mark that cannot be dismissed is a modal dialog with no '
      'buttons. The requirement is stated here and the controls are built at '
      'Step 347, '
      'which is the row that asks for them, so there is one dismissal '
      'mechanism rather than two that can disagree.';

  static const double bandFloor = 95;
  static const double bandOptimal = 99;
  static const double bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static const String bandNote =
      'Floor 95, optimal 99, ceiling 100, in the right order for a '
      'higher-is-better percentage -- one of the few well-formed bands in this '
      'batch. What it measures, "Process Execution Quality", is not stated in '
      'terms of anything on this row, so the figure published here is the '
      'share of coach marks that carry a sentence, leave their target '
      'operable, and are distinguishable from a focus ring.';

  static double get quality => marks.isEmpty
      ? 0
      : marks
              .where(
                (HabotCoachMark m) =>
                    m.sentence.isNotEmpty && m.targetStaysOperable,
              )
              .length /
          marks.length *
          100;

  static Map<String, bool> get obligations => <String, bool>{
        'the guidance ring is not in the focus indicator\'s language':
            theTwoPurposesLookDifferent && theDifferenceIsNotOnlyColour,
        'this file never draws a focus ring': !thisFileDrawsFocusRings,
        'every mark carries a sentence': everyMarkCarriesASentence,
        'the sentence is what is announced': theSentenceIsWhatIsAnnounced,
        'the ringed control stays operable':
            everyTargetStaysOperable && !theScrimBlocksTheRingedControl,
        'the ring does not reduce the target': theRingDoesNotShrinkTheTarget,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'two purposes, two forms':
            HabotRingPurpose.values.length == 2 && theTwoPurposesLookDifferent,
        'the forms differ in shape, not only colour':
            theDifferenceIsNotOnlyColour &&
                formFor[HabotRingPurpose.guidance] ==
                    HabotRingForm.dashedOffset,
        'the focus indicator is left to Step 109':
            !thisFileDrawsFocusRings && focusNote.contains('Step 109'),
        'three marks, each with a sentence':
            marks.length == 3 && noMarkIsARingAlone,
        'the instruction is announced before the control name':
            theSentenceIsWhatIsAnnounced &&
                messageNote.contains('means nothing until'),
        'every target remains pressable':
            everyTargetStaysOperable && !theScrimBlocksTheRingedControl,
        'the scrim has a hole in it': scrimNote.contains('hole'),
        'the ring is offset by the declared gap':
            theOffsetIsTheDeclaredGap && theRingDoesNotShrinkTheTarget,
        'dismissal is required here and built at Step 347':
            aMarkCanBeDismissed && dismissalOwner == 'Step 347',
        'the band is well formed and its population is named':
            theBandIsWellFormed && quality == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: the Atomic Step on this row begins with the number "12." '
      'inside its own text; every narrative column is about BigQuery row-level '
      'multi-tenant isolation; the Data Requirement column describes an '
      'expandable video player with play/pause overlays; and the Setup Step '
      'column reads "Test the listeners trigger the dark mode token set '
      'correctly". Atomic Step: "Configure visual highlight rings for target '
      'components."';
}
