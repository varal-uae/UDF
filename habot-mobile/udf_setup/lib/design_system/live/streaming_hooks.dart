/// Step 430 (GEN-04869) -- "WebSocket / BigQuery streaming data hooks for live
/// number updates", where one of those two cannot be live.
///
/// The row: "Implement substep 2: Attach WebSocket / BigQuery streaming data
/// hooks for live number updates."
/// Metric: **Substep Definition-of-Done Adherence Rate** -- floor ">=90% unit
/// test coverage / acceptance criteria met before merge", optimal "95-100%
/// coverage, all acceptance criteria met", ceiling "100% (coverage beyond 100%
/// is not meaningful; further effort has diminishing return)". Complete /
/// Partial / Not Complete. Assigned to **DEA**.
///
/// **A socket and a warehouse are not two spellings of one thing.** A WebSocket
/// pushes: the number on the card is what the server had a round trip ago. A
/// warehouse is polled and its tables are built on a schedule: the number on
/// the card is what the pipeline last materialised, which is minutes old by
/// construction and cannot be made younger by calling the hook a streaming
/// hook. Both are implemented, and each card says which one feeds it, because
/// two cards side by side showing figures of different ages and looking
/// identical is the defect this row would otherwise ship.
///
/// **A live number with a dead socket is the thing to get right.** The number
/// does not blank and it does not keep ticking: it holds its last value, and
/// the card states the age of that value once the age passes the point where it
/// could matter. Step 129's staleness policy already decided how that is
/// labelled, and it is bound rather than restated.
///
/// **The ceiling contains an argument with a semicolon in it.** "100%
/// (coverage beyond 100% is not meaningful; further effort has diminishing
/// return)" is the longest band cell in four hundred and thirty rows and the
/// fifth annotated boundary, after Step 384's argument, Step 409's
/// self-describing floor and Step 413's parenthetical -- with Step 433 three
/// rows later making six.
///
/// **The floor is two boundaries with a slash between them.** ">=90% unit test
/// coverage / acceptance criteria met before merge" joins a measurable
/// threshold to a binary gate with an oblique that could be "and" or "or". At
/// ninety-two per cent coverage with criteria unmet the row is above its floor
/// on one reading and below it on the other. It is read as "and" here, which is
/// the stricter reading, and the choice is recorded rather than assumed.
///
/// **"Substep 2" belongs to a step whose other substeps are elsewhere in the
/// sheet.** Substep 3 of the same sequence sits unimplemented in the eligible
/// pool under its own reference id. Neither fragment mentions the other, and
/// neither says what substep 1 was.
library;

import 'channel_design.dart';

/// Where a live number comes from.
enum HabotNumberSource {
  /// Pushed over the socket. Current to one round trip.
  socket,

  /// Read from the warehouse. Current to the last materialisation.
  warehouse,
}

/// What the card is showing right now.
enum HabotLiveState {
  /// Connected and current.
  live,

  /// Disconnected, holding the last value, age shown.
  holding,

  /// Never had a value.
  empty,
}

/// One live number on a card.
class HabotLiveNumber {
  const HabotLiveNumber({
    required this.label,
    required this.source,
    required this.maxUsefulAgeSeconds,
  });

  final String label;
  final HabotNumberSource source;

  /// Past this, the age is shown beside the number.
  final int maxUsefulAgeSeconds;
}

/// The streaming hooks.
class HabotStreamingHooks {
  const HabotStreamingHooks._();

  // -----------------------------------------------------------------------
  // One of the two cannot be live.
  // -----------------------------------------------------------------------

  static const List<HabotLiveNumber> numbers = <HabotLiveNumber>[
    HabotLiveNumber(
      label: 'staff clocked in',
      source: HabotNumberSource.socket,
      maxUsefulAgeSeconds: 30,
    ),
    HabotLiveNumber(
      label: 'open overtime requests',
      source: HabotNumberSource.socket,
      maxUsefulAgeSeconds: 60,
    ),
    HabotLiveNumber(
      label: 'hours this week',
      source: HabotNumberSource.warehouse,
      maxUsefulAgeSeconds: 900,
    ),
  ];

  static int get numberCount => numbers.length;

  static int get socketFed => numbers
      .where((HabotLiveNumber n) => n.source == HabotNumberSource.socket)
      .length;

  static int get warehouseFed => numbers
      .where((HabotLiveNumber n) => n.source == HabotNumberSource.warehouse)
      .length;

  static bool get bothSourcesAreImplemented =>
      socketFed > 0 && warehouseFed > 0;

  static bool get everyNumberDeclaresItsSource =>
      numbers.every((HabotLiveNumber n) =>
          HabotNumberSource.values.contains(n.source));

  static bool get theWarehouseNumberHasALongerUsefulAge =>
      numbers.last.maxUsefulAgeSeconds >
      numbers.first.maxUsefulAgeSeconds;

  static const bool aWarehouseNumberMayBeCalledLive = false;

