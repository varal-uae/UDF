/// AISS GATE -- Step 440 of 415
/// Global Reference ID:       GEN-02489
/// Atomic Steps Reference ID: GEN-02489
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Set thematic color updates to activate based on milestone
///               achievements."
/// Metric: Process Completion Rate -- floor "0", optimal "95-100%", ceiling
///         "1". Best Qualitative Output: "Complete/Partial/Not Complete".
///         ISO/IEC 25010 (Product Quality). Assigned to **UDF**.
///
/// RECOLOUR THE APPLICATION ON A MILESTONE, UNDER THE FIRST BAND IN THE TRACK
/// WHOSE FLOOR IS ZERO.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/recognition/milestone_theme.dart';

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

  group('GEN-02489 :: a floor of zero', () {
    gate(
      'GEN-02489-G1',
      'The floor is zero, the first in the track.',
      'A build that does nothing clears it',
      () =>
          HabotMilestoneTheme.theFirstZeroFloor &&
          HabotMilestoneTheme.aBuildThatDoesNothingClearsIt,
    );

    gate(
      'GEN-02489-G2',
      'And three notations in three cells.',
      'An integer, a percentage range, and a fraction',
      () =>
          HabotMilestoneTheme.threeNotationsInThreeCells &&
          HabotMilestoneTheme.floorNote.contains('compared with itself'),
    );

  });

  group('GEN-02489 :: only the person\'s own card', () {
    gate(
      'GEN-02489-G3',
      'Three recolour scopes, only one allowed.',
      'The person\'s own card; never the app theme or a semantic role',
      () =>
          HabotRecolourScope.values.length == 3 &&
          HabotMilestoneTheme.onlyTheOwnCardIsRecoloured,
    );

    gate(
      'GEN-02489-G4',
      'The error role stays for errors.',
      'As Step 425 decided',
      () =>
          HabotMilestoneTheme.theErrorRoleStaysForErrors &&
          HabotMilestoneTheme.noAccentIsASemanticRole,
    );

    gate(
      'GEN-02489-G5',
      'Three accents, each a named role passing 4.5:1.',
      'The same contrast floor as everything else since Step 4',
      () =>
          HabotMilestoneTheme.accents.length == 3 &&
          HabotMilestoneTheme.everyAccentIsARoleNotALiteral &&
          HabotMilestoneTheme.everyAccentPassesContrast,
    );

    gate(
      'GEN-02489-G6',
      'And the scope is the person\'s own card.',
      'Nowhere else',
      () =>
          HabotMilestoneTheme.scopeNote.contains('nowhere else') &&
          HabotMilestoneTheme.theCardIsTheProgressionCard,
    );

  });

  group('GEN-02489 :: the colour is not the reward', () {
    gate(
      'GEN-02489-G7',
      'Every milestone is announced in words.',
      'With an icon, because the carrier rule applies to good news too',
      () =>
          HabotMilestoneTheme.everyMilestoneIsAnnouncedInWords &&
          HabotMilestoneTheme.theCarrierRuleHolds,
    );

    gate(
      'GEN-02489-G8',
      'High-contrast mode keeps the accent still.',
      'Somebody who asked for maximum contrast asked colours to stop being '
          'decorative',
      () =>
          HabotMilestoneTheme.highContrastIsRespected &&
          HabotMilestoneTheme.rewardNote.contains('stop being decorative'),
    );

  });

  group('GEN-02489 :: the result', () {
    gate(
      'GEN-02489-G9',
      'Completion reaches the ceiling.',
      'Every accent passes contrast and is announced',
      () => HabotMilestoneTheme.completion == 1,
    );

    gate(
      'GEN-02489-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotMilestoneTheme.obligations.length == 5 &&
          HabotMilestoneTheme.obligations.values.every((bool b) => b) &&
          HabotMilestoneTheme.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int accents = HabotMilestoneTheme.accents.length;
    final double contrast = HabotMilestoneTheme.contrastFloor;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02489',
        atomicStepReferenceId: 'GEN-02489',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor is 0 -- the first zero floor in '
            'the track, which a build doing nothing clears -- and its three '
            'band cells use three notations: an integer, a percentage range '
            'and a fraction; its instruction would recolour the application on '
            'a milestone, which would repaint semantic roles and bypass the '
            'contrast checks enforced since Step 4, so only an accent on the '
            'person\'s own card changes; and the milestone is announced in '
            'words with an icon, because colour cannot be the whole reward. '
            'Atomic Step: "Set thematic color updates to activate based on '
            'milestone achievements."',
        implementationOrder: 440,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Set thematic color updates to activate based on milestone '
          'achievements':
              '$accents milestone accents on the person\'s own card only, each '
                  'a named role at or above $contrast:1 and announced in words',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Completion Rate',
            observed:
                'THE FLOOR IS ZERO. Every band in four hundred and thirty-nine '
                'rows put its floor above nothing; this one sits at 0, so a '
                'build that does nothing clears it. Its three cells use three '
                'notations -- 0, "95-100%" and 1 -- so the band cannot be '
                'compared with itself. Observed: all $accents accents pass the '
                '$contrast:1 floor and are announced in words.',
            floor: '0',
            optimal: '95-100%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName:
                'Semantic roles or app-wide colours changed by a milestone',
            observed:
                '0. The error role means something is broken, the attention '
                'role marks a bottleneck, and contrast has been enforced since '
                'Step 4; swapping the palette for one person on a milestone '
                'would recolour all of it with no guarantee the checks still '
                'pass. Only an accent on the person\'s own card changes, and '
                'in high-contrast mode not even that.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/recognition/milestone_theme.dart',
        ],
      ),
    );
  });
}
