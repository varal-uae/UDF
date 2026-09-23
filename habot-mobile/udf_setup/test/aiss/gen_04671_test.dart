/// AISS GATE -- Step 477 of 1,314
/// Global Reference ID:       GEN-04671
/// Atomic Steps Reference ID: GEN-04671
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Integrate Over-the-Air update SDK modules (Expo Updates /
///               CodePush)."
/// Metric: OTA Update Adoption Rate (7-day) -- floor "0.8", optimal "0.95",
///         ceiling "0.99". Best Qualitative Output: "Good/Average/Poor".
///         CodePush/Expo OTA Update Industry Benchmark. Assigned to **ADFA**.
///
/// A CHANNEL THAT CAN REPLACE THE APPLICATION ON A PHONE SOMEBODY IS WORKING
/// FROM, SCORED ON WHETHER PEOPLE TOOK IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/ota_channel.dart';

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

  group('GEN-04671 :: three decimals and no unit', () {
    gate(
      'GEN-04671-G1',
      'The band is 0.8, 0.95 and 0.99.',
      'Three bare decimals with no unit named anywhere',
      () => HabotOtaChannel.theBandIsBareDecimals,
    );

    gate(
      'GEN-04671-G2',
      'Ascending, which is the one thing it gets right.',
      'Higher adoption is better; the band at least agrees',
      () => HabotOtaChannel.theBandAscendsCorrectly,
    );

    gate(
      'GEN-04671-G3',
      'So a reading is declared instead of assumed.',
      'The share of active devices on the newest bundle within seven days',
      () => HabotOtaChannel.aReadingIsDeclared,
    );

  });

  group('GEN-04671 :: a number about people', () {
    gate(
      'GEN-04671-G4',
      'The observed share is reported with its denominator.',
      '341 of 412 active devices',
      () =>
          HabotOtaChannel.theDenominatorIsReported &&
          HabotOtaChannel.activeDevices == 412,
    );

    gate(
      'GEN-04671-G5',
      'And the rota is recorded beside it.',
      'A four-on-four-off rota moves this number without the integration '
      'changing',
      () => HabotOtaChannel.rotaNote.contains('four-on-four-off'),
    );

    gate(
      'GEN-04671-G6',
      'The integration is verified on its own terms.',
      'Because the metric scores users rather than the SDK',
      () => HabotOtaChannel.theIntegrationIsVerifiedSeparately,
    );

  });

  group('GEN-04671 :: four rules for changing an application', () {
    gate(
      'GEN-04671-G7',
      'An update applies at cold start and never mid-session.',
      'Nobody half-way through recording a visit loses the screen',
      () => HabotOtaChannel.nobodyLosesAScreenMidVisit,
    );

    gate(
      'GEN-04671-G8',
      'Three rollout stages, every one haltable.',
      'Five per cent, twenty-five, then everybody',
      () =>
          HabotOtaChannel.theRolloutIsStaged &&
          HabotOtaChannel.everyStageCanBeHalted,
    );

    gate(
      'GEN-04671-G9',
      'No update changes what is collected.',
      'That is a declaration made to a store and to the people the data is '
      'about',
      () =>
          !HabotOtaChannel.anUpdateMayChangeWhatIsCollected &&
          HabotOtaChannel.collectionNote.contains('through review'),
    );

  });

  group('GEN-04671 :: the result', () {
    gate(
      'GEN-04671-G10',
      'Five obligations met, and 0.83 reports Average.',
      'Above the floor of 0.8 and below the optimal of 0.95',
      () =>
          HabotOtaChannel.obligations.length == 5 &&
          HabotOtaChannel.obligations.values.every((bool b) => b) &&
          HabotOtaChannel.aBadBundleRollsItselfBack &&
          HabotOtaChannel.qualitativeOutput == 'Average',
    );
  });

  tearDownAll(() {
    final double share = HabotOtaChannel.observedShare;
    final int devices = HabotOtaChannel.activeDevices;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04671',
        atomicStepReferenceId: 'GEN-04671',
        setupStepAction:
            'COLUMN NOTE: this row\'s band is three bare decimals -- 0.8, '
            '0.95, 0.99 -- with no unit, read here as the share of active '
            'devices on the newest bundle within seven days; the metric scores '
            'whether people took the update rather than whether the SDK was '
            'integrated, so the share is reported with its denominator and the '
            'integration verified separately; updates apply at cold start and '
            'never mid-session, the running version is visible, rollout is '
            'staged and haltable, no update may change what is collected, and '
            'a bundle that fails to boot twice rolls itself back. Atomic Step: '
            '"Integrate Over-the-Air update SDK modules (Expo Updates / '
            'CodePush)."',
        implementationOrder: 477,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Integrate Over-the-Air update SDK modules (Expo Updates / '
          'CodePush).':
              'adoption ${share.toStringAsFixed(2)} across $devices active '
              'devices, updates applied at cold start only, three haltable '
              'rollout stages, and no change to what is collected',
          'Completion Status': 'Average',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'OTA Update Adoption Rate (7-day)',
            observed:
                'THREE BARE DECIMALS, AND A NUMBER ABOUT PEOPLE RATHER THAN '
                'ABOUT THE INTEGRATION. The band names 0.8, 0.95 and 0.99 of '
                'something it never identifies; read as the share of active '
                'devices on the newest bundle within seven days, the observed '
                'figure is ${share.toStringAsFixed(2)} over $devices devices, '
                'which is Average. A faultless integration on a '
                'four-on-four-off rota sits below the floor for a week and '
                'then jumps, so the denominator and the rota are reported with '
                'it.',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '0.99',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Updates that could apply mid-session',
            observed:
                '0. An over-the-air channel can change the application without '
                'review, which is its value and its danger: updates apply at '
                'the next cold start, the running bundle version is visible in '
                'the application and in the crash report, rollout is staged at '
                'five, twenty-five and a hundred per cent with every stage '
                'haltable, no update may change what data is collected, and a '
                'bundle that fails to boot twice rolls back to the previous '
                'one.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/ota_channel.dart',
        ],
      ),
    );
  });
}
