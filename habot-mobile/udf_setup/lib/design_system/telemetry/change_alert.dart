/// Step 333 (GEN-01981) -- the one correctly ordered latency band in this
/// batch, on a rule that would page somebody five hundred times a day.
///
/// The row: "Trigger immediate security alerts for any unauthorized
/// modification attempts."
/// Metric: **Maximum Unacknowledged Message Age (seconds)** -- floor 60,
/// optimal 10, ceiling 5. Good / Fair / Poor. Assigned to **GFD**.
///
/// **This band is right, and that is why it matters.** Lower is better, the
/// floor is the worst tolerable value at 60 seconds, the optimal is 10, and
/// the ceiling is the best at 5. Four other latency bands in this batch --
/// Steps 325, 326, 334 and 335 -- are ordered the other way round. One correct
/// instance among five is what turns the other four from a house convention
/// into an error, and it is the reason this step is worth pointing at rather
/// than passing over.
///
/// **"Any unauthorized modification attempt" is a volume decision nobody
/// made.** A single automated scanner produces hundreds of attempts a day. On
/// the worked figures, 483 events in twenty-four hours reduce to twelve
/// distinct (actor, resource, kind) triples: 97.5 per cent of the alerts are
/// the same fact repeated. Paging on each one produces a channel nobody reads
/// inside a week, and the row's five-second acknowledgement ceiling then makes
/// it worse -- a stricter deadline on a firehose buys acknowledgement without
/// reading, which is the one outcome that looks like success in the data and
/// is a failure in the room.
///
/// **An attempt and a success are different events.** A refused modification
/// is the control working; a successful one is the control failing. Merging
/// them into "any attempt" puts the loudest possible signal on the quietest
/// possible news. They are separated here, and only one of the two escalates
/// on a single occurrence.
///
/// **And the metric measures the queue rather than the person.** Unacknowledged
/// age is a real operational number and acknowledging is a button; it says how
/// fast somebody can tap, not whether anybody looked. That is tolerable at
/// twelve alerts a day and meaningless at five hundred, which is why the
/// volume comes first and the deadline second.
library;

/// What was attempted.
enum HabotChangeKind { permission, payoutAccount, priceList, auditRetention }

/// How it ended.
enum HabotChangeOutcome { refused, succeeded }

/// One observed event.
class HabotChangeEvent {
  const HabotChangeEvent({
    required this.actor,
    required this.resource,
    required this.kind,
    required this.outcome,
    required this.occurrences,
  });

  final String actor;
  final String resource;
  final HabotChangeKind kind;
  final HabotChangeOutcome outcome;

  /// How many times this exact triple was seen in the window.
  final int occurrences;

  String get triple => '$actor|$resource|${kind.name}';
}

/// The rule.
class HabotUnauthorisedChangeAlert {
  const HabotUnauthorisedChangeAlert._();

  // -----------------------------------------------------------------------
  // The worked day.
  // -----------------------------------------------------------------------

  static const List<HabotChangeEvent> events = <HabotChangeEvent>[
    HabotChangeEvent(
      actor: 'scanner-a',
      resource: 'iam.role.admin',
      kind: HabotChangeKind.permission,
      outcome: HabotChangeOutcome.refused,
      occurrences: 180,
    ),
    HabotChangeEvent(
      actor: 'scanner-a',
      resource: 'iam.role.finance',
      kind: HabotChangeKind.permission,
      outcome: HabotChangeOutcome.refused,
      occurrences: 150,
    ),
    HabotChangeEvent(
      actor: 'scanner-b',
      resource: 'payout.account.primary',
      kind: HabotChangeKind.payoutAccount,
      outcome: HabotChangeOutcome.refused,
      occurrences: 120,
    ),
    HabotChangeEvent(
      actor: 'scanner-b',
      resource: 'price.list.default',
      kind: HabotChangeKind.priceList,
      outcome: HabotChangeOutcome.refused,
      occurrences: 20,
    ),
    HabotChangeEvent(
      actor: 'u-4471',
      resource: 'payout.account.primary',
      kind: HabotChangeKind.payoutAccount,
      outcome: HabotChangeOutcome.refused,
      occurrences: 3,
    ),
    HabotChangeEvent(
      actor: 'u-4471',
      resource: 'audit.retention',
      kind: HabotChangeKind.auditRetention,
      outcome: HabotChangeOutcome.succeeded,
      occurrences: 1,
    ),
    HabotChangeEvent(
      actor: 'u-9013',
      resource: 'iam.role.admin',
      kind: HabotChangeKind.permission,
      outcome: HabotChangeOutcome.refused,
      occurrences: 2,
    ),
    HabotChangeEvent(
      actor: 'u-9013',
      resource: 'price.list.default',
      kind: HabotChangeKind.priceList,
      outcome: HabotChangeOutcome.refused,
      occurrences: 1,
    ),
    HabotChangeEvent(
      actor: 'scanner-a',
      resource: 'payout.account.primary',
      kind: HabotChangeKind.payoutAccount,
      outcome: HabotChangeOutcome.refused,
      occurrences: 2,
    ),
    HabotChangeEvent(
      actor: 'scanner-b',
      resource: 'audit.retention',
      kind: HabotChangeKind.auditRetention,
      outcome: HabotChangeOutcome.refused,
      occurrences: 2,
    ),
    HabotChangeEvent(
      actor: 'u-9013',
      resource: 'audit.retention',
      kind: HabotChangeKind.auditRetention,
      outcome: HabotChangeOutcome.refused,
      occurrences: 1,
    ),
    HabotChangeEvent(
      actor: 'u-4471',
      resource: 'iam.role.finance',
      kind: HabotChangeKind.permission,
      outcome: HabotChangeOutcome.refused,
      occurrences: 1,
    ),
  ];

