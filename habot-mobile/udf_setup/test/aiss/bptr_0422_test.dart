/// AISS GATE -- Step 11 of 20
/// Global Reference ID:      BPTR-0422
/// Atomic Steps Reference ID: BPTR-0422-A01
/// Setup Step (Action):      "Define Passive Failure Motion Curves."
///
/// Expected Output: "CSS motion token library."
/// Completion Measures: "Standardized CSS transitions defined."
/// Metric: Requirements Traceability Coverage -- Floor 90, Optimal 98, Ceiling 100.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

Map<String, dynamic> _motionJson() {
  final File file = File('lib/design_system/tokens/tokens.json');
  expect(file.existsSync(), isTrue);
  final Map<String, dynamic> json =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return json['motion'] as Map<String, dynamic>;
}

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

  group('BPTR-0422-A01 :: passive failure motion curves', () {
    gate(
      'BPTR-0422-G1',
      '4 Substeps #1: "Set animation duration (300ms)."',
      'Failure duration is exactly 300ms and is the emphasized rung of the '
          'shared ladder',
      () =>
          HabotMotion.failureDuration.inMilliseconds == 300 &&
          HabotMotion.failureDuration == HabotMotion.emphasized,
    );

    gate(
      'BPTR-0422-G2',
      '4 Substeps #2: "Define easing curve."',
      'A failure curve is defined, is decelerating, and is distinct from the '
          'generic default',
      () {
        if (HabotEasing.failure == HabotEasing.standard) {
          return false;
        }
        // Decelerating: covers more than half its distance in the first half of
        // its time. Checked numerically rather than asserted by name.
        final double halfway = HabotEasing.failure.transform(0.5);
        return halfway > 0.5 &&
            HabotEasing.failure.transform(0) == 0 &&
            HabotEasing.failure.transform(1) == 1;
      },
    );

    gate(
      'BPTR-0422-G3',
      '4 Substeps #3: "Decide dimming intensity." + Poka-Yoke: "Animation '
          'physically locks surrounding UI until acknowledged."',
      'Dim opacity sits in a usable band and the UI-lock flag is on',
      () =>
          HabotMotion.failureDimOpacity > 0 &&
          HabotMotion.failureDimOpacity < 1 &&
          // Dark enough to read as inert, light enough to keep context visible.
          HabotMotion.failureDimOpacity >= 0.2 &&
          HabotMotion.failureDimOpacity <= 0.6 &&
          HabotMotion.failureLocksSurroundingUi,
    );

    gate(
      'BPTR-0422-G4',
      '4 Substeps #4: "Set auto-scroll."',
      'Auto-scroll is decided (enabled) and has a duration no slower than the '
          'failure animation itself',
      () =>
          HabotMotion.failureAutoScrollEnabled &&
          HabotMotion.failureAutoScrollDuration > Duration.zero &&
          HabotMotion.failureAutoScrollDuration <=
              HabotMotion.failureDuration,
    );

    gate(
      'BPTR-0422-G5',
      'Self-Chasing: "Failed element pulses continuously until resolved."',
      'Pulse period and opacity bounds are defined and coherent',
      () =>
          HabotMotion.failurePulsePeriod > HabotMotion.failureDuration &&
          HabotMotion.failurePulseMinOpacity <
              HabotMotion.failurePulseMaxOpacity &&
          HabotMotion.failurePulseMinOpacity > 0 &&
          HabotMotion.failurePulseMaxOpacity <= 1.0,
    );

    gate(
      'BPTR-0422-G6',
      'Completion Measures: "Standardized CSS transitions defined." + What '
          'Standardized Must Be Done: "Motion and animation design tokens."',
      'The duration ladder is strictly ascending, every curve is a real curve, '
          'and no interactive transition exceeds the 200ms ceiling',
      () {
        for (int i = 1; i < HabotMotion.durationLadder.length; i++) {
          if (HabotMotion.durationLadder[i] <=
              HabotMotion.durationLadder[i - 1]) {
            return false;
          }
        }
        for (final Curve curve in HabotEasing.all) {
          if (curve.transform(0) != 0 || curve.transform(1) != 1) {
            return false;
          }
        }
        return HabotMotion.stepperSlideIn <= HabotMotion.interactiveCeiling &&
            HabotMotion.stepperSlideOut <= HabotMotion.interactiveCeiling;
      },
    );

    gate(
      'BPTR-0422-G7',
      'Common Library to Store: "Motion & Animation System" -- tokens.json is '
          'the source of truth.',
      'Every motion constant in Dart matches tokens.json exactly (no drift)',
      () {
        final Map<String, dynamic> m = _motionJson();
        return (m['failure_duration_ms'] as num) ==
                HabotMotion.failureDuration.inMilliseconds &&
            (m['failure_dim_opacity'] as num) ==
                HabotMotion.failureDimOpacity &&
            m['failure_locks_surrounding_ui'] ==
                HabotMotion.failureLocksSurroundingUi &&
            (m['failure_auto_scroll_duration_ms'] as num) ==
                HabotMotion.failureAutoScrollDuration.inMilliseconds &&
            m['failure_auto_scroll_enabled'] ==
                HabotMotion.failureAutoScrollEnabled &&
            (m['failure_pulse_period_ms'] as num) ==
                HabotMotion.failurePulsePeriod.inMilliseconds &&
            (m['stepper_slide_in_ms'] as num) ==
                HabotMotion.stepperSlideIn.inMilliseconds &&
            (m['stepper_slide_out_ms'] as num) ==
                HabotMotion.stepperSlideOut.inMilliseconds &&
            (m['interactive_ceiling_ms'] as num) ==
                HabotMotion.interactiveCeiling.inMilliseconds &&
            (m['fast_ms'] as num) == HabotMotion.fast.inMilliseconds &&
            (m['emphasized_ms'] as num) ==
                HabotMotion.emphasized.inMilliseconds;
      },
    );
  });

  test(
    '[BPTR-0422-G8] each motion role has its own curve rather than one curve '
    'reused everywhere',
    () {
      // Atomic Reusability says this token set "wraps all compliance/validation
      // failures". That only works if a failure reads differently from an
      // ordinary transition -- otherwise the motion carries no information.
      final Set<Curve> distinct = HabotEasing.all.toSet();
      expect(
        distinct.length,
        HabotEasing.all.length,
        reason: 'Two motion roles resolve to the same curve',
      );
      expect(
        HabotMotion.durationLadder,
        contains(HabotMotion.failureDuration),
        reason: 'The failure duration must be a rung of the shared ladder, '
            'not a one-off value',
      );

      gates.add(
        const AissGate(
          id: 'BPTR-0422-G8',
          requirementSource:
              'Atomic Reusability: "Wraps all compliance/validation failures." '
              '+ Mobile-First UX Decision: "Motion draws eye to failure point '
              'on any screen."',
          description:
              'Failure, stepper-enter, stepper-exit and standard each resolve '
              'to a distinct curve, so motion carries meaning',
          passed: true,
        ),
      );
    },
  );

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BPTR-0422',
        atomicStepReferenceId: 'BPTR-0422-A01',
        setupStepAction: 'Define Passive Failure Motion Curves.',
        implementationOrder: 11,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Object Type': 'Motion token library (Dart consts + tokens.json)',
          'Object Location/Path':
              'lib/design_system/tokens/motion_tokens.dart + '
              'lib/design_system/tokens/tokens.json -> motion',
          'Open Status': 'Defined and drift-gated',
          'Timestamp': 'generated per run (see evidence.json mtime)',
          'File Handle ID': 'motion_tokens.dart',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirements Traceability Coverage',
            observed:
                '8 of 8 declared motion requirements gated (100%): 4 substeps '
                '+ poka-yoke + self-chasing + completion measure + drift',
            floor: '90.0',
            optimal: '98.0',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/motion_tokens.dart',
          'lib/design_system/tokens/tokens.json',
        ],
      ),
    );
  });
}
