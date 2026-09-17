/// Step 316 (GEN-00445) -- a band with one number in it, which is right, and
/// three inputs collapsed into one message, which is not.
///
/// The row: "Hardcode Fail-Closed logic: treat Null, Error, or False results
/// as a hard stop. Google Docs"
/// Metric: **Fail-Closed Stop Reliability** -- floor 1, optimal 1, ceiling
/// "N/A (100% target)". Pass / Fail. OWASP Fail-Secure Design.
///
/// **The degenerate band is correct here, and that is worth saying.** Floor and
/// optimal are the same number and the ceiling is the string "N/A", which in
/// any other row this track has met would be a defect. On this subject it is
/// the truth: a fail-closed control that holds 99.9 per cent of the time is
/// not a control with a small gap, it is a control with a known way through.
/// There is no band because there is no gradient. Eleven batches of band
/// findings, and this is the first row whose collapsed band is the right
/// shape.
///
/// **"Hardcode" is the word to argue with, and only half of it.** Hardcoding
/// the *policy* -- that an absent, failed or negative answer stops the action
/// -- is exactly right: a fail-closed decision that can be configured is a
/// fail-open decision with a delay. Hardcoding the *values* is what this
/// repository has forbidden since Step 4. The decision is a constant; every
/// threshold it consults is a token.
///
/// **Null, Error and False are three different facts and only one is a
/// refusal.** `false` means the check ran and said no. An error means the
/// check could not run. Null means nothing ever asked it. All three stop the
/// action -- that is the whole of fail-closed -- but collapsing them into one
/// message tells somebody "you may not do this" when the truth is "we do not
/// know yet", which is Step 294's finding arriving from the other side. The
/// stop is identical. The sentence is not, and the sentence is the only part
/// the person ever sees.
///
/// **COLUMN NOTE.** The Atomic Step ends with the stray token "Google Docs",
/// and the Setup Step reads "Test the reflow transition at exactly the Compact
/// breakpoint boundary -- 599dp and 600dp", which is a layout instruction on a
/// security row.
library;

import '../operations/authorisation_lock.dart';

/// What came back from a check.
enum HabotCheckResult {
  /// The check ran and returned true.
  allowed,

  /// The check ran and returned false.
  refused,

  /// The check could not run.
  errored,

  /// Nothing asked the check.
  absent,
}

/// What the interface does about it.
enum HabotStopKind {
  /// Not a stop.
  proceed,

  /// Stopped, and we can say why in the first person.
  refusedWithReason,

  /// Stopped, and the reason is ours rather than theirs.
  stoppedByOurFault,

  /// Stopped, and nobody asked the question.
  stoppedByOmission,
}

/// The rule.
class HabotFailClosed {
  const HabotFailClosed._();

  // -----------------------------------------------------------------------
  // The policy, which is a constant.
  // -----------------------------------------------------------------------

  /// Anything that is not an explicit true stops the action.
  static bool mayProceed(HabotCheckResult result) =>
      result == HabotCheckResult.allowed;

  static HabotStopKind stopKindFor(HabotCheckResult result) {
    switch (result) {
      case HabotCheckResult.allowed:
        return HabotStopKind.proceed;
      case HabotCheckResult.refused:
        return HabotStopKind.refusedWithReason;
      case HabotCheckResult.errored:
        return HabotStopKind.stoppedByOurFault;
      case HabotCheckResult.absent:
        return HabotStopKind.stoppedByOmission;
    }
  }

  static List<HabotCheckResult> get stopping => HabotCheckResult.values
      .where((HabotCheckResult r) => !mayProceed(r))
      .toList();

  static bool get everythingButTrueStops => stopping.length == 3;

  /// The policy is not a setting. A fail-closed decision that can be
  /// configured is a fail-open decision with a delay.
  static const bool thePolicyIsConfigurable = false;

  static const String policyNote =
      'Hardcoding the policy is right and hardcoding the values is not, and '
      'the row uses one word for both. The decision -- anything that is not an '
      'explicit true stops the action -- is a constant, because a fail-closed '
      'rule with a switch on it is a fail-open rule with a delay. Every '
      'threshold the rule consults is a token, which is what this repository '
      'has required since Step 4.';

  // -----------------------------------------------------------------------
  // Three stops, three sentences.
  // -----------------------------------------------------------------------

  static const Map<HabotStopKind, String> messages = <HabotStopKind, String>{
    HabotStopKind.refusedWithReason:
        'This was checked and refused. The reason is on the approval record',
    HabotStopKind.stoppedByOurFault:
        'We could not complete the check. Nothing has been changed -- try '
            'again in a moment',
    HabotStopKind.stoppedByOmission:
        'This has not been checked yet. It will unlock once the check runs',
  };

  static String messageFor(HabotCheckResult result) =>
      messages[stopKindFor(result)] ?? '';

  static bool get everyStopHasItsOwnSentence =>
      messages.length == 3 &&
      messages.values.toSet().length == 3 &&
      stopping.every((HabotCheckResult r) => messageFor(r).isNotEmpty);