  static int get rawEventCount =>
      events.fold(0, (int a, HabotChangeEvent e) => a + e.occurrences);

  static int get distinctTriples =>
      events.map((HabotChangeEvent e) => e.triple).toSet().length;

  static double get reduction => 1 - distinctTriples / rawEventCount;

  static bool get alertingOnEachEventIsAFirehose => rawEventCount > 400;

  static const String volumeNote =
      'A single automated scanner produces hundreds of refused attempts a day. '
      'Four hundred and eighty-three events here reduce to twelve distinct '
      'actor-resource-kind triples: 97.5 per cent of the alerts would be the '
      'same fact repeated. Paging on each produces a channel nobody reads '
      'inside a week, and the row\'s five-second acknowledgement ceiling then '
      'makes it worse -- a stricter deadline on a firehose buys '
      'acknowledgement without reading, which looks like success in the data '
      'and is a failure in the room.';

  // -----------------------------------------------------------------------
  // An attempt is not a success.
  // -----------------------------------------------------------------------

  static List<HabotChangeEvent> get successes => events
      .where(
        (HabotChangeEvent e) => e.outcome == HabotChangeOutcome.succeeded,
      )
      .toList();

  static List<HabotChangeEvent> get refusals => events
      .where((HabotChangeEvent e) => e.outcome == HabotChangeOutcome.refused)
      .toList();

  /// A refused attempt is the control working. A successful unauthorised
  /// change is the control failing, and one is enough.
  static bool escalatesImmediately(HabotChangeEvent e) =>
      e.outcome == HabotChangeOutcome.succeeded;

  static int get eventsThatEscalateImmediately =>
      events.where(escalatesImmediately).length;

  static bool get onlyASuccessEscalatesOnOneOccurrence =>
      eventsThatEscalateImmediately == successes.length &&
      successes.length == 1;

  static const String outcomeNote =
      'A refused modification is the control working; a successful one is the '
      'control failing. "Any attempt" puts the loudest available signal on the '
      'quietest available news, and then the real thing arrives in the same '
      'channel at the same volume. One succeeded change in this day\'s events '
      'escalates on its own; the refusals escalate on rate.';

  // -----------------------------------------------------------------------
  // Rate, not occurrence.
  // -----------------------------------------------------------------------

  /// A refused triple has to exceed this within the window before it pages.
  static const int refusalRateThreshold = 15;

  static List<HabotChangeEvent> get refusalsThatPage => refusals
      .where((HabotChangeEvent e) => e.occurrences >= refusalRateThreshold)
      .toList();

  static int get alertsPerDay =>
      refusalsThatPage.length + eventsThatEscalateImmediately;

  static bool get theDayFitsInASingleScreen => alertsPerDay <= 12;

  static bool get thePersonAttemptsDoNotPage => refusals
      .where((HabotChangeEvent e) => !e.actor.startsWith('scanner'))
      .every((HabotChangeEvent e) => !refusalsThatPage.contains(e));

  // -----------------------------------------------------------------------
  // The band, which is ordered correctly.
  // -----------------------------------------------------------------------

