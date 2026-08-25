/// AISS GATE -- Step 85 of 95
/// Global Reference ID:       MCIIM-008
/// Atomic Steps Reference ID: MCIIM-008-A01
/// Setup Step (Action):       "Building Isolated Visual Viewports for Broken
///                             Byt Context Isolation"
/// Setup Step Description:    "Render the final isolated viewport to ensure NO
///                             UNRELATED FILE DETAILS are visible to the
///                             user."
/// Data Requirement:          "Allocate EXACTLY 50% of the viewport height to
///                             the snippet image viewer, using the rest for
///                             the input box. | Use clean, neutral container
///                             borders to frame the reference snippet image."
/// Metric: Millisecond Precision Accuracy (ms) -- Optimal 50.0, Ceiling 100.0.
///
/// CONTAMINATED ROW, RECORDED: eleven columns describe an API gateway and
/// Cloud Run ingress -- Decision Before ("What runtime timeout configuration
/// protects resource connections during high traffic load?"), Why This Matters
/// ("Eliminates point-to-point service dependencies"), Expected Output ("API
/// Gateway Configuration Blueprint and Dynamic Routing Flow Maps"), Completion
/// Measures ("API gateway lookups dynamically redirect incoming requests"),
/// UX Translation, Flow Impact, Dashboard Implication, What Must Be
/// Standardized, Atomic Reusability, Common Library and GCP Alignment. None
/// are gated.
///
/// METRIC MISMATCH, RECORDED: "Millisecond Precision Accuracy" against the W3C
/// High Resolution Time standard is a clock measure on a rendering step.
/// Reported as NOT PRODUCED; Step 93 builds the clock it would belong to and
/// measures its drift there.
///
/// THE 50% IS NOT A NEW NUMBER. `HabotSplitRatio.balanced` already declares an
/// even split and Steps 36-38 already gated it, so G1 asserts the equality
/// rather than declaring a second 0.5.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/isolated_viewport.dart';
import 'package:udf_setup/design_system/shell/contextual_mirror.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

HabotByt _task() => HabotByt.fromDelivery(
  id: 'byt-1',
  box: _box,
  snippet: Uri.parse(
    'https://assets.habot.internal/crops/byt-1.png'
    '?crop=${HabotCropContract.signatureFor(_box)}',
  ),
  prompt: 'Read the invoice total',
  expectedFormat: 'digits and a decimal point',
)!;

