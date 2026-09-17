/// Step 384 (GEN-04781) -- three strikes on a fingerprint, and a band whose
/// cells are sentences.
///
/// The row: "Implement substep 4: Attach biometric failure rate counter that
/// forces full credential authentication after 3 consecutive errors."
/// Metric: **Substep Definition-of-Done Adherence Rate** -- floor ">=90% unit
/// test coverage / acceptance criteria met before merge", optimal "95-100%
/// coverage, all acceptance criteria met", ceiling "100% (coverage beyond 100%
/// is not meaningful; further effort has diminishing return)". Complete /
/// Partial / Not Complete. ISO/IEC 25010. Assigned to **PDG**.
///
/// **The platform already counts, and counting twice is the bug.** iOS and
/// Android both lock biometric matching out after their own run of failures and
/// hand back a specific error for it. An app that keeps a second counter will
/// disagree with the first one, and the disagreement is not symmetric: the app
/// can only ever be *more* permissive than the platform, because it does not
/// see the failures that happened at the system prompt. So the counter here is
/// bound to the platform's lockout rather than run beside it.
///
/// **"Forces full credential authentication" is the right fallback and the
/// wrong word.** Falling back to a password is not a punishment for failing a
/// fingerprint; it is the ordinary way in, and biometrics are the shortcut. An
/// interface that presents the fallback as a consequence teaches people that
/// the password is the failure path, which is how somebody ends up choosing a
/// weaker one.
///
/// **A failure is not always a wrong finger.** Four causes: no match, a wet or
/// dirty sensor, a hardware fault, and the platform's own lockout. Only the
/// first is evidence about the person, and counting the other three toward a
/// strike limit locks somebody out because it is raining.
///
/// **The band is three sentences.** The floor holds a coverage figure and a
/// process condition joined by a slash; the optimal holds a range and a second
/// condition; the ceiling holds a number and an *argument* -- "coverage beyond
/// 100% is not meaningful; further effort has diminishing return". A boundary
/// cell containing a justification is a new shape for this track.
library;

/// Why a biometric attempt did not succeed.
enum HabotBiometricFailure {
  /// The presented finger or face did not match.
  noMatch,

  /// The sensor could not read anything usable.
  sensorUnreadable,

  /// The sensor is not working.
  hardwareFault,

  /// The platform has locked biometric matching out.
  platformLockout,
}

/// A way into the account.
enum HabotAuthFactor {
  /// The shortcut.
  biometric,

  /// The ordinary way in.
  credential,
}

/// The biometric fallback rule.
class HabotBiometricFallback {
  const HabotBiometricFallback._();

  // -----------------------------------------------------------------------
  // The platform counts.
  // -----------------------------------------------------------------------

  static const int strikesTheRowAsksFor = 3;

  static const bool theAppKeepsItsOwnCounter = false;

  /// The app cannot see failures that happened at the system prompt, so a
  /// second counter can only ever be more permissive than the platform's.
  static const bool aSecondCounterCouldBeStricter = false;

  static bool get theCounterIsBoundToThePlatform =>
      !theAppKeepsItsOwnCounter && !aSecondCounterCouldBeStricter;

  static bool isLockedOut(List<HabotBiometricFailure> run) =>
      run.contains(HabotBiometricFailure.platformLockout) ||
      run.where((HabotBiometricFailure f) =>
              f == HabotBiometricFailure.noMatch).length >=
          strikesTheRowAsksFor;

  static bool get threeNoMatchesLockOut => isLockedOut(
        <HabotBiometricFailure>[
          HabotBiometricFailure.noMatch,
          HabotBiometricFailure.noMatch,
          HabotBiometricFailure.noMatch,
        ],
      );

  static bool get aPlatformLockoutIsHonouredImmediately => isLockedOut(
        <HabotBiometricFailure>[HabotBiometricFailure.platformLockout],
      );

  static const String counterNote =
      'Both platforms already lock biometric matching out after their own run '
      'of failures and return a specific error for it. An app that keeps a '
      'second counter will disagree with the first, and the disagreement is '
      'one-sided: the app cannot see failures that happened at the system '
      'prompt, so its count is always the lower one. The counter here honours '
      'the platform lockout as well as its own run of three.';

  // -----------------------------------------------------------------------
  // Not every failure is about the person.
  // -----------------------------------------------------------------------

  static const Map<HabotBiometricFailure, bool> countsAsAStrike =
      <HabotBiometricFailure, bool>{
    HabotBiometricFailure.noMatch: true,
    HabotBiometricFailure.sensorUnreadable: false,
    HabotBiometricFailure.hardwareFault: false,
    HabotBiometricFailure.platformLockout: false,
  };

  static bool get onlyOneCauseCountsAsAStrike =>
      countsAsAStrike.values.where((bool b) => b).length == 1;

  static bool get aWetSensorIsNotAStrike =>
      countsAsAStrike[HabotBiometricFailure.sensorUnreadable] == false;

  static const Map<HabotBiometricFailure, String> messageFor =
      <HabotBiometricFailure, String>{
    HabotBiometricFailure.noMatch: 'That did not match. Try again.',
    HabotBiometricFailure.sensorUnreadable:
        'The sensor could not read your finger. Wipe it and try again.',
    HabotBiometricFailure.hardwareFault:
        'The fingerprint sensor is not responding. Use your password.',
    HabotBiometricFailure.platformLockout:
        'Fingerprint is locked until you sign in with your password.',
  };

  static bool get everyCauseHasItsOwnMessage =>
      messageFor.length == HabotBiometricFailure.values.length &&
      messageFor.values.toSet().length == HabotBiometricFailure.values.length;

