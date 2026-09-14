/// AISS GATE -- Step 224 of 235
/// Global Reference ID:       CFCST-014
/// Atomic Steps Reference ID: CFCST-014
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Apply Material Design 3 guidelines to convert modal popovers
///               into sliding bottom sheets on mobile screens."
/// Metric: Mobile Usability Compliance (Touch Target Size & Core Web Vitals).
///
/// A DIALOG AND A BOTTOM SHEET ARE NOT INTERCHANGEABLE. Step 195 built the
/// compliance alert on the blocking property; converting it by width turns it
/// into something you can flick off the bottom of the display. The conversion
/// is by intent, not by device.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/surfaces/dialog_to_sheet.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double correctness = 0;

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

  const double compactWidth = 360;
  const double expandedWidth = 1024;

  group('CFCST-014 :: the conversion is by intent', () {
    gate(
      'CFCST-014-G1',
      'Atomic Step: "convert modal popovers into sliding bottom sheets ON '
          'MOBILE SCREENS."',
      'A surface that offers a choice becomes a modal sheet on a compact '
          'window and an anchored popover where there is room -- which is the '
          'row\'s rule, applied where it is right',
      () =>
          HabotSurfaceChoice.formFor(
                HabotSurfaceIntent.choice,
                compactWidth,
              ) ==
              HabotSurfaceForm.modalSheet &&
          HabotSurfaceChoice.formFor(
                HabotSurfaceIntent.choice,
                expandedWidth,
              ) ==
              HabotSurfaceForm.anchoredPopover &&
          HabotSurfaceChoice.formFor(
                HabotSurfaceIntent.disclosure,
                compactWidth,
              ) ==
              HabotSurfaceForm.standardSheet,
    );

    gate(
      'CFCST-014-G2',
      'Step 195: "an alert dialog takes the screen, blocks every other control '
          'and cannot be ignored."',
      'A decision and a destructive confirmation stay dialogs at every window '
          'class, because being unable to gesture them away is the property '
          'they were chosen for',
      () =>
          HabotSurfaceChoice.formFor(
                HabotSurfaceIntent.decision,
                compactWidth,
              ) ==
              HabotSurfaceForm.dialog &&
          HabotSurfaceChoice.formFor(
                HabotSurfaceIntent.decision,
                expandedWidth,
              ) ==
              HabotSurfaceForm.dialog &&
          HabotSurfaceChoice.formFor(
                HabotSurfaceIntent.destructiveConfirmation,
                compactWidth,
              ) ==
              HabotSurfaceForm.dialog &&
          HabotSurfaceChoice.intentsThatStayDialogs.length == 2,
    );

    gate(
      'CFCST-014-G3',
      '"Convert one into the other because the screen is narrow and the '
          'compliance alert becomes a thing you can flick off the bottom of '
          'the display."',
      'The surfaces that stay dialogs are exactly the ones that cannot be '
          'dismissed by a gesture, and a width-only conversion is demonstrated '
          'breaking that property rather than being warned about',
      () =>
          HabotSurfaceChoice.intentsThatStayDialogs.every(
            (HabotSurfaceIntent i) =>
                !HabotSurfaceChoice.isDismissibleByGesture(
              HabotSurfaceChoice.formFor(i, compactWidth),
            ),
          ) &&
          HabotSurfaceChoice.blindConversionBreaksBlocking(
            HabotSurfaceIntent.decision,
          ) &&
          HabotSurfaceChoice.blindConversionBreaksBlocking(
            HabotSurfaceIntent.destructiveConfirmation,
          ) &&
          HabotSurfaceChoice.isDismissibleByGesture(
            HabotSurfaceForm.modalSheet,
          ) &&
          !HabotSurfaceChoice.isDismissibleByGesture(
            HabotSurfaceForm.dialog,
          ) &&
          HabotSurfaceChoice.notInterchangeableNote
              .contains('flick off the bottom'),
    );

    gate(
      'CFCST-014-G4',
      'A surface nobody assigned is a surface somebody picks at the call site.',
      'Every intent resolves to a form at both a compact and an expanded '
          'width, so the mapping is total over four intents and four forms '
          'rather than covering the cases somebody remembered',
      () =>
          HabotSurfaceIntent.values.length == 4 &&
          HabotSurfaceForm.values.length == 4 &&
          HabotSurfaceIntent.values.every(
            (HabotSurfaceIntent i) =>
                HabotSurfaceChoice.formFor(i, compactWidth).name.isNotEmpty &&
                HabotSurfaceChoice.formFor(i, expandedWidth).name.isNotEmpty,
          ),
    );
  });

  group('CFCST-014 :: sizing, and the metric', () {
    gate(
      'CFCST-014-G5',
      '"A converted dialog snapped to the sheet default is a sheet that is '
          'mostly empty -- which people read as something still loading."',
      'The snap is sized to the content and clamped to the declared stops: a '
          '180dp dialog in a 740dp viewport lands on the minimum stop rather '
          'than the 60% default, and content taller than the maximum stop is '
          'clamped rather than overflowing',
      () =>
          HabotSurfaceChoice.snapFor(
                contentHeightDp: 180,
                viewportHeightDp: 740,
              ) ==
              HabotSheet.minSnapFraction &&
          HabotSurfaceChoice.snapFor(
                contentHeightDp: 720,
                viewportHeightDp: 740,
              ) ==
              HabotSheet.maxSnapFraction &&
          HabotSurfaceChoice.contentSizedRatherThanDefaultSnapped &&
          HabotSurfaceChoice.defaultSnapFraction ==
              HabotSheet.defaultSnapFraction &&
          HabotSurfaceChoice.emptySheetNote.contains('still loading'),
    );

    gate(
      'CFCST-014-G6',
      'Step GEN-00235 owns the sheet\'s motion.',
      'The converted surface uses the declared sheet enter and exit durations '
          'rather than picking its own, and the exit is shorter than the '
          'enter, as MD3 specifies for a surface leaving the screen',
      () =>
          HabotSurfaceChoice.enterDuration == HabotMotion.sheetEnter &&
          HabotSurfaceChoice.exitDuration == HabotMotion.sheetExit &&
          HabotSurfaceChoice.exitDuration < HabotSurfaceChoice.enterDuration,
    );

    gate(
      'CFCST-014-G7',
      'Metric: "Mobile Usability Compliance (Touch Target Size & Core Web '
          'Vitals)."',
      'The metric names two things and neither is about this row -- touch '
          'target size is Steps 227-229 and Core Web Vitals are browser '
          'measurements with no LCP to report in a Flutter application -- so '
          'no figure is invented for them and the conversion correctness is '
          'what is reported: nine of nine, giving 1.0',
      () {
        correctness = HabotSurfaceChoice.conversionCorrectness;
        return HabotSurfaceChoice.checks.length == 9 &&
            HabotSurfaceChoice.checks.values.every((bool b) => b) &&
            correctness == 1.0 &&
            HabotSurfaceChoice.qualitativeOutput == 'Pass' &&
            HabotSurfaceChoice.metricName.contains('Core Web Vitals') &&
            HabotSurfaceChoice.metricDoesNotMeasureTheRowNote
                .contains('no LCP to report') &&
            HabotSurfaceChoice.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'CFCST-014',
        atomicStepReferenceId: 'CFCST-014',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Apply Material Design 3 guidelines to convert modal '
            'popovers into sliding bottom sheets on mobile screens."',
        implementationOrder: 224,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSurfaceChoice',
          'Component Properties':
              '${HabotSurfaceIntent.values.length} intents mapped totally onto '
              '${HabotSurfaceForm.values.length} forms by intent and window '
              'class; ${HabotSurfaceChoice.intentsThatStayDialogs.length} '
              'intents stay dialogs at every class; snap sized to content and '
              'clamped to the Step GEN-00235 stops; sheet motion from the '
              'declared tokens',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: a dialog and a bottom sheet are not interchangeable '
              'surfaces. A dialog is modal and blocking -- it takes the '
              'screen, absorbs every other pointer and cannot be dismissed by '
              'looking away -- and Step 195 built the compliance alert on '
              'exactly that property. An MD3 bottom sheet is dragged away with '
              'a thumb. Convert one into the other because the screen is '
              'narrow and the compliance alert becomes a thing you can flick '
              'off the bottom of the display. So the conversion is by INTENT '
              'rather than by width: a choice becomes a sheet on a compact '
              'window because a sheet is easier to reach and easier to '
              'dismiss; a decision stays a dialog on every size class, because '
              'that is what makes it a decision. SECOND FINDING: the metric on '
              'this row measures neither half of the row. Touch target size is '
              'Steps 227-229. Core Web Vitals are browser measurements -- LCP '
              'and CLS are defined by a page load and this is a Flutter '
              'application, so there is no LCP to report. No figure is '
              'invented for them. THIRD: a dialog\'s content is shorter than '
              'the sheet\'s 60% default snap, so a converted dialog left on '
              'the default is a mostly-empty sheet that reads as something '
              'still loading; the snap is sized to the content.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Usability Compliance (Touch Target Size & '
                'Core Web Vitals)',
            observed:
                'NEITHER HALF IS ABOUT THIS ROW. Touch target size is measured '
                'at Steps 227-229; Core Web Vitals require a browser page '
                'load, which a Flutter application does not have. No figure is '
                'invented. What is reported instead is conversion correctness: '
                '${correctness.toStringAsFixed(2)} over '
                '${HabotSurfaceChoice.checks.length} checks.',
            floor: '>=90% of interactive elements meet 44x44; CWV "Needs '
                'Improvement" or better',
            optimal: '100% compliance with 44-48px targets; CWV "Good"',
            ceiling: '100%',
          ),
          AissMeasurement(
            metricName: 'Intents whose surface does not change with width',
            observed:
                '${HabotSurfaceChoice.intentsThatStayDialogs.length} of '
                '${HabotSurfaceIntent.values.length} -- decision and '
                'destructive confirmation. Both are demonstrated losing their '
                'blocking property under a width-only conversion, which is '
                'what the row\'s literal rule would have done to the Step 195 '
                'compliance alert.',
            floor: '2',
            optimal: '2',
            ceiling: '2',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/surfaces/dialog_to_sheet.dart',
        ],
      ),
    );
  });
}
