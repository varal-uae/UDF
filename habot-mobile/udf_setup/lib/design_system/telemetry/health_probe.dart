/// AISS Step 162 -- GEN-01021
/// Setup Step (Action): "Deploy Automated System Handshake & Health Probe
///                       Architecture"
/// Atomic Step: "Stream health check probe logs to BigQuery table
///               audit.system_health_probes."
/// Metric: Ingestion Delay -- Floor "<= 1 sec", Optimal "Instant",
///         Ceiling "<= 3 secs". Complete / Not Complete.
///
/// **"INSTANT" IS NOT A NUMBER, AND PRETENDING IT IS WOULD BE THE DISHONEST
/// READING.** An optimal of "Instant" cannot be met or missed. The smallest
/// interval this app can actually observe is one frame, so that is what
/// [HabotMotion.probeIngestionOptimal] holds, and the substitution is
/// recorded. The floor and the ceiling are real numbers and are used as given.
///
/// **A PROBE PIPELINE THAT ONLY REPORTS FAILURES CANNOT TELL A HEALTHY SYSTEM
/// FROM A STOPPED PROBE.** Silence means either "everything is fine" or "the
/// probe has not run since Tuesday", and those are the two states an
/// operations team most needs to distinguish. Healthy results are therefore
/// streamed too, which is also why the ingestion delay matters: a late healthy
/// probe looks exactly like a missing one.
///
/// **PROBES ARE FOREGROUND-ONLY.** A probe that runs while the app is
/// backgrounded wakes the radio to measure a radio that is asleep: it burns
/// battery and reports a round-trip time that describes the wake-up, not the
/// dependency. The Step 119 lifecycle observer suspends probing, and Step 166
/// drops anything that slipped through.
///
/// **WHAT IS PROBED IS DECLARED, NOT DISCOVERED.** A probe set assembled by
/// whoever remembered to add one ends up covering the dependency that broke
/// last year and not the one that will break next. The four here are the ones
/// this app cannot function without, each with the reason it is on the list.
library;

import '../data/outbox.dart';
import '../tokens/motion_tokens.dart';
import 'event_schema.dart';

/// The dependencies this app probes.
enum HabotProbeTarget {
  /// The API this app writes through. Everything queues behind it.
  api,

  /// The socket that carries live status (Steps 126-128).
  socket,

  /// The local store the outbox is durable in (Step 113). A probe here
  /// catches a full disk before a user loses a form to it.
  localStore,

  /// The clock. Sounds trivial; a device whose clock is hours out produces
  /// revisions that sort wrongly and tokens that read as expired.
  clock,
}

/// Why each target is probed. Declared so the set can be argued with.
class HabotProbeRationale {
  const HabotProbeRationale._();

  static const Map<HabotProbeTarget, String> reasons =
      <HabotProbeTarget, String>{
    HabotProbeTarget.api:
        'Every queued write goes through it; when it is down the outbox grows '
            'silently and the user sees nothing until the queue counter does.',
    HabotProbeTarget.socket:
        'Live status arrives over it. A socket that is open and dead looks '
            'identical to a quiet one, which is what Step 127 exists for.',
    HabotProbeTarget.localStore:
        'Durability depends on it. A full disk turns every autosave into a '
            'silent failure, and a user loses a form to it before anyone '
            'notices.',
    HabotProbeTarget.clock:
        'A device hours out of sync produces revisions that sort wrongly and '
            'tokens that read as expired. It is the cheapest probe here and '
            'the one nobody thinks to run.',
  };
}

/// One probe result.
class HabotProbeResult {
  const HabotProbeResult({
    required this.target,
    required this.healthy,
    required this.roundTrip,
    required this.at,
    required this.traceId,
  });

  final HabotProbeTarget target;
  final bool healthy;
  final Duration roundTrip;
  final DateTime at;
  final String traceId;

  Map<String, Object?> toRow() => <String, Object?>{
        'probe': target.name,
        'healthy': healthy,
        'rtt_ms': roundTrip.inMilliseconds,
        'probed_at': at.toUtc().toIso8601String(),
        'trace_id': traceId,
      };

  HabotEvent toEvent({required int sessionOrdinal}) => HabotEvent(
        kind: HabotEventKind.probeCompleted,
        view: 'system',
        traceId: traceId,
        occurredAt: at,
        sessionOrdinal: sessionOrdinal,
        payload: <String, Object?>{
          'probe': target.name,
          'healthy': healthy,
          'rtt_ms': roundTrip.inMilliseconds,
        },
      );
}

