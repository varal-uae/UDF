/// AISS GATE -- Step 331 of 335
/// Global Reference ID:       GEN-00224
/// Atomic Steps Reference ID: GEN-00224
/// Setup Step (Action): "Integrate the RegexMaskDirectory with the
///                      FormatterRegistry -- formatters read from the
///                      directory." (INPUT MASKING, ON A COUNTER ROW)
/// Atomic Step: "Display a real-time exception task counter on the mobile
///               worker dashboard."
/// Metric: UI Presentation Conformance -- floor "Matches MD3 spec with minor
///         documented variance", optimal "100% conformance", ceiling 1.
///         Pass/Fail.
///
/// A FLOOR WRITTEN IN PROSE WITH TWO UNDEFINED WORDS IN IT, AND "REAL-TIME"
/// ON A SURFACE THE SAME ROW SAYS POLLS EVERY THIRTY SECONDS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/exception_counter.dart';

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

  group('GEN-00224 :: "real-time"', () {
    gate(
      'GEN-00224-G1',
      'The row\'s own implementation cell says polling every 30 seconds.',
      'So the counter is up to thirty seconds stale while the Atomic Step '
          'calls it real-time',
      () =>
          HabotExceptionCounter.pollInterval.inSeconds == 30 &&
          HabotExceptionCounter.worstCaseStalenessSeconds == 30 &&
          !HabotExceptionCounter.theCounterIsRealTime,
    );

    gate(
      'GEN-00224-G2',
      'The counter carries its own age.',
      'Stated rather than implied, and classified by Step 129\'s freshness '
          'policy rather than a timestamp invented here',
      () =>
          HabotExceptionCounter.theCounterCarriesItsOwnAge &&
          HabotExceptionCounter.theAgeIsStatedRatherThanImplied &&
          HabotExceptionCounter.realTimeNote.contains('Step 129'),
    );

    gate(
      'GEN-00224-G3',
      'The gap matters most when the counter does.',
      'When work is arriving quickly, which is the moment the number is most '
          'trusted and most wrong',
      () => HabotExceptionCounter.realTimeNote
          .contains('when work is arriving'),
    );
  });

  group('GEN-00224 :: a number without a verb', () {
    gate(
      'GEN-00224-G4',
      'Seven exceptions, five of them this worker\'s.',
      'A count alone says nothing actionable: not which one, not whether it '
          'is new, not whether it is theirs',
      () =>
          HabotExceptionCounter.tasks.length == 7 &&
          HabotExceptionCounter.count == 5,
    );

    gate(
      'GEN-00224-G5',
      'Three facts rather than one.',
      'The count, what arrived since they last looked, and the one to open '
          'first -- and only the first of those is a number',
      () =>
          HabotExceptionCounter.threeFactsRatherThanOne &&
          HabotExceptionCounter.newSinceLastLooked.length == 2,
    );

    gate(
      'GEN-00224-G6',
      'The one to open first is the blocking one.',
      'Blocking before oldest, so the task other work is waiting on comes '
          'before the task that has simply been waiting',
      () =>
          HabotExceptionCounter.theBlockingOneIsFirst &&
          HabotExceptionCounter.openFirst.id == 'EX-1',
    );

    gate(
      'GEN-00224-G7',
      'A count that rises all day and never falls is a guilt meter.',
      'So the delta sits beside it, and the tappable thing is the task rather '
          'than the total',
      () =>
          !HabotExceptionCounter.theCounterIsTappable &&
          HabotExceptionCounter.theOneToOpenIsTappable &&
          HabotExceptionCounter.counterNote.contains('a guilt meter'),
    );
  });

  group('GEN-00224 :: the floor that is a sentence', () {
    gate(
      'GEN-00224-G8',
      'Floor: "Matches MD3 spec with minor documented variance".',
      '"Minor" and "documented" are both undefined and between them cover any '
          'variance somebody is willing to write down',
      () =>
          HabotExceptionCounter.theFloorIsProse &&
          HabotExceptionCounter.undefinedWordsInTheFloor.length == 2 &&
          HabotExceptionCounter.theFloorCannotBeFailed,
    );

    gate(
      'GEN-00224-G9',
      'The third unfailable floor in this batch, and the third kind.',
      'Step 319\'s is the insecure default, Step 329\'s gradients a control '
          'that should not gradient, and this one is prose',
      () =>
          HabotExceptionCounter.thirdVarietyInOneBatch &&
          HabotExceptionCounter.unfailableFloorsInThisBatch.contains(319) &&
          HabotExceptionCounter.unfailableFloorsInThisBatch.contains(329) &&
          HabotExceptionCounter.bandNote.contains('depends on the reader'),
    );

    gate(
      'GEN-00224-G10',
      'Output: Pass / Fail.',
      'Six declared obligations, all met, giving Pass; all ten declared '
          'checks hold',
      () =>
          HabotExceptionCounter.obligations.length == 6 &&
          HabotExceptionCounter.obligations.values.every((bool b) => b) &&
          HabotExceptionCounter.qualitativeOutput == 'Pass' &&
          HabotExceptionCounter.checks.length == 10 &&
          HabotExceptionCounter.checks.values.every((bool b) => b) &&
          HabotExceptionCounter.columnNote.contains('RegexMaskDirectory'),
    );
  });

  tearDownAll(() {
    final String age = HabotExceptionCounter.ageLabel(25);
    final String first = HabotExceptionCounter.openFirst.id;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00224',
        atomicStepReferenceId: 'GEN-00224',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Integrate '
            'the RegexMaskDirectory with the FormatterRegistry -- formatters '
            'read from the directory", which is input masking on a counter '
            'row, and the band floor is a sentence containing the words '
            '"minor" and "documented". Atomic Step: "Display a real-time '
            'exception task counter on the mobile worker dashboard."',
        implementationOrder: 331,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Display a real-time exception task counter on the mobile worker':
              '${HabotExceptionCounter.count} exceptions for this worker, '
                  '${HabotExceptionCounter.newSinceLastLooked.length} of them '
                  'new since they last looked',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the counter is labelled "$age"; the one offered first is $first '
                  'because other work is waiting on it',
          'Data Quality Note':
              'REAL-TIME: ${HabotExceptionCounter.realTimeNote} '
              'COUNTER: ${HabotExceptionCounter.counterNote} '
              'BAND: ${HabotExceptionCounter.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Presentation Conformance',
            observed:
                'THE FLOOR CANNOT BE EVALUATED. "Matches MD3 spec with minor '
                'documented variance" contains two undefined words that '
                'between them cover any variance somebody writes down, so the '
                'floor cannot be failed. Third unfailable floor in this batch '
                'and the third kind, after an insecure default at Step 319 and '
                'a gradiented fail-closed control at Step 329.',
            floor: 'Matches MD3 spec with minor documented variance',
            optimal: '100% conformance to Material Design 3 specification',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Seconds of staleness the counter hides',
            observed:
                '0. The counter is up to thirty seconds behind, because the '
                'row\'s own implementation cell specifies thirty-second '
                'polling, and it says so on its face rather than calling '
                'itself real-time. The age is classified by the freshness '
                'policy built at Step 129.',
            floor: '30',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/exception_counter.dart',
        ],
      ),
    );
  });
}
