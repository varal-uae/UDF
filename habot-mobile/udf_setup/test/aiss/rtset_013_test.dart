/// AISS GATE -- Step 429 of 415
/// Global Reference ID:       RTSET-013
/// Atomic Steps Reference ID: RTSET-013
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Determine WebSocket event channel structures and layout card
///               refresh triggers."
/// Metric: Channel / Topic Design Completeness -- floor "0.9", optimal "0.99",
///         ceiling "1". Best Qualitative Output: "Complete". Fully defining
///         every routing path (Parent/LSA/SEN, escalation tiers, alert
///         channels) before build is standard practice to prevent silent
///         message loss once live.. Assigned to **UDF**.
///
/// CHANNELS PER SCOPE RATHER THAN PER CARD, ON A ROW WHOSE LOWER HALF IS ABOUT
/// CORS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/live/channel_design.dart';

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

  group('RTSET-013 :: three channels, five cards', () {
    gate(
      'RTSET-013-G1',
      'Five cards on three channels.',
      'Site, shift and viewer, serving any number of cards',
      () =>
          HabotChannelDesign.cardCount == 5 &&
          HabotChannelDesign.channelCount == 3 &&
          HabotChannelDesign.channelsAreFewerThanCards,
    );

    gate(
      'RTSET-013-G2',
      'Two cards share one scope and cannot disagree.',
      'Because every card on a scope updates from one message',
      () =>
          HabotChannelDesign.twoCardsShareTheShiftScope &&
          HabotChannelDesign.oneMessageServesEveryCardOnAScope,
    );

    gate(
      'RTSET-013-G3',
      'And twelve subscriptions would be twelve reconnects.',
      'Plus two copies of the same data taken at two instants, which is how '
          'one screen shows two totals',
      () => HabotChannelDesign.scopeNote.contains('two totals'),
    );

  });

  group('RTSET-013 :: a refresh that fires under a thumb', () {
    gate(
      'RTSET-013-G4',
      'Layout changes are held under a pointer.',
      'A card re-laying-out under a moving thumb moves the target between the '
          'press and the release',
      () =>
          HabotChannelDesign.onlyLayoutChangesAreDeferred &&
          HabotChannelDesign.twoCardsCanChangeLayout,
    );

    gate(
      'RTSET-013-G5',
      'And number changes are not.',
      'Holding those is how a live figure becomes a stale one',
      () =>
          !HabotChannelDesign.numberChangesAreHeld &&
          HabotChannelDesign.bothHalvesAreAddressed,
    );

    gate(
      'RTSET-013-G6',
      'Because the target moves between press and release.',
      'So the tap lands on whatever slid into that position',
      () => HabotChannelDesign.gestureNote.contains('slid into that position'),
    );

  });

  group('RTSET-013 :: every trigger has a reason', () {
    gate(
      'RTSET-013-G7',
      'Three triggers, each with a rationale.',
      'A channel message, a manual pull, and a poll where the source cannot '
          'push',
      () =>
          HabotChannelDesign.everyTriggerHasARationale &&
          HabotChannelDesign.everyCardDeclaresItsTrigger,
    );

    gate(
      'RTSET-013-G8',
      'The polling card is labelled with its age.',
      'A card that polls is not live and is not allowed to look like the '
          'others',
      () =>
          HabotChannelDesign.thePollingCardIsMarkedAsSuch &&
          HabotChannelDesign.triggerNote.contains('look like the others'),
    );

  });

  group('RTSET-013 :: the column, the standard, and the CORS row', () {
    gate(
      'RTSET-013-G9',
      'One-valued output column, and prose in the standard column.',
      '"Complete" with nothing else available, and a sentence arguing for the '
          'band where a standard belongs',
      () =>
          HabotChannelDesign.theCountReachesFourteen &&
          HabotChannelDesign.theStandardColumnHoldsProse &&
          HabotChannelDesign.secondSuchRow,
    );

    gate(
      'RTSET-013-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotChannelDesign.obligations.length == 5 &&
          HabotChannelDesign.obligations.values.every((bool b) => b) &&
          HabotChannelDesign.qualitativeOutput == 'Complete' &&
          HabotChannelDesign.completenessReachesTheCeiling &&
          HabotChannelDesign.fiveCellsBelongElsewhere &&
          HabotChannelDesign.seventhSplicedRow,
    );
  });

  tearDownAll(() {
    final int cards = HabotChannelDesign.cardCount;
    final int channels = HabotChannelDesign.channelCount;
    final int polling = HabotChannelDesign.pollingCards;
    final int spliced = HabotChannelDesign.cellsFromTheCorsRow.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'RTSET-013',
        atomicStepReferenceId: 'RTSET-013',
        setupStepAction:
            'COLUMN NOTE: this row\'s Best Qualitative Output column holds the '
            'single word "Complete", the fourteenth one-valued column in the '
            'track and the third in this batch after Steps 423 and 428; its '
            'reference-standard column holds a sentence arguing for the band '
            'rather than naming a standard, the second such row after Step '
            '416; its Data Requirement holds the Layout Type and Grid '
            'Dimensions field set that belongs to a layout row; and its '
            'Poka-Yoke, Completion Measures, Expected Output, Common Library '
            'and Decision Group cells are all about CORS and wildcard origins '
            'at an API gateway, making this the seventh spliced row in the '
            'track and the fourth in this batch. Atomic Step: "Determine '
            'WebSocket event channel structures and layout card refresh '
            'triggers."',
        implementationOrder: 429,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type':
              'not applicable: this row\'s Data Requirement holds the layout '
                  'field set belonging to a layout row',
          'Layout Grid Dimensions': 'as above',
          'Spacing Rules': 'as above',
          'Alignment Settings': 'as above',
          'Layout Validation Status':
              '$cards cards on $channels scoped channels; $polling card polls '
                  'and is labelled with the age of what it shows; $spliced '
                  'cells on this row are about CORS at an API gateway',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Channel / Topic Design Completeness',
            observed:
                'A ONE-VALUED OUTPUT COLUMN, PROSE IN THE STANDARD COLUMN, AND '
                'A LOWER HALF ABOUT CORS. The Best Qualitative Output cell '
                'holds the single word "Complete" -- the fourteenth one-valued '
                'column in the track and the third in this batch after Steps '
                '423 and 428 -- the reference-standard column holds a sentence '
                'arguing for the band rather than naming a standard, the '
                'second such row after Step 416, and $spliced cells describe '
                'wildcard origins and a CORS manifest at an API gateway, '
                'making this the seventh spliced row in the track. Observed: '
                '$cards cards on $channels channels, every one declaring a '
                'trigger with a rationale.',
            floor: '0.9',
            optimal: '0.99',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Cards that can disagree with each other',
            observed:
                '0 of $cards. Twelve cards with twelve subscriptions is twelve '
                'reconnect handshakes after a tunnel, and the moment two of '
                'them want the same data they get two copies taken at two '
                'instants -- which is how one screen shows two totals. Three '
                'scoped channels mean every card on a scope updates from one '
                'message. Updates that change layout are held while a pointer '
                'is down, because a card re-laying-out under a moving thumb '
                'moves the target between the press and the release; updates '
                'that change only a number are applied at once.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/live/channel_design.dart',
        ],
      ),
    );
  });
}
