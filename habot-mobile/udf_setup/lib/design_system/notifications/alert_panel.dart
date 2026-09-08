/// AISS: FLADE-011-10-A01 -- "'Shakti Alert Panel' (Critical System Breach
/// UI). (Un-ignorable, global red banners alerting all users of a manual
/// override or P1 architectural breach.)"
/// Setup Step Description: "Write logic to INTERCEPT AND DISABLE ALL
/// INTERACTIVE UI ELEMENTS on the underlying screen while the alert is
/// active."
/// Metric: Observability / Alert Coverage -- Floor >=90%, Optimal 1.0.
///
/// AISS: ARCPE-009-02-A01 -- "Set Context Pruning Warning Overlays."
/// Setup Step Description: "Initialize an alert element layout layer
/// designated as the warning overlay."
/// Metric: Touch Target Size & Accessibility Compliance -- Floor 44px/WCAG AA,
///         Optimal 48px/WCAG AA, Ceiling 56px/WCAG AAA.
///
/// Two steps, one file, because they are the same mechanism at two severities:
/// a layer above the screen that takes attention. FLADE-011-10 takes ALL of
/// it; ARCPE-009-02 takes some.
///
/// COLUMN NOTE, RECORDED: neither row has an Estimated Time or substeps. Both
/// Setup Step Descriptions are unusually specific for this sheet, and are what
/// the implementation is measured against.
///
/// THE INTERCEPTION IS THE STEP. "Un-ignorable" is easy to write and easy to
/// fake -- a red banner you can tap past is ignorable. So the panel does not
/// ask the screen beneath it to behave: it wraps it in an
/// [AbsorbPointer], which swallows every gesture below by construction. There
/// is no `dismissible` parameter, and no way for a screen to opt out.
///
/// ON ARCPE-009-02'S METRIC: 44/48/56px restates the TTMAC-011 standard
/// already gated in Step 10. Rather than declaring those numbers again, the
/// overlay reads `HabotDensity.minTouchTarget` and the gate asserts the
/// optimal band equals it -- the same treatment Step 54 gave the Step 45
/// column rule.
library;

import 'package:flutter/material.dart';

import '../feedback/status_badge.dart';
import '../interaction/atomic_button.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// How much attention a layer takes.
enum HabotAlertSeverity {
  /// ARCPE-009-02: a warning. The screen beneath stays usable.
  warning,

  /// FLADE-011-10: a P1 breach. Nothing beneath responds.
  critical,
}

/// The touch-target bands ARCPE-009-02 names, bound to the standard Step 10
/// already set rather than restated.
class HabotAlertTouchTargets {
  const HabotAlertTouchTargets._();

  /// "44px / WCAG AA" -- the WCAG 2.1 SC 2.5.5 floor.
  static const double floorPx = 44;

  /// "48px / WCAG AA" -- and this is `HabotDensity.minTouchTarget`, gated in
  /// Step 10. The gate asserts the equality so the two cannot drift.
  static const double optimalPx = HabotDensity.minTouchTarget;

  /// "56px / WCAG AAA".
  static const double ceilingPx = 56;

  static bool meetsFloor(double px) => px >= floorPx;
  static bool meetsOptimal(double px) => px >= optimalPx;

  static String bandFor(double px) {
    if (px >= ceilingPx) {
      return 'AAA';
    }
    if (px >= optimalPx) {
      return 'AA (optimal)';
    }
    if (px >= floorPx) {
      return 'AA (floor)';
    }
    return 'below floor';
  }
}

/// One active alert.
@immutable
class HabotSystemAlert {
  const HabotSystemAlert({
    required this.id,
    required this.severity,
    required this.headline,
    required this.detail,
    this.acknowledgeLabel = 'Acknowledge',
  });

  final String id;
  final HabotAlertSeverity severity;
  final String headline;
  final String detail;
  final String acknowledgeLabel;

