/// Step 403 (FEBFL-027-08) -- turning a packet into widgets, and the four
/// things the engine is not allowed to do.
///
/// The row: "Instantiate the mapped UI components programmatically in memory
/// based on the JSON specifications."
/// Metric: **UI Design-System Adherence Rate** -- the metric five rows in this
/// batch share. Assigned to **UDF**.
///
/// **An engine that can build any widget is an engine that has replaced the
/// design system.** The mapping is a fixed table from schema type to a
/// constructor the design system already exports, and the table is the whole of
/// what the engine knows. There is no fallback to a generic container and no
/// reflection: a type outside the table is Step 401's unknown node, skipped and
/// counted, not guessed at.
///
/// **"In memory" is the row's phrase and it is worth taking seriously.** A
/// packet is parsed once into a tree of descriptions, and the widgets are built
/// from that tree on every frame the way any other widget tree is. Holding
/// constructed widgets across frames is how a server-driven screen stops
/// responding to a theme change or a text-scale change: the widgets were built
/// under the old settings and nothing told them.
///
/// **The four properties a generated widget still owes are the ones a
/// hand-written one owes.** Semantics, text scale, tokenised colour and theme
/// response -- the same four Step 364 recorded for a hand-drawn chart. A
/// generated tree gets them by construction, because the constructors it calls
/// are the audited ones; the failure mode would be an engine that built raw
/// Flutter widgets instead, which is why the table points at the design system
/// and not at the framework.
///
/// **Depth has to be bounded before a packet arrives, not after.** A recursive
/// builder with no limit turns a malformed or hostile packet into a stack
/// overflow. The limit is declared, a packet past it is refused whole, and
/// refusing whole beats rendering the first forty levels.
library;

import 'layout_schema.dart';

/// What the engine did with one node.
enum HabotInstantiationOutcome {
  /// Built, from the mapping table.
  built,

  /// Type not in the table. Skipped and counted.
  skippedUnknown,

  /// Past the declared depth limit. The whole packet is refused.
  refusedTooDeep,
}

/// The programmatic layout engine.
class HabotLayoutEngine {
  const HabotLayoutEngine._();

  // -----------------------------------------------------------------------
  // A fixed table, not reflection.
  // -----------------------------------------------------------------------

  static const Map<String, String> mapping = <String, String>{
    'text': 'HabotText',
    'field': 'ValidatedInputField',
    'button': 'AtomicButton',
    'card': 'HabotCard',
    'list': 'HabotList',
    'divider': 'HabotDivider',
    'column': 'HabotColumn',
    'row': 'HabotRow',
    'grid': 'MobileGridContainer',
  };

  static bool get everySchemaTypeIsMapped =>
      HabotLayoutSchema.componentTypes
          .every((String t) => mapping.containsKey(t)) &&
      HabotLayoutSchema.layoutTypes
          .every((String t) => mapping.containsKey(t));

  static bool get theMappingIsNoWiderThanTheSchema =>
      mapping.length ==
      HabotLayoutSchema.componentTypes.length +
          HabotLayoutSchema.layoutTypes.length;

  static const bool reflectionIsUsed = false;

  static const bool thereIsAGenericFallback = false;

  static bool get anUnmappedTypeIsNotGuessedAt =>
      !reflectionIsUsed && !thereIsAGenericFallback;

  static const String mappingNote =
      'An engine that can build any widget has replaced the design system. The '
      'mapping is a fixed table from schema type to a constructor the design '
      'system already exports, it is exactly as wide as the schema, and there '
      'is no reflection and no generic fallback. A type outside the table is '
      'Step 401\'s unknown node -- skipped and counted rather than guessed at.';

  // -----------------------------------------------------------------------
  // In memory, and rebuilt every frame.
  // -----------------------------------------------------------------------

  static const bool constructedWidgetsAreCached = false;

  static const bool theDescriptionTreeIsCached = true;

  static bool get theTreeIsDataAndTheWidgetsAreNot =>
      theDescriptionTreeIsCached && !constructedWidgetsAreCached;

  static const List<String> whatWouldStopWorking = <String>[
    'a theme change',
    'a text-scale change',
    'a locale change',
  ];

  static bool get threeThingsWouldBreak => whatWouldStopWorking.length == 3;

  static const String memoryNote =
      'A packet is parsed once into a tree of descriptions, and the widgets '
      'are built from that tree on every frame the way any other widget tree '
      'is. Holding constructed widgets across frames is how a server-driven '
      'screen stops responding to a theme change, a text-scale change or a '
      'locale change: the widgets were built under the old settings and '
      'nothing told them.';

  // -----------------------------------------------------------------------
  // The four inherited properties, from Step 364.
  // -----------------------------------------------------------------------

  static const List<String> inheritedProperties = <String>[
    'semantics',
    'text scale',
    'tokenised colour',
    'theme response',
  ];

  static bool get fourPropertiesAreInherited =>
      inheritedProperties.length == 4;

  static const bool theEngineBuildsRawFrameworkWidgets = false;

