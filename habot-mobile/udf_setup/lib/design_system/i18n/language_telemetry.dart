/// AISS Step 145 -- GEN-04968
/// Setup Step (Action) / Atomic Step: "Wire data logging per the BigQuery/GCP
///   alignment requirement: Language usage telemetry streamed to BigQuery to
///   identify underserved demographic groups (data captured: log language
///   preference selections to BigQuery demographic tables)."
/// Metric: Event Logging Completeness & Streaming Latency -- Floor "<=5 min
///         end-to-end event delivery latency, >=99% event capture
///         completeness", Optimal "<=1 min latency, 100% completeness",
///         Ceiling "<=15 min latency before analytics data is considered
///         stale". Complete / Partial / Not Complete.
///
/// **99% CAPTURE IS UNREACHABLE FOR THIS EVENT WITHOUT THE STEP 117 OUTBOX,
/// AND THAT IS THE WHOLE DESIGN.** The moment a language preference is set is
/// disproportionately likely to be a moment with no network: it is one of the
/// first things a new user does, often on a depot handset, often before they
/// have connected to anything. A fire-and-forget HTTP post loses exactly the
/// events the row exists to collect -- the underserved groups it is trying to
/// identify are the ones whose events go missing. So the selection is written
/// to the durable outbox in the same operation that changes the preference,
/// and the sync loop delivers it whenever the device next has a connection.
///
/// **THE LATENCY THE ROW MEASURES IS NOT THE LATENCY THIS CLIENT CONTROLS.**
/// "End-to-end event delivery" spans client capture, transport, an ingestion
/// service and a BigQuery streaming insert. The client owns the first hop.
/// [HabotLanguageTelemetry.handoverLatency] reports the part it owns -- time
/// from selection to the event being durably queued -- and the evidence says
/// plainly that the remaining hops are the server's. Reporting an end-to-end
/// figure this code cannot observe would be a fabricated measurement.
///
/// **A LANGUAGE PREFERENCE IS DEMOGRAPHIC DATA, AND THE ROW SAYS SO.**
/// "Demographic tables", "underserved demographic groups". That makes this
/// event more sensitive than a tap count: it is a strong proxy for ethnicity
/// and immigration status. The purpose the row states -- finding underserved
/// groups -- needs COUNTS, not people. So the event carries an install-scoped
/// id and nothing else identifying: no account id, no device id, no free text.
/// Aggregate answers do not need to be joinable back to a person, and an
/// event that cannot be joined cannot later be repurposed into one that is.
///
/// THE BIGQUERY BOUNDARY IS THE STEP 132 ONE, unchanged: a mobile client
/// holding warehouse credentials would be a security defect rather than a
/// feature. The client records and hands over, carrying the destination table
/// name; landing the row is the server's half.
library;

import '../data/outbox.dart';
import '../tokens/motion_tokens.dart';

/// What made a language become active.
enum HabotLanguageSelectionSource {
  /// The user chose it in the settings toggle.
  userChoice,

  /// Taken from the OS locale on first launch.
  deviceDefault,

  /// The app fell back because the chosen language stopped being offerable.
  fallback,
}

/// One language-selection event.
class HabotLanguageEvent {
  const HabotLanguageEvent({
    required this.installId,
    required this.selectedLocale,
    required this.previousLocale,
    required this.source,
    required this.deviceLocale,
    required this.occurredAt,
  });

  /// Install-scoped, rotating with a reinstall, never joined to an account.
  /// See the header: counts, not people.
  final String installId;

  final String selectedLocale;

  /// What it was before. Without this a switch away from a language looks
  /// identical to a switch toward it, and "underserved" is exactly the
  /// distinction that matters.
  final String? previousLocale;

  final HabotLanguageSelectionSource source;

  /// What the OS was set to. The gap between this and [selectedLocale] is the
  /// actual signal: a device set to Polish whose user selects Polish tells you
  /// the default was right; one set to English whose user selects Urdu tells
  /// you the default was wrong for them.
  final String deviceLocale;

  final DateTime occurredAt;

  Map<String, Object?> toPayload() => <String, Object?>{
        'destination_table': HabotLanguageTelemetry.destinationTable,
        'install_id': installId,
        'selected_locale': selectedLocale,
        'previous_locale': previousLocale,
        'device_locale': deviceLocale,
        'source': source.name,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
      };

  /// The fields this event deliberately does NOT carry. Declared so that
  /// adding one is a visible change to a list rather than a quiet addition to
  /// a payload.
  static const List<String> excludedFields = <String>[
    'account_id',
    'user_id',
    'device_id',
    'email',
    'name',
    'free_text',
  ];
}

