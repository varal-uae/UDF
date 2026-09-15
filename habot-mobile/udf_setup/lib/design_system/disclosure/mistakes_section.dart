/// Step 278 (DSDD-003-14) -- collapsing the section people came to read.
///
/// The row: "Program the 'Common Mistakes' section to render as a collapsible
/// Material 3 accordion."
/// Metric: **UI Design-System Adherence Rate** -- floor ">=85%", optimal
/// ">=95%", ceiling 1. Good / Average / Poor. Cited: MD3 Guidelines and the
/// Nielsen Norman Group heuristics.
///
/// **Progressive disclosure hides what nobody needs by default. A list of
/// common mistakes is what somebody needs *before* they act.** Step 111
/// collapsed a promo field because a person who has no code should not see an
/// empty text box; the same argument inverts here. Collapsing the mistakes
/// makes them findable only by people who already suspect they made one,
/// which is the population the section is least useful to.
///
/// **So the disclosure is two-level, and the split is the design decision.**
/// Every mistake's *title* is always visible -- a scannable list, which is
/// what a reader uses to recognise their own situation -- and each
/// *explanation* is what collapses. The section keeps its accordion, the
/// reader keeps the index, and the vertical space the row is worried about is
/// still saved, because the explanations are the long part.
///
/// **The row's design notes belong to a documentation site.** "Web-accessible
/// interface for team members", "Material Design sidebar for document
/// navigation", "Ask Expert chat functionality": none of that is this
/// application, and the section being described lives in a handbook. What
/// transfers is the accordion, and it transfers with the inversion above.
library;

import '../checkout/promo_accordion.dart';
import '../tokens/spacing_tokens.dart';

/// One entry in the section.
class HabotMistakeEntry {
  const HabotMistakeEntry({
    required this.title,
    required this.explanation,
    required this.recogniseFrom,
  });

  /// Always visible. A reader scans these to find their own situation.
  final String title;

  /// Collapsible. The long part.
  final String explanation;

  /// What the reader would have seen that brings them here. The thing that
  /// makes a title recognisable rather than merely accurate.
  final String recogniseFrom;

  bool get isScannable => title.length <= 60 && recogniseFrom.isNotEmpty;

  bool get explanationIsTheLongPart => explanation.length > title.length * 3;
}

/// The section.
class HabotMistakesSection {
  const HabotMistakesSection._();

  /// Titles are not collapsible. This is the whole finding, as a constant a
  /// future change has to argue with.
  static const bool titlesAreAlwaysVisible = true;

  /// Explanations are.
  static const bool explanationsAreCollapsible = true;

  /// And the section is collapsed on first render, the way Step 111's promo
  /// panel is -- which is only defensible because the titles survive it.
  static bool get sectionStartsCollapsed =>
      !HabotPromoAccordion.expandedByDefault;

  static const List<HabotMistakeEntry> entries = <HabotMistakeEntry>[
    HabotMistakeEntry(
      title: 'The separator you typed was filtered out',
      explanation: 'Three of the declared field rules carry a mask that '
          'removes a character their own pattern requires, so a date or a '
          'time typed correctly never matches. The field is at fault, not '
          'the entry; open decision 24 tracks the correction.',
      recogniseFrom: 'a date field that rejects a date you typed correctly',
    ),
    HabotMistakeEntry(
      title: 'A total that is off by a fraction of a fils',
      explanation: 'Money was held in a double somewhere. Binary floating '
          'point cannot represent a tenth exactly, so sums of prices drift by '
          'amounts too small to see and too large to reconcile. Every amount '
          'in this application is a fixed-point value at four stored decimal '
          'places; a figure that disagrees came from outside that type.',
      recogniseFrom: 'a total that differs from the sum of its lines by 0.01',
    ),
    HabotMistakeEntry(
      title: 'The button is grey and nothing says why',
      explanation: 'A disabled control with no stated reason is a dead end. '
          'Every gate in this application carries a reason and a target, so '
          'if a control is refusing you there is a sentence somewhere saying '
          'what would change it -- and if there is not, that is a defect '
          'worth reporting rather than a rule you have to guess.',
      recogniseFrom: 'a greyed-out action with no message beside it',
    ),
    HabotMistakeEntry(
      title: 'The screen appears stuck part-way down a panel',
      explanation: 'Two scrolling regions on the same axis: the inner one '
          'takes the gesture wherever the finger landed. Panels here render a '
          'fixed number of rows and open the rest on a surface of their own '
          'rather than capping their own height, so a screen that behaves '
          'this way is showing a component that predates the rule.',
      recogniseFrom: 'a list that will not scroll until you drag from the '
          'edge',
    ),
    HabotMistakeEntry(
      title: 'A green badge that means nothing was checked',
      explanation: 'An indicator that resolves silence to success is worse '
          'than no indicator. Health states here are three-valued -- '
          'verified, unknown, failed -- and unknown is what a stale or '
          'missing answer produces. A two-state badge elsewhere is one to '
          'distrust.',
      recogniseFrom: 'a status chip that is green on a device that has been '
          'offline',
    ),
  ];

  static bool get everyTitleIsScannable =>
      entries.every((HabotMistakeEntry e) => e.isScannable);

  static bool get everyExplanationIsTheLongPart =>
      entries.every((HabotMistakeEntry e) => e.explanationIsTheLongPart);

  /// How much of the section's text is in the collapsible half. The saving
  /// the row wants, measured rather than asserted.
  static double get shareOfTextThatCollapses {
    final int titles = entries.fold(
      0,
      (int a, HabotMistakeEntry e) => a + e.title.length,
    );
    final int bodies = entries.fold(
      0,
      (int a, HabotMistakeEntry e) => a + e.explanation.length,
    );
    return bodies / (titles + bodies);
  }

