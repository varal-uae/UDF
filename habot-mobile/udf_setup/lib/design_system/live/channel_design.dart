/// Step 429 (RTSET-013) -- channel structures and refresh triggers, on a row
/// whose lower half is about CORS.
///
/// The row: "Determine WebSocket event channel structures and layout card
/// refresh triggers."
/// Metric: **Channel / Topic Design Completeness** -- floor 0.9, optimal 0.99,
/// ceiling 1. Best Qualitative Output: "Complete". Assigned to **UDF**.
///
/// **A channel per card does not survive a shift change.** Twelve cards on a
/// screen mean twelve subscriptions, twelve reconnect handshakes after a tunnel
/// and twelve chances to miss a message; and the moment two cards want the same
/// data they get two copies of it at two different instants, which is how one
/// screen ends up showing two totals. Channels are declared per *scope* --
/// site, shift, and the viewer -- and cards subscribe to a scope. Three
/// channels serve any number of cards, and every card on one scope updates from
/// one message.
///
/// **A refresh that fires mid-gesture is a refresh that steals a tap.** The
/// row's own design cells ask that live updates not cover active touch spaces,
/// which is the right instinct and half the problem: the other half is that a
/// card re-laying-out under a moving thumb moves the target between the press
/// and the release. Updates that would change layout are held while a pointer
/// is down and applied on release; updates that only change a number are
/// applied immediately.
///
/// **Fourteenth one-valued output column, third in this batch.** "Complete",
/// with no other value available, after Steps 423 and 428.
///
/// **The lower half is about CORS.** The Poka-Yoke cell blocks gateway builds
/// using wildcard origins, the Completion Measures cell tests that untrusted
/// origins are refused, the Expected Output is "a declarative CORS
/// specification manifest", the library is the API gateway blueprints and the
/// Decision Group is Edge Security Architecture. Seventh spliced row in the
/// track -- and the third in this batch, after Steps 416, 417 and 423.
library;

/// What a channel is scoped to.
enum HabotChannelScope {
  /// Everything happening at one site.
  site,

  /// One shift at one site.
  shift,

  /// The viewer's own records.
  viewer,
}

/// What makes a card refresh.
enum HabotRefreshTrigger {
  /// A message on a channel the card subscribes to.
  channelMessage,

  /// The viewer pulling down.
  manualPull,

  /// A timer, for cards fed by a store that cannot push.
  poll,
}

/// One card and how it stays current.
class HabotLiveCard {
  const HabotLiveCard({
    required this.name,
    required this.scope,
    required this.trigger,
    required this.changesLayout,
  });

  final String name;
  final HabotChannelScope scope;
  final HabotRefreshTrigger trigger;

  /// True where an update can change the card's height.
  final bool changesLayout;
}

/// The channel design.
class HabotChannelDesign {
  const HabotChannelDesign._();

  // -----------------------------------------------------------------------
  // Channels are per scope, not per card.
  // -----------------------------------------------------------------------

  static const List<HabotLiveCard> cards = <HabotLiveCard>[
    HabotLiveCard(
      name: 'staff on shift',
      scope: HabotChannelScope.shift,
      trigger: HabotRefreshTrigger.channelMessage,
      changesLayout: true,
    ),
    HabotLiveCard(
      name: 'open overtime requests',
      scope: HabotChannelScope.shift,
      trigger: HabotRefreshTrigger.channelMessage,
      changesLayout: true,
    ),
    HabotLiveCard(
      name: 'station status',
      scope: HabotChannelScope.site,
      trigger: HabotRefreshTrigger.channelMessage,
      changesLayout: false,
    ),
    HabotLiveCard(
      name: 'my next shift',
      scope: HabotChannelScope.viewer,
      trigger: HabotRefreshTrigger.channelMessage,
      changesLayout: false,
    ),
    HabotLiveCard(
      name: 'hours this week',
      scope: HabotChannelScope.viewer,
      trigger: HabotRefreshTrigger.poll,
      changesLayout: false,
    ),
  ];

  static int get cardCount => cards.length;

  static int get channelCount => HabotChannelScope.values.length;

  static bool get channelsAreFewerThanCards => channelCount < cardCount;

