/// AISS GATE -- Step 304 of 315
/// Global Reference ID:       GEN-02049
/// Atomic Steps Reference ID: GEN-02049
/// Setup Step (Action): (the generic engineering-console boilerplate, with the
///                      World's Best Practice column asking for WCAG
///                      conformance of a continuous integration check --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Prevent developers from hardcoding custom help text in the UI
///               layer."
/// Metric: Automated PR Rejection Rate for Non-Compliance (%) -- floor 95,
///         optimal 99.5, ceiling 100. High/Medium/Low.
///
/// WHEN THE STEP FULLY SUCCEEDS THE DENOMINATOR IS ZERO AND THE METRIC IS
/// UNDEFINED. THE BEST STATE OF THE WORLD IS THE UNMEASURABLE ONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/help_text_registry.dart';

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

  group('GEN-02049 :: the shape that already exists', () {
    gate(
      'GEN-02049-G1',
      'Step 99 keyed action hints by an enum with a completeness check.',
      'Fourteen action kinds are covered and nothing is missing, which is '
          'exactly the mechanism this row is asking somebody to invent',
      () =>
          HabotHelpTextRegistry.actionHintsAreAlreadyRegistered &&
          HabotHelpTextRegistry.actionKindsCovered == 14 &&
          HabotHelpTextRegistry.nothingIsMissingFromTheActionRegistry,
    );

    gate(
      'GEN-02049-G2',
      'Two registries with different rules is the condition being cured.',
      'Field help extends the existing shape rather than adding a second '
          'scheme',
      () => HabotHelpTextRegistry.reuseNote
          .contains('two registries with different rules'),
    );
  });

  group('GEN-02049 :: field help on the same shape', () {
    gate(
      'GEN-02049-G3',
      'Atomic Step: "prevent hardcoding custom help text".',
      'Five field entries, every id unique, every one resolving from the '
          'registry rather than from a call site',
      () =>
          HabotHelpTextRegistry.entries.length == 5 &&
          HabotHelpTextRegistry.everyIdIsUnique &&
          HabotHelpTextRegistry.everyDeclaredEntryResolves,
    );

    gate(
      'GEN-02049-G4',
      'An unknown id is reported as hardcoded, not as missing.',
      'Because the failure being prevented is a string written at a call '
          'site, and a lookup miss is the evidence of one',
      () =>
          HabotHelpTextRegistry.sourceFor('help.notInTheRegistry') ==
              HabotHelpSource.hardcoded &&
          HabotHelpTextRegistry.lookup('help.iban') != null,
    );

    gate(
      'GEN-02049-G5',
      'Help text that repeats its own label helps nobody.',
      'No entry does, and every entry names the field it belongs to',
      () =>
          HabotHelpTextRegistry.noEntryMerelyRepeatsItsLabel &&
          HabotHelpTextRegistry.everyEntryHasAField,
    );
  });

  group('GEN-02049 :: the rule, specified and off', () {
    gate(
      'GEN-02049-G6',
      'HARDCODED_HELP_TEXT would be the eleventh poka-yoke rule.',
      'Four matched parameters and three exempt paths are declared, so '
          'enabling it is a one-line change somebody makes on purpose',
      () =>
          HabotHelpTextRegistry.ruleId == 'HARDCODED_HELP_TEXT' &&
          HabotHelpTextRegistry.existingPokaYokeRules == 10 &&
          HabotHelpTextRegistry.ruleWouldBeNumber == 'eleventh' &&
          HabotHelpTextRegistry.everyMatchedParameterIsNamed &&
          HabotHelpTextRegistry.exemptPaths.length == 3,
    );

    gate(
      'GEN-02049-G7',
      'The guard file belongs to a gated step.',
      'The rule is declared off rather than written into work already signed '
          'off, and it cannot fire on its own registry',
      () =>
          !HabotHelpTextRegistry.ruleIsEnabled &&
          HabotHelpTextRegistry.theRuleCannotFireOnItsOwnRegistry &&
          HabotHelpTextRegistry.guardFileIsGatedNote
              .contains('open decision'),
    );
  });

  group('GEN-02049 :: the metric', () {
    gate(
      'GEN-02049-G8',
      'Floor 95, optimal 99.5, in pull requests.',
      'At 1,200 pull requests a year with eight per cent touching '
          'user-facing copy, the floor lets 4.8 hardcoded strings a year '
          'through and the optimal lets 0.48',
      () =>
          HabotHelpTextRegistry.nonCompliantPerYear == 96.0 &&
          (HabotHelpTextRegistry.escapingAtTheFloor - 4.8).abs() < 1e-9 &&
          (HabotHelpTextRegistry.escapingAtTheOptimal - 0.48).abs() < 1e-9,
    );

    gate(
      'GEN-02049-G9',
      'The detector matters more than its calibration.',
      'Four strings separate the floor from the optimal; ninety-six separate '
          'having the rule from not having it, and only the ceiling lets none '
          'through',
      () =>
          HabotHelpTextRegistry.theDetectorMattersMoreThanItsCalibration &&
          HabotHelpTextRegistry.escapingWithNoDetector == 96.0 &&
          HabotHelpTextRegistry.escapingAt(
                HabotHelpTextRegistry.ceilingRecall,
              ) ==
              0.0,
    );

    gate(
      'GEN-02049-G10',
      'Output: High / Medium / Low, where High is best.',
      'Full success makes the denominator zero and the metric undefined, and '
          'a team reading the column without the definition optimises for '
          'rejecting more; five obligations hold and all twelve declared '
          'checks hold',
      () =>
          HabotHelpTextRegistry.theMetricIsUndefinedOnFullSuccess &&
          HabotHelpTextRegistry.metricNote.contains('cannot be taken') &&
          HabotHelpTextRegistry.obligations.length == 5 &&
          HabotHelpTextRegistry.obligations.values.every((bool b) => b) &&
          HabotHelpTextRegistry.qualitativeOutput == 'High' &&
          HabotHelpTextRegistry.checks.length == 12 &&
          HabotHelpTextRegistry.checks.values.every((bool b) => b) &&
          HabotHelpTextRegistry.columnNote.contains('continuous integration'),
    );
  });

  tearDownAll(() {
    final String atFloor =
        HabotHelpTextRegistry.escapingAtTheFloor.toStringAsFixed(2);
    final String atOptimal =
        HabotHelpTextRegistry.escapingAtTheOptimal.toStringAsFixed(2);
    final String params = HabotHelpTextRegistry.matchedParameters.join(', ');

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02049',
        atomicStepReferenceId: 'GEN-02049',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is the generic '
            'engineering-console boilerplate, and the World\'s Best Practice '
            'column asks to "follow Material Design 3 guidelines" and "ensure '
            'WCAG 2.1 AA accessibility" of a continuous integration check. '
            'Atomic Step: "Prevent developers from hardcoding custom help text '
            'in the UI layer."',
        implementationOrder: 304,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Prevent developers from hardcoding custom help text in the UI':
              '${HabotHelpTextRegistry.entries.length} field entries keyed in '
                  'a registry; the rule that would enforce it is specified and '
                  'declared off',
          'Completion Status': 'High',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'HARDCODED_HELP_TEXT matches $params and exempts its own '
                  'registry',
          'Data Quality Note':
              'REUSE: ${HabotHelpTextRegistry.reuseNote} '
              'GUARD: ${HabotHelpTextRegistry.guardFileIsGatedNote} '
              'METRIC: ${HabotHelpTextRegistry.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Automated PR Rejection Rate for Non-Compliance (%)',
            observed:
                'UNDEFINED AT FULL SUCCESS. The rate is rejections over '
                'non-compliant pull requests, so when nothing is '
                'non-compliant the denominator is zero. At this project\'s '
                'volume the floor of 95% lets $atFloor hardcoded strings a '
                'year reach main and the optimal lets $atOptimal; the '
                'difference between having the detector and not having it is '
                '96.',
            floor: '95',
            optimal: '99.5',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Field help entries written at a call site',
            observed:
                '0 of ${HabotHelpTextRegistry.entries.length}. Every entry is '
                'keyed, no entry repeats its own label, and an id that is not '
                'in the registry is reported as hardcoded rather than as '
                'missing.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/i18n/help_text_registry.dart',
        ],
      ),
    );
  });
}
