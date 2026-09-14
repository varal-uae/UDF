/// AISS Step 174 -- GEN-00291
/// Setup Step (Action) / Atomic Step: "Configure color tokens to be validated
///   at build time."
/// Metric: Configuration Conformance Rate -- Floor "Configuration matches spec
///         with documented deviations only", Optimal "100% configuration
///         matches approved specification", Ceiling 1.0.
///         Complete / Partial / Not Complete.
///
/// **"BUILD TIME" IN A FLUTTER APP IS THE ANALYZER AND THE TEST GATE.** There
/// is no separate build step in which a Dart constant could be checked; the
/// compiler does not know what a colour token means. What this project has
/// instead is `tool/verify_aiss.sh`, which already fails the build on the
/// poka-yoke guard — so "validated at build time" means a validation that runs
/// there and returns a non-zero exit. The substitution is recorded, and it is
/// exact: the failure the row wants prevented (a bad token reaching a release)
/// is prevented at the same moment.
///
/// **HALF OF THIS IS ALREADY TRUE, AND SAYING SO IS THE POINT.** The RAW_HEX
/// guard has failed the build on a colour literal outside the declaration
/// sites since Step 4, and Steps 4 and 105 audit every pair for contrast. What
/// did NOT exist is a check on the token set ITSELF: that every role the
/// theme needs is declared, that no two roles quietly hold the same value,
/// and that the provisional status of the palette is visible rather than
/// remembered.
///
/// **TWO ROLES WITH THE SAME HEX IS THE DEFECT THIS FINDS.** It passes every
/// contrast audit — the same colour has the same ratio — and it means a state
/// the design system claims to distinguish is invisible: a disabled control
/// that looks enabled, an error surface that looks like a warning. Nothing
/// else in this repository would catch it.
///
/// **A PROVISIONAL PALETTE MUST SAY SO IN THE CONFORMANCE REPORT.**
/// `tokens.json` has been `PROVISIONAL` pending brand sign-off since Step 1.
/// A conformance rate of 1.0 against an unapproved specification is 1.0
/// against nothing, so the flag is part of the output rather than a footnote
/// in a README.
library;

/// One colour role the theme requires.
class HabotColorRole {
  const HabotColorRole({
    required this.name,
    required this.scheme,
    required this.pairsWith,
  });

  final String name;

  /// Which scheme it belongs to: light, dark, high-contrast light or
  /// high-contrast dark.
  final String scheme;

  /// The role it is read against, for the Step 4 contrast audit. Null for a
  /// role nothing is drawn on.
  final String? pairsWith;
}

/// One conformance finding.
class HabotTokenFinding {
  const HabotTokenFinding({
    required this.rule,
    required this.detail,
  });

  final String rule;
  final String detail;

  @override
  String toString() => '$rule: $detail';
}

/// Validates the colour token set.
class HabotTokenValidation {
  const HabotTokenValidation._();

  /// Where the validation runs, and what "build time" means here.
  static const String buildGate = 'tool/verify_aiss.sh';

  /// The roles every scheme must declare. Missing one is a theme that falls
  /// back to a Material default nobody chose.
  static const List<String> requiredRoles = <String>[
    'primary',
    'onPrimary',
    'surface',
    'onSurface',
    'surfaceVariant',
    'onSurfaceVariant',
    'error',
    'onError',
    'outline',
  ];

  /// The schemes the app ships.
  static const List<String> requiredSchemes = <String>[
    'light',
    'dark',
    'highContrastLight',
    'highContrastDark',
  ];

  /// Roles that are allowed to share a value, and why. Everything else
  /// sharing is a finding.
  ///
  /// Empty by default: on this palette nothing legitimately collides, and an
  /// empty exemption list is what makes the check strict. An entry here is a
  /// decision someone has to write down.
  static const Map<String, String> sanctionedDuplicates = <String, String>{};

