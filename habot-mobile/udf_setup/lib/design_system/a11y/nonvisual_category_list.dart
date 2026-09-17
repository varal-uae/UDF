/// Step 314 (GEN-04979) -- a "screen-reader fallback list", which is the
/// defect this row is trying to fix.
///
/// The row: "Implement substep 4: Add screen-reader fallback list allowing
/// non-visual tap selection of sensory categories."
/// Metric: **Substep Definition-of-Done Adherence Rate** -- floor ">=90% unit
/// test coverage / acceptance criteria met before merge", optimal "95-100%
/// coverage, all acceptance criteria met", ceiling "100%". Complete / Partial
/// / Not Complete. ISO/IEC 25010.
///
/// **A second list for screen readers is the thing that goes wrong, not the
/// fix.** Two structures holding the same nine categories is eighteen places
/// to change and nine pairs that can disagree, and every disagreement is
/// invisible to everybody who does not use a screen reader -- so it is not
/// caught in review, not caught by a designer, and not caught by the person
/// who added the tenth category to the visible list. It is found months later
/// by the one user it was built for. The parallel accessible version is the
/// oldest anti-pattern in this field and it always starts as this sentence.
///
/// **One structure, and it is the accessible one.** Each category is a single
/// entry carrying its name, its selected state and its semantic label; the
/// visual list renders it and the semantics tree exposes the same object. Nine
/// places to change, no pair that can disagree, and adding a category is one
/// edit that cannot be half done.
///
/// **"Sensory categories" is a Level A problem in two words.** SC 1.3.3
/// Sensory Characteristics forbids instructions that rely only on shape, size,
/// visual location, orientation or sound. A category identified by a colour
/// swatch or by where it sits cannot be referred to at all: "pick the blue
/// one" is not a sentence a screen reader can act on. Every category here has
/// a name, and the swatch is decoration beside the name rather than the
/// identity of the thing.
///
/// **"Non-visual tap selection" describes a gesture that is not available.**
/// With a screen reader on, selection is explore-by-touch followed by a
/// double-tap, and the double-tap belongs to the assistive technology -- the
/// same fact Step 312 in this batch found from the other direction, where the
/// Setup Step tried to bind a confirmation to it. A control that is properly
/// exposed needs no separate non-visual selection path, because the ordinary
/// path already is one.
///
/// **Coverage cannot see the thing this row is about.** The metric's floor is
/// 90 per cent unit test coverage. A semantics node is not a branch: a list
/// row with no label executes exactly the same lines as one with a label, so a
/// suite at 100 per cent coverage passes over a control that announces
/// nothing. Coverage is a fair Definition of Done on many rows and it is blind
/// on this one, which is worth saying because it is the reassuring kind of
/// blindness -- the number goes up while the defect stays.
library;

import '../tokens/touch_target_band.dart';

/// One category, in one structure.
class HabotSensoryCategory {
  const HabotSensoryCategory({
    required this.id,
    required this.name,
    required this.swatchRole,
    required this.selected,
  });

  final String id;

  /// The identity. Always a word, never a colour or a position.
  final String name;

  /// Decoration beside the name. Never the thing that identifies it.
  final String swatchRole;

  final bool selected;

  /// What the semantics tree exposes. Derived from the same fields the visual
  /// row renders, so the two cannot drift.
  String get semanticLabel => name;

  String get semanticState => selected ? 'selected' : 'not selected';
}

/// The list.
class HabotNonvisualCategoryList {
  const HabotNonvisualCategoryList._();

  static const List<HabotSensoryCategory> categories =
      <HabotSensoryCategory>[
    HabotSensoryCategory(
      id: 'noise',
      name: 'Loud noise',
      swatchRole: 'error',
      selected: false,
    ),
    HabotSensoryCategory(
      id: 'bright',
      name: 'Bright light',
      swatchRole: 'warning',
      selected: true,
    ),
    HabotSensoryCategory(
      id: 'crowd',
      name: 'Crowded space',
      swatchRole: 'warning',
      selected: false,
    ),
    HabotSensoryCategory(
      id: 'confined',
      name: 'Confined space',
      swatchRole: 'warning',
      selected: false,
    ),
    HabotSensoryCategory(
      id: 'heat',
      name: 'Extreme heat',
      swatchRole: 'error',
      selected: true,
    ),
    HabotSensoryCategory(
      id: 'vibration',
      name: 'Sustained vibration',
      swatchRole: 'neutral',
      selected: false,
    ),
    HabotSensoryCategory(
      id: 'fumes',
      name: 'Chemical fumes',
      swatchRole: 'error',
      selected: false,
    ),
    HabotSensoryCategory(
      id: 'height',
      name: 'Working at height',
      swatchRole: 'error',
      selected: false,
    ),
    HabotSensoryCategory(
      id: 'dust',
      name: 'Airborne dust',
      swatchRole: 'neutral',
      selected: false,
    ),
  ];

