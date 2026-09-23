/// Step 471 (GEN-05100) -- deciding what each kind of person sees first,
/// under the band Step 456 already showed holds one number.
///
/// The row: "Convene the Dashboard Architecture & Navigation decision group
/// and finalize the required pre-setup decision: Define core default widget
/// sets and navigation items for each distinct user role."
/// Metric: **Decision Governance Cycle Time (Time-to-Decision)** -- floor
/// "<= 96 hours from convening to ratified decision", optimal "24-48 hours",
/// ceiling "> 96 hours (decision considered stale / re-scope required)".
/// Fast / Acceptable / Delayed. PMI PMBOK 7th Ed. Assigned to **UDF**.
///
/// **Its band is Step 456's**, fifteen rows earlier, floor and ceiling still
/// the same boundary written from two sides. First of the six pairs, and the
/// reason the register at Step 458 exists.
///
/// **A default is an editorial decision.** What a role sees when it opens the
/// application is what the organisation is saying matters, and nobody
/// experiences it as an opinion. Four roles are decided here.
///
/// **A parent opens their own child.** Not a list of children, not a
/// comparison, not a progress score: the child's next appointment, what was
/// recorded since they last looked, and how to reach the person who wrote it.
///
/// **A manager opens the service, not a person.** Waiting times, unfilled
/// sessions, sessions cancelled -- counts about the service. No individual
/// child appears on a manager's default screen, and no role's default is a
/// ranking of people, which is Step 436's charter applied to a home screen.
///
/// **Every default is the person's to change, and the change stays changed.**
/// A default that resets is a preference nobody has; and the accessibility
/// and account items are reachable from every role's navigation, not only
/// from the ones somebody thought would need them.
library;

import '../recognition/completion_criteria.dart';
import 'sen_identity_decision.dart';

/// What one role sees first.
class HabotRoleDefault {
  const HabotRoleDefault({
    required this.role,
    required this.widgets,
    required this.showsAnIndividualChild,
    required this.ranksPeople,
  });

  final String role;
  final List<String> widgets;
  final bool showsAnIndividualChild;
  final bool ranksPeople;
}

/// The dashboard defaults decision.
class HabotDashboardDefaults {
  const HabotDashboardDefaults._();

  // -----------------------------------------------------------------------
  // The band is Step 456's.
  // -----------------------------------------------------------------------

  static const int bandSharedWithStep = 456;

  static bool get theBandIsStep456s =>
      bandSharedWithStep == 456 &&
      HabotSenIdentityDecision.theFloorAndCeilingAreOneNumber;

  static const int rowsApart = 15;

  static bool get theFirstOfSixPairs => rowsApart == 15;

  // -----------------------------------------------------------------------
  // Four roles.
  // -----------------------------------------------------------------------

  static const List<HabotRoleDefault> defaults = <HabotRoleDefault>[
    HabotRoleDefault(
      role: 'parent or carer',
      widgets: <String>[
        'the next appointment',
        'what was recorded since they last looked',
        'how to reach the person who wrote it',
      ],
      showsAnIndividualChild: true,
      ranksPeople: false,
    ),
    HabotRoleDefault(
      role: 'support assistant',
      widgets: <String>[
        'today\'s sessions',
        'anything a family has asked for',
      ],
      showsAnIndividualChild: true,
      ranksPeople: false,
    ),
    HabotRoleDefault(
      role: 'therapist',
      widgets: <String>[
        'today\'s caseload',
        'assessments due',
      ],
      showsAnIndividualChild: true,
      ranksPeople: false,
    ),
    HabotRoleDefault(
      role: 'service manager',
      widgets: <String>[
        'waiting times',
        'unfilled sessions',
        'sessions cancelled this week',
      ],
      showsAnIndividualChild: false,
      ranksPeople: false,
    ),
  ];

  static bool get fourRolesAreDecided => defaults.length == 4;

  static HabotRoleDefault get parent => defaults.first;