/// Runs probes and hands their results over.
class HabotHealthProbe {
  HabotHealthProbe({
    required this.outbox,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final HabotOutbox outbox;
  final DateTime Function() _clock;

  static const String destinationTable = 'audit.system_health_probes';
  static const String outboxKind = 'health_probe_log';

  final List<HabotProbeResult> _results = <HabotProbeResult>[];
  final Set<String> _handedOver = <String>{};
  final List<Duration> _handoverDelays = <Duration>[];
  int _suppressedInBackground = 0;

  bool _foreground = true;

  List<HabotProbeResult> get results =>
      List<HabotProbeResult>.unmodifiable(_results);

  int get suppressedInBackground => _suppressedInBackground;

  /// Driven by the Step 119 lifecycle observer.
  void setForeground({required bool foreground}) => _foreground = foreground;

  bool get isProbing => _foreground;

  static String idOf(HabotProbeResult r) =>
      '${r.target.name}:${r.at.toUtc().millisecondsSinceEpoch}';

  /// Record a probe result and queue it.
  ///
  /// Returns null when the app is backgrounded: the probe is not run and not
  /// recorded, rather than run and discarded, because running it is the part
  /// that costs battery.
  Future<HabotOutboxEntry?> record(HabotProbeResult result) async {
    if (!_foreground) {
      _suppressedInBackground++;
      return null;
    }
    final DateTime start = _clock();
    _results.add(result);
    final HabotOutboxEntry entry = await outbox.enqueue(
      id: idOf(result),
      kind: outboxKind,
      payload: <String, Object?>{
        'destination_table': destinationTable,
        ...result.toRow(),
      },
    );
    _handedOver.add(idOf(result));
    _handoverDelays.add(_clock().difference(start));
    return entry;
  }

  /// Results recorded but never queued. Empty is the requirement.
  List<String> get notHandedOver => _results
      .map(idOf)
      .where((String id) => !_handedOver.contains(id))
      .toList();

  /// Healthy results are streamed as well as failures -- see the header.
  int get healthyStreamed =>
      _results.where((HabotProbeResult r) => r.healthy).length;

  int get unhealthyStreamed =>
      _results.where((HabotProbeResult r) => !r.healthy).length;

  /// Targets with no result at all. Reported, because a probe that is not
  /// running is the failure this whole architecture exists to make visible.
  List<HabotProbeTarget> get unprobedTargets => HabotProbeTarget.values
      .where((HabotProbeTarget t) =>
          !_results.any((HabotProbeResult r) => r.target == t))
      .toList();

  // ---- the row's metric ---------------------------------------------------

  /// The hop this client owns: probe result to durable queue.
  Duration get handoverDelay {
    if (_handoverDelays.isEmpty) {
      return Duration.zero;
    }
    int micros = 0;
    for (final Duration d in _handoverDelays) {
      micros += d.inMicroseconds;
    }
    return Duration(microseconds: micros ~/ _handoverDelays.length);
  }

  /// The row's bands, applied to an observed end-to-end ingestion delay.
  static String bandFor(Duration delay) {
    if (delay <= HabotMotion.probeIngestionOptimal) {
      return 'optimal (as close to instant as observable)';
    }
    if (delay <= HabotMotion.probeIngestionFloor) {
      return 'within floor (<= 1s)';
    }
    return delay <= HabotMotion.probeIngestionCeiling
        ? 'within ceiling (<= 3s)'
        : 'BEYOND CEILING';
  }

  static bool withinCeiling(Duration delay) =>
      delay <= HabotMotion.probeIngestionCeiling;

  static const String instantSubstitution =
      'The row\'s optimal is "Instant", which cannot be met or missed. The '
      'smallest interval this app can observe is one frame, so that is what '
      'the optimal token holds. The floor (1s) and ceiling (3s) are real '
      'numbers and are used as given.';

  static const String healthyStreamedNote =
      'Healthy results are streamed too. A pipeline that reports only '
      'failures cannot tell "everything is fine" from "the probe has not run '
      'since Tuesday", and those are the two states an operations team most '
      'needs to distinguish -- which is also why a late healthy probe matters: '
      'it looks exactly like a missing one.';

  static const String foregroundOnlyNote =
      'A probe that runs while the app is backgrounded wakes the radio to '
      'measure a radio that is asleep: it burns battery and reports a '
      'round-trip that describes the wake-up rather than the dependency. The '
      'probe is not run at all in the background, rather than run and '
      'discarded, because running it is the part that costs.';

  static const String bigQueryBoundary =
      'The client records and hands over carrying the destination table the '
      'row names; landing the row in audit.system_health_probes is the server '
      'concern. Same boundary as Steps 132, 145 and 161.';
}
