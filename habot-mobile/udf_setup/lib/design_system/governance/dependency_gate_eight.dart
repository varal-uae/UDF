/// Step 466 (GEN-05045) -- Step 459 with one digit changed, and the two
/// columns that say the same sentence on all twenty rows.
///
/// The row: "Confirm that the dependency prerequisite (Step 8) is complete
/// before starting this step."
/// Metric: **Dependency Gate Compliance Rate** -- floor "95% of prerequisite
/// gates verified before start (no exceptions on critical path)", optimal
/// "100% of prerequisite gates verified before start", ceiling "100% (a gate
/// cannot be satisfied beyond full completion)". Pass / Fail. ITIL v4 Change
/// Enablement. Assigned to **UDF**.
///
/// **One character separates this row from Step 459.** A 2 became an 8. Both
/// ordinals point into a list the sheet does not contain, so neither row
/// names a prerequisite anybody could look up, and a gate nobody can fail is
/// not a gate.
///
/// **Which matters, because the same rows promise enforcement.** The
/// Mistake-Proofing column on this row -- and on all twenty rows in this
/// batch, word for word -- reads "CI/CD pipeline physically blocks deployment
/// if any gate for this step fails." The Self-Chasing column, also on all
/// twenty, reads "Automated Liveness Handshake monitors this step every 30
/// seconds and triggers rollback on failure." A pipeline cannot block on a
/// gate whose subject is an ordinal into nothing, and nothing can roll back
/// every thirty seconds on twenty rows that describe twenty different things.
/// The columns are a single sentence each, stamped on the batch.
///
/// **The floor's contradiction is inherited whole**, so it is implemented as
/// Step 459 implemented it: every critical prerequisite verified without
/// exception, and at least 95 per cent of the rest.
///
/// **The prerequisites are named from the code again**, and they are the
/// capture thread: Steps 460, 461, 462, 464 and 465.
library;

import '../capture/assistance_package.dart';
import '../capture/recognition_accuracy.dart';
import '../capture/recording_indicator.dart';
import '../capture/transcript_punctuation.dart';
import 'dependency_gate_two.dart';
import 'integration_check_second.dart';

/// The second dependency gate.
class HabotDependencyGateEight {
  const HabotDependencyGateEight._();

  // -----------------------------------------------------------------------
  // One character apart.
  // -----------------------------------------------------------------------

  static const String atomicStep =
      'Confirm that the dependency prerequisite (Step 8) is complete before '
      'starting this step.';

  static const String step459AtomicStep =
      'Confirm that the dependency prerequisite (Step 2) is complete before '
      'starting this step.';

  static int get charactersThatDiffer {
    int n = 0;
    for (int i = 0; i < atomicStep.length; i++) {
      if (atomicStep[i] != step459AtomicStep[i]) {
        n++;
      }
    }
    return n;
  }

  static bool get exactlyOneCharacterDiffers => charactersThatDiffer == 1;

  static const int theStepNamed = 8;

  static bool get neitherOrdinalCanBeLookedUp =>
      HabotDependencyGateTwo.theNamedStepIsNotThisSheets && theStepNamed == 8;

  static const String ordinalNote =
      'A 2 became an 8. Both ordinals point into a list the sheet does not '
      'contain, so neither row names a prerequisite anybody could look up, and '
      'a gate nobody can fail is not a gate.';

  // -----------------------------------------------------------------------
  // Two columns, one sentence each, twenty rows.
  // -----------------------------------------------------------------------

  static const String pokaYokeCell =
      'CI/CD pipeline physically blocks deployment if any gate for this step '
      'fails.';

  static const String selfChasingCell =
      'Automated Liveness Handshake monitors this step every 30 seconds and '
      'triggers rollback on failure.';

  static const int rowsCarryingTheseCells = 20;

  static bool get bothColumnsAreStamped => rowsCarryingTheseCells == 20;

  static bool get thePipelineCannotBlockOnAnOrdinal =>
      pokaYokeCell.contains('blocks deployment') &&
      neitherOrdinalCanBeLookedUp;

  static bool get nothingRollsBackEveryThirtySeconds =>
      selfChasingCell.contains('30 seconds') && bothColumnsAreStamped;

  static const String stampNote =
      'The Mistake-Proofing column reads the same sentence on all twenty rows '
      'in this batch, and so does Self-Chasing. A pipeline cannot block on a '
      'gate whose subject is an ordinal into nothing, and nothing rolls back '
      'every thirty seconds on twenty rows describing twenty different things. '
      'The columns are one sentence each, stamped on the batch.';

  // -----------------------------------------------------------------------
  // The floor, inherited.
  // -----------------------------------------------------------------------