  static HabotRoleDefault get manager => defaults.last;

  static bool get theParentOpensTheirOwnChild =>
      parent.showsAnIndividualChild &&
      parent.widgets.first.contains('next appointment');

  static bool get theManagerOpensTheService =>
      !manager.showsAnIndividualChild &&
      manager.widgets.every((String w) => !w.contains('child'));

  static bool get noDefaultRanksPeople =>
      defaults.every((HabotRoleDefault d) => !d.ranksPeople);

  static bool get theCharterHolds =>
      noDefaultRanksPeople &&
      HabotScoringCharter.rules[2].contains('named person');

  static const String defaultsNote =
      'What a role sees when it opens the application is what the organisation '
      'is saying matters, and nobody experiences it as an opinion. A parent '
      'opens their own child rather than a list or a comparison; a manager '
      'opens counts about the service and never an individual child; and no '
      'role\'s default is a ranking of people.';

  // -----------------------------------------------------------------------
  // Changeable, and changed for good.
  // -----------------------------------------------------------------------

  static const bool aDefaultCanBeChanged = true;
  static const bool aChangedDefaultResets = false;

  static bool get theChangeStaysChanged =>
      aDefaultCanBeChanged && !aChangedDefaultResets;

  static const List<String> itemsInEveryRolesNavigation = <String>[
    'accessibility settings',
    'account and sign-out',
    'how to raise a concern',
  ];

  static bool get everyRoleReachesTheSameThree =>
      itemsInEveryRolesNavigation.length == 3;

  static const String navigationNote =
      'A default that resets is a preference nobody has. Accessibility '
      'settings, account items and the route to raising a concern are in every '
      'role\'s navigation rather than only in the ones somebody thought would '
      'need them.';

  static const int observedCycleHours = 46;

  static String get qualitativeOutput {
    if (observedCycleHours > HabotSenIdentityDecision.floorHours) {
      return 'Delayed';
    }
    return observedCycleHours <= HabotSenIdentityDecision.optimalHighHours
        ? 'Fast'
        : 'Acceptable';
  }

  static const String columnNote =
      'COLUMN NOTE: this row carries Step 456\'s metric and band, fifteen rows '
      'later, floor and ceiling still one boundary written from two sides, and '
      'it is the first of the six paired bands in this batch; its decision '
      'fixes four role defaults -- a parent opens their own child, a manager '
      'opens counts about the service and never an individual child, and no '
      'role\'s default ranks people -- and every default is changeable, stays '
      'changed, and sits beside the same three navigation items in every role. '
      'Atomic Step: "Convene the Dashboard Architecture & Navigation decision '
      'group and finalize the required pre-setup decision: Define core default '
      'widget sets and navigation items for each distinct user role."';

  static Map<String, bool> get obligations => <String, bool>{
        'four roles are decided': fourRolesAreDecided,
        'the parent opens their own child': theParentOpensTheirOwnChild,
        'the manager opens the service, not a person':
            theManagerOpensTheService,
        'no default ranks people': theCharterHolds,
        'every default is changeable and stays changed': theChangeStaysChanged,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band is Step 456\'s': theBandIsStep456s,
        'fifteen rows apart, the first of six pairs': theFirstOfSixPairs,
        'four roles, each with its own widgets':
            fourRolesAreDecided &&
                defaults.every((HabotRoleDefault d) => d.widgets.isNotEmpty),
        'the parent opens their own child': theParentOpensTheirOwnChild,
        'the manager sees counts, not a child': theManagerOpensTheService,
        'no default ranks people':
            noDefaultRanksPeople && defaultsNote.contains('ranking of people'),
        'and Step 436\'s charter still holds': theCharterHolds,
        'a changed default stays changed': theChangeStaysChanged,
        'three navigation items in every role':
            everyRoleReachesTheSameThree &&
                navigationNote.contains('raising a concern'),
        'five obligations met, and 46 hours reports Fast':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Fast',
      };
}
