/// AISS GATE -- Step 248 of 255
/// Global Reference ID:       HC-CMP-0054
/// Atomic Steps Reference ID: HC-CMP-0054
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure the glaring red badge and disrupted sort order to
///               create visual friction."
/// Metric: UI Hesitation/Friction Detection Threshold -- Floor ">3 sec dwell",
///         Optimal ">5 sec dwell", Ceiling ">10 sec dwell". High/Medium/Low.
///         Standard cited: Nielsen Norman Group response-time heuristics.
///
/// REPORTS PARTIAL. One of the row's three asks is built and scoped to actions
/// that cannot be undone; the disrupted sort order is refused outright and the
/// colour-only badge is refused as specified.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/validation_state_color.dart';
import 'package:udf_setup/design_system/interaction/deliberate_friction.dart';

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

  group('HC-CMP-0054 :: what is refused', () {
    gate(
      'HC-CMP-0054-G1',
      'Atomic Step: "DISRUPTED SORT ORDER to create visual friction."',
      'Refused outright. A list\'s order is a promise, and the cost of '
          'breaking it does not land evenly -- a person navigating by '
          'position, with a screen reader or switch control or from memory, '
          'pays more than the person the friction was aimed at',
      () =>
          !HabotDeliberateFriction.rulingFor(
            HabotFrictionDevice.sortOrderDisruption,
          ).permitted &&
          HabotDeliberateFriction.rulingFor(
                HabotFrictionDevice.sortOrderDisruption,
              ).scope ==
              '' &&
          HabotDeliberateFriction.rulingFor(
            HabotFrictionDevice.sortOrderDisruption,
          ).reason.contains('confusion is a pause they do not'),
    );

    gate(
      'HC-CMP-0054-G2',
      'Atomic Step: "the GLARING RED BADGE."',
      'Refused as specified and reinstated with four cues. A badge that is red '
          'and nothing else conveys meaning by hue alone, which fails WCAG 2.1 '
          'SC 1.4.1 -- and the required cues are read from the existing error '
          'state rather than restated here',
      () =>
          !HabotDeliberateFriction.rulingFor(
            HabotFrictionDevice.colourOnlyBadge,
          ).permitted &&
          HabotDeliberateFriction.theRowsBadgeWouldCarryOne &&
          HabotDeliberateFriction.aWarningCarriesMoreThanColour &&
          HabotDeliberateFriction.requiredCues.length == 4 &&
          HabotDeliberateFriction.requiredCues
              .contains(HabotStateCarrier.semantics),
    );

    gate(
      'HC-CMP-0054-G3',
      'Step 249 is asked for a deliberately slowed progress bar by name.',
      'Five devices are ruled on and three are refused, each with an argument '
          'rather than an omission, and each scoped to nowhere -- including '
          'fake progress, so the two steps are one ruling rather than two '
          'opinions',
      () =>
          HabotDeliberateFriction.rulings.length == 5 &&
          HabotDeliberateFriction.refusedDevices.length == 3 &&
          HabotDeliberateFriction.everyRefusalIsArgued &&
          !HabotDeliberateFriction.rulingFor(
            HabotFrictionDevice.fakeProgress,
          ).permitted,
    );
  });

  group('HC-CMP-0054 :: what is built', () {
    gate(
      'HC-CMP-0054-G4',
      'Step 224: a destructive confirmation stays a dialog at every window '
          'class.',
      'A pause is permitted only where the action cannot be undone, and no '
          'permitted scope is a commercial one -- friction that exists to '
          'change what somebody buys is not a safeguard',
      () =>
          HabotDeliberateFriction.pauseIsPermittedFor(
            actionIsIrreversible: true,
          ) &&
          !HabotDeliberateFriction.pauseIsPermittedFor(
            actionIsIrreversible: false,
          ) &&
          HabotDeliberateFriction.noPermittedScopeIsCommercial &&
          HabotDeliberateFriction.everyPermissionIsScoped &&
          HabotDeliberateFriction.permittedDevices.length == 2,
    );

    gate(
      'HC-CMP-0054-G5',
      'Metric: floor ">3 sec", optimal ">5 sec", ceiling ">10 sec".',
      'The band is monotone over the three declared tokens -- three seconds is '
          'Low, five is Medium, ten is High -- and it is applied only to the '
          'confirmation surface, because on a booking screen the same five '
          'seconds means the person cannot find what they came for',
      () =>
          HabotDeliberateFriction.bandIsMonotone &&
          HabotDeliberateFriction.dwellFloor.inSeconds == 3 &&
          HabotDeliberateFriction.dwellOptimal.inSeconds == 5 &&
          HabotDeliberateFriction.dwellCeiling.inSeconds == 10 &&
          HabotDeliberateFriction.metricAppliesOnlyHereNote
              .contains('came for'),
    );

    gate(
      'HC-CMP-0054-G6',
      'Read literally, the best possible outcome is a person who never acts.',
      'Past the ceiling the person is not deciding, they are stuck, and that '
          'case is named rather than graded as an even better result',
      () =>
          HabotDeliberateFriction.dwellIsStuckRatherThanDeciding(
            HabotDeliberateFriction.dwellCeiling * 2,
          ) &&
          !HabotDeliberateFriction.dwellIsStuckRatherThanDeciding(
            HabotDeliberateFriction.dwellOptimal,
          ) &&
          HabotDeliberateFriction.ceilingIsNotBetterNote
              .contains('rather than as a success'),
    );

    gate(
      'HC-CMP-0054-G7',
      'UI Hesitation/Friction Detection Threshold -- High/Medium/Low.',
      'All eleven checks hold and the step reports PARTIAL: one of the row\'s '
          'three asks is delivered and measured on the row\'s own band, and a '
          'Complete here would have meant a list that reorders itself to '
          'confuse people',
      () =>
          HabotDeliberateFriction.checks.length == 11 &&
          HabotDeliberateFriction.checks.values.every((bool b) => b) &&
          HabotDeliberateFriction.qualitativeOutput == 'Partial' &&
          (HabotDeliberateFriction.deliveryRate - 1 / 3).abs() < 1e-9 &&
          HabotDeliberateFriction.partialNote
              .contains('no metric is worth that') &&
          HabotDeliberateFriction.columnNote.contains('no Setup Step'),
    );
  });

  tearDownAll(() {
    final String sortOrderReason = HabotDeliberateFriction
        .rulingFor(HabotFrictionDevice.sortOrderDisruption)
        .reason;
    final String badgeReason = HabotDeliberateFriction
        .rulingFor(HabotFrictionDevice.colourOnlyBadge)
        .reason;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HC-CMP-0054',
        atomicStepReferenceId: 'HC-CMP-0054',
        setupStepAction:
            'COLUMN NOTE: this row carries no Setup Step, no Expected Output '
            'and no Completion Measures -- only a metric and a Data Collected '
            'list about configuration changes. Atomic Step: "Configure the '
            'glaring red badge and disrupted sort order to create visual '
            'friction."',
        implementationOrder: 248,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDeliberateFriction / HabotFrictionRuling',
          'Component Properties':
              '${HabotDeliberateFriction.rulings.length} friction devices '
              'ruled on, ${HabotDeliberateFriction.permittedDevices.length} '
              'permitted with a scope and '
              '${HabotDeliberateFriction.refusedDevices.length} refused with '
              'an argument; a dwell band over three declared tokens, applied '
              'only to a confirmation before an irreversible action',
          'Completion Status': 'PARTIAL -- see note',
          'Data Quality Note':
              'REPORTED PARTIAL. ${HabotDeliberateFriction.partialNote} '
              'REFUSED (sort order): '
              '$sortOrderReason '
              'REFUSED (colour-only badge): '
              '$badgeReason '
              'BUILT: ${HabotDeliberateFriction.metricAppliesOnlyHereNote} '
              'CEILING: ${HabotDeliberateFriction.ceilingIsNotBetterNote} '
              'SCOPE: ${HabotDeliberateFriction.commercialFrictionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Hesitation/Friction Detection Threshold',
            observed:
                'Applied to the confirmation surface only, where a pause is '
                'the point. Monotone over the declared tokens: '
                '${HabotDeliberateFriction.dwellFloor.inSeconds}s is Low, '
                '${HabotDeliberateFriction.dwellOptimal.inSeconds}s is '
                'Medium, ${HabotDeliberateFriction.dwellCeiling.inSeconds}s '
                'is High. Beyond the ceiling the surface is reported as one '
                'to look at rather than as a better result.',
            floor: '>3 sec dwell',
            optimal: '>5 sec dwell',
            ceiling: '>10 sec dwell',
          ),
          AissMeasurement(
            metricName: 'Devices the row asked for that were delivered',
            observed:
                '1 of ${HabotDeliberateFriction.devicesTheRowAsksFor}. The '
                'friction is built and scoped; the glaring red badge is '
                'refused as specified and reinstated with four cues; the '
                'disrupted sort order is refused outright.',
            floor: '3 of 3',
            optimal: '3 of 3',
            ceiling: '3 of 3',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/deliberate_friction.dart',
        ],
      ),
    );
  });
}
