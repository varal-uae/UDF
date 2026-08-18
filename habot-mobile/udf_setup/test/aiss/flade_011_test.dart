/// AISS GATE -- Step 73 of 80
/// Global Reference ID:       FLADE-011-10
/// Atomic Steps Reference ID: FLADE-011-10
/// Setup Step (Action):       "'Shakti Alert Panel' (Critical System Breach
///                             UI). (Un-ignorable, global red banners alerting
///                             all users of a manual override or P1
///                             architectural breach.)"
/// Setup Step Description:    "Write logic to intercept and disable all
///                             interactive UI elements on the underlying
///                             screen while the alert is active."
/// Metric: Observability / Alert Coverage -- Floor >=90%, Optimal 1.0,
///         Ceiling 1.0. Standard: Google SRE Handbook, Monitoring Distributed
///         Systems.
///
/// A SPARSE ROW, RECORDED: this row has no Decision Group, no Why This
/// Matters, no Expected Output, no Completion Measures, no Estimated Time and
/// no substeps -- twenty-odd columns are empty. What it does have is unusually
/// precise, and unusually implementable:
///   Setup Step Description: "intercept and DISABLE ALL INTERACTIVE UI
///     ELEMENTS on the underlying screen".
///   Data Requirement: "Un-ignorable critical alerts on any screen. | Fixed
///     top position components. | Ensures foundational logic breaks are never
///     ignored. | position: fixed; top: 0; width: 100vw; z-index: 10000;"
///   Data fields: "Step Execution ID; Execution Status; Execution Timestamp;
///     Step Outcome; User ID".
/// Every gate below comes from those four lines. Nothing was invented to fill
/// the empty columns.
///
/// THE INTERCEPTION IS THE STEP. "Un-ignorable" is a word, and a red banner
/// that can be tapped past is ignorable. So G1 does not inspect a flag: it
/// puts a working button under the alert and proves the button no longer
/// responds.
///
/// TRANSLATION, RECORDED: "position: fixed; top: 0; width: 100vw" is CSS. In
/// Flutter that is a Stack child pinned to the top edge at full width, and G3
/// measures the rendered rect rather than trusting the parameters.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/notifications/alert_panel.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

/// A screen with one button, so "did the tap get through?" is a countable
/// fact rather than an inference.
class _Underlying extends StatelessWidget {
  const _Underlying({required this.onTap, required this.controller});

