/// Step 276 (ARCPE-004-05) -- two event handlers that are one gesture, and a
/// band that attributes both its ends to the wrong WCAG level.
///
/// The row: "Program click and tap event handlers to toggle accordion
/// expansion states."
/// Metric: **Touch Target Size & Accessibility Compliance** -- floor "44px /
/// WCAG AA", optimal "48px / WCAG AA", ceiling "56px / WCAG AAA".
/// Good / Average / Poor. Cited: MD3 Accessibility Guidelines; WCAG 2.1 AA.
///
/// **"Click and tap" is one handler here, not two.** On the web they are
/// separate events -- a mouse click and a touch tap -- and a touch also
/// synthesises a click afterwards, which is where the old tap delay came from
/// and which Step 230 removed. Flutter has one gesture arena: `onTap` resolves
/// for mouse, touch and stylus alike, so binding a second handler would fire
/// the toggle twice and leave the panel where it started. The row's two
/// handlers are one, and an implementation that followed the sentence
/// literally would produce a header that does nothing.
///
/// **`<details>`/`<summary>` is not available, and it was carrying more than
/// markup.** The row's design notes name the HTML disclosure element, which
/// supplies the expanded state, the button role, keyboard operation and the
/// region association for free. None of that exists here, so all four have to
/// be declared -- which `HabotPromoAccordion` (Step 111) already does under
/// `A11Y_PROGRESSIVE_DISCLOSURE`. This step is the census, not a second one.
///
/// **The band names the wrong level at both ends.** WCAG 2.2 SC 2.5.8 (AA)
/// asks for 24x24 CSS px; SC 2.5.5 (AAA) asks for 44x44. So "44px / WCAG AA"
/// is the AAA figure labelled AA, and "56px / WCAG AAA" is a number that
/// appears nowhere in WCAG at all -- it is MD3's comfortable density. The
/// numbers 44 / 48 / 56 are the right band for this application and are
/// already declared as `HabotTouchBand`; the levels attached to them are
/// wrong, and Step 227 found the same kind of mis-citation on three other
/// rows.
library;

import '../checkout/promo_accordion.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// A pointer kind the row's two handlers were meant to cover.
enum HabotPointerKind {
  /// A finger.
  touch,

  /// A mouse.
  mouse,

  /// A stylus.
  stylus,
}

/// The toggle.
class HabotAccordionHandlers {
  const HabotAccordionHandlers._();

  /// How many handlers the row asks to bind.
  static const int handlersTheRowNames = 2;

  /// How many this framework needs. One arena, one callback.
  static const int handlersNeededHere = 1;

  /// Which callback each pointer kind arrives on. Written out so the claim
  /// is a property of a table rather than of a sentence: a framework that
  /// needed a second callback for one of them would have a second entry here.
  static const Map<HabotPointerKind, String> callbackFor =
      <HabotPointerKind, String>{
    HabotPointerKind.touch: 'onTap',
    HabotPointerKind.mouse: 'onTap',
    HabotPointerKind.stylus: 'onTap',
  };

  static Set<String> get distinctCallbacks => callbackFor.values.toSet();

  static bool get everyPointerKindUsesTheSameCallback =>
      callbackFor.length == HabotPointerKind.values.length &&
      HabotPointerKind.values.length == 3 &&
      distinctCallbacks.length == handlersNeededHere;

  /// What binding both would do: two toggles per tap, so the panel returns to
  /// the state it started in and the header reads as broken rather than as
  /// double-bound.
  static bool expandedAfter({
    required bool wasExpanded,
    required int handlersBound,
  }) {
    bool state = wasExpanded;
    for (int i = 0; i < handlersBound; i++) {
      state = !state;
    }
    return state;
  }

  static bool get oneHandlerToggles =>
      expandedAfter(wasExpanded: false, handlersBound: handlersNeededHere) &&
      !expandedAfter(wasExpanded: true, handlersBound: handlersNeededHere);

  /// The bug the row's wording would produce.
  static bool get twoHandlersDoNothing =>
      expandedAfter(wasExpanded: false, handlersBound: handlersTheRowNames) ==
      false;

  static const String oneGestureNote =
      'On the web a mouse click and a touch tap are separate events, and a '
      'touch synthesises a click afterwards -- the source of the old '
      'three-hundred-millisecond tap delay Step 230 removed. Flutter has one '
      'gesture arena: onTap resolves for touch, mouse and stylus alike. So '
      'the row\'s two handlers are one handler, and binding both would toggle '
      'twice per tap and leave the panel exactly where it was. An '
      'implementation that followed the sentence literally would ship a '
      'header that appears to do nothing, which is the worst kind of defect '
      'to find: it looks like a missing feature rather than a double-bound '
      'one.';

  // -----------------------------------------------------------------------
  // What <details> was carrying.
  // -----------------------------------------------------------------------

  /// The four things the HTML element supplies for free and which have to be
  /// declared here instead.
  static const List<String> obligationsDetailsWouldHaveCarried = <String>[
    'the expanded state is exposed to assistive technology',
    'the header has a button role rather than being decorated text',
    'the header is operable from a keyboard and appears in the traversal',
    'the panel is associated with the header that controls it',
  ];

  static bool get everyObligationIsNamed =>
      obligationsDetailsWouldHaveCarried.length == 4 &&
      obligationsDetailsWouldHaveCarried.every((String s) => s.length > 30);

  /// The rule already exists, and this is the check that it still does.
  static bool get theSemanticRuleIsAlreadyDeclared =>
      HabotPromoAccordion.semanticRule == 'A11Y_PROGRESSIVE_DISCLOSURE';

