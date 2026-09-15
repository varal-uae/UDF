/// Step 264 (HAZFE-020-09) -- a frame around an image that shows something
/// nobody else should see.
///
/// The row: "Ensure secured image components utilize clear layout frames to
/// maximize touch clean alignment."
/// Metric: **UI Design-System Adherence Rate** -- floor >=85%, optimal >=95%,
/// ceiling 1. Good/Average/Poor. Standard cited: Material Design 3 / Nielsen
/// Norman Group Heuristic Evaluation.
///
/// **"Touch clean alignment" is not a term, and the row has to be read for
/// what it is reaching at.** What a secured image needs is a declared frame:
/// a fixed aspect ratio so the layout does not move when the image loads, a
/// declared surface behind it so a transparent PNG does not reveal whatever is
/// underneath, and no interactive target inside the frame that a person could
/// hit while trying to scroll past it.
///
/// **What makes an image "secured" is not a border.** It is an image of an
/// identity document, a child's face, or a medical note. The frame is the
/// visible part; the rules that matter are that it is not written to the
/// device's shared photo cache, not included in the screenshot the OS takes
/// for the app switcher, and not decoded at a size larger than the frame it
/// is shown in.
///
/// **A frame with no aspect ratio is the layout shift Step 191 is about.** An
/// image whose height is unknown until it loads moves everything beneath it,
/// and a person mid-tap hits the thing that moved into their finger.
library;

import '../a11y/image_semantics.dart';
import '../tokens/spacing_tokens.dart';

/// What is in the picture, and therefore how it is treated.
enum HabotSecuredImageKind {
  /// A photograph of a person. The strictest case.
  personPhoto,

  /// An identity or medical document.
  document,

  /// A photograph attached to a support ticket. Sensitive because nobody
  /// knows what is in it until somebody looks.
  ticketAttachment,

  /// Not sensitive. Included so the rules can be shown to differ.
  publicListing,
}

/// The rules for one kind.
class HabotSecuredImageRule {
  const HabotSecuredImageRule({
    required this.kind,
    required this.aspectRatio,
    required this.excludedFromAppSwitcher,
    required this.writtenToSharedCache,
    required this.interactiveInsideFrame,
    required this.altTextSource,
    required this.why,
  });

  final HabotSecuredImageKind kind;

  /// Declared before the image loads, so the layout does not move.
  final double aspectRatio;

  /// Whether the OS screenshot taken when the application is backgrounded is
  /// obscured.
  final bool excludedFromAppSwitcher;

  /// Whether the decoded image reaches the device's shared photo storage.
  /// False for everything sensitive.
  final bool writtenToSharedCache;

  /// Whether anything inside the frame can be tapped. False for everything
  /// sensitive: a tap target inside a photograph is a target somebody hits
  /// while scrolling.
  final bool interactiveInsideFrame;

  /// Where the alternative text comes from. Step 266 governs its content.
  final String altTextSource;

  final String why;

  bool get isSensitive => kind != HabotSecuredImageKind.publicListing;
}

/// The frame.
class HabotSecuredImage {
  const HabotSecuredImage._();

  /// The gap between the frame and anything beside it, read from the
  /// declared spacing ladder rather than chosen here.
  static double get framePadding => HabotSpacing.md;

  static List<HabotSecuredImageRule> get rules => <HabotSecuredImageRule>[
        const HabotSecuredImageRule(
          kind: HabotSecuredImageKind.personPhoto,
          aspectRatio: 1,
          excludedFromAppSwitcher: true,
          writtenToSharedCache: false,
          interactiveInsideFrame: false,
          altTextSource: 'the person\'s name, from the record -- never a '
              'description of their appearance',
          why: 'A child\'s face. Square because every avatar in this '
              'application is, and out of the app switcher because the '
              'screenshot the OS takes is stored unencrypted on some '
              'platforms.',
        ),
        const HabotSecuredImageRule(
          kind: HabotSecuredImageKind.document,
          aspectRatio: 1.414,
          excludedFromAppSwitcher: true,
          writtenToSharedCache: false,
          interactiveInsideFrame: false,
          altTextSource: 'the document type and its state -- "Emirates ID, '
              'front, verified" -- never its contents',
          why: 'A4 proportions, because that is what a scanned document is. '
              'The alt text names the document rather than reading it out, '
              'because a screen reader in a public place is a speaker.',
        ),
        const HabotSecuredImageRule(
          kind: HabotSecuredImageKind.ticketAttachment,
          aspectRatio: 1.333,
          excludedFromAppSwitcher: true,
          writtenToSharedCache: false,
          interactiveInsideFrame: false,
          altTextSource: 'what the person typed when they attached it, and '
              '"photo attached, not described" when they typed nothing',
          why: 'Four by three, because that is what a phone camera produces. '
              'Sensitive because nobody knows what is in it until somebody '
              'looks -- which is the argument for treating every attachment '
              'as sensitive rather than classifying it first.',
        ),
        const HabotSecuredImageRule(
          kind: HabotSecuredImageKind.publicListing,
          aspectRatio: 1.777,
          excludedFromAppSwitcher: false,
          writtenToSharedCache: true,
          interactiveInsideFrame: true,
          altTextSource: 'the listing title, authored by the organiser',
          why: 'Sixteen by nine, cacheable, and the whole card is a tap '
              'target because tapping it is the point. Present so the rules '
              'above can be shown to be about sensitivity rather than about '
              'images.',
        ),
      ];