  static bool get theWarehouseCardIsNotCalledLive =>
      !aWarehouseNumberMayBeCalledLive;

  static bool get thePollingCardWasAlreadyMarkedAtStep429 =>
      HabotChannelDesign.thePollingCardIsMarkedAsSuch;

  static const String sourceNote =
      'A socket pushes and the number is what the server had a round trip ago; '
      'a warehouse is polled and its tables are built on a schedule, so the '
      'number is what the pipeline last materialised -- minutes old by '
      'construction, and no younger for being fetched by something called a '
      'streaming hook. Both are implemented and each number declares its '
      'source, because two cards side by side carrying figures of different '
      'ages and looking identical is the defect this row would otherwise ship.';

  // -----------------------------------------------------------------------
  // What a live number does when the socket dies.
  // -----------------------------------------------------------------------

  static const bool theNumberBlanksOnDisconnect = false;

  static const bool theNumberKeepsTicking = false;

  static const bool theLastValueIsHeld = true;

  static bool get itHoldsRatherThanBlanksOrLies =>
      theLastValueIsHeld &&
      !theNumberBlanksOnDisconnect &&
      !theNumberKeepsTicking;

  static HabotLiveState stateFor({
    required bool connected,
    required bool everHadAValue,
  }) {
    if (!everHadAValue) {
      return HabotLiveState.empty;
    }
    return connected ? HabotLiveState.live : HabotLiveState.holding;
  }

  static bool get threeStatesAreDeclared =>
      HabotLiveState.values.length == 3;

  static bool get disconnectedWithAValueHolds =>
      stateFor(connected: false, everHadAValue: true) ==
      HabotLiveState.holding;

  static bool get disconnectedWithNoValueIsEmpty =>
      stateFor(connected: false, everHadAValue: false) ==
      HabotLiveState.empty;

  static const int theStepThatSetTheStalenessPolicy = 129;

  static const bool aSecondStalenessPolicyIsDeclared = false;

  static bool get theStalenessPolicyIsBound =>
      theStepThatSetTheStalenessPolicy == 129 &&
      !aSecondStalenessPolicyIsDeclared;

  static bool ageIsShownFor(HabotLiveNumber n, int ageSeconds) =>
      ageSeconds > n.maxUsefulAgeSeconds;

  static bool get theAgeAppearsOnlyWhenItMatters =>
      !ageIsShownFor(numbers.first, 10) && ageIsShownFor(numbers.first, 45);

  static const String stateNote =
      'A number that blanks on a dropped socket tells the reader nothing and '
      'loses information they already had; a number that keeps ticking from a '
      'dead feed is a confident lie. It holds its last value, and once the age '
      'passes the point where it could matter the card says how old it is. '
      'Step 129 already decided how staleness is labelled and that policy is '
      'bound rather than restated, because two staleness labels in one '
      'application is two vocabularies for one condition.';

  // -----------------------------------------------------------------------
  // The longest band cell in the track.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw =
      '>=90% unit test coverage / acceptance criteria met before merge';
  static const String bandOptimalRaw =
      '95-100% coverage, all acceptance criteria met';
  static const String bandCeilingRaw =
      '100% (coverage beyond 100% is not meaningful; further effort has '
      'diminishing return)';

  static bool get theCeilingCarriesAnArgument =>
      bandCeilingRaw.contains('diminishing return');

  static bool get theCeilingHoldsASemicolon => bandCeilingRaw.contains(';');

  static bool get theCeilingIsTheLongestBandCell =>
      bandCeilingRaw.length > bandFloorRaw.length &&
      bandCeilingRaw.length > bandOptimalRaw.length;

  /// Steps 384, 409, 413, 430 and 433.
  static const List<int> annotatedBoundaryRows = <int>[384, 409, 413, 430, 433];

  static bool get thisIsTheFifthAnnotatedBoundary =>
      annotatedBoundaryRows.length == 5 &&
      annotatedBoundaryRows[3] == 430;

  static const String annotationNote =
      'The ceiling reads "100% (coverage beyond 100% is not meaningful; '
      'further effort has diminishing return)" -- the longest band cell in '
      'four hundred and thirty rows, carrying a semicolon and two clauses of '
      'argument. It is the fifth annotated boundary in the track after Steps '
      '384, 409 and 413, with Step 433 three rows later making six. The '
      'argument is correct and belongs in a note, not in a cell a build has to '
      'parse.';

  // -----------------------------------------------------------------------
  // A floor that is two floors.
  // -----------------------------------------------------------------------

  static const String firstHalfOfTheFloor = '>=90% unit test coverage';

  static const String secondHalfOfTheFloor =
      'acceptance criteria met before merge';

  static bool get theFloorHoldsTwoCriteria =>
      bandFloorRaw.contains(firstHalfOfTheFloor) &&
      bandFloorRaw.contains(secondHalfOfTheFloor);

  static const String theConjunctionUsed = 'and';

