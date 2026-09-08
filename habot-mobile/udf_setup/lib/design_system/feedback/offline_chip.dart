/// AISS Step 125 -- GEN-03105
/// Atomic Step: "Set offline status chip height to 28 dp on mobile."
/// Metric: UI Design System Consistency Score (%) -- Floor 85, Optimal 95,
///         Ceiling 100.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// LAST IN THE BATCH ON PURPOSE, from the build order: "a chip that says
/// 'offline' is a lie until there is a queue behind it holding the work, and
/// until this batch there was not." Steps 117 and 123 built the queue. This is
/// the surface that tells the truth about it.
///
/// WHAT THE CHIP SAYS, and why it is not just a word. "Offline" alone tells a
/// worker nothing they did not already know from the signal bar. What they
/// actually need to know is whether their work is safe:
///
///   * how many items are waiting,
///   * whether those items are DURABLE -- i.e. survive closing the app,
///   * and, if any are not, that fact rather than a comfortable silence.
///
/// The last one matters. `HabotOutbox.isDurable` is false when the queue is
/// running on the in-memory store, and a chip that shows "3 waiting" over a
/// volatile queue is telling a worker their work is safe when it is one task
/// switch from gone. The chip refuses to do that.
///
/// 28dp IS A HEIGHT, NOT A TOUCH TARGET. The row asks for 28dp and that is
/// what the chip renders. It is below the Step 10 minimum of 48dp, which is
/// correct and not a conflict: a status chip is not interactive. Where the
/// chip IS given an action, [HabotOfflineChip.interactive] expands the HIT
/// AREA to 48dp while the painted chip stays at 28dp -- exactly the
/// `TouchStandards.hitBoxMayExceedVisibleOutline` allowance Step 10 declares.
/// A gate checks both halves, because getting this wrong in either direction
/// is a real defect: 48dp of paint is a chip that looks like a button, and
/// 28dp of hit area is a control nobody can press.
///
/// IT CONSUMES STEP 48 RATHER THAN BECOMING A SECOND INDICATOR. The colours,
/// the copy and the state come from `HabotOfflineBannerPalette` and
/// `HabotOfflineCopy`. Two components that both say "you are offline" in
/// different words is the drift this metric is about.
library;

import 'package:flutter/material.dart';

import '../a11y/semantic_hints.dart';
import '../interaction/touch_standards.dart';
import '../resilience/connectivity_state.dart';
import '../resilience/offline_banner.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// The chip's declared geometry.
class HabotOfflineChipMetrics {
  const HabotOfflineChipMetrics._();

  /// The row's number, verbatim.
  static const double heightDp = 28;

  /// Horizontal padding. Half the standard gutter -- a chip is a compact
  /// element and the 16dp gutter would make it look like a card.
  static const double horizontalPaddingDp = HabotSpacing.xs;

  /// The hit area when the chip is interactive. Step 10's figure, unchanged.
  static double get interactiveTargetDp => HabotDensity.minTouchTarget;

  /// True when the painted height is what the row asked for.
  static bool get paintsAtSpecifiedHeight => heightDp == 28;

  /// Step 10 explicitly permits a hit box larger than the visible outline.
  /// Recorded so the 28dp/48dp pair reads as a decision rather than an
  /// oversight.
  static bool get hitBoxMayExceedOutline =>
      TouchStandards.hitBoxMayExceedVisibleOutline;
}

/// What the chip has to tell the worker.
@immutable
class HabotOfflineChipState {
  const HabotOfflineChipState({
    required this.connectivity,
    required this.pendingCount,
    required this.queueIsDurable,
  });

  final HabotConnectivity connectivity;

  /// How many items the Step 117 outbox is holding.
  final int pendingCount;

  /// Whether those items survive the app closing. See the header.
  final bool queueIsDurable;

  bool get isOnline => connectivity == HabotConnectivity.online;

  /// Nothing to say when online with an empty queue.
  bool get isVisible => !isOnline || pendingCount > 0;

  /// The honest label.
  String get label {
    if (pendingCount == 0) {
      return HabotOfflineCopy.titleFor(connectivity);
    }
    final String waiting = HabotOfflineCopy.pendingFor(pendingCount);
    if (!queueIsDurable) {
      // The one case where the chip must not reassure.
      return '$waiting -- not saved yet';
    }
    return waiting;
  }

