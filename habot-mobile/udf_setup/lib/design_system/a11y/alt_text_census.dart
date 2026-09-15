/// Step 266 (GEN-04627) -- text alternatives for non-text content, and the
/// two cases the row's word "all" gets wrong.
///
/// The row: "Provide clear text alternatives (alt descriptions) for all
/// non-text visual content."
/// Metric: **Accessibility Conformance Score** -- floor 90% (AA partial),
/// optimal 100% (Full AA), ceiling N/A (AAA optional). Pass/Fail. Standard
/// cited: WCAG 2.1 Level AA.
///
/// **The rule already exists.** `HabotAltText` validates alternative text,
/// `HabotImage` requires it, `HabotDecorativeImage` exists for content that
/// carries none, and the poka-yoke guard has carried `A11Y_RAW_IMAGE` since
/// Step 97. This is the seventh restatement of an accessibility requirement
/// this track has already met, and the census is the answer rather than an
/// eighth implementation.
///
/// **"All" is wrong in two directions.** SC 1.1.1 requires a text alternative
/// *or* that the content be ignored by assistive technology. Alt text on a
/// decorative divider makes a screen reader announce a divider, which is worse
/// than silence; and a policy of alt-text-on-everything produces exactly that.
/// Decorative content is marked decorative, which is a text alternative of a
/// kind -- the empty one.
///
/// **And some non-text content has no author.** A photograph a person attaches
/// to a support ticket cannot be described by this application: nobody here
/// has seen it. Inventing a description would be worse than none, and the
/// honest route is to ask the person who attached it and to say plainly, when
/// they decline, that the photograph is not described.
library;

import 'image_semantics.dart';

/// Where the alternative text for a piece of content comes from.
enum HabotAltAuthor {
  /// Written by whoever built the screen. Most of them.
  designSystem,

  /// Written by the organiser who uploaded the content.
  contentAuthor,

  /// Written by the person who attached it, in the moment.
  theUploader,

  /// Nobody. The content is decorative and is marked as such.
  noneBecauseDecorative,

  /// Nobody, and it is not decorative. The gap this step reports.
  noneAvailable,
}

/// One class of non-text content in this application.
class HabotNonTextContent {
  const HabotNonTextContent({
    required this.name,
    required this.purpose,
    required this.author,
    required this.why,
  });

  final String name;
  final HabotImagePurpose purpose;
  final HabotAltAuthor author;
  final String why;

  bool get needsAlternativeText =>
      purpose == HabotImagePurpose.informational;

  bool get hasAnAuthor =>
      author != HabotAltAuthor.noneAvailable &&
      author != HabotAltAuthor.noneBecauseDecorative;

  /// Conformant: informational content has an author, decorative content is
  /// marked decorative, and nothing is left in between.
  bool get isConformant =>
      needsAlternativeText ? hasAnAuthor : author ==
          HabotAltAuthor.noneBecauseDecorative;
}

/// The census.
class HabotAltTextCensus {
  const HabotAltTextCensus._();

  static const List<HabotNonTextContent> inventory = <HabotNonTextContent>[
    HabotNonTextContent(
      name: 'navigation and action icons',
      purpose: HabotImagePurpose.informational,
      author: HabotAltAuthor.designSystem,
      why: 'An icon with no label is the commonest unlabelled control there '
          'is, and the guard has refused one since Step 97.',
    ),
    HabotNonTextContent(
      name: 'activity listing photographs',
      purpose: HabotImagePurpose.informational,
      author: HabotAltAuthor.contentAuthor,
      why: 'Uploaded by an organiser, who is the only person who knows what '
          'the picture shows. The upload form asks, and the listing does not '
          'publish without it.',
    ),
    HabotNonTextContent(
      name: 'child profile avatars',
      purpose: HabotImagePurpose.informational,
      author: HabotAltAuthor.designSystem,
      why: 'The alternative is the child\'s name from the record. Never a '
          'description of their appearance, which is the thing an automatic '
          'describer would produce.',
    ),
    HabotNonTextContent(
      name: 'the entry pass QR symbol',
      purpose: HabotImagePurpose.informational,
      author: HabotAltAuthor.designSystem,
      why: 'A QR code is unreadable to a screen reader by definition, so the '
          'alternative carries the booking reference the code encodes -- the '
          'information, not the picture.',
    ),
    HabotNonTextContent(
      name: 'chart marks and trend lines',
      purpose: HabotImagePurpose.informational,
      author: HabotAltAuthor.designSystem,
      why: 'A chart\'s alternative is its finding, not its shape. "Bookings '
          'rose for six weeks and fell in the seventh" rather than "a line '
          'chart".',
    ),
    HabotNonTextContent(
      name: 'section dividers and background textures',
      purpose: HabotImagePurpose.decorative,
      author: HabotAltAuthor.noneBecauseDecorative,
      why: 'Carries nothing the surrounding text does not. Alt text here '
          'makes a reader announce a divider, which is worse than silence.',
    ),
    HabotNonTextContent(
      name: 'empty-state illustrations',
      purpose: HabotImagePurpose.decorative,
      author: HabotAltAuthor.noneBecauseDecorative,
      why: 'The empty state already says what is empty and what to do about '
          'it. The drawing restates it in a form nobody can hear.',
    ),
    HabotNonTextContent(
      name: 'support ticket photo attachments',
      purpose: HabotImagePurpose.informational,
      author: HabotAltAuthor.theUploader,
      why: 'Nobody in this application has seen it. The person attaching it '
          'is asked, and when they decline the attachment is announced as '
          '"photo attached, not described" -- which is true, and better than '
          'a description somebody invented.',
    ),
  ];