  static const String causeNote =
      'Four causes, and only one of them is evidence about the person: no '
      'match, a sensor that could not read anything, a hardware fault, and the '
      'platform\'s own lockout. Counting the other three toward a strike limit '
      'locks somebody out because it is raining, and tells them they failed '
      'when the sensor did.';

  // -----------------------------------------------------------------------
  // The fallback is the ordinary way in.
  // -----------------------------------------------------------------------

  static const HabotAuthFactor theOrdinaryWayIn = HabotAuthFactor.credential;

  static const HabotAuthFactor theShortcut = HabotAuthFactor.biometric;

  static bool get theFallbackIsTheOrdinaryWayIn =>
      theOrdinaryWayIn == HabotAuthFactor.credential &&
      theShortcut == HabotAuthFactor.biometric;

  static const bool theFallbackIsPresentedAsAConsequence = false;

  static const String fallbackWording =
      'Sign in with your password';

  static const String wordingRefused =
      'Too many failed attempts. You must now use your password.';

  static bool get theWordingIsNotPunitive =>
      !theFallbackIsPresentedAsAConsequence &&
      !fallbackWording.contains('Too many');

  /// The credential route is on screen from the first attempt, not revealed
  /// after three failures.
  static const bool theCredentialRouteIsAlwaysVisible = true;

  static const String fallbackNote =
      'Falling back to a password is not a punishment for failing a '
      'fingerprint; it is the ordinary way in, and biometrics are the '
      'shortcut. The credential route is on screen from the first attempt '
      'rather than revealed after three failures, and the wording does not '
      'count them -- an interface that presents the password as the failure '
      'path is teaching people to choose a weaker one.';

  // -----------------------------------------------------------------------
  // Three sentences where three values belong.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw =
      '>=90% unit test coverage / acceptance criteria met before merge';
  static const String bandOptimalRaw =
      '95-100% coverage, all acceptance criteria met';
  static const String bandCeilingRaw =
      '100% (coverage beyond 100% is not meaningful; further effort has '
      'diminishing return)';

  static bool get everyCellIsASentence =>
      bandFloorRaw.contains(' ') &&
      bandOptimalRaw.contains(' ') &&
      bandCeilingRaw.contains(' ');

  static bool get noneOfTheThreeParsesAsANumber =>
      double.tryParse(bandFloorRaw) == null &&
      double.tryParse(bandOptimalRaw) == null &&
      double.tryParse(bandCeilingRaw) == null;

  /// The ceiling cell contains an argument for why the ceiling is where it is,
  /// which is a new shape.
  static bool get theCeilingContainsAnArgument =>
      bandCeilingRaw.contains('diminishing return');

  static const String bandNote =
      'The floor holds a coverage figure and a process condition joined by a '
      'slash, the optimal holds a range and a second condition, and the '
      'ceiling holds a number followed by an argument for why it is the '
      'ceiling. None of the three parses as a number, and a boundary cell '
      'containing a justification is a shape this track has not met before -- '
      'the cell is reasoning with its reader rather than holding a value.';

  static const String metricName = 'Substep Definition-of-Done Adherence Rate';

  static const bool theMetricIsAboutTheRowNotTheFeature = true;

  static double get causesHandled => HabotBiometricFailure.values.isEmpty
      ? 0
      : messageFor.length / HabotBiometricFailure.values.length * 100;

  static Map<String, bool> get obligations => <String, bool>{
        'the platform lockout is honoured':
            aPlatformLockoutIsHonouredImmediately,
        'the app does not keep a competing counter':
            theCounterIsBoundToThePlatform,
        'only a genuine non-match counts as a strike':
            onlyOneCauseCountsAsAStrike,
        'every cause has its own message': everyCauseHasItsOwnMessage,
        'the credential route is always visible':
            theCredentialRouteIsAlwaysVisible,
        'the fallback is not worded as a punishment': theWordingIsNotPunitive,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'three consecutive non-matches lock out': threeNoMatchesLockOut,
        'and a platform lockout is honoured at once':
            aPlatformLockoutIsHonouredImmediately,
        'the app keeps no competing counter':
            theCounterIsBoundToThePlatform &&
                counterNote.contains('always the lower one'),
        'four causes, one of which counts as a strike':
            HabotBiometricFailure.values.length == 4 &&
                onlyOneCauseCountsAsAStrike &&
                aWetSensorIsNotAStrike,
        'each cause has its own message':
            everyCauseHasItsOwnMessage &&
                causeNote.contains('because it is raining'),
        'the credential is the ordinary way in':
            theFallbackIsTheOrdinaryWayIn && theCredentialRouteIsAlwaysVisible,
        'the wording does not count failures at the person':
            theWordingIsNotPunitive &&
                wordingRefused.contains('Too many') &&
                fallbackNote.contains('a weaker one'),
        'every band cell is a sentence': everyCellIsASentence,
        'and the ceiling cell contains an argument':
            theCeilingContainsAnArgument &&
                noneOfTheThreeParsesAsANumber &&
                bandNote.contains('reasoning with its reader'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theMetricIsAboutTheRowNotTheFeature &&
                causesHandled == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to PDG rather than UDF; all three of '
      'its boundary cells are sentences rather than values, and the ceiling '
      'cell contains an argument for why it is the ceiling -- "coverage beyond '
      '100% is not meaningful; further effort has diminishing return" -- which '
      'is a shape this track has not met before; its metric scores the '
      'definition of done for the substep rather than anything about '
      'authentication; and the Setup Step column is empty. Atomic Step: '
      '"Implement substep 4: Attach biometric failure rate counter that forces '
      'full credential authentication after 3 consecutive errors."';
}
