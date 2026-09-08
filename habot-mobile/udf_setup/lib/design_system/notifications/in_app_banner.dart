/// AISS: GEN-04374-A01 -- "Build an atomic InAppBanner notification bar
/// component."
/// Metric: Push Notification Delivery Rate -- Floor 0.95, Optimal 0.99,
///         Ceiling 0.999.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC NOTE, RECORDED: "Push Notification Delivery Rate" is a property of
/// the push service, not of a banner widget -- a banner cannot influence
/// whether FCM delivered anything. What this component owns is the last leg:
/// once a message reaches the app, does it reach the SCREEN? That is
/// measurable, and it is what is reported.
///
/// WHERE THIS SITS. Step 48 already put a banner slot at the top of the shell
/// body for the offline banner, and Step 62 put the dashboard summary strip
/// under it. This is the third thing competing for that space, so the rule is
/// stated once here rather than discovered later: connectivity outranks
/// notifications. A user who is offline needs to know that before they read
/// news they cannot act on.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../feedback/status_badge.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'notification_payload.dart';

/// Banner policy: how long a kind stays, and how loudly.
class HabotBannerPolicy {
  const HabotBannerPolicy._();

  /// An informational banner leaves by itself. Anything demanding a decision
  /// does not -- an approval request that vanished while the user was reading
  /// it is worse than one that never appeared.
  static bool autoDismisses(HabotNotificationKind kind) =>
      kind == HabotNotificationKind.informational ||
      kind == HabotNotificationKind.failure;

  static Duration dwellFor(HabotNotificationKind kind) =>
      kind == HabotNotificationKind.failure
      ? HabotMotion.snackbarDisplayWithAction
      : HabotMotion.snackbarDisplay;

  /// The status role a kind renders in. Reuses the Step 28 vocabulary, so a
  /// banner and a badge describing the same event agree.
  static HabotStatusRole roleFor(HabotNotificationKind kind) {
    switch (kind) {
      case HabotNotificationKind.critical:
        return HabotStatusRole.error;
      case HabotNotificationKind.failure:
        return HabotStatusRole.error;
      case HabotNotificationKind.dispatch:
      case HabotNotificationKind.approval:
        return HabotStatusRole.warning;
      case HabotNotificationKind.informational:
        return HabotStatusRole.primary;
    }
  }

  /// Precedence in the shared banner slot. Lower sorts first.
  ///
  /// Connectivity is not a notification kind and is not in this enum, which is
  /// the point: [connectivityPrecedence] is above everything here, so the
  /// offline banner from Step 48 always wins the slot.
  static const int connectivityPrecedence = -1;

  static int precedenceOf(HabotNotificationKind kind) {
    switch (kind) {
      case HabotNotificationKind.critical:
        return 0;
      case HabotNotificationKind.dispatch:
        return 1;
      case HabotNotificationKind.approval:
        return 2;
      case HabotNotificationKind.failure:
        return 3;
      case HabotNotificationKind.informational:
        return 4;
    }
  }

  /// Which of two competing banners takes the slot.
  static HabotNotificationKind winner(
    HabotNotificationKind a,
    HabotNotificationKind b,
  ) => precedenceOf(a) <= precedenceOf(b) ? a : b;
}

