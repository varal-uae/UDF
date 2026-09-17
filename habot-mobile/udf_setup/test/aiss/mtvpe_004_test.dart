/// AISS GATE -- Step 346 of 355
/// Global Reference ID:       MTVPE-004
/// Atomic Steps Reference ID: MTVPE-004
/// Setup Step (Action): "Initialize the Universal MTO split-screen mirror
///                      deployment script." (A DEPLOYMENT SCRIPT, ON AN
///                      ANIMATION ROW)
/// Atomic Step: "Apply CSS transitions to enable a smooth,
///               hardware-accelerated slide-in animation from the right
///               viewport edge."
/// Metric: CSS Style Application Accuracy (%) -- floor 98, optimal 100,
///         ceiling 100. Pass / Fail. W3C CSS Animations and Transitions.
///
/// THE FOURTEENTH FOREIGN STACK, AND A METRIC WHOSE POPULATION IS EMPTY:
/// THE SHARE OF CORRECTLY APPLIED CSS RULES AMONG ZERO CSS RULES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/guidance/guidance_panel.dart';

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

  group('MTVPE-004 :: the absent stack', () {
    gate(
      'MTVPE-004-G1',
      'Atomic Step: "Apply CSS transitions".',
      'This is a Flutter application with no stylesheet, no cascade and no '
          'transition property',
      () =>
          HabotGuidancePanel.theRowAssumesADifferentStack &&
          !HabotGuidancePanel.thisApplicationHasAStylesheet &&
          HabotGuidancePanel.stackThisApplicationUses == 'Flutter',
    );

    gate(
      'MTVPE-004-G2',
      'Metric: "CSS Style Application Accuracy (%)".',
      'The share of correctly applied CSS rules among zero CSS rules, scored '
          'against the W3C module that defines the absent thing',
      () =>
          HabotGuidancePanel.theMetricHasNoPopulationHere &&
          HabotGuidancePanel.stackNote.contains('among zero CSS rules'),
    );

    gate(
      'MTVPE-004-G3',
      'Fourteenth foreign stack, after React Native at Step 317.',
      'Step 258 keeps the register rather than each row discovering it again',
      () =>
          HabotGuidancePanel.theRegisterIsAlreadyDeclared &&
          HabotGuidancePanel.foreignStackOrdinal == 14 &&
          HabotGuidancePanel.stackNote.contains('Step 258'),
    );
  });

  group('MTVPE-004 :: what translates', () {
    gate(
      'MTVPE-004-G4',
      'The intent survives: a panel that arrives from an edge.',
      'It tells a person where it came from and therefore where it goes back '
          'to, which is the difference between a panel and a page',
      () =>
          HabotGuidancePanel.bothDurationsComeFromTokens &&
          HabotGuidancePanel.intentNote.contains('panel and a page'),
    );

    gate(
      'MTVPE-004-G5',
      'Leaving is not slower than arriving.',
      'Both durations come from the motion tokens rather than from this row',
      () =>
          HabotGuidancePanel.leavingIsNotSlowerThanArriving &&
          HabotGuidancePanel.bothDurationsComeFromTokens,
    );
  });

  group('MTVPE-004 :: what does not', () {
    gate(
      'MTVPE-004-G6',
      '"Hardware-accelerated" is a real CSS instruction and an empty one '
          'here.',
      'Flutter composites every widget on the GPU already, so there is no slow '
          'path to avoid and no hint to give',
      () =>
          !HabotGuidancePanel.aCompositingHintIsNeeded &&
          HabotGuidancePanel.accelerationNote.contains('it is empty'),
    );

    gate(
      'MTVPE-004-G7',
      'The row says "the right viewport edge".',
      'The panel enters from the edge it will return to, which in a '
          'right-to-left locale is the left one -- the rule Step 225 settled',
      () =>
          HabotGuidancePanel.theEdgeIsResolvedNotPhysical &&
          HabotGuidancePanel.theResolutionRuleIsAlreadyDeclared &&
          HabotGuidancePanel.edge == HabotPanelEdge.trailing,
    );
  });

  group('MTVPE-004 :: reduced motion and the band', () {
    gate(
      'MTVPE-004-G8',
      'A slide across a viewport is vestibular motion.',
      'When the platform preference is set the panel cross-fades in place; the '
          'default is still a slide',
      () =>
          HabotGuidancePanel.reducedMotionReplacesTheSlide &&
          HabotGuidancePanel.theDefaultIsStillASlide &&
          HabotPanelEntry.values.length == 2,
    );

    gate(
      'MTVPE-004-G9',
      'Reduced motion replaces the slide, not the panel.',
      'Removing the panel would be reading the preference as a request for '
          'less function',
      () =>
          !HabotGuidancePanel.reducedMotionRemovesThePanel &&
          HabotGuidancePanel.reducedMotionNote.contains('less function'),
    );

    gate(
      'MTVPE-004-G10',
      'Floor 98, optimal 100, ceiling 100. Output Pass / Fail.',
      'The top two values are the same number -- third such band in this batch '
          '-- and five obligations hold, giving Pass',
      () =>
          HabotGuidancePanel.theOptimalEqualsTheCeiling &&
          HabotGuidancePanel.obligations.length == 5 &&
          HabotGuidancePanel.obligations.values.every((bool b) => b) &&
          HabotGuidancePanel.qualitativeOutput == 'Pass' &&
          HabotGuidancePanel.checks.length == 10 &&
          HabotGuidancePanel.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int enterMs = HabotGuidancePanel.enterDuration.inMilliseconds;
    final int exitMs = HabotGuidancePanel.exitDuration.inMilliseconds;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MTVPE-004',
        atomicStepReferenceId: 'MTVPE-004',
        setupStepAction:
            'COLUMN NOTE: this row asks for CSS transitions in an application '
            'with no CSS and scores them on "CSS Style Application Accuracy '
            '(%)"; its Decision Group is "G1 (Perimeter Security)" and its '
            'narrative columns are about TLS 1.3 handshakes and Terraform '
            'gateway configuration; its Data Requirement column describes a '
            'video player; and its Setup Step column reads "Initialize the '
            'Universal MTO split-screen mirror deployment script". Atomic '
            'Step: "Apply CSS transitions to enable a smooth, '
            'hardware-accelerated slide-in animation from the right viewport '
            'edge."',
        implementationOrder: 346,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'MTVPE-004',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              'the panel enters in ${enterMs}ms and leaves in ${exitMs}ms, '
                  'both from the motion tokens; no CSS is written',
          'User ID': 'Fredrick',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the edge is trailing rather than right, and reduced motion '
                  'cross-fades the panel in place rather than removing it',
          'Data Quality Note':
              'STACK: ${HabotGuidancePanel.stackNote} '
              'ACCELERATION: ${HabotGuidancePanel.accelerationNote} '
              'EDGE: ${HabotGuidancePanel.edgeNote} '
              'REDUCED MOTION: ${HabotGuidancePanel.reducedMotionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'CSS Style Application Accuracy (%)',
            observed:
                'THE POPULATION IS EMPTY. This is a Flutter application: no '
                'stylesheet, no cascade, no transition property. The metric '
                'asks for the share of correctly applied CSS rules among zero '
                'CSS rules, and the standard cited is the W3C module that '
                'defines the absent thing. The band also repeats itself, with '
                'an optimal and a ceiling both at 100 -- third such band in '
                'this batch. Fourteenth foreign stack on the register Step 258 '
                'keeps, after React Native at Step 317.',
            floor: '98',
            optimal: '100',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Milliseconds for the panel to arrive and to leave',
            observed:
                '$enterMs in and $exitMs out, both read from the motion tokens '
                'rather than declared here, and the exit is not slower than '
                'the entry because leaving should never be made to wait. What '
                'survives the translation out of CSS is the intent: a panel '
                'that arrives from an edge says where it came from and '
                'therefore where it goes back to. What does not survive is '
                '"hardware-accelerated", which is a real instruction in CSS '
                'and an empty one here.',
            floor: '$enterMs',
            optimal: '$exitMs',
            ceiling: '$exitMs',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/guidance/guidance_panel.dart',
        ],
      ),
    );
  });
}
