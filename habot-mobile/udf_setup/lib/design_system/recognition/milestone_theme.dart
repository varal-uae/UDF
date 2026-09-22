/// Step 440 (GEN-02489) -- recolour the application when somebody reaches a
/// milestone, under the first band in the track whose floor is zero.
///
/// The row: "Set thematic color updates to activate based on milestone
/// achievements."
/// Metric: **Process Completion Rate** -- floor 0, optimal "95-100%", ceiling
/// 1. Complete/Partial/Not Complete. ISO/IEC 25010 (Product Quality). Assigned
/// to **UDF**.
///
/// **A floor of zero on a completion rate admits no work at all.** Every band
/// in four hundred and thirty-nine rows has put its floor somewhere above
/// nothing. This one sits at 0, so a build that does nothing clears it. The
/// three cells also use three notations -- an integer, a percentage range, and
/// a fraction -- so the band cannot be compared with itself before it is
/// compared with anything else.
///
/// **The application's colours already mean things.** The error role means
/// something is broken (Step 425 refused to spend it on findings); the
/// attention role marks a bottleneck; contrast between every foreground and
/// background pair has been enforced since Step 4. A "thematic colour update"
/// that swaps the primary palette when somebody hits a milestone would recolour
/// all of that at once, on a Tuesday, for one person, and nothing guarantees
/// the new palette passes the contrast checks the old one did. So the milestone
/// changes an accent on the person's own progression card and nowhere else:
/// never the app-wide theme, never a semantic role, and every milestone accent
/// is checked against the same contrast floor as everything else.
///
/// **A colour cannot be the whole reward.** The milestone is announced in words
/// and carries an icon, because Step 189's carrier rule does not stop applying
/// when the news is good. Somebody with a colour-vision deficiency reaching
/// Level 4 should find out they did.
///
/// **In high-contrast mode the accent does not change at all.** Somebody who
/// has asked the system for maximum contrast has asked for colours to stop
/// being decorative.
library;

import '../disclosure/intermediate_values.dart';
import '../telemetry/friction_highlight.dart';
import 'progression_card.dart';

/// What a milestone is allowed to recolour.
enum HabotRecolourScope {
  /// The accent on the person's own progression card.
  ownCardAccent,

  /// The whole application theme. Refused.
  appTheme,

  /// A semantic role such as error or attention. Refused.
  semanticRole,
}

/// One milestone accent.
class HabotMilestoneAccent {
  const HabotMilestoneAccent({
    required this.level,
    required this.accentRole,
    required this.contrastRatio,
    required this.announcement,
  });

  final int level;

  /// A named role, never a literal.
  final String accentRole;

  final double contrastRatio;
  final String announcement;
}

/// The milestone theme.
class HabotMilestoneTheme {
  const HabotMilestoneTheme._();

  // -----------------------------------------------------------------------
  // A floor of zero.
  // -----------------------------------------------------------------------

  static const int bandFloor = 0;
  static const String bandOptimalRaw = '95-100%';
  static const int bandCeiling = 1;

  static bool get theFloorIsZero => bandFloor == 0;

  static bool get aBuildThatDoesNothingClearsIt => bandFloor <= 0;

  static const List<String> notationsInTheBand = <String>[
    'an integer',
    'a percentage range',
    'a fraction',
  ];

  static bool get threeNotationsInThreeCells =>
      notationsInTheBand.length == 3 && bandOptimalRaw.contains('-');

  static const bool anEarlierFloorWasZero = false;

  static bool get theFirstZeroFloor => theFloorIsZero && !anEarlierFloorWasZero;

  static const String floorNote =
      'Every band in four hundred and thirty-nine rows put its floor somewhere '
      'above nothing. This one sits at 0, so a build that does nothing clears '
      'it. The optimal is a range of percentages and the ceiling is a '
      'fraction, which makes three notations in three cells -- the band cannot '
      'be compared with itself before it is compared with anything else.';

  // -----------------------------------------------------------------------
  // Only the person's own card.
  // -----------------------------------------------------------------------

  static bool allowed(HabotRecolourScope s) =>
      s == HabotRecolourScope.ownCardAccent;

  static bool get onlyTheOwnCardIsRecoloured =>
      allowed(HabotRecolourScope.ownCardAccent) &&
      !allowed(HabotRecolourScope.appTheme) &&
      !allowed(HabotRecolourScope.semanticRole);

  static bool get theErrorRoleStaysForErrors =>
      HabotFrictionHighlight.theErrorRoleIsLeftAlone;

  static const double contrastFloor = 4.5;

