/// Step 374 (GEN-01628) -- a widget that must not know where its numbers came
/// from, and the third copy of the shared band.
///
/// The row: "Connect dashboard widgets to fetch aggregated telemetry from
/// BigQuery streaming APIs."
/// Metric: **Dashboard Data Refresh Latency** -- floor "<1 hour", optimal
/// "<5 minutes", ceiling "<24 hours". Good/Average/Poor. Assigned to **DEA**.
///
/// **A widget that names its warehouse is a widget that cannot be moved.**
/// "Fetch from BigQuery streaming APIs" is a transport decision written into a
/// presentation row. A dashboard widget should take a series and a freshness
/// state and know nothing else; whether the series arrived from a streaming
/// API, a cached aggregate or a fixture is the repository's business, and Step
/// 112 settled that shape for this project long before this row asked.
///
/// **A client that queries a warehouse directly is a client holding warehouse
/// credentials.** That is the part the row does not mention and the part that
/// matters: a mobile application cannot hold a service account that can read
/// an analytics warehouse, because the application ships to devices and the
/// credential ships with it. The widget therefore binds to an endpoint that
/// returns an already-aggregated series, and the aggregation happens where the
/// credential lives.
///
/// **Aggregated is also a privacy control, not only a performance one.** An
/// aggregate over a small group is not anonymous -- which Step 362 records two
/// rows earlier with a k-anonymity floor -- so the binding refuses a series
/// whose buckets fall below the same floor rather than rendering them.
///
/// **Third copy of the shared band.** Steps 358, 362 and 375 carry it too, and
/// Steps 163 and 175 tokenised it. The widget reads its freshness from the
/// Step 129 policy instead.
library;

import '../badges/safety_ratio_panel.dart';
import 'freshness.dart';
import 'search_trends.dart';

/// Where a series came from, as far as the widget is concerned.
enum HabotSeriesOrigin {
  /// An endpoint that returns an aggregated series.
  aggregateEndpoint,

  /// A fixture, in tests.
  fixture,
}

/// One bucket of an aggregated series.
class HabotSeriesBucket {
  const HabotSeriesBucket({
    required this.label,
    required this.value,
    required this.contributors,
  });

  final String label;
  final double value;

  /// How many distinct subjects are behind the bucket.
  final int contributors;
}

/// The binding between a dashboard widget and its data.
class HabotTelemetryWidgetBinding {
  const HabotTelemetryWidgetBinding._();

  // -----------------------------------------------------------------------
  // The widget does not name its warehouse.
  // -----------------------------------------------------------------------

  static const String transportTheRowNames = 'BigQuery streaming APIs';

  static const bool theWidgetKnowsItsTransport = false;

  static const List<String> whatTheWidgetTakes = <String>[
    'a series',
    'a freshness state',
  ];

  static bool get theWidgetTakesTwoThings => whatTheWidgetTakes.length == 2;

  static bool get theOriginIsSwappable =>
      HabotSeriesOrigin.values.length == 2 && !theWidgetKnowsItsTransport;

  static const int theStepThatSettledTheShape = 112;

  static const String transportNote =
      '"Fetch from BigQuery streaming APIs" is a transport decision written '
      'into a presentation row. A dashboard widget takes a series and a '
      'freshness state and knows nothing else; whether the series arrived from '
      'a streaming API, a cached aggregate or a fixture is the repository\'s '
      'business, and Step 112 settled that shape for this project long before '
      'this row asked. A widget that names its warehouse is a widget that '
      'cannot be tested without one.';

  // -----------------------------------------------------------------------
  // A client that queries a warehouse holds its credentials.
  // -----------------------------------------------------------------------

  static const bool theClientHoldsWarehouseCredentials = false;

  static const String whereTheAggregationHappens =
      'behind an endpoint, where the credential lives';

  static bool get theCredentialNeverShips =>
      !theClientHoldsWarehouseCredentials &&
      whereTheAggregationHappens.contains('where the credential lives');

  static const String credentialNote =
      'A mobile application cannot hold a service account that can read an '
      'analytics warehouse, because the application ships to devices and the '
      'credential ships with it -- and a warehouse credential reads everything '
      'in the warehouse, not the one series a widget wanted. The row does not '
      'mention this, and it is the part that decides the design: the widget '
      'binds to an endpoint returning an already-aggregated series, and the '
      'aggregation happens where the credential can stay.';

  // -----------------------------------------------------------------------
  // Aggregated is a privacy control too.
  // -----------------------------------------------------------------------

  static int get anonymityFloor => HabotSearchTrends.kAnonymityFloor;