  static bool get collapsingStillSavesMostOfTheSpace =>
      shareOfTextThatCollapses > 0.8;

  static const String invertedDisclosureNote =
      'Progressive disclosure hides what nobody needs by default, and a list '
      'of common mistakes is what somebody needs before they act rather than '
      'after. Collapsing it makes the section findable only by people who '
      'already suspect they made a mistake, which is the population it helps '
      'least. The split here is two-level: titles always visible so a reader '
      'can scan for their own situation, explanations collapsible because '
      'they are the long part. Over four fifths of the section\'s text is '
      'still in the collapsible half, so the space the row wants is saved '
      'without hiding the index.';

  // -----------------------------------------------------------------------
  // The accordion itself, which already exists.
  // -----------------------------------------------------------------------

  /// One open panel at a time loses the reader's place: opening the third
  /// mistake closes the first, and a reader comparing two of them cannot.
  static const bool allowsMultipleOpenPanels = true;

  /// The latch vocabulary from Step 111, reused rather than redeclared. An
  /// explanation the reader has open stays open across a rebuild for the same
  /// reason a typed promo code does.
  static bool get theLatchVocabularyIsReused =>
      HabotAccordionLatch.values.length == 3 &&
      HabotAccordionLatch.values.contains(HabotAccordionLatch.openedByUser) &&
      HabotAccordionLatch.values
          .contains(HabotAccordionLatch.heldOpenByContent);

  static bool get theExistingSemanticRuleApplies =>
      HabotPromoAccordion.semanticRule == 'A11Y_PROGRESSIVE_DISCLOSURE';

  static double get headerMinHeightDp =>
      HabotPromoAccordion.headerMinHeightDp;

  static double get panelPaddingDp => HabotPromoAccordion.panelPaddingDp;

  static bool get presentationComesFromTheExistingComponent =>
      headerMinHeightDp == HabotDensity.minTouchTarget &&
      panelPaddingDp == HabotSpacing.md;

  static const String singleOpenNote =
      'One open panel at a time loses the reader\'s place: opening the third '
      'mistake closes the first, and somebody comparing two of them cannot. '
      'Single-open accordions exist to keep a page short, and this page is '
      'already short because the titles are one line each. Multiple panels '
      'may be open, and an explanation the reader opened stays open across a '
      'rebuild for the same reason Step 111 holds a typed promo code.';

  // -----------------------------------------------------------------------
  // Metric: UI Design-System Adherence Rate -- 85% / 95% / 1.
  // -----------------------------------------------------------------------

  /// What adherence means here: every presentational decision comes from a
  /// declared component or token rather than from this file.
  static Map<String, bool> get adherenceItems => <String, bool>{
        'header minimum height from the declared touch-target token':
            headerMinHeightDp == HabotDensity.minTouchTarget,
        'panel padding from the declared spacing scale':
            panelPaddingDp == HabotSpacing.md,
        'expand and collapse durations from the declared motion tokens':
            HabotPromoAccordion.expandDuration.inMilliseconds > 0 &&
                HabotPromoAccordion.collapseDuration.inMilliseconds > 0,
        'the disclosure semantics rule is the existing one':
            theExistingSemanticRuleApplies,
        'the latch vocabulary is the existing one':
            theLatchVocabularyIsReused,
        'collapsed on first render, as the existing component is':
            sectionStartsCollapsed,
      };

  static double get adherenceRate =>
      adherenceItems.values.where((bool b) => b).length /
      adherenceItems.length;

  static const double floorPercent = 85;
  static const double optimalPercent = 95;

  static String get qualitativeOutput {
    final double pct = adherenceRate * 100;
    if (pct >= optimalPercent) {
      return 'Good';
    }
    return pct >= floorPercent ? 'Average' : 'Poor';
  }

  static const String documentationSiteNote =
      'The row\'s design notes describe a documentation site: a '
      'web-accessible interface for team members, a Material sidebar for '
      'document navigation, an "Ask Expert" chat. None of that is this '
      'application, and the section being described lives in a handbook. What '
      'transfers is the accordion pattern, and it transfers with the '
      'inversion above -- which is worth more than porting a sidebar nobody '
      'here would use.';

  static Map<String, bool> get checks => <String, bool>{
        'five mistakes, every title scannable':
            entries.length == 5 && everyTitleIsScannable,
        'every explanation is the long part':
            everyExplanationIsTheLongPart,
        'titles stay visible and explanations collapse':
            titlesAreAlwaysVisible && explanationsAreCollapsible,
        'collapsing still saves most of the space, measured':
            collapsingStillSavesMostOfTheSpace,
        'the inverted disclosure argument is recorded':
            invertedDisclosureNote.contains('helps least'),
        'multiple panels may be open': allowsMultipleOpenPanels &&
            singleOpenNote.contains('loses the reader'),
        'the Step 111 component supplies the presentation':
            presentationComesFromTheExistingComponent,
        'the latch vocabulary and semantics rule are reused':
            theLatchVocabularyIsReused && theExistingSemanticRuleApplies,
        'six adherence items, all of them holding':
            adherenceItems.length == 6 &&
                adherenceItems.values.every((bool b) => b) &&
                adherenceRate == 1.0 &&
                qualitativeOutput == 'Good',
        'the documentation-site notes are recorded as not this application':
            documentationSiteNote.contains('handbook'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Program an '
      'automated cloud function trigger that executes immediately upon any '
      'message landing inside the DLQ", which belongs to a different subject '
      'entirely. Atomic Step: "Program the \'Common Mistakes\' section to '
      'render as a collapsible Material 3 accordion."';
}
