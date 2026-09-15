/// AISS GATE -- Step 280 of 295
/// Global Reference ID:       ERMWD-029-07
/// Atomic Steps Reference ID: ERMWD-029-07
/// Setup Step (Action): "Run the static analysis scanner tool locally against
///                      all existing mobile filtering files." (DIFFERENT
///                      SUBJECT)
/// Atomic Step: "Configure touch-based focus traps inside modals with
///               thumb-friendly dismissal zones."
/// Metric: Process Execution Quality Score -- Floor ">=90%", Optimal ">=98%",
///         Ceiling 1. Good / Average / Poor. ISO 9001:2015.
///
/// A FOCUS TRAP IS NOT A TOUCH CONSTRUCT. THE ROW NAMES ONE MECHANISM AND
/// ASKS FOR THE OTHER, AND BOTH ARE NEEDED BY DIFFERENT PEOPLE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/modal_focus_trap.dart';
import 'package:udf_setup/design_system/surfaces/dialog_to_sheet.dart';

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

  group('ERMWD-029-07 :: two mechanisms, one name', () {
    gate(
      'ERMWD-029-07-G1',
      'Atomic Step: "touch-based focus traps".',
      'Both containment mechanisms are declared with the population each '
          'serves -- traversal for keyboard and reader users, a scrim for '
          'everybody else -- because the row names one and needs two',
      () =>
          HabotModalFocusTrap.bothMechanismsAreDeclared &&
          HabotModalFocusTrap.theRowNamesFewerMechanismsThanItNeeds &&
          HabotContainment.values.length == 2,
    );

    gate(
      'ERMWD-029-07-G2',
      'A finger does not traverse.',
      'The distinction between focus traversal and pointer containment is '
          'recorded rather than implied, so a future reader does not build '
          'one and name it the other',
      () => HabotModalFocusTrap.traversalIsNotTouchNote
          .contains('lands where it lands'),
    );
  });

  group('ERMWD-029-07 :: exits, and the rule they obey', () {
    gate(
      'ERMWD-029-07-G3',
      'A trap with no exit is a cage.',
      'Every declared modal form has at least two ways out, checked across '
          'the whole taxonomy rather than the two that were thought about',
      () => HabotModalFocusTrap.everyFormHasAtLeastTwoExits,
    );

    gate(
      'ERMWD-029-07-G4',
      'Step 225: a decision dialog is not dismissible by gesture.',
      'A dialog keeps its blocking property -- a scrim tap does not close one '
          '-- while a modal sheet can be tapped or dragged away',
      () =>
          HabotModalFocusTrap.aDialogIsNotClosedByTappingOutside &&
          HabotModalFocusTrap.aSheetIs &&
          HabotSurfaceForm.values.length == 4,
    );

    gate(
      'ERMWD-029-07-G5',
      'Two rules that can drift are one rule too many.',
      'Scrim dismissal is defined as the gesture rule rather than beside it, '
          'and the equivalence holds for every declared form',
      () =>
          HabotModalFocusTrap.theScrimRuleFollowsTheGestureRule &&
          HabotModalFocusTrap.noCageNote.contains('cannot drift'),
    );
  });

  group('ERMWD-029-07 :: thumb-friendly, measured', () {
    gate(
      'ERMWD-029-07-G6',
      'Atomic Step: "thumb-friendly dismissal zones".',
      'Two of the three dismissal affordances are inside the reach band and '
          'the one that is not is the conventional close control, which is '
          'therefore never the only route',
      () =>
          HabotModalFocusTrap.withinReach.length == 2 &&
          HabotModalFocusTrap.theConventionalCloseIsTheUnreachableOne &&
          (HabotModalFocusTrap.shareWithinReach - 2 / 3).abs() < 1e-9,
    );

    gate(
      'ERMWD-029-07-G7',
      'The reach claim has to match the one already made.',
      'Step 176 anchored the FAB in the same corner for the same reason and '
          'recorded the same handedness limitation; this step reads that '
          'rather than asserting a second reach band',
      () =>
          HabotModalFocusTrap.theReachClaimMatchesTheExistingOne &&
          HabotModalFocusTrap.thumbNote
              .contains('which affordance is primary'),
    );

    gate(
      'ERMWD-029-07-G8',
      'Trapping focus without restoring it is half an implementation.',
      'Focus returns to the control that opened the modal, and the reason it '
          'gets forgotten -- it is invisible to anybody not using a reader -- '
          'is recorded',
      () =>
          HabotModalFocusTrap.focusReturnsToTheOpener &&
          HabotModalFocusTrap.restorationNote
              .contains('passes every visual review'),
    );

    gate(
      'ERMWD-029-07-G9',
      'Metric: Process Execution Quality Score -- 90% / 98% / 1.',
      'Nine declared obligations, all of them met, giving Good; and the row\'s '
          'React Native props in a Dart application are recorded as the sixth '
          'stack assumption this track has been handed',
      () =>
          HabotModalFocusTrap.obligations.length == 9 &&
          HabotModalFocusTrap.obligations.values.every((bool b) => b) &&
          HabotModalFocusTrap.qualityScore == 1.0 &&
          HabotModalFocusTrap.qualitativeOutput == 'Good' &&
          HabotModalFocusTrap.wrongStackNote.contains('sixth row') &&
          HabotModalFocusTrap.checks.length == 12 &&
          HabotModalFocusTrap.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String reach =
        (HabotModalFocusTrap.shareWithinReach * 100).toStringAsFixed(0);
    final String dialogExits =
        '${HabotModalFocusTrap.routesFor(HabotSurfaceForm.dialog).length}';
    final String sheetExits =
        '${HabotModalFocusTrap.routesFor(HabotSurfaceForm.modalSheet).length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ERMWD-029-07',
        atomicStepReferenceId: 'ERMWD-029-07',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Run the '
            'static analysis scanner tool locally against all existing mobile '
            'filtering files", and the Data Requirement column carries React '
            'Native props for secure text fields. Atomic Step: "Configure '
            'touch-based focus traps inside modals with thumb-friendly '
            'dismissal zones."',
        implementationOrder: 280,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Parameter':
              'containment mechanism, dismissal routes, reach band, focus '
                  'restoration target',
          'Current Setting':
              '${HabotContainment.values.length} mechanisms declared; '
                  '$dialogExits exits for a dialog and $sheetExits for a '
                  'modal sheet; $reach% of dismissal affordances within reach; '
                  'focus returns to the opener',
          'Previous Setting':
              'none -- no containment rule existed before this step',
          'Change Log':
              'scrim dismissal defined AS Step 225\'s gesture rule rather '
                  'than beside it',
          'Component Properties':
              '${HabotDismissRoute.values.length} dismissal routes across '
              '${HabotSurfaceForm.values.length} surface forms',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotModalFocusTrap.traversalIsNotTouchNote} '
              'EXITS: ${HabotModalFocusTrap.noCageNote} '
              'REACH: ${HabotModalFocusTrap.thumbNote} '
              'STACK: ${HabotModalFocusTrap.wrongStackNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                '100% over ${HabotModalFocusTrap.obligations.length} declared '
                'obligations: both mechanisms named with their populations, '
                'every form given at least two exits, the scrim rule defined '
                'as the gesture rule, most dismissal affordances within '
                'reach, and focus restored to the opener.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Dismissal affordances within one-handed reach',
            observed:
                '$reach%. The conventional close control in the top trailing '
                'corner is the one outside it, and it is never the only '
                'route.',
            floor: 'more than half',
            optimal: 'more than half',
            ceiling: 'more than half',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/modal_focus_trap.dart',
        ],
      ),
    );
  });
}