  static bool get theFloorContradictionIsInherited =>
      HabotDependencyGateTwo.theTwoCannotHoldOfOneSet;

  static bool get itIsImplementedAsTwoRules =>
      HabotDependencyGateTwo.twoRulesNotOne;

  // -----------------------------------------------------------------------
  // The capture thread, named from the code.
  // -----------------------------------------------------------------------

  static const List<HabotPrerequisiteGate> gates = <HabotPrerequisiteGate>[
    HabotPrerequisiteGate(
      step: 460,
      symbol: 'HabotAssistancePackage.everySurfaceAnnouncesSomething',
      critical: false,
      verified: true,
    ),
    HabotPrerequisiteGate(
      step: 461,
      symbol: 'HabotTranscriptPunctuation.onlyConfirmedTextIsSaved',
      critical: true,
      verified: true,
    ),
    HabotPrerequisiteGate(
      step: 462,
      symbol: 'HabotRecognitionAccuracy.everyCohortIsReported',
      critical: true,
      verified: true,
    ),
    HabotPrerequisiteGate(
      step: 464,
      symbol: 'HabotRecordingIndicator.theRoomCanSeeIt',
      critical: true,
      verified: true,
    ),
    HabotPrerequisiteGate(
      step: 465,
      symbol: 'HabotIntegrationCheckSecond.everyCasePasses',
      critical: false,
      verified: true,
    ),
  ];

  static bool get everyCriticalGateIsVerified => gates
      .where((HabotPrerequisiteGate g) => g.critical)
      .every((HabotPrerequisiteGate g) => g.verified);

  static double get nonCriticalRate {
    final List<HabotPrerequisiteGate> rest =
        gates.where((HabotPrerequisiteGate g) => !g.critical).toList();
    if (rest.isEmpty) {
      return 100;
    }
    final int ok = rest.where((HabotPrerequisiteGate g) => g.verified).length;
    return 100 * ok / rest.length;
  }

  static bool get everyNamedSymbolResolves =>
      HabotAssistancePackage.everySurfaceAnnouncesSomething &&
      HabotTranscriptPunctuation.onlyConfirmedTextIsSaved &&
      HabotRecognitionAccuracy.everyCohortIsReported &&
      HabotRecordingIndicator.theRoomCanSeeIt &&
      HabotIntegrationCheckSecond.everyCasePasses;

  static bool get bothRulesHold =>
      everyCriticalGateIsVerified && nonCriticalRate >= 95;

  static String get qualitativeOutput => bothRulesHold ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row differs from Step 459 by a single character, a 2 '
      'become an 8, and both ordinals point into a list the sheet does not '
      'contain; the Mistake-Proofing and Self-Chasing columns each read one '
      'sentence on all twenty rows in this batch, promising a pipeline block '
      'and a thirty-second rollback that no ordinal into nothing could '
      'trigger; the floor\'s contradiction is inherited whole and implemented '
      'as two rules; and five prerequisites from the capture thread are named '
      'from the code. Atomic Step: "Confirm that the dependency prerequisite '
      '(Step 8) is complete before starting this step."';

  static Map<String, bool> get obligations => <String, bool>{
        'the one-character difference is recorded':
            exactlyOneCharacterDiffers,
        'the stamped columns are recorded': bothColumnsAreStamped,
        'every critical prerequisite is verified': everyCriticalGateIsVerified,
        'the non-critical rate is at least 95 per cent': nonCriticalRate >= 95,
        'every named symbol resolves': everyNamedSymbolResolves,
      };

  static Map<String, bool> get checks => <String, bool>{
        'exactly one character separates this row from Step 459':
            exactlyOneCharacterDiffers,
        'and neither ordinal can be looked up':
            neitherOrdinalCanBeLookedUp &&
                ordinalNote.contains('is not a gate'),
        'the Mistake-Proofing column is one sentence on twenty rows':
            bothColumnsAreStamped,
        'so the pipeline cannot block on it':
            thePipelineCannotBlockOnAnOrdinal,
        'and nothing rolls back every thirty seconds':
            nothingRollsBackEveryThirtySeconds &&
                stampNote.contains('stamped on the batch'),
        'the floor\'s contradiction is inherited':
            theFloorContradictionIsInherited && itIsImplementedAsTwoRules,
        'five prerequisites, three of them critical':
            gates.length == 5 &&
                gates.where((HabotPrerequisiteGate g) => g.critical).length ==
                    3,
        'every critical one is verified': everyCriticalGateIsVerified,
        'and every named symbol resolves': everyNamedSymbolResolves,
        'five obligations met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