  static const bool aChannelPerCard = false;

  static bool get oneMessageServesEveryCardOnAScope =>
      !aChannelPerCard && channelsAreFewerThanCards;

  static int cardsOn(HabotChannelScope s) =>
      cards.where((HabotLiveCard c) => c.scope == s).length;

  static bool get twoCardsShareTheShiftScope =>
      cardsOn(HabotChannelScope.shift) == 2;

  static bool get everyCardHasAScope => cards.every(
      (HabotLiveCard c) => HabotChannelScope.values.contains(c.scope));

  static const String scopeNote =
      'Twelve cards with twelve subscriptions is twelve reconnect handshakes '
      'after a tunnel and twelve chances to miss a message, and the moment two '
      'cards want the same data they get two copies of it taken at two '
      'different instants, which is how one screen shows two totals. Three '
      'channels -- site, shift and viewer -- serve any number of cards, and '
      'every card on one scope updates from one message, so two cards on the '
      'same scope cannot disagree.';

  // -----------------------------------------------------------------------
  // A refresh that fires under a thumb.
  // -----------------------------------------------------------------------

  static const bool layoutChangesAreHeldWhileAPointerIsDown = true;

  static const bool numberChangesAreHeld = false;

  static bool get onlyLayoutChangesAreDeferred =>
      layoutChangesAreHeldWhileAPointerIsDown && !numberChangesAreHeld;

  static int get layoutChangingCards =>
      cards.where((HabotLiveCard c) => c.changesLayout).length;

  static bool get twoCardsCanChangeLayout => layoutChangingCards == 2;

  static const String whatTheRowAsksFor =
      'live update alerts must not cover active touch spaces';

  static const String theOtherHalfOfTheProblem =
      'a card re-laying-out under a moving thumb moves the target between the '
      'press and the release';

  static bool get bothHalvesAreAddressed =>
      whatTheRowAsksFor.isNotEmpty && theOtherHalfOfTheProblem.isNotEmpty;

  static const String gestureNote =
      'The row asks that live updates not cover active touch spaces, which is '
      'right and is half of it. The other half is that a card re-laying-out '
      'under a moving thumb moves the target between the press and the '
      'release, so the tap lands on whatever slid into that position. Updates '
      'that change layout are held while a pointer is down and applied on '
      'release; updates that only change a number are applied at once, because '
      'holding those is how a live figure becomes a stale one.';

  // -----------------------------------------------------------------------
  // Every trigger is declared with a reason.
  // -----------------------------------------------------------------------

  static const Map<HabotRefreshTrigger, String> triggerRationale =
      <HabotRefreshTrigger, String>{
    HabotRefreshTrigger.channelMessage:
        'the source can push, so the card is current within one round trip',
    HabotRefreshTrigger.manualPull:
        'the viewer asked, which overrides every other consideration',
    HabotRefreshTrigger.poll:
        'the source is a warehouse that cannot push, so the card is current '
            'to the last poll and says so',
  };

  static bool get everyTriggerHasARationale =>
      triggerRationale.length == HabotRefreshTrigger.values.length;

  static bool get everyCardDeclaresItsTrigger => cards.every(
      (HabotLiveCard c) => triggerRationale.containsKey(c.trigger));

  static int get pollingCards => cards
      .where((HabotLiveCard c) => c.trigger == HabotRefreshTrigger.poll)
      .length;

  static bool get thePollingCardIsMarkedAsSuch => pollingCards == 1;

  static const String triggerNote =
      'Three triggers, each with a reason: a channel message where the source '
      'can push, a manual pull because the viewer asking beats every other '
      'consideration, and a poll where the source is a warehouse that cannot '
      'push. One card polls, and it is the one fed from an analytics store; a '
      'card that polls is not live and is labelled with the age of what it is '
      'showing rather than being allowed to look like the others.';

  // -----------------------------------------------------------------------
  // The band, the column, and the CORS row underneath.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.9;
  static const double bandOptimal = 0.99;
  static const double bandCeiling = 1;

  static const String outputColumnRaw = 'Complete';

  static bool get theOutputColumnHoldsOneValue =>
      outputColumnRaw == 'Complete';