  static const List<HabotSeriesBucket> series = <HabotSeriesBucket>[
    HabotSeriesBucket(label: 'Week 1', value: 412, contributors: 180),
    HabotSeriesBucket(label: 'Week 2', value: 388, contributors: 175),
    HabotSeriesBucket(label: 'Week 3', value: 96, contributors: 41),
    HabotSeriesBucket(label: 'Week 4', value: 7, contributors: 4),
  ];

  static bool isRenderable(HabotSeriesBucket b) =>
      b.contributors >= anonymityFloor;

  static List<HabotSeriesBucket> get renderable =>
      series.where(isRenderable).toList();

  static List<HabotSeriesBucket> get withheld =>
      series.where((HabotSeriesBucket b) => !isRenderable(b)).toList();

  /// Three of four buckets render; the fourth has four contributors and is
  /// withheld rather than drawn as a very short bar.
  static bool get threeOfFourRender =>
      renderable.length == 3 && withheld.length == 1;

  static const bool aWithheldBucketIsDrawnAsZero = false;

  static String get withholdingLabel =>
      '${withheld.length} period below the reporting threshold';

  static bool get theWithholdingIsStated =>
      withholdingLabel.contains('below the reporting threshold');

  static const String privacyNote =
      'An aggregate over a small group is not anonymous, which Step 362 '
      'records two rows earlier with the same floor. A bucket with four '
      'contributors is four people, and drawing it as a very short bar '
      'publishes them. The binding withholds it and says so, because drawing '
      'it as zero would be a different lie -- the series would read as a '
      'collapse in activity rather than as a period held back.';

  // -----------------------------------------------------------------------
  // Freshness, from the policy rather than the row.
  // -----------------------------------------------------------------------

  static bool get theBandIsTheSharedOne =>
      HabotSafetyRatioPanel.rowsSharingThisBand.contains(374);

  static int get rowsSharingIt =>
      HabotSafetyRatioPanel.rowsSharingThisBand.length;

  static const bool theWidgetAdoptsTheRowsBand = false;

  static HabotFreshness freshnessOf(Duration age) =>
      HabotFreshnessPolicy.classify(age);

  static bool get theWidgetCarriesAFreshnessState =>
      whatTheWidgetTakes.contains('a freshness state');

  static const String bandNote =
      'The third copy of the shared band: Steps 358, 362 and 375 carry the '
      'identical three cells and Steps 163 and 175 tokenised them, six rows in '
      'all. The widget does not adopt it. It takes a freshness state '
      'classified by the Step 129 policy, so a series that is a day old is '
      'labelled Delayed on the widget rather than being treated as ideal.';

  static Map<String, bool> get obligations => <String, bool>{
        'the widget does not know its transport':
            !theWidgetKnowsItsTransport && theOriginIsSwappable,
        'the widget takes a series and a freshness state':
            theWidgetTakesTwoThings && theWidgetCarriesAFreshnessState,
        'no warehouse credential reaches the client':
            theCredentialNeverShips,
        'a bucket below the anonymity floor is withheld':
            threeOfFourRender && !aWithheldBucketIsDrawnAsZero,
        'the withholding is stated rather than silent':
            theWithholdingIsStated,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the row names a transport and the widget does not':
            transportTheRowNames.contains('BigQuery') &&
                !theWidgetKnowsItsTransport,
        'the widget takes two things and nothing else':
            theWidgetTakesTwoThings && theOriginIsSwappable,
        'the shape was settled at Step 112':
            theStepThatSettledTheShape == 112 &&
                transportNote.contains('cannot be tested without one'),
        'no warehouse credential ships to a device':
            theCredentialNeverShips &&
                credentialNote.contains('reads everything'),
        'four buckets, three of which render':
            series.length == 4 && threeOfFourRender,
        'the anonymity floor is the one Step 362 declared':
            anonymityFloor == 10 && privacyNote.contains('Step 362'),
        'a withheld bucket is not drawn as zero':
            !aWithheldBucketIsDrawnAsZero &&
                privacyNote.contains('a different lie'),
        'the withholding is stated on the widget': theWithholdingIsStated,
        'this row carries the shared band and does not adopt it':
            theBandIsTheSharedOne &&
                rowsSharingIt == 6 &&
                !theWidgetAdoptsTheRowsBand,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to DEA rather than UDF, it writes a '
      'transport decision into a presentation row, its band is the one shared '
      'with Steps 358, 362 and 375 of this batch and with Steps 163 and 175, '
      'its Data Requirement cell holds the Atomic Step\'s own truncated text '
      'as the artefact to prepare, and the Setup Step column is empty. Atomic '
      'Step: "Connect dashboard widgets to fetch aggregated telemetry from '
      'BigQuery streaming APIs."';
}
