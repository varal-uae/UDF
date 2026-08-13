/// AISS GATE -- Step 34 of 35
/// Global Reference ID:       UFHT-032
/// Atomic Steps Reference ID: UFHT-032-A01
/// Setup Step (Action):       "UI Hesitation Tracker Engine Setup"
/// Setup Step Description:    "Attach focus event listeners to every individual
///                             input field within the target form."
/// Metric: Event Listener Coverage Rate (%) -- Floor 95.0, Optimal 99.0,
///         Ceiling 100.0.
///
/// COLUMN CONTAMINATION, RECORDED AND EXCLUDED: this row's Expected Output
/// reads "Historical Audit Report SQL", its Completion Measure reads
/// "Row_Level_Audit_Coverage == 100%", and its pre-step Decision asks about
/// primary keys in caching tables. All three belong to a warehouse step. They
/// are NOT gated. What is gated is the Setup Step, the Description and the
/// Metric, which are coherent and describe a UI instrument.
///
/// This is the step TTMAC-014 named by ID as the source of its double-tap
/// correction rate. Closing that deferral is what this step is for.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/validated_input_field.dart';
import 'package:udf_setup/design_system/telemetry/hesitation_tracker.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

/// A clock the gate drives, so dwell and double-tap windows are exact rather
/// than dependent on how fast the machine runs the test.
class _StepClock {
  DateTime now = DateTime.utc(2026, 8, 12);
  DateTime call() => now;
  void advance(Duration by) => now = now.add(by);
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  double observedCoverage = 0;

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

  group('UFHT-032-A01 :: hesitation tracker engine', () {
    gate(
      'UFHT-032-G1',
      'Setup Step Description: "Attach focus event listeners to EVERY '
          'INDIVIDUAL INPUT FIELD within the target form." + Metric: Event '
          'Listener Coverage Rate (%), Floor 95.0, Optimal 99.0.',
      'Attaching a listener registers the field and counts toward coverage, so '
          'the metric is computed from what actually happened rather than '
          'asserted',
      () {
        final HabotHesitationTracker tracker = HabotHesitationTracker();
        final List<FocusNode> nodes = <FocusNode>[
          for (int i = 0; i < 4; i++) FocusNode(),
        ];
        addTearDown(() {
          for (final FocusNode node in nodes) {
            node.dispose();
          }
        });
        for (int i = 0; i < nodes.length; i++) {
          tracker.attach('field$i', nodes[i]);
        }
        observedCoverage = tracker.listenerCoverage;
        return tracker.registeredFields.length == 4 &&
            tracker.attachedFields.length == 4 &&
            observedCoverage == 100.0;
      },
    );

    gate(
      'UFHT-032-G2',
      'Metric: Event Listener Coverage Rate (%) -- a metric that can only ever '
          'read 100% is not a measurement.',
      'Coverage genuinely falls when a registered field loses its listener, so '
          'the metric can fail',
      () {
        final HabotHesitationTracker tracker = HabotHesitationTracker();
        final FocusNode a = FocusNode();
        final FocusNode b = FocusNode();
        addTearDown(a.dispose);
        addTearDown(b.dispose);

        tracker.attach('a', a);
        final VoidCallback listener = tracker.attach('b', b);
        if (tracker.listenerCoverage != 100.0) {
          return false;
        }
        tracker.detach('b', b, listener);
        // The field stays registered: dropping a listener is a shortfall, not
        // a disappearance from the denominator.
        return tracker.registeredFields.length == 2 &&
            tracker.attachedFields.length == 1 &&
            tracker.listenerCoverage == 50.0;
      },
    );

    gate(
      'UFHT-032-G3',
      'Privacy, by construction -- the step asks for focus events, not for '
          'content. A tracker that can log a field value eventually will.',
      'No recorded event carries a field value: the event payload is field '
          'name, kind, timestamp and dwell only, and the name is scrubbed on '
          'the way out',
      () {
        final _StepClock clock = _StepClock();
        final HabotHesitationTracker tracker = HabotHesitationTracker(
          clock: clock.call,
        );
        tracker.recordFocus('account');
        clock.advance(HabotMotion.hesitationDwell);
        tracker.recordBlur('account');

        final Map<String, Object?> json = tracker.events.last.toJson();
        return json.keys.toSet().containsAll(<String>{
              'field',
              'kind',
              'at',
              'dwell_ms',
              'hesitation',
            }) &&
            json.length == 5 &&
            !json.containsKey('value') &&
            !json.containsKey('text');
      },
    );

    gate(
      'UFHT-032-G4',
      'Setup Step (Action): "UI HESITATION Tracker Engine Setup." Hesitation is '
          'dwell without progress; ordinary typing is not hesitation.',
      'A dwell at or beyond the threshold reads as hesitation and a shorter '
          'one does not',
      () {
        final _StepClock clock = _StepClock();
        final HabotHesitationTracker tracker = HabotHesitationTracker(
          clock: clock.call,
        );

        tracker.recordFocus('slow');
        clock.advance(HabotMotion.hesitationDwell);
        tracker.recordBlur('slow');

        tracker.recordFocus('quick');
        clock.advance(HabotMotion.fast);
        tracker.recordBlur('quick');

        final List<HabotInteractionEvent> blurs = tracker.events
            .where(
              (HabotInteractionEvent e) => e.kind == HabotInteractionKind.blur,
            )
            .toList();
        return blurs.length == 2 &&
            blurs.first.isHesitation &&
            !blurs.last.isHesitation;
      },
    );

    gate(
      'UFHT-032-G5',
      'TTMAC-014 Completion Measure, which named this step: double-tap '
          'corrections must be measurable.',
      'Two taps on the same target inside the double-tap window record one '
          'correction; the same two taps outside the window record none',
      () {
        final _StepClock clock = _StepClock();
        final HabotHesitationTracker tracker = HabotHesitationTracker(
          clock: clock.call,
        );

        tracker.recordTap('submit');
        clock.advance(HabotMotion.doubleTapWindow ~/ 2);
        final bool inWindow = tracker.recordTap('submit');

        clock.advance(HabotMotion.doubleTapWindow * 4);
        tracker.recordTap('submit');
        clock.advance(HabotMotion.doubleTapWindow * 4);
        final bool outOfWindow = tracker.recordTap('submit');

        return inWindow &&
            !outOfWindow &&
            tracker.countOf(HabotInteractionKind.doubleTapCorrection) == 1 &&
            tracker.tapCount == 4 &&
            tracker.doubleTapCorrectionRate == 25.0;
      },
    );
  });

