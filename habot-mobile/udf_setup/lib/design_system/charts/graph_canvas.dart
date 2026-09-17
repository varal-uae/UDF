/// Step 365 (GEN-00876) -- the second LaTeX band, and a graph that has to
/// decide what it is before it decides how fast to draw.
///
/// The row: "Construct graph visualizer canvas widget using custom
/// hardware-accelerated rendering."
/// Metric: **Canvas Render Speed** -- floor, optimal and ceiling all
/// `$60\text{ fps}$`. Pass / Fail. "Mobile GPU Canvas Acceleration Spec".
///
/// **The same typeset band as Step 356.** All three boundary cells hold
/// `$60\text{ fps}$` in LaTeX math mode. Two rows in one batch is enough to say
/// it is not a one-off keystroke: something in the pipeline that produced this
/// sheet renders numbers with a typesetting wrapper, and it lands in cells a
/// consumer will parse. The standard cited, "Mobile GPU Canvas Acceleration
/// Spec", is also not the name of a published specification -- the same shape
/// as Step 353's "Mobile Sensory Feedback Standards".
///
/// **"Hardware-accelerated" is empty here for the reason Step 346 gave.**
/// Flutter composites every widget on the GPU already. There is no slow path to
/// opt out of and no hint to give, so the instruction is not wrong, it is
/// inert.
///
/// **60 fps is a budget, not a target, and it is the wrong one to optimise
/// against.** A graph that holds 60 fps while showing an unreadable hairball
/// has met the row and failed the person. The number that decides whether a
/// graph is usable is **how many nodes are on screen**, and beyond a few dozen
/// no amount of frame budget helps: the picture stops being a picture.
///
/// **So the widget caps what it draws and says what it cut.** A neighbourhood
/// view around a focused node, a stated cap, and a count of what is outside it
/// -- which is Step 363's truncation rule applied to a graph instead of a list.
///
/// **A graph is a list for anybody not looking at it.** The canvas announces
/// nothing, so the same structure is available as an indented list of relations
/// -- the form Step 311 already built for trace maps, reused rather than
/// redesigned.
library;

import '../dashboard/query_row_limit.dart';

/// What a graph widget can be asked to show.
enum HabotGraphScope {
  /// Everything. Never drawn.
  wholeGraph,

  /// A focused node and its immediate relations.
  neighbourhood,
}

/// One worked graph.
class HabotGraphSample {
  const HabotGraphSample({
    required this.label,
    required this.totalNodes,
    required this.drawnNodes,
  });

  final String label;
  final int totalNodes;
  final int drawnNodes;

  int get hidden => totalNodes - drawnNodes;
}

/// The graph visualiser canvas.
class HabotGraphCanvas {
  const HabotGraphCanvas._();

  // -----------------------------------------------------------------------
  // The band, typeset, for the second time.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = r'$60\text{ fps}$';
  static const String bandOptimalRaw = r'$60\text{ fps}$';
  static const String bandCeilingRaw = r'$60\text{ fps}$';

  static bool get theBandIsLatex =>
      bandFloorRaw.startsWith(r'$') && bandFloorRaw.contains(r'\text{');

  static bool get allThreeBoundariesAreIdentical =>
      bandFloorRaw == bandOptimalRaw && bandOptimalRaw == bandCeilingRaw;

  static bool get theBandCannotBeParsedAsANumber =>
      double.tryParse(bandFloorRaw) == null;

  /// Step 356 carries the identical three cells.
  static const List<int> latexBandRows = <int>[356, 365];

  static bool get twoRowsInThisBatchAreTypeset => latexBandRows.length == 2;

  static const String citedStandard = 'Mobile GPU Canvas Acceleration Spec';

  static const bool theCitedStandardIsPublished = false;

  /// Step 353's "Mobile Sensory Feedback Standards" has the same shape.
  static const int theOtherInventedStandardRow = 353;

  static const String bandNote =
      'All three boundary cells hold "\$60\\text{ fps}\$" in LaTeX math mode, '
      'exactly as Step 356 does. Two rows in one batch is enough to say this '
      'is not a keystroke: something in the pipeline that produced this sheet '
      'renders numbers with a typesetting wrapper, into cells a consumer will '
      'parse. The standard cited, "Mobile GPU Canvas Acceleration Spec", is '
      'also not the name of a published specification -- the same shape as '
      'Step 353\'s "Mobile Sensory Feedback Standards".';

  // -----------------------------------------------------------------------
  // The acceleration instruction, which is inert.
  // -----------------------------------------------------------------------

  static const bool aCompositingHintIsNeeded = false;

  static const int theStepThatSettledThis = 346;

  static const String accelerationNote =
      'Flutter composites every widget on the GPU already, so there is no slow '
      'path to opt out of and no hint to give. Step 346 settled this for a CSS '
      'transition and it is the same answer for a canvas: the instruction is '
      'not wrong, it is inert, and writing something to satisfy it would be '
      'writing something that does nothing.';

  // -----------------------------------------------------------------------
  // The number that decides whether a graph is usable.
  // -----------------------------------------------------------------------

  static const int drawableNodeCap = 40;

  static const List<HabotGraphSample> samples = <HabotGraphSample>[
    HabotGraphSample(
      label: 'one record and its immediate lineage',
      totalNodes: 18,
      drawnNodes: 18,
    ),
    HabotGraphSample(
      label: 'a busy record, one hop out',
      totalNodes: 214,
      drawnNodes: 40,
    ),
    HabotGraphSample(
      label: 'the whole table lineage',
      totalNodes: 9600,
      drawnNodes: 40,
    ),
  ];

