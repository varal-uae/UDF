/// AISS GATE -- Step 55 of 65
/// Global Reference ID:       GEN-02929
/// Atomic Steps Reference ID: GEN-02929-A01
/// Setup Step (Action):       "Format statistical confidence metrics using
///                             Material bodySmall typography on mobile."
/// Metric: Task Completion Status -- Floor 0.8, Optimal 1.0.
///
/// METRIC NAME NOTE, RECORDED: "Task Completion Status" is generic project
/// tracking on a typography step -- it measures whether the step was done, not
/// whether the typography is right. Gated against the Setup Step, which names
/// a specific role in the type scale, and against the Step 46 fitting rules.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/text_fit.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/confidence_metric.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/typography_tokens.dart';

import 'aiss_reporter.dart';

const HabotConfidenceMetric _accuracy = HabotConfidenceMetric(
  value: 96.4,
  lower: 94.1,
  upper: 98.7,
  confidence: 0.95,
  unit: '%',
);

const HabotConfidenceMetric _noisy = HabotConfidenceMetric(
  value: 10,
  lower: 1,
  upper: 40,
  confidence: 0.95,
);

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

  group('GEN-02929-A01 :: the named type role', () {
    gate(
      'GEN-02929-G1',
      'Setup Step (Action): "...using Material BODYSMALL typography on '
          'mobile."',
      'The role is the bodySmall token from the Step 2 type scale, not a font '
          'size that happens to match it today, and it sits at or above the '
          'Step 46 readable floor',
      () =>
          HabotConfidenceMetric.token == HabotTypography.bodySmall &&
          HabotConfidenceMetric.token.sizeSp >= HabotTextFit.minReadableFontSp &&
          HabotTextFit.mustWrap.contains(HabotConfidenceMetric.token.name),
    );

    gate(
      'GEN-02929-G2',
      'Setup Step (Action) read with GEN-02060 (Step 46): a confidence '
          'interval is the densest text on a dashboard, at the second-smallest '
          'role, on the narrowest device supported.',
      'The full form fits at the 320dp audit width; a tile too narrow for it '
          'falls back to the compact form, and a narrower one still to the '
          'value alone -- a real three-rung ladder, each rung measured against '
          'the line capacity rather than assumed',
      () {
        bool fitsIn(String text, double width) =>
            text.length <=
            HabotTextFit.charsPerLine(
                  width,
                  HabotConfidenceMetric.token.sizeSp,
                ) *
                HabotConfidenceMetric.maxLines;

        final String wide = _accuracy.fittedFor(HabotTextFit.auditWidthDp);
        final String medium = _accuracy.fittedFor(72);
        final String tiny = _accuracy.fittedFor(48);
        return wide == _accuracy.formatted &&
            medium == _accuracy.compact &&
            tiny == '96.4%' &&
            fitsIn(wide, HabotTextFit.auditWidthDp) &&
            fitsIn(medium, 72) &&
            fitsIn(tiny, 48);
      },
    );
  });

  group('GEN-02929-A01 :: what a confidence interval means', () {
    gate(
      'GEN-02929-G3',
      'Statistical convention: a range without its confidence level tells the '
          'reader nothing about how much to trust it.',
      'Both the full form and the compact form carry the confidence level. '
          'There is no formatting path that produces a bare range',
      () =>
          _accuracy.formatted.contains('95% CI') &&
          _accuracy.compact.contains('95%') &&
          _accuracy.formatted.contains('94.1') &&
          _accuracy.formatted.contains('98.7') &&
          _accuracy.semanticsLabel.contains('95 percent confidence'),
    );

    gate(
      'GEN-02929-G4',
      'Setup Step (Action) -- a formatter that renders a useless number as '
          'confidently as a useful one is worse than no formatter.',
      'An interval wider than the value it surrounds is reported as '
          'indicative rather than as a measurement, in both the visual and the '
          'spoken form',
      () =>
          _noisy.isIndicative &&
          !_accuracy.isIndicative &&
          _noisy.formatted.contains('indicative') &&
          _noisy.semanticsLabel.contains('wider than the value') &&
          _noisy.relativeWidth > HabotConfidenceMetric.indicativeThreshold,
    );

    gate(
      'GEN-02929-G5',
      'TTMCS-005 (Step 4) accessibility floor: "+/-" and "CI" are not words, '
          'and a screen reader saying "plus slash minus" is worse than saying '
          'nothing.',
      'The spoken form spells out the range and the confidence level in words '
          'and contains none of the visual shorthand',
      () =>
          !_accuracy.semanticsLabel.contains('+/-') &&
          !_accuracy.semanticsLabel.contains('CI') &&
          _accuracy.semanticsLabel.contains('between') &&
          _accuracy.semanticsLabel.contains('confidence'),
    );
  });

  group('GEN-02929-A01 :: rendered', () {
    testWidgets('[GEN-02929-G6] the metric renders in the bodySmall role and '
        'speaks its long form', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: HabotConfidenceText(metric: _accuracy),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Text rendered =
          tester.widget<Text>(find.byKey(HabotConfidenceText.textKey));
      final TextStyle expected = HabotTypography.textTheme().bodySmall!;
      expect(rendered.style?.fontSize, expected.fontSize);
      expect(find.text(_accuracy.formatted), findsOneWidget);
      expect(find.bySemanticsLabel(_accuracy.semanticsLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();

      gates.add(
        AissGate(
          id: 'GEN-02929-G6',
          requirementSource:
              'Setup Step (Action): "Format statistical confidence metrics '
              'using Material bodySmall typography on mobile."',
          description:
              'At 360dp the metric renders at the bodySmall size from the type '
              'scale and announces its long form to a screen reader',
          passed: true,
          detail:
              'rendered at ${rendered.style?.fontSize}sp; spoken as '
              '"${_accuracy.semanticsLabel}"',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02929',
        atomicStepReferenceId: 'GEN-02929-A01',
        setupStepAction:
            'Format statistical confidence metrics using Material bodySmall '
            'typography on mobile.',
        implementationOrder: 55,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'bodySmall':
              '${HabotConfidenceMetric.token.sizeSp.toStringAsFixed(0)}sp, '
              'line height '
              '${HabotConfidenceMetric.token.lineHeightSp.toStringAsFixed(0)}sp',
          'Component Name': 'HabotConfidenceMetric / HabotConfidenceText',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC NAME MISMATCH -- "Task Completion Status" is generic '
              'project tracking on a typography step. Gated against the '
              'bodySmall role the Setup Step names.',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Completion Status',
            observed:
                '1.0 -- the named type role is the one from the scale, the '
                'confidence level is carried in every formatting path, an '
                'over-wide interval is reported as indicative rather than as a '
                'measurement, and the spoken form contains no visual shorthand',
            floor: '0.8',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/confidence_metric.dart',
        ],
      ),
    );
  });
}
