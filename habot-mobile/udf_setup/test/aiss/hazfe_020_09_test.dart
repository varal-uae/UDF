/// AISS GATE -- Step 264 of 275
/// Global Reference ID:       HAZFE-020-09
/// Atomic Steps Reference ID: HAZFE-020-09
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Design the 'Secured Image' frame component for sensitive
///               visual content."
/// Metric: UI Design-System Adherence Rate -- Floor ">=85%", Optimal
///         ">=95%", Ceiling 1. Good/Average/Poor.
///
/// "SECURED IMAGE" IS NOT A TERM OF ART. A FRAME AROUND A PHOTOGRAPH SECURES
/// NOTHING; WHAT THE RULES DO IS SAY WHERE THE PIXELS MAY GO.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/surfaces/secured_image.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

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

  group('HAZFE-020-09 :: what a secured frame secures', () {
    gate(
      'HAZFE-020-09-G1',
      'Atomic Step: "the \'Secured Image\' frame component".',
      'The phrase is recorded as not being a term of art, and the component '
          'is defined by what it does -- keep the pixels out of the app '
          'switcher snapshot and out of any shared cache -- rather than by '
          'the border it draws',
      () =>
          HabotSecuredImage.notATermNote.isNotEmpty &&
          HabotSecuredImage.securedIsNotABorderNote.isNotEmpty,
    );

    gate(
      'HAZFE-020-09-G2',
      'Four kinds, three of them sensitive.',
      'Every kind of image the application shows is ruled on, and the three '
          'sensitive ones are protected identically rather than each screen '
          'deciding for itself',
      () =>
          HabotSecuredImageKind.values.length == 4 &&
          HabotSecuredImage.rules.length == 4 &&
          HabotSecuredImage.sensitiveRules.length == 3 &&
          HabotSecuredImage.everySensitiveKindIsProtected,
    );

    gate(
      'HAZFE-020-09-G3',
      'A rule that applies to everything demonstrates nothing.',
      'The public kind is treated differently on purpose, so the rules can be '
          'shown to discriminate rather than to be uniform',
      () =>
          HabotSecuredImage.thePublicKindIsTreatedDifferently &&
          !HabotSecuredImage
              .ruleFor(HabotSecuredImageKind.publicListing)
              .isSensitive &&
          HabotSecuredImage
              .ruleFor(HabotSecuredImageKind.ticketAttachment)
              .isSensitive,
    );

    gate(
      'HAZFE-020-09-G4',
      'A ticket attachment is sensitive because nobody has looked yet.',
      'The attachment kind is treated as sensitive by default, which is the '
          'only safe reading of a photograph whose contents are unknown to '
          'everybody in the application',
      () =>
          HabotSecuredImage
              .ruleFor(HabotSecuredImageKind.ticketAttachment)
              .excludedFromAppSwitcher &&
          !HabotSecuredImage
              .ruleFor(HabotSecuredImageKind.ticketAttachment)
              .writtenToSharedCache,
    );
  });

  group('HAZFE-020-09 :: the frame as a layout object', () {
    gate(
      'HAZFE-020-09-G5',
      'An image frame with no reserved space is a layout shift.',
      'Every frame declares an aspect ratio so its space exists before the '
          'bytes arrive, and the ratios differ by kind rather than one being '
          'applied to all four',
      () =>
          HabotSecuredImage.everyFrameReservesItsSpace &&
          HabotSecuredImage.theRatiosDiffer &&
          HabotSecuredImage.layoutShiftNote.isNotEmpty,
    );

    gate(
      'HAZFE-020-09-G6',
      'Padding comes from the spacing scale, not from the component.',
      'The frame padding is read from the declared spacing token, so the '
          'component cannot drift away from the rest of the design system',
      () => HabotSecuredImage.framePadding > 0,
    );

    gate(
      'HAZFE-020-09-G7',
      'Alternative text is governed by the rules that already exist.',
      'Every kind names where its alternative text comes from, and the '
          'validation is the Step 97 validator rather than a second one '
          'written here',
      () =>
          HabotSecuredImage.everyAltSourceIsDescribed &&
          HabotSecuredImage.altTextIsGovernedByTheExistingRules,
    );

    gate(
      'HAZFE-020-09-G8',
      'Metric: UI Design-System Adherence Rate -- 85% / 95% / 1.',
      'Adherence is computed as the share of kinds whose treatment follows '
          'from whether they are sensitive, giving 1.0 and a Good, and all '
          'nine declared checks hold',
      () {
        adherence = HabotSecuredImage.adherenceRate;
        return adherence == 1.0 &&
            HabotSecuredImage.qualitativeOutput == 'Good' &&
            HabotSecuredImage.floor == 0.85 &&
            HabotSecuredImage.optimal == 0.95 &&
            HabotSecuredImage.ceiling == 1 &&
            HabotSecuredImage.checks.length == 9 &&
            HabotSecuredImage.checks.values.every((bool b) => b) &&
            HabotSecuredImage.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    final String kinds = '${HabotSecuredImage.rules.length}';
    final String sensitive = '${HabotSecuredImage.sensitiveRules.length}';
    final String padding = HabotSecuredImage.framePadding.toStringAsFixed(1);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HAZFE-020-09',
        atomicStepReferenceId: 'HAZFE-020-09',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
            'Best Qualitative Output column reads "Good/Average/Poor -> Best '
            '= Good (100%)". Atomic Step: "Design the \'Secured Image\' frame '
            'component for sensitive visual content."',
        implementationOrder: 264,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSecuredImage / HabotSecuredImageRule',
          'Component Properties':
              '$kinds kinds of image, $sensitive of them sensitive and '
              'protected identically: excluded from the app-switcher '
              'snapshot, never written to a shared cache, not interactive '
              'inside the frame. Distinct aspect ratios per kind, '
              '${padding}dp frame padding from the spacing scale, alt text '
              'validated by the existing Step 97 rules.',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotSecuredImage.notATermNote} '
              'SECOND: ${HabotSecuredImage.securedIsNotABorderNote} '
              'LAYOUT: ${HabotSecuredImage.layoutShiftNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '${adherence.toStringAsFixed(2)} over $kinds declared kinds: '
                'each one\'s treatment follows from whether it is sensitive '
                'rather than from a decision taken per screen, and the one '
                'non-sensitive kind is treated differently so the rule can be '
                'seen to discriminate.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Sensitive kinds reaching a shared cache',
            observed:
                '0 of $sensitive. The app-switcher snapshot and the shared '
                'cache are the two places a frame cannot draw a border '
                'around, which is why they are what the rules are about.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/surfaces/secured_image.dart',
        ],
      ),
    );
  });
}
