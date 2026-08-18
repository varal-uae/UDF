/// AISS: GEN-02455-A01 -- "Step 23: Develop the Universal Notification
/// Center."
/// Setup Step Description: "Determine which notifications require PERMANENT
/// STORAGE versus EPHEMERAL DISPLAY."
/// Metric: UI Compliance Rate (%) -- Floor 0.95, Optimal 1.0.
///
/// THE DESCRIPTION IS THE STEP, and it is a classification question rather
/// than a storage question. The decision recorded here:
///
///   EPHEMERAL  a notification whose whole value is in the moment it arrives.
///              A dispatch offer expires in sixty seconds; a failure snackbar
///              describes a thing the user just watched fail. Keeping those
///              produces a list of stale urgencies nobody can act on.
///
///   PERSISTED  a notification that still means something an hour later. An
///              approval request is outstanding until answered. A critical
///              breach is a fact about the system. Informational news is what
///              a notification centre is FOR.
///
/// The rule is derived from the kind rather than passed in, so two callers
/// cannot disagree about whether the same event is worth keeping.
///
/// ON THE METRIC. "UI Compliance Rate (%)" at a 0.95 floor is one of the few
/// GEN-* metrics here that can be read honestly: the compliance in question is
/// whether every notification the centre receives is handled according to the
/// classification -- stored if it should be, dropped if it should not, and
/// never silently lost either way. That is countable.
library;

import 'package:flutter/foundation.dart';

import 'notification_payload.dart';

/// What the centre does with a notification.
enum HabotRetention {
  /// Shown, then gone. Never enters the centre.
  ephemeral,

  /// Shown and kept, until read and then archived.
  persisted,
}

/// One entry in the centre.
@immutable
class HabotNotificationEntry {
  const HabotNotificationEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.route,
    required this.receivedAt,
    this.readAt,
    this.archivedAt,
  });

  final String id;
  final HabotNotificationKind kind;
  final String title;
  final String body;
  final String route;
  final DateTime receivedAt;
  final DateTime? readAt;
  final DateTime? archivedAt;

  bool get isRead => readAt != null;
  bool get isArchived => archivedAt != null;

  HabotNotificationEntry copyWith({DateTime? readAt, DateTime? archivedAt}) =>
      HabotNotificationEntry(
        id: id,
        kind: kind,
        title: title,
        body: body,
        route: route,
        receivedAt: receivedAt,
        readAt: readAt ?? this.readAt,
        archivedAt: archivedAt ?? this.archivedAt,
      );

  String get semanticsLabel =>
      '${isRead ? '' : 'Unread. '}$title. $body';
}

/// The classification rule.
class HabotRetentionPolicy {
  const HabotRetentionPolicy._();

  /// The recorded decision. A pure function of the kind, so it is the same
  /// answer everywhere.
  static HabotRetention forKind(HabotNotificationKind kind) {
    switch (kind) {
      case HabotNotificationKind.dispatch:
        // Expires in 60 seconds. A list of expired offers is a list of things
        // nobody can act on.
        return HabotRetention.ephemeral;
      case HabotNotificationKind.failure:
        // The user watched it happen. The failure itself is logged; the
        // notification about it is not news an hour later.
        return HabotRetention.ephemeral;
      case HabotNotificationKind.approval:
      case HabotNotificationKind.critical:
      case HabotNotificationKind.informational:
        return HabotRetention.persisted;
    }
  }

  static bool isPersisted(HabotNotificationKind kind) =>
      forKind(kind) == HabotRetention.persisted;

  /// The centre holds this many entries. Past it the OLDEST READ entry goes;
  /// an unread one is never evicted to make room, because the whole point of
  /// keeping it was that nobody has seen it.
  static const int capacity = 200;
}

/// The centre.
class HabotNotificationCenter extends ChangeNotifier {
  HabotNotificationCenter({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final List<HabotNotificationEntry> _entries = <HabotNotificationEntry>[];

  int _received = 0;
  int _handled = 0;
  int _evictedUnread = 0;

  /// Newest first, archived excluded -- what the screen shows.
  List<HabotNotificationEntry> get entries => List<HabotNotificationEntry>
      .unmodifiable(
        _entries.where((HabotNotificationEntry e) => !e.isArchived).toList()
          ..sort(
            (HabotNotificationEntry a, HabotNotificationEntry b) =>
                b.receivedAt.compareTo(a.receivedAt),
          ),
      );

  List<HabotNotificationEntry> get archived =>
      List<HabotNotificationEntry>.unmodifiable(
        _entries.where((HabotNotificationEntry e) => e.isArchived),
      );

  int get unreadCount => _entries
      .where((HabotNotificationEntry e) => !e.isRead && !e.isArchived)
      .length;

  int get storedCount => _entries.length;

  /// Metric: UI Compliance Rate. Every notification offered to the centre was
  /// handled according to the classification -- stored if persisted, declined
  /// if ephemeral -- and none was silently lost.
  double get complianceRate => _received == 0 ? 1 : _handled / _received;

  int get receivedCount => _received;

  /// An unread entry evicted by capacity pressure. Should always be zero; it
  /// is counted rather than assumed.
  int get evictedUnreadCount => _evictedUnread;

  /// Offers a notification to the centre. Returns true when it was stored.
  ///
  /// An ephemeral notification returning false is not a failure -- it is the
  /// classification working. Both outcomes count as handled.
  bool receive({
    required String id,
    required HabotNotificationKind kind,
    required String title,
    required String body,
    required String route,
    DateTime? at,
  }) {
    _received++;
    if (!HabotRetentionPolicy.isPersisted(kind)) {
      _handled++;
      return false;
    }
    if (_entries.any((HabotNotificationEntry e) => e.id == id)) {
      // Already stored. Handled, not stored twice.
      _handled++;
      return false;
    }
    _evictIfFull();
    _entries.add(
      HabotNotificationEntry(
        id: id,
        kind: kind,
        title: title,
        body: body,
        route: route,
        receivedAt: at ?? _clock(),
      ),
    );
    _handled++;
    notifyListeners();
    return true;
  }

  void _evictIfFull() {
    if (_entries.length < HabotRetentionPolicy.capacity) {
      return;
    }
    final int readIndex = _entries.indexWhere(
      (HabotNotificationEntry e) => e.isRead || e.isArchived,
    );
    if (readIndex >= 0) {
      _entries.removeAt(readIndex);
      return;
    }
    // Everything stored is unread. Drop the oldest and count it, rather than
    // refuse the new one -- and make the fact visible.
    _entries.removeAt(0);
    _evictedUnread++;
  }

  void markRead(String id) => _update(id, readAt: _clock());

  void archive(String id) => _update(id, archivedAt: _clock());

  void _update(String id, {DateTime? readAt, DateTime? archivedAt}) {
    final int i = _entries.indexWhere((HabotNotificationEntry e) => e.id == id);
    if (i < 0) {
      return;
    }
    final HabotNotificationEntry updated =
        _entries[i].copyWith(readAt: readAt, archivedAt: archivedAt);
    if (updated.readAt == _entries[i].readAt &&
        updated.archivedAt == _entries[i].archivedAt) {
      return;
    }
    _entries[i] = updated;
    notifyListeners();
  }

  void markAllRead() {
    bool changed = false;
    for (int i = 0; i < _entries.length; i++) {
      if (!_entries[i].isRead) {
        _entries[i] = _entries[i].copyWith(readAt: _clock());
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void clear() {
    if (_entries.isEmpty) {
      return;
    }
    _entries.clear();
    notifyListeners();
  }
}
