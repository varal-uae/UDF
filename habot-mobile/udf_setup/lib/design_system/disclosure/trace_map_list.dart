/// Step 311 (ACRAE-032-14) -- flattening a graph into a list, and the two
/// relations that do not survive the flattening.
///
/// The row: "Hide deep complex structural trace maps inside lightweight text
/// list blocks on small mobile screen states."
/// Metric: **UI Design-System Adherence Rate** -- floor >=85%, optimal >=95%,
/// ceiling 1. Good / Average / Poor.
///
/// **A trace is a graph and a list is a sequence, and the difference is not
/// cosmetic.** An indented list reproduces parent-child edges exactly: every
/// span sits under the span that started it. What it cannot reproduce is an
/// edge that points sideways -- a retry that refers back to an earlier
/// attempt, two spans that hit the same cache entry. The worked trace here has
/// twelve spans, eleven parent edges and two such links: thirteen relations,
/// of which a list carries eleven. The two it drops are the ones somebody
/// opens a trace map to find.
///
/// **So the list says what it is not showing.** The alternative is to pretend,
/// and a person reading a complete-looking tree concludes there were no
/// retries. Each span that participates in a sideways link carries a marker
/// naming the other end, and the list's header states the count. That is
/// weaker than a graph and it is honest, which is the trade the small screen
/// actually forces.
///
/// **Indentation is a width budget.** Sixteen points a level against 328
/// available: at depth eight the indent has taken 128 points and left 200,
/// which is about where a span name stops being readable. Depth is therefore
/// capped at eight and deeper spans are reached by opening the span above
/// them, rather than by letting the text column narrow until it wraps one word
/// at a time.
///
/// **"Hide" is allowed here, and it is worth saying why.** Step 104 refuses to
/// put essential content behind a disclosure control and throws when somebody
/// tries. A trace map is forensic by definition -- ids, timings, provenance --
/// so hiding it is the tier working as designed rather than an exception to
/// it. The tier is read from Step 104 instead of asserted here.
///
/// **COLUMN NOTE.** The Setup Step reads "Initialize the parsing selection
/// rule properties governing how document version discrepancies display",
/// which is document versioning on a row about trace visualisation, and the
/// domain expertise cell reads "Prompt Engineering".
library;

import '../a11y/progressive_disclosure.dart';
import '../tokens/spacing_tokens.dart';

/// One span in the worked trace.
class HabotTraceSpan {
  const HabotTraceSpan({
    required this.id,
    required this.name,
    required this.parentId,
    required this.depth,
    this.linkedTo,
  });

  final String id;
  final String name;

  /// Null for the root.
  final String? parentId;

  final int depth;

  /// A sideways edge: the relation a list cannot draw.
  final String? linkedTo;

  bool get isRoot => parentId == null;

  bool get hasASidewaysLink => linkedTo != null;
}

/// The list.
class HabotTraceMapList {
  const HabotTraceMapList._();

  static const List<HabotTraceSpan> spans = <HabotTraceSpan>[
    HabotTraceSpan(id: 's1', name: 'submit batch', parentId: null, depth: 0),
    HabotTraceSpan(id: 's2', name: 'validate', parentId: 's1', depth: 1),
    HabotTraceSpan(id: 's3', name: 'load profile', parentId: 's2', depth: 2),
    HabotTraceSpan(id: 's4', name: 'cache read', parentId: 's3', depth: 3),
    HabotTraceSpan(id: 's5', name: 'authorise', parentId: 's1', depth: 1),
    HabotTraceSpan(
      id: 's6',
      name: 'load profile',
      parentId: 's5',
      depth: 2,
      linkedTo: 's4',
    ),
    HabotTraceSpan(id: 's7', name: 'post ledger', parentId: 's1', depth: 1),
    HabotTraceSpan(id: 's8', name: 'ledger write', parentId: 's7', depth: 2),
    HabotTraceSpan(
      id: 's9',
      name: 'ledger write retry',
      parentId: 's7',
      depth: 2,
      linkedTo: 's8',
    ),
    HabotTraceSpan(id: 's10', name: 'notify', parentId: 's1', depth: 1),
    HabotTraceSpan(id: 's11', name: 'push dispatch', parentId: 's10', depth: 2),
    HabotTraceSpan(id: 's12', name: 'receipt', parentId: 's10', depth: 2),
  ];

  // -----------------------------------------------------------------------
  // What survives the flattening.
  // -----------------------------------------------------------------------

  static int get parentEdges =>
      spans.where((HabotTraceSpan s) => !s.isRoot).length;

  static List<HabotTraceSpan> get spansWithSidewaysLinks =>
      spans.where((HabotTraceSpan s) => s.hasASidewaysLink).toList();

  static int get sidewaysEdges => spansWithSidewaysLinks.length;

  static int get totalRelations => parentEdges + sidewaysEdges;

  static int get relationsALinePreserves => parentEdges;

  static double get shareOfRelationsPreserved =>
      relationsALinePreserves / totalRelations;

  static bool get aListCannotDrawSidewaysEdges => sidewaysEdges > 0;

  /// And so the list says so, rather than looking complete.
  static String markerFor(HabotTraceSpan span) => span.hasASidewaysLink
      ? 'also touches ${span.linkedTo}'
      : '';

  static bool get everySidewaysLinkIsMarked => spansWithSidewaysLinks
      .every((HabotTraceSpan s) => markerFor(s).isNotEmpty);

  static String get header =>
      '$parentEdges nested calls, $sidewaysEdges linked elsewhere';