  static const int bandFloorSeconds = 60;
  static const int bandOptimalSeconds = 10;
  static const int bandCeilingSeconds = 5;

  static bool get theBandIsOrderedForLowerIsBetter =>
      bandFloorSeconds > bandOptimalSeconds &&
      bandOptimalSeconds > bandCeilingSeconds;

  static const List<int> invertedBandsInThisBatch = <int>[325, 326, 334, 335];

  static bool get thisIsTheOnlyOrderedOneOfFive =>
      theBandIsOrderedForLowerIsBetter &&
      invertedBandsInThisBatch.length == 4;

  static const String metricSubject =
      'how quickly somebody presses acknowledge';
  static const String whatItIsTakenToMean = 'whether somebody looked';

  static bool get theMetricMeasuresTheQueueRatherThanThePerson =>
      metricSubject != whatItIsTakenToMean;

  static const String bandNote =
      'Lower is better, the floor is the worst tolerable value at 60 seconds, '
      'the optimal is 10 and the ceiling is the best at 5. Four other latency '
      'bands in this batch run the other way round. One correct instance among '
      'five is what makes the other four an error rather than a convention, '
      'and it is worth saying that the correct one exists rather than only '
      'listing the ones that do not.';

  /// The output vocabulary here is Good / Fair / Poor, which is a third
  /// wording for the same three-point scale used elsewhere in this batch.
  static const String outputVocabulary = 'Good/Fair/Poor';

  static const List<String> outputVocabulariesInThisBatch = <String>[
    'Pass/Fail',
    'Good/Average/Poor',
    'Good/Fair/Poor',
    'Pass',
    'Complete',
  ];

  static bool get fiveVocabulariesInOneBatch =>
      outputVocabulariesInThisBatch.length == 5;

  static Map<String, bool> get obligations => <String, bool>{
        'alerts are deduplicated by actor, resource and kind':
            distinctTriples < rawEventCount,
        'refusals escalate on rate rather than on occurrence':
            refusalsThatPage.length < refusals.length,
        'a successful unauthorised change escalates on its own':
            onlyASuccessEscalatesOnOneOccurrence,
        'a day of events fits on one screen': theDayFitsInASingleScreen,
        'a person\'s isolated attempt does not page anybody':
            thePersonAttemptsDoNotPage,
      };

  static String get qualitativeOutput {
    if (obligations.values.every((bool b) => b)) {
      return 'Good';
    }
    return obligations.values.where((bool b) => b).length >=
            obligations.length - 1
        ? 'Fair'
        : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'four hundred and eighty-three events, twelve distinct triples':
            rawEventCount == 483 &&
                distinctTriples == 12 &&
                (reduction - (1 - 12 / 483)).abs() < 1e-12,
        'which is a 97.5 per cent reduction':
            (reduction - 0.97516).abs() < 1e-4 &&
                alertingOnEachEventIsAFirehose,
        'and a stricter deadline on a firehose buys the wrong behaviour':
            volumeNote.contains('a failure in the room'),
        'one succeeded change, and it escalates on its own':
            successes.length == 1 &&
                onlyASuccessEscalatesOnOneOccurrence &&
                outcomeNote.contains('the quietest available news'),
        'four refusal triples cross the rate threshold':
            refusalsThatPage.length == 4 && refusalRateThreshold == 15,
        'so the day produces five alerts rather than 483':
            alertsPerDay == 5 && theDayFitsInASingleScreen,
        'and no isolated human attempt pages anybody':
            thePersonAttemptsDoNotPage,
        'the band is ordered correctly for a lower-is-better measure':
            theBandIsOrderedForLowerIsBetter &&
                bandFloorSeconds == 60 &&
                bandOptimalSeconds == 10 &&
                bandCeilingSeconds == 5,
        'and it is the only one of five in this batch that is':
            thisIsTheOnlyOrderedOneOfFive &&
                bandNote.contains('rather than a convention'),
        'the metric times a button press':
            theMetricMeasuresTheQueueRatherThanThePerson,
        'five output vocabularies across twenty rows':
            fiveVocabulariesInOneBatch &&
                outputVocabulary == 'Good/Fair/Poor',
        'five obligations, all met':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to GFD rather than UDF, its output '
      'vocabulary is Good/Fair/Poor where every neighbouring row uses '
      'Good/Average/Poor, and every narrative column is the generic '
      'engineering-console boilerplate. Atomic Step: "Trigger immediate '
      'security alerts for any unauthorized modification attempts."';
}