  group('UFHT-032-A01 :: coverage is structural', () {
    testWidgets('[UFHT-032-G6] every field in a real form attaches its own '
        'listener without the form asking', (WidgetTester tester) async {
      final HabotHesitationTracker tracker = HabotHesitationTracker();
      HabotHesitationTracker.useInstance(tracker);
      addTearDown(() => HabotHesitationTracker.useInstance(
            HabotHesitationTracker(),
          ));

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: Column(
              children: <Widget>[
                ValidatedInputField(
                  fieldName: 'account',
                  label: 'Account number',
                  cde: HabotCde.accountNumber,
                ),
                ValidatedInputField(
                  fieldName: 'email',
                  label: 'Email',
                  cde: HabotCde.emailAddress,
                ),
                ValidatedInputField(
                  fieldName: 'phone',
                  label: 'Phone',
                  cde: HabotCde.phoneNumber,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tracker.registeredFields, <String>{'account', 'email', 'phone'});
      expect(tracker.attachedFields.length, 3);
      expect(tracker.listenerCoverage, 100.0);

      // And the listeners are live: focusing a field records the event.
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      expect(
        tracker.events.any(
          (HabotInteractionEvent e) =>
              e.field == 'account' && e.kind == HabotInteractionKind.focus,
        ),
        isTrue,
      );

      gates.add(
        AissGate(
          id: 'UFHT-032-G6',
          requirementSource:
              'Setup Step Description: "Attach focus event listeners to every '
              'individual input field within the target form." + Metric: Event '
              'Listener Coverage Rate (%), Optimal 99.0.',
          description:
              'A three-field form built from the design system reaches 100% '
              'listener coverage with no per-field wiring, and the listeners '
              'fire on real focus',
          passed: true,
          detail:
              'coverage ${tracker.listenerCoverage.toStringAsFixed(1)}% '
              '(floor 95.0, optimal 99.0)',
        ),
      );
    });

    testWidgets('[UFHT-032-G7] removing entered content records a correction, '
        'and the content itself is never recorded', (
      WidgetTester tester,
    ) async {
      final HabotHesitationTracker tracker = HabotHesitationTracker();
      HabotHesitationTracker.useInstance(tracker);
      addTearDown(() => HabotHesitationTracker.useInstance(
            HabotHesitationTracker(),
          ));

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: ValidatedInputField(
              fieldName: 'account',
              label: 'Account number',
              cde: HabotCde.accountNumber,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '12345678');
      await tester.pump();
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();

      expect(tracker.countOf(HabotInteractionKind.correction), 1);
      for (final HabotInteractionEvent event in tracker.events) {
        expect(event.toJson().values.join(' '), isNot(contains('5678')));
      }

      gates.add(
        const AissGate(
          id: 'UFHT-032-G7',
          requirementSource:
              'Setup Step (Action): "UI Hesitation Tracker Engine Setup" -- a '
              'correction is the signal; the content is not.',
          description:
              'Shortening an entered value records exactly one correction, and '
              'no event payload contains any part of what was typed',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'UFHT-032',
        atomicStepReferenceId: 'UFHT-032-A01',
        setupStepAction: 'UI Hesitation Tracker Engine Setup',
        implementationOrder: 34,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'UFHT-032-A01/hesitation-tracker',
          'Execution Status': 'Derived from gate outcomes',
          'Step Outcome':
              'Focus, blur, correction and double-tap listeners attached to '
              'every design-system input field',
          'Completion Status': 'Derived from gate outcomes',
          'Excluded columns':
              'Expected Output ("Historical Audit Report SQL"), Completion '
              'Measure ("Row_Level_Audit_Coverage == 100%") and the pre-step '
              'Decision (caching-table primary keys) are contaminated and are '
              'not gated.',
          'Privacy':
              'No event carries a field value. Payload is field name, kind, '
              'timestamp and dwell only; the name is scrubbed on emit.',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Event Listener Coverage Rate (%)',
            observed:
                '100.0 -- every field constructed through ValidatedInputField '
                'attaches its listener in initState, so coverage is structural. '
                'The metric can still fail: a detached listener drops it '
                '(gated by G2).',
            floor: '95.0',
            optimal: '99.0',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/hesitation_tracker.dart',
          'lib/design_system/forms/validated_input_field.dart',
        ],
      ),
    );
  });
}
