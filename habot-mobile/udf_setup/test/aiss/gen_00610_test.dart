/// AISS GATE -- Step 88 of 95
/// Global Reference ID:       GEN-00610
/// Atomic Steps Reference ID: GEN-00610-A01
/// Setup Step (Action):       "Implement Context-Isolated Split-Screen UI for
///                             Mobile MTOI Exception Handling"
/// Setup Step Description:    "STRIP PERIPHERAL NAVIGATION ELEMENTS, DRAWERS,
///                             AND HEADERS from the scaffold view."
/// Metric: Peripheral Element Count -- Floor 0, Optimal 0, Ceiling 0.
///
/// THE MOST DIRECTLY GATEABLE METRIC IN THE BATCH: a zero-tolerance count with
/// the same value in all three bands. So the gate does not check a range -- it
/// walks the rendered widget tree of a real task screen and counts.
///
/// TWO ROWS AGREE ABOUT THIS. MCIIM-021's own UI Implementation column says
/// "hide global navigation (app bars/bottom nav) during the task to maximise
/// focus", from a different row in a different block of the sheet. When two
/// independently written rows ask for the same thing, it is worth building
/// structurally rather than by convention -- so the chassis has no parameter
/// through which a header, footer or floating action could be passed at all.
///
/// A GENERATED ROW OTHERWISE, RECORDED: Why This Matters is the Description
/// plus "is a critical implementation step", Expected Output is the template
/// restatement, Completion Measures is "100% CI/CD pass rate", and the four
/// Material Design columns are the boilerplate shared with every GEN-* row.
/// The LaTeX-style `$0$` in the metric cells is a source-sheet artefact.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/task_chassis.dart';
import 'package:udf_setup/design_system/mto/task_screen.dart';
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

Widget _stubSnippet(BuildContext context, HabotByt byt) =>
    SizedBox(width: byt.box.width, height: byt.box.height);

void main() {
  final List<AissGate> gates = <AissGate>[];
  int measuredPeripherals = -1;

  setUp(HabotTaskLayoutRegistry.reset);

  group('GEN-00610-A01 :: the peripheral count', () {
    testWidgets('[GEN-00610-G1] a rendered task screen contains zero '
        'peripheral elements', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: HabotTaskScreen(
            byt: _task(),
            cde: HabotCde.currencyAmount,
            imageBuilder: _stubSnippet,
            onSubmit: (String _) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final List<Widget> rendered = tester.allWidgets.toList();
      measuredPeripherals = HabotPeripheralCensus.countIn(rendered);
      expect(
        measuredPeripherals,
        HabotPeripheralCensus.allowedCount,
        reason:
            'found: ${HabotPeripheralCensus.namesIn(rendered).join(", ")}',
      );
      // And the task itself is on screen -- a blank screen would also score
      // zero, which would make the metric meaningless.
      expect(find.byKey(HabotTaskAnswerPane.inputKey), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-00610-G1',
          requirementSource:
              'Setup Step Description: "STRIP PERIPHERAL NAVIGATION ELEMENTS, '
              'DRAWERS, AND HEADERS from the scaffold view." Metric: '
              'Peripheral Element Count, floor/optimal/ceiling all 0.',
          description:
              'The rendered tree of a real task screen contains none of the '
              'named peripheral types, while still containing the task -- so '
              'the zero is a measurement rather than an empty screen',
          passed: true,
          detail:
              '$measuredPeripherals peripheral elements across '
              '${rendered.length} widgets',
        ),
      );
    });

    test('[GEN-00610-G2] the chassis has nowhere to put a peripheral element',
        () {
      final String source = File(
        'lib/design_system/mto/task_chassis.dart',
      ).readAsStringSync();
      final String chassis = source.split('class HabotTaskChassis')[1];
      for (final String slot in <String>['header:', 'footer:', 'floatingAction:']) {
        expect(
          chassis.contains(slot),
          isFalse,
          reason: 'the chassis must not pass $slot to the scaffold',
        );
      }
      expect(
        chassis.contains('required this.evidence'),
        isTrue,
        reason: 'evidence and action are the only two slots',
      );

      gates.add(
        const AissGate(
          id: 'GEN-00610-G2',
          requirementSource:
              'MCIIM-021 UI Implementation: "Hide global navigation (app '
              'bars/bottom nav) during the task to maximise focus" -- the '
              'same requirement, from a second row.',
          description:
              'The chassis exposes no header, footer or floating-action slot '
              'at all, so the count stays at zero by construction rather than '
              'by every caller remembering',
          passed: true,
          detail: 'source scan of task_chassis.dart',
        ),
      );
    });

    test('[GEN-00610-G3] the census is a closed list that includes this app\'s '
        'own navigation, not only the framework\'s', () {
      expect(
        HabotPeripheralCensus.peripheralTypes,
        containsAll(<Type>[NavigationBar, NavigationRail, Drawer, AppBar]),
      );
      expect(
        HabotPeripheralCensus.peripheralTypes.length,
        greaterThanOrEqualTo(8),
        reason:
            'a scan that only knew the framework types would pass a screen '
            'that kept HabotAdaptiveNavigation',
      );
      expect(HabotPeripheralCensus.isPeripheral(const Placeholder()), isFalse);
      expect(HabotPeripheralCensus.allowedCount, 0);

      gates.add(
        AissGate(
          id: 'GEN-00610-G3',
          requirementSource:
              'Metric: Peripheral Element Count. A count needs a definition '
              'of what it counts.',
          description:
              'The peripheral vocabulary is a named, closed list covering '
              'both framework chrome and this app\'s own navigation and '
              'header components',
          passed: true,
          detail:
              '${HabotPeripheralCensus.peripheralTypes.length} types counted '
              'as peripheral',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00610',
        atomicStepReferenceId: 'GEN-00610-A01',
        setupStepAction:
            'Implement Context-Isolated Split-Screen UI for Mobile MTOI '
            'Exception Handling',
        implementationOrder: 88,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Strip peripheral navigation elements, drawers, and headers':
              'measured on the rendered tree: '
              '${measuredPeripherals < 0 ? "not measured" : "$measuredPeripherals"}',
          'Component Name': 'HabotTaskChassis',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'GENERATED ROW -- Why This Matters, Expected Output and the four '
              'substeps are template prose; Completion Measures is CI/CD '
              'tracking; the Material Design columns are boilerplate shared '
              'with every GEN-* row. Not gated. THE METRIC IS THE BEST IN THE '
              'BATCH: a zero-tolerance count, used literally. The LaTeX-style '
              '"\$0\$" formatting in the metric cells is a source-sheet '
              'artefact, not a value. SECOND ROW AGREES: MCIIM-021 asks for '
              'the same thing in its UI Implementation column.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Peripheral Element Count',
            observed: measuredPeripherals < 0
                ? 'not measured'
                : '$measuredPeripherals -- counted on the rendered widget tree '
                      'of a real task screen at 400x900, against a closed list '
                      'of framework chrome and this app\'s own navigation and '
                      'header components. The task itself was present in the '
                      'same tree, so the zero is not an empty screen.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/task_chassis.dart',
          'lib/design_system/mto/task_screen.dart',
        ],
      ),
    );
  });
}
