/// AISS: GEN-02676-A01 -- "Add a badge counter to the bottom navigation icon
/// that displays the current unread notification count."
/// Metric: Implementation Completeness Rate -- Floor "90% of defined scope
/// completed", Optimal "100% of scope complete with peer validation".
///
/// A count badge, not a status badge. Step 28's [HabotStatusBadge] says what
/// state something is in; this says how many of something are waiting. They
/// are deliberately different components with different shapes -- a numeric
/// badge that could also read "Complete" would be two ideas in one control.
///
/// Three rules the widget enforces rather than documents:
///   * zero shows nothing at all,
///   * counts past the cap read as "99+" rather than overflowing the dot,
///   * the count is announced ("3 unread") rather than left as a decoration a
///     screen reader skips.
library;

import 'package:flutter/material.dart';

import '../tokens/surface_tokens.dart';

/// The unread-count badge that sits on a navigation icon.
class HabotNavBadge extends StatelessWidget {
  const HabotNavBadge({
    required this.count,
    required this.child,
    this.label,
    super.key,
  }) : assert(count >= 0, 'An unread count cannot be negative');

  /// Unread items. Zero renders [child] unchanged.
  final int count;

  /// The icon the badge decorates.
  final Widget child;

  /// The destination this badge belongs to, used in the announcement.
  final String? label;

  /// Past this the badge shows "99+". MD3's own cap, and the point at which
  /// the exact number stops being actionable anyway.
  static const int maxCount = 99;

  static const Key badgeKey = Key('habot.nav.badge');

  bool get isVisible => count > 0;

  /// What the badge reads. Public so the gate can assert the text without
  /// digging through the render tree.
  String get displayText => count > maxCount ? '$maxCount+' : '$count';

  /// What a screen reader announces. The number has to be in the semantics
  /// tree, not only in the pixels.
  String get semanticsLabel =>
      label == null ? '$count unread' : '$label, $count unread';

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return child;
    }
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      container: true,
      child: Badge(
        key: badgeKey,
        label: Text(displayText),
        backgroundColor: scheme.error,
        textColor: scheme.onError,
        largeSize: HabotFeedback.badgeLabelledHeight,
        smallSize: HabotFeedback.badgeDotSize,
        child: child,
      ),
    );
  }
}

/// The unread counts the navigation shows, in one place.
///
/// A count that lives on the destination list is a count somebody has to
/// remember to update; a count that lives here is one the navigation reads.
class HabotUnreadCounts extends ChangeNotifier {
  HabotUnreadCounts([Map<String, int>? initial])
    : _counts = <String, int>{...?initial};

  final Map<String, int> _counts;

  int countFor(String route) => _counts[route] ?? 0;

  /// Total across every destination. What a launcher icon would show.
  int get total => _counts.values.fold(0, (int a, int b) => a + b);

  void set(String route, int count) {
    assert(count >= 0, 'An unread count cannot be negative');
    _counts[route] = count;
    notifyListeners();
  }

  /// Marks a destination read. The one operation the navigation itself
  /// performs -- opening a destination is what clears its badge.
  void clear(String route) {
    if ((_counts[route] ?? 0) != 0) {
      _counts[route] = 0;
      notifyListeners();
    }
  }
}
