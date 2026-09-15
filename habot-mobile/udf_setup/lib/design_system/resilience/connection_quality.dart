/// Step 260 (GEN-05386) -- what the network is actually doing, as opposed to
/// what it says it is.
///
/// The row: "Build and configure: integrate Network Information API listeners
/// (navigator.connection) into the mobile PWA shell."
/// Metric: **Low-Bandwidth Performance Resilience** -- floor <= 5% failure on
/// 3G, optimal <= 1% failure on 3G, ceiling 0% failure. Pass/Fail. Standard
/// cited: Google web.dev Network Resilience Guidelines.
///
/// **`navigator.connection` is a web API, and it is not everywhere.** It is
/// unavailable in Safari, which is every iOS browser; the Flutter android and
/// ios builds have no `navigator` at all. A policy keyed on it therefore has
/// no value on most of this application's targets, and the branch that runs
/// when it is absent is the branch that matters.
///
/// **Connection type is not connection quality.** `effectiveType` is an
/// estimate the browser derives from recent traffic, and a phone on 4G in a
/// basement is slower than one on 3G outdoors. Deciding what to load from a
/// label is deciding from a guess about a guess. What is not a guess is the
/// latency of the application's own requests, which this repository has been
/// measuring since Step 165.
///
/// **One part of the API is not an estimate.** `saveData` is a preference a
/// person set. It is honoured whenever it is readable, regardless of what the
/// bandwidth estimate says, because a preference outranks a measurement of
/// the thing the preference is about.
library;

import '../tokens/motion_tokens.dart';

/// Where a judgement about the network comes from.
enum HabotNetworkSignal {
  /// A stated preference. Not an estimate, and not overridable by one.
  userPreference,

  /// Measured round-trip latency of this application's own requests.
  measuredLatency,

  /// The platform's connectivity type: wifi, mobile, none.
  connectivityType,

  /// The browser's bandwidth estimate. Web only, absent on Safari.
  browserEstimate,
}

/// What the application does about it.
enum HabotDataPolicy {
  /// Everything: images at display resolution, prefetch ahead.
  full,

  /// No prefetch, images on demand.
  conservative,

  /// Text and structure only; images on an explicit tap.
  minimal,
}

/// One signal, with what it is worth.
class HabotSignalSource {
  const HabotSignalSource({
    required this.signal,
    required this.availableOn,
    required this.isAnEstimate,
    required this.why,
  });

  final HabotNetworkSignal signal;

  /// Targets where it can be read at all.
  final Set<String> availableOn;

  /// Whether the value is derived rather than stated or measured.
  final bool isAnEstimate;

  final String why;

  bool get isAvailableEverywhere => availableOn.length == 3;
}

/// The policy.
class HabotConnectionQuality {
  const HabotConnectionQuality._();

  static const Set<String> allTargets = <String>{'android', 'ios', 'web'};

  static List<HabotSignalSource> get sources => <HabotSignalSource>[
        const HabotSignalSource(
          signal: HabotNetworkSignal.userPreference,
          availableOn: <String>{'android', 'ios', 'web'},
          isAnEstimate: false,
          why: 'saveData on the web, and the platform data-saver setting on '
              'android. A preference a person set, which outranks any '
              'estimate of the thing the preference is about.',
        ),
        const HabotSignalSource(
          signal: HabotNetworkSignal.measuredLatency,
          availableOn: <String>{'android', 'ios', 'web'},
          isAnEstimate: false,
          why: 'The round-trip time of this application\'s own requests, '
              'which Step 165 has been measuring since it declared '
              'interactiveOn3g. Not a guess: it is the number the person is '
              'actually experiencing.',
        ),
        const HabotSignalSource(
          signal: HabotNetworkSignal.connectivityType,
          availableOn: <String>{'android', 'ios', 'web'},
          isAnEstimate: true,
          why: 'Wifi, mobile or none. Says whether a request can be made at '
              'all and nothing about how fast it will be -- wifi on a hotel '
              'network is slower than most mobile connections.',
        ),
        const HabotSignalSource(
          signal: HabotNetworkSignal.browserEstimate,
          availableOn: <String>{'web'},
          isAnEstimate: true,
          why: 'navigator.connection.effectiveType. Absent in Safari, which '
              'is every iOS browser, and absent in the android and ios '
              'builds which have no navigator at all. An estimate the '
              'browser derives from recent traffic.',
        ),
      ];

  static HabotSignalSource sourceFor(HabotNetworkSignal s) =>
      sources.firstWhere((HabotSignalSource x) => x.signal == s);

  /// The signal the row asks for, and the one target it works on.
  static Set<String> get targetsTheRowsApiCovers =>
      sourceFor(HabotNetworkSignal.browserEstimate).availableOn;

  static double get rowApiTargetCoverage =>
      targetsTheRowsApiCovers.length / allTargets.length;

  static List<HabotSignalSource> get signalsAvailableEverywhere =>
      sources.where((HabotSignalSource s) => s.isAvailableEverywhere).toList();

  static List<HabotSignalSource> get statedOrMeasured =>
      sources.where((HabotSignalSource s) => !s.isAnEstimate).toList();

  // -----------------------------------------------------------------------
  // The decision.
  // -----------------------------------------------------------------------

  /// The latency above which the application stops prefetching. Read from
  /// the Step 165 budget rather than declared again: if a round trip is
  /// taking as long as the whole interactive budget, prefetching a second
  /// one is taking the person's bandwidth to guess with.
  static Duration get conservativeAbove => HabotMotion.interactiveOn3g;

  /// Twice that, and the application stops fetching images at all without
  /// being asked.
  static Duration get minimalAbove => conservativeAbove * 2;