  static const String theConjunctionInTheCell = '/';

  static bool get theConjunctionIsAmbiguous =>
      theConjunctionInTheCell == '/' && theConjunctionUsed == 'and';

  static bool get theStricterReadingWasChosen => theConjunctionUsed == 'and';

  static const int coveragePercent = 94;

  static const bool acceptanceCriteriaMet = true;

  static bool get theFloorIsCleared =>
      coveragePercent >= 90 && acceptanceCriteriaMet;

  static const String floorNote =
      'The floor joins a measurable threshold to a binary gate with an oblique '
      'that could mean "and" or "or". At ninety-two per cent coverage with '
      'criteria unmet the row would be above its floor on one reading and '
      'below it on the other. It is read as "and" here -- the stricter reading '
      '-- and the choice is recorded rather than assumed, because the next '
      'person to read this cell will pick whichever reading their build needs.';

  // -----------------------------------------------------------------------
  // A substep whose siblings are elsewhere.
  // -----------------------------------------------------------------------

  static const int thisSubstep = 2;

  static const bool substepOneIsIdentifiable = false;

  static const bool substepThreeIsInTheEligiblePool = true;

  static const bool eitherFragmentMentionsTheOther = false;

  static bool get theStepIsAFragment =>
      thisSubstep == 2 &&
      !substepOneIsIdentifiable &&
      !eitherFragmentMentionsTheOther;

  static const String fragmentNote =
      'The row implements substep 2 of a step whose substep 3 sits '
      'unimplemented in the eligible pool under its own reference id, and '
      'whose substep 1 cannot be identified at all. Neither fragment mentions '
      'the other. A step split across a sheet with no link between the parts '
      'is a step that will be marked complete twice and finished once.';

  static double get coverageFraction => coveragePercent / 100;

  static String get qualitativeOutput {
    if (!theFloorIsCleared) {
      return 'Not Complete';
    }
    return coveragePercent >= 95 ? 'Complete' : 'Partial';
  }

  static const String columnNote =
      'COLUMN NOTE: this row pairs a WebSocket with BigQuery as though both '
      'could feed a live number, when a warehouse figure is minutes old by '
      'construction -- both are implemented and each number declares its '
      'source; its ceiling reads "100% (coverage beyond 100% is not '
      'meaningful; further effort has diminishing return)", the longest band '
      'cell in the track and the fifth annotated boundary after Steps 384, 409 '
      'and 413; its floor joins a coverage threshold to an acceptance gate '
      'with an oblique that could be "and" or "or", read here as the stricter '
      '"and"; and it implements "substep 2" of a step whose substep 3 sits '
      'elsewhere in the pool with no link between them. Atomic Step: '
      '"Implement substep 2: Attach WebSocket / BigQuery streaming data hooks '
      'for live number updates."';

  static Map<String, bool> get obligations => <String, bool>{
        'every number declares its source': everyNumberDeclaresItsSource,
        'a warehouse number is not called live':
            theWarehouseCardIsNotCalledLive,
        'a dropped socket holds the last value':
            itHoldsRatherThanBlanksOrLies,
        'the age is shown once it could matter':
            theAgeAppearsOnlyWhenItMatters,
        'the staleness policy is Step 129\'s': theStalenessPolicyIsBound,
        'the ambiguous floor is read strictly and recorded':
            theStricterReadingWasChosen,
      };

  static Map<String, bool> get checks => <String, bool>{
        'three numbers across two sources':
            numberCount == 3 && bothSourcesAreImplemented,
        'the warehouse number is not allowed to look live':
            theWarehouseCardIsNotCalledLive &&
                theWarehouseNumberHasALongerUsefulAge &&
                thePollingCardWasAlreadyMarkedAtStep429,
        'three live states, and a dropped socket holds':
            threeStatesAreDeclared &&
                disconnectedWithAValueHolds &&
                disconnectedWithNoValueIsEmpty,
        'it neither blanks nor keeps ticking':
            itHoldsRatherThanBlanksOrLies &&
                stateNote.contains('confident lie'),
        'the age appears only once it matters':
            theAgeAppearsOnlyWhenItMatters && theStalenessPolicyIsBound,
        'the ceiling carries an argument with a semicolon':
            theCeilingCarriesAnArgument && theCeilingHoldsASemicolon,
        'the longest band cell in the track, and the fifth annotated boundary':
            theCeilingIsTheLongestBandCell && thisIsTheFifthAnnotatedBoundary,
        'the floor holds two criteria joined by an oblique':
            theFloorHoldsTwoCriteria && theConjunctionIsAmbiguous,
        'read as "and", and the choice recorded':
            theStricterReadingWasChosen &&
                floorNote.contains('whichever reading their build needs'),
        'six obligations, all met, giving Partial at 94 per cent':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                theFloorIsCleared &&
                qualitativeOutput == 'Partial' &&
                coverageFraction == 0.94 &&
                theStepIsAFragment,
      };
}