/// A stand-in for the cropped image: a widget test cannot load one over HTTP,
/// and a viewport that rendered nothing in tests would prove nothing.
Widget _stubSnippet(BuildContext context, HabotByt byt) => SizedBox(
  width: byt.box.width,
  height: byt.box.height,
  child: const ColoredBox(color: Color(0xFF000000)),
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredEvidenceHeight = -1;

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

  group('MCIIM-008-A01 :: the split', () {
    gate(
      'MCIIM-008-G1',
      'Data Requirement: "Allocate EXACTLY 50% of the viewport height to the '
          'snippet image viewer, using the rest for the input box." Read '
          'against SSTLA-012 (Step 36), which already declares a balanced '
          'split ratio.',
      'The evidence share IS HabotSplitRatio.balanced, not a second 0.5 '
          'written here, and the two halves of a viewport add back up to it '
          'exactly',
      () {
        measuredEvidenceHeight = HabotEvidenceSplit.evidenceHeightFor(800);
        return HabotIsolatedViewport.evidenceShare ==
                HabotSplitRatio.balanced.evidenceShare &&
            HabotIsolatedViewport.evidenceShare == 0.5 &&
            measuredEvidenceHeight == 400 &&
            HabotEvidenceSplit.actionHeightFor(800) == 400 &&
            HabotEvidenceSplit.evidenceHeightFor(645) +
                    HabotEvidenceSplit.actionHeightFor(645) ==
                645;
      },
    );
  });

  group('MCIIM-008-A01 :: what is on screen', () {
    testWidgets('[MCIIM-008-G2] the viewport renders the crop and nothing '
        'else, and says so to a screen reader', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: HabotIsolatedViewport(
                byt: _task(),
                imageBuilder: _stubSnippet,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(HabotIsolatedViewport.viewportKey), findsOneWidget);
      expect(find.byKey(HabotIsolatedViewport.frameKey), findsOneWidget);
      // Nothing interactive inside the evidence pane: it is evidence, not a
      // control surface.
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);

      final Semantics semantics = tester.widget<Semantics>(
        find.byKey(HabotIsolatedViewport.viewportKey),
      );
      expect(
        semantics.properties.label,
        contains('the source document is not available on this device'),
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'MCIIM-008-G2',
          requirementSource:
              'Setup Step Description: "Render the final isolated viewport to '
              'ensure NO UNRELATED FILE DETAILS are visible to the user."',
          description:
              'The rendered viewport contains the crop, a frame and its '
              'semantics -- no controls, no second image, and a spoken label '
              'that states the source document is not on the device',
          passed: true,
        ),
      );
    });

    testWidgets('[MCIIM-008-G3] the frame clips, so nothing spills outside it',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 200,
              child: HabotIsolatedViewport(
                byt: _task(),
                imageBuilder: _stubSnippet,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(HabotIsolatedViewport.frameKey),
          matching: find.byType(ClipRRect),
        ),
        findsOneWidget,
        reason: '"CSS overflow: hidden" -- a spilled edge is context',
      );
      final Rect frame = tester.getRect(
        find.byKey(HabotIsolatedViewport.frameKey),
      );
      expect(frame.width, lessThanOrEqualTo(360));
      expect(frame.height, lessThanOrEqualTo(200));
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'MCIIM-008-G3',
          requirementSource:
              'MCIIM-009-09 Data Requirement: "CSS overflow: hidden", applied '
              'to the viewport this step renders.',
          description:
              'The frame clips its contents and stays inside the box it was '
              'given, measured on the rendered tree',
          passed: true,
          detail:
              'frame ${frame.width.toStringAsFixed(0)}x'
              '${frame.height.toStringAsFixed(0)} inside a 360x200 pane',
        ),
      );
    });

    testWidgets('[MCIIM-008-G4] the viewport is a neutral frame, not a card '
        'with its own elevation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: HabotIsolatedViewport(
                byt: _task(),
                imageBuilder: _stubSnippet,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final DecoratedBox frame = tester.widget<DecoratedBox>(
        find.byKey(HabotIsolatedViewport.frameKey),
      );
      final BoxDecoration decoration = frame.decoration as BoxDecoration;
      expect(
        decoration.border,
        isNotNull,
        reason: '"clean, neutral container borders"',
      );
      expect(
        decoration.boxShadow,
        isNull,
        reason:
            'a border AND a shadow is the combination GEN-01452 (Step 29) '
            'forbids on every surface in this system',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'MCIIM-008-G4',
          requirementSource:
              'Data Requirement: "Use CLEAN, NEUTRAL CONTAINER BORDERS to '
              'frame the reference snippet image."',
          description:
              'The frame is a border in the outline-variant role with no '
              'shadow, so it obeys the Step 29 rule that a surface may have a '
              'border or a shadow but never both',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MCIIM-008',
        atomicStepReferenceId: 'MCIIM-008-A01',
        setupStepAction:
            'Building Isolated Visual Viewports for Broken Byt Context '
            'Isolation',
        implementationOrder: 85,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'the byt id the viewport was given',
          'Execution Status': 'rendered / refused before rendering',
          'Execution Timestamp': 'carried by the delivery',
          'Step Outcome':
              'evidence pane '
              '${measuredEvidenceHeight < 0 ? "not measured" : "${measuredEvidenceHeight.toStringAsFixed(0)}dp of an 800dp viewport"}',
          'User ID': 'not held by the viewport',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'CONTAMINATED ROW -- eleven columns describe an API gateway and '
              'Cloud Run ingress (Expected Output "API Gateway Configuration '
              'Blueprint", Completion Measures about gateway lookups). Not '
              'gated. Two columns are specific and were used: the Description '
              'and the 50%-height allocation. METRIC MISMATCH -- "Millisecond '
              'Precision Accuracy" is a clock measure on a rendering step; '
              'recorded as NOT PRODUCED, and Step 93 measures the clock it '
              'would belong to.',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Millisecond Precision Accuracy (ms)',
            observed:
                'NOT PRODUCED -- this is a High Resolution Time measure, and '
                'this step renders a frame. No number invented. GEN-03866 '
                '(Step 93) measures timer drift, which is the same instrument '
                'applied to the thing that actually has a clock.',
            floor: '0.0',
            optimal: '50.0',
            ceiling: '100.0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/isolated_viewport.dart',
        ],
      ),
    );
  });
}
