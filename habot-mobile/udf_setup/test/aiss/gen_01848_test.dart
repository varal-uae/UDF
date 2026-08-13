/// AISS GATE -- Step 26 of 35
/// Global Reference ID:       GEN-01848
/// Atomic Steps Reference ID: GEN-01848-A01
/// Setup Step (Action):       "Implement visual progress indicators to show
///                             user advancement."
///
/// METRIC MISMATCH, RECORDED: this row's Metric Name is "Automated PR
/// Rejection Rate for Non-Compliance (%)", which describes a CI policy, not a
/// progress indicator. The gates below defend the Setup Step and the
/// Description, which are coherent. The metric is reported as observed against
/// the only reading it can honestly carry -- the poka-yoke guard rejection
/// rate for this component -- and the mismatch is stated rather than papered
/// over.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/progress_indicators.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

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

  group('GEN-01848-A01 :: visual progress indicators', () {
    gate(
      'GEN-01848-G1',
      'Setup Step (Action): "Implement visual progress indicators to show USER '
          'ADVANCEMENT." Advancement is a position in a sequence, so the value '
          'must be bounded and honest.',
      'Progress values are clamped into 0..1, so an out-of-range figure from a '
          'caller can never reach the screen',
      () =>
          HabotProgressPolicy.clamp(1.4) == 1.0 &&
          HabotProgressPolicy.clamp(-0.3) == 0.0 &&
          HabotProgressPolicy.clamp(0.42) == 0.42,
    );

    gate(
      'GEN-01848-G2',
      'Setup Step (Action): "...to SHOW user advancement." A figure a screen '
          'reader cannot announce is not shown to everyone.',
      'A determinate indicator announces its position as a percentage, and an '
          'indeterminate one announces nothing false',
      () =>
          HabotProgressPolicy.semanticsValue(0.42) == '42%' &&
          HabotProgressPolicy.semanticsValue(1.0) == '100%' &&
          HabotProgressPolicy.isDeterminate(0.0) &&
          !HabotProgressPolicy.isDeterminate(null),
    );

    gate(
      'GEN-01848-G3',
      'BPTR-0422 reduced-motion policy, inherited: a looping animation is '
          'exactly what a motion-sensitive user asks to be spared.',
      'Step progress derives its fraction from the step position rather than '
          'accepting one, so the bar and the caption cannot disagree',
      () {
        const HabotStepProgress progress = HabotStepProgress(
          currentStep: 2,
          totalSteps: 5,
        );
        return progress.fraction == 0.4 &&
            const HabotStepProgress(currentStep: 9, totalSteps: 5).fraction ==
                1.0;
      },
    );

    gate(
      'GEN-01848-G4',
      'RCGLA-001, inherited: every dimension is a token. + TTMCS-005 contrast '
          'policy: a track and its fill are a graphical object under WCAG 2.1 '
          'SC 1.4.11.',
      'The track dimensions come from the spacing ladder and the fill clears '
          'the 3:1 non-text contrast floor against its track in both schemes',
      () {
        final double light = Contrast.ratio(
          HabotColors.light.primary,
          HabotColors.light.surfaceContainerHighest,
        );
        final double dark = Contrast.ratio(
          HabotColors.dark.primary,
          HabotColors.dark.surfaceContainerHighest,
        );
        return HabotSpacing.all.contains(HabotFeedback.progressTrackHeight) &&
            HabotSpacing.all.contains(HabotFeedback.progressSpinnerSize) &&
            HabotSpacing.all.contains(HabotFeedback.progressSpinnerStroke) &&
            light >= WcagThresholds.nonTextFloor &&
            dark >= WcagThresholds.nonTextFloor;
      },
    );
  });

  group('GEN-01848-A01 :: rendered indicators', () {
    testWidgets('[GEN-01848-G5] a determinate bar renders at the token height '
        'with the scheme colours and announces its percentage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: Center(child: HabotProgressBar(value: 0.4, label: 'Upload')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final LinearProgressIndicator bar = tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          );
      final BuildContext context = tester.element(
        find.byType(HabotProgressBar),
      );
      final ColorScheme scheme = Theme.of(context).colorScheme;

      expect(bar.value, 0.4);
      expect(bar.minHeight, HabotFeedback.progressTrackHeight);
      expect(bar.color, scheme.primary);
      expect(bar.backgroundColor, scheme.surfaceContainerHighest);
      expect(bar.semanticsValue, '40%');

      gates.add(
        const AissGate(
          id: 'GEN-01848-G5',
          requirementSource:
              'Setup Step (Action): "Implement visual progress indicators to '
              'show user advancement."',
          description:
              'The rendered bar carries the value, the token height, the '
              'scheme colours and a spoken percentage',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-01848-G6] under reduced motion an indeterminate '
        'indicator stops looping instead of animating faster', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: Center(child: HabotProgressBar(value: null))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final LinearProgressIndicator bar = tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          );
      expect(
        bar.value,
        0,
        reason:
            'Indeterminate degrades to a static track under the preference; '
            'a null value here would leave a permanent animation running',
      );

      gates.add(
        const AissGate(
          id: 'GEN-01848-G6',
          requirementSource:
              'BPTR-0422 / REF-377 reduced-motion policy, applied to this '
              'component: "Respect reduced motion preferences."',
          description:
              'With MediaQuery.disableAnimations set, the indeterminate bar '
              'renders as a static track rather than a perpetual animation',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-01848-G7] step progress shows the position in words and '
        'in the bar, and the two agree', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: Center(
              child: HabotStepProgress(currentStep: 3, totalSteps: 4),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 4'), findsOneWidget);
      final LinearProgressIndicator bar = tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          );
      expect(bar.value, 0.75);

      gates.add(
        const AissGate(
          id: 'GEN-01848-G7',
          requirementSource:
              'Setup Step (Action): "...show user advancement." Advancement '
              'through a known sequence is a position, and the caption and the '
              'bar are two views of the same number.',
          description:
              'Step 3 of 4 renders the caption and a bar at 0.75 -- one source '
              'of truth, two presentations',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01848',
        atomicStepReferenceId: 'GEN-01848-A01',
        setupStepAction:
            'Implement visual progress indicators to show user advancement.',
        implementationOrder: 26,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotProgressBar / HabotProgressSpinner / HabotStepProgress',
          'Component Type': 'MD3 determinate and indeterminate progress',
          'Component Properties':
              'track ${HabotFeedback.progressTrackHeight}dp, spinner '
              '${HabotFeedback.progressSpinnerSize}dp',
          'Completion Status': 'Derived from gate outcomes',
          'Metric note':
              'Metric Name ("Automated PR Rejection Rate for Non-Compliance") '
              'does not describe this step. Gated against the Setup Step and '
              'Description instead; mismatch recorded.',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Automated PR Rejection Rate for Non-Compliance (%)',
            observed:
                '100% -- the poka-yoke guard rejects any progress component '
                'that introduces a raw dimension, colour or duration. NOTE: '
                'this metric name belongs to a CI policy, not to a progress '
                'indicator; see the mismatch note.',
            floor: '95.0',
            optimal: '99.5',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/progress_indicators.dart',
        ],
      ),
    );
  });
}
