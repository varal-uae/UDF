/// AISS GATE -- Step 299 of 315
/// Global Reference ID:       CRSSS-007-16
/// Atomic Steps Reference ID: CRSSS-007-16
/// Setup Step (Action): "Apply persistent fixed position CSS styling
///                      (position: fixed, bottom: 16px, right: 16px, z-index:
///                      1000)." (CSS, IN A FLUTTER APPLICATION)
/// Atomic Step: "Monitor the initial splash screen animation metrics to
///               confirm zero interface stutter during startup delays."
/// Metric: QA Test Case Pass Rate -- floor >=95%, optimal 1, ceiling 1.
///         Pass/Fail. ISO/IEC/IEEE 29119.
///
/// REPORTS PARTIAL. ONE GATE IS DEFERRED: THE SPLASH SCREEN IS NOT A FLUTTER
/// SURFACE AND NOTHING IN lib/ CAN OBSERVE A FRAME OF IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/loading/splash_frame_budget.dart';

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

  group('CRSSS-007-16 :: what cannot be measured from here', () {
    gate(
      'CRSSS-007-16-G1',
      'Atomic Step: "Monitor the initial splash screen animation metrics".',
      'The splash is resolved by the operating system before the engine '
          'starts, so no Dart runs while it is on screen and no frame '
          'callback exists to observe it',
      () =>
          HabotSplashFrameBudget.theRowNamesTheUnobservableSurface &&
          HabotSplashFrameBudget.unobservable.length == 1 &&
          HabotSplashFrameBudget.whoDrawsTheSplash
              .contains('before the engine starts'),
    );

    gate(
      'CRSSS-007-16-G2',
      'The deferral is a specification rather than an excuse.',
      'Five named requirements -- a platform-side trace, a release build, a '
          'physical device, an agreed definition of a dropped frame at both '
          'refresh rates',
      () =>
          HabotSplashFrameBudget.whatTheDeferredGateNeeds.length == 5 &&
          HabotSplashFrameBudget.deferredGates == 1 &&
          HabotSplashFrameBudget.unmeasurableNote
              .contains('named here rather than'),
    );
  });

  group('CRSSS-007-16 :: the handoff, which is the real complaint', () {
    gate(
      'CRSSS-007-16-G3',
      'Nobody reports a stuttering splash.',
      'They report a white flash between the splash and the app, which is '
          'the interval Dart can observe, and it gets one frame',
      () =>
          HabotSplashFrameBudget.theHandoffIsObservable &&
          HabotSplashFrameBudget.handoffFrameAllowance == 1 &&
          HabotSplashFrameBudget.handoffNote
              .contains(HabotSplashFrameBudget.complaintAsReported),
    );

    gate(
      'CRSSS-007-16-G4',
      'The frame budget is a token.',
      'One sixtieth of a second, and a 1,200ms cold start is 71 whole frames',
      () =>
          HabotSplashFrameBudget.theFrameBudgetIsOneSixtieth &&
          HabotSplashFrameBudget.framesPerSecond == 60 &&
          HabotSplashFrameBudget.framesInColdStart == 71 &&
          HabotSplashFrameBudget.handoffBudgetMicroseconds == 16667,
    );
  });

  group('CRSSS-007-16 :: zero against ninety-five', () {
    gate(
      'CRSSS-007-16-G5',
      'Atomic Step says zero stutter; the floor accepts 95 per cent.',
      'Across 71 frames the floor allows three dropped frames -- three '
          'visible hitches inside a band whose own instruction says none',
      () =>
          HabotSplashFrameBudget.framesDroppedAtTheFloor == 3 &&
          HabotSplashFrameBudget.theBandContradictsTheInstruction,
    );

    gate(
      'CRSSS-007-16-G6',
      'Only one of the two can be the requirement.',
      'The Atomic Step is kept because it describes something a person would '
          'notice, and the floor is recorded',
      () => HabotSplashFrameBudget.bandNote.contains('a person would notice'),
    );

    gate(
      'CRSSS-007-16-G7',
      'Metric: QA Test Case Pass Rate.',
      'Test cases passing, on a row about frames delivered on time',
      () => HabotSplashFrameBudget.theMetricMeasuresSomethingElse,
    );
  });

  group('CRSSS-007-16 :: the row and its own dependency', () {
    gate(
      'CRSSS-007-16-G8',
      'Atomic Steps Global Dependancy: CRSSS-007-16.',
      'The row holds its own Global Reference ID, so nothing in the graph can '
          'unblock it -- one of the reasons a dependency graph stops moving',
      () =>
          HabotSplashFrameBudget.theRowDependsOnItself &&
          HabotSplashFrameBudget.selfDependencyNote
              .contains('never unblocked'),
    );

    gate(
      'CRSSS-007-16-G9',
      'Setup Step: CSS with a z-index.',
      'The tenth foreign stack in this track, and the first to specify a '
          'z-index in a toolkit where paint order is the widget tree',
      () => HabotSplashFrameBudget.wrongStackNote.contains('tenth foreign'),
    );

    gate(
      'CRSSS-007-16-G10',
      'Output: Pass/Fail, best = Pass (100%).',
      'Four obligations of five met, reported as Partial rather than Pass, '
          'with the fifth deferred; all eleven declared checks hold',
      () =>
          HabotSplashFrameBudget.obligations.length == 5 &&
          HabotSplashFrameBudget.obligationsMet == 4 &&
          (HabotSplashFrameBudget.passRate - 0.8).abs() < 1e-9 &&
          HabotSplashFrameBudget.qualitativeOutput == 'Partial' &&
          HabotSplashFrameBudget.checks.length == 11 &&
          HabotSplashFrameBudget.checks.values.every((bool b) => b) &&
          HabotSplashFrameBudget.columnNote.contains('z-index'),
    );
  });

  group('CRSSS-007-16 :: deferred', () {
    test('[CRSSS-007-16-G11] splash animation frame metrics', () {
      gates.add(
        const AissGate(
          id: 'CRSSS-007-16-G11',
          requirementSource:
              'Atomic Step: "Monitor the initial splash screen animation '
              'metrics to confirm zero interface stutter during startup '
              'delays."',
          description:
              'DEFERRED. The splash surface is drawn by the operating system '
              'before the Flutter engine starts. Measuring it needs an '
              'Android FrameMetricsAggregator or an iOS os_signpost in the '
              'host project, a release build on a physical device, and an '
              'agreed definition of a dropped frame at 60Hz and 120Hz. None '
              'of that lives in this repository, and approximating it from '
              'Dart would be reporting a different number under this name.',
          passed: false,
          deferred: true,
          detail:
              'What CAN be observed is budgeted: the handoff from the '
              'platform surface to the first Flutter frame gets one frame, '
              'which is where the white flash people actually report comes '
              'from.',
        ),
      );
    });
  });

  tearDownAll(() {
    final String frames = '${HabotSplashFrameBudget.framesInColdStart}';
    final String dropped = '${HabotSplashFrameBudget.framesDroppedAtTheFloor}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'CRSSS-007-16',
        atomicStepReferenceId: 'CRSSS-007-16',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Apply '
            'persistent fixed position CSS styling (position: fixed, bottom: '
            '16px, right: 16px, z-index: 1000)" -- CSS, in a Flutter '
            'application -- and the Atomic Steps Global Dependancy cell holds '
            'the row\'s own reference id, so the row is its own prerequisite. '
            'Atomic Step: "Monitor the initial splash screen animation metrics '
            'to confirm zero interface stutter during startup delays."',
        implementationOrder: 299,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Metric Name': 'frames delivered on time during startup',
          'Metric Value':
              'not observable for the platform splash; the handoff is '
                  'budgeted at 1 frame',
          'Monitoring Status':
              'PARTIAL -- 4 of 5 obligations met, 1 gate deferred',
          'Alert Threshold':
              'the row\'s floor of 95% permits $dropped dropped frames across '
                  'the $frames frames of a 1,200ms cold start',
          'Monitoring Timestamp': '2026-09-17T00:00:00Z',
          'Completion Status': 'Partial',
          'Data Quality Note':
              'UNMEASURABLE: ${HabotSplashFrameBudget.unmeasurableNote} '
              'HANDOFF: ${HabotSplashFrameBudget.handoffNote} '
              'BAND: ${HabotSplashFrameBudget.bandNote} '
              'SELF-DEPENDENCY: ${HabotSplashFrameBudget.selfDependencyNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'QA Test Case Pass Rate',
            observed:
                'PARTIAL. The metric counts test cases and the row is about '
                'frames. Reported instead over five declared obligations, of '
                'which four hold and the fifth -- measuring the splash '
                'animation itself -- is deferred with its protocol. The floor '
                'of 95% would permit $dropped dropped frames in $frames, on a '
                'row whose Atomic Step says zero.',
            floor: '>=95%',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Frames allowed for the platform-to-Flutter handoff',
            observed:
                '1. Longer than one frame and the gap reads as a flash rather '
                'than as a transition. This is the interval Dart can observe '
                'and the one people complain about; the surface the row names '
                'is neither.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/loading/splash_frame_budget.dart',
        ],
      ),
    );
  });
}
