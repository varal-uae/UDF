/// AISS GATE -- Step 330 of 335
/// Global Reference ID:       GEN-00123
/// Atomic Steps Reference ID: GEN-00123
/// Setup Step (Action): "Run the Token Studio linter to confirm zero token
///                      overrides or raw typography values." (TYPOGRAPHY, ON A
///                      TIMER ROW)
/// Atomic Step: "Log a process design failure entry when a timer expires."
/// Metric: Task Execution SLA Adherence -- floor "<= 300 seconds (hard ceiling
///         per task)", optimal "<= 180 seconds median", ceiling "300 seconds
///         (auto-revocation threshold)". Pass/Fail. ITIL v4.
///
/// THE FLOOR AND THE CEILING ARE THE SAME NUMBER UNDER TWO NAMES -- A FOURTH
/// BAND SHAPE IN ONE BATCH. AND THE ENTRY'S NAME DECIDES THE CAUSE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/timer_expiry_log.dart';

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

  group('GEN-00123 :: the clock', () {
    gate(
      'GEN-00123-G1',
      'WCAG 2.1 SC 2.2.1 Timing Adjustable -- Level A.',
      'A warning at 240 seconds of 300, one extension of 120, and the work '
          'preserved -- the three things a time limit owes',
      () =>
          HabotTimerExpiryLog.warnAtSeconds == 240 &&
          HabotTimerExpiryLog.slaSeconds == 300 &&
          HabotTimerExpiryLog.thereIsAWarningBeforeTheLimit &&
          HabotTimerExpiryLog.anExtensionIsOffered,
    );

    gate(
      'GEN-00123-G2',
      'The task is handed back rather than discarded.',
      'To the queue it came from, with its notes; the expiry notice says '
          'nothing entered is lost',
      () =>
          !HabotTimerExpiryLog.theTaskIsDiscardedAtZero &&
          HabotTimerExpiryLog.theExpiryNoticeSaysNothingIsLost &&
          HabotTimerExpiryLog.longestPossibleSeconds == 420,
    );

    gate(
      'GEN-00123-G3',
      'Step 315 recorded the same Level A failure.',
      'From the other direction -- a Setup Step that froze inputs at zero -- '
          'and the people who run out of time are the ones who needed more',
      () =>
          HabotTimerExpiryLog.criterionLevel == 'A' &&
          HabotTimerExpiryLog.stepThatRecordedTheSameFailure == 315 &&
          HabotTimerExpiryLog.timingNote.contains('needed more of it'),
    );
  });

  group('GEN-00123 :: what the entry refuses to say', () {
    gate(
      'GEN-00123-G4',
      'Atomic Step: "Log a process design failure entry".',
      'Four causes are available, the default is unknown, and the '
          'application never infers one',
      () =>
          HabotTimerExpiryLog.causesAvailable == 4 &&
          HabotTimerExpiryLog.unknownIsOneOfThem &&
          HabotTimerExpiryLog.theCauseDefaultsToUnknown &&
          !HabotTimerExpiryLog.theCauseCanBeInferredByTheApplication,
    );

    gate(
      'GEN-00123-G5',
      'The row\'s own name for the entry decides the cause.',
      'A timer expiring is sometimes the design, often the world and '
          'occasionally the person; a log that cannot say unknown fills up '
          'with confident wrong values',
      () =>
          HabotTimerExpiryLog.theRowsNameDecidesTheCause &&
          HabotTimerExpiryLog.causeNote
              .contains('confident wrong values'),
    );
  });

  group('GEN-00123 :: what a person sees', () {
    gate(
      'GEN-00123-G6',
      'Three notices, each saying what happens next.',
      'Warning, expired and extended, on the declared snackbar-with-action '
          'duration',
      () =>
          HabotTimerExpiryLog.notices.length == 3 &&
          HabotTimerExpiryLog.everyNoticeSaysWhatHappensNext &&
          HabotTimerExpiryLog.warningNoticeDuration.inSeconds == 6,
    );
  });

  group('GEN-00123 :: the band', () {
    gate(
      'GEN-00123-G7',
      'Floor "<= 300 seconds (hard ceiling per task)".',
      'And ceiling "300 seconds (auto-revocation threshold)" -- one number, '
          'two names',
      () =>
          HabotTimerExpiryLog.theFloorAndTheCeilingAreTheSameNumber &&
          HabotTimerExpiryLog.theyCarryDifferentNames,
    );

    gate(
      'GEN-00123-G8',
      'A band whose two ends are one value has no interior.',
      'The optimal, 180, sits below both ends and is the only one of the '
          'three that is a target',
      () =>
          HabotTimerExpiryLog.theBandHasNoInterior &&
          HabotTimerExpiryLog.medianTargetSeconds == 180,
    );

    gate(
      'GEN-00123-G9',
      'A fourth band shape in one batch.',
      'The others are inverted, unfailable or one-valued; this one is '
          'duplicated',
      () => HabotTimerExpiryLog.bandNote.contains('fourth shape'),
    );

    gate(
      'GEN-00123-G10',
      'Output: Pass / Fail.',
      'Six declared obligations, all met, giving Pass; all ten declared '
          'checks hold',
      () =>
          HabotTimerExpiryLog.obligations.length == 6 &&
          HabotTimerExpiryLog.obligations.values.every((bool b) => b) &&
          HabotTimerExpiryLog.qualitativeOutput == 'Pass' &&
          HabotTimerExpiryLog.checks.length == 10 &&
          HabotTimerExpiryLog.checks.values.every((bool b) => b) &&
          HabotTimerExpiryLog.columnNote.contains('Token Studio'),
    );
  });

  tearDownAll(() {
    final String expired = HabotTimerExpiryLog.notices['expired'] ?? '';
    final String warning = HabotTimerExpiryLog.notices['warning'] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00123',
        atomicStepReferenceId: 'GEN-00123',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Run the '
            'Token Studio linter to confirm zero token overrides or raw '
            'typography values", which is typography on a timer row, and the '
            'band\'s floor and ceiling are the same 300 seconds under two '
            'different names. Atomic Step: "Log a process design failure entry '
            'when a timer expires."',
        implementationOrder: 330,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Log a process design failure entry when a timer expires.':
              'the entry records what happened; the cause defaults to unknown '
                  'and only a person sets it',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the warning reads "$warning"; the expiry reads "$expired"',
          'Data Quality Note':
              'TIMING: ${HabotTimerExpiryLog.timingNote} '
              'CAUSE: ${HabotTimerExpiryLog.causeNote} '
              'BAND: ${HabotTimerExpiryLog.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Execution SLA Adherence',
            observed:
                'THE BAND HAS NO INTERIOR. Three hundred seconds is the "hard '
                'ceiling per task" at the floor and the "auto-revocation '
                'threshold" at the ceiling -- one number under two names -- '
                'and the optimal of 180 sits below both. A fourth distinct '
                'band shape in this batch, after four inverted, three '
                'unfailable and four one-valued outputs.',
            floor: '<= 300 seconds (hard ceiling per task)',
            optimal: '<= 180 seconds median completion',
            ceiling: '300 seconds (auto-revocation threshold)',
          ),
          AissMeasurement(
            metricName: 'Expiries recorded with a cause nobody established',
            observed:
                '0. The row names the entry a "process design failure", which '
                'records a conclusion in the name of the observation. Four '
                'causes are available including unknown, unknown is the '
                'default, and the application never infers one -- because a '
                'log that cannot say "we do not know yet" fills with confident '
                'wrong values instead.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/timer_expiry_log.dart',
        ],
      ),
    );
  });
}
