/// AISS GATE -- Step 35 of 35
/// Global Reference ID:       GEN-00632
/// Atomic Steps Reference ID: GEN-00632-A01
/// Setup Step (Action):       "Deploy Mobile UX Friction Logs (Hesitation
///                             Tracking)"
/// Setup Step Description:    "Define the FrictionTracker widget wrapper class."
/// Metric: Class Wrapper Integrity -- Floor 100%, Optimal 100%.
///   Another single-value metric: the wrapper either holds for every screen it
///   wraps, or it does not.
///
/// The second half of the telemetry pair. UFHT-032 records the interactions;
/// this turns them into a report and puts the recording in the widget tree, so
/// a screen is instrumented by being wrapped rather than by every control
/// remembering to report itself.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/telemetry/friction_tracker.dart';
import 'package:udf_setup/design_system/telemetry/hesitation_tracker.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

class _StepClock {
  DateTime now = DateTime.utc(2026, 8, 12);
  DateTime call() => now;
  void advance(Duration by) => now = now.add(by);
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  double replayRate = 0;

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

  group('GEN-00632-A01 :: friction report', () {
    gate(
      'GEN-00632-G1',
      'Setup Step Description: "Define the FrictionTracker widget wrapper '
          'class." + Metric: Class Wrapper Integrity, Floor = Optimal = 100%.',
      'The report derives every rate from recorded counts rather than storing '
          'them, so a rate can never disagree with the events behind it',
      () {
        const FrictionReport report = FrictionReport(
          screenName: 'probe',
          taps: 200,
          doubleTapCorrections: 1,
          corrections: 6,
          hesitations: 4,
          events: 40,
        );
        return report.doubleTapCorrectionRate == 0.5 &&
            report.correctionRate == 3.0 &&
            report.hesitationRate == 10.0 &&
            const FrictionReport(
                  screenName: 'empty',
                  taps: 0,
                  doubleTapCorrections: 0,
                  corrections: 0,
                  hesitations: 0,
                  events: 0,
                ).doubleTapCorrectionRate ==
                0;
      },
    );

    gate(
      'GEN-00632-G2',
      'REF-197 Poka-Yoke, inherited: "strip out server-specific error language '
          'automatically before messages reach the UI layer" -- a friction log '
          'is a log, and the same rule applies to it.',
      'The emitted log is scrubbed and value-free: a screen name carrying a '
          'path or an address is redacted before it leaves the report',
      () {
        const FrictionReport report = FrictionReport(
          screenName: '/srv/habot/lib/screens/batch.dart',
          taps: 1,
          doubleTapCorrections: 0,
          corrections: 0,
          hesitations: 0,
          events: 1,
        );
        final String emitted = report.toJson().values.join(' ');
        return !emitted.contains('/srv/habot') &&
            !emitted.contains('.dart') &&
            report.toJson().containsKey('double_tap_correction_rate_pct');
      },
    );

    gate(
      'GEN-00632-G3',
      'TTMAC-014 Completion Measure: "double-tap corrections below 1%." The '
          'gate that step deferred needs a computed rate, and this is where it '
          'is computed.',
      'A deterministic 500-interaction replay produces a double-tap correction '
          'rate below the 1% ceiling, from real recorded taps rather than a '
          'constant',
      () {
        final _StepClock clock = _StepClock();
        final HabotHesitationTracker tracker = HabotHesitationTracker(
          clock: clock.call,
        );

        // 500 deliberate taps, spaced well outside the double-tap window, with
        // two genuine double-taps mixed in.
        for (int i = 0; i < 500; i++) {
          tracker.recordTap('target-${i % 7}');
          if (i == 100 || i == 300) {
            // A genuine correction: the same target tapped again inside the
            // window, which is exactly what TTMAC-014 is counting.
            clock.advance(HabotMotion.doubleTapWindow ~/ 2);
            tracker.recordTap('target-${i % 7}');
          }
          clock.advance(HabotMotion.doubleTapWindow * 3);
        }

        replayRate = tracker.doubleTapCorrectionRate;
        return tracker.tapCount == 502 &&
            tracker.countOf(HabotInteractionKind.doubleTapCorrection) == 2 &&
            replayRate < 1.0;
      },
    );
  });

  group('GEN-00632-A01 :: the wrapper in a tree', () {
    testWidgets('[GEN-00632-G4] wrapping a screen records its taps without '
        'swallowing them', (WidgetTester tester) async {
      final HabotHesitationTracker tracker = HabotHesitationTracker();
      int buttonPresses = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: FrictionTracker(
              screenName: 'BatchScreen',
              tracker: tracker,
              child: Center(
                child: FilledButton(
                  onPressed: () => buttonPresses++,
                  child: const Text('Release'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Release'));
      await tester.pumpAndSettle();

      // The instrument observed the tap...
      expect(tracker.tapCount, 1);
      // ...and the button underneath still received it.
      expect(buttonPresses, 1);

      gates.add(
        const AissGate(
          id: 'GEN-00632-G4',
          requirementSource:
              'Setup Step Description: "Define the FrictionTracker widget '
              'wrapper class." Instrumentation that swallows a tap is worse '
              'than no instrumentation.',
          description:
              'A wrapped screen records the pointer while the control beneath '
              'it still fires',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-00632-G5] the wrapper exposes a live report for the '
        'screen it wraps, reachable from any subtree', (
      WidgetTester tester,
    ) async {
      final HabotHesitationTracker tracker = HabotHesitationTracker();
      late BuildContext inner;

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: FrictionTracker(
              screenName: 'BatchScreen',
              tracker: tracker,
              child: Builder(
                builder: (BuildContext context) {
                  inner = context;
                  return const Center(child: Text('body'));
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('body'));
      await tester.tap(find.text('body'));
      await tester.pumpAndSettle();

      final FrictionTrackerState? state = FrictionTracker.maybeOf(inner);
      expect(state, isNotNull);

      final FrictionReport report = state!.report;
      expect(report.screenName, 'BatchScreen');
      expect(report.taps, 2);
      expect(report.toJson()['screen'], 'BatchScreen');

      gates.add(
        AissGate(
          id: 'GEN-00632-G5',
          requirementSource:
              'Metric: Class Wrapper Integrity (100%). A wrapper whose report '
              'cannot be read from inside the subtree it wraps has no '
              'integrity to measure.',
          description:
              'A subtree finds its enclosing tracker and reads a live report '
              'naming the screen and counting its taps',
          passed: true,
          detail: 'report: ${report.toJson()}',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00632',
        atomicStepReferenceId: 'GEN-00632-A01',
        setupStepAction: 'Deploy Mobile UX Friction Logs (Hesitation Tracking)',
        implementationOrder: 35,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'FrictionTracker / FrictionReport',
          'Component Type': 'Screen-level telemetry wrapper',
          'Component Properties':
              'taps, double-tap corrections, corrections, hesitations, events',
          'Completion Status': 'Derived from gate outcomes',
          'Privacy':
              'Screen names are scrubbed on emit; no field content is ever '
              'recorded by the engine this wraps.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Class Wrapper Integrity',
            observed:
                '100% -- the wrapper records every pointer that reaches the '
                'subtree, passes all of them through, and exposes a live '
                'report to any descendant. Deterministic replay double-tap '
                'rate: ${replayRate.toStringAsFixed(2)}% against the 1% '
                'ceiling TTMAC-014 set.',
            floor: '100%',
            optimal: '100%',
            ceiling: 'N/A (100% target)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/friction_tracker.dart',
          'lib/design_system/telemetry/hesitation_tracker.dart',
        ],
      ),
    );
  });
}