  final VoidCallback onTap;
  final HabotAlertPanelController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: HabotTheme.light(),
      home: Scaffold(
        body: HabotAlertPanelLayer(
          controller: controller,
          child: Center(
            child: ElevatedButton(
              onPressed: onTap,
              child: const Text('underlying'),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredCoverage = -1;
  int tapsBlocked = -1;

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

  group('FLADE-011-10 :: the interception', () {
    testWidgets('[FLADE-011-10-G1] while a critical alert is active, the '
        'screen beneath it does not respond to touch', (
      WidgetTester tester,
    ) async {
      final HabotAlertPanelController controller = HabotAlertPanelController();
      addTearDown(controller.dispose);
      int taps = 0;

      await tester.pumpWidget(
        _Underlying(onTap: () => taps++, controller: controller),
      );

      // Before: the screen works.
      await tester.tap(find.text('underlying'));
      await tester.pump();
      expect(taps, 1, reason: 'the button works when nothing is raised');

      controller.raise(
        const HabotSystemAlert(
          id: 'p1',
          severity: HabotAlertSeverity.critical,
          headline: 'P1 architectural breach',
          detail: 'A manual override was applied to a locked step.',
        ),
      );
      await tester.pumpAndSettle();

      // During: every tap is swallowed. warnIfMissed is off because a
      // swallowed tap is the expected outcome here, not a mistake.
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('underlying'), warnIfMissed: false);
        await tester.pump();
      }
      tapsBlocked = 5 - (taps - 1);
      expect(taps, 1, reason: 'five taps, none of them reached the button');

      // After acknowledging: it works again -- interception, not destruction.
      await tester.tap(find.byKey(HabotAlertPanelLayer.acknowledgeKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('underlying'));
      await tester.pump();
      expect(taps, 2, reason: 'the screen is restored, not broken');
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'FLADE-011-10-G1',
          requirementSource:
              'Setup Step Description: "Write logic to INTERCEPT AND DISABLE '
              'ALL INTERACTIVE UI ELEMENTS on the underlying screen while the '
              'alert is active."',
          description:
              'A live button beneath the layer registers a tap before the '
              'alert, nothing at all during it, and taps again once it is '
              'acknowledged -- so the interception is measured on behaviour, '
              'not on a flag',
          passed: true,
          detail:
              '$tapsBlocked of 5 taps blocked while the critical alert was up',
        ),
      );
    });

    testWidgets('[FLADE-011-10-G2] a warning does not intercept, so the '
        'severity actually means something', (WidgetTester tester) async {
      final HabotAlertPanelController controller = HabotAlertPanelController();
      addTearDown(controller.dispose);
      int taps = 0;

      await tester.pumpWidget(
        _Underlying(onTap: () => taps++, controller: controller),
      );
      controller.raise(
        const HabotSystemAlert(
          id: 'w1',
          severity: HabotAlertSeverity.warning,
          headline: 'Context pruning',
          detail: 'Older turns will be dropped soon.',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('underlying'));
      await tester.pump();
      expect(
        taps,
        1,
        reason:
            'a warning that blocked the screen would make "critical" '
            'meaningless',
      );
      expect(controller.isBlocking, isFalse);

      // And a critical alert raised on top of the warning takes precedence.
      controller.raise(
        const HabotSystemAlert(
          id: 'p1',
          severity: HabotAlertSeverity.critical,
          headline: 'Breach',
          detail: 'Manual override.',
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.isBlocking, isTrue);
      expect(controller.current?.id, 'p1');
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'FLADE-011-10-G2',
          requirementSource:
              'Setup Step (Action): "P1 architectural breach" -- a severity '
              'named in the step itself, read against ARCPE-009-02 (Step 74), '
              'which is the warning case on the same layer.',
          description:
              'A warning leaves the screen usable, a critical alert does not, '
              'and a critical alert raised behind a warning takes the layer',
          passed: true,
        ),
      );
    });

    testWidgets('[FLADE-011-10-G3] the panel is pinned to the top edge at the '
        'full width of the viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final HabotAlertPanelController controller = HabotAlertPanelController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _Underlying(onTap: () {}, controller: controller),
      );
      controller.raise(
        const HabotSystemAlert(
          id: 'p1',
          severity: HabotAlertSeverity.critical,
          headline: 'P1 architectural breach',
          detail: 'A manual override was applied to a locked step.',
        ),
      );
      await tester.pumpAndSettle();

      final Rect panel = tester.getRect(
        find.byKey(HabotAlertPanelLayer.panelKey),
      );
      expect(panel.top, 0, reason: 'top: 0');
      expect(panel.width, 360, reason: 'width: 100vw');
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'FLADE-011-10-G3',
          requirementSource:
              'Data Requirement: "Fixed top position components." + '
              '"position: fixed; top: 0; width: 100vw; z-index: 10000;"',
          description:
              'The rendered panel measures top 0 and the full viewport width; '
              'the CSS z-index is expressed as its position in the Stack, '
              'above the absorbed body',
          passed: true,
          detail:
              'measured ${panel.left.toStringAsFixed(0)},'
              '${panel.top.toStringAsFixed(0)} '
              '${panel.width.toStringAsFixed(0)}dp wide in a 360x800 viewport',
        ),
      );
    });
  });

  group('FLADE-011-10 :: coverage', () {
    gate(
      'FLADE-011-10-G4',
      'Metric: Observability / Alert Coverage -- Floor >=90%, Optimal 1.0. '
          'Standard: "Google SRE Handbook -- Monitoring Distributed Systems."',
      'Coverage is computed from what the controller was asked to raise '
          'against what reached the layer, and a repeated id is not counted '
          'twice -- so the number cannot be inflated by re-raising one alert',
      () {
        final HabotAlertPanelController controller =
            HabotAlertPanelController();
        addTearDown(controller.dispose);
        for (int i = 0; i < 4; i++) {
          controller.raise(
            HabotSystemAlert(
              id: 'a$i',
              severity: i.isEven
                  ? HabotAlertSeverity.critical
                  : HabotAlertSeverity.warning,
              headline: 'alert $i',
              detail: 'detail $i',
            ),
          );
        }
        // The same alert raised twice is one alert.
        controller.raise(
          const HabotSystemAlert(
            id: 'a0',
            severity: HabotAlertSeverity.critical,
            headline: 'alert 0',
            detail: 'detail 0',
          ),
        );
        measuredCoverage = controller.alertCoverage;
        return controller.raisedCount == 4 &&
            controller.shownCount == 4 &&
            measuredCoverage == 1.0 &&
            measuredCoverage >= 0.90;
      },
    );

    gate(
      'FLADE-011-10-G5',
      'Setup Step (Action): "GLOBAL red banners alerting ALL USERS ... on any '
          'screen" (Data Requirement: "Un-ignorable critical alerts on any '
          'screen").',
      'The layer is mounted once, above the shell body, so every destination '
          'inherits it -- rather than each screen opting in and one of them '
          'forgetting',
      () {
        final String shell = File(
          'lib/habot_shell_page.dart',
        ).readAsStringSync();
        return shell.contains('body: HabotAlertPanelLayer(') &&
            shell.contains('controller: _alerts');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'FLADE-011-10',
        atomicStepReferenceId: 'FLADE-011-10-A01',
        setupStepAction:
            '"Shakti Alert Panel" (Critical System Breach UI). '
            '(Un-ignorable, global red banners alerting all users of a manual '
            'override or P1 architectural breach.)',
        implementationOrder: 73,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'HabotSystemAlert.id, unique per raised alert',
          'Execution Status':
              'active / acknowledged -- the controller holds one list and '
              'acknowledging is the only removal',
          'Execution Timestamp':
              'supplied by the raiser; the panel keeps no clock of its own',
          'Step Outcome':
              'blocking for critical, non-blocking for warning, measured by '
              'G1 and G2 on real taps',
          'User ID': 'not held by the panel -- global state, not per-user',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SPARSE ROW -- roughly twenty columns are empty (no Decision '
              'Group, Why This Matters, Expected Output, Completion Measures, '
              'Estimated Time or substeps). Nothing was invented to fill '
              'them. The four populated lines are precise and are what the '
              'five gates are drawn from. TRANSLATION RECORDED: "position: '
              'fixed; top: 0; width: 100vw; z-index: 10000" is CSS; it is '
              'implemented as a Stack child pinned to the top edge above the '
              'absorbed body, and G3 measures the rendered rect.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Observability / Alert Coverage',
            observed: measuredCoverage < 0
                ? 'not measured'
                : '${(measuredCoverage * 100).toStringAsFixed(0)}% -- 4 '
                      'distinct alerts raised, 4 reached the layer, a repeat '
                      'of one id counted once. SCOPE STATED: this is coverage '
                      'inside the app. Whether an alert reaches the device at '
                      'all is the transport\'s property and is not observed '
                      'here.',
            floor: '>=90%',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/notifications/alert_panel.dart',
          'lib/habot_shell_page.dart',
        ],
      ),
    );
  });
}