  bool get blocksInteraction => severity == HabotAlertSeverity.critical;

  HabotStatusRole get role => severity == HabotAlertSeverity.critical
      ? HabotStatusRole.error
      : HabotStatusRole.warning;

  String get semanticsLabel =>
      '${severity == HabotAlertSeverity.critical ? 'Critical system alert' : 'Warning'}. '
      '$headline. $detail';
}

/// The alert state, shared by the whole app.
///
/// "GLOBAL red banners alerting ALL USERS" - so this is not per-screen state.
/// One controller, hoisted above the shell, and every screen inherits its
/// consequences whether or not it knows about it.
class HabotAlertPanelController extends ChangeNotifier {
  HabotAlertPanelController();

  final List<HabotSystemAlert> _active = <HabotSystemAlert>[];
  final Set<String> _everRaised = <String>{};
  final Set<String> _everShown = <String>{};

  List<HabotSystemAlert> get active =>
      List<HabotSystemAlert>.unmodifiable(_active);

  /// The alert currently occupying the layer: the most severe one raised.
  HabotSystemAlert? get current {
    if (_active.isEmpty) {
      return null;
    }
    for (final HabotSystemAlert alert in _active) {
      if (alert.severity == HabotAlertSeverity.critical) {
        return alert;
      }
    }
    return _active.first;
  }

  /// True while anything beneath the layer must not respond.
  bool get isBlocking => current?.blocksInteraction ?? false;

  void raise(HabotSystemAlert alert) {
    _everRaised.add(alert.id);
    if (_active.any((HabotSystemAlert a) => a.id == alert.id)) {
      return;
    }
    _active.add(alert);
    _everShown.add(alert.id);
    notifyListeners();
  }

  /// Acknowledging removes it. A critical alert cannot be dismissed by tapping
  /// elsewhere -- only by this, which the panel wires to an explicit control.
  void acknowledge(String id) {
    final int before = _active.length;
    _active.removeWhere((HabotSystemAlert a) => a.id == id);
    if (_active.length != before) {
      notifyListeners();
    }
  }

  void clear() {
    if (_active.isEmpty) {
      return;
    }
    _active.clear();
    notifyListeners();
  }

  /// Metric: Observability / Alert Coverage. The share of raised alerts that
  /// actually reached the layer -- an alert raised and not shown is exactly
  /// the coverage gap the metric is about.
  double get alertCoverage =>
      _everRaised.isEmpty ? 1 : _everShown.length / _everRaised.length;

  int get raisedCount => _everRaised.length;
  int get shownCount => _everShown.length;
}

/// The layer.
///
/// Wraps the whole app body. When a critical alert is active the body is
/// wrapped in an [AbsorbPointer] -- which is the Setup Step Description
/// implemented rather than promised: "intercept and disable all interactive UI
/// elements on the underlying screen".
class HabotAlertPanelLayer extends StatelessWidget {
  const HabotAlertPanelLayer({
    required this.controller,
    required this.child,
    super.key,
  });

  final HabotAlertPanelController controller;
  final Widget child;

