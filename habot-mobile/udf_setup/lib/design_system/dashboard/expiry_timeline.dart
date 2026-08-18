/// AISS: SCTSS-019-A01 -- "Expiry Timeline Trackers - Replace spreadsheet
/// grids with visual data maps that cleanly structure timeline restrictions."
///
/// 4 Substeps, verbatim:
///   1. "Define expiration metadata."
///   2. "Set rendering arrays."
///   3. "Map to Boolean locks."
///   4. "Code visual alerts."
///
/// Mobile App First: "A HORIZONTAL timeline component specifically optimized
/// for mobile side-scrolling gestures."
/// Poka-Yoke: "Timeline dates are hard-rendered as READ-ONLY; HR physically
/// cannot click to edit or shorten the dates."
/// Self-Chasing: "Active non-compete visually overlays a PADLOCK ICON on
/// 'Rehire' button, chasing HR to wait until timeline expires."
/// Completion Measure: "100% of separated employees with active non-competes
/// visually tracked."
/// Metric: Responsive Layout Fidelity (%) -- Floor 0.95, Optimal 1.0.
///
/// The poka-yoke is the design constraint, and it is stronger than "do not add
/// an edit button". A restriction whose end date can be moved by the person
/// the restriction inconveniences is not a restriction. So [HabotExpiry] has
/// no setters, the widget takes no edit callback, and substep 3's "Boolean
/// locks" are DERIVED from the dates rather than stored beside them -- there
/// is no lock flag to flip.
library;

import 'package:flutter/material.dart';

import '../feedback/status_badge.dart';
import '../tokens/dashboard_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// Substep 1: "Define expiration metadata."
///
/// Immutable by construction. Every field is final, every derived state is a
/// getter, and there is no `copyWith` that takes a new end date -- which is
/// the poka-yoke expressed in the type system rather than in a review comment.
@immutable
class HabotExpiry {
  const HabotExpiry({
    required this.id,
    required this.subject,
    required this.restriction,
    required this.startsOn,
    required this.endsOn,
  });

  final String id;

  /// Who or what the restriction applies to.
  final String subject;

  /// What is restricted -- "Non-compete", "Garden leave", "Licence".
  final String restriction;

  final DateTime startsOn;
  final DateTime endsOn;

  Duration get totalDuration => endsOn.difference(startsOn);

  /// Substep 3: "Map to BOOLEAN LOCKS." Derived, never stored.
  bool isActiveAt(DateTime now) =>
      !now.isBefore(startsOn) && now.isBefore(endsOn);

  bool hasExpiredAt(DateTime now) => !now.isBefore(endsOn);

  bool isPendingAt(DateTime now) => now.isBefore(startsOn);

  /// How far through the restriction [now] sits, 0 to 1. The bar length.
  double progressAt(DateTime now) {
    if (totalDuration.inSeconds <= 0) {
      return 1;
    }
    final double t =
        now.difference(startsOn).inSeconds / totalDuration.inSeconds;
    return t.clamp(0.0, 1.0);
  }

  int daysRemainingAt(DateTime now) {
    final int days = endsOn.difference(now).inDays;
    return days < 0 ? 0 : days;
  }

  /// Substep 4: "Code visual ALERTS." The role a restriction carries, derived
  /// from how close it is to expiring rather than set by a caller.
  HabotStatusRole roleAt(DateTime now) {
    if (hasExpiredAt(now)) {
      return HabotStatusRole.success;
    }
    if (isPendingAt(now)) {
      return HabotStatusRole.neutral;
    }
    return daysRemainingAt(now) <= HabotExpiryTimeline.imminentDays
        ? HabotStatusRole.warning
        : HabotStatusRole.error;
  }

  /// Self-Chasing: the padlock. True while the restriction blocks the action
  /// it exists to block.
  bool locksActionAt(DateTime now) => isActiveAt(now) || isPendingAt(now);

  String semanticsLabelAt(DateTime now) {
    if (hasExpiredAt(now)) {
      return '$subject, $restriction expired';
    }
    if (isPendingAt(now)) {
      return '$subject, $restriction not yet started';
    }
    return '$subject, $restriction active, '
        '${daysRemainingAt(now)} days remaining, locked';
  }
}

