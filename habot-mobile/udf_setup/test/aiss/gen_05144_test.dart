/// AISS GATE -- Step 230 of 235
/// Global Reference ID:       GEN-05144
/// Atomic Steps Reference ID: GEN-05144
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Design the approach and technical specification for: set up
///               viewport parameters and disable accidental double-tap zoom
///               behaviors on mobile browsers."
/// Metric: Technical Specification Completeness -- Floor "Spec missing
///         acceptance criteria or edge cases", Optimal "Spec complete: inputs,
///         outputs, edge cases & acceptance criteria defined", Ceiling 1.
///         Complete/Partial/Not Complete.
///
/// THIS ROW CLOSES HALF OF OPEN DECISION 2. RCGLA-012 asked for
/// user-scalable=no and was deferred because it fails WCAG 1.4.4. This row asks
/// for something different and achievable: disabling ACCIDENTAL double-tap
/// zoom, which touch-action: manipulation does without touching pinch zoom.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/viewport_policy.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completeness = 0;

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

  group('GEN-05144 :: two different asks', () {
    gate(
      'GEN-05144-G1',
      'Open decision 2: RCGLA-012 substep 2 asked for user-scalable=no and was '
          'deferred because it fails WCAG 2.1 SC 1.4.4 Resize Text.',
      'Both scale locks are declared and neither is emitted, and each names '
          'the criterion it would fail -- so the refusal is a recorded '
          'decision rather than an omission somebody could undo by adding a '
          'word to a meta tag',
      () {
        final List<HabotViewportDirective> refused =
            HabotViewportPolicy.refused;
        return refused.length == 2 &&
            refused.any(
              (HabotViewportDirective d) =>
                  d.declaration == 'user-scalable=no',
            ) &&
            refused.any(
              (HabotViewportDirective d) =>
                  d.declaration == 'maximum-scale=1',
            ) &&
            HabotViewportPolicy.everyRefusalNamesACriterion &&
            refused.every(
              (HabotViewportDirective d) => d.wcagImpact.contains('1.4.4'),
            ) &&
            HabotViewportPolicy.leavesTheZoomSuppressionHalfRefused;
      },
    );

    gate(
      'GEN-05144-G2',
      'Atomic Step: "disable ACCIDENTAL DOUBLE-TAP ZOOM behaviors."',
      'touch-action: manipulation is emitted, which removes the double-tap '
          'gesture and the tap delay that waiting for it creates while leaving '
          'pinch zoom intact -- so the responsiveness the deferred row wanted '
          'is delivered without the conformance failure',
      () =>
          HabotViewportPolicy.closesTheResponsivenessHalfOfDecisionTwo &&
          HabotViewportPolicy.pinchZoomRemains &&
          HabotViewportPolicy.tapDelayRemovedMs == 300 &&
          HabotViewportPolicy.emitted.any(
            (HabotViewportDirective d) =>
                d.declaration == 'touch-action: manipulation',
          ) &&
          HabotViewportPolicy.openDecisionTwoNote
              .contains('stays refused'),
    );

    gate(
      'GEN-05144-G3',
      '"Nothing emitted fails an accessibility criterion."',
      'Every directive this build emits has an empty WCAG impact, and the '
          'assembled meta tag contains no scale lock of either spelling -- '
          'assembled from the directive list rather than written out, so a '
          'refusal cannot be re-added by editing a string',
      () =>
          HabotViewportPolicy.nothingEmittedFailsWcag &&
          HabotViewportPolicy.metaOmitsScaleLocks &&
          HabotViewportPolicy.viewportMeta ==
              'width=device-width, initial-scale=1' &&
          HabotViewportPolicy.emitted.length == 3,
    );

    gate(
      'GEN-05144-G4',
      'A viewport meta tag and touch-action are web platform concepts.',
      'The specification is scoped to the web and PWA targets and names the '
          'two where none of this exists, rather than being quietly '
          'generalised to every build',
      () =>
          HabotViewportPolicy.appliesTo.length == 2 &&
          HabotViewportPolicy.appliesTo.contains('web') &&
          HabotViewportPolicy.doesNotApplyTo.contains('android') &&
          HabotViewportPolicy.doesNotApplyTo.contains('ios') &&
          HabotViewportPolicy.platformBoundaryNote
              .contains('quietly generalised'),
    );
  });

  group('GEN-05144 :: the specification the metric asks for', () {
    gate(
      'GEN-05144-G5',
      'Metric optimal: "Spec complete: inputs, outputs, edge cases & '
          'acceptance criteria defined."',
      'All four sections the metric names are present and non-empty, so the '
          'completeness figure is computed over the sections the row asks for '
          'rather than over a definition of "complete" invented here',
      () =>
          HabotSpecSection.values.length == 4 &&
          HabotSpecSection.values.every(HabotViewportPolicy.sectionIsPresent) &&
          HabotViewportPolicy.specification.length == 4,
    );

    gate(
      'GEN-05144-G6',
      '"Spec missing acceptance criteria or edge cases" is the floor, so the '
          'edge cases are the half that decides the grade.',
      'Four edge cases are recorded, including the browser that ignores '
          'touch-action, the user already at 200% zoom, the subtree that needs '
          'its own double-tap, and the two platforms where none of this exists',
      () {
        final List<String> edges =
            HabotViewportPolicy.specification[HabotSpecSection.edgeCases]!;
        return edges.length == 4 &&
            edges.any((String e) => e.contains('ignores touch-action')) &&
            edges.any((String e) => e.contains('200%')) &&
            edges.any((String e) => e.contains('android and ios')) &&
            HabotViewportPolicy
                .specification[HabotSpecSection.acceptanceCriteria]!
                .length ==
                4;
      },
    );

    gate(
      'GEN-05144-G7',
      'Metric: Technical Specification Completeness -- ceiling 1. '
          'Complete/Partial/Not Complete.',
      'Completeness is 1.0 and the step reports Complete, with all nine checks '
          'holding -- including the two that are about open decision 2 rather '
          'than about this row',
      () {
        completeness = HabotViewportPolicy.specCompleteness;
        return completeness == 1.0 &&
            HabotViewportPolicy.qualitativeOutput == 'Complete' &&
            HabotViewportPolicy.checks.length == 9 &&
            HabotViewportPolicy.checks.values.every((bool b) => b) &&
            HabotViewportPolicy.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    final int edgeCaseCount = HabotViewportPolicy
        .specification[HabotSpecSection.edgeCases]!.length;
    final int acceptanceCount = HabotViewportPolicy
        .specification[HabotSpecSection.acceptanceCriteria]!.length;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05144',
        atomicStepReferenceId: 'GEN-05144',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Design the approach and technical specification for: set '
            'up viewport parameters and disable accidental double-tap zoom '
            'behaviors on mobile browsers."',
        implementationOrder: 230,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotViewportPolicy',
          'Component Properties':
              '${HabotViewportPolicy.directives.length} declared directives, '
              '${HabotViewportPolicy.emitted.length} emitted and '
              '${HabotViewportPolicy.refused.length} refused with the '
              'criterion each would fail; meta assembled from the directive '
              'list rather than written out; specification complete across '
              '${HabotSpecSection.values.length} sections; scoped to '
              '${HabotViewportPolicy.appliesTo.join(" and ")}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'THIS ROW CLOSES HALF OF OPEN DECISION 2. RCGLA-012 substep 2 '
              'asked for user-scalable=no and was deferred, because '
              'suppressing zoom fails WCAG 2.1 SC 1.4.4 Resize Text and modern '
              'mobile browsers ignore it anyway -- a conformance failure that '
              'does not even take effect. This row asks for something '
              'different and achievable: disabling ACCIDENTAL double-tap zoom, '
              'which touch-action: manipulation does. It removes the '
              'double-tap gesture and the ~300ms tap delay that waiting for it '
              'creates, and leaves pinch zoom entirely intact. So the '
              'responsiveness the earlier row wanted is delivered without the '
              'violation, and the zoom suppression it asked for stays refused. '
              'Both scale locks -- user-scalable=no and maximum-scale=1, which '
              'is the same failure in a different spelling -- are declared, '
              'refused, and carry the criterion they would fail. The meta tag '
              'is ASSEMBLED from the directive list rather than written out, '
              'so a refusal cannot be re-added by editing a string. BOUNDARY: '
              'a viewport meta and touch-action are web platform concepts; the '
              'Flutter android and ios builds have neither, and that is an '
              'edge case in the specification rather than a silent '
              'generalisation.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Technical Specification Completeness',
            observed:
                '${completeness.toStringAsFixed(2)} -- all '
                '${HabotSpecSection.values.length} sections the metric names '
                'are present: inputs, outputs, $edgeCaseCount edge cases and '
                '$acceptanceCount acceptance criteria.',
            floor: 'Spec missing acceptance criteria or edge cases',
            optimal: 'Spec complete: inputs, outputs, edge cases & acceptance '
                'criteria defined',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Emitted directives failing an accessibility criterion',
            observed:
                '0 of ${HabotViewportPolicy.emitted.length}. The two that '
                'would -- user-scalable=no and maximum-scale=1 -- are refused '
                'and each names WCAG 2.1 SC 1.4.4. Pinch zoom survives, so '
                'text can still be enlarged to 200%.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/viewport_policy.dart',
        ],
      ),
    );
  });
}