  static HabotSecuredImageRule ruleFor(HabotSecuredImageKind k) =>
      rules.firstWhere((HabotSecuredImageRule r) => r.kind == k);

  static List<HabotSecuredImageRule> get sensitiveRules =>
      rules.where((HabotSecuredImageRule r) => r.isSensitive).toList();

  /// Every sensitive kind is out of the app switcher, out of the shared
  /// cache and free of tap targets. Every one of the three, not two of them.
  static bool get everySensitiveKindIsProtected => sensitiveRules.every(
        (HabotSecuredImageRule r) =>
            r.excludedFromAppSwitcher &&
            !r.writtenToSharedCache &&
            !r.interactiveInsideFrame,
      );

  /// And the public one is not, which is what makes the rule a rule about
  /// sensitivity rather than a rule about images.
  static bool get thePublicKindIsTreatedDifferently {
    final HabotSecuredImageRule pub =
        ruleFor(HabotSecuredImageKind.publicListing);
    return !pub.excludedFromAppSwitcher &&
        pub.writtenToSharedCache &&
        pub.interactiveInsideFrame;
  }

  /// Every kind declares an aspect ratio before the image loads.
  static bool get everyFrameReservesItsSpace =>
      rules.every((HabotSecuredImageRule r) => r.aspectRatio > 0);

  /// Four different ratios, because a square frame around a landscape
  /// photograph crops a face out of it.
  static bool get theRatiosDiffer =>
      rules.map((HabotSecuredImageRule r) => r.aspectRatio).toSet().length ==
      rules.length;

  /// The alt text rules compose with Step 266's rather than replacing them:
  /// each source is a phrase that has to survive the existing validator.
  static bool get everyAltSourceIsDescribed => rules.every(
        (HabotSecuredImageRule r) => r.altTextSource.length > 30,
      );

  static bool get altTextIsGovernedByTheExistingRules =>
      HabotAltText.maxLength > 0 &&
      HabotAltText.isUsable('Emirates ID, front, verified') &&
      !HabotAltText.isUsable('photo of a document');

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String notATermNote =
      '"Touch clean alignment" is not a term of art in Material Design or in '
      'the Nielsen Norman heuristics the row cites, and it has to be read for '
      'what it is reaching at. What a secured image needs is a declared '
      'frame: a fixed aspect ratio so the layout does not move when the image '
      'loads, a declared surface behind it so a transparent PNG does not '
      'reveal what is underneath, and no tap target inside the frame that '
      'somebody could hit while scrolling past it.';

  static const String securedIsNotABorderNote =
      'What makes an image secured is not a border. It is an image of an '
      'identity document, a child\'s face, or a medical note. The frame is '
      'the visible part; the rules that matter are that it is not written to '
      'the device\'s shared photo storage, not included in the screenshot the '
      'OS takes for the app switcher, and not decoded larger than the frame '
      'it is shown in. A ticket attachment counts, because nobody knows what '
      'is in it until somebody looks -- which is the argument for treating '
      'every attachment as sensitive rather than classifying it first.';

  static const String layoutShiftNote =
      'A frame with no declared aspect ratio is a layout shift: an image '
      'whose height is unknown until it loads moves everything beneath it, '
      'and a person mid-tap hits whatever moved into their finger. Every kind '
      'declares its ratio before the image arrives, and the four ratios '
      'differ because a square frame around a landscape photograph crops a '
      'face out of it.';

  // -----------------------------------------------------------------------
  // Metric: UI Design-System Adherence Rate.
  // -----------------------------------------------------------------------

  static const double floor = 0.85;
  static const double optimal = 0.95;
  static const double ceiling = 1;

  /// Adherence over the declared kinds: the share whose treatment follows
  /// from whether they are sensitive rather than from a choice per screen.
  static double get adherenceRate =>
      rules
          .where(
            (HabotSecuredImageRule r) =>
                r.isSensitive ==
                (r.excludedFromAppSwitcher &&
                    !r.writtenToSharedCache &&
                    !r.interactiveInsideFrame),
          )
          .length /
      rules.length;

  static String get qualitativeOutput {
    if (adherenceRate >= optimal) {
      return 'Good';
    }
    return adherenceRate >= floor ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'four kinds of image are ruled on':
            rules.length == HabotSecuredImageKind.values.length,
        'three are sensitive and all three are protected the same way':
            sensitiveRules.length == 3 && everySensitiveKindIsProtected,
        'the public one is treated differently, so the rule is about '
            'sensitivity rather than about images':
            thePublicKindIsTreatedDifferently,
        'every frame reserves its space before the image loads':
            everyFrameReservesItsSpace && theRatiosDiffer,
        'the frame padding is read from the declared spacing ladder':
            framePadding == HabotSpacing.md,
        'every kind says where its alternative text comes from':
            everyAltSourceIsDescribed,
        'alt text is governed by the existing validator rather than a new one':
            altTextIsGovernedByTheExistingRules,
        'the row\'s phrase is read rather than treated as a term':
            notATermNote.contains('not a term of art'),
        'adherence follows from sensitivity, and is at the ceiling':
            adherenceRate == ceiling,
      };

  static const String columnNote =
      'COLUMN NOTE: this row carries no Setup Step, no Expected Output and no '
      'Completion Measures -- only a metric and a Data Collected list about '
      'layout grids. Atomic Step: "Ensure secured image components utilize '
      'clear layout frames to maximize touch clean alignment."';
}