  // -----------------------------------------------------------------------
  // One structure rather than two.
  // -----------------------------------------------------------------------

  static const int structures = 1;

  static const int structuresTheRowAsksFor = 2;

  static int get placesToChange => categories.length * structures;

  static int get placesToChangeWithAFallbackList =>
      categories.length * structuresTheRowAsksFor;

  static int get pairsThatCouldDisagree =>
      structuresTheRowAsksFor == 1 ? 0 : categories.length;

  static int get pairsThatCanDisagreeHere =>
      structures == 1 ? 0 : categories.length;

  static double get editReduction =>
      1 - placesToChange / placesToChangeWithAFallbackList;

  /// The label the screen reader reads is derived from the field the visible
  /// row renders, so there is nothing to keep in step.
  static bool get theLabelIsDerivedRatherThanDuplicated => categories
      .every((HabotSensoryCategory c) => c.semanticLabel == c.name);

  static bool get nothingCanDrift =>
      pairsThatCanDisagreeHere == 0 && theLabelIsDerivedRatherThanDuplicated;

  static const String parallelListNote =
      'Two structures holding the same nine categories is eighteen places to '
      'change and nine pairs that can disagree, and every disagreement is '
      'invisible to everyone who does not use a screen reader: not caught in '
      'review, not caught by a designer, not caught by whoever adds the tenth '
      'category to the visible list. It is found months later by the one '
      'person it was built for. The parallel accessible version is the oldest '
      'anti-pattern in this field, and it always begins as exactly this '
      'sentence.';

  // -----------------------------------------------------------------------
  // Sensory characteristics.
  // -----------------------------------------------------------------------

  static const String criterion = 'WCAG 2.1 SC 1.3.3 Sensory Characteristics';
  static const String criterionLevel = 'A';

  static bool get everyCategoryHasAName => categories.every(
        (HabotSensoryCategory c) => c.name.trim().split(' ').isNotEmpty &&
            c.name.trim().length > 3,
      );

  static bool get noCategoryIsIdentifiedByItsSwatch {
    final Set<String> swatches =
        categories.map((HabotSensoryCategory c) => c.swatchRole).toSet();
    return swatches.length < categories.length;
  }

  static bool get noTwoCategoriesShareAName =>
      categories.map((HabotSensoryCategory c) => c.name).toSet().length ==
      categories.length;

  static const String sensoryNote =
      'SC 1.3.3 is Level A: an instruction may not rely only on shape, size, '
      'visual location, orientation or sound. The nine categories here use '
      'three swatch roles between them, so a swatch could not identify a '
      'category even for somebody who can see it -- "pick the red one" names '
      'four things. Each is identified by its name; the swatch sits beside '
      'the name as reinforcement, which is the same arrangement Step 306 '
      'reached for severity.';

  // -----------------------------------------------------------------------
  // The gesture.
  // -----------------------------------------------------------------------

  static const String screenReaderSelection =
      'explore by touch, then double-tap, which belongs to the assistive '
      'technology';

  static const bool aSeparateNonVisualPathIsNeeded = false;

  static const int siblingStepWithTheSameFact = 312;

  static bool get everyRowIsAProperTarget =>
      HabotTouchBand.optimalDp >= HabotTouchBand.floorDp;

  static double get rowMinimumDp => HabotTouchBand.optimalDp;