/// Substep 2: "Set rendering arrays." The layout numbers for the timeline.
class HabotExpiryTimeline {
  const HabotExpiryTimeline._();

  /// Within this many days of expiry a restriction is imminent rather than
  /// merely active, and its alert changes.
  static const int imminentDays = 30;

  /// The width of one row's track. Wider than a phone on purpose -- the
  /// Mobile App First row asks for a horizontal side-scrolling component, and
  /// a timeline squeezed to 360dp is the spreadsheet grid this step replaces.
  static const double trackWidth = 480;

  static const double trackHeight = HabotSpacing.sm;
  static const double rowHeight = 64;
  static const double labelWidth = 140;

  /// Every restriction in [expiries] is on screen. The completion measure
  /// asks for "100% of separated employees with active non-competes visually
  /// tracked", and this is that count -- nothing is paged out of view.
  static int trackedCount(List<HabotExpiry> expiries) => expiries.length;

  static int activeCount(List<HabotExpiry> expiries, DateTime now) =>
      expiries.where((HabotExpiry e) => e.isActiveAt(now)).length;
}

/// The tracker.
///
/// Takes no `onDateChanged`, no `onEdit` and no `editable` flag. There is no
/// parameter through which a date could be modified, which is what "physically
/// cannot" means when it is implemented rather than promised.
class HabotExpiryTracker extends StatelessWidget {
  const HabotExpiryTracker({
    required this.expiries,
    required this.now,
    super.key,
  });

  final List<HabotExpiry> expiries;

  /// Injected rather than read from the clock, so the gates can drive a
  /// restriction across its own expiry without waiting for it.
  final DateTime now;

  static const Key trackerKey = Key('habot.expiry.tracker');
  static Key rowKeyFor(String id) => Key('habot.expiry.$id');
  static Key padlockKeyFor(String id) => Key('habot.expiry.lock.$id');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: trackerKey,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: HabotExpiryTimeline.labelWidth +
            HabotExpiryTimeline.trackWidth +
            HabotSpacing.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final HabotExpiry expiry in expiries)
              _ExpiryRow(expiry: expiry, now: now),
          ],
        ),
      ),
    );
  }
}

class _ExpiryRow extends StatelessWidget {
  const _ExpiryRow({required this.expiry, required this.now});

  final HabotExpiry expiry;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final HabotStatusRole role = expiry.roleAt(now);
    final Color accent =
        HabotStatuses.onContainerColor(theme.colorScheme, role);
    final Color track =
        HabotStatuses.containerColor(theme.colorScheme, role);

    return Semantics(
      key: HabotExpiryTracker.rowKeyFor(expiry.id),
      label: expiry.semanticsLabelAt(now),
      container: true,
      excludeSemantics: true,
      child: SizedBox(
        height: HabotExpiryTimeline.rowHeight,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: HabotExpiryTimeline.labelWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(expiry.subject, style: theme.textTheme.labelLarge),
                  Text(
                    expiry.restriction,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: HabotSpacing.xs),
            // The padlock. UI Decision row asks for high contrast, so it takes
            // the status role's on-container colour, which Step 28 already
            // measured at 7:1 in both schemes.
            if (expiry.locksActionAt(now))
              Icon(
                Icons.lock_outline,
                key: HabotExpiryTracker.padlockKeyFor(expiry.id),
                size: HabotSpacing.md,
                color: accent,
              )
            else
              Icon(
                Icons.lock_open_outlined,
                size: HabotSpacing.md,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            const SizedBox(width: HabotSpacing.xs),
            Expanded(
              child: _Track(
                progress: expiry.progressAt(now),
                accent: accent,
                track: track,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({
    required this.progress,
    required this.accent,
    required this.track,
  });

  final double progress;
  final Color accent;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        HabotDashboardTokens.skeletonCornerRadius,
      ),
      child: SizedBox(
        height: HabotExpiryTimeline.trackHeight,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              widthFactor: progress,
              child: ColoredBox(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
