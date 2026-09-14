/// AISS GATE -- Step 222 of 235
/// Global Reference ID:       ARCPE-016-14
/// Atomic Steps Reference ID: ARCPE-016-14
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Verify the panels stack vertically without overlapping layout
///               items on mobile screens."
/// Metric: Verification Assertion Accuracy -- Floor 0.95, Optimal 0.99,
///         Ceiling 1. Pass/Fail.
///
/// OVERLAP IS NOT THE FAILURE MODE. A Flutter Column does not overlap its
/// children, it overflows them -- a debug stripe, and in release a pane
/// silently clipped at the bottom edge. A verification written against overlap
/// passes on every build and catches nothing.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/layout/pane_overflow_check.dart';
import 'package:udf_setup/design_system/layout/pane_split.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double accuracy = 0;

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

  group('ARCPE-016-14 :: what the assertion is about', () {
    gate(
      'ARCPE-016-14-G1',
      'Atomic Step: "verify the panels stack vertically WITHOUT OVERLAPPING '
          'layout items."',
      'The assertion is a height budget rather than an overlap check, because '
          'a Column overflows rather than overlapping -- and an overflow is a '
          'stripe in debug and a silent clip in release, which is the build '
          'that ships',
      () =>
          HabotPaneOverflowCheck.overlapIsNotTheFailureNote
              .contains('silently clipped') &&
          HabotPaneOverflowCheck.overlapIsNotTheFailureNote
              .contains('catches nothing') &&
          HabotPaneOverflowCheck.requiredHeight(
                HabotPaneOverflowCheck.peerStack,
              ) ==
              520,
    );

    gate(
      'ARCPE-016-14-G2',
      'The budget has to include what the screen always has before any pane '
          'gets anything.',
      'Chrome is counted into the requirement and the keyboard is subtracted '
          'from what is available, so the two sides of the comparison are the '
          'ones a running screen actually has',
      () {
        final HabotFitResult dry = HabotPaneOverflowCheck.evaluate(
          panes: HabotPaneOverflowCheck.peerStack,
          device: HabotPaneOverflowCheck.shortestPhone,
          keyboardOpen: false,
        );
        final HabotFitResult wet = HabotPaneOverflowCheck.evaluate(
          panes: HabotPaneOverflowCheck.peerStack,
          device: HabotPaneOverflowCheck.shortestPhone,
          keyboardOpen: true,
        );
        return dry.availableDp == 568 &&
            wet.availableDp == 232 &&
            dry.requiredDp == 520 &&
            wet.requiredDp == 520 &&
            dry.fits &&
            !wet.fits &&
            dry.marginDp == 48 &&
            wet.marginDp == -288 &&
            HabotPaneOverflowCheck.chromeHeightDp == 120 &&
            HabotPaneOverflowCheck.keyboardInsetDp == 336;
      },
    );

    gate(
      'ARCPE-016-14-G3',
      '"Checking the budget with the keyboard closed checks the state the '
          'screen is not in while anyone is using it."',
      'The same composition fits on every declared phone with the keyboard '
          'closed and fails on five of the six with it open, which is the '
          'difference the row\'s wording would have hidden',
      () {
        final List<HabotFitResult> closed =
            HabotPaneOverflowCheck.failures(
          HabotPaneOverflowCheck.peerStack,
          keyboardOpen: false,
        );
        final List<HabotFitResult> open = HabotPaneOverflowCheck.failures(
          HabotPaneOverflowCheck.peerStack,
          keyboardOpen: true,
        );
        return closed.isEmpty &&
            open.length == 5 &&
            HabotPaneOverflowCheck.phones.length == 6 &&
            HabotPaneOverflowCheck.keyboardIsTheCaseNote
                .contains('320x568');
      },
    );

    gate(
      'ARCPE-016-14-G4',
      'A pinned element is the thing a stack is most often asked to absorb.',
      'Adding a 72dp totals bar that cannot scroll breaks the budget on the '
          'shortest phone with the keyboard closed -- so the composition is '
          'refused before anyone opens a field',
      () {
        final HabotFitResult r = HabotPaneOverflowCheck.evaluate(
          panes: HabotPaneOverflowCheck.peerStackWithPinnedSummary,
          device: HabotPaneOverflowCheck.shortestPhone,
          keyboardOpen: false,
        );
        return !r.fits &&
            r.requiredDp == 592 &&
            r.marginDp == -24 &&
            HabotPaneOverflowCheck.peerStackWithPinnedSummary.length == 3 &&
            !HabotPaneOverflowCheck.peerStackWithPinnedSummary.last
                .scrollsInternally;
      },
    );
  });

  group('ARCPE-016-14 :: the assertion is accurate both ways', () {
    gate(
      'ARCPE-016-14-G5',
      'An assertion that fires on everything is as useless as one that fires '
          'on nothing.',
      'The check stays quiet on the composition that fits and fires on the two '
          'that do not, and the composition that fails is told to stop '
          'stacking rather than to shrink a pane below its minimum',
      () =>
          !HabotPaneOverflowCheck.mustStopStacking(
            HabotPaneOverflowCheck.peerStack,
            keyboardOpen: false,
          ) &&
          HabotPaneOverflowCheck.mustStopStacking(
            HabotPaneOverflowCheck.peerStack,
            keyboardOpen: true,
          ) &&
          HabotPaneOverflowCheck.mustStopStacking(
            HabotPaneOverflowCheck.peerStackWithPinnedSummary,
            keyboardOpen: false,
          ),
    );

    gate(
      'ARCPE-016-14-G6',
      '"Mobile screens" is a set, not a device.',
      'The check runs across every declared phone rather than one, and the '
          'shortest of them -- the 320x568 handset -- is the one the verdict '
          'turns on, because a budget evaluated on a tall phone is a budget '
          'that passes',
      () =>
          HabotPaneOverflowCheck.evaluateAcrossPhones(
                HabotPaneOverflowCheck.peerStack,
                keyboardOpen: false,
              ).length ==
              HabotPaneOverflowCheck.phones.length &&
          HabotPaneOverflowCheck.shortestPhone.heightDp == 568 &&
          HabotPaneOverflowCheck.shortestPhone.widthDp == 320 &&
          HabotPaneOverflowCheck.phones.every(
            (HabotDeviceProfile d) => d.deviceType == HabotDeviceType.phone,
          ),
    );

    gate(
      'ARCPE-016-14-G7',
      'Metric: Verification Assertion Accuracy -- floor 0.95, optimal 0.99. '
          'Pass/Fail.',
      'All six assertion checks hold, giving 1.0 and a Pass, and the pane '
          'minimums are read from Step 218\'s declared usable extent rather '
          'than invented for this check',
      () {
        accuracy = HabotPaneOverflowCheck.assertionAccuracy;
        return HabotPaneOverflowCheck.assertionChecks.length == 6 &&
            HabotPaneOverflowCheck.assertionChecks.values
                .every((bool b) => b) &&
            accuracy == 1.0 &&
            accuracy >= HabotPaneOverflowCheck.floor &&
            HabotPaneOverflowCheck.qualitativeOutput == 'Pass' &&
            HabotPaneOverflowCheck.peerStack.every(
              (HabotStackedPane p) =>
                  p.minimumHeightDp == HabotPaneSplit.minimumUsablePaneDp,
            ) &&
            HabotPaneOverflowCheck.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ARCPE-016-14',
        atomicStepReferenceId: 'ARCPE-016-14',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Verify the panels stack vertically without overlapping '
            'layout items on mobile screens."',
        implementationOrder: 222,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPaneOverflowCheck / HabotFitResult',
          'Component Properties':
              'Height budget over '
              '${HabotPaneOverflowCheck.phones.length} declared phones in two '
              'keyboard states; chrome '
              '${HabotPaneOverflowCheck.chromeHeightDp.toStringAsFixed(0)}dp, '
              'keyboard inset '
              '${HabotPaneOverflowCheck.keyboardInsetDp.toStringAsFixed(0)}dp; '
              'pane minimums read from the Step 218 usable extent',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: overlap is not the failure mode. A Flutter Column does '
              'not overlap its children, it OVERFLOWS them -- a '
              'yellow-and-black stripe in a debug build, and in a release '
              'build a pane silently clipped at the bottom edge, which is the '
              'version that ships. A verification written against overlap '
              'passes on every build and catches nothing. The assertion is a '
              'height budget instead: every pane minimum, plus the chrome the '
              'screen always has, plus the keyboard when it is open, against '
              'the shortest declared device. MEASURED: two scrolling peer '
              'panes need 520dp and the shortest handset offers 568 with the '
              'keyboard closed -- 48dp of margin -- and 232 with it open, '
              'which is 288dp short. The composition fits on all six declared '
              'phones closed and fails on five of the six open. Adding a 72dp '
              'pinned totals bar breaks it on the shortest phone before anyone '
              'opens a field. The keyboard state is the one that matters, '
              'because a booking form spends most of its life in it.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Verification Assertion Accuracy',
            observed:
                '${accuracy.toStringAsFixed(2)} over '
                '${HabotPaneOverflowCheck.assertionChecks.length} cases: the '
                'assertion stays quiet on the composition that fits and fires '
                'on the two that do not, across every declared phone rather '
                'than one.',
            floor: '0.95',
            optimal: '0.99',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Height margin on the shortest declared phone',
            observed:
                '+48dp with the keyboard closed, -288dp with it open, and '
                '-24dp closed once a 72dp pinned bar is added. Reported as '
                'signed margins rather than as pass/fail, because the number '
                'is what says how much room a future change has.',
            floor: '0dp',
            optimal: '>=48dp',
            ceiling: 'n/a',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/pane_overflow_check.dart',
        ],
      ),
    );
  });
}