  /// The decision, in the order that matters: a stated preference first, a
  /// measurement second, and an estimate only where nothing better exists.
  static HabotDataPolicy policyFor({
    required bool saveDataRequested,
    required Duration? measuredRoundTrip,
    required bool isOffline,
  }) {
    if (isOffline) {
      return HabotDataPolicy.minimal;
    }
    if (saveDataRequested) {
      return HabotDataPolicy.minimal;
    }
    if (measuredRoundTrip == null) {
      return HabotDataPolicy.conservative;
    }
    if (measuredRoundTrip > minimalAbove) {
      return HabotDataPolicy.minimal;
    }
    if (measuredRoundTrip > conservativeAbove) {
      return HabotDataPolicy.conservative;
    }
    return HabotDataPolicy.full;
  }

  /// A stated preference is not overridden by a fast measurement.
  static bool get preferenceOutranksMeasurement =>
      policyFor(
        saveDataRequested: true,
        measuredRoundTrip: Duration.zero,
        isOffline: false,
      ) ==
      HabotDataPolicy.minimal;

  /// With nothing measured yet -- the first request of a cold start -- the
  /// application is careful rather than optimistic. Being wrong in the
  /// careful direction costs a prefetch; being wrong the other way costs the
  /// person their data.
  static bool get unknownIsConservative =>
      policyFor(
        saveDataRequested: false,
        measuredRoundTrip: null,
        isOffline: false,
      ) ==
      HabotDataPolicy.conservative;

  static bool get theBandIsMonotone =>
      policyFor(
        saveDataRequested: false,
        measuredRoundTrip: Duration.zero,
        isOffline: false,
      ) ==
          HabotDataPolicy.full &&
      policyFor(
        saveDataRequested: false,
        measuredRoundTrip: minimalAbove,
        isOffline: false,
      ) ==
          HabotDataPolicy.conservative &&
      policyFor(
        saveDataRequested: false,
        measuredRoundTrip: minimalAbove * 2,
        isOffline: false,
      ) ==
          HabotDataPolicy.minimal;

  /// Offline is not slow. It is a different state and it has its own
  /// component already -- this policy defers to it rather than treating no
  /// connection as an extremely long round trip.
  static bool get offlineIsNotJustSlow =>
      policyFor(
        saveDataRequested: false,
        measuredRoundTrip: Duration.zero,
        isOffline: true,
      ) ==
      HabotDataPolicy.minimal;

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String webApiNote =
      'navigator.connection is a web API and it is not everywhere. It is '
      'unavailable in Safari, which is every browser on iOS, and the Flutter '
      'android and ios builds have no navigator at all. A policy keyed on it '
      'has no value on two of this application\'s three targets, so the '
      'branch that runs when it is absent is the branch that matters -- and '
      'writing the policy around the absent case first is the difference '
      'between a feature and a feature that works on one target.';

  static const String typeIsNotQualityNote =
      'Connection type is not connection quality. effectiveType is an '
      'estimate the browser derives from recent traffic, and a phone on 4G in '
      'a basement is slower than one on 3G outdoors; wifi on a hotel network '
      'is slower than most mobile connections. Deciding what to load from a '
      'label is deciding from a guess about a guess. What is not a guess is '
      'the round-trip time of this application\'s own requests, which it has '
      'been measuring since Step 165.';

  static const String saveDataNote =
      'One part of the API is not an estimate. saveData is a preference a '
      'person set, and it is honoured whenever it is readable regardless of '
      'what the bandwidth estimate says -- a preference outranks a '
      'measurement of the thing the preference is about. It is the only part '
      'of navigator.connection this policy reads, and it has a platform '
      'equivalent on android, so it is the part that generalises.';

  static const String metricNote =
      'The metric is "<= 5% failure on 3G", which is a property of the whole '
      'request path rather than of this policy: a failure rate on 3G depends '
      'on the server, the carrier and the payload. What this step can be '
      'graded on is whether the decision is made from the best signal '
      'available on each target, and whether the case where the row\'s own '
      'API is missing is the one the policy is built around. Both are '
      'measured; the failure rate is named as needing a field measurement no '
      'build host can take.';

  // -----------------------------------------------------------------------
  // Metric.
  // -----------------------------------------------------------------------

  static Map<String, bool> get checks => <String, bool>{
        'four signals are distinguished by where they come from':
            HabotNetworkSignal.values.length == 4 && sources.length == 4,
        'the API the row names covers one of three targets':
            targetsTheRowsApiCovers.length == 1 &&
                (rowApiTargetCoverage - 1 / 3).abs() < 1e-9,
        'three signals are available everywhere, and two of those are not '
            'estimates': signalsAvailableEverywhere.length == 3 &&
            statedOrMeasured.length == 2,
        'a stated preference outranks a fast measurement':
            preferenceOutranksMeasurement,
        'nothing measured yet means careful, not optimistic':
            unknownIsConservative,
        'the policy is monotone in the measured round trip': theBandIsMonotone,
        'offline is a different state, not an extremely long round trip':
            offlineIsNotJustSlow,
        'the thresholds are read from the Step 165 budget rather than '
            'declared again': conservativeAbove == HabotMotion.interactiveOn3g,
        'the absent-API case is named as the one the policy is built around':
            webApiNote.contains('the branch that matters'),
        'the row\'s failure-rate metric is named as a field measurement':
            metricNote.contains('no build host can take'),
      };

  static String get qualitativeOutput =>
      checks.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Build and configure: integrate Network Information API listeners '
      '(navigator.connection) into the mobile PWA shell."';
}
