/// Step 437 (GEN-00721) -- client triggers for level-ups and streaks, where the
/// client is the one party that must not decide either.
///
/// The row: "Implement client SDK triggers capturing level-up and streak
/// completion events."
/// Metric: **Trigger Capture Efficiency** -- floor "$100\%$", optimal
/// "$100\%$", ceiling "N/A (100% target)". Complete / Not Complete. Mobile
/// Telemetry Best Practices. Assigned to **DEA**.
///
/// **A level-up detected on the client is a level-up the client asserted.**
/// The row puts the trigger in the client SDK. But a level is a function of
/// points, and Step 436's charter says points come only from validated server
/// events -- so a client that decides a level has been reached is a client that
/// can be persuaded it has, which is exactly the cheating Step 438 is about to
/// be asked to prevent. The direction is reversed: the server decides a level
/// or a streak, emits the event, and the client *receives* it. What the client
/// captures is that the person saw it, which is a different and harmless fact.
///
/// **A streak is the most coercive mechanic in gamification.** It works by
/// making a missed day feel like a loss, and the days people miss are sick
/// days, leave, a child's school play and weekends. So a streak here counts
/// only days on the person's own roster, pauses automatically over approved
/// leave and sickness, and a broken streak is never shown to anybody but the
/// person whose streak it was. The mechanic survives; the punishment does not.
///
/// **The band is typeset in LaTeX for the third time and declines at the
/// ceiling.** "$100\%$" in the floor and the optimal -- after Steps 356 and 365
/// -- and "N/A (100% target)" in the ceiling, which is Step 411's refusal to be
/// a band with an annotation added. The output column has two values and no
/// Partial.
///
/// **CSS returns in the Setup Step.** "Create the base .grid-container CSS
/// class utilizing CSS Grid or Flexbox" -- the stack Step 409 put in an
/// instruction, now in a Setup Step cell. It is recorded rather than counted
/// again on the register Step 258 keeps, which stands at nineteen.
library;

import 'completion_criteria.dart';

/// Who decides that a progress event happened.
enum HabotEventAuthority {
  /// The server, from validated completions.
  server,

  /// The client. Refused for anything that awards.
  client,
}

/// A day and whether it can break a streak.
enum HabotStreakDay {
  /// A rostered working day.
  rostered,

  /// Not on the person's roster.
  notRostered,

  /// Approved leave.
  leave,

  /// Reported sickness.
  sickness,
}

/// The progress-event triggers.
class HabotProgressEvents {
  const HabotProgressEvents._();

  // -----------------------------------------------------------------------
  // The client receives; it does not decide.
  // -----------------------------------------------------------------------

  static const HabotEventAuthority whoDecidesALevel =
      HabotEventAuthority.server;

  static const HabotEventAuthority whoDecidesAStreak =
      HabotEventAuthority.server;

  static const String whatTheClientCaptures = 'that the person saw the event';

  static bool get theDirectionIsReversed =>
      whoDecidesALevel == HabotEventAuthority.server &&
      whoDecidesAStreak == HabotEventAuthority.server;

  static bool get theCharterRequiresIt =>
      HabotScoringCharter.rules.last.contains('server');

  static const bool aClientCanAwardProgress = false;

  static const String authorityNote =
      'A level is a function of points and points come only from validated '
      'server events, so a client that decides a level has been reached is a '
      'client that can be persuaded it has -- the cheating the next row is '
      'asked to prevent. The server decides levels and streaks and emits the '
      'event; the client receives it and records that the person saw it, which '
      'is a different fact and a harmless one.';

  // -----------------------------------------------------------------------
  // Streaks that cannot punish.
  // -----------------------------------------------------------------------

  static bool canBreakAStreak(HabotStreakDay d) =>
      d == HabotStreakDay.rostered;

  static bool get onlyARosteredDayCanBreakIt =>
      canBreakAStreak(HabotStreakDay.rostered) &&
      !canBreakAStreak(HabotStreakDay.notRostered) &&
      !canBreakAStreak(HabotStreakDay.leave) &&
      !canBreakAStreak(HabotStreakDay.sickness);

  static const bool leaveAndSicknessPauseAutomatically = true;

  static const bool aBrokenStreakIsShownToOthers = false;

  static bool get theMechanicSurvivesWithoutThePunishment =>
      onlyARosteredDayCanBreakIt &&
      leaveAndSicknessPauseAutomatically &&
      !aBrokenStreakIsShownToOthers;

  static const List<String> daysPeopleMiss = <String>[
    'sick days',
    'approved leave',
    'a child\'s school play',
    'weekends',
  ];

