/// AISS GATE -- Step 488 of 1,314
/// Global Reference ID:       GEN-05452
/// Atomic Steps Reference ID: GEN-05452
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build and configure: create an automated performance alert
///               subroutine flagging UI components that breach target latency
///               limits"
/// Metric: UI Rendering Performance & Contrast Compliance -- floor "FCP <= 1.8s
///         / contrast 3:1", optimal "FCP <= 1.2s / contrast 4.5:1", ceiling
///         "FCP <= 0.8s". Best Qualitative Output: "Pass/Fail". WCAG 2.1 AA &
///         Google Core Web Vitals. Assigned to **UDF**.
///
/// PAINT TIME AND COLOUR CONTRAST IN ONE CELL, JOINED BY AN OBLIQUE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/alerts/latency_alert.dart';

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

  group('GEN-05452 :: an oblique across two dimensions', () {
    gate(
      'GEN-05452-G1',
      'The floor joins two dimensions with an oblique.',
      'First contentful paint and colour contrast',
      () => HabotLatencyAlert.theFloorJoinsTwoDimensions,
    );

    gate(
      'GEN-05452-G2',
      'The fourth oblique, and the first across two dimensions.',
      'After Steps 430, 446 and 461, which joined readings of one thing',
      () =>
          HabotLatencyAlert.theFourthOblique &&
          HabotLatencyAlert.theFirstAcrossTwoDimensions,
    );

    gate(
      'GEN-05452-G3',
      'And the ceiling drops the contrast half.',
      'At the top of its own band the row stops caring whether anybody can '
      'read',
      () =>
          HabotLatencyAlert.theCeilingDropsContrast &&
          HabotLatencyAlert.obliqueNote
              .contains('drops the ' 'contrast half entirely'),
    );

  });

  group('GEN-05452 :: a requirement turned into an aspiration', () {
    gate(
      'GEN-05452-G4',
      'The 3:1 floor is below the requirement for body text.',
      'WCAG 2.1 AA asks 4.5:1 for body text',
      () => HabotLatencyAlert.theFloorIsBelowTheRequirementForBodyText,
    );

    gate(
      'GEN-05452-G5',
      'So the band turns a requirement into an aspiration.',
      'By putting the requirement in the optimal',
      () =>
          HabotLatencyAlert.theBandTurnsARequirementIntoAnAspiration &&
          HabotLatencyAlert.contrastNote
              .contains('only where the standard allows it'),
    );

    gate(
      'GEN-05452-G6',
      'Body text at 4.5 and large text at 3.',
      'Which is what the standard the row cites actually says',
      () =>
          HabotLatencyAlert.bodyTextIsHeldAtFourPointFive &&
          HabotLatencyAlert.largeTextIsJudgedAtThree,
    );

  });

  group('GEN-05452 :: both measured, separately', () {
    gate(
      'GEN-05452-G7',
      'Three components measured, one paint breach.',
      'The visit list at 2.4 seconds against 1.8',
      () =>
          HabotLatencyAlert.measured.length == 3 &&
          HabotLatencyAlert.onePaintBreach,
    );

    gate(
      'GEN-05452-G8',
      'And no contrast breach.',
      'Because the two are counted apart',
      () => HabotLatencyAlert.noContrastBreach,
    );

    gate(
      'GEN-05452-G9',
      'The flag names the component, the device and the percentile.',
      '"The screen is slow" is not actionable',
      () =>
          HabotLatencyAlert.theFlagNamesTheComponent &&
          HabotLatencyAlert.theFlagNamesTheDeviceAndPercentile &&
          HabotLatencyAlert.keyedOnTheComponent,
    );

  });

  group('GEN-05452 :: the result', () {
    gate(
      'GEN-05452-G10',
      'Five obligations met, and the paint breach reports Fail.',
      'The subroutine works; the row reports what it found',
      () =>
          HabotLatencyAlert.obligations.length == 5 &&
          HabotLatencyAlert.obligations.values.every((bool b) => b) &&
          HabotLatencyAlert.flagNote
              .contains('one slow screen is one alert') &&
          HabotLatencyAlert.qualitativeOutput == 'Fail',
    );
  });

  tearDownAll(() {
    final int breaches = HabotLatencyAlert.paintFlags.length;
    final int measured = HabotLatencyAlert.measured.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05452',
        atomicStepReferenceId: 'GEN-05452',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor and optimal join a paint budget '
            'and a contrast ratio with an oblique, the fourth oblique in the '
            'track and the first across two genuinely different dimensions, '
            'and its ceiling drops the contrast half entirely; its 3:1 floor '
            'also turns a WCAG body-text requirement into an aspiration, so '
            'text is held at 4.5:1 and 3:1 applied only to large text; both '
            'dimensions are measured separately, the visit list breaches the '
            'paint budget at 2.4 seconds and no component breaches contrast, '
            'and every flag names the component, the device class and the '
            'percentile. Atomic Step: "Build and configure: create an '
            'automated performance alert subroutine flagging UI components '
            'that breach target latency limits"',
        implementationOrder: 488,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build and configure: create an automated performance alert '
          'subroutine flagging':
              '$measured components measured on the oldest declared device '
              'with $breaches paint breach and no contrast breach, each flag '
              'naming the component, the device class and the percentile',
          'Completion Status': 'Fail',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Rendering Performance & Contrast Compliance',
            observed:
                'FAIL, ON A ROW THAT BUILT THE THING THAT FOUND IT. The band '
                'joins a paint budget and a contrast ratio with an oblique -- '
                'the fourth oblique in the track and the first across two '
                'genuinely different dimensions -- and its ceiling drops the '
                'contrast half entirely. Both are measured separately across '
                '$measured components: $breaches paint breach at 2.4 seconds '
                'against 1.8, and no contrast breach. The subroutine works and '
                'the row reports what it found.',
            floor: 'FCP <= 1.8s / contrast 3:1',
            optimal: 'FCP <= 1.2s / contrast 4.5:1',
            ceiling: 'FCP <= 0.8s',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Body text held below 4.5:1',
            observed:
                '0 of $measured. WCAG 2.1 AA requires 4.5:1 for body text and '
                'allows 3:1 for large text and non-text components, so a floor '
                'of 3:1 turns a requirement into an aspiration. Text is held '
                'at 4.5:1 and 3:1 applied only where the standard allows it, '
                'and every flag names the component, the device class and the '
                'percentile rather than saying that the screen is slow.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/alerts/latency_alert.dart',
        ],
      ),
    );
  });
}
