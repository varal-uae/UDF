/// AISS: GEN-00999-A01 -- "Deploy Automated Mobile Deep Link Routing &
/// Context Restoration Engine."
/// Setup Step Description / Expected Output: "Create
/// deep_link_context_manager.dart" -- this file, at the name the sheet gives.
/// Metric: Syntax Validity -- Floor = Optimal = 100%.
///
/// Restoring a route is easy. Restoring a *context* is the step: which record
/// was open, how far down the operator had scrolled, which pane the split was
/// showing, what was half-typed. A deep link that lands a user on the right
/// screen at the top of an empty form has technically worked and practically
/// wasted their place.
///
/// Everything here round-trips through JSON, because a context that cannot be
/// written to disk cannot survive the process being killed -- which is the
/// only case that matters on mobile.
///
/// PRIVACY: [HabotDeepLinkContext.draft] holds form values, so it is the one
/// structure in this design system that can carry user content. It is capped,
/// never logged, and scrubbed on the way into any diagnostic. The hesitation
/// tracker from Step 34 deliberately holds none of this.
library;

import 'dart:convert';

import '../resilience/log_scrubber.dart';

/// Where a user was, in enough detail to put them back.
class HabotDeepLinkContext {
  const HabotDeepLinkContext({
    required this.route,
    this.params = const <String, String>{},
    this.scrollOffset = 0,
    this.selectedId,
    this.draft = const <String, String>{},
    this.paneIndex = 0,
  });

  /// The route path, without query.
  final String route;

  /// Path and query parameters, already parsed.
  final Map<String, String> params;

  /// Where the list was scrolled to.
  final double scrollOffset;

  /// The record that was open, if any.
  final String? selectedId;

  /// Half-entered form values, keyed by field name.
  final Map<String, String> draft;

  /// Which pane or tab was showing, for the Step 36 mirror.
  final int paneIndex;

  /// A context is only worth restoring if it says more than the route does.
  bool get isMeaningful =>
      scrollOffset > 0 ||
      selectedId != null ||
      draft.isNotEmpty ||
      paneIndex != 0 ||
      params.isNotEmpty;

  Map<String, Object?> toJson() => <String, Object?>{
    'route': route,
    'params': params,
    'scroll_offset': scrollOffset,
    if (selectedId != null) 'selected_id': selectedId,
    'draft': draft,
    'pane_index': paneIndex,
  };

  static HabotDeepLinkContext fromJson(Map<String, Object?> json) =>
      HabotDeepLinkContext(
        route: json['route']! as String,
        params: Map<String, String>.from(
          (json['params'] as Map<Object?, Object?>? ?? <Object?, Object?>{})
              .map(
                (Object? k, Object? v) => MapEntry<String, String>('$k', '$v'),
              ),
        ),
        scrollOffset: (json['scroll_offset'] as num? ?? 0).toDouble(),
        selectedId: json['selected_id'] as String?,
        draft: Map<String, String>.from(
          (json['draft'] as Map<Object?, Object?>? ?? <Object?, Object?>{}).map(
            (Object? k, Object? v) => MapEntry<String, String>('$k', '$v'),
          ),
        ),
        paneIndex: (json['pane_index'] as num? ?? 0).toInt(),
      );

  /// Safe to put in a log: route and shape only, never values.
  Map<String, Object?> toDiagnostic() => <String, Object?>{
    'route': HabotLogScrubber.scrub(route),
    'param_count': params.length,
    'has_selection': selectedId != null,
    'draft_field_count': draft.length,
    'scroll_offset': scrollOffset,
    'pane_index': paneIndex,
  };

  @override
  bool operator ==(Object other) =>
      other is HabotDeepLinkContext &&
      other.route == route &&
      other.scrollOffset == scrollOffset &&
      other.selectedId == selectedId &&
      other.paneIndex == paneIndex &&
      _mapEquals(other.params, params) &&
      _mapEquals(other.draft, draft);

  @override
  int get hashCode => Object.hash(route, scrollOffset, selectedId, paneIndex);

  static bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final MapEntry<String, String> entry in a.entries) {
      if (b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}

/// Captures and restores contexts.
///
/// Storage is injectable so the gates can drive it without a plugin: the
/// production implementation writes the same JSON to whatever the platform
/// offers, and the contract this class is gated on is the round trip, not the
/// medium.
class DeepLinkContextManager {
  DeepLinkContextManager({Map<String, String>? storage})
    : _storage = storage ?? <String, String>{};

  /// Route -> serialised context.
  final Map<String, String> _storage;

  /// How many routes keep a remembered context. Beyond this the oldest is
  /// dropped: an unbounded restoration cache is a memory leak with good
  /// intentions.
  static const int maxRememberedRoutes = 16;

  /// The order routes were last captured, oldest first.
  final List<String> _recency = <String>[];

  int get rememberedCount => _storage.length;

  /// Records where the user is. Called on leaving a route.
  void capture(HabotDeepLinkContext context) {
    _storage[context.route] = jsonEncode(context.toJson());
    _recency
      ..remove(context.route)
      ..add(context.route);
    while (_recency.length > maxRememberedRoutes) {
      _storage.remove(_recency.removeAt(0));
    }
  }

  /// The remembered context for [route], or null if there is none.
  HabotDeepLinkContext? restore(String route) {
    final String? raw = _storage[route];
    if (raw == null) {
      return null;
    }
    return HabotDeepLinkContext.fromJson(
      jsonDecode(raw) as Map<String, Object?>,
    );
  }

  /// Builds the context a link implies, merged with anything remembered for
  /// the same route.
  ///
  /// The incoming link wins on any parameter it names -- a user who followed a
  /// link to record 42 wants record 42, not the record they were on last time
  /// -- while everything the link is silent about is restored.
  HabotDeepLinkContext resolve(
    String route, {
    Map<String, String> linkParams = const <String, String>{},
  }) {
    final HabotDeepLinkContext? remembered = restore(route);
    if (remembered == null) {
      return HabotDeepLinkContext(route: route, params: linkParams);
    }
    if (linkParams.isEmpty) {
      return remembered;
    }
    return HabotDeepLinkContext(
      route: route,
      params: <String, String>{...remembered.params, ...linkParams},
      scrollOffset: remembered.scrollOffset,
      selectedId: linkParams['id'] ?? remembered.selectedId,
      draft: remembered.draft,
      paneIndex: remembered.paneIndex,
    );
  }

  void forget(String route) {
    _storage.remove(route);
    _recency.remove(route);
  }

  void clear() {
    _storage.clear();
    _recency.clear();
  }
}
