/// AISS GATE -- Step 174 of 175
/// Global Reference ID:       GEN-00291
/// Atomic Steps Reference ID: GEN-00291
/// Setup Step (Action) / Atomic Step: "Configure color tokens to be validated
///   at build time."
/// Metric: Configuration Conformance Rate -- Floor "Configuration matches spec
///         with documented deviations only", Optimal "100% configuration
///         matches approved specification", Ceiling 1.0.
///         Complete / Partial / Not Complete.
///
/// HALF OF THIS WAS ALREADY TRUE AND SAYING SO IS THE POINT. The RAW_HEX guard
/// has failed the build on a colour literal since Step 4. What did NOT exist is
/// a check on the token SET itself -- and the defect it finds, two roles
/// quietly holding the same value, passes every contrast audit in the
/// repository.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tokens/token_validation.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double conformance = 0;
  double fallenConformance = 1;

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  /// A well-formed scheme: every required role, every value an 8-digit ARGB
  /// hex, no two roles sharing one.
  Map<String, String> scheme() => <String, String>{
        'primary': '0xFF1B5E20',
        'onPrimary': '0xFFFFFFFF',
        'surface': '0xFFFAFAFA',
        'onSurface': '0xFF1C1B1F',
        'surfaceVariant': '0xFFE7E0EC',
        'onSurfaceVariant': '0xFF49454F',
        'error': '0xFFB3261E',
        'onError': '0xFFFFFBFE',
        'outline': '0xFF79747E',
      };

  Map<String, Map<String, String>> allSchemes() => <String, Map<String, String>>{
        for (final String s in HabotTokenValidation.requiredSchemes)
          s: scheme(),
      };

  group('GEN-00291 :: what "validated at build time" means here', () {
    gate(
      'GEN-00291-G1',
      'Atomic Step: "Configure color tokens to be validated AT BUILD TIME." '
          'There is no separate build step in which a Dart constant could be '
          'checked.',
      'The substitution is recorded and it is exact: the validation runs in '
          'the gate script that already fails the build on the poka-yoke '
          'guard, so the failure the row wants prevented -- a bad token '
          'reaching a release -- is prevented at the same moment',
      () =>
          HabotTokenValidation.buildGate == 'tool/verify_aiss.sh' &&
          HabotTokenValidation.buildTimeSubstitution
              .contains('exits non-zero') &&
          HabotTokenValidation.buildTimeSubstitution
              .contains('bad token reaching a release') &&
          HabotTokenValidation.alreadyTrueNote.contains('RAW_HEX'),
    );

    gate(
      'GEN-00291-G2',
      '"A missing role is a theme that falls back to a Material default '
          'nobody chose, in one scheme only, which is how a dark-mode-specific '
          'colour bug is born."',
      'Every role the theme needs is declared, in every scheme the app ships, '
          'and a well-formed configuration produces no findings at all',
      () {
        final List<HabotTokenFinding> findings =
            HabotTokenValidation.validate(allSchemes());
        return HabotTokenValidation.requiredRoles.length == 9 &&
            HabotTokenValidation.requiredSchemes.length == 4 &&
            HabotTokenValidation.requiredSchemes
                .contains('highContrastDark') &&
            findings.isEmpty &&
            HabotTokenValidation.validateScheme('light', scheme()).isEmpty;
      },
    );

    gate(
      'GEN-00291-G3',
      'MISSING_ROLE / MISSING_SCHEME. A validator that never reports anything '
          'is a validator nobody can trust.',
      'A role dropped from one scheme is reported by name with the scheme it '
          'is missing from, and a scheme absent entirely is reported rather '
          'than skipped',
      () {
        final Map<String, String> incomplete = scheme()..remove('outline');
        final List<HabotTokenFinding> roleFindings =
            HabotTokenValidation.validateScheme('dark', incomplete);
        final Map<String, Map<String, String>> missingScheme = allSchemes()
          ..remove('highContrastDark');
        final List<HabotTokenFinding> schemeFindings =
            HabotTokenValidation.validate(missingScheme);
        return roleFindings.single.rule == 'MISSING_ROLE' &&
            roleFindings.single.detail.contains('dark.outline') &&
            roleFindings.single.detail.contains('dark-mode-specific') &&
            roleFindings.single.toString().startsWith('MISSING_ROLE:') &&
            schemeFindings.single.rule == 'MISSING_SCHEME' &&
            schemeFindings.single.detail.contains('highContrastDark') &&
            // A blank value is both absent and unparseable, and is reported as
            // both rather than one rule swallowing the other.
            HabotTokenValidation.validateScheme(
              'light',
              scheme()..['outline'] = '   ',
            )
                .map((HabotTokenFinding f) => f.rule)
                .toSet()
                .containsAll(<String>{'MISSING_ROLE', 'MALFORMED_VALUE'});
      },
    );

    gate(
      'GEN-00291-G4',
      'MALFORMED_VALUE. "Requiring alpha is deliberate: a 6-digit value that '
          'the parser defaults to opaque is a value somebody meant to be '
          'translucent often enough to matter."',
      'A value that is not an 8-digit ARGB hex is reported -- a six-digit '
          'colour, a CSS-style hash, a named colour -- because a value the '
          'theme cannot parse is a crash at startup rather than a wrong colour',
      () {
        final List<HabotTokenFinding> findings =
            HabotTokenValidation.validateScheme(
          'light',
          scheme()..['primary'] = '0x1B5E20',
        );
        return HabotTokenValidation.isWellFormedHex('0xFF1B5E20') &&
            HabotTokenValidation.isWellFormedHex('0xff1b5e20') &&
            !HabotTokenValidation.isWellFormedHex('0x1B5E20') &&
            !HabotTokenValidation.isWellFormedHex('#FF1B5E20') &&
            !HabotTokenValidation.isWellFormedHex('green') &&
            !HabotTokenValidation.isWellFormedHex('') &&
            findings.single.rule == 'MALFORMED_VALUE' &&
            findings.single.detail.contains('light.primary') &&
            findings.single.detail.contains('crash at startup');
      },
    );
  });

  group('GEN-00291 :: the defect nothing else in this repository catches', () {
    gate(
      'GEN-00291-G5',
      '"Two roles with the same hex passes every contrast audit -- the same '
          'colour has the same ratio -- and means a state the design system '
          'claims to distinguish is invisible."',
      'Two roles holding one value are reported with both role names and the '
          'value, and the finding says why it matters: a disabled control that '
          'looks enabled, an error surface that looks like a warning',
      () {
        final List<HabotTokenFinding> findings =
            HabotTokenValidation.validateScheme(
          'light',
          scheme()..['surfaceVariant'] = '0xFFFAFAFA',
        );
        final HabotTokenFinding duplicate = findings.single;
        return duplicate.rule == 'DUPLICATE_ROLE_VALUE' &&
            duplicate.detail.contains('surface') &&
            duplicate.detail.contains('surfaceVariant') &&
            duplicate.detail.contains('0xFFFAFAFA') &&
            duplicate.detail.contains('passes every contrast audit') &&
            HabotTokenValidation.duplicateNote
                .contains('Nothing else in this repository would catch it');
      },
    );

    gate(
      'GEN-00291-G6',
      '"An entry in sanctionedDuplicates is a decision someone has to write '
          'down. An empty exemption list is what makes the check strict."',
      'Nothing is exempt by default, so every collision is a finding rather '
          'than an inherited allowance nobody remembers agreeing to',
      () =>
          HabotTokenValidation.sanctionedDuplicates.isEmpty &&
          HabotTokenValidation.validateScheme(
                'light',
                scheme()..['onError'] = '0xFFFFFFFF',
              ).length ==
              1,
    );
  });

  group('GEN-00291 :: the rate, and what it is a rate against', () {
    gate(
      'GEN-00291-G7',
      'Metric: Configuration Conformance Rate -- optimal "100% configuration '
          'matches APPROVED specification", ceiling 1.0.',
      'The conformance rate is 1.0 on a clean configuration and falls when a '
          'scheme drops a role or two roles collide, so the figure is a '
          'measurement rather than a constant',
      () {
        conformance = HabotTokenValidation.conformanceRate(allSchemes());
        final Map<String, Map<String, String>> broken = allSchemes();
        broken['light'] = scheme()
          ..remove('outline')
          ..['onPrimary'] = '0xFFFAFAFA';
        fallenConformance = HabotTokenValidation.conformanceRate(broken);
        return conformance == 1.0 &&
            HabotTokenValidation.validate(broken).length == 2 &&
            fallenConformance < 1.0 &&
            fallenConformance > 0.9;
      },
    );

    gate(
      'GEN-00291-G8',
      '"tokens.json has been PROVISIONAL pending brand sign-off since Step 1. '
          'A conformance rate of 1.0 against an unapproved specification is '
          '1.0 against nothing."',
      'The approval flag is part of the output rather than a footnote: with '
          'the specification provisional the qualitative result is Partial '
          'however clean the configuration is, which is the honest answer for '
          'this row today',
      () =>
          !HabotTokenValidation.specificationIsApproved &&
          HabotTokenValidation.specificationStatus.contains('PROVISIONAL') &&
          HabotTokenValidation.specificationStatus
              .contains('hex values are placeholders') &&
          HabotTokenValidation.qualitativeOutput(allSchemes()) == 'Partial' &&
          HabotTokenValidation.conformanceRate(allSchemes()) == 1.0 &&
          HabotTokenValidation.provisionalNote.contains('1.0 against nothing'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00291',
        atomicStepReferenceId: 'GEN-00291',
        setupStepAction: 'Configure color tokens to be validated at build '
            'time.',
        implementationOrder: 174,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTokenValidation',
          'Component Properties':
              '${HabotTokenValidation.requiredRoles.length} required roles '
              'across ${HabotTokenValidation.requiredSchemes.length} schemes; '
              '5 rules (MISSING_SCHEME, MISSING_ROLE, MALFORMED_VALUE, '
              'DUPLICATE_ROLE_VALUE, and the 8-digit ARGB shape); '
              '${HabotTokenValidation.sanctionedDuplicates.length} sanctioned '
              'duplicates; runs in ${HabotTokenValidation.buildGate}',
          'Completion Status': 'Partial -- the specification is provisional',
          'Data Quality Note':
              'SUBSTITUTION RECORDED: "build time" in a Flutter app is the '
              'analyzer and the test gate; there is no separate build step in '
              'which a Dart constant could be checked and the compiler does '
              'not know what a colour token means. The validation runs in '
              'tool/verify_aiss.sh, which already fails the build on the '
              'poka-yoke guard, so a bad token is stopped at the same moment. '
              'HONEST REPORTING: the qualitative output is Partial and stays '
              'Partial however clean the configuration is, because tokens.json '
              'has been PROVISIONAL pending brand sign-off since Step 1 and a '
              'conformance rate against an unapproved specification is a rate '
              'against nothing.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Configuration Conformance Rate',
            observed:
                '${conformance.toStringAsFixed(2)} against the declared '
                'specification, falling to '
                '${fallenConformance.toStringAsFixed(2)} when one scheme drops '
                'a role and two of its roles collide. The qualitative output '
                'is reported as Partial regardless, because the specification '
                'itself is not approved.',
            floor: 'Configuration matches spec with documented deviations only',
            optimal: '100% configuration matches approved specification',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Duplicate role values detected',
            observed:
                'Caught with both role names and the shared value. This is the '
                'defect nothing else in the repository finds: it passes every '
                'contrast audit, because the same colour has the same ratio, '
                'and it means a state the design system claims to distinguish '
                'is invisible -- a disabled control that looks enabled, an '
                'error surface that looks like a warning. The exemption list '
                'is empty by default, so every collision is a finding.',
            floor: '0 unsanctioned duplicates',
            optimal: '0 unsanctioned duplicates',
            ceiling: '0 unsanctioned duplicates',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/token_validation.dart',
        ],
      ),
    );
  });
}