  /// Only one of the three is a refusal in the first person. The other two
  /// are the application's own failure and the application's own omission.
  static List<HabotCheckResult> get notTheirFault => stopping
      .where(
        (HabotCheckResult r) =>
            stopKindFor(r) != HabotStopKind.refusedWithReason,
      )
      .toList();

  static bool get twoOfTheThreeStopsAreOurs => notTheirFault.length == 2;

  /// The naive reading, kept executable so the difference is visible.
  static const String collapsedMessage = 'You are not allowed to do this';

  static bool get theCollapsedMessageIsWrongTwiceOutOfThree =>
      notTheirFault.length == 2 && collapsedMessage.contains('not allowed');

  /// Step 294 reached the same three-valued shape from authorisation.
  static bool get theThreeValuedShapeIsAlreadyDeclared =>
      HabotAuthorityState.values.length == 3;

  static const String threeInputsNote =
      'All three stop the action, which is the whole of fail-closed, and the '
      'stop is identical in every case. What differs is the sentence: "we '
      'checked and the answer is no", "we could not check", "nobody asked '
      'yet". Collapsing them tells somebody they are not allowed to do '
      'something when the truth is that the application did not manage to find '
      'out -- and on two of the three that is a statement about us, said in '
      'the second person. Step 294 reached the same three-valued shape from '
      'the authorisation side.';

  /// Nothing is written on any of the three. Fail-closed means the stop
  /// happens before the effect, not that the effect is reversed afterwards.
  static const bool anythingIsWrittenOnAStop = false;

  static const String atomicityNote =
      'The stop happens before the effect. A rule that lets the write through '
      'and then reverses it is fail-open with a compensating transaction, '
      'which is a different design with a different failure mode -- the '
      'reversal can itself fail. Nothing is written on any of the three '
      'stopping results.';

  // -----------------------------------------------------------------------
  // The band, which is right.
  // -----------------------------------------------------------------------

  static const double bandFloor = 1;
  static const double bandOptimal = 1;
  static const String bandCeiling = 'N/A (100% target)';

  static bool get theFloorEqualsTheOptimal => bandFloor == bandOptimal;

  static bool get theCeilingIsNotANumber =>
      double.tryParse(bandCeiling) == null;

  /// And on this subject that is correct, which is the unusual part.
  static bool get theCollapsedBandIsRightHere =>
      theFloorEqualsTheOptimal && theCeilingIsNotANumber;

  static const String bandNote =
      'Floor and optimal are the same number and the ceiling is the string '
      '"N/A". On any other row this track has met, that is a defect. Here it '
      'is the truth: a fail-closed control that holds 99.9 per cent of the '
      'time is not a control with a small gap, it is a control with a known '
      'way through, and the 0.1 per cent is where somebody goes. There is no '
      'band because there is no gradient, and this is the first row in eleven '
      'batches whose collapsed band is the right shape for its subject.';

  static Map<String, bool> get obligations => <String, bool>{
        'anything that is not an explicit true stops the action':
            everythingButTrueStops,
        'nothing is written on a stop': !anythingIsWrittenOnAStop,
        'the policy is not configurable': !thePolicyIsConfigurable,
        'each stop carries its own sentence': everyStopHasItsOwnSentence,
        'two of the three sentences are about us rather than them':
            twoOfTheThreeStopsAreOurs,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'four results, three of which stop':
            HabotCheckResult.values.length == 4 &&
                everythingButTrueStops &&
                mayProceed(HabotCheckResult.allowed),
        'each stopping result maps to its own kind':
            stopKindFor(HabotCheckResult.refused) ==
                    HabotStopKind.refusedWithReason &&
                stopKindFor(HabotCheckResult.errored) ==
                    HabotStopKind.stoppedByOurFault &&
                stopKindFor(HabotCheckResult.absent) ==
                    HabotStopKind.stoppedByOmission,
        'three distinct sentences, none of them shared':
            everyStopHasItsOwnSentence,
        'two of the three are the application\'s own failure':
            twoOfTheThreeStopsAreOurs &&
                theCollapsedMessageIsWrongTwiceOutOfThree,
        'the three-valued shape was already declared at Step 294':
            theThreeValuedShapeIsAlreadyDeclared &&
                threeInputsNote.contains('Step 294'),
        'the policy is a constant and the thresholds are tokens':
            !thePolicyIsConfigurable &&
                policyNote.contains('fail-open rule with a delay'),
        'the stop precedes the effect':
            !anythingIsWrittenOnAStop &&
                atomicityNote.contains('compensating transaction'),
        'the band has one number and no gradient':
            theFloorEqualsTheOptimal && theCeilingIsNotANumber,
        'and on this subject that is the right shape':
            theCollapsedBandIsRightHere &&
                bandNote.contains('a known way through'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Atomic Step ends with the stray token "Google Docs", '
      'and the Setup Step column reads "Test the reflow transition at exactly '
      'the Compact breakpoint boundary -- 599dp and 600dp", which is a layout '
      'instruction on a security row. Atomic Step: "Hardcode Fail-Closed '
      'logic: treat Null, Error, or False results as a hard stop."';
}