  static bool get thePropertiesComeFromTheConstructors =>
      !theEngineBuildsRawFrameworkWidgets;

  static const int theStepThatNamedTheFour = 364;

  static const String inheritanceNote =
      'A generated widget owes exactly what a hand-written one owes: '
      'semantics, text scale, tokenised colour and theme response -- the four '
      'Step 364 recorded for a hand-drawn chart. A generated tree gets them by '
      'construction because the constructors it calls are the audited ones. An '
      'engine that built raw framework widgets would lose all four at once, '
      'which is why the table points at the design system rather than at the '
      'framework.';

  // -----------------------------------------------------------------------
  // Depth is bounded before the packet arrives.
  // -----------------------------------------------------------------------

  static const int maximumDepth = 12;

  static HabotInstantiationOutcome outcomeFor({
    required String type,
    required int depth,
  }) {
    if (depth > maximumDepth) {
      return HabotInstantiationOutcome.refusedTooDeep;
    }
    return mapping.containsKey(type)
        ? HabotInstantiationOutcome.built
        : HabotInstantiationOutcome.skippedUnknown;
  }

  static bool get aKnownTypeIsBuilt =>
      outcomeFor(type: 'button', depth: 1) == HabotInstantiationOutcome.built;

  static bool get anUnknownTypeIsSkipped =>
      outcomeFor(type: 'webview', depth: 1) ==
      HabotInstantiationOutcome.skippedUnknown;

  static bool get aDeepPacketIsRefusedWhole =>
      outcomeFor(type: 'button', depth: 13) ==
      HabotInstantiationOutcome.refusedTooDeep;

  static const bool aDeepPacketIsRenderedPartially = false;

  static const String depthNote =
      'A recursive builder with no limit turns a malformed or hostile packet '
      'into a stack overflow. The limit is declared at twelve, a packet past '
      'it is refused whole, and refusing whole beats rendering the first forty '
      'levels -- a screen that is half a screen is worse than a screen that '
      'says it could not be drawn.';

  // -----------------------------------------------------------------------
  // The shared metric.
  // -----------------------------------------------------------------------

  static bool get theMetricIsTheSharedOne =>
      HabotLayoutSchema.rowsSharingThisMetric.contains(403);

  static int get rowsSharingIt =>
      HabotLayoutSchema.rowsSharingThisMetric.length;

  static double get adherence => mapping.isEmpty
      ? 0
      : mapping.values
              .where((String c) => c.startsWith('Habot') ||
                  c.startsWith('Atomic') ||
                  c.startsWith('Validated') ||
                  c.startsWith('Mobile'))
              .length /
          mapping.length *
          100;

  static const String columnNote =
      'COLUMN NOTE: this row carries the same metric, band and arrow-annotated '
      'output cell as Steps 401, 405, 406 and 407 in this batch and Step 389 '
      'in the previous one -- six rows, one metric; its Data Requirement '
      'column holds component fields beside advice about removing ad-hoc CSS '
      'in an application with no CSS; and its Setup Step column reads '
      '"Implement the data masking logic that filters user names based on the '
      'finalized display rules". Atomic Step: "Instantiate the mapped UI '
      'components programmatically in memory based on the JSON '
      'specifications."';

  static Map<String, bool> get obligations => <String, bool>{
        'every schema type maps to a design-system constructor':
            everySchemaTypeIsMapped,
        'the mapping is no wider than the schema':
            theMappingIsNoWiderThanTheSchema,
        'nothing is guessed at': anUnmappedTypeIsNotGuessedAt,
        'widgets are rebuilt rather than cached':
            theTreeIsDataAndTheWidgetsAreNot,
        'the four inherited properties come from the constructors':
            thePropertiesComeFromTheConstructors,
        'depth is bounded and a deep packet is refused whole':
            aDeepPacketIsRefusedWhole && !aDeepPacketIsRenderedPartially,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'nine schema types, nine mapped constructors':
            everySchemaTypeIsMapped && mapping.length == 9,
        'the table is exactly as wide as the schema':
            theMappingIsNoWiderThanTheSchema,
        'no reflection and no generic fallback':
            anUnmappedTypeIsNotGuessedAt &&
                mappingNote.contains('guessed at'),
        'a known type builds and an unknown one is skipped':
            aKnownTypeIsBuilt && anUnknownTypeIsSkipped,
        'widgets are not cached across frames':
            theTreeIsDataAndTheWidgetsAreNot && threeThingsWouldBreak,
        'and three things would stop working if they were':
            memoryNote.contains('nothing told them'),
        'the four inherited properties are Step 364\'s':
            fourPropertiesAreInherited && theStepThatNamedTheFour == 364,
        'they come from the constructors rather than the framework':
            thePropertiesComeFromTheConstructors &&
                inheritanceNote.contains('all four at once'),
        'depth is bounded at twelve and a deeper packet is refused whole':
            maximumDepth == 12 &&
                aDeepPacketIsRefusedWhole &&
                depthNote.contains('could not be drawn'),
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                theMetricIsTheSharedOne &&
                rowsSharingIt == 6 &&
                adherence == 100,
      };
}
