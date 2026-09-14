/// AISS GATE -- Step 192 of 195
/// Global Reference ID:       GEN-03503
/// Atomic Steps Reference ID: GEN-03503
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Position high-contrast M3 Action Buttons locked at the bottom
///               of mobile screens."
/// Metric: Bottom Lock Anchor Precision -- Floor 1, Optimal 1, Ceiling 1.
///         Pass.
///
/// "THE BOTTOM" IS NOT A NUMBER. There are three of them and they move: the
/// window, the safe area above the gesture bar, and the top of the keyboard. A
/// metric called Anchor Precision with 1 at every bound asks for the anchor to
/// be exactly right rather than approximately right.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/error_snackbar.dart';
import 'package:udf_setup/design_system/layout/bottom_action_bar.dart';
import 'package:udf_setup/design_system/tokens/button_role_map.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/tokens/touch_target_band.dart';

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

  // A modern handset: 34dp of gesture bar, keyboard closed.
  const HabotWindowInsets gestureBarOnly = HabotWindowInsets(
    viewPaddingBottom: 34,
    viewInsetsBottom: 0,
  );
  // The same handset with the keyboard up.
  const HabotWindowInsets keyboardOpen = HabotWindowInsets(
    viewPaddingBottom: 34,
    viewInsetsBottom: 336,
  );

  group('GEN-03503 :: the three bottoms', () {
    gate(
      'GEN-03503-G1',
      'Atomic Step: "...locked at the BOTTOM of mobile screens." Metric: '
          'Bottom Lock Anchor Precision, 1 at every bound.',
      'The anchor is computed from the window insets rather than padded by a '
          'number: with a gesture bar it is exactly the safe-area inset, with '
          'the keyboard open it is exactly the keyboard inset, and with '
          'neither it is zero rather than a defensive constant',
      () =>
          HabotBottomActionBar.anchorOffsetFor(gestureBarOnly) == 34 &&
          HabotBottomActionBar.anchorOffsetFor(keyboardOpen) == 336 &&
          HabotBottomActionBar.anchorOffsetFor(
                const HabotWindowInsets(
                  viewPaddingBottom: 0,
                  viewInsetsBottom: 0,
                ),
              ) ==
              0 &&
          HabotBottomActionBar.precisionNote
              .contains('the reviewer\'s phone'),
    );

    gate(
      'GEN-03503-G2',
      '"The system gesture area is behind the keyboard, so adding both would '
          'push the bar up by a home-indicator height of empty space."',
      'The two insets are not summed: the anchor is the larger of them, which '
          'is one rule rather than two and produces the right answer in both '
          'states',
      () =>
          HabotBottomActionBar.anchorOffsetFor(keyboardOpen) <
              gestureBarOnly.viewPaddingBottom +
                  keyboardOpen.viewInsetsBottom &&
          HabotBottomActionBar.anchorOffsetFor(keyboardOpen) ==
              keyboardOpen.viewInsetsBottom &&
          keyboardOpen.keyboardIsOpen &&
          !gestureBarOnly.keyboardIsOpen,
    );

    gate(
      'GEN-03503-G3',
      '"A button locked to the window bottom on a modern handset is a button '
          'the system swipe takes the tap for."',
      'The bar always clears the system intrusion, and its content is tall '
          'enough for a target at the Step 184 optimum with the declared inset '
          'above and below',
      () =>
          HabotBottomActionBar.occupiedHeightFor(gestureBarOnly) >
              gestureBarOnly.viewPaddingBottom &&
          HabotBottomActionBar.barContentHeight >=
              HabotTouchBand.optimalDp &&
          HabotBottomActionBar.barContentHeight ==
              HabotTouchBand.optimalDp +
                  (HabotBottomActionBar.contentInset * 2) &&
          HabotBottomActionBar.contentInset == HabotSpacing.md &&
          HabotBottomActionBar.threeBottomsNote
              .contains('goes to the background'),
    );
  });

  group('GEN-03503 :: the bar and its neighbours', () {
    gate(
      'GEN-03503-G4',
      'Step 154 removes the FAB when the keyboard opens. This bar does the '
          'opposite, and the divergence has to be a decision.',
      'The bar rises with the keyboard rather than hiding from it, and the '
          'reason is carried in the code: a FAB is a shortcut to something '
          'else, while the bar holds the primary action FOR the thing being '
          'typed into',
      () =>
          HabotBottomActionBar.rowsWithKeyboard &&
          HabotBottomActionBar.keyboardBehaviourRationale
              .contains('strands the user mid-form') &&
          HabotBottomActionBar.keyboardBehaviourRationale
              .contains('Step 154') &&
          HabotBottomActionBar.anchorOffsetFor(keyboardOpen) >
              HabotBottomActionBar.anchorOffsetFor(gestureBarOnly),
    );

    gate(
      'GEN-03503-G5',
      'MD3 places transient messages above persistent bottom elements. "A '
          'snackbar over the submit button is an error message obscuring the '
          'control that would fix the error."',
      'A snackbar is positioned above the whole occupied height of the bar, '
          'using the Step 68 reserved space, and the clearance check rejects a '
          'snackbar placed at the window bottom',
      () =>
          HabotBottomActionBar.snackbarBottomFor(keyboardOpen) ==
              HabotBottomActionBar.occupiedHeightFor(keyboardOpen) +
                  HabotSnackbarInsets.reservedBottomSpace &&
          HabotBottomActionBar.snackbarClearsBar(
            keyboardOpen,
            HabotBottomActionBar.snackbarBottomFor(keyboardOpen),
          ) &&
          !HabotBottomActionBar.snackbarClearsBar(keyboardOpen, 0) &&
          HabotBottomActionBar.snackbarNote.contains('fix the error'),
    );

    gate(
      'GEN-03503-G6',
      '"High-contrast M3 Action Buttons." Which roles those are is Step 188\'s '
          'map.',
      'The bar\'s actions are declared by what they do rather than by side, '
          'and the primary action\'s colour token is read from the button role '
          'map rather than chosen here -- so the bar survives a right-to-left '
          'locale without a second decision',
      () =>
          HabotBottomActionBar.actions.length == 2 &&
          HabotBottomActionBar.actions.contains(HabotButtonRole.confirm) &&
          HabotBottomActionBar.actions.contains(HabotButtonRole.dismiss) &&
          HabotBottomActionBar.primaryActionToken ==
              HabotButtonRoleMap.containerTokenFor(HabotButtonRole.confirm) &&
          HabotBottomActionBar.primaryActionToken ==
              'md.sys.color.primary' &&
          HabotBottomActionBar.surfaceRung == 'surfaceContainer',
    );

    gate(
      'GEN-03503-G7',
      'Metric: Bottom Lock Anchor Precision -- 1 at every bound, so a '
          'conjunction rather than a rate.',
      'Every precision condition holds, including the three constructed '
          'inset cases, so "locked at the bottom" is exact rather than '
          'approximately right on the device somebody happened to check',
      () =>
          HabotBottomActionBar.isPrecise &&
          HabotBottomActionBar.precisionChecks.length == 8 &&
          HabotBottomActionBar.precisionChecks.values.every((bool b) => b) &&
          HabotBottomActionBar.qualitativeOutput == 'Pass' &&
          HabotBottomActionBar.floor == 1 &&
          HabotBottomActionBar.ceiling == 1 &&
          HabotBottomActionBar.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03503',
        atomicStepReferenceId: 'GEN-03503',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Position high-contrast M3 Action Buttons locked at the '
            'bottom of mobile screens."',
        implementationOrder: 192,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotBottomActionBar / HabotWindowInsets',
          'Component Properties':
              'Anchor computed as the larger of the safe-area and keyboard '
              'insets; content height '
              '${HabotBottomActionBar.barContentHeight.toStringAsFixed(0)}dp '
              '(a ${HabotTouchBand.optimalDp.toStringAsFixed(0)}dp target plus '
              '${HabotBottomActionBar.contentInset.toStringAsFixed(0)}dp above '
              'and below); actions declared by role; snackbar placed above the '
              'occupied height',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'READING RECORDED: "the bottom" is three different things that '
              'move -- the window, the safe area above the gesture bar, and '
              'the top of the keyboard. A button locked to the window bottom '
              'is one the system swipe takes the tap for: the user presses '
              'Submit, the app goes to the background, and nothing about that '
              'reads as a layout bug. DIVERGENCE FROM STEP 154, DELIBERATE: '
              'the FAB hides from the keyboard and this bar rises with it. A '
              'FAB is a shortcut to something other than what the user is '
              'doing; the bar holds the primary action FOR the thing being '
              'typed into, and hiding it strands the user mid-form. The reason '
              'is carried in the code so the next person does not "fix" one to '
              'match the other.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Bottom Lock Anchor Precision',
            observed:
                'All ${HabotBottomActionBar.precisionChecks.length} conditions '
                'hold. With a 34dp gesture bar the anchor is exactly 34dp; '
                'with a 336dp keyboard it is exactly 336dp and does NOT add '
                'the safe area hidden behind it; with neither it is 0 rather '
                'than a defensive constant.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Clearance from neighbouring bottom elements',
            observed:
                'A snackbar is placed above the bar\'s full occupied height '
                'plus the Step 68 reserved space, and the clearance check '
                'rejects one placed at the window bottom. MD3 puts transient '
                'messages above persistent bottom elements; a snackbar over '
                'the submit button obscures the control that would fix the '
                'error it is reporting.',
            floor: 'snackbar above the bar',
            optimal: 'snackbar above the bar',
            ceiling: 'snackbar above the bar',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/bottom_action_bar.dart',
        ],
      ),
    );
  });
}