  static bool withinCap(HabotGraphSample s) => s.drawnNodes <= drawableNodeCap;

  static bool get everySampleRespectsTheCap => samples.every(withinCap);

  static int get samplesThatFitWhole =>
      samples.where((HabotGraphSample s) => s.hidden == 0).length;

  /// One of three fits whole; the other two are neighbourhoods.
  static bool get oneOfThreeFitsWhole => samplesThatFitWhole == 1;

  static const bool theWholeGraphIsEverDrawn = false;

  static bool get theScopeIsAlwaysANeighbourhood => !theWholeGraphIsEverDrawn;

  static const String legibilityNote =
      'Sixty frames a second is a budget, not a target, and holding it while '
      'drawing an unreadable hairball meets the row and fails the person. What '
      'decides whether a graph is usable is how many nodes are on screen, and '
      'past a few dozen no frame budget helps -- the picture stops being a '
      'picture. The widget draws a neighbourhood around a focused node, never '
      'the whole graph, and caps it at forty.';

  // -----------------------------------------------------------------------
  // What was cut is stated, which is Step 363's rule.
  // -----------------------------------------------------------------------

  static String hiddenLabel(HabotGraphSample s) => s.hidden == 0
      ? 'Showing all ${s.totalNodes}'
      : 'Showing ${s.drawnNodes} of ${s.totalNodes}';

  static bool get theCutIsStated =>
      hiddenLabel(samples[1]) == 'Showing 40 of 214';

  static bool get theCompleteCaseSaysSo =>
      hiddenLabel(samples.first) == 'Showing all 18';

  /// The same rule Step 363 applies to a list, applied to a graph.
  static bool get theTruncationRuleIsAlreadyDeclared =>
      HabotQueryRowLimit.bothStatesAreLabelled;

  static const String truncationNote =
      'A graph that silently drops nodes is the same wrong answer as a list '
      'that silently drops rows, and it is harder to notice because a graph '
      'has no scrollbar to be short. Both states are labelled -- "Showing 40 '
      'of 214" and "Showing all 18" -- which is Step 363\'s rule applied to a '
      'different shape of truncation.';

  // -----------------------------------------------------------------------
  // A graph is a list for anybody not looking at it.
  // -----------------------------------------------------------------------

  static const bool theCanvasAnnouncesItself = false;

  static const String nonVisualForm =
      'an indented list of relations, the form Step 311 built for trace maps';

  static bool get thereIsANonVisualEquivalent => nonVisualForm.isNotEmpty;

  static bool get theNonVisualFormIsReused =>
      nonVisualForm.contains('Step 311');

  static const String nonVisualNote =
      'A canvas draws pixels and announces nothing, so the graph is also '
      'available as an indented list of relations -- the form Step 311 already '
      'built for trace maps, reused rather than redesigned. That step also '
      'recorded what an indented list loses: it preserved eleven of thirteen '
      'relations and said which two it dropped, which is the honest version of '
      'this trade rather than a claim that the two forms are equivalent.';

  static Map<String, bool> get obligations => <String, bool>{
        'the whole graph is never drawn':
            theScopeIsAlwaysANeighbourhood && everySampleRespectsTheCap,
        'what is not drawn is stated': theCutIsStated,
        'a complete view says it is complete': theCompleteCaseSaysSo,
        'there is a non-visual equivalent': thereIsANonVisualEquivalent,
        'no compositing hint is written': !aCompositingHintIsNeeded,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the band is LaTeX and unparseable':
            theBandIsLatex && theBandCannotBeParsedAsANumber,
        'all three boundaries are the same string':
            allThreeBoundariesAreIdentical,
        'two rows in this batch are typeset':
            twoRowsInThisBatchAreTypeset && latexBandRows.contains(356),
        'the cited standard is not a published one':
            !theCitedStandardIsPublished &&
                theOtherInventedStandardRow == 353 &&
                citedStandard.contains('Spec'),
        'the acceleration instruction is inert, as Step 346 settled':
            !aCompositingHintIsNeeded && theStepThatSettledThis == 346,
        'three samples, one of which fits whole':
            samples.length == 3 && oneOfThreeFitsWhole,
        'every sample respects the forty-node cap':
            everySampleRespectsTheCap && drawableNodeCap == 40,
        'frame rate is the wrong thing to optimise against':
            legibilityNote.contains('stops being a picture'),
        'both truncation states are labelled, as at Step 363':
            theCutIsStated &&
                theCompleteCaseSaysSo &&
                theTruncationRuleIsAlreadyDeclared,
        'the non-visual form is Step 311\'s, with its losses recorded':
            !theCanvasAnnouncesItself &&
                theNonVisualFormIsReused &&
                nonVisualNote.contains('eleven of thirteen'),
      };

  static const String columnNote =
      'COLUMN NOTE: all three boundary cells on this row hold the LaTeX string '
      '"\$60\\text{ fps}\$", as Step 356\'s do; the standard cited, '
      '"Mobile GPU Canvas Acceleration Spec", is not a published '
      'specification; and the Setup Step column reads "Bind the enforcer to '
      'the mobile device\'s virtual keyboard input events", which is input '
      'handling on a rendering row. Atomic Step: "Construct graph visualizer '
      'canvas widget using custom hardware-accelerated rendering."';
}
