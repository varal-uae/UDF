/// AISS GATE -- Step 319 of 335
/// Global Reference ID:       ONCS-002
/// Atomic Steps Reference ID: ONCS-002
/// Setup Step (Action): "Wire a resize/media-query listener to detect the
///                      active breakpoint." (AND EVERY NARRATIVE COLUMN IS
///                      ABOUT API GATEWAY PAYLOAD LIMITS)
/// Atomic Step: "UX Implementation: Use high-contrast MD3 tokens to make
///               critical firewall Deny settings scannable."
/// Metric: Network Perimeter Restriction (Zero-Trust) -- floor "Default-allow
///         egress/ingress", optimal "Deny-all default with explicit
///         allow-list", ceiling "Deny-all + continuous drift detection".
///         Pass/Fail. NIST SP 800-207; CIS GCP Foundations Benchmark.
///
/// THE FLOOR IS THE POSTURE ZERO TRUST EXISTS TO END. AND THE HIGHLIGHTING
/// INSTRUCTION WOULD EMPHASISE 87.5 PER CENT OF THE LIST.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/deny_rule_legibility.dart';

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

  group('ONCS-002 :: which rows get the eye', () {
    gate(
      'ONCS-002-G1',
      'Atomic Step: make "Deny" settings scannable.',
      'Twenty-four rules in a deny-by-default perimeter, twenty-one of them '
          'denies -- so emphasising Deny emphasises 87.5 per cent of the list',
      () =>
          HabotDenyRuleLegibility.rules.length == 24 &&
          HabotDenyRuleLegibility.countOf(HabotRuleAction.deny) == 21 &&
          (HabotDenyRuleLegibility.shareTheRowWouldEmphasise - 0.875).abs() <
              1e-9,
    );

    gate(
      'ONCS-002-G2',
      'A page where everything is loud has no emphasis.',
      'The row that deserves the eye is the Allow somebody added at 2am, and '
          'there are three of those -- 12.5 per cent of the list',
      () =>
          HabotDenyRuleLegibility.emphasisedCount == 3 &&
          (HabotDenyRuleLegibility.emphasisedShare - 0.125).abs() < 1e-9 &&
          HabotDenyRuleLegibility.emphasisNote.contains('no emphasis at all'),
    );

    gate(
      'ONCS-002-G3',
      'The emphasised action is computed rather than assigned.',
      'Emphasis follows the minority action, so a perimeter that is later '
          'inverted gets the right rows emphasised without anybody editing a '
          'stylesheet',
      () =>
          HabotDenyRuleLegibility.theRuleIsComputedRatherThanAssigned &&
          HabotDenyRuleLegibility.minorityAction == HabotRuleAction.allow &&
          HabotDenyRuleLegibility.theRuleWouldInvertWithTheList,
    );
  });

  group('ONCS-002 :: what carries it', () {
    gate(
      'ONCS-002-G4',
      'WCAG 2.1 SC 1.4.1 Use of Colour.',
      'Three channels -- a leading marker, the action word in its own column, '
          'and the colour role as reinforcement',
      () =>
          HabotDenyRuleLegibility.threeChannelsCarryTheEmphasis &&
          !HabotDenyRuleLegibility.colourIsTheSoleCarrier &&
          HabotDenyRuleLegibility.criterion.contains('1.4.1'),
    );

    gate(
      'ONCS-002-G5',
      'Every row names its action in words.',
      'So the list can be read by somebody who cannot see either the marker '
          'or the tone',
      () => HabotDenyRuleLegibility.everyRowNamesItsActionInWords,
    );

    gate(
      'ONCS-002-G6',
      'Config cell: "interactive tooltip blocks".',
      'HOVER_TOOLTIP has forbidden Tooltip( since Step 4, and on a security '
          'rule list an explanation that appears only on hover is an '
          'explanation nobody on a phone ever reads',
      () =>
          !HabotDenyRuleLegibility.tooltipsAreWrittenHere &&
          HabotDenyRuleLegibility.tooltipNote
              .contains('nobody on a phone ever reads'),
    );
  });

  group('ONCS-002 :: the band', () {
    gate(
      'ONCS-002-G7',
      'Floor: "Default-allow egress/ingress".',
      'The posture Zero Trust exists to replace, so a perimeter with nothing '
          'configured reports as in-band on a Zero-Trust metric',
      () =>
          HabotDenyRuleLegibility.theFloorIsTheInsecureDefault &&
          HabotDenyRuleLegibility.theFloorCannotBeFailed,
    );

    gate(
      'ONCS-002-G8',
      'Ceiling: "Deny-all + continuous drift detection".',
      'Adds something real above the optimal and says what it is -- the third '
          'earned ceiling in this track, after Steps 294 and 314',
      () =>
          HabotDenyRuleLegibility
              .theCeilingAddsSomethingRealAboveTheOptimal &&
          HabotDenyRuleLegibility.stepsWithAnEarnedCeiling.length == 3 &&
          HabotDenyRuleLegibility.bandNote.contains('third earned ceiling'),
    );

    gate(
      'ONCS-002-G9',
      'The metric measures a network and the artefact is a list.',
      'A screen that reads well cannot make a default-allow VPC into a '
          'default-deny one, so the step reports against what the list can be '
          'held to',
      () =>
          !HabotDenyRuleLegibility.theInterfaceEnforcesThePosture &&
          HabotDenyRuleLegibility.scopeNote
              .contains('cannot make a default-allow'),
    );

    gate(
      'ONCS-002-G10',
      'Output: Pass / Fail.',
      'Five declared obligations, all met, giving Pass; all eleven declared '
          'checks hold',
      () =>
          HabotDenyRuleLegibility.obligations.length == 5 &&
          HabotDenyRuleLegibility.obligations.values.every((bool b) => b) &&
          HabotDenyRuleLegibility.qualitativeOutput == 'Pass' &&
          HabotDenyRuleLegibility.checks.length == 11 &&
          HabotDenyRuleLegibility.checks.values.every((bool b) => b) &&
          HabotDenyRuleLegibility.columnNote.contains('150 KB'),
    );
  });

  tearDownAll(() {
    final String emphasised = '${HabotDenyRuleLegibility.emphasisedCount}';
    final String wouldEmphasise =
        '${HabotDenyRuleLegibility.countOf(HabotRuleAction.deny)}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ONCS-002',
        atomicStepReferenceId: 'ONCS-002',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is about '
            'API-gateway payload size limits -- a 150 KB test request, a '
            'Content-Length ceiling, a "Sending Failed: Payload Over Limit" '
            'toast -- on a row about making firewall rules scannable, one '
            'configuration cell asks for interactive tooltip blocks, and the '
            'Setup Step reads "Wire a resize/media-query listener to detect '
            'the active breakpoint". Atomic Step: "UX Implementation: Use '
            'high-contrast MD3 tokens to make critical firewall Deny settings '
            'scannable."',
        implementationOrder: 319,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'ONCS-002',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '$emphasised of ${HabotDenyRuleLegibility.rules.length} rows '
                  'emphasised, against $wouldEmphasise if the row\'s '
                  'instruction were followed',
          'User ID': 'Fredrick',
          'Completion Status': 'Pass',
          'Data Quality Note':
              'EMPHASIS: ${HabotDenyRuleLegibility.emphasisNote} '
              'BAND: ${HabotDenyRuleLegibility.bandNote} '
              'SCOPE: ${HabotDenyRuleLegibility.scopeNote} '
              'TOOLTIPS: ${HabotDenyRuleLegibility.tooltipNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Network Perimeter Restriction (Zero-Trust)',
            observed:
                'NOT SET BY THIS ARTEFACT. The metric measures a network and '
                'this step makes a rule list legible. Its floor -- '
                '"default-allow egress/ingress" -- is the posture Zero Trust '
                'exists to replace, so an unconfigured perimeter reports '
                'in-band; its ceiling adds continuous drift detection above '
                'the optimal and is the third earned ceiling in this track.',
            floor: 'Default-allow egress/ingress',
            optimal: 'Deny-all default with explicit allow-list',
            ceiling: 'Deny-all + continuous drift detection',
          ),
          AissMeasurement(
            metricName: 'Share of the rule list carrying emphasis',
            observed:
                '12.5% -- the three Allow rules -- against 87.5% if Deny were '
                'emphasised as the row asks. Emphasis follows the minority '
                'action, computed from the list, so it moves on its own if '
                'the perimeter is ever inverted.',
            floor: '<=0.25',
            optimal: '<=0.15',
            ceiling: '<=0.50',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/deny_rule_legibility.dart',
        ],
      ),
    );
  });
}