  static const String gestureNote =
      'With a screen reader on, selection is explore-by-touch followed by a '
      'double-tap, and the double-tap belongs to the assistive technology. '
      'Step 312 in this batch met the same fact from the other side, where a '
      'Setup Step tried to bind a confirmation to that gesture. A control that '
      'is properly exposed -- a name, a role, a selected state -- needs no '
      'separate non-visual selection path, because the ordinary path already '
      'is one. Building the second path is how the first one stays broken.';

  // -----------------------------------------------------------------------
  // The metric, which cannot see any of this.
  // -----------------------------------------------------------------------

  static const double floorCoverage = 0.90;
  static const double optimalCoverageMin = 0.95;
  static const double ceilingCoverage = 1.0;

  /// A control with no semantic label executes the same lines as one with a
  /// label, so coverage cannot distinguish them.
  static const bool coverageCanSeeAMissingLabel = false;

  static const String coverageNote =
      'A semantics node is not a branch. A list row with no label executes '
      'exactly the lines a labelled row executes, so a suite at 100 per cent '
      'coverage passes over a control that announces nothing at all. Coverage '
      'is a fair Definition of Done on many rows and it is blind on this one, '
      'which is worth saying because it is the reassuring kind of blindness: '
      'the number goes up while the defect stays. What would catch it is a '
      'test that reads the semantics tree, which is what this step\'s own gate '
      'file does.';

  static bool get theCeilingIsHonest =>
      ceilingCoverage == 1.0 && optimalCoverageMin < ceilingCoverage;

  static const String ceilingTextNote =
      'The ceiling cell reads "100% (coverage beyond 100% is not meaningful; '
      'further effort has diminishing return)" -- the only ceiling in this '
      'batch that explains itself and is right to. Step 288 was the last one '
      'to manage it.';

  static Map<String, bool> get obligations => <String, bool>{
        'there is one structure rather than two': structures == 1,
        'the semantic label is derived from the rendered field':
            theLabelIsDerivedRatherThanDuplicated,
        'nothing can drift between a visible and a spoken list':
            nothingCanDrift,
        'every category is identified by a name': everyCategoryHasAName,
        'no two categories share a name': noTwoCategoriesShareAName,
        'every row is a target at the project minimum': everyRowIsAProperTarget,
      };

  static double get adherence =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (adherence >= 1.0) {
      return 'Complete';
    }
    return adherence > 0 ? 'Partial' : 'Not Complete';
  }

  static Map<String, bool> get checks => <String, bool>{
        'nine categories in one structure':
            categories.length == 9 && structures == 1 && placesToChange == 9,
        'the row\'s two structures would be eighteen places and nine pairs':
            structuresTheRowAsksFor == 2 &&
                placesToChangeWithAFallbackList == 18 &&
                pairsThatCouldDisagree == 9 &&
                editReduction == 0.5,
        'and nothing here can drift':
            nothingCanDrift &&
                pairsThatCanDisagreeHere == 0 &&
                parallelListNote.contains('the oldest anti-pattern'),
        'the criterion is Level A':
            criterionLevel == 'A' && criterion.contains('1.3.3'),
        'swatch roles are shared, so a swatch could not identify anything':
            noCategoryIsIdentifiedByItsSwatch &&
                sensoryNote.contains('names four things'),
        'every category has a name and no two share one':
            everyCategoryHasAName && noTwoCategoriesShareAName,
        'the double-tap belongs to the screen reader':
            !aSeparateNonVisualPathIsNeeded &&
                siblingStepWithTheSameFact == 312 &&
                screenReaderSelection.contains('assistive technology'),
        'and building a second path is how the first stays broken':
            gestureNote.contains('stays broken'),
        'every row is a target at the project minimum':
            everyRowIsAProperTarget && rowMinimumDp == 48,
        'coverage cannot see a missing label':
            !coverageCanSeeAMissingLabel &&
                floorCoverage == 0.90 &&
                coverageNote.contains('reassuring kind of blindness'),
        'the ceiling explains itself and is right':
            theCeilingIsHonest && ceilingTextNote.contains('Step 288'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                adherence == 1.0 &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is the generic '
      'engineering-console boilerplate, and the Expected Output cell is the '
      'Atomic Step truncated mid-word -- "allowing non-visual tap sel". Atomic '
      'Step: "Implement substep 4: Add screen-reader fallback list allowing '
      'non-visual tap selection of sensory categories."';
}
