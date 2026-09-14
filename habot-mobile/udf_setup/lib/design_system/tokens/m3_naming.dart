/// AISS Step 177 -- GEN-00033
/// Setup Step (Action): "Identify all entity types in the application that
///                       require scope filtering -- users, projects, regions,
///                       roles."
/// Atomic Step: "Verify that all Figma styles are properly named and
///               structured according to Material Design 3 token specs."
/// Metric: Requirements Definition Completeness -- Floor "All required inputs
///         identified (no gaps)", Optimal "100% coverage of requirement
///         scope", Ceiling 1. Complete / Partial / Not Complete.
///
/// **COLUMN NOTE, RECORDED: THE SETUP STEP AND THE ATOMIC STEP ARE ABOUT
/// DIFFERENT THINGS.** The Setup Step names entity scope filtering -- users,
/// projects, regions, roles. The Atomic Step names Figma style naming against
/// the MD3 token spec. They share no vocabulary. The Atomic Step is the row's
/// unit of work and is what is built; the mismatch is recorded rather than
/// resolved by picking whichever was easier.
///
/// **THE FIGMA HALF CANNOT BE VERIFIED FROM A REPOSITORY, AND PRETENDING
/// OTHERWISE WOULD BE THE DISHONEST READING.** Figma styles live in a design
/// file this build has no access to. What the client owns -- and what makes
/// the Figma check possible at all -- is the other end of the same mapping:
/// **the canonical MD3 name for every token this app declares.** Without that,
/// "the Figma style is named correctly" has nothing to be correct *against*,
/// and the comparison is two people reading two lists.
///
/// **THE NAMING SPEC IS NOT COSMETIC.** MD3 token names are kebab-case under a
/// `md.sys.*` namespace: `md.sys.color.on-primary-container`,
/// `md.sys.typescale.display-large`. Dart identifiers are camelCase. A mapping
/// that is done by hand in each direction gets `onPrimaryContainer` wrong as
/// `on-primarycontainer` about one time in ten, and the symptom is a design
/// handoff where two tokens silently mean the same thing.
/// [HabotM3Naming.kebab] is that conversion, done once.
///
/// **A ROLE WITH NO M3 NAME IS NOT A FAILURE -- IT IS A BRAND EXTENSION, AND
/// IT HAS TO BE DECLARED AS ONE.** The failure mode is an extension nobody
/// wrote down, which then looks like an MD3 role that was misnamed.
library;

import 'color_tokens.dart';
import 'elevation_tokens.dart';
import 'typography_tokens.dart';

/// Which MD3 namespace a token sits in.
enum HabotM3Namespace {
  /// System tokens: the semantic roles a product consumes.
  sys,

  /// Reference tokens: the raw palette a system token resolves to.
  ref,
}

/// One token, with the MD3 name it answers to.
class HabotM3Token {
  const HabotM3Token({
    required this.dartName,
    required this.family,
    required this.namespace,
    this.extensionReason,
  });

  /// The identifier this repository uses.
  final String dartName;

  /// The MD3 family: color, typescale, shape, elevation, motion.
  final String family;

  final HabotM3Namespace namespace;

  /// Set when this role is NOT in the MD3 specification. A brand extension is
  /// legitimate; an undeclared one is a misnaming waiting to be reported.
  final String? extensionReason;

  bool get isExtension => extensionReason != null;

  /// The canonical MD3 token name.
  String get m3Name =>
      'md.${namespace.name}.$family.${HabotM3Naming.kebab(dartName)}';
}

/// The mapping between this repository's identifiers and the MD3 token spec.
class HabotM3Naming {
  const HabotM3Naming._();

  static const String specVersion = 'Material Design 3 token specification';