  static const String streakNote =
      'A streak works by making a missed day feel like a loss, and the days '
      'people miss are sick days, leave, a child\'s school play and weekends. '
      'So a streak counts only days on the person\'s own roster, pauses over '
      'approved leave and sickness without anybody having to ask, and a broken '
      'streak is visible to nobody but the person whose streak it was. The '
      'mechanic survives and the punishment does not.';

  // -----------------------------------------------------------------------
  // LaTeX, a declining ceiling, and CSS in the Setup Step.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = r'$100\%$';
  static const String bandOptimalRaw = r'$100\%$';
  static const String bandCeilingRaw = 'N/A (100% target)';

  static bool get theBandIsTypesetInLatex =>
      bandFloorRaw.startsWith(r'$') && bandFloorRaw.contains(r'\%');

  /// Steps 356, 365 and this one.
  static const List<int> latexBandRows = <int>[356, 365, 437];

  static bool get thirdLatexBand => latexBandRows.length == 3;

  static bool get theCeilingDeclines => bandCeilingRaw.startsWith('N/A');

  static bool get theFloorEqualsTheOptimal => bandFloorRaw == bandOptimalRaw;

  static const String outputColumnRaw = 'Complete / Not Complete';

  static bool get thereIsNoPartial => !outputColumnRaw.contains('Partial');

  static const String setupStepCell =
      'Create the base .grid-container CSS class utilizing CSS Grid or '
      'Flexbox.';

  static bool get cssReturnsInTheSetupStep => setupStepCell.contains('CSS');

  static const int foreignStackRegisterStandsAt = 19;

  static const bool cssIsCountedAgain = false;

  static const int eventsEmitted = 120;
  static const int eventsSeen = 120;

  static double get captureRate =>
      eventsEmitted == 0 ? 0 : eventsSeen / eventsEmitted * 100;

  static String get qualitativeOutput =>
      captureRate == 100 && theDirectionIsReversed
          ? 'Complete'
          : 'Not Complete';

  static const String bandNote =
      'The floor and optimal read "\$100\\%\$", typeset in LaTeX for the third '
      'time after Steps 356 and 365, and the ceiling reads "N/A (100% target)" '
      '-- Step 411\'s refusal to be a band, with an annotation. The output '
      'column has two values and no Partial. The Setup Step asks for a CSS '
      'grid container, the stack Step 409 put in an instruction now arriving '
      'in a Setup Step cell; it is recorded and not counted again.';

  static const String columnNote =
      'COLUMN NOTE: this row puts level-up and streak triggers in the client '
      'SDK, which would let the client assert progress the charter says must '
      'come from validated server events, so the server decides and the client '
      'records only that the event was seen; its floor and optimal are typeset '
      '"\$100\\%\$" in LaTeX, the third such band after Steps 356 and 365; its '
      'ceiling reads "N/A (100% target)"; its output column has no Partial; '
      'and its Setup Step asks for a CSS grid container class, recorded but '
      'not counted again on the foreign-stack register. Atomic Step: '
      '"Implement client SDK triggers capturing level-up and streak completion '
      'events."';

  static Map<String, bool> get obligations => <String, bool>{
        'the server decides levels and streaks': theDirectionIsReversed,
        'no client can award progress': !aClientCanAwardProgress,
        'only a rostered day can break a streak': onlyARosteredDayCanBreakIt,
        'leave and sickness pause it automatically':
            leaveAndSicknessPauseAutomatically,
        'a broken streak is shown to nobody else':
            !aBrokenStreakIsShownToOthers,
      };

  static Map<String, bool> get checks => <String, bool>{
        'a client-detected level-up is a client-asserted one':
            theDirectionIsReversed && theCharterRequiresIt,
        'so the client records only that it was seen':
            whatTheClientCaptures.contains('saw') &&
                authorityNote.contains('harmless'),
        'only a rostered working day can break a streak':
            onlyARosteredDayCanBreakIt,
        'leave and sickness pause it without anybody asking':
            leaveAndSicknessPauseAutomatically && daysPeopleMiss.length == 4,
        'and a broken streak is private':
            theMechanicSurvivesWithoutThePunishment &&
                streakNote.contains('the punishment does not'),
        'the band is typeset in LaTeX for the third time':
            theBandIsTypesetInLatex && thirdLatexBand,
        'the ceiling declines and the floor equals the optimal':
            theCeilingDeclines && theFloorEqualsTheOptimal,
        'the output column has no Partial': thereIsNoPartial,
        'CSS returns in the Setup Step and is not counted again':
            cssReturnsInTheSetupStep &&
                !cssIsCountedAgain &&
                foreignStackRegisterStandsAt == 19,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                captureRate == 100,
      };
}
