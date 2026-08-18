/// AISS: GEN-00699-A01 -- "Configure Mobile Push Notifications & Real-Time
/// Alert Triggers."
/// Setup Step Description: "Write client-side push notification receiver
/// handler onMessageReceived."
/// Metric: Client Handler Speed -- Floor <= 10ms, Optimal <= 2ms,
///         Ceiling 20ms.
///
/// DUPLICATE SETUP STEP, RECORDED: S.No 8936 (this step) and S.No 13985
/// (Step 66) carry the byte-identical Setup Step "Configure Mobile Push
/// Notifications & Real-Time Alert Triggers", with different Setup Step
/// Descriptions, different metrics and different estimates (4 Hours vs 12
/// Hours). Two atomic steps sharing a Setup Step verbatim are indistinguishable
/// in any report keyed on that column. They are told apart here by their
/// descriptions -- Step 66 is the FCM/dispatch engine, this is the client
/// receiver -- and the duplication is recorded rather than silently resolved.
///
/// THE METRIC IS THE DESIGN. A <=2ms optimal for `onMessageReceived` is not a
/// performance target bolted on afterwards; it dictates what the handler may
/// do. Two milliseconds is not enough to hit storage, render a widget or await
/// anything. So the handler PARSES AND ENQUEUES, and nothing else: everything
/// slower runs on the drain, off the delivery path. That is measurable, and G4
/// measures it over a thousand messages.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../tokens/motion_tokens.dart';
import 'notification_payload.dart';

/// Where a message arrived from. The same handler serves all three, which is
/// what makes "one place a message enters the app" true rather than aspirational.
enum HabotMessageSource {
  /// Delivered while the app was in the foreground.
  foreground,

  /// Delivered to the system tray and later tapped.
  tapped,

  /// Raised locally by the app itself.
  local,
}

/// One message as it arrived, before anything has been done with it.
@immutable
class HabotIncomingMessage {
  const HabotIncomingMessage({
    required this.source,
    required this.receivedAt,
    required this.raw,
  });

  final HabotMessageSource source;
  final DateTime receivedAt;

  /// The wire form, exactly as handed over.
  final Map<String, Object?> raw;
}

/// What the handler made of a message.
@immutable
class HabotParsedMessage {
  const HabotParsedMessage({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.route,
    required this.source,
    required this.receivedAt,
    required this.data,
  });

  final String id;
  final HabotNotificationKind kind;
  final String title;
  final String body;
  final String route;
  final HabotMessageSource source;
  final DateTime receivedAt;
  final Map<String, String> data;
}

/// The receiver.
///
/// Deliberately not a ChangeNotifier and deliberately synchronous: notifying
/// listeners inside the delivery path would put an unbounded amount of widget
/// rebuilding inside a 2ms budget.
class HabotMessageReceiver {
  HabotMessageReceiver({int queueLimit = defaultQueueLimit})
    : _queueLimit = queueLimit;

  /// A queue that grows without limit is a memory leak wearing a buffer's
  /// clothes. Past this, the OLDEST informational message is dropped and
  /// counted -- never a dispatch, approval or critical one.
  static const int defaultQueueLimit = 128;

  final int _queueLimit;
  final List<HabotParsedMessage> _queue = <HabotParsedMessage>[];
  final Set<String> _seenIds = <String>{};
  final List<Duration> _handlerTimings = <Duration>[];
  int _malformed = 0;
  int _duplicates = 0;
  int _dropped = 0;

  List<HabotParsedMessage> get queued =>
      List<HabotParsedMessage>.unmodifiable(_queue);

  int get queueDepth => _queue.length;
  int get malformedCount => _malformed;
  int get duplicateCount => _duplicates;
  int get droppedCount => _dropped;

  /// Every measured handler duration, for the metric.
  List<Duration> get handlerTimings => List<Duration>.unmodifiable(_handlerTimings);

  /// THE HANDLER. Parse, deduplicate, enqueue. Nothing else.
  ///
  /// Returns the parsed message, or null when the message was malformed or a
  /// duplicate -- neither of which throws, because an exception on the
  /// delivery path takes out the next message too.
  HabotParsedMessage? onMessageReceived(HabotIncomingMessage message) {
    final Stopwatch clock = Stopwatch()..start();
    try {
      final HabotParsedMessage? parsed = _parse(message);
      if (parsed == null) {
        _malformed++;
        return null;
      }
      if (!_seenIds.add(parsed.id)) {
        // The same notification can arrive twice: once in the foreground and
        // once as a tap. Showing it twice is the bug this prevents.
        _duplicates++;
        return null;
      }
      _enqueue(parsed);
      return parsed;
    } finally {
      clock.stop();
      _handlerTimings.add(clock.elapsed);
    }
  }