  /// Validate one scheme's declared tokens.
  ///
  /// [tokens] maps role name to the value as declared -- a hex string, so the
  /// check is on the configuration rather than on a runtime Color, which is
  /// what "validated at build time" asks for.
  static List<HabotTokenFinding> validateScheme(
    String scheme,
    Map<String, String> tokens,
  ) {
    final List<HabotTokenFinding> out = <HabotTokenFinding>[];

    for (final String role in requiredRoles) {
      if (!tokens.containsKey(role) || tokens[role]!.trim().isEmpty) {
        out.add(
          HabotTokenFinding(
            rule: 'MISSING_ROLE',
            detail: '$scheme.$role is not declared. The theme would fall back '
                'to a Material default nobody chose, in one scheme only, '
                'which is how a dark-mode-specific colour bug is born.',
          ),
        );
      }
    }

    for (final MapEntry<String, String> e in tokens.entries) {
      if (!isWellFormedHex(e.value)) {
        out.add(
          HabotTokenFinding(
            rule: 'MALFORMED_VALUE',
            detail: '$scheme.${e.key} is "${e.value}", which is not an 8-digit '
                'ARGB hex. A value the theme cannot parse is a crash at '
                'startup rather than a wrong colour.',
          ),
        );
      }
    }

    final Map<String, List<String>> byValue = <String, List<String>>{};
    for (final MapEntry<String, String> e in tokens.entries) {
      byValue.putIfAbsent(e.value.toUpperCase(), () => <String>[]).add(e.key);
    }
    for (final MapEntry<String, List<String>> e in byValue.entries) {
      if (e.value.length < 2) {
        continue;
      }
      // Sorted so the message is stable whatever order the map iterated in,
      // and reported with the value AS DECLARED rather than with the
      // upper-cased key the comparison used.
      final List<String> roles = e.value.toList()..sort();
      if (sanctionedDuplicates.containsKey(roles.join('+'))) {
        continue;
      }
      out.add(
        HabotTokenFinding(
          rule: 'DUPLICATE_ROLE_VALUE',
          detail: '$scheme: ${roles.join(", ")} all hold '
              '${tokens[roles.first]}. This passes every contrast audit -- the '
              'same colour has the same ratio -- and means a state the design '
              'system claims to distinguish is invisible.',
        ),
      );
    }
    return out;
  }

  /// Validate every scheme.
  static List<HabotTokenFinding> validate(
    Map<String, Map<String, String>> schemes,
  ) {
    final List<HabotTokenFinding> out = <HabotTokenFinding>[];
    for (final String scheme in requiredSchemes) {
      final Map<String, String>? tokens = schemes[scheme];
      if (tokens == null) {
        out.add(
          HabotTokenFinding(
            rule: 'MISSING_SCHEME',
            detail: '$scheme is not declared at all.',
          ),
        );
        continue;
      }
      out.addAll(validateScheme(scheme, tokens));
    }
    return out;
  }

  /// 8-digit ARGB, uppercase or lowercase, with the alpha explicit. Requiring
  /// alpha is deliberate: a 6-digit value that the parser defaults to opaque
  /// is a value somebody meant to be translucent often enough to matter.
  static bool isWellFormedHex(String value) =>
      RegExp(r'^0x[0-9a-fA-F]{8}$').hasMatch(value);

  // ---- the row's metric ---------------------------------------------------

  /// Conformance over the declared checks.
  static double conformanceRate(Map<String, Map<String, String>> schemes) {
    final int checks =
        requiredSchemes.length * (requiredRoles.length + 2);
    final int failures = validate(schemes).length;
    if (checks == 0) {
      return 0;
    }
    final int ok = checks - (failures > checks ? checks : failures);
    return ok / checks;
  }

  /// Whether the specification the configuration is checked against has
  /// actually been approved.
  ///
  /// **This is part of the output, not a footnote.** A conformance rate of
  /// 1.0 against an unapproved specification is 1.0 against nothing.
  static const bool specificationIsApproved = false;

  static const String specificationStatus = 'PROVISIONAL pending brand '
      'sign-off (unchanged since Step 1). Every colour passes its '
      'accessibility gates; the hex values are placeholders.';

  static String qualitativeOutput(Map<String, Map<String, String>> schemes) {
    if (!specificationIsApproved) {
      // Deliberately not "Complete" while the spec is provisional, however
      // clean the configuration is.
      return 'Partial';
    }
    return conformanceRate(schemes) >= 1.0 ? 'Complete' : 'Partial';
  }

  static const String buildTimeSubstitution =
      'There is no separate build step in which a Dart constant could be '
      'checked, and the compiler does not know what a colour token means. '
      'What this project has is tool/verify_aiss.sh, which already fails the '
      'build on the poka-yoke guard, so "validated at build time" means a '
      'validation that runs there and exits non-zero. The substitution is '
      'exact: the failure the row wants prevented -- a bad token reaching a '
      'release -- is prevented at the same moment.';

  static const String alreadyTrueNote =
      'Half of this was already true. RAW_HEX has failed the build on a colour '
      'literal outside the declaration sites since Step 4, and Steps 4 and 105 '
      'audit every pair for contrast. What did not exist is a check on the '
      'token SET: that every required role is declared in every scheme, that '
      'no two roles quietly hold the same value, and that the provisional '
      'status of the palette is visible rather than remembered.';

  static const String duplicateNote =
      'Two roles with the same hex passes every contrast audit -- the same '
      'colour has the same ratio -- and means a state the design system claims '
      'to distinguish is invisible: a disabled control that looks enabled, an '
      'error surface that looks like a warning. Nothing else in this '
      'repository would catch it.';

  static const String provisionalNote =
      'tokens.json has been PROVISIONAL pending brand sign-off since Step 1. '
      'A conformance rate of 1.0 against an unapproved specification is 1.0 '
      'against nothing, so the flag is part of the output and the qualitative '
      'result is Partial however clean the configuration is.';
}
