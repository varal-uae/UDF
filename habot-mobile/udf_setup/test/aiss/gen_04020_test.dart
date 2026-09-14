/// AISS GATE -- Step 246 of 255
/// Global Reference ID:       GEN-04020
/// Atomic Steps Reference ID: GEN-04020
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Create client-side event listeners (onFocus, onBlur,
///               onChange) for mobile input components."
/// Metric: Mobile Form Event Listener Coverage -- Floor 1, Optimal 1, Ceiling
///         1. Pass/Fail. Standard cited: W3C DOM Event Standard.
///
/// THREE DOM NAMES, THREE FLUTTER MECHANISMS AND FOUR MOMENTS. The counts do
/// not line up, and the moment that matters is the one the row has no name for.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/field_lifecycle_events.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double moments = 0;

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

  group('GEN-04020 :: the substitution', () {
    gate(
      'GEN-04020-G1',
      'Standard cited: W3C DOM Event Standard.',
      'Flutter has no DOM events: onFocus and onBlur are two transitions of '
          'one FocusNode observed by one listener, and onChange is two '
          'different mechanisms -- so coverage is measured over moments rather '
          'than over a listener count that would be right about another '
          'platform',
      () =>
          HabotFieldLifecycleEvents.theCountsDoNotLineUp &&
          HabotListenerMechanism.values.length == 3 &&
          HabotFieldLifecycleEvents.substitutionNote
              .contains('no DOM events'),
    );

    gate(
      'GEN-04020-G2',
      'Atomic Step lists onFocus, onBlur and onChange.',
      'All three names are bound and all four moments a field can be in are '
          'bound, so the row\'s own count and the honest one both reach 1.0',
      () {
        moments = HabotFieldLifecycleEvents.momentCoverage;
        return HabotFieldLifecycleEvents.domEventCoverage == 1.0 &&
            HabotFieldLifecycleEvents.everyMomentIsBound &&
            moments == 1.0 &&
            HabotFieldMoment.values.length == 4;
      },
    );

    gate(
      'GEN-04020-G3',
      'Step 239: a controller rewritten by a formatter does not fire '
          'onChanged.',
      'The fourth moment -- an edit made by code -- has a name and a mechanism '
          'that can see it, which is the controller listener; a validator '
          'bound only to onChanged sees what the person typed and not what the '
          'formatter produced',
      () =>
          HabotFieldLifecycleEvents.bindings.any(
            (HabotEventBinding b) =>
                b.moment == HabotFieldMoment.editedByCode &&
                b.mechanism == HabotListenerMechanism.controllerListener,
          ) &&
          HabotFieldLifecycleEvents.programmaticWriteNote
              .contains('does not fire for programmatic'),
    );

    gate(
      'GEN-04020-G4',
      'A binding with no reason is a line in a constructor.',
      'Every one of the four says why it does or does not judge, and the four '
          'are bound across three distinct mechanisms rather than to one '
          'general listener',
      () =>
          HabotFieldLifecycleEvents.bindings.length == 4 &&
          HabotFieldLifecycleEvents.bindings.every(
            (HabotEventBinding b) => b.why.length > 60,
          ) &&
          HabotFieldLifecycleEvents.mechanismsUsed.length == 3,
    );
  });

  group('GEN-04020 :: when to judge', () {
    gate(
      'GEN-04020-G5',
      '"Validating on every keystroke tells a person their email address is '
          'invalid while they are typing the first character of it."',
      'Exactly one moment judges unconditionally and it is blur, so the value '
          'is whole before anything is said about it',
      () =>
          HabotFieldLifecycleEvents.unconditionalValidationMoments.length ==
              1 &&
          HabotFieldLifecycleEvents.unconditionalValidationMoments.single
                  .moment ==
              HabotFieldMoment.lostFocus &&
          HabotFieldLifecycleEvents.whenToJudgeNote
              .contains('true and useless'),
    );

    gate(
      'GEN-04020-G6',
      'A correction should clear the moment it is correct.',
      'All four cases of the judging rule hold: blur judges, focus never '
          'judges, a keystroke in a clean field does not, and a keystroke in '
          'an errored field judges immediately -- which is the rule '
          'HabotFormGate already implements with its touched set',
      () =>
          HabotFieldLifecycleEvents.judgingRuleHolds &&
          HabotFieldLifecycleEvents.judgingRule.length == 4 &&
          HabotFieldLifecycleEvents.whenToJudgeNote
              .contains('not a second implementation'),
    );

    gate(
      'GEN-04020-G7',
      'Mobile Form Event Listener Coverage -- floor, optimal and ceiling 1.',
      'All nine checks hold and both coverage figures are 1.0, so the step '
          'reports Pass on a substitution that names four moments where the '
          'row named three events',
      () =>
          HabotFieldLifecycleEvents.checks.length == 9 &&
          HabotFieldLifecycleEvents.checks.values.every((bool b) => b) &&
          HabotFieldLifecycleEvents.qualitativeOutput == 'Pass' &&
          HabotFieldLifecycleEvents.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String domCoverage =
        HabotFieldLifecycleEvents.domEventCoverage.toStringAsFixed(1);
    final int judgingMoments =
        HabotFieldLifecycleEvents.unconditionalValidationMoments.length;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04020',
        atomicStepReferenceId: 'GEN-04020',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Create client-side event listeners (onFocus, onBlur, '
            'onChange) for mobile input components."',
        implementationOrder: 246,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotFieldLifecycleEvents / HabotFieldMoment / '
              'HabotListenerMechanism',
          'Component Properties':
              '${HabotFieldLifecycleEvents.domEventsTheRowNames.length} DOM '
              'names mapped onto ${HabotFieldMoment.values.length} moments '
              'across ${HabotListenerMechanism.values.length} mechanisms; '
              'one moment judges unconditionally; a four-case rule for when '
              'the pattern runs',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION: ${HabotFieldLifecycleEvents.substitutionNote} '
              'RULE: ${HabotFieldLifecycleEvents.whenToJudgeNote} FINDING: '
              '${HabotFieldLifecycleEvents.programmaticWriteNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Form Event Listener Coverage',
            observed:
                '${moments.toStringAsFixed(1)} over the '
                '${HabotFieldMoment.values.length} moments a field can be in, '
                'and $domCoverage '
                'over the three DOM names the row lists. The moment count is '
                'the honest denominator: three names do not describe four '
                'things.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Moments at which a field is judged unconditionally',
            observed:
                '$judgingMoments of '
                '${HabotFieldMoment.values.length} -- blur. A keystroke '
                're-judges only a field that is already showing an error, so '
                'a correction clears immediately and a first character is '
                'never called invalid.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/field_lifecycle_events.dart',
        ],
      ),
    );
  });
}