/// Records language selections and hands them to the outbox.
class HabotLanguageTelemetry {
  HabotLanguageTelemetry({
    required this.outbox,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final HabotOutbox outbox;
  final DateTime Function() _clock;

  static const String destinationTable =
      'demographics.language_preference_events_v1';

  static const String outboxKind = 'language_preference_event';

  final List<HabotLanguageEvent> _recorded = <HabotLanguageEvent>[];
  final Set<String> _handedOver = <String>{};
  final List<Duration> _handoverLatencies = <Duration>[];

  List<HabotLanguageEvent> get recorded =>
      List<HabotLanguageEvent>.unmodifiable(_recorded);

  int get eventsRecorded => _recorded.length;

  /// Events recorded but not handed to the queue. Empty is the requirement.
  List<String> get notHandedOver => _recorded
      .map(idOf)
      .where((String id) => !_handedOver.contains(id))
      .toList();

  /// A stable id for one selection, so a double-tap on the same option
  /// enqueues once. The outbox dedupes at enqueue by id (Step 117).
  static String idOf(HabotLanguageEvent e) =>
      '${e.installId}:${e.selectedLocale}:'
      '${e.occurredAt.toUtc().millisecondsSinceEpoch}';

  /// Record a selection and queue it.
  Future<HabotOutboxEntry> record(HabotLanguageEvent event) async {
    final DateTime start = _clock();
    _recorded.add(event);
    final HabotOutboxEntry entry = await outbox.enqueue(
      id: idOf(event),
      kind: outboxKind,
      payload: event.toPayload(),
    );
    _handedOver.add(idOf(event));
    _handoverLatencies.add(_clock().difference(start));
    return entry;
  }

  // ---- the row's metric ---------------------------------------------------

  /// Capture completeness: the share of recorded selections that reached the
  /// durable queue.
  ///
  /// Tracked at the moment of enqueue rather than inferred from the queue
  /// later -- once an entry is sent it is gone from the queue, and "not in
  /// the queue" cannot then tell delivered from never-queued. Same reasoning
  /// as Step 132, and the same mistake avoided.
  double get captureCompleteness => _recorded.isEmpty
      ? 1
      : (_recorded.length - notHandedOver.length) / _recorded.length;

  /// The latency this client actually controls: selection to durable queue.
  Duration get handoverLatency {
    if (_handoverLatencies.isEmpty) {
      return Duration.zero;
    }
    int micros = 0;
    for (final Duration d in _handoverLatencies) {
      micros += d.inMicroseconds;
    }
    return Duration(microseconds: micros ~/ _handoverLatencies.length);
  }

  /// Which band an observed end-to-end delivery time falls in, in the row's
  /// own words. Takes the figure as an argument because the client cannot
  /// observe it -- see the header.
  static String bandFor(Duration endToEnd) {
    if (endToEnd <= HabotMotion.telemetryDeliveryOptimal) {
      return 'optimal (<= 1 min)';
    }
    if (endToEnd <= HabotMotion.telemetryDeliveryFloor) {
      return 'within floor (<= 5 min)';
    }
    if (endToEnd <= HabotMotion.telemetryStale) {
      return 'late but usable (<= 15 min)';
    }
    return 'STALE (> 15 min)';
  }

  static bool isStale(Duration endToEnd) =>
      endToEnd > HabotMotion.telemetryStale;

  static const double captureFloor = 0.99;
  static const double captureOptimal = 1.0;

  /// The event's payload must not carry anything that identifies a person.
  static List<String> privacyViolations(HabotLanguageEvent e) {
    final Map<String, Object?> payload = e.toPayload();
    return HabotLanguageEvent.excludedFields
        .where(payload.containsKey)
        .toList();
  }

  static const String offlineCaptureNote =
      'The moment a language preference is set is disproportionately likely to '
      'be a moment with no network: it is one of the first things a new user '
      'does, often on a depot handset, often before connecting to anything. A '
      'fire-and-forget post would lose exactly the events this row exists to '
      'collect -- the underserved groups it is trying to identify are the ones '
      'whose events go missing. The selection is written to the Step 117 '
      'durable outbox in the same operation that changes the preference.';

  static const String latencyBoundaryNote =
      '"End-to-end event delivery latency" spans client capture, transport, '
      'an ingestion service and a BigQuery streaming insert. This client owns '
      'the first hop and reports it. The remaining hops are the server\'s, and '
      'reporting an end-to-end figure this code cannot observe would be a '
      'fabricated measurement.';

  static const String privacyNote =
      'A language preference is a strong proxy for ethnicity and immigration '
      'status, and the row itself calls the destination a demographic table. '
      'The purpose it states -- finding underserved groups -- needs counts, '
      'not people, so the event carries an install-scoped id and nothing else '
      'identifying. An event that cannot be joined to a person cannot later be '
      'repurposed into one that is, and HabotLanguageEvent.excludedFields '
      'makes adding such a field a visible change to a list rather than a '
      'quiet addition to a payload.';

  static const String bigQueryBoundary =
      'A mobile client must not write to BigQuery: an app holding warehouse '
      'credentials would be a security defect rather than a feature. The '
      'client records the selection durably and hands it over carrying the '
      'destination table name; landing the row is the server concern. Same '
      'boundary as Step 132.';
}
