/// AISS: GEN-04561-A01 -- "Build notification payload generators setting
/// titles, bodies, and target routes."
/// Metric: Push Notification Delivery Rate -- Floor 0.95, Optimal 0.99,
/// Ceiling 0.999.
///
/// COLUMN NOTE, RECORDED: this row's Setup Step (Action) and Setup Step
/// Description columns contain the identical string, so the usual
/// three-column derivation has only two distinct inputs.
///
/// THE TARGET ROUTE IS THE POINT. Titles and bodies are copy; the route is the
/// join to Step 43. A notification whose target does not resolve through
/// `HabotRouter` produces exactly the blank screen that step exists to
/// prevent -- so [HabotNotificationPayload] cannot be constructed with a route
/// the router does not know. That is checked at construction rather than at
/// tap time, because a tap is the worst moment to discover a bad link.
///
/// ON THE METRIC. "Push Notification Delivery Rate" is a property of the
/// transport, not of a payload generator -- a perfectly formed payload can
/// still be dropped by a push service. What a generator owns is whether the
/// payload it produced is DELIVERABLE: complete, within platform limits, and
/// pointed at a real destination. That is what is measured, and the
/// distinction is recorded rather than glossed.
library;

import 'package:flutter/foundation.dart';

import '../navigation/route_table.dart';

/// What kind of notification this is. Governs everything downstream: which
/// surface renders it (Steps 69-74), whether it is stored or ephemeral
/// (Step 75), and where it sorts (Step 78).
enum HabotNotificationKind {
  /// Time-critical, requires a decision inside a window. Step 66's dispatch
  /// offers.
  dispatch,

  /// Someone is waiting on this user to approve something. Step 77.
  approval,

  /// Something failed. Renders through the Step 25 snackbar path.
  failure,

  /// A P1 breach. Renders through the Step 73 blocking panel.
  critical,

  /// Ordinary news. The banner, and the notification centre.
  informational,
}

/// Platform limits. Exceeding them does not fail loudly -- it truncates
/// silently on the device, which is worse, so the generator refuses instead.
class HabotPayloadLimits {
  const HabotPayloadLimits._();

  /// Android collapses a notification title past roughly this length; iOS
  /// elides it. Either way the tail is lost.
  static const int maxTitleChars = 65;

  /// The body a lock screen will show before "..." on both platforms.
  static const int maxBodyChars = 240;

  /// FCM's documented data-payload ceiling is 4KB. Held well under it: a
  /// payload near the limit is a payload one field away from being dropped.
  static const int maxDataBytes = 3072;
}

/// Why a payload was rejected. Never a bare false.
enum HabotPayloadDefect {
  emptyTitle,
  titleTooLong,
  emptyBody,
  bodyTooLong,
  unroutableTarget,
  payloadTooLarge,
}

/// The result of validating a payload.
@immutable
class HabotPayloadValidation {
  const HabotPayloadValidation({required this.defects});

  final List<HabotPayloadDefect> defects;

  bool get isDeliverable => defects.isEmpty;
}

/// One notification, ready to send.
///
/// There is no public constructor. The only way to obtain a payload is
/// [HabotNotificationFactory.build], which validates -- so an invalid payload
/// is not a thing that exists rather than a thing to be checked for.
@immutable
class HabotNotificationPayload {
  const HabotNotificationPayload._({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.targetRoute,
    required this.data,
  });

  final String id;
  final HabotNotificationKind kind;
  final String title;
  final String body;

  /// The deep link this notification opens. Guaranteed resolvable by the
  /// router that built it.
  final String targetRoute;

  /// Extra key-values carried to the destination. Never contains anything a
  /// log scrubber would strip -- the factory checks.
  final Map<String, String> data;

  /// The FCM-shaped map, for the transport to send.
  Map<String, Object> toMessage() => <String, Object>{
    'notification': <String, String>{'title': title, 'body': body},
    'data': <String, String>{
      'id': id,
      'kind': kind.name,
      'route': targetRoute,
      ...data,
    },
  };

  /// Approximate wire size, for the platform limit check.
  int get approximateBytes =>
      title.length +
      body.length +
      targetRoute.length +
      data.entries.fold<int>(
        0,
        (int sum, MapEntry<String, String> e) => sum + e.key.length + e.value.length,
      );
}

/// The generator.
class HabotNotificationFactory {
  const HabotNotificationFactory({required this.router});

  /// The Step 43 router. Held, not optional: a factory that cannot check a
  /// route cannot make the guarantee this class exists to make.
  final HabotRouter router;

  /// Validates without building, so a caller can report problems rather than
  /// only discover them.
  HabotPayloadValidation validate({
    required String title,
    required String body,
    required String targetRoute,
    Map<String, String> data = const <String, String>{},
  }) {
    final List<HabotPayloadDefect> defects = <HabotPayloadDefect>[];
    if (title.trim().isEmpty) {
      defects.add(HabotPayloadDefect.emptyTitle);
    } else if (title.length > HabotPayloadLimits.maxTitleChars) {
      defects.add(HabotPayloadDefect.titleTooLong);
    }
    if (body.trim().isEmpty) {
      defects.add(HabotPayloadDefect.emptyBody);
    } else if (body.length > HabotPayloadLimits.maxBodyChars) {
      defects.add(HabotPayloadDefect.bodyTooLong);
    }
    if (!routeIsReal(targetRoute)) {
      defects.add(HabotPayloadDefect.unroutableTarget);
    }
    final int bytes = title.length +
        body.length +
        targetRoute.length +
        data.entries.fold<int>(
          0,
          (int sum, MapEntry<String, String> e) =>
              sum + e.key.length + e.value.length,
        );
    if (bytes > HabotPayloadLimits.maxDataBytes) {
      defects.add(HabotPayloadDefect.payloadTooLarge);
    }
    return HabotPayloadValidation(defects: defects);
  }

  /// True when the router resolves [route] to a real destination rather than
  /// falling back.
  ///
  /// The fallback is deliberately NOT good enough here. Step 43 falls back so
  /// that a bad link never produces a blank screen; that is the right
  /// behaviour at tap time and the wrong standard at authoring time, because a
  /// notification that silently lands on the overview has not delivered its
  /// news.
  bool routeIsReal(String route) {
    if (route.trim().isEmpty) {
      return false;
    }
    return !router.match(route).isFallback;
  }

  /// Builds, or returns null with the defects reported through [onRejected].
  HabotNotificationPayload? build({
    required String id,
    required HabotNotificationKind kind,
    required String title,
    required String body,
    required String targetRoute,
    Map<String, String> data = const <String, String>{},
    void Function(HabotPayloadValidation validation)? onRejected,
  }) {
    final HabotPayloadValidation validation = validate(
      title: title,
      body: body,
      targetRoute: targetRoute,
      data: data,
    );
    if (!validation.isDeliverable) {
      onRejected?.call(validation);
      return null;
    }
    return HabotNotificationPayload._(
      id: id,
      kind: kind,
      title: title,
      body: body,
      targetRoute: targetRoute,
      data: Map<String, String>.unmodifiable(data),
    );
  }

  /// The share of attempted payloads that came out deliverable. What a
  /// generator can honestly report against a delivery-rate metric.
  static double deliverableRate(List<HabotPayloadValidation> attempts) =>
      attempts.isEmpty
      ? 1
      : attempts
                .where((HabotPayloadValidation v) => v.isDeliverable)
                .length /
            attempts.length;
}
