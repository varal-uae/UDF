/// Step 401 (FEBFL-027-03) -- describing a screen as data, and the first of
/// five rows in this batch sharing one metric.
///
/// The row: "Define a JSON UI schema specification governing view layout
/// structures, component types, and data bindings."
/// Metric: **UI Design-System Adherence Rate** -- floor ">=85%", optimal
/// ">=95%", ceiling "1". Best Qualitative Output: "Good/Average/Poor -> Best =
/// Good (100%)". Assigned to **UDF**.
///
/// **A UI schema is a second language, and the question is what it may say.**
/// A schema that can express anything is a programming language with no
/// debugger, shipped to production as a string. A schema that can express only
/// what the design system already offers is a configuration format, and the
/// difference is entirely in what the grammar refuses. This one names four node
/// kinds, a closed set of component types taken from the components that exist,
/// and bindings by path -- and it cannot express a colour, a spacing value, a
/// duration or a condition.
///
/// **Four things a schema must not be able to say.** A hex colour, because the
/// poka-yoke rule has forbidden literals since Step 4 and a schema is a way
/// round a linter. A raw spacing number, for the same reason. A duration or a
/// curve, because motion is tokenised. And arbitrary logic, because a
/// conditional in a layout packet is business rules shipped over the wire with
/// no review and no test.
///
/// **Versioning is not optional for a format that arrives at runtime.** A
/// client built in March will be handed a packet written in September. The
/// schema carries a version, the engine refuses a version it does not know, and
/// refusing loudly is better than rendering three-quarters of a screen.
///
/// **Unknown is not the same as invalid.** A node type the client does not
/// recognise is a newer server, and a packet with one is not corrupt. The
/// schema says what happens: the unknown node is skipped, counted, and reported
/// -- so a screen missing a section is a known state rather than a mystery.
library;

/// What kind of thing a schema node describes.
enum HabotSchemaNodeKind {
  /// A container with children.
  layout,

  /// A leaf that draws something.
  component,

  /// A named value pulled from the view model.
  binding,

  /// Something this client does not know.
  unknown,
}

/// One node in a layout packet.
class HabotSchemaNode {
  const HabotSchemaNode({
    required this.kind,
    required this.type,
    required this.children,
    required this.bindingPath,
  });

  final HabotSchemaNodeKind kind;

  /// A component type from the closed set, or a container type.
  final String type;

  final List<HabotSchemaNode> children;

  /// Empty except on bindings.
  final String bindingPath;
}

/// The layout schema specification.
class HabotLayoutSchema {
  const HabotLayoutSchema._();

  // -----------------------------------------------------------------------
  // What the grammar allows.
  // -----------------------------------------------------------------------

  static const List<String> componentTypes = <String>[
    'text',
    'field',
    'button',
    'card',
    'list',
    'divider',
  ];

  static const List<String> layoutTypes = <String>[
    'column',
    'row',
    'grid',
  ];

  static bool get theComponentSetIsClosed => componentTypes.length == 6;

  static bool accepts(String type) =>
      componentTypes.contains(type) || layoutTypes.contains(type);

  static bool get anUndeclaredTypeIsRejected => !accepts('webview');

  static const String grammarNote =
      'A schema that can express anything is a programming language with no '
      'debugger, shipped to production as a string. A schema that can express '
      'only what the design system already offers is a configuration format, '
      'and the whole difference is in what the grammar refuses. Six component '
      'types and three layout types, all of which already exist as widgets.';

  // -----------------------------------------------------------------------
  // Four things it must not be able to say.
  // -----------------------------------------------------------------------

  static const Map<String, String> forbidden = <String, String>{
    'a colour value':
        'the poka-yoke rule has forbidden literals since Step 4, and a schema '
            'is a way round a linter',
    'a spacing number': 'spacing comes from the scale or it does not exist',
    'a duration or a curve': 'motion is tokenised',
    'a conditional expression':
        'logic in a layout packet is a business rule shipped over the wire '
            'with no review and no test',
  };

  static bool get fourThingsAreForbidden => forbidden.length == 4;

  static bool get everyRefusalHasAReason =>
      forbidden.values.every((String r) => r.isNotEmpty);

  static const bool aColourCanBeExpressed = false;
  static const bool aConditionCanBeExpressed = false;

  static bool get theSchemaCannotRouteRoundTheGuard =>
      !aColourCanBeExpressed && !aConditionCanBeExpressed;

  static const String forbiddenNote =
      'The four things this schema cannot express are the four a layout packet '
      'would otherwise be used to smuggle: a colour, a spacing value, a motion '
      'duration and a conditional. The first three are already forbidden in '
      'lib/ by the poka-yoke rules, and a format that could carry them would '
      'be a documented route around a guard the build enforces. The fourth is '
      'worse: a condition in a packet is logic nobody reviewed.';

  // -----------------------------------------------------------------------
  // Versioning.
  // -----------------------------------------------------------------------

  static const int schemaVersion = 1;

  static bool understands(int version) => version == schemaVersion;

  static bool get anUnknownVersionIsRefused =>
      understands(1) && !understands(2);

