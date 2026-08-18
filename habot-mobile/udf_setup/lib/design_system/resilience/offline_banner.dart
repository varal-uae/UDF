/// AISS: GEN-03437-A01 -- "Display an 'Offline Mode' status banner and pending
/// queue counters on UI screens."
/// Metric: Banner Contrast Ratio -- Floor 4.5:1, Optimal 7:1, Ceiling 21:1.
///
/// One of the few GEN-* rows in this batch whose metric genuinely fits its
/// step: a status banner that cannot be read is not a status banner, and the
/// WCAG engine from Step 4 measures exactly this. The gate reports the
/// measured ratio rather than asserting compliance.
///
/// The banner renders [HabotConnectivityMonitor] from Step 47 and holds no
/// state of its own. That is deliberate: two sources of truth for "are we
/// offline?" is how an app ends up showing a sync icon over a queue of forty
/// unsent records.
library;

import 'package:flutter/material.dart';

import '../a11y/contrast.dart';
import '../feedback/status_badge.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'connectivity_state.dart';

/// Colour policy for the banner, kept separate from the widget so the gate can
/// measure the pair without pumping anything.
class HabotOfflineBannerPalette {
  const HabotOfflineBannerPalette._();

  /// Offline is a warning, not an error: nothing has failed, and the user's
  /// work is queued rather than lost. Warning maps to the tertiary container
  /// in this design system (Step 28 fixed that mapping).
  static const HabotStatusRole offlineRole = HabotStatusRole.warning;

  /// Degraded is quieter still -- one missed poll is not news.
  static const HabotStatusRole degradedRole = HabotStatusRole.neutral;

  static HabotStatusRole roleFor(HabotConnectivity state) =>
      state == HabotConnectivity.offline ? offlineRole : degradedRole;

  static Color background(ColorScheme scheme, HabotConnectivity state) =>
      HabotStatuses.containerColor(scheme, roleFor(state));

  static Color foreground(ColorScheme scheme, HabotConnectivity state) =>
      HabotStatuses.onContainerColor(scheme, roleFor(state));

  /// The measured ratio for a state, in a scheme. What the metric asks for.
  static double contrastFor(ColorScheme scheme, HabotConnectivity state) =>
      Contrast.ratio(
        foreground(scheme, state),
        background(scheme, state),
      );
}

/// Copy for each state. Plain language, no jargon -- the same rule REF-197
/// applied to error templates.
class HabotOfflineCopy {
  const HabotOfflineCopy._();

  static const String offlineTitle = 'Offline Mode';
  static const String degradedTitle = 'Connection is unsteady';

  static String titleFor(HabotConnectivity state) =>
      state == HabotConnectivity.offline ? offlineTitle : degradedTitle;

  /// The queue line. Singular and plural are separate strings because "1
  /// items waiting" is the kind of detail that makes an app feel unfinished.
  static String pendingFor(int count) {
    if (count == 0) {
      return 'Nothing is waiting to send.';
    }
    if (count == 1) {
      return '1 change is waiting to send.';
    }
    return '$count changes are waiting to send.';
  }
}

/// The banner.
class HabotOfflineBanner extends StatelessWidget {
  const HabotOfflineBanner({required this.monitor, super.key});

  final HabotConnectivityMonitor monitor;

  static const Key bannerKey = Key('habot.offline.banner');
  static const Key pendingCounterKey = Key('habot.offline.pendingCount');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: monitor,
      builder: (BuildContext context, Widget? _) => _banner(context),
    );
  }

  Widget _banner(BuildContext context) {
    if (monitor.state == HabotConnectivity.online) {
      return const SizedBox.shrink();
    }
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      key: bannerKey,
      liveRegion: true,
      label:
          '${HabotOfflineCopy.titleFor(monitor.state)}. '
          '${HabotOfflineCopy.pendingFor(monitor.pendingCount)}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: HabotOfflineBannerPalette.background(scheme, monitor.state),
          borderRadius: BorderRadius.circular(HabotShape.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.all(HabotSpacing.sm),
          child: _BannerContent(
            state: monitor.state,
            pendingCount: monitor.pendingCount,
            foreground: HabotOfflineBannerPalette.foreground(
              scheme,
              monitor.state,
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({
    required this.state,
    required this.pendingCount,
    required this.foreground,
  });

  final HabotConnectivity state;
  final int pendingCount;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Icon(
          state == HabotConnectivity.offline
              ? Icons.cloud_off
              : Icons.cloud_queue,
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
                HabotOfflineCopy.titleFor(state),
                style: text.titleSmall?.copyWith(color: foreground),
              ),
              Text(
                HabotOfflineCopy.pendingFor(pendingCount),
                key: HabotOfflineBanner.pendingCounterKey,
                style: text.bodySmall?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