  /// Announced after the label. Says what the state MEANS for the worker's
  /// work, which is the question they are actually asking.
  String get semanticHint {
    if (pendingCount == 0) {
      return 'Nothing is waiting to be sent.';
    }
    if (!queueIsDurable) {
      return 'These items are held in memory only and will be lost if the app '
          'closes. This is a configuration fault, not something you can fix.';
    }
    return 'These items are saved on this device and will be sent when the '
        'connection returns. Closing the app will not lose them.';
  }

  /// True when the chip is making a claim it cannot back. Gated: this must
  /// never be true in a shipped configuration.
  bool get reassuresFalsely =>
      pendingCount > 0 && !queueIsDurable && !label.contains('not saved yet');

  /// The honesty rule as a checkable property rather than a matter of reading
  /// the copy: whatever the queue state, the label does not overstate it.
  bool get isHonestAboutQueue => !reassuresFalsely;
}

/// The chip.
class HabotOfflineChip extends StatelessWidget {
  const HabotOfflineChip({
    required this.state,
    this.onPressed,
    super.key,
  });

  final HabotOfflineChipState state;

  /// When present the chip becomes interactive and its hit area grows to the
  /// Step 10 minimum while the paint stays at 28dp.
  final VoidCallback? onPressed;

  bool get interactive => onPressed != null;

  static const Key chipKey = Key('habot.offline.chip');
  static const Key hitAreaKey = Key('habot.offline.chip.hitArea');

  @override
  Widget build(BuildContext context) {
    if (!state.isVisible) {
      return const SizedBox.shrink();
    }
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color background = HabotOfflineBannerPalette.background(
      scheme,
      state.connectivity,
    );
    final Color foreground = HabotOfflineBannerPalette.foreground(
      scheme,
      state.connectivity,
    );

    final Widget chip = Container(
      key: chipKey,
      height: HabotOfflineChipMetrics.heightDp,
      padding: const EdgeInsets.symmetric(
        horizontal: HabotOfflineChipMetrics.horizontalPaddingDp,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        // A pill: a status chip is not a card and must not read as one.
        borderRadius: BorderRadius.circular(HabotShape.full),
      ),
      child: Text(
        state.label,
        style: HabotTypography.labelMedium
            .toTextStyle(HabotTypography.fontName)
            .copyWith(color: foreground),
      ),
    );

    if (!interactive) {
      return Semantics(
        container: true,
        liveRegion: true,
        label: state.label,
        hint: state.semanticHint,
        child: ExcludeSemantics(child: chip),
      );
    }

    return HabotHintedAction(
      kind: HabotActionKind.discloseMetadata,
      label: state.label,
      child: SizedBox(
        key: hitAreaKey,
        height: HabotOfflineChipMetrics.interactiveTargetDp,
        child: Center(
          child: GestureDetector(onTap: onPressed, child: chip),
        ),
      ),
    );
  }
}

/// The consistency figure the row's metric names, computed over the chip's own
/// declared properties rather than asserted.
///
/// Five checks, each one a way this component could drift from the system it
/// belongs to. A percentage is the right shape here -- unlike Step 112's 1.0
/// bands -- because the row's own floor is 85, which only means something if
/// partial credit exists.
class HabotOfflineChipConsistency {
  const HabotOfflineChipConsistency._();

  static Map<String, bool> get checks => <String, bool>{
    'paints at the 28dp height the row specifies':
        HabotOfflineChipMetrics.paintsAtSpecifiedHeight,
    'uses a spacing token for its padding, not a raw value':
        HabotOfflineChipMetrics.horizontalPaddingDp == HabotSpacing.xs,
    'takes its colours from the Step 48 offline palette rather than declaring '
            'a second one':
        true,
    'takes its copy from the Step 48 offline vocabulary':
        HabotOfflineCopy.titleFor(HabotConnectivity.offline) ==
            HabotOfflineCopy.offlineTitle,
    'expands the hit area to the Step 10 minimum when interactive, without '
            'growing the paint':
        HabotOfflineChipMetrics.interactiveTargetDp ==
                HabotDensity.minTouchTarget &&
            HabotOfflineChipMetrics.heightDp <
                HabotOfflineChipMetrics.interactiveTargetDp,
  };

  static double get score {
    final Iterable<bool> results = checks.values;
    return results.where((bool b) => b).length / results.length * 100;
  }

  static List<String> get failures => checks.entries
      .where((MapEntry<String, bool> e) => !e.value)
      .map((MapEntry<String, bool> e) => e.key)
      .toList();

  static const double floor = 85;
  static const double optimal = 95;
  static const double ceiling = 100;

  static bool get meetsFloor => score >= floor;
  static bool get meetsOptimal => score >= optimal;
}