/// One banner-worthy notification.
class HabotBannerMessage {
  const HabotBannerMessage({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final String id;
  final HabotNotificationKind kind;
  final String title;
  final String body;

  /// A banner offers at most one action. Two is a dialog.
  final String? actionLabel;
  final VoidCallback? onAction;

  bool get hasAction => actionLabel != null && onAction != null;

  String get semanticsLabel =>
      '$title. $body${hasAction ? '. Action available: $actionLabel' : ''}';
}

/// The banner controller: what is showing, and what is waiting.
///
/// One at a time, by precedence. A stack of banners is a wall, and a user
/// dismissing four things to reach their screen is a user who will dismiss the
/// fifth without reading it.
class HabotBannerController extends ChangeNotifier {
  HabotBannerController();

  HabotBannerMessage? _current;
  final List<HabotBannerMessage> _pending = <HabotBannerMessage>[];
  Timer? _dwellTimer;
  final Set<String> _offeredIds = <String>{};
  final Set<String> _shownIds = <String>{};

  HabotBannerMessage? get current => _current;
  int get pendingCount => _pending.length;

  /// Messages offered to the banner, and DISTINCT messages that actually
  /// reached the screen. Distinct matters: a displaced banner that is requeued
  /// and shown again has reached the screen once, not twice, and counting the
  /// re-show would let the rate exceed 1.
  int get offeredCount => _offeredIds.length;
  int get shownCount => _shownIds.length;

  double get screenDeliveryRate =>
      _offeredIds.isEmpty ? 1 : _shownIds.length / _offeredIds.length;

  void present(HabotBannerMessage message) {
    _offeredIds.add(message.id);
    final HabotBannerMessage? showing = _current;
    if (showing == null) {
      _show(message);
      return;
    }
    if (HabotBannerPolicy.precedenceOf(message.kind) <
        HabotBannerPolicy.precedenceOf(showing.kind)) {
      // The incoming message outranks what is on screen. The displaced one is
      // requeued rather than lost.
      _pending.insert(0, showing);
      _show(message);
      return;
    }
    _pending.add(message);
    _pending.sort(
      (HabotBannerMessage a, HabotBannerMessage b) => HabotBannerPolicy
          .precedenceOf(a.kind)
          .compareTo(HabotBannerPolicy.precedenceOf(b.kind)),
    );
    notifyListeners();
  }

  void _show(HabotBannerMessage message) {
    _dwellTimer?.cancel();
    _current = message;
    _shownIds.add(message.id);
    if (HabotBannerPolicy.autoDismisses(message.kind)) {
      _dwellTimer = Timer(
        HabotBannerPolicy.dwellFor(message.kind),
        () => dismiss(message.id),
      );
    }
    notifyListeners();
  }

  void dismiss(String id) {
    if (_current?.id != id) {
      return;
    }
    _dwellTimer?.cancel();
    _current = null;
    if (_pending.isNotEmpty) {
      _show(_pending.removeAt(0));
    } else {
      notifyListeners();
    }
  }

  void clear() {
    _dwellTimer?.cancel();
    _current = null;
    _pending.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }
}

/// The banner.
class HabotInAppBanner extends StatelessWidget {
  const HabotInAppBanner({required this.controller, super.key});

  final HabotBannerController controller;

  static const Key bannerKey = Key('habot.notification.banner');
  static const Key dismissKey = Key('habot.notification.banner.dismiss');
  static const Key actionKey = Key('habot.notification.banner.action');

  /// Height is not fixed -- a two-line body needs two lines -- but the minimum
  /// is a touch target, because the dismiss control lives inside it.
  static const double minHeight = HabotDensity.minTouchTarget;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? _) {
        final HabotBannerMessage? message = controller.current;
        if (message == null) {
          return const SizedBox.shrink();
        }
        return _BannerBody(message: message, controller: controller);
      },
    );
  }
}

class _BannerBody extends StatelessWidget {
  const _BannerBody({required this.message, required this.controller});

  final HabotBannerMessage message;
  final HabotBannerController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final HabotStatusRole role = HabotBannerPolicy.roleFor(message.kind);
    final Color background =
        HabotStatuses.containerColor(theme.colorScheme, role);
    final Color foreground =
        HabotStatuses.onContainerColor(theme.colorScheme, role);

    return Semantics(
      key: HabotInAppBanner.bannerKey,
      liveRegion: true,
      label: message.semanticsLabel,
      container: true,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: HabotInAppBanner.minHeight,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(HabotShape.sm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(HabotSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  HabotStatuses.of(_statusFor(role)).icon,
                  size: HabotSpacing.lg,
                  color: foreground,
                ),
                const SizedBox(width: HabotSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        message.title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: foreground),
                      ),
                      Text(
                        message.body,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: foreground),
                      ),
                    ],
                  ),
                ),
                if (message.hasAction)
                  TextButton(
                    key: HabotInAppBanner.actionKey,
                    onPressed: message.onAction,
                    child: Text(
                      message.actionLabel!,
                      style: TextStyle(color: foreground),
                    ),
                  ),
                IconButton(
                  key: HabotInAppBanner.dismissKey,
                  onPressed: () => controller.dismiss(message.id),
                  iconSize: HabotSpacing.md,
                  color: foreground,
                  tooltip: '',
                  // AISS Step 99 (GEN-04572): see alert_panel.dart -- the
                  // Step 24 tooltip strip removed this control's accessible
                  // name along with its hover affordance.
                  icon: const Icon(
                    Icons.close,
                    semanticLabel: 'Dismiss message',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The status whose icon carries this role. WCAG 2.1 SC 1.4.1 through Step
  /// 28: the banner's meaning survives greyscale because the icon comes with
  /// the role rather than beside it.
  static HabotStatus _statusFor(HabotStatusRole role) {
    for (final HabotStatusSpec spec in HabotStatuses.all) {
      if (spec.role == role) {
        return spec.status;
      }
    }
    return HabotStatuses.all.first.status;
  }
}