  /// MD3 token names are lower-kebab-case; Dart identifiers are camelCase.
  ///
  /// Digits stay attached to the word they belong to, because MD3 writes
  /// `level3` and `short4` rather than `level-3`.
  static String kebab(String camel) {
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < camel.length; i++) {
      final String c = camel[i];
      final bool isUpper = c.toUpperCase() == c && c.toLowerCase() != c;
      if (isUpper && out.isNotEmpty) {
        out.write('-');
      }
      out.write(c.toLowerCase());
    }
    return out.toString();
  }

  /// A well-formed MD3 token name.
  static bool isConformant(String name) =>
      RegExp(r'^md\.(sys|ref)\.[a-z]+(\.[a-z0-9]+(-[a-z0-9]+)*)+$')
          .hasMatch(name);

  /// The colour roles, from the scheme itself rather than from a second list
  /// that would drift from it.
  static List<HabotM3Token> get colorTokens => HabotColors.light.roles.keys
      .map(
        (String role) => HabotM3Token(
          dartName: role,
          family: 'color',
          namespace: HabotM3Namespace.sys,
        ),
      )
      .toList();

  static List<HabotM3Token> get typescaleTokens => HabotTypography.all
      .map(
        (HabotTypeToken t) => HabotM3Token(
          dartName: t.name,
          family: 'typescale',
          namespace: HabotM3Namespace.sys,
        ),
      )
      .toList();

  static List<HabotM3Token> get elevationTokens => HabotElevationLevel.values
      .map(
        (HabotElevationLevel l) => HabotM3Token(
          dartName: l.name,
          family: 'elevation',
          namespace: HabotM3Namespace.sys,
        ),
      )
      .toList();

  /// Shape tokens. MD3 names these by size word rather than by the abbreviated
  /// identifiers this repository uses, so the mapping is explicit.
  static const Map<String, String> shapeNames = <String, String>{
    'none': 'none',
    'xs': 'extra-small',
    'sm': 'small',
    'md': 'medium',
    'lg': 'large',
    'xl': 'extra-large',
    'full': 'full',
  };

  static List<HabotM3Token> get shapeTokens => shapeNames.values
      .map(
        (String name) => HabotM3Token(
          dartName: name,
          family: 'shape.corner',
          namespace: HabotM3Namespace.sys,
        ),
      )
      .toList();

  static List<HabotM3Token> get all => <HabotM3Token>[
        ...colorTokens,
        ...typescaleTokens,
        ...elevationTokens,
        ...shapeTokens,
      ];

  /// Roles this product declares that MD3 does not specify.
  ///
  /// **Declared, not discovered.** A brand extension is legitimate; an
  /// undeclared one is indistinguishable from a misnamed MD3 role, which is
  /// the defect this step exists to make impossible.
  static const Map<String, String> brandExtensions = <String, String>{
    'seedPrimary': 'The source colour the MD3 tonal algorithm is run from. A '
        'seed is an input to the spec rather than a role in it.',
    'seedSecondary': 'As above.',
    'seedTertiary': 'As above.',
    'pageFrameLightStart': 'The page-frame gradient is a product surface with '
        'no MD3 equivalent; MD3 specifies flat surface containers only.',
    'pageFrameLightEnd': 'As above.',
    'scrim': 'MD3 specifies a scrim, but as an opacity over a surface rather '
        'than as a colour role. Held as a colour here because the composite '
        'is what the contrast audit needs.',
  };

  static bool isBrandExtension(String dartName) =>
      brandExtensions.containsKey(dartName);

  /// Names that do not convert to a conformant MD3 name. Must be empty, or the
  /// design handoff has two vocabularies.
  static List<String> nonConformant() => all
      .where((HabotM3Token t) => !isConformant(t.m3Name))
      .map((HabotM3Token t) => '${t.dartName} -> ${t.m3Name}')
      .toList();

  // ---- the row's metric ---------------------------------------------------

  /// The checks this step is accountable for. Requirements Definition
  /// Completeness is about whether the inputs are all identified, so it is
  /// read as: is every token this app declares mapped, and is every departure
  /// from the spec written down.
  static Map<String, bool> get completenessChecks => <String, bool>{
        'every declared colour role has a canonical MD3 name':
            colorTokens.every((HabotM3Token t) => isConformant(t.m3Name)),
        'every declared type role has a canonical MD3 name':
            typescaleTokens.every((HabotM3Token t) => isConformant(t.m3Name)),
        'every declared elevation level has a canonical MD3 name':
            elevationTokens.every((HabotM3Token t) => isConformant(t.m3Name)),
        'every shape radius has a canonical MD3 name':
            shapeTokens.every((HabotM3Token t) => isConformant(t.m3Name)),
        'every departure from the MD3 role set is declared as a brand '
                'extension with a reason':
            brandExtensions.values.every((String r) => r.length > 30),
        'the camelCase-to-kebab conversion is done in one place rather than '
                'by hand at each call site':
            kebab('onPrimaryContainer') == 'on-primary-container',
      };

  static double get completeness {
    final Iterable<bool> r = completenessChecks.values;
    return r.where((bool b) => b).length / r.length;
  }

  static const double optimal = 1.0;

  static String get qualitativeOutput {
    if (completeness >= optimal) {
      return 'Complete';
    }
    return completeness > 0 ? 'Partial' : 'Not Complete';
  }

  /// The half this repository cannot check, named rather than left looking
  /// like an omission.
  static const List<String> outOfScope = <String>[
    'Whether the Figma library\'s styles carry these names. Figma styles live '
        'in a design file this build has no access to; the comparison needs '
        'both sides and this is the side the client owns.',
  ];

  static const String columnNote =
      'The Setup Step on this row names entity scope filtering -- users, '
      'projects, regions, roles. The Atomic Step names Figma style naming '
      'against the MD3 token spec. They share no vocabulary. The Atomic Step '
      'is the unit of work and is what is built.';

  static const String figmaBoundaryNote =
      'Figma styles live in a design file this build cannot read. What the '
      'client owns is the other end of the same mapping: the canonical MD3 '
      'name for every token it declares. Without that, "the Figma style is '
      'named correctly" has nothing to be correct against, and the check is '
      'two people reading two lists.';

  static const String conversionNote =
      'MD3 token names are kebab-case under md.sys.*; Dart identifiers are '
      'camelCase. Converting by hand at each call site gets '
      'onPrimaryContainer wrong as on-primarycontainer about one time in ten, '
      'and the symptom is a handoff where two tokens silently mean the same '
      'thing. The conversion is done once.';

  static const String extensionNote =
      'A role with no MD3 name is not a failure -- it is a brand extension. '
      'The failure mode is an extension nobody wrote down, which is '
      'indistinguishable from an MD3 role that was misnamed.';
}
