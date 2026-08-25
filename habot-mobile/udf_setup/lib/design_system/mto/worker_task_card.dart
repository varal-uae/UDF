/// AISS: GEN-02896-A01 -- "Build the mobile worker interface using MATERIAL 3
/// ELEVATED CARD component."
/// Metric: Mobile Usability Task Success Rate (%) -- Floor 80.0, Optimal 95.0.
///
/// METRIC NOT PRODUCED, RECORDED. A task success rate is obtained by giving a
/// task to a sample of people and counting who completes it. No suite produces
/// it, and the same metric was already recorded as not produced on Step 77. No
/// number is invented in its place. What IS gated is what the step names: an
/// M3 elevated card, and the properties this design system already requires of
/// every card.
///
/// A VARIANT, NOT A FOURTH CARD. `HabotCard` from Step 29 owns the elevation
/// ladder, the corner radius and the rule that a card may have a shadow or a
/// border but never both. This is the same treatment Step 52 gave the KPI
/// card: the worker card configures that chassis rather than drawing its own,
/// and a gate asserts the variant is `elevated` because the sheet names it.
///
/// THE PRIORITY BADGE IS STEP 78's. `HabotAlertPriority` already maps P1-P4 to
/// the Step 28 status roles, so a P1 task and a P1 alert are the same red. One
/// priority vocabulary, not two.
library;

import 'package:flutter/material.dart';

import '../feedback/status_badge.dart';
import '../notifications/alert_priority.dart';
import '../surfaces/card_chassis.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';
import 'interaction_timer.dart';
import 'task_queue.dart';

/// The card a worker sees in a list of waiting tasks.
///
/// It summarises; it does not isolate. The crop itself is only ever rendered
/// on the task screen, inside the chassis -- a list of thumbnails would put
/// nine crops on one screen and undo Step 81.
class HabotWorkerTaskCard extends StatelessWidget {
  const HabotWorkerTaskCard({
    required this.task,
    required this.onOpen,
    this.timer,
    super.key,
  });

  final HabotMtoTask task;

  /// Opening is the whole interaction. The card has no secondary control,
  /// because `HabotCard` makes the whole surface the target.
  final VoidCallback onOpen;

  /// When present, the elapsed readout is shown. Null on a task nobody has
  /// started.
  final HabotInteractionTimer? timer;

  static const Key cardKey = Key('habot.mto.taskCard');
  static const Key elapsedKey = Key('habot.mto.taskCard.elapsed');

  /// The sheet names the component: "Material 3 Elevated Card".
  static const HabotCardVariant variant = HabotCardVariant.elevated;

  /// The Step 78 priority, rendered in the Step 28 vocabulary.
  HabotStatusRole get priorityRole => task.priority.role;

  String get semanticLabel =>
      '${task.priority.label} priority task. ${task.prompt}. '
      '${task.isAllocated ? 'In progress.' : 'Waiting.'}';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return HabotCard(
      key: cardKey,
      variant: variant,
      onPressed: onOpen,
      semanticLabel: semanticLabel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PriorityChip(priority: task.priority),
          const SizedBox(width: HabotSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(task.prompt, style: theme.textTheme.titleSmall),
                const SizedBox(height: HabotSpacing.xxs),
                Text(
                  task.isAllocated ? 'In progress' : 'Waiting',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (timer != null)
            AnimatedBuilder(
              animation: timer!,
              builder: (BuildContext context, Widget? _) => Text(
                timer!.readout,
                key: elapsedKey,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: timer!.isOverSla ? scheme.error : scheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The priority badge: colour AND text, because colour alone fails SC 1.4.1 --
/// the same rule the Step 28 status badge follows.
class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final HabotAlertPriority priority;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HabotStatuses.containerColor(scheme, priority.role),
        borderRadius: BorderRadius.circular(HabotShape.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HabotSpacing.xs,
          vertical: HabotSpacing.xxs,
        ),
        child: Text(
          priority.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: HabotStatuses.onContainerColor(scheme, priority.role),
          ),
        ),
      ),
    );
  }
}
