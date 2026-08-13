/// AISS: GEN-02082-A01 -- "Build a deep link routing engine leveraging
/// Navigation component routing."
///
/// METRIC MISMATCH, RECORDED: this row's Metric Name is "Push Notification
/// Click-Through Rate (%)", which measures whether people tap notifications --
/// a marketing outcome, not a property of a router. The gates defend the Setup
/// Step; the measurement states the mismatch rather than pretending a routing
/// engine can move a click-through rate on its own.
///
/// Split from Step 42 deliberately, because parsing a URL and restoring a
/// context are different failures with different fixes. This half turns a
/// string into a destination; the other half decides what the user sees when
/// they get there.
///
/// The parser is pure. It takes a string and returns a match -- no Navigator,
/// no BuildContext, no plugin -- which is what lets every routing rule be
/// tested exhaustively instead of through a widget.
library;

import 'package:flutter/widgets.dart';

import 'deep_link_context_manager.dart';

/// One route the app can show.
@immutable
class HabotRoute {
  const HabotRoute({
    required this.path,
    required this.title,
    this.requiresId = false,
  });

  /// A path pattern. A segment beginning with `:` is a parameter, so
  /// `/batches/:id` matches `/batches/42` and yields `{'id': '42'}`.
  final String path;

  final String title;

  /// True when the route is meaningless without an id -- `/batches/:id` is;
  /// `/batches` is not.
  final bool requiresId;

  List<String> get segments =>
      path.split('/').where((String s) => s.isNotEmpty).toList();
}

/// What the router made of a link.
@immutable
class HabotRouteMatch {
  const HabotRouteMatch({
    required this.route,
    required this.params,
    required this.isFallback,
  });

  final HabotRoute route;
  final Map<String, String> params;

  /// True when nothing matched and the router fell back. A fallback is still a
  /// real destination: a link that resolves to nothing at all is a blank
  /// screen, which is the worst possible answer to a tapped notification.
  final bool isFallback;
}

/// The routing engine.
class HabotRouter {
  HabotRouter({
    required this.routes,
    required this.fallback,
    DeepLinkContextManager? contextManager,
  }) : contextManager = contextManager ?? DeepLinkContextManager();

  final List<HabotRoute> routes;

  /// Where an unrecognised link lands.
  final HabotRoute fallback;

  /// Step 42, injected. The router restores context; it does not implement it.
  final DeepLinkContextManager contextManager;

  /// Parses a link into a match. Never throws and never returns null: an
  /// unparseable link is a fallback, not an exception thrown at a user who
  /// tapped a notification.
  HabotRouteMatch match(String link) {
    final Uri? uri = Uri.tryParse(link);
    if (uri == null) {
      return _fallbackMatch();
    }
    final List<String> incoming = uri.pathSegments
        .where((String s) => s.isNotEmpty)
        .toList();

    for (final HabotRoute route in routes) {
      final Map<String, String>? params = _tryMatch(route, incoming);
      if (params == null) {
        continue;
      }
      final Map<String, String> merged = <String, String>{
        ...params,
        ...uri.queryParameters,
      };
      if (route.requiresId && (merged['id'] ?? '').isEmpty) {
        continue;
      }
      return HabotRouteMatch(route: route, params: merged, isFallback: false);
    }
    return _fallbackMatch();
  }

  /// The full journey: parse the link, then restore whatever this user had
  /// open on that route last time.
  HabotDeepLinkContext resolve(String link) {
    final HabotRouteMatch matched = match(link);
    return contextManager.resolve(
      matched.route.path,
      linkParams: matched.params,
    );
  }

  /// Records where the user is, so the next link to this route can restore it.
  void capture(HabotDeepLinkContext context) => contextManager.capture(context);

  HabotRouteMatch _fallbackMatch() => HabotRouteMatch(
    route: fallback,
    params: const <String, String>{},
    isFallback: true,
  );

  static Map<String, String>? _tryMatch(
    HabotRoute route,
    List<String> incoming,
  ) {
    final List<String> pattern = route.segments;
    if (pattern.length != incoming.length) {
      return null;
    }
    final Map<String, String> params = <String, String>{};
    for (int i = 0; i < pattern.length; i++) {
      final String expected = pattern[i];
      if (expected.startsWith(':')) {
        if (incoming[i].isEmpty) {
          return null;
        }
        params[expected.substring(1)] = incoming[i];
        continue;
      }
      if (expected != incoming[i]) {
        return null;
      }
    }
    return params;
  }

  /// Every route declares a distinct path. Two routes with the same pattern
  /// means one of them is unreachable, and which one depends on list order --
  /// exactly the kind of bug that only appears in production.
  bool get pathsAreUnique {
    final Set<String> seen = <String>{};
    for (final HabotRoute route in <HabotRoute>[...routes, fallback]) {
      if (!seen.add(route.path)) {
        return false;
      }
    }
    return true;
  }
}