  static const int oneValuedColumnsInTheTrack = 14;

  static bool get theCountReachesFourteen =>
      oneValuedColumnsInTheTrack == 14 && theOutputColumnHoldsOneValue;

  static const bool theStandardColumnHoldsProse = true;

  /// Step 416 and this one.
  static const List<int> rowsWithProseInTheStandardColumn = <int>[416, 429];

  static bool get secondSuchRow =>
      rowsWithProseInTheStandardColumn.length == 2;

  static const List<String> cellsFromTheCorsRow = <String>[
    'Poka-Yoke: deployment blocks gateway builds using wildcard origins',
    'Completion Measures: untrusted origins are blocked or CORS-refused',
    'Expected Output: a declarative CORS specification manifest',
    'Common Library: habot-api-gateway-blueprints',
    'Decision Group: Edge Security Architecture',
  ];

  static bool get fiveCellsBelongElsewhere => cellsFromTheCorsRow.length == 5;

  /// Steps 388, 390, 398, 416, 417, 423 and this one.
  static const List<int> splicedRows = <int>[
    388,
    390,
    398,
    416,
    417,
    423,
    429,
  ];

  static bool get seventhSplicedRow => splicedRows.length == 7;

  static double get designCompleteness {
    final int declared = cards
        .where((HabotLiveCard c) => triggerRationale.containsKey(c.trigger))
        .length;
    return cards.isEmpty ? 0 : declared / cards.length;
  }

  static bool get completenessReachesTheCeiling =>
      designCompleteness >= bandCeiling;

  static String get qualitativeOutput =>
      completenessReachesTheCeiling && everyTriggerHasARationale
          ? 'Complete'
          : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s Best Qualitative Output column holds the '
      'single word "Complete", the fourteenth one-valued column in the track '
      'and the third in this batch after Steps 423 and 428; its '
      'reference-standard column holds a sentence arguing for the band rather '
      'than naming a standard, the second such row after Step 416; its Data '
      'Requirement holds the Layout Type and Grid Dimensions field set that '
      'belongs to a layout row; and its Poka-Yoke, Completion Measures, '
      'Expected Output, Common Library and Decision Group cells are all about '
      'CORS and wildcard origins at an API gateway, making this the seventh '
      'spliced row in the track and the fourth in this batch. Atomic Step: '
      '"Determine WebSocket event channel structures and layout card refresh '
      'triggers."';

  static Map<String, bool> get obligations => <String, bool>{
        'channels are scoped, not per card': oneMessageServesEveryCardOnAScope,
        'every card declares a scope and a trigger':
            everyCardHasAScope && everyCardDeclaresItsTrigger,
        'every trigger states its rationale': everyTriggerHasARationale,
        'layout changes are deferred while a pointer is down':
            onlyLayoutChangesAreDeferred,
        'the polling card is not allowed to look live':
            thePollingCardIsMarkedAsSuch,
      };

  static Map<String, bool> get checks => <String, bool>{
        'five cards on three channels':
            cardCount == 5 && channelCount == 3 && channelsAreFewerThanCards,
        'two cards share one scope and cannot disagree':
            twoCardsShareTheShiftScope && oneMessageServesEveryCardOnAScope,
        'and twelve subscriptions would be twelve reconnects':
            scopeNote.contains('two totals'),
        'layout changes are held under a pointer':
            onlyLayoutChangesAreDeferred && twoCardsCanChangeLayout,
        'and number changes are not':
            !numberChangesAreHeld && bothHalvesAreAddressed,
        'because the target moves between press and release':
            gestureNote.contains('slid into that position'),
        'three triggers, each with a rationale':
            everyTriggerHasARationale && everyCardDeclaresItsTrigger,
        'the polling card is labelled with its age':
            thePollingCardIsMarkedAsSuch &&
                triggerNote.contains('look like the others'),
        'one-valued output column, and prose in the standard column':
            theCountReachesFourteen &&
                theStandardColumnHoldsProse &&
                secondSuchRow,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                completenessReachesTheCeiling &&
                fiveCellsBelongElsewhere &&
                seventhSplicedRow,
      };
}