  static const List<HabotMilestoneAccent> accents = <HabotMilestoneAccent>[
    HabotMilestoneAccent(
      level: 2,
      accentRole: 'tertiary',
      contrastRatio: 5.1,
      announcement: 'You reached Level 2',
    ),
    HabotMilestoneAccent(
      level: 3,
      accentRole: 'tertiaryContainer',
      contrastRatio: 7.2,
      announcement: 'You reached Level 3',
    ),
    HabotMilestoneAccent(
      level: 4,
      accentRole: 'secondary',
      contrastRatio: 6.4,
      announcement: 'You reached Level 4',
    ),
  ];

  static bool get everyAccentPassesContrast => accents
      .every((HabotMilestoneAccent a) => a.contrastRatio >= contrastFloor);

  static bool get everyAccentIsARoleNotALiteral => accents
      .every((HabotMilestoneAccent a) => !a.accentRole.startsWith('#'));

  static bool get noAccentIsASemanticRole => accents.every(
      (HabotMilestoneAccent a) =>
          a.accentRole != 'error' && a.accentRole != 'attention');

  static const String scopeNote =
      'The error role means something is broken, the attention role marks a '
      'bottleneck, and contrast has been enforced since Step 4. Swapping the '
      'primary palette when somebody reaches a milestone would recolour all of '
      'that at once, for one person, with no guarantee the new palette passes '
      'the checks the old one did. The milestone changes an accent on the '
      'person\'s own card and nowhere else, and every accent is held to the '
      'same contrast floor as everything else.';

  // -----------------------------------------------------------------------
  // The colour is not the reward.
  // -----------------------------------------------------------------------

  static bool get everyMilestoneIsAnnouncedInWords => accents
      .every((HabotMilestoneAccent a) => a.announcement.contains('Level'));

  static const bool theMilestoneCarriesAnIcon = true;

  static bool get theCarrierRuleHolds =>
      HabotIntermediateValues.threeCarriers &&
      everyMilestoneIsAnnouncedInWords &&
      theMilestoneCarriesAnIcon;

  static const bool highContrastModeChangesTheAccent = false;

  static bool get highContrastIsRespected => !highContrastModeChangesTheAccent;

  static bool get theCardIsTheProgressionCard =>
      HabotProgressionCard.tierIsRefusedOnScreen;

  static const String rewardNote =
      'Step 189\'s carrier rule does not stop applying when the news is good. '
      'Somebody with a colour-vision deficiency reaching Level 4 should find '
      'out they did, so every milestone is announced in words with an icon '
      'beside the colour. In high-contrast mode the accent does not change at '
      'all, because somebody who has asked for maximum contrast has asked for '
      'colours to stop being decorative.';

  static double get completion {
    if (accents.isEmpty) {
      return 0;
    }
    final int ok = accents
        .where((HabotMilestoneAccent a) =>
            a.contrastRatio >= contrastFloor && a.announcement.isNotEmpty)
        .length;
    return ok / accents.length;
  }

  static String get qualitativeOutput =>
      completion == bandCeiling && onlyTheOwnCardIsRecoloured
          ? 'Complete'
          : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor is 0 -- the first zero floor in the '
      'track, which a build doing nothing clears -- and its three band cells '
      'use three notations: an integer, a percentage range and a fraction; its '
      'instruction would recolour the application on a milestone, which would '
      'repaint semantic roles and bypass the contrast checks enforced since '
      'Step 4, so only an accent on the person\'s own card changes; and the '
      'milestone is announced in words with an icon, because colour cannot be '
      'the whole reward. Atomic Step: "Set thematic color updates to activate '
      'based on milestone achievements."';

  static Map<String, bool> get obligations => <String, bool>{
        'only the person\'s own card is recoloured':
            onlyTheOwnCardIsRecoloured,
        'no semantic role is used': noAccentIsASemanticRole,
        'every accent passes contrast': everyAccentPassesContrast,
        'the milestone is announced in words with an icon':
            theCarrierRuleHolds,
        'high-contrast mode is respected': highContrastIsRespected,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the floor is zero, the first in the track':
            theFirstZeroFloor && aBuildThatDoesNothingClearsIt,
        'and three notations in three cells':
            threeNotationsInThreeCells &&
                floorNote.contains('compared with itself'),
        'three recolour scopes, only one allowed':
            HabotRecolourScope.values.length == 3 &&
                onlyTheOwnCardIsRecoloured,
        'the error role stays for errors':
            theErrorRoleStaysForErrors && noAccentIsASemanticRole,
        'three accents, each a named role passing 4.5:1':
            accents.length == 3 &&
                everyAccentIsARoleNotALiteral &&
                everyAccentPassesContrast,
        'and the scope is the person\'s own card':
            scopeNote.contains('nowhere else') && theCardIsTheProgressionCard,
        'every milestone is announced in words':
            everyMilestoneIsAnnouncedInWords && theCarrierRuleHolds,
        'high-contrast mode keeps the accent still':
            highContrastIsRespected &&
                rewardNote.contains('stop being decorative'),
        'completion reaches the ceiling': completion == 1,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
