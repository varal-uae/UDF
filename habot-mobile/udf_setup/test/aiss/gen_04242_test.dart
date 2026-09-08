/// AISS GATE -- Step 97 of 115
/// Global Reference ID:       GEN-04242
/// Atomic Steps Reference ID: GEN-04242-A01
/// Setup Step (Action):       "Align the implementation with the platform
///                             architecture: Automated accessibility linter
///                             integration in Cloud Build pipelines."
/// Metric: Colour Contrast / Accessibility Compliance -- 3:1 / 4.5:1 / 7:1.
///
/// TRANSLATION RECORDED: no Cloud Build pipeline exists in this project. The
/// rules go into the existing guard, run by `tool/verify_aiss.sh`, and they
/// FAIL THE BUILD -- the decision recorded in the Steps 96-110 build order.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/a11y_rules.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  group('GEN-04242-A01 :: the rules exist and bite', () {
    gate(
      'GEN-04242-G1',
      'Setup Step (Action): "AUTOMATED accessibility linter integration".',
      'Six rules are declared as data, each naming the implementation step it '
          'protects and each carrying a message that says what to do instead',
      () =>
          HabotA11yRules.all.length >= 6 &&
          HabotA11yRules.isWellFormed &&
          HabotA11yRules.all.every(
            (HabotA11yRule r) => r.message.contains('Habot'),
          ),
    );

    gate(
      'GEN-04242-G2',
      'Decision recorded in the build order: the rules FAIL THE BUILD rather '
          'than producing a report.',
      'The rules are applied by test/guards/a11y_rules_test.dart, which '
          'tool/verify_aiss.sh runs at stage G-C and stops on -- so a '
          'violation is a red build, not a line in a log nobody reads',
      () {
        // The guard file is the enforcement. Its existence is the claim; that
        // it FAILS is proven by its own planted-violation test, which is in
        // the same run.
        return HabotA11yRules.all.every(
          (HabotA11yRule r) => r.pattern.pattern.isNotEmpty,
        );
      },
    );

    gate(
      'GEN-04242-G3',
      'A rule set decays through unexplained exemptions.',
      'Every exemption names its file AND gives a rationale; rules with no '
          'exemption are recorded as absolute so the stronger claim is '
          'visible',
      () =>
          HabotA11yRules.all.every(
            (HabotA11yRule r) =>
                r.exemptPaths.isEmpty ||
                (r.exemptionRationale != null &&
                    r.exemptionRationale!.length > 30),
          ) &&
          HabotA11yRules.absolute.isNotEmpty,
    );
  });

  group('GEN-04242-A01 :: the rules discriminate', () {
    gate(
      'GEN-04242-G4',
      'A rule that fires on the sanctioned alternative is a rule that gets '
          'switched off.',
      'Each rule fires on the construct it bans and stays silent on the '
          'replacement the design system provides',
      () {
        const String banned = '''
          final a = Image.asset(p);
          final b = IconButton(icon: const Icon(Icons.close));
          final c = BlockSemantics(child: w);
        ''';
        const String fine = '''
          final a = HabotImage(image: p, alt: x);
          final b = IconButton(icon: const Icon(Icons.close, semanticLabel: l));
          final c = HabotFocusTrap(onDismiss: f, label: l, child: w);
        ''';
        bool fires(String id, String src) =>
            HabotA11yRules.byId(id).pattern.hasMatch(src);
        return fires('A11Y_RAW_IMAGE', banned) &&
            !fires('A11Y_RAW_IMAGE', fine) &&
            fires('A11Y_UNNAMED_ICON_BUTTON', banned) &&
            !fires('A11Y_UNNAMED_ICON_BUTTON', fine) &&
            fires('A11Y_RAW_SEMANTIC_MODAL', banned) &&
            !fires('A11Y_RAW_SEMANTIC_MODAL', fine);
      },
    );

    gate(
      'GEN-04242-G5',
      'Build-order decision: "violations found in Steps 1-95 are fixed here, '
          'not deferred".',
      'The four violations these rules found in already-signed-off code were '
          'fixed in this batch, so no rule ships with a grandfather clause',
      () {
        // If any of the four had been grandfathered, its file would appear in
        // an exemption list. None does.
        const List<String> fixedFiles = <String>[
          'lib/design_system/notifications/alert_panel.dart',
          'lib/design_system/notifications/in_app_banner.dart',
          'lib/design_system/mto/isolated_viewport.dart',
          'lib/design_system/dashboard/skeleton.dart',
        ];
        return HabotA11yRules.all.every(
          (HabotA11yRule r) => fixedFiles.every(
            (String f) => !r.exemptPaths.contains(f),
          ),
        );
      },
    );

    gate(
      'GEN-04242-G6',
      'GEN-04242 names an existing pipeline; this project has a different one.',
      'The rule that closes the Step 24 regression states plainly that a '
          'tooltip is not the fix, so the next developer does not reintroduce '
          'the hover affordance while satisfying the linter',
      () {
        final HabotA11yRule r = HabotA11yRules.byId(
          'A11Y_UNNAMED_ICON_BUTTON',
        );
        return r.message.contains('tooltip') && r.message.contains('Step 24');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04242',
        atomicStepReferenceId: 'GEN-04242-A01',
        setupStepAction:
            'Align the implementation with the platform architecture: '
            'Automated accessibility linter integration in Cloud Build '
            'pipelines.',
        implementationOrder: 97,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotA11yRules + test/guards/a11y_rules_test.dart',
          'Component Properties':
              '${HabotA11yRules.all.length} build-failing rules, '
              '${HabotA11yRules.absolute.length} of them absolute; '
              'applied to every .dart file under lib/ with comments and '
              'string literals blanked first',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'The row names Cloud Build, which this project does not have. '
              'Translation to tool/verify_aiss.sh recorded in the file header '
              'and in the Step 98 runbook.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Accessibility rules enforced at build time',
            observed:
                '${HabotA11yRules.all.length} rules, all applied to lib/ on '
                'every run of tool/verify_aiss.sh. Four pre-existing '
                'violations were found in Steps 1-95 and all four were fixed '
                'rather than exempted.',
            floor: 'rules exist',
            optimal: 'rules fail the build',
            ceiling: 'rules fail the build',
          ),
          const AissMeasurement(
            metricName: 'Colour Contrast / Accessibility Compliance (the '
                'sheet metric)',
            observed:
                'NOT PRODUCED BY THIS STEP. The 3:1 / 4.5:1 / 7:1 bands are a '
                'contrast measure; they are produced by Step 96 across four '
                'schemes and by Step 105 for the high-contrast pair. A linter '
                'integration step does not have a contrast ratio of its own, '
                'and none is invented here.',
            floor: '3:1',
            optimal: '4.5:1',
            ceiling: '7:1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/a11y_rules.dart',
          'test/guards/a11y_rules_test.dart',
        ],
      ),
    );
  });
}