  static const String detailsElementNote =
      'The row\'s design notes name standard HTML details/summary elements. '
      'That element is not markup alone: it supplies the expanded state, the '
      'button role, keyboard operation and the association between header and '
      'panel, and a framework without it has to declare all four. Step 111 '
      'already did, under A11Y_PROGRESSIVE_DISCLOSURE, so what this row needs '
      'is the census rather than a second accordion -- the same conclusion '
      'Steps 216, 227, 250 and 266 reached about their own restatements.';

  // -----------------------------------------------------------------------
  // The target, which is the row's own metric.
  // -----------------------------------------------------------------------

  /// The whole header row is the target. The commonest accordion defect is a
  /// chevron-sized hit area inside a full-width header, which looks
  /// identical and misses four times out of five.
  static double get headerMinHeightDp => HabotPromoAccordion.headerMinHeightDp;

  static const double chevronGlyphDp = 24;

  static bool get theHeaderIsTheTargetRatherThanTheChevron =>
      headerMinHeightDp >= HabotTouchBand.optimalDp &&
      chevronGlyphDp < HabotTouchBand.floorDp;

  /// Checked through the existing band rather than restated: a chevron-only
  /// hit area fails, a full header passes.
  static bool get theExistingBandAgrees =>
      HabotTouchBand.optimalDp == 48 &&
      HabotTouchBand.floorDp == 44 &&
      HabotTouchBand.ceilingDp == 56 &&
      headerMinHeightDp == HabotDensity.minTouchTarget;

  static const String chevronNote =
      'The whole header is the target, not the chevron. A twenty-four-point '
      'glyph inside a full-width header looks exactly like a working '
      'accordion and misses most of the time, because the visible affordance '
      'and the hit area are different shapes. This row\'s own metric is touch '
      'target size, so its two halves meet here: the header\'s minimum height '
      'is the declared touch-target token and its width is the row.';

  // -----------------------------------------------------------------------
  // Metric: 44px / WCAG AA, 48px / WCAG AA, 56px / WCAG AAA.
  // -----------------------------------------------------------------------

  /// WCAG 2.2 SC 2.5.8, Target Size (Minimum), Level AA.
  static const double wcagAaMinimumPx = 24;

  /// WCAG 2.2 SC 2.5.5, Target Size (Enhanced), Level AAA.
  static const double wcagAaaEnhancedPx = 44;

  /// The row's floor is the AAA figure wearing an AA label.
  static bool get theFloorIsAaaLabelledAa =>
      HabotTouchBand.floorDp == wcagAaaEnhancedPx &&
      wcagAaaEnhancedPx != wcagAaMinimumPx;

  /// And its ceiling is not a WCAG figure at all.
  static bool get theCeilingIsNotInTheSpecification =>
      HabotTouchBand.ceilingDp != wcagAaMinimumPx &&
      HabotTouchBand.ceilingDp != wcagAaaEnhancedPx;

  static const String citationNote =
      'The band names the wrong level at both ends. WCAG 2.2 SC 2.5.8, Target '
      'Size (Minimum), is Level AA and asks for 24x24 CSS pixels; SC 2.5.5, '
      'Target Size (Enhanced), is Level AAA and asks for 44x44. So the row\'s '
      'floor of "44px / WCAG AA" is the AAA figure with an AA label, and its '
      'ceiling of "56px / WCAG AAA" is a number that appears nowhere in WCAG '
      '-- it is MD3\'s comfortable density. The numbers themselves are the '
      'right band for this application and are already declared as '
      'HabotTouchBand; only the attributions are wrong. Step 227 found the '
      'same kind of mis-citation on three other rows, which makes this the '
      'fourth.';

  static const String unitsNote =
      'The band is written in px and the citation it points at is written in '
      'dp. They are not the same unit: a CSS pixel is a reference pixel at a '
      'nominal density, a dp is a density-independent point, and on a phone '
      'at 3x they differ. Nothing in this repository is measured in px, so '
      'the band is read as dp -- which is what the citation\'s own "44-48dp" '
      'says -- and the discrepancy is recorded rather than silently '
      'converted. Step 285 carries the same mix on the same day.';

  static String get qualitativeOutput =>
      everyPointerKindUsesTheSameCallback &&
              theHeaderIsTheTargetRatherThanTheChevron &&
              theSemanticRuleIsAlreadyDeclared
          ? 'Good'
          : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'every pointer kind resolves through one callback':
            everyPointerKindUsesTheSameCallback &&
                handlersNeededHere == 1 &&
                handlersTheRowNames == 2,
        'one handler toggles and two handlers do nothing':
            oneHandlerToggles && twoHandlersDoNothing,
        'the one-gesture finding is recorded rather than implied':
            oneGestureNote.contains('appears to do nothing'),
        'the four obligations the HTML element carried are named':
            everyObligationIsNamed,
        'the existing progressive-disclosure rule still holds':
            theSemanticRuleIsAlreadyDeclared &&
                detailsElementNote.contains('census'),
        'the header rather than the chevron is the target':
            theHeaderIsTheTargetRatherThanTheChevron &&
                chevronNote.contains('different shapes'),
        'the band is read from the existing declaration':
            theExistingBandAgrees,
        'the floor is the AAA figure labelled AA':
            theFloorIsAaaLabelledAa && wcagAaMinimumPx == 24,
        'the ceiling is not a WCAG figure at all':
            theCeilingIsNotInTheSpecification &&
                citationNote.contains('appears nowhere in WCAG'),
        'the px/dp mix is recorded rather than silently converted':
            unitsNote.contains('not the same unit'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Implement the '
      'overlay to trigger when performance drops below the safety limit", '
      'which belongs to neither the Atomic Step nor the metric. Atomic Step: '
      '"Program click and tap event handlers to toggle accordion expansion '
      'states."';
}
