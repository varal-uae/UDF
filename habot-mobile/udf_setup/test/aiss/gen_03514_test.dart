/// AISS GATE -- Step 179 of 195
/// Global Reference ID:       GEN-03514
/// Atomic Steps Reference ID: GEN-03514
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Package design system linter configurations into a shared
///               build governance repo."
/// Metric: Governance Repo Packaging -- Floor 1, Optimal 1, Ceiling 1.
///         Complete.
///
/// HALF OF THIS WAS ALREADY TRUE. Step 97 extracted the accessibility rules
/// into lib/ because a rule that only exists inside a test file cannot be read
/// by anything else. The poka-yoke rules never got the same treatment. The
/// catalogue deliberately does NOT carry the patterns -- two copies of a regex,
/// only one of which is executed, is the drift this step exists to prevent.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/a11y_rules.dart';
import 'package:udf_setup/design_system/tokens/governance_rules.dart';

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

  group('GEN-03514 :: the catalogue', () {
    gate(
      'GEN-03514-G1',
      'Atomic Step: "Package design system linter configurations into a '
          'shared build governance repo."',
      'Both rule families are declared as data with the same shape: an id, '
          'what is forbidden, what to use instead, why, the owning step and '
          'the severity -- so the rule set can be counted and read rather than '
          'only executed',
      () =>
          HabotGovernanceRules.all.length == 10 &&
          HabotA11yRules.all.length == 6 &&
          HabotGovernance.ruleCount == 16 &&
          HabotGovernanceRules.all.every(
            (HabotGovernanceRule r) =>
                r.id == r.id.toUpperCase() &&
                r.forbids.length > 15 &&
                r.instead.length > 10 &&
                r.why.length > 40 &&
                r.owner.contains('Step') &&
                r.isBlocking,
          ) &&
          HabotGovernance.pokaYokeRuleIds.toSet().intersection(
                HabotGovernance.a11yRuleIds.toSet(),
              ).isEmpty,
    );

    gate(
      'GEN-03514-G2',
      '"A rule that only says no gets worked around; a rule that names the '
          'component gets followed."',
      'Every poka-yoke rule names the sanctioned alternative rather than only '
          'the forbidden construct, and the alternatives are the components '
          'this design system actually ships',
      () {
        final HabotGovernanceRule fab =
            HabotGovernanceRules.byId('ROGUE_FAB');
        final HabotGovernanceRule scaffold =
            HabotGovernanceRules.byId('ROGUE_SCAFFOLD');
        final HabotGovernanceRule colour =
            HabotGovernanceRules.byId('RAW_COLOR_LITERAL');
        return fab.instead.contains('HabotKeyboardAwareFab') &&
            scaffold.instead.contains('HabotMasterScaffold') &&
            colour.instead.contains('HabotColors') &&
            HabotGovernanceRules.byId('RAW_DURATION').instead
                .contains('HabotMotion');
      },
    );

    gate(
      'GEN-03514-G3',
      '"The patterns are deliberately NOT declared in the catalogue. Copying '
          'each regex would give the project two copies, and the copy that '
          'fails the build is the one in the scanner."',
      'The catalogue entry type has no pattern field at all, and the scanner '
          'that does hold the patterns is named in one place so the two can be '
          'tied together rather than drifting',
      () =>
          HabotGovernance.noPatternsHereNote.contains('two copies') &&
          HabotGovernance.noPatternsHereNote
              .contains('only one of them is executed') &&
          HabotGovernanceRules.scanner ==
              'test/guards/poka_yoke_no_hardcoded_values_test.dart' &&
          HabotGovernanceRules.a11yScanner ==
              'test/guards/a11y_rules_test.dart' &&
          HabotGovernance.scanners.length == 2 &&
          HabotGovernance.asymmetryNote.contains('Step 97'),
    );
  });

  group('GEN-03514 :: exemptions, which are how a rule dies', () {
    gate(
      'GEN-03514-G4',
      '"An exemption without a reason is how a rule dies."',
      'Every exempt path in either family carries a written reason, and the '
          'whole set is readable as one list so it can be argued with rather '
          'than discovered one file at a time',
      () =>
          HabotGovernanceRules.unexplainedExemptions.isEmpty &&
          HabotGovernanceRules.exemptions.length == 17 &&
          HabotGovernanceRules.exemptions.values
              .every((String r) => r.length > 20) &&
          HabotGovernanceRules.exemptions.keys
              .every((String k) => k.contains(' @ lib/')),
    );

    gate(
      'GEN-03514-G5',
      'An exemption pointing at an ordinary widget file is a rule somebody '
          'switched off.',
      'Every exempt path is either a declared token site or one of the four '
          'named single implementations, and the rules that admit no exemption '
          'at all are identified as such',
      () =>
          HabotGovernanceRules.exemptionsOutsideDeclaredSites.isEmpty &&
          HabotGovernanceRules.absolute.length == 2 &&
          HabotGovernanceRules.absolute
              .map((HabotGovernanceRule r) => r.id)
              .toSet()
              .containsAll(<String>{'HOVER_TOOLTIP', 'HOVER_CALLBACK'}) &&
          HabotGovernanceRules.byId('HOVER_TOOLTIP').isAbsolute &&
          !HabotGovernanceRules.byId('RAW_DURATION').isAbsolute,
    );

    gate(
      'GEN-03514-G6',
      'Metric: Governance Repo Packaging -- 1 at floor, optimal and ceiling, '
          'so a set of conditions rather than a rate.',
      'Every packaging condition holds, the catalogue exports without the '
          'patterns so an adopting repository does not have to copy regexes, '
          'and what packaging does NOT yet include is named',
      () =>
          HabotGovernance.isPackaged &&
          HabotGovernance.packagingRate == 1.0 &&
          HabotGovernance.packagingChecks.length == 7 &&
          HabotGovernance.qualitativeOutput == 'Complete' &&
          HabotGovernance.export().length == HabotGovernance.ruleCount &&
          HabotGovernance.export().every(
            (Map<String, Object?> e) =>
                e.containsKey('id') &&
                e.containsKey('family') &&
                e.containsKey('owner') &&
                !e.containsKey('pattern'),
          ) &&
          HabotGovernance.outstanding.length == 2 &&
          HabotGovernance.outstanding.first.contains('consume this catalogue'),
    );

    gate(
      'GEN-03514-G7',
      '"A separate repository is an organisation decision, not a client one."',
      'The scope is recorded: the contents are here and where they live is not '
          'a call this codebase makes, which is a different statement from the '
          'work not being done',
      () =>
          HabotGovernance.separateRepoNote
              .contains('organisation decision') &&
          HabotGovernance.separateRepoNote.contains('second copy of a rule') &&
          HabotGovernance.outstanding.last.contains('where they live') &&
          HabotGovernance.packageName == 'habot_design_governance' &&
          HabotGovernance.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03514',
        atomicStepReferenceId: 'GEN-03514',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Package design system linter configurations into a shared '
            'build governance repo."',
        implementationOrder: 179,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotGovernanceRules / HabotGovernance',
          'Component Properties':
              '${HabotGovernance.ruleCount} rules catalogued '
              '(${HabotGovernanceRules.all.length} poka-yoke, '
              '${HabotA11yRules.all.length} accessibility), all blocking; '
              '${HabotGovernanceRules.exemptions.length} poka-yoke exemptions '
              'each with a written reason; '
              '${HabotGovernanceRules.absolute.length} rules admitting no '
              'exemption; exportable without patterns',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: Step 97 extracted the six accessibility rules into '
              'lib/ and wrote down why -- a rule that only exists inside a '
              'test file cannot be read by anything else. The ten poka-yoke '
              'rules never got the same treatment and have lived inside the '
              'scanner since Step 4. DESIGN DECISION: the catalogue does NOT '
              'carry the patterns. Copying each regex would give the project '
              'two copies, and the copy that fails the build is the one in the '
              'scanner -- so the catalogue would drift and nobody would '
              'notice, because only one of them is executed. SCOPE: a separate '
              'repository is an organisation decision; the contents are here, '
              'where they live is not a call this codebase makes.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Governance Repo Packaging',
            observed:
                'All ${HabotGovernance.packagingChecks.length} packaging '
                'conditions hold: both families declared as data, every rule '
                'naming its owning step and its sanctioned alternative, every '
                'exemption explained and pointing at a declared site, and an '
                'export that carries ${HabotGovernance.ruleCount} rules '
                'without a single regex.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Exemptions carrying a written reason',
            observed:
                '${HabotGovernanceRules.exemptions.length} of '
                '${HabotGovernanceRules.exemptions.length}, none of them '
                'pointing at a file outside the declared token sites and the '
                'four named single implementations. The two absolute rules '
                '(HOVER_TOOLTIP, HOVER_CALLBACK) admit no exemption anywhere.',
            floor: 'all exemptions explained',
            optimal: 'all exemptions explained',
            ceiling: 'all exemptions explained',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/governance_rules.dart',
        ],
      ),
    );
  });
}
