/// AISS Step 127 -- GEN-04550
/// Atomic Step: "Implement heartbeat ping/pong mechanisms maintaining
///               connection viability."
/// Metric: Real-Time Message Delivery Latency -- Floor < 2s, Optimal < 500ms,
///         Ceiling < 100ms (diminishing returns).
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// BAND DIRECTION, RECORDED: lower is better here, and the sheet has written
/// the CEILING as the best value again (<100ms) with the floor as the worst
/// (<2s). Same inversion as Step 102's row. Both figures are used in the
/// direction they plainly mean, and the inversion is recorded rather than
/// silently normalised.
///
/// WHY A HEARTBEAT EXISTS AT ALL, because "the socket says it is open" sounds
/// like enough and is not. A TCP connection through a mobile NAT survives in
/// the client's memory long after the carrier has dropped the mapping. The
/// socket reports `open`, writes succeed into a buffer, and nothing arrives.
/// This is the single most common way a "real-time" mobile app silently stops
/// being real-time, and no error is ever raised.
///
/// A heartbeat is the only way to tell a live connection from a dead one that
/// has not noticed: send something, require an answer, and treat silence as a
/// drop. [HabotHeartbeat.missedBeatsBeforeDead] is how much silence is allowed.
///
/// WHAT IT PRODUCES FOR THE REST OF THE BATCH. Every pong is a round-trip
/// measurement, and Step 124's governor needs exactly those. The heartbeat is
/// therefore the app's primary RTT source, which is also why it is classed as
/// [HabotWorkClass.lightBackground] there: pausing the thing that measures the
/// link, because the link is slow, would leave the governor blind.
library;

import 'dart:async';

import '../tokens/motion_tokens.dart';

/// What the heartbeat currently believes.
enum HabotLiveness {
  /// Answering within the budget.
  live,

  /// Answering, but slowly. The link works and is degraded.
  slow,

  /// Beats have gone unanswered but not yet enough to declare it dead.
  suspect,

  /// Silent past the allowance. Treated as dropped.
  dead,
}

/// One ping and what came back.
class HabotBeat {
  const HabotBeat({
    required this.sequence,
    required this.sentAt,
    this.answeredAt,
  });

  final int sequence;
  final DateTime sentAt;

  /// Null while outstanding, and stays null if it is never answered.
  final DateTime? answeredAt;

  bool get answered => answeredAt != null;

  Duration? get rtt =>
      answeredAt == null ? null : answeredAt!.difference(sentAt);

  HabotBeat answeredAtTime(DateTime at) =>
      HabotBeat(sequence: sequence, sentAt: sentAt, answeredAt: at);
}

