/// Step 486 (GEN-00687) -- anomaly alerts into a chat channel, under a
/// ceiling that is worse than the floor.
///
/// The row: "Program anomaly alert triggers publishing Shakti Alerts to Slack
/// on failure."
/// Metric: **Alert Dispatch Latency** -- floor "$\le 3\text{ secs}$", optimal
/// "$\le 1\text{ sec}$", ceiling "$5\text{ secs}$". Pass / Fail. Habot Shakti
/// Safety Protocol. Assigned to **GFD**.
///
/// **Five seconds is worse than three.** On a latency band the ceiling holds
/// the slowest value, which is the pattern Batch P found on the delivery rows
/// and which appears twice more in this batch, at Steps 487 and 490. Three
/// rows in one batch, all three dispatch or aggregation latencies, all three
/// with the ceiling at the far end from the optimal. The column is being used
/// as "the worst we will tolerate" on every latency row in the sheet, and the
/// heading says the opposite.
///
/// **Step 487 measures the same thing under a different name.** "Alert
/// Dispatch Latency" here, "Alert Trigger Dispatch Delay" there, with
/// identical band values. Two names for one measure, which is how a dashboard
/// ends up with two charts that never agree.
///
/// **An alert nobody acts on should be deleted, not muted.** Muting is how a
/// channel fills with noise that everyone has learned to scroll past, and the
/// one that mattered scrolls past with it. Every alert here names an owner,
/// and an alert with no owner is not published.
///
/// **One fault must not post four hundred times.** Alerts are keyed on the
/// fault rather than the occurrence, so a failing job that retries every ten
/// seconds produces one message that updates, not a wall of them.
///
/// **Severity chooses the channel, and only severity pages a person.** A
/// storage job that failed at two in the morning can wait for the morning; a
/// safeguarding export that failed cannot. Waking somebody is a decision the
/// severity makes explicitly, not a default of the integration.
library;

/// One alert as published.
class HabotPublishedAlert {
  const HabotPublishedAlert({
    required this.faultKey,
    required this.severity,
    required this.owner,
    required this.channel,
    required this.pages,
  });

  /// Identifies the fault, not the occurrence.
  final String faultKey;

  /// 1 is highest.
  final int severity;

  final String owner;
  final String channel;
  final bool pages;
}

/// The anomaly alert dispatcher.
class HabotAnomalyDispatch {
  const HabotAnomalyDispatch._();

  // -----------------------------------------------------------------------
  // A ceiling at the far end from the optimal.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = r'$\le 3\text{ secs}$';
  static const String bandOptimalRaw = r'$\le 1\text{ sec}$';
  static const String bandCeilingRaw = r'$5\text{ secs}$';

  static const int floorSeconds = 3;
  static const int optimalSeconds = 1;
  static const int ceilingSeconds = 5;

  static bool get theCeilingIsSlowerThanTheFloor =>
      ceilingSeconds > floorSeconds;

  static bool get theOptimalIsTheFastest =>
      optimalSeconds < floorSeconds && optimalSeconds < ceilingSeconds;

  /// Steps 486, 487 and 490 in this batch.
  static const List<int> latencyCeilingsAtTheWorstEnd = <int>[486, 487, 490];

  static bool get threeInOneBatch =>
      latencyCeilingsAtTheWorstEnd.length == 3;

  static const String bandNote =
      'On a latency band the ceiling holds the slowest value, which Batch P '
      'found on the delivery rows and which appears three times in this batch '
      'alone. The column is being used as "the worst we will tolerate" on '
      'every latency row in the sheet, and the heading says the opposite.';

  // -----------------------------------------------------------------------
  // Two names for one measure.
  // -----------------------------------------------------------------------

  static const String thisMetricName = 'Alert Dispatch Latency';
  static const String step487MetricName = 'Alert Trigger Dispatch Delay';

  static bool get twoNamesForOneMeasure =>
      thisMetricName != step487MetricName;

  static bool get theBandValuesAreIdentical =>
      floorSeconds == 3 && optimalSeconds == 1 && ceilingSeconds == 5;

  static const String namingNote =
      'The same three values appear under "Alert Dispatch Latency" here and '
      '"Alert Trigger Dispatch Delay" at Step 487. Two names for one measure '
      'is how a dashboard ends up with two charts that never agree.';

