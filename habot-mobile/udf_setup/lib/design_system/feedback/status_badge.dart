/// AISS: GEN-01275-A01 -- "Embed M3 status Badges to mark completed and active
/// milestone nodes."
///
/// The badge is the persistent form of the same status a snackbar announces
/// once, so both draw from one vocabulary: [HabotStatus]. Two vocabularies
/// would let a node read "Active" while the message that produced it said
/// "In review".
///
/// WCAG 2.1 SC 1.4.1 ("use of colour") is the constraint that shapes this
/// component: a status may never be carried by colour alone. Every status here
/// has an icon and a text label as well as a colour role, and the gate asserts
/// that all three are populated for every value -- so a colour-blind user, a
/// greyscale screenshot and a screen reader all get the same information.
library;

import 'package:flutter/material.dart';

import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';

/// The status vocabulary. One list, used by badges, milestone nodes and any
/// future status surface.
enum HabotStatus {
  /// Not started. Present in the sequence, waiting its turn.
  pending,

  /// The step the user is on now -- the "active" the requirement names.
  active,

  /// Finished successfully -- the "completed" the requirement names.
  complete,

  /// Cannot proceed until something outside this step changes.
  blocked,

  /// Attempted and failed.
  failed,
}

/// Which colour role a status paints with. Roles, not colours: the actual
/// values come from the audited scheme, so both themes are covered and a brand
/// palette swap cannot break the contrast guarantee.
enum HabotStatusRole { neutral, primary, success, warning, error }

class HabotStatusSpec {
  const HabotStatusSpec({
    required this.status,
    required this.label,
    required this.icon,
    required this.role,
  });

  final HabotStatus status;

  /// SC 1.4.1: the text carrier.
  final String label;

  /// SC 1.4.1: the shape carrier.
  final IconData icon;

  /// The colour carrier -- third of three, never the only one.
  final HabotStatusRole role;
}

class HabotStatuses {
  const HabotStatuses._();

  static const Map<HabotStatus, HabotStatusSpec> _specs =
      <HabotStatus, HabotStatusSpec>{
        HabotStatus.pending: HabotStatusSpec(
          status: HabotStatus.pending,
          label: 'Pending',
          icon: Icons.radio_button_unchecked,
          role: HabotStatusRole.neutral,
        ),
        HabotStatus.active: HabotStatusSpec(
          status: HabotStatus.active,
          label: 'Active',
          icon: Icons.play_circle_outline,
          role: HabotStatusRole.primary,
        ),
        HabotStatus.complete: HabotStatusSpec(
          status: HabotStatus.complete,
          label: 'Complete',
          icon: Icons.check_circle,
          role: HabotStatusRole.success,
        ),
        HabotStatus.blocked: HabotStatusSpec(
          status: HabotStatus.blocked,
          label: 'Blocked',
          icon: Icons.pause_circle_outline,
          role: HabotStatusRole.warning,
        ),
        HabotStatus.failed: HabotStatusSpec(
          status: HabotStatus.failed,
          label: 'Failed',
          icon: Icons.error_outline,
          role: HabotStatusRole.error,
        ),
      };

  static HabotStatusSpec of(HabotStatus status) => _specs[status]!;

  static Iterable<HabotStatusSpec> get all => _specs.values;

  static bool get isComplete => _specs.length == HabotStatus.values.length;

  /// Container colour for a role, from the audited scheme.
  static Color containerColor(ColorScheme scheme, HabotStatusRole role) {
    switch (role) {
      case HabotStatusRole.neutral:
        return scheme.surfaceContainerHighest;
      case HabotStatusRole.primary:
        return scheme.primaryContainer;
      case HabotStatusRole.success:
        return scheme.secondaryContainer;
      case HabotStatusRole.warning:
        return scheme.tertiaryContainer;
      case HabotStatusRole.error:
        return scheme.errorContainer;
    }
  }

  /// The content colour that pairs with [containerColor]. Kept adjacent so the
  /// pairing cannot drift -- the contrast audit measures exactly these pairs.
  static Color onContainerColor(ColorScheme scheme, HabotStatusRole role) {
    switch (role) {
      case HabotStatusRole.neutral:
        return scheme.onSurface;
      case HabotStatusRole.primary:
        return scheme.onPrimaryContainer;
      case HabotStatusRole.success:
        return scheme.onSecondaryContainer;
      case HabotStatusRole.warning:
        return scheme.onTertiaryContainer;
      case HabotStatusRole.error:
        return scheme.onErrorContainer;
    }
  }
}

/// A labelled status badge: icon, text and colour together.
class HabotStatusBadge extends StatelessWidget {
  const HabotStatusBadge({required this.status, super.key});

  final HabotStatus status;

  HabotStatusSpec get spec => HabotStatuses.of(status);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color content = HabotStatuses.onContainerColor(scheme, spec.role);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HabotStatuses.containerColor(scheme, spec.role),
        borderRadius: BorderRadius.circular(HabotShape.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HabotSpacing.xs,
          vertical: HabotFeedback.badgeHorizontalPadding,
        ),
        child: _BadgeContent(spec: spec, color: content),
      ),
    );
  }
}

class _BadgeContent extends StatelessWidget {
  const _BadgeContent({required this.spec, required this.color});

  final HabotStatusSpec spec;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(spec.icon, size: HabotFeedback.badgeIconSize, color: color),
        const SizedBox(width: HabotFeedback.badgeHorizontalPadding),
        Text(
          spec.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

/// A milestone node: the badge attached to a step in a sequence.
///
/// This is the shape the requirement actually describes -- "mark completed and
/// active milestone nodes" -- and it exists so a caller cannot mark a node by
/// tinting it and calling that a badge.
class HabotMilestoneNode extends StatelessWidget {
  const HabotMilestoneNode({
    required this.title,
    required this.status,
    super.key,
  });

  final String title;
  final HabotStatus status;

  @override
  Widget build(BuildContext context) {
    // One node, one sentence: a screen reader should say "Invoice sent,
    // Complete", not read the title and the badge as unrelated fragments.
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '$title, ${HabotStatuses.of(status).label}',
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: HabotSpacing.xs),
          HabotStatusBadge(status: status),
        ],
      ),
    );
  }
}
