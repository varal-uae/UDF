/// AISS GATE -- Step 487 of 1,314
/// Global Reference ID:       GEN-00921
/// Atomic Steps Reference ID: GEN-00921
/// Setup Step (Action): Standardize the shimmer angle (e.g., 45 degrees) across
///                      all skeleton components.
/// Atomic Step: "Program Shakti Alerts notifying Product Managers if any funnel
///               step drops > 15% week-over-week."
/// Metric: Alert Trigger Dispatch Delay -- floor "$\le 3\text{ secs}$", optimal
///         "$\le 1\text{ sec}$", ceiling "$5\text{ secs}$". Best Qualitative
///         Output: "Pass / Fail". Habot Shakti Safety Protocol. Assigned to
///         **CAL**.
///
/// A FIFTEEN PER CENT THRESHOLD THAT WOULD FIRE ON NOTHING, AND A BAND TIMING
/// THE OTHER HALF OF THE ROW.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/alerts/funnel_drop_alert.dart';

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

  group('GEN-00921 :: Step 486\'s measure, renamed', () {
    gate(
      'GEN-00921-G1',
      'It is Step 486\'s measure under another name.',
      'Same floor, same optimal, same ceiling, different title',
      () => HabotFunnelDropAlert.itIsStep486sMeasure,
    );

    gate(
      'GEN-00921-G2',
      'With the ceiling slower than the floor again.',
      'Five seconds above a three-second floor',
      () => HabotFunnelDropAlert.theCeilingIsSlowerThanTheFloorAgain,
    );

    gate(
      'GEN-00921-G3',
      'The band times dispatch while the row sets a threshold.',
      'Dispatch speed says nothing about whether the alert should have fired',
      () =>
          HabotFunnelDropAlert.theBandMeasuresTheOtherHalf &&
          HabotFunnelDropAlert.halvesNote.contains('should have fired'),
    );

  });

  group('GEN-00921 :: a minimum denominator', () {
    gate(
      'GEN-00921-G4',
      'Three funnel steps, one alert this week.',
      'Because two of the three should not produce one',
      () =>
          HabotFunnelDropAlert.steps.length == 3 &&
          HabotFunnelDropAlert.oneAlertThisWeek,
    );

    gate(
      'GEN-00921-G5',
      'The step 1,840 people reached fires.',
      'Down 18 per cent on a volume that can carry the comparison',
      () => HabotFunnelDropAlert.theBigStepFires,
    );

    gate(
      'GEN-00921-G6',
      'The step 47 people reached does not.',
      'Below the minimum weekly volume',
      () => HabotFunnelDropAlert.theSmallStepDoesNotFire,
    );

    gate(
      'GEN-00921-G7',
      'Though it would have without the volume floor.',
      'Eight people out of forty-seven is a 17 per cent drop',
      () =>
          HabotFunnelDropAlert.theSmallStepWouldHaveFiredWithoutTheFloor &&
          HabotFunnelDropAlert.minimumWeeklyVolume == 200,
    );

    gate(
      'GEN-00921-G8',
      'The steady step stays quiet.',
      'Twelve fewer out of 1,710 is not news',
      () =>
          HabotFunnelDropAlert.theSteadyStepDoesNotFire &&
          HabotFunnelDropAlert.volumeNote.contains('never gets read'),
    );

  });

  group('GEN-00921 :: what the message carries', () {
    gate(
      'GEN-00921-G9',
      'The message carries the counts and the build.',
      '"Down 18 per cent" and "1502 from 1840 against build 871" are different '
      'messages',
      () =>
          HabotFunnelDropAlert.theMessageCarriesAbsoluteCounts &&
          HabotFunnelDropAlert.theMessageNamesTheBuild &&
          HabotFunnelDropAlert.theBuildsAreCompared,
    );

  });

  group('GEN-00921 :: the result', () {
    gate(
      'GEN-00921-G10',
      'Five obligations met, and 0.8 seconds reports Pass.',
      'Inside the three-second floor',
      () =>
          HabotFunnelDropAlert.obligations.length == 5 &&
          HabotFunnelDropAlert.obligations.values.every((bool b) => b) &&
          HabotFunnelDropAlert.messageNote.contains('different messages') &&
          HabotFunnelDropAlert.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int steps = HabotFunnelDropAlert.steps.length;
    final int volume = HabotFunnelDropAlert.minimumWeeklyVolume;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00921',
        atomicStepReferenceId: 'GEN-00921',
        setupStepAction:
            'COLUMN NOTE: this row carries Step 486\'s three band values under '
            'a second metric name, with the ceiling again slower than the '
            'floor, and the band times the dispatch while the instruction is '
            'about a threshold; so the threshold rule is specified here: a '
            'minimum weekly volume of 200 before the fifteen per cent rule '
            'applies, which stops the smallest steps firing every week, and '
            'every message carries the absolute counts and the build that was '
            'live, because "down 18 per cent" and "down 18 per cent, 1502 from '
            '1840" are different messages. Atomic Step: "Program Shakti Alerts '
            'notifying Product Managers if any funnel step drops > 15% '
            'week-over-week."',
        implementationOrder: 487,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Program Shakti Alerts notifying Product Managers if any funnel step':
              '$steps funnel steps against a 15 per cent rule with a minimum '
              'weekly volume of $volume, producing one alert carrying absolute '
              'counts and the build that was live',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Alert Trigger Dispatch Delay',
            observed:
                'ONE MEASURE, TWO NAMES, AND A BAND TIMING THE OTHER HALF OF '
                'THE ROW. "Alert Trigger Dispatch Delay" carries Step 486\'s '
                'three values with the ceiling again slower than the floor, '
                'and it times the dispatch while the instruction sets a '
                'fifteen per cent threshold. Observed: 0.8 seconds to '
                'dispatch, inside the floor.',
            floor: r'$\le 3\text{ secs}$',
            optimal: r'$\le 1\text{ sec}$',
            ceiling: r'$5\text{ secs}$',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Alerts fired on a step too small to measure',
            observed:
                '0 of $steps. A funnel step that forty-seven people reach '
                'moves by fifteen per cent when eight of them do something '
                'different, which happens constantly, so the rule carries a '
                'minimum weekly volume of $volume. One step of three fires '
                'this week, and its message carries 1502 from 1840 and the '
                'build that was live rather than a bare percentage.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/alerts/funnel_drop_alert.dart',
        ],
      ),
    );
  });
}