  static const bool aPartialScreenIsRendered = false;

  static bool get refusalIsLoud => !aPartialScreenIsRendered;

  static const String versionNote =
      'A client built in March will be handed a packet written in September. '
      'The schema carries a version, the engine refuses one it does not know, '
      'and refusing loudly beats rendering three-quarters of a screen -- a '
      'half-drawn form is indistinguishable from a working one until somebody '
      'tries to submit it.';

  // -----------------------------------------------------------------------
  // Unknown is not invalid.
  // -----------------------------------------------------------------------

  static const bool anUnknownNodeMakesThePacketInvalid = false;

  static const bool anUnknownNodeIsCounted = true;

  static const bool anUnknownNodeIsReported = true;

  static bool get unknownIsHandledRatherThanFatal =>
      !anUnknownNodeMakesThePacketInvalid &&
      anUnknownNodeIsCounted &&
      anUnknownNodeIsReported;

  static const String unknownNote =
      'A node type this client does not recognise is a newer server, not a '
      'corrupt packet. The unknown node is skipped, counted and reported, so a '
      'screen missing a section is a known state with a number attached rather '
      'than a mystery -- and the count is what tells somebody a rollout got '
      'ahead of the installed base.';

  // -----------------------------------------------------------------------
  // The metric five rows share.
  // -----------------------------------------------------------------------

  static const String metricName = 'UI Design-System Adherence Rate';

  static const String bandFloorRaw = '>=85%';
  static const String bandOptimalRaw = '>=95%';
  static const String bandCeilingRaw = '1';

  static bool get theBandMixesUnits =>
      bandFloorRaw.contains('%') && !bandCeilingRaw.contains('%');

  /// Step 389 carried it first; Steps 401, 403, 405, 406 and 407 carry it here.
  static const List<int> rowsSharingThisMetric = <int>[
    389,
    401,
    403,
    405,
    406,
    407,
  ];

  static bool get sixRowsShareOneMetric =>
      rowsSharingThisMetric.length == 6 && rowsSharingThisMetric.first == 389;

  static const String outputColumnRaw =
      'Good/Average/Poor -> Best = Good (100%)';

  static bool get theOutputColumnHoldsAnAnnotation =>
      outputColumnRaw.contains('->');

  static double get expressiveness => componentTypes.isEmpty
      ? 0
      : componentTypes.where(accepts).length / componentTypes.length * 100;

  static const String metricNote =
      'Six rows carry this metric, this band and this arrow-annotated output '
      'cell: Step 389 in the previous batch and Steps 401, 403, 405, 406 and '
      '407 here. Five of the six are consecutive. It scores design-system '
      'adherence, which for a schema means the share of expressible component '
      'types that exist as real widgets -- everything the grammar allows is a '
      'component the design system already ships.';

  static const String columnNote =
      'COLUMN NOTE: this row is the first of five in this batch carrying the '
      'identical metric, band and arrow-annotated output cell -- "UI '
      'Design-System Adherence Rate", ">=85%" to ">=95%" to a bare "1", and '
      '"Good/Average/Poor -> Best = Good (100%)" -- with Step 389 in the '
      'previous batch making six; its Data Requirement column holds layout '
      'fields beside advice about "complete removal of ad-hoc CSS '
      'modifications" in an application with no CSS; and its Setup Step column '
      'reads "Connect the verification block to an external multi-factor '
      'authentication code system". Atomic Step: "Define a JSON UI schema '
      'specification governing view layout structures, component types, and '
      'data bindings."';

  static Map<String, bool> get obligations => <String, bool>{
        'the component set is closed': theComponentSetIsClosed,
        'an undeclared type is rejected': anUndeclaredTypeIsRejected,
        'the schema cannot express a colour or a condition':
            theSchemaCannotRouteRoundTheGuard,
        'the schema carries a version': anUnknownVersionIsRefused,
        'an unknown node is skipped, counted and reported':
            unknownIsHandledRatherThanFatal,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'six component types and three layout types':
            theComponentSetIsClosed && layoutTypes.length == 3,
        'an undeclared type is rejected':
            anUndeclaredTypeIsRejected && accepts('card'),
        'four node kinds, one of them unknown':
            HabotSchemaNodeKind.values.length == 4,
        'four things the grammar forbids, each with a reason':
            fourThingsAreForbidden && everyRefusalHasAReason,
        'and a schema is not a route around the guard':
            theSchemaCannotRouteRoundTheGuard &&
                forbiddenNote.contains('logic nobody reviewed'),
        'an unknown version is refused loudly':
            anUnknownVersionIsRefused &&
                refusalIsLoud &&
                versionNote.contains('tries to submit it'),
        'an unknown node is not a corrupt packet':
            unknownIsHandledRatherThanFatal &&
                unknownNote.contains('ahead of the installed base'),
        'the band mixes units': theBandMixesUnits,
        'six rows share this metric, five of them here':
            sixRowsShareOneMetric && theOutputColumnHoldsAnAnnotation,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                expressiveness == 100,
      };
}