  static const Key layerKey = Key('habot.alert.layer');
  static const Key panelKey = Key('habot.alert.panel');
  static const Key overlayKey = Key('habot.alert.overlay');
  static const Key acknowledgeKey = Key('habot.alert.acknowledge');
  static const Key barrierKey = Key('habot.alert.barrier');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? _) {
        final HabotSystemAlert? alert = controller.current;
        return Stack(
          key: layerKey,
          children: <Widget>[
            // The screen. Absorbed -- not merely covered -- while a critical
            // alert is up.
            Positioned.fill(
              child: AbsorbPointer(
                key: HabotAlertPanelLayer.barrierKey,
                absorbing: controller.isBlocking,
                child: child,
              ),
            ),
            if (alert != null)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _AlertBanner(alert: alert, controller: controller),
              ),
          ],
        );
      },
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.alert, required this.controller});

  final HabotSystemAlert alert;
  final HabotAlertPanelController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background =
        HabotStatuses.containerColor(theme.colorScheme, alert.role);
    final Color foreground =
        HabotStatuses.onContainerColor(theme.colorScheme, alert.role);
    final bool critical = alert.severity == HabotAlertSeverity.critical;

    return Material(
      key: critical
          ? HabotAlertPanelLayer.panelKey
          : HabotAlertPanelLayer.overlayKey,
      color: background,
      child: SafeArea(
        bottom: false,
        child: Semantics(
          liveRegion: true,
          label: alert.semanticsLabel,
          container: true,
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.all(HabotSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  critical ? Icons.gpp_maybe : Icons.warning_amber_outlined,
                  color: foreground,
                  size: HabotSpacing.lg,
                ),
                const SizedBox(width: HabotSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        alert.headline,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: foreground),
                      ),
                      const SizedBox(height: HabotSpacing.xxs),
                      Text(
                        alert.detail,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: foreground),
                      ),
                      const SizedBox(height: HabotSpacing.xs),
                      // The only way out of a critical alert. An AtomicButton,
                      // so it carries the Step 10 touch target and the Step 13
                      // interaction boundaries rather than declaring its own.
                      AtomicButton(
                        key: HabotAlertPanelLayer.acknowledgeKey,
                        semanticLabel: alert.acknowledgeLabel,
                        touchPadding: HabotSpacing.xs,
                        onPressed: () => controller.acknowledge(alert.id),
                        child: Text(
                          alert.acknowledgeLabel,
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: foreground),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ARCPE-009-02: the warning overlay as a standalone layout layer.
///
/// "Initialize an alert element layout LAYER designated as the warning
/// overlay." A layer, not a widget on a screen -- so it takes the body and
/// returns it wrapped, the same shape as the critical panel above, and the
/// two cannot end up with different geometry.
class HabotWarningOverlay extends StatelessWidget {
  const HabotWarningOverlay({
    required this.message,
    required this.onDismiss,
    required this.child,
    super.key,
  });

  /// Null hides the overlay entirely.
  final String? message;
  final VoidCallback onDismiss;
  final Widget child;

  static const Key overlayKey = Key('habot.warning.overlay');
  static const Key dismissKey = Key('habot.warning.dismiss');

  /// The type role for the overlay's text. bodyMedium wraps rather than
  /// truncating (Step 46), which a warning must.
  static const HabotTypeToken messageToken = HabotTypography.bodyMedium;

  @override
  Widget build(BuildContext context) {
    final String? text = message;
    if (text == null) {
      return child;
    }
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          key: overlayKey,
          liveRegion: true,
          label: 'Warning. $text',
          container: true,
          excludeSemantics: true,
          child: ColoredBox(
            color: HabotStatuses.containerColor(
              theme.colorScheme,
              HabotStatusRole.warning,
            ),
            child: Padding(
              padding: const EdgeInsets.all(HabotSpacing.sm),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: HabotStatuses.onContainerColor(
                          theme.colorScheme,
                          HabotStatusRole.warning,
                        ),
                      ),
                    ),
                  ),
                  // Sized to the optimal band ARCPE-009-02 names, which is the
                  // Step 10 token rather than a 48 written here.
                  SizedBox(
                    width: HabotAlertTouchTargets.optimalPx,
                    height: HabotAlertTouchTargets.optimalPx,
                    child: IconButton(
                      key: dismissKey,
                      onPressed: onDismiss,
                      tooltip: '',
                      // AISS Step 99 (GEN-04572): on an IconButton the
                      // tooltip is also the accessible name, so the Step 24
                      // hover strip left this control announcing as "button"
                      // and nothing else. semanticLabel restores the name
                      // without restoring the hover affordance.
                      icon: const Icon(
                        Icons.close,
                        semanticLabel: 'Dismiss alert',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
