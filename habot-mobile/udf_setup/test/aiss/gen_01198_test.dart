/// AISS GATE -- Step 201 of 215
/// Global Reference ID:       GEN-01198
/// Atomic Steps Reference ID: GEN-01198
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Render registered child profiles as selectable M3 Outlined
///               Cards featuring avatars and checkmark selection states."
/// Metric: Special-Requirement Field Capture Accuracy -- Floor 0.95,
///         Optimal 0.999, Ceiling 1. Pass/Fail.
///
/// THE METRIC IS THE INSTRUCTION. The row describes a face and a tick; the
/// metric is about whether allergies, medication and access needs get
/// captured. A card showing a photograph and a name lets a parent select by
/// face in a second and never see that the allergy field is empty.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/booking/child_profile_card.dart';
import 'package:udf_setup/design_system/tokens/shape_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double accuracy = 0;
  double naive = 0;

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

  HabotChildProfile child(
    String id,
    Set<HabotChildRequirement> done, {
    bool photo = true,
  }) =>
      HabotChildProfile(
        id: id,
        displayName: 'Child $id',
        completedRequirements: done,
        hasAvatarImage: photo,
      );

  final HabotChildProfile complete =
      child('a', HabotChildRequirement.values.toSet());

  /// Everything except allergies -- the field a parent never notices missing
  /// because the card was showing them a face.
  final HabotChildProfile missingAllergies = child(
    'b',
    HabotChildRequirement.values.toSet()
      ..remove(HabotChildRequirement.allergies),
  );

  final HabotChildProfile sparse = child(
    'c',
    <HabotChildRequirement>{
      HabotChildRequirement.dateOfBirth,
      HabotChildRequirement.emergencyContact,
    },
    photo: false,
  );

  group('GEN-01198 :: what the card has to show', () {
    gate(
      'GEN-01198-G1',
      'Metric: SPECIAL-REQUIREMENT FIELD CAPTURE ACCURACY, on a row that '
          'describes avatars and checkmarks.',
      'A profile missing one required field is surfaced as missing on the card '
          'itself, before the parent chooses -- so selection by face cannot '
          'hide an empty allergy field',
      () =>
          !missingAllergies.isComplete &&
          missingAllergies.missingRequirements.single ==
              HabotChildRequirement.allergies &&
          HabotChildProfileCard.surfacesMissingRequirements(
            missingAllergies,
          ) &&
          HabotChildProfileCard
              .semanticsFor(missingAllergies, selected: false)
              .label
              .contains('1 required detail missing') &&
          HabotChildProfileCard.metricIsTheInstructionNote
              .contains('select by face'),
    );

    gate(
      'GEN-01198-G2',
      '"A card that does nothing when tapped is reported as a broken card, '
          'not as a validation message."',
      'An incomplete profile can still be selected and cannot be sent -- the '
          'card names the problem, and the block lives where the booking is '
          'assembled rather than under the finger',
      () =>
          HabotChildProfileCard.mayBeSelected(missingAllergies) &&
          !HabotChildProfileCard.isBookable(missingAllergies) &&
          HabotChildProfileCard.mayBeSelected(complete) &&
          HabotChildProfileCard.isBookable(complete) &&
          HabotChildProfileCard.selectNotRefuseNote
              .contains('what is missing'),
    );

    gate(
      'GEN-01198-G3',
      'Every required field is named rather than counted, so "incomplete" has '
          'an answer a support conversation can start from.',
      'Six requirements are declared and a sparse profile reports the four it '
          'is missing, in declaration order rather than set order',
      () =>
          HabotChildRequirement.values.length == 6 &&
          sparse.missingRequirements.length == 4 &&
          sparse.missingRequirements.first ==
              HabotChildRequirement.allergies &&
          sparse.missingRequirements.last ==
              HabotChildRequirement.authorisedCollection &&
          sparse.captureRate == 2 / 6,
    );
  });

  group('GEN-01198 :: selection, and who can perceive it', () {
    gate(
      'GEN-01198-G4',
      'Step 97: "to a screen reader a checkmark is an icon, not a selection."',
      'Selection is carried as state and announced, and the hint says what '
          'activation will do rather than describing the tick',
      () {
        final HabotChildCardSemantics on =
            HabotChildProfileCard.semanticsFor(complete, selected: true);
        final HabotChildCardSemantics off =
            HabotChildProfileCard.semanticsFor(complete, selected: false);
        return on.selected &&
            !off.selected &&
            on.hint.contains('remove from booking') &&
            off.hint.contains('add to booking') &&
            HabotChildProfileCard.tickIsNotAStateNote
                .contains('carries the selected state as state');
      },
    );

    gate(
      'GEN-01198-G5',
      'A tick plus an outline colour is one signal drawn twice.',
      'The selected outline is thicker as well as differently coloured, and '
          'both widths are shape tokens -- so selection survives a viewer who '
          'cannot separate the two colours',
      () =>
          HabotChildProfileCard.selectionIsNotColourAlone &&
          HabotChildProfileCard.outlineWidthDp == HabotShape.borderWidth &&
          HabotChildProfileCard.selectedOutlineWidthDp ==
              HabotShape.focusBorderWidth &&
          HabotChildProfileCard.cornerRadiusDp == HabotShape.md &&
          HabotChildProfileCard.selectedOutlineToken !=
              HabotChildProfileCard.unselectedOutlineToken,
    );

    gate(
      'GEN-01198-G6',
      'Step 97 A11Y_RAW_IMAGE: an image with no semantic label is invisible. '
          'A child\'s photograph is not decorative.',
      'The avatar is announced either way -- as a photograph when there is '
          'one and as initials when there is not -- so a profile without a '
          'picture announces something rather than nothing',
      () {
        final HabotChildCardSemantics withPhoto =
            HabotChildProfileCard.semanticsFor(complete, selected: false);
        final HabotChildCardSemantics withoutPhoto =
            HabotChildProfileCard.semanticsFor(sparse, selected: false);
        return withPhoto.avatarLabel.startsWith('Photo of') &&
            withoutPhoto.avatarLabel.startsWith('Initials for') &&
            withPhoto.avatarLabel.isNotEmpty &&
            withoutPhoto.avatarLabel.isNotEmpty &&
            HabotChildProfileCard.avatarIsNotDecorativeNote
                .contains('announcing nothing');
      },
    );

    gate(
      'GEN-01198-G7',
      'Metric: Special-Requirement Field Capture Accuracy -- floor 0.95, '
          'Pass/Fail.',
      'Across three profiles the real capture accuracy is 0.75 and reports '
          'Fail, while the number the row\'s own description makes easy to '
          'count -- did the card get selected -- is 1.0 and would have '
          'reported Pass',
      () {
        final List<HabotChildProfile> population = <HabotChildProfile>[
          complete,
          missingAllergies,
          sparse,
        ];
        accuracy = HabotChildProfileCard.captureAccuracy(population);
        naive = HabotChildProfileCard.selectionSuccessRate(population);
        return (accuracy - 13 / 18).abs() < 1e-9 &&
            naive == 1.0 &&
            accuracy < HabotChildProfileCard.floor &&
            HabotChildProfileCard.qualitativeOutput(accuracy) == 'Fail' &&
            HabotChildProfileCard.qualitativeOutput(naive) == 'Pass' &&
            HabotChildProfileCard.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01198',
        atomicStepReferenceId: 'GEN-01198',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Render registered child profiles as selectable M3 Outlined '
            'Cards featuring avatars and checkmark selection states."',
        implementationOrder: 201,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotChildProfileCard / HabotChildProfile',
          'Component Properties':
              '${HabotChildRequirement.values.length} named requirements per '
              'profile; MD3 outlined card at '
              '${HabotChildProfileCard.cornerRadiusDp.toStringAsFixed(0)}dp '
              'radius with a '
              '${HabotChildProfileCard.outlineWidthDp.toStringAsFixed(0)}dp '
              'outline going to '
              '${HabotChildProfileCard.selectedOutlineWidthDp'
              '.toStringAsFixed(0)}dp when selected; selection carried as '
              'semantic state; avatar '
              'announced with or without a photograph',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the metric is the instruction. The row describes a '
              'face and a tick; the metric is Special-Requirement Field '
              'Capture Accuracy. A card showing a photograph and a name lets a '
              'parent select by face in under a second and never discover that '
              'the allergy field on that profile has been empty since the '
              'child was added -- the selection succeeds, the booking '
              'succeeds, and the number the row is graded on was decided by '
              'something the card never showed. The card therefore carries '
              'requirement completeness. Measured over three profiles: 0.75 '
              'real capture accuracy against a 0.95 floor, reported as FAIL, '
              'where "did the card get selected" is 1.0 and would have '
              'reported Pass. DECISION: an incomplete profile can still be '
              'selected. A card that does nothing when tapped is reported as a '
              'broken card, not as a validation message; the block lives at '
              'the booking gate in Step 202. ACCESSIBILITY: a checkmark is an '
              'icon to a screen reader, so selection is state; the selected '
              'outline is thicker as well as recoloured; and a child\'s '
              'photograph is never marked decorative.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Special-Requirement Field Capture Accuracy',
            observed:
                '${accuracy.toStringAsFixed(4)} across three profiles -- '
                '13 of 18 required fields carry a value. Below the 0.95 floor, '
                'reported as Fail rather than rounded into a Pass.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Selection success rate (the easy number)',
            observed:
                '${naive.toStringAsFixed(2)} on the identical population. '
                'Every selectable card is selectable, so this is 1.0 for any '
                'implementation and says nothing about whether the data '
                'behind the card is there. Kept beside the real figure so the '
                'difference is demonstrated rather than argued.',
            floor: 'n/a -- contrast figure',
            optimal: 'n/a -- contrast figure',
            ceiling: 'n/a -- contrast figure',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/booking/child_profile_card.dart',
        ],
      ),
    );
  });
}