  HabotParsedMessage? _parse(HabotIncomingMessage message) {
    final Object? dataField = message.raw['data'];
    final Object? notificationField = message.raw['notification'];
    if (dataField is! Map || notificationField is! Map) {
      return null;
    }
    final Map<String, String> data = <String, String>{
      for (final MapEntry<Object?, Object?> e in dataField.entries)
        if (e.key is String && e.value is String)
          e.key! as String: e.value! as String,
    };
    final String? id = data['id'];
    final String? route = data['route'];
    final String? kindName = data['kind'];
    final Object? title = notificationField['title'];
    final Object? body = notificationField['body'];
    if (id == null ||
        id.isEmpty ||
        route == null ||
        route.isEmpty ||
        title is! String ||
        body is! String) {
      return null;
    }
    return HabotParsedMessage(
      id: id,
      kind: _kindOf(kindName),
      title: title,
      body: body,
      route: route,
      source: message.source,
      receivedAt: message.receivedAt,
      data: Map<String, String>.unmodifiable(data),
    );
  }

  /// An unknown or absent kind becomes informational rather than throwing. A
  /// sender that ships a new kind before the client knows it should degrade to
  /// the quietest surface, not crash the receiver.
  static HabotNotificationKind _kindOf(String? name) {
    for (final HabotNotificationKind kind in HabotNotificationKind.values) {
      if (kind.name == name) {
        return kind;
      }
    }
    return HabotNotificationKind.informational;
  }

  void _enqueue(HabotParsedMessage parsed) {
    if (_queue.length >= _queueLimit) {
      final int victim = _queue.indexWhere(
        (HabotParsedMessage m) =>
            m.kind == HabotNotificationKind.informational,
      );
      if (victim == -1) {
        // Everything queued is urgent. Refuse the new one rather than evict an
        // approval request to make room for another approval request.
        _dropped++;
        return;
      }
      _queue.removeAt(victim);
      _dropped++;
    }
    _queue.add(parsed);
  }

  /// Everything queued, cleared. Called off the delivery path -- this is where
  /// the slow work belongs.
  List<HabotParsedMessage> drain() {
    final List<HabotParsedMessage> out =
        List<HabotParsedMessage>.from(_queue);
    _queue.clear();
    return out;
  }

  /// Convenience for a transport that hands over JSON text.
  HabotParsedMessage? onRawMessage(
    String json, {
    HabotMessageSource source = HabotMessageSource.foreground,
    DateTime? at,
  }) {
    Map<String, Object?> decoded;
    try {
      final Object? value = jsonDecode(json);
      if (value is! Map<String, Object?>) {
        _malformed++;
        return null;
      }
      decoded = value;
    } on FormatException {
      _malformed++;
      return null;
    }
    return onMessageReceived(
      HabotIncomingMessage(
        source: source,
        receivedAt: at ?? DateTime.now(),
        raw: decoded,
      ),
    );
  }

  // --- the metric ---------------------------------------------------------

  /// Floor: "<= 10 ms".
  static const Duration handlerFloor = HabotMotion.messageHandlerFloor;

  /// Optimal: "<= 2 ms".
  static const Duration handlerOptimal = HabotMotion.messageHandlerOptimal;

  /// Ceiling: "20 ms".
  static const Duration handlerCeiling = HabotMotion.messageHandlerCeiling;

  Duration get worstHandlerTime => _handlerTimings.isEmpty
      ? Duration.zero
      : _handlerTimings.reduce((Duration a, Duration b) => a > b ? a : b);

  Duration get medianHandlerTime {
    if (_handlerTimings.isEmpty) {
      return Duration.zero;
    }
    final List<Duration> sorted = List<Duration>.from(_handlerTimings)
      ..sort();
    return sorted[sorted.length ~/ 2];
  }

  /// The share of handler runs inside the optimal band, as a percentage. The
  /// number worth reporting: one slow parse in a thousand is a different
  /// problem from every parse being slow.
  double get optimalPassRate => _handlerTimings.isEmpty
      ? 100
      : (_handlerTimings.where((Duration d) => d <= handlerOptimal).length /
                _handlerTimings.length) *
            100;

  void resetTimings() {
    _handlerTimings.clear();
  }

  /// Clears the dedup memory. Exposed so a long-lived session can bound it;
  /// the queue itself is bounded by [defaultQueueLimit].
  void forgetSeen() {
    _seenIds.clear();
  }
}
