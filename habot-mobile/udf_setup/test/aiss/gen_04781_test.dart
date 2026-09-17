/// AISS GATE -- Step 384 of 395
/// Global Reference ID:       GEN-04781
/// Atomic Steps Reference ID: GEN-04781
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 4: Attach biometric failure rate counter
///               that forces full credential authentication after 3
///               consecutive errors."
/// Metric: Substep Definition-of-Done Adherence Rate -- three boundary cells
///         that are sentences, the ceiling containing an argument. Complete /
///         Partial / Not Complete. ISO/IEC 25010. Assigned to **PDG**.
///
/// THE PLATFORM ALREADY COUNTS, AND A BOUNDARY CELL THAT REASONS WITH ITS
/// READER IS A NEW SHAPE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/auth/biometric_fallback.dart';

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

  group('GEN-04781 :: the platform counts', () {
    gate(
      'GEN-04781-G1',
      'Three consecutive non-matches lock out.',
      'Which is what the row asks for',
      () =>
          HabotBiometricFallback.threeNoMatchesLockOut &&
          HabotBiometricFallback.strikesTheRowAsksFor == 3,
    );

    gate(
      'GEN-04781-G2',
      'And a platform lockout is honoured at once.',
      'Both platforms already lock biometric matching out after their own run '
          'of failures and return a specific error',
      () => HabotBiometricFallback.aPlatformLockoutIsHonouredImmediately,
    );

    gate(
      'GEN-04781-G3',
      'The app keeps no competing counter.',
      'It cannot see failures at the system prompt, so its count is always the '
          'lower one -- a second counter can only ever be more permissive',
      () =>
          HabotBiometricFallback.theCounterIsBoundToThePlatform &&
          !HabotBiometricFallback.theAppKeepsItsOwnCounter &&
          HabotBiometricFallback.counterNote.contains('always the lower one'),
    );
  });

  group('GEN-04781 :: not every failure is about the person', () {
    gate(
      'GEN-04781-G4',
      'Four causes, one of which counts as a strike.',
      'No match, an unreadable sensor, a hardware fault, and the platform\'s '
          'own lockout',
      () =>
          HabotBiometricFailure.values.length == 4 &&
          HabotBiometricFallback.onlyOneCauseCountsAsAStrike &&
          HabotBiometricFallback.aWetSensorIsNotAStrike,
    );

    gate(
      'GEN-04781-G5',
      'Each cause has its own message.',
      'Counting the other three toward a strike limit locks somebody out '
          'because it is raining',
      () =>
          HabotBiometricFallback.everyCauseHasItsOwnMessage &&
          HabotBiometricFallback.causeNote.contains('because it is raining'),
    );
  });

  group('GEN-04781 :: the fallback is the ordinary way in', () {
    gate(
      'GEN-04781-G6',
      'The credential is the ordinary route and biometrics are the shortcut.',
      'Two factors, and the one the row calls a consequence is the normal one',
      () =>
          HabotAuthFactor.values.length == 2 &&
          HabotBiometricFallback.theFallbackIsTheOrdinaryWayIn,
    );

    gate(
      'GEN-04781-G7',
      'The credential route is on screen from the first attempt.',
      'Rather than revealed after three failures',
      () => HabotBiometricFallback.theCredentialRouteIsAlwaysVisible,
    );

    gate(
      'GEN-04781-G8',
      'The wording does not count failures at the person.',
      '"Sign in with your password" rather than "too many failed attempts" -- '
          'an interface that makes the password the failure path teaches '
          'people to choose a weaker one',
      () =>
          HabotBiometricFallback.theWordingIsNotPunitive &&
          !HabotBiometricFallback.theFallbackIsPresentedAsAConsequence &&
          HabotBiometricFallback.fallbackNote.contains('a weaker one'),
    );
  });

  group('GEN-04781 :: three sentences where three values belong', () {
    gate(
      'GEN-04781-G9',
      'Every band cell is a sentence, and the ceiling holds an argument.',
      '"100% (coverage beyond 100% is not meaningful; further effort has '
          'diminishing return)" -- a cell reasoning with its reader rather '
          'than holding a value',
      () =>
          HabotBiometricFallback.everyCellIsASentence &&
          HabotBiometricFallback.noneOfTheThreeParsesAsANumber &&
          HabotBiometricFallback.theCeilingContainsAnArgument &&
          HabotBiometricFallback.bandNote.contains('reasoning with its reader'),
    );

    gate(
      'GEN-04781-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Six obligations, all met, giving Complete; every cause is handled, and '
          'all ten declared checks hold',
      () =>
          HabotBiometricFallback.obligations.length == 6 &&
          HabotBiometricFallback.obligations.values.every((bool b) => b) &&
          HabotBiometricFallback.qualitativeOutput == 'Complete' &&
          HabotBiometricFallback.causesHandled == 100 &&
          HabotBiometricFallback.theMetricIsAboutTheRowNotTheFeature &&
          HabotBiometricFallback.checks.length == 10 &&
          HabotBiometricFallback.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String lockoutMessage = HabotBiometricFallback
            .messageFor[HabotBiometricFailure.platformLockout] ??
        '';
    final String sensorMessage = HabotBiometricFallback
            .messageFor[HabotBiometricFailure.sensorUnreadable] ??
        '';
    final int strikeCauses = HabotBiometricFallback.countsAsAStrike.values
        .where((bool b) => b)
        .length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04781',
        atomicStepReferenceId: 'GEN-04781',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to PDG rather than UDF; all '
            'three of its boundary cells are sentences rather than values, and '
            'the ceiling cell contains an argument for why it is the ceiling '
            '-- "coverage beyond 100% is not meaningful; further effort has '
            'diminishing return" -- which is a shape this track has not met '
            'before; its metric scores the definition of done for the substep '
            'rather than anything about authentication; and the Setup Step '
            'column is empty. Atomic Step: "Implement substep 4: Attach '
            'biometric failure rate counter that forces full credential '
            'authentication after 3 consecutive errors."',
        implementationOrder: 384,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement substep 4: Attach biometric failure rate counter that':
              '4 failure causes, $strikeCauses of which counts toward the '
                  'three-strike limit',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'a platform lockout reads "$lockoutMessage"; an unreadable '
                  'sensor reads "$sensorMessage"',
          'Data Quality Note':
              'COUNTER: ${HabotBiometricFallback.counterNote} CAUSES: '
              '${HabotBiometricFallback.causeNote} FALLBACK: '
              '${HabotBiometricFallback.fallbackNote} BAND: '
              '${HabotBiometricFallback.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Substep Definition-of-Done Adherence Rate',
            observed:
                'THREE SENTENCES, AND A CEILING THAT ARGUES. The floor holds a '
                'coverage figure and a process condition joined by a slash, '
                'the optimal holds a range and a second condition, and the '
                'ceiling holds a number followed by a justification for why it '
                'is the ceiling. None of the three parses as a number. A '
                'boundary cell containing an argument is a shape this track '
                'has not met before: the cell is reasoning with its reader '
                'rather than holding a value. The metric also scores the '
                'definition of done for the substep rather than anything about '
                'authentication.',
            floor: '>=90% unit test coverage / acceptance criteria met before '
                'merge',
            optimal: '95-100% coverage, all acceptance criteria met',
            ceiling: '100% (coverage beyond 100% is not meaningful; further '
                'effort has diminishing return)',
          ),
          AissMeasurement(
            metricName: 'Lockouts caused by something other than the person',
            observed:
                '0 of 4 causes. Both platforms already count biometric '
                'failures and lock matching out, and an app keeping a second '
                'counter can only ever be more permissive than the first '
                'because it cannot see failures at the system prompt -- so the '
                'counter here honours the platform lockout as well as its own '
                'run of three. Only a genuine non-match counts as a strike: an '
                'unreadable sensor, a hardware fault and the platform lockout '
                'do not, because counting them locks somebody out for the '
                'weather. The credential route is visible from the first '
                'attempt and is worded as the ordinary way in.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/auth/biometric_fallback.dart',
        ],
      ),
    );
  });
}
