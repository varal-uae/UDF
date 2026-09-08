/// AISS GATE -- Step 155 of 155
/// Global Reference ID:       GEN-04506
/// Atomic Steps Reference ID: GEN-04506
/// Setup Step (Action) / Atomic Step: "Bind success haptic profiles to
///   completed form submission actions."
/// Metric: Micro-interaction Response Latency -- Floor "< 100ms",
///         Optimal "< 50ms", Ceiling "< 16ms (1 frame @60fps)".
///         Good / Average / Poor.
///
/// THE CEILING IS TIGHTER THAN THE OPTIMAL, WHICH IS UNUSUAL AND CORRECT: one
/// frame is reachable only by firing synchronously, which is a property of the
/// code rather than of a timing run.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/haptics.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

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

  ({HabotHaptics haptics, List<HabotHapticStrength> fired}) build({
    bool enabled = true,
  }) {
    final List<HabotHapticStrength> fired = <HabotHapticStrength>[];
    return (
      haptics: HabotHaptics(enabled: enabled, platform: fired.add),
      fired: fired,
    );
  }

  group('GEN-04506 :: the binding the row asks for', () {
    gate(
      'GEN-04506-G1',
      'Atomic Step: "Bind SUCCESS haptic profiles to COMPLETED FORM SUBMISSION '
          'actions."',
      'A completed submission fires the success profile through the platform, '
          'once, and the moment it fired is recorded so the binding is '
          'observable rather than assumed',
      () {
        final ({HabotHaptics haptics, List<HabotHapticStrength> fired}) h =
            build();
        h.haptics.onSubmitSucceeded();
        return h.fired.single == HabotHapticStrength.medium &&
            h.haptics.fired.single == HabotHapticMoment.submitSucceeded &&
            h.haptics.firedCount == 1 &&
            HabotHaptics.strengthFor(HabotHapticMoment.submitSucceeded) ==
                HabotHapticStrength.medium;
      },
    );

    gate(
      'GEN-04506-G2',
      'A heavy buzz on a failed submit punishes someone for a mistake the form '
          'usually caused, and the error message is what does the work.',
      'Failure is deliberately NOT the mirror of success: it gets the light '
          'profile, and every declared moment has a strength so a new one '
          'cannot be added without someone deciding how it should feel',
      () {
        final ({HabotHaptics haptics, List<HabotHapticStrength> fired}) h =
            build();
        h.haptics.onSubmitFailed();
        return h.fired.single == HabotHapticStrength.light &&
            HabotHaptics.strengthFor(HabotHapticMoment.submitFailed) !=
                HabotHaptics.strengthFor(HabotHapticMoment.submitSucceeded) &&
            HabotHapticMoment.values.every(
              (HabotHapticMoment m) =>
                  HabotHapticStrength.values.contains(
                    HabotHaptics.strengthFor(m),
                  ),
            );
      },
    );

    gate(
      'GEN-04506-G3',
      'A haptic on every outcome is a haptic on nothing: buzzing on every '
          'keystroke and step change turns the motor into background noise, '
          'and the one that matters becomes indistinguishable from the rest.',
      'The moments are a closed set of four, the things this app will NOT '
          'buzz on are named so that adding one is a visible change rather '
          'than a line in a widget, and no undeclared moment can fire',
      () =>
          HabotHapticMoment.values.length == 4 &&
          HabotHaptics.undeclaredMoments.isEmpty &&
          HabotHaptics.deliberatelySilent.length >= 5 &&
          HabotHaptics.deliberatelySilent.contains('every keystroke') &&
          HabotHaptics.deliberatelySilent.contains('a wizard step change') &&
          HabotHaptics.restraintNote.contains('background noise'),
    );

    gate(
      'GEN-04506-G4',
      'Haptics are unpleasant or painful for people with certain tremor, '
          'neuropathic and sensory conditions, and Flutter exposes no way to '
          'read the OS haptic setting -- so honouring it is not something this '
          'code can do implicitly.',
      'A preference exists, defaults to ON because the row asks for the '
          'feedback, and when it is off nothing reaches the platform at all -- '
          'not a silent call',
      () {
        final ({HabotHaptics haptics, List<HabotHapticStrength> fired}) on =
            build();
        final ({HabotHaptics haptics, List<HabotHapticStrength> fired}) off =
            build(enabled: false);
        off.haptics.onSubmitSucceeded();
        final bool silentWhileOff =
            off.fired.isEmpty && off.haptics.firedCount == 0;
        off.haptics.setEnabled(true);
        off.haptics.onSubmitSucceeded();
        return on.haptics.isEnabled &&
            silentWhileOff &&
            off.fired.single == HabotHapticStrength.medium &&
            HabotHaptics.preferenceNote.contains('no way to read the OS '
                'haptic setting');
      },
    );
  });

  group('GEN-04506 :: the metric, and why the ceiling is the tight end', () {
    gate(
      'GEN-04506-G5',
      'Metric: Floor <100ms, Optimal <50ms, Ceiling <16ms (one frame at '
          '60fps). The ceiling is the BEST value here, not the worst.',
      'The three bounds come from tokens rather than literals, they are '
          'ordered ceiling < optimal < floor, and an observed tap-to-haptic '
          'time is banded in the row own vocabulary',
      () =>
          HabotHaptics.frameBudget == HabotMotion.hapticFrameBudget &&
          HabotHaptics.optimal == HabotMotion.hapticLatencyOptimal &&
          HabotHaptics.floor == HabotMotion.hapticLatencyFloor &&
          HabotHaptics.frameBudget < HabotHaptics.optimal &&
          HabotHaptics.optimal < HabotHaptics.floor &&
          HabotHaptics.bandFor(const Duration(milliseconds: 8)) == 'Good' &&
          HabotHaptics.bandFor(const Duration(milliseconds: 40)) == 'Good' &&
          HabotHaptics.bandFor(const Duration(milliseconds: 80)) ==
              'Average' &&
          HabotHaptics.bandFor(const Duration(milliseconds: 250)) == 'Poor',
    );

    gate(
      'GEN-04506-G6',
      'One frame is reachable only by firing in the same frame as the state '
          'change. Any await before it -- including a one-line analytics call '
          '-- pushes it into the next frame, and no timing run on a fast '
          'machine reveals that.',
      'The call is synchronous and returns void, which is a property of the '
          'code rather than of a measurement, and the reasoning is recorded so '
          'nobody later makes it async for convenience',
      () {
        final ({HabotHaptics haptics, List<HabotHapticStrength> fired}) h =
            build();
        // The platform call has happened by the time the next statement runs.
        // An async implementation could not make this true.
        h.haptics.fire(HabotHapticMoment.destructiveConfirmed);
        final bool alreadyFired = h.fired.length == 1;
        return HabotHaptics.firesSynchronously &&
            alreadyFired &&
            h.fired.single == HabotHapticStrength.medium &&
            HabotHaptics.synchronousNote.contains('same frame as the state '
                'change') &&
            HabotHaptics.synchronousNote.contains('returns void');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04506',
        atomicStepReferenceId: 'GEN-04506',
        setupStepAction:
            'Bind success haptic profiles to completed form submission '
            'actions.',
        implementationOrder: 155,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotHaptics',
          'Component Properties':
              '${HabotHapticMoment.values.length} declared moments, '
              '${HabotHapticStrength.values.length} strengths, '
              '${HabotHaptics.deliberatelySilent.length} moments explicitly '
              'left silent; synchronous, void-returning fire()',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row, and the last of this batch. The ceiling '
              '(one frame) is tighter than the optimal, which is unusual and '
              'is why the gate checks a property of the call path rather than '
              'a timing.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Micro-interaction Response Latency',
            observed:
                'The platform call happens in the same synchronous run as the '
                'state change, which is the only way the '
                '${HabotMotion.hapticFrameBudget.inMilliseconds}ms one-frame '
                'ceiling is reachable. Checked as a property of the call path '
                'rather than as a timing: a haptic behind an await cannot land '
                'in the same frame however fast the device is, and no timing '
                'run on a fast machine would reveal it.',
            floor: '< 100ms',
            optimal: '< 50ms',
            ceiling: '< 16ms (1 frame @60fps)',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Moments this app buzzes on',
            observed:
                '4, declared as a closed set, with five more named as '
                'deliberately silent. A haptic on every outcome is a haptic on '
                'nothing: buzzing on every keystroke and step change turns the '
                'motor into background noise, at which point the submission -- '
                'the one the row is about -- is indistinguishable from the '
                'rest.',
            floor: '4',
            optimal: '4',
            ceiling: '4',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/haptics.dart',
        ],
      ),
    );
  });
}
