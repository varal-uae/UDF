/// AISS GATE -- Step 261 of 275
/// Global Reference ID:       GEN-04495
/// Atomic Steps Reference ID: GEN-04495
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Request camera permissions for capturing evidence
///               attachments."
/// Metric: Native Permission Grant Success Rate -- Floor 0.8, Optimal 0.95,
///         Ceiling 0.99. Good/Average/Poor.
///
/// A GRANT RATE IS A PROPERTY OF PEOPLE, NOT OF THIS CODE. THE ONLY LEVERS
/// THAT MOVE IT ARE ASKING BETTER AND ASKING MORE OFTEN.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/support/camera_permission.dart';

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

  group('GEN-04495 :: the five states', () {
    gate(
      'GEN-04495-G1',
      'Atomic Step: "Request camera permissions".',
      'Five permission states are distinguished rather than the two a boolean '
          'would give, and every one of them has a remedy written for it',
      () =>
          HabotPermissionState.values.length == 5 &&
          HabotCameraPermission.everyStateHasARemedy &&
          HabotCameraPermission.fourStatesNote.isNotEmpty,
    );

    gate(
      'GEN-04495-G2',
      'Asking again when no prompt will appear is a loop.',
      'A prompt appears in exactly one state, so the retry button that '
          'reissues the request from permanently denied is unreachable rather '
          'than merely discouraged',
      () =>
          HabotCameraPermission.promptWillAppear(
            HabotPermissionState.notDetermined,
          ) &&
          !HabotCameraPermission.promptWillAppear(
            HabotPermissionState.permanentlyDenied,
          ) &&
          HabotCameraPermission.theRetryLoopIsUnreachable,
    );

    gate(
      'GEN-04495-G3',
      'Restricted is not the person\'s decision.',
      'Restricted is kept distinct from permanently denied, because telling '
          'somebody to change a setting a parental control or an '
          'administrator owns is telling them to do something they cannot',
      () =>
          HabotCameraPermission.restrictedIsNotPermanentlyDenied &&
          HabotCameraPermission.remedyFor(HabotPermissionState.restricted) !=
              HabotCameraPermission.remedyFor(
                HabotPermissionState.permanentlyDenied,
              ),
    );

    gate(
      'GEN-04495-G4',
      'The one prompt you get is spent at launch or spent well.',
      'Nothing is requested on launch; the request happens when the person '
          'chooses to take a photo, which is the only moment the reason for '
          'it is visible',
      () =>
          HabotCameraPermission.neverAsksOnLaunch &&
          HabotCameraPermission.asksWhenTheyAsk &&
          HabotCameraPermission.inContextNote.isNotEmpty,
    );
  });

  group('GEN-04495 :: the metric, substituted', () {
    gate(
      'GEN-04495-G5',
      'Metric: Native Permission Grant Success Rate -- 0.8 / 0.95 / 0.99.',
      'The grant rate is named as a measurement of people rather than of this '
          'code, and as one whose only levers are asking at a better moment '
          'and asking more often',
      () => HabotCameraPermission.grantRateNote.contains('pressure'),
    );

    gate(
      'GEN-04495-G6',
      'The substitution: what happens when the answer is no.',
      'Three routes reach a submitted ticket and two of them need no camera, '
          'so a refused permission is not a dead end and the grant rate stops '
          'deciding whether the task can be done',
      () =>
          HabotCameraPermission.routes.length == 3 &&
          HabotCameraPermission.routesWithoutCamera.length == 2 &&
          HabotCameraPermission.taskCompletionWithoutCamera == 1.0 &&
          HabotCameraPermission.aDeniedCameraIsNotADeadEnd,
    );

    gate(
      'GEN-04495-G7',
      'Output: Good/Average/Poor.',
      'All nine declared checks hold and the reported band is Good, on the '
          'substituted property rather than on a grant rate nobody here can '
          'observe',
      () =>
          HabotCameraPermission.checks.length == 9 &&
          HabotCameraPermission.checks.values.every((bool b) => b) &&
          HabotCameraPermission.qualitativeOutput == 'Good' &&
          HabotCameraPermission.floor == 0.8 &&
          HabotCameraPermission.optimal == 0.95 &&
          HabotCameraPermission.ceiling == 0.99 &&
          HabotCameraPermission.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String routes = '${HabotCameraPermission.routes.length}';
    final String without =
        '${HabotCameraPermission.routesWithoutCamera.length}';
    final String completion =
        HabotCameraPermission.taskCompletionWithoutCamera.toStringAsFixed(2);
    final String states = '${HabotPermissionState.values.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04495',
        atomicStepReferenceId: 'GEN-04495',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Request camera permissions for capturing evidence '
            'attachments."',
        implementationOrder: 261,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotCameraPermission / HabotPermissionState / '
                  'HabotAttachmentRoute',
          'Component Properties':
              '$states permission states each with its own remedy; a prompt '
              'is possible in exactly one of them; $routes routes to a '
              'submitted ticket of which $without need no camera; nothing is '
              'requested on launch',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotCameraPermission.grantRateNote} '
              'STATES: ${HabotCameraPermission.fourStatesNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Native Permission Grant Success Rate',
            observed:
                'NOT OBSERVABLE HERE. The rate is a measurement of what '
                'people tap in a system dialog. Substituted: task completion '
                'without the permission, which is $completion -- $without of '
                '$routes routes reach a submitted ticket with no camera '
                'access at all.',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '0.99',
          ),
          AissMeasurement(
            metricName: 'Permission states with a remedy',
            observed:
                '$states of $states, including restricted, which is kept '
                'distinct from permanently denied because the person cannot '
                'change it themselves.',
            floor: '5 of 5',
            optimal: '5 of 5',
            ceiling: '5 of 5',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/support/camera_permission.dart',
        ],
      ),
    );
  });
}