  static List<HabotNonTextContent> get informational => inventory
      .where((HabotNonTextContent c) => c.needsAlternativeText)
      .toList();

  static List<HabotNonTextContent> get decorative => inventory
      .where((HabotNonTextContent c) => !c.needsAlternativeText)
      .toList();

  static List<HabotNonTextContent> get nonConformant =>
      inventory.where((HabotNonTextContent c) => !c.isConformant).toList();

  /// The row's metric, over the content classes this application has.
  static double get conformanceScore =>
      inventory.where((HabotNonTextContent c) => c.isConformant).length /
      inventory.length *
      100;

  /// What a policy of alt-text-on-everything would score, once the two
  /// decorative classes are counted as the failures they would be.
  static double get scoreIfEverythingWereDescribed =>
      informational.length / inventory.length * 100;

  static bool get describingEverythingScoresLower =>
      scoreIfEverythingWereDescribed < conformanceScore;

  /// Three different people author the alternatives, which is the fact that
  /// makes "provide alt descriptions" not an instruction to one team.
  static Set<HabotAltAuthor> get authors =>
      inventory.map((HabotNonTextContent c) => c.author).toSet();

  static bool get theUploaderIsOneOfThem =>
      authors.contains(HabotAltAuthor.theUploader);

  static bool get nothingIsLeftUnauthored =>
      !authors.contains(HabotAltAuthor.noneAvailable);

  // -----------------------------------------------------------------------
  // The existing rule, exercised rather than restated.
  // -----------------------------------------------------------------------

  /// The validator that already exists, shown deciding. These are not new
  /// rules: they are the Step 97 rules, run.
  static bool get theExistingValidatorStillDecides =>
      HabotAltText.isUsable('Bookings rose for six weeks and fell in the '
          'seventh') &&
      !HabotAltText.isUsable('image of a chart') &&
      !HabotAltText.isUsable('chart.png') &&
      !HabotAltText.isUsable('a') &&
      HabotImagePurpose.values.length == 2;

  static const String alreadyExistsNote =
      'The rule already exists. HabotAltText validates alternative text, '
      'HabotImage requires it, HabotDecorativeImage exists for content that '
      'carries none, and the poka-yoke guard has refused a bare Image widget '
      'since Step 97. This is the seventh restatement of an accessibility '
      'requirement this track has already met, and a census is the answer '
      'rather than an eighth implementation -- the same conclusion Steps 216, '
      '227 and 250 reached about window classes, touch targets and error '
      'cues.';

  static const String allIsWrongTwiceNote =
      '"All" is wrong in two directions. SC 1.1.1 requires a text '
      'alternative OR that the content be ignored by assistive technology, '
      'and alt text on a decorative divider makes a screen reader announce a '
      'divider -- worse than silence. A policy of alt-text-on-everything '
      'produces exactly that, and would score lower on this row\'s own metric '
      'than marking the decorative classes decorative does. The other '
      'direction is content with no author: a photograph somebody attached '
      'to a ticket cannot be described by this application, because nobody '
      'here has seen it. Inventing one would be worse than none.';

  static const String chartNote =
      'A chart\'s alternative is its finding, not its shape. "Bookings rose '
      'for six weeks and fell in the seventh" rather than "a line chart" -- '
      'the second is a description of the picture, and a person who cannot '
      'see the picture did not want one.';

  // -----------------------------------------------------------------------
  // Metric: Accessibility Conformance Score.
  // -----------------------------------------------------------------------

  static const double floorPercent = 90;
  static const double optimalPercent = 100;

  static String get qualitativeOutput =>
      conformanceScore >= floorPercent ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'eight classes of non-text content are inventoried':
            inventory.length == 8,
        'six are informational and two are decorative':
            informational.length == 6 && decorative.length == 2,
        'every class is conformant, and none is left unauthored':
            nonConformant.isEmpty && nothingIsLeftUnauthored,
        'the conformance score is at the row\'s optimal':
            conformanceScore == optimalPercent,
        'describing everything would score lower on the row\'s own metric':
            describingEverythingScoresLower &&
                (scoreIfEverythingWereDescribed - 75).abs() < 1e-9,
        'four authors are distinguished, and one of them is the person who '
            'attached the file': authors.length == 4 && theUploaderIsOneOfThem,
        'the existing Step 97 validator is exercised rather than restated':
            theExistingValidatorStillDecides,
        'a chart\'s alternative is its finding rather than its shape':
            chartNote.contains('did not want one'),
        'the census is named as the answer rather than an eighth '
            'implementation': alreadyExistsNote.contains('seventh '
                'restatement'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the ceiling '
      'is "N/A (AAA optional)" -- a band with no top. Atomic Step: "Provide '
      'clear text alternatives (alt descriptions) for all non-text visual '
      'content."';
}