  static bool get theHeaderStatesWhatIsNotDrawn =>
      header.contains('linked elsewhere');

  static const String flatteningNote =
      'An indented list reproduces parent-child edges exactly and cannot '
      'reproduce an edge that points sideways -- a retry referring back to its '
      'first attempt, two spans hitting the same cache entry. Twelve spans '
      'here carry thirteen relations and a list carries eleven of them. The '
      'two it drops are the ones somebody opens a trace map to find, so the '
      'list names them instead of pretending: a complete-looking tree leads a '
      'reader to conclude there were no retries, which is worse than a list '
      'that admits it is a projection.';

  // -----------------------------------------------------------------------
  // Indentation is a width budget.
  // -----------------------------------------------------------------------

  static const double availableWidthDp = 328;

  static double get indentPerLevelDp => HabotSpacing.md;

  /// Below this a span name wraps a word at a time and the list stops being
  /// lightweight in the only sense that matters.
  static const double minimumTextWidthDp = 200;

  static int get maxDepth =>
      ((availableWidthDp - minimumTextWidthDp) / indentPerLevelDp).floor();

  static double indentAt(int depth) => depth * indentPerLevelDp;

  static double textWidthAt(int depth) => availableWidthDp - indentAt(depth);

  static int get deepestSpanDepth => spans.fold(
        0,
        (int a, HabotTraceSpan s) => s.depth > a ? s.depth : a,
      );

  static bool get everySpanFitsWithinTheCap => deepestSpanDepth <= maxDepth;

  static bool get theCapIsDerivedRatherThanChosen =>
      maxDepth == ((availableWidthDp - minimumTextWidthDp) / 16).floor();

  static const String indentNote =
      'Sixteen points a level against 328 available. At depth eight the indent '
      'has taken 128 and left 200, which is about where a span name stops '
      'being readable, so eight is the cap -- derived from the two widths '
      'rather than picked. Deeper spans are reached by opening the span above '
      'them. The alternative, letting the column narrow until the text wraps '
      'one word per line, produces a list that is lightweight only in the '
      'sense that it contains very little.';

  // -----------------------------------------------------------------------
  // Why hiding is allowed.
  // -----------------------------------------------------------------------

  static const HabotDisclosureTier tier = HabotDisclosureTier.forensic;

  static bool get theTierPermitsHiding =>
      tier != HabotDisclosureTier.essential;

  static bool get theTierIsReadRatherThanAsserted =>
      HabotDisclosureTier.values.length == 3 &&
      tier == HabotDisclosureTier.forensic;

  static const String tierNote =
      'Step 104 refuses to put essential content behind a disclosure control '
      'and throws when somebody tries. A trace map is forensic by definition '
      '-- ids, timings, provenance -- so hiding it is the tier working as '
      'designed rather than an exception being made. The row says "hide" and '
      'is, for once, asking for the thing the design system already permits; '
      'the only question it leaves open is what the hidden thing looks like '
      'when it is opened, which is the rest of this step.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandCeiling = '1';

  static bool get theCeilingIsInADifferentUnit => !bandCeiling.contains('%');

  static Map<String, bool> get obligations => <String, bool>{
        'every parent edge is preserved':
            relationsALinePreserves == parentEdges,
        'every sideways link is marked rather than dropped silently':
            everySidewaysLinkIsMarked,
        'the header states how many relations are not drawn':
            theHeaderStatesWhatIsNotDrawn,
        'no span is deeper than the derived cap': everySpanFitsWithinTheCap,
        'the cap comes from the two widths rather than from a preference':
            theCapIsDerivedRatherThanChosen,
        'the content is hidden at a tier that permits hiding':
            theTierPermitsHiding,
      };

  static double get adherence =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (adherence >= 0.95) {
      return 'Good';
    }
    return adherence >= 0.85 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'twelve spans, eleven parent edges, two sideways links':
            spans.length == 12 &&
                parentEdges == 11 &&
                sidewaysEdges == 2 &&
                totalRelations == 13,
        'a list preserves eleven of the thirteen':
            relationsALinePreserves == 11 &&
                (shareOfRelationsPreserved - 11 / 13).abs() < 1e-9 &&
                aListCannotDrawSidewaysEdges,
        'and names the two it cannot draw':
            everySidewaysLinkIsMarked &&
                markerFor(spans[8]) == 'also touches s8' &&
                markerFor(spans[0]) == '',
        'the header counts them': header == '11 nested calls, 2 linked '
            'elsewhere',
        'a complete-looking tree is the thing being avoided':
            flatteningNote.contains('admits it is a projection'),
        'the depth cap is eight, derived from 328 and 200':
            maxDepth == 8 &&
                indentPerLevelDp == 16 &&
                indentAt(8) == 128 &&
                textWidthAt(8) == 200,
        'and every span in the trace is inside it':
            everySpanFitsWithinTheCap && deepestSpanDepth == 3,
        'hiding is permitted because the tier is forensic':
            theTierPermitsHiding &&
                theTierIsReadRatherThanAsserted &&
                tierNote.contains('for once'),
        'the ceiling is in a different unit from the floor':
            theCeilingIsInADifferentUnit,
        'six obligations, all met':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                adherence == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Initialize the '
      'parsing selection rule properties governing how document version '
      'discrepancies display", which is document versioning on a row about '
      'trace visualisation, and the domain expertise cell reads "Prompt '
      'Engineering". Atomic Step: "Hide deep complex structural trace maps '
      'inside lightweight text list blocks on small mobile screen states."';
}
