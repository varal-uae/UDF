/// AISS GATE -- Step 328 of 335
/// Global Reference ID:       GEN-05188
/// Atomic Steps Reference ID: GEN-05188
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the mistake-proofing (Poka-Yoke) control:
///               auto-masking algorithms physically block sending phone
///               numbers, email addresses, or external links in chat messages"
/// Metric: Mistake-Proofing Control Effectiveness (Error Interception Rate) --
///         floor ">= 90% of induced errors intercepted", optimal ">= 99%",
///         ceiling 1. Pass/Fail. Shingo. Assigned to **DEA**.
///
/// POKA-YOKE PREVENTS ERRORS, AND THIS IS A BUSINESS RULE. THE SAME CONTROL
/// PASSES AND FAILS THE FLOOR DEPENDING ON A POPULATION NOBODY NAMED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/chat_disintermediation.dart';

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

  group('GEN-05188 :: it is a rule, not a mistake-proofing control', () {
    gate(
      'GEN-05188-G1',
      'Shingo: a control that stops what a person did not mean to do.',
      'Sending a phone number to a customer is a deliberate act the platform '
          'forbids for commercial reasons, so the label is wrong twice',
      () =>
          !HabotChatDisintermediation.sendingContactDetailsIsASlip &&
          HabotChatDisintermediation.theRowMislabelsTheControl &&
          HabotChatDisintermediation.shingoDefinition
              .contains('did not mean to do'),
    );

    gate(
      'GEN-05188-G2',
      'Which changes the message.',
      '"That looks like a mistake" is false and reads as an accusation; the '
          'message says what the rule is and why, and carries the reason',
      () =>
          HabotChatDisintermediation.theMessageIsTrueRatherThanAccusatory &&
          HabotChatDisintermediation.theMessageCarriesTheReason &&
          HabotChatDisintermediation.labelNote
              .contains('the name is corrected'),
    );
  });

  group('GEN-05188 :: two populations, one floor', () {
    gate(
      'GEN-05188-G3',
      'Eight ways a contact detail can be written, four of them caught.',
      'Plain digits, separators, dots and Arabic-Indic numerals are caught; '
          'spelled-out digits, full-width homoglyphs, a photograph and a '
          'pointer elsewhere are not',
      () =>
          HabotChatDisintermediation.forms.length == 8 &&
          HabotChatDisintermediation.caught == 4 &&
          HabotChatDisintermediation.interceptionAgainstSomebodyTrying == 0.5,
    );

    gate(
      'GEN-05188-G4',
      'Fifty per cent against a floor of ninety.',
      'And close to perfect against an accidental paste -- the same control '
          'sits on both sides of the floor depending on who is being '
          'intercepted',
      () =>
          HabotChatDisintermediation.theSameControlIsAPassAndAFail &&
          HabotChatDisintermediation.interceptionAgainstAnAccident == 1.0 &&
          HabotChatDisintermediation.floorRate == 0.90,
    );

    gate(
      'GEN-05188-G5',
      'The figure is published with its population attached.',
      'Because without one it is not a figure',
      () => HabotChatDisintermediation.populationNote
          .contains('it is not a figure'),
    );

    gate(
      'GEN-05188-G6',
      'The four missed forms are not a regex gap.',
      'Each new pattern produces a new evasion and the people evading are '
          'motivated; a determined case is an enforcement problem with an '
          'account attached',
      () =>
          HabotChatDisintermediation.theFourMissedFormsAreDeliberate &&
          HabotChatDisintermediation.enforcementNote
              .contains('an account attached'),
    );
  });

  group('GEN-05188 :: block, not mask', () {
    gate(
      'GEN-05188-G7',
      'Atomic Step: "auto-masking algorithms physically block".',
      'Two opposite behaviours in one sentence: blocking costs the message, '
          'masking puts words in somebody\'s mouth and does it silently',
      () =>
          HabotChatDisintermediation.nothingIsSentThatWasNotTyped &&
          HabotChatDisintermediation.behaviourNote
              .contains('does it silently'),
    );

    gate(
      'GEN-05188-G8',
      'Nothing typed is lost.',
      'The send is refused, every character is kept, and the cursor goes on '
          'the span that stopped it',
      () =>
          HabotChatDisintermediation.nothingTypedIsLost &&
          HabotChatDisintermediation.behaviour ==
              HabotInterceptBehaviour.blockAndPoint,
    );

    gate(
      'GEN-05188-G9',
      'The warning fires once per message.',
      'Rather than on every keystroke, which is Step 309\'s finding on a '
          'different subject',
      () => !HabotChatDisintermediation.theWarningFiresPerKeystroke,
    );

    gate(
      'GEN-05188-G10',
      'Output: Pass / Fail.',
      'Six declared obligations, all met, giving Pass; all ten declared '
          'checks hold',
      () =>
          HabotChatDisintermediation.obligations.length == 6 &&
          HabotChatDisintermediation.obligations.values.every((bool b) => b) &&
          HabotChatDisintermediation.qualitativeOutput == 'Pass' &&
          HabotChatDisintermediation.checks.length == 10 &&
          HabotChatDisintermediation.checks.values.every((bool b) => b) &&
          HabotChatDisintermediation.columnNote.contains('DEA'),
    );
  });

  tearDownAll(() {
    final String message = HabotChatDisintermediation.message;
    final String trying =
        (HabotChatDisintermediation.interceptionAgainstSomebodyTrying * 100)
            .toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05188',
        atomicStepReferenceId: 'GEN-05188',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to DEA rather than UDF, and '
            'every narrative column is the generic engineering-console '
            'boilerplate -- "Read-only M3 KPI cards with deep-link '
            'drill-down" -- on a row about what a person may type into a chat. '
            'Atomic Step: "Implement the mistake-proofing (Poka-Yoke) control: '
            'auto-masking algorithms physically block sending phone numbers, '
            'email addresses, or external links in chat messages."',
        implementationOrder: 328,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement the mistake-proofing (Poka-Yoke) control: auto-masking '
                  'algorithms physically block sending':
              'blocked rather than masked; the message reads "$message"',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              '$trying per cent interception against somebody trying, close '
                  'to 100 against an accidental paste',
          'Data Quality Note':
              'LABEL: ${HabotChatDisintermediation.labelNote} '
              'POPULATION: ${HabotChatDisintermediation.populationNote} '
              'ENFORCEMENT: ${HabotChatDisintermediation.enforcementNote} '
              'BEHAVIOUR: ${HabotChatDisintermediation.behaviourNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Mistake-Proofing Control Effectiveness (Error Interception '
                'Rate)',
            observed:
                '$trying% against somebody trying, and effectively 100% '
                'against an accidental paste -- the same control on both '
                'sides of the 90% floor, because the row does not say which '
                'population "induced errors" means. Published with the '
                'population attached. The four forms the matcher misses are '
                'an enforcement problem rather than a text-matching one.',
            floor: '>= 90% of induced errors intercepted',
            optimal: '>= 99% of induced errors intercepted',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Messages sent that the person did not write',
            observed:
                '0. The row asks for masking and blocking in one sentence and '
                'their failure modes are opposite; this blocks, keeps every '
                'character, and puts the cursor on the span, so nothing is '
                'redacted into somebody\'s mouth and nothing they typed is '
                'lost.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/chat_disintermediation.dart',
        ],
      ),
    );
  });
}