/// Ping, pong, and the judgement in between.
class HabotHeartbeat {
  HabotHeartbeat({
    required this.sendPing,
    this.onRoundTrip,
    this.onDeclaredDead,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Puts a ping on the wire. Returns immediately; the answer arrives through
  /// [recordPong].
  final Future<void> Function(int sequence) sendPing;

  /// Called with every measured round trip. This is what Step 124's governor
  /// subscribes to.
  final void Function(Duration rtt)? onRoundTrip;

  /// Called once when the connection is declared dead, so Step 121's backoff
  /// can start. Called ONCE per death, not per missed beat.
  final void Function()? onDeclaredDead;

  final DateTime Function() _clock;

  /// How often to beat.
  static Duration get interval => HabotMotion.heartbeatInterval;

  /// How long an answer may take before the beat counts as missed.
  static Duration get timeout => HabotMotion.heartbeatTimeout;

  /// Answering slower than this means the link is degraded but alive. The
  /// row's floor, which is the WORST acceptable latency.
  static Duration get slowThreshold => HabotMotion.heartbeatSlowThreshold;

  /// Two missed beats, not one. A single missed beat is a phone that switched
  /// from wifi to cellular mid-flight -- extremely common, and declaring the
  /// connection dead for it would mean reconnecting constantly on a train.
  static const int missedBeatsBeforeDead = 2;

  final List<HabotBeat> _beats = <HabotBeat>[];
  int _sequence = 0;
  int _consecutiveMissed = 0;
  bool _declaredDead = false;
  Timer? _timer;

  List<HabotBeat> get beats => List<HabotBeat>.unmodifiable(_beats);
  int get consecutiveMissed => _consecutiveMissed;
  bool get isDeclaredDead => _declaredDead;

  HabotBeat? get outstanding {
    for (final HabotBeat b in _beats.reversed) {
      if (!b.answered) {
        return b;
      }
    }
    return null;
  }

  /// Round trips measured, newest last.
  List<Duration> get roundTrips => _beats
      .where((HabotBeat b) => b.answered)
      .map((HabotBeat b) => b.rtt!)
      .toList();

  Duration? get lastRtt => roundTrips.isEmpty ? null : roundTrips.last;

  /// The current judgement.
  HabotLiveness get liveness {
    if (_declaredDead) {
      return HabotLiveness.dead;
    }
    if (_consecutiveMissed > 0) {
      return HabotLiveness.suspect;
    }
    final Duration? rtt = lastRtt;
    if (rtt == null) {
      return HabotLiveness.live;
    }
    return rtt > slowThreshold ? HabotLiveness.slow : HabotLiveness.live;
  }

  /// Send one beat.
  Future<HabotBeat> beat() async {
    _sequence++;
    final HabotBeat b = HabotBeat(sequence: _sequence, sentAt: _clock());
    _beats.add(b);
    await sendPing(_sequence);
    return b;
  }

  /// The answer arrived. Ignores a pong for a beat that already timed out --
  /// a late answer is not evidence the link is healthy, it is evidence it is
  /// slow, and counting it would let a dying connection look alive.
  Duration? recordPong(int sequence) {
    final int i = _beats.indexWhere(
      (HabotBeat b) => b.sequence == sequence && !b.answered,
    );
    if (i < 0) {
      return null;
    }
    final DateTime at = _clock();
    final HabotBeat answered = _beats[i].answeredAtTime(at);
    if (answered.rtt! > timeout) {
      // Late. Recorded so the latency figure stays honest, but it does not
      // clear the missed-beat counter.
      _beats[i] = answered;
      onRoundTrip?.call(answered.rtt!);
      return answered.rtt;
    }
    _beats[i] = answered;
    _consecutiveMissed = 0;
    _declaredDead = false;
    onRoundTrip?.call(answered.rtt!);
    return answered.rtt;
  }

  /// Called when a beat's timeout expires with no answer.
  void recordMissed() {
    _consecutiveMissed++;
    if (_consecutiveMissed >= missedBeatsBeforeDead && !_declaredDead) {
      _declaredDead = true;
      onDeclaredDead?.call();
    }
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(beat()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// The producible half of the row's metric: the median measured round trip.
  /// A real number over real beats -- against an in-memory transport in the
  /// gate, and against a server in production, with the same code either way.
  Duration? get medianRtt {
    final List<Duration> rtts = roundTrips;
    if (rtts.isEmpty) {
      return null;
    }
    final List<int> ms = rtts.map((Duration d) => d.inMilliseconds).toList()
      ..sort();
    return Duration(milliseconds: ms[ms.length ~/ 2]);
  }

  /// The share of beats that were answered at all. The connection-viability
  /// figure the row's title actually asks about.
  double get answerRate =>
      _beats.isEmpty ? 1 : roundTrips.length / _beats.length;

  static const String bandInversionNote =
      'The row writes Floor < 2s, Optimal < 500ms, Ceiling < 100ms. Lower is '
      'better, so the CEILING is the best value here and the FLOOR the worst '
      '-- the opposite of the sheet usual convention, and the same inversion '
      'Step 102 met. Both figures are used in the direction they plainly mean.';
}