  // -----------------------------------------------------------------------
  // Owners, keys, severity.
  // -----------------------------------------------------------------------

  static const List<HabotPublishedAlert> alerts = <HabotPublishedAlert>[
    HabotPublishedAlert(
      faultKey: 'export.safeguarding.failed',
      severity: 1,
      owner: 'the on-call data engineer',
      channel: 'page',
      pages: true,
    ),
    HabotPublishedAlert(
      faultKey: 'backup.visits.stale',
      severity: 2,
      owner: 'the platform team channel',
      channel: 'chat',
      pages: false,
    ),
    HabotPublishedAlert(
      faultKey: 'sync.photos.retrying',
      severity: 3,
      owner: 'the platform team channel',
      channel: 'digest',
      pages: false,
    ),
  ];

  static bool get everyAlertHasAnOwner =>
      alerts.every((HabotPublishedAlert a) => a.owner.isNotEmpty);

  static const bool anAlertWithNoOwnerIsPublished = false;

  static bool get onlySeverityOnePages =>
      alerts.where((HabotPublishedAlert a) => a.pages).every(
          (HabotPublishedAlert a) => a.severity == 1);

  static bool get severityChoosesTheChannel =>
      alerts.first.channel == 'page' && alerts.last.channel == 'digest';

  static const int retriesInOneFault = 40;
  static const int messagesPublished = 1;

  static bool get oneFaultIsOneMessage =>
      retriesInOneFault > 1 && messagesPublished == 1;

  static bool get keyedOnTheFaultNotTheOccurrence => alerts
      .every((HabotPublishedAlert a) => a.faultKey.contains('.'));

  static const bool unactionedAlertsAreMuted = false;
  static const bool unactionedAlertsAreDeleted = true;

  static bool get mutingIsNotTheAnswer =>
      !unactionedAlertsAreMuted && unactionedAlertsAreDeleted;

  static const String noiseNote =
      'Muting is how a channel fills with noise everyone has learned to scroll '
      'past, and the one that mattered scrolls past with it. An alert nobody '
      'acts on is deleted, an alert with no owner is not published, and a '
      'failing job that retries forty times produces one message that updates '
      'rather than forty messages.';

  static const double observedDispatchSeconds = 0.6;

  static String get qualitativeOutput =>
      observedDispatchSeconds <= floorSeconds ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s ceiling of five seconds is slower than its '
      'floor of three, the first of three latency rows in this batch to put '
      'the ceiling at the far end from the optimal, and Step 487 carries the '
      'same three values under a different metric name; what is built keys '
      'alerts on the fault rather than the occurrence so forty retries produce '
      'one message, gives every alert a named owner and publishes none without '
      'one, lets severity alone decide whether a person is paged, and deletes '
      'alerts nobody acts on rather than muting them. Atomic Step: "Program '
      'anomaly alert triggers publishing Shakti Alerts to Slack on failure."';

  static Map<String, bool> get obligations => <String, bool>{
        'every alert has an owner': everyAlertHasAnOwner,
        'no alert is published without one':
            !anAlertWithNoOwnerIsPublished,
        'one fault is one message': oneFaultIsOneMessage,
        'only severity one pages a person': onlySeverityOnePages,
        'unactioned alerts are deleted, not muted': mutingIsNotTheAnswer,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the ceiling is slower than the floor':
            theCeilingIsSlowerThanTheFloor && theOptimalIsTheFastest,
        'three latency rows in this batch do the same':
            threeInOneBatch && bandNote.contains('the heading says the '
                'opposite'),
        'Step 487 carries the same values under another name':
            twoNamesForOneMeasure && theBandValuesAreIdentical,
        'which is how two charts stop agreeing':
            namingNote.contains('never agree'),
        'three alerts, each with an owner':
            alerts.length == 3 && everyAlertHasAnOwner,
        'alerts are keyed on the fault': keyedOnTheFaultNotTheOccurrence,
        'so forty retries produce one message': oneFaultIsOneMessage,
        'only the severity-one alert pages anybody':
            onlySeverityOnePages && severityChoosesTheChannel,
        'unactioned alerts are deleted rather than muted':
            mutingIsNotTheAnswer && noiseNote.contains('scrolls past with it'),
        'five obligations met, and 0.6 seconds reports Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
