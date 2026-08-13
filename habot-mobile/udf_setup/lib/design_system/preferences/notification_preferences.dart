/// AISS: GEN-03404-A01 -- "Build the mobile notification preference screen
/// using M3 Switch components."
/// Metric: Preference Screen Render Time -- Floor <100ms, Optimal <30ms,
///         Ceiling 200ms.
///
/// The narrowest and most dependent thing in the batch, and last for that
/// reason: a screen, inside a panel (Step 49), inside a shell (Steps 36-40),
/// reached through a route (Step 43).
///
/// The name comes from IS22-RCGLA-022's own Atomic Reusability column --
/// "NotificationPreferenceSheet UI wrapper block" -- so the two steps are
/// linked in the sheet as well as in the code.
///
/// On the metric: a render budget is measurable here, unlike most of the
/// GEN-* metrics in this batch. The gate builds the screen and times it. What
/// it measures is the widget build, not a cold app start -- and it says so,
/// because a 30ms budget that quietly excluded half the work would be worth
/// nothing.
library;

import 'package:flutter/material.dart';

import '../surfaces/bottom_sheet.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'preference_manager.dart';

/// The render budget, from the step's own metric row.
class HabotPreferenceRenderBudget {
  const HabotPreferenceRenderBudget._();

  /// Floor: "< 100ms".
  static const Duration floor = HabotMotion.preferenceRenderFloor;

  /// Optimal: "< 30ms".
  static const Duration optimal = HabotMotion.preferenceRenderOptimal;

  /// Ceiling: "200ms" -- and also [HabotMotion.interactiveCeiling], because a
  /// screen the user is waiting on is subject to the same ceiling as anything
  /// else they wait on.
  static const Duration ceiling = HabotMotion.interactiveCeiling;

  static bool withinFloor(Duration measured) => measured < floor;
  static bool withinOptimal(Duration measured) => measured < optimal;
}

/// The notification preference screen.
///
/// Deliberately not a `Page`: it renders inside the shell's current
/// destination, and only [NotificationPreferenceSheet] presents it as its own
/// surface. That keeps it out of the RCGLA-018 screen inventory, which is for
/// things that own a scaffold.
class NotificationPreferenceView extends StatelessWidget {
  const NotificationPreferenceView({required this.store, super.key});

  final PreferenceStore store;

  static const Key viewKey = Key('habot.preferences.notifications');

  static const String title = 'Notifications';

  static const String intro =
      'Choose what we may send you. Receipts and security alerts are separate '
      'from offers, so turning one off never affects the other.';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      key: viewKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: HabotSpacing.md),
          child: Text(intro, style: theme.textTheme.bodyMedium),
        ),
        const SizedBox(height: HabotSpacing.xs),
        HabotPreferencePanel(store: store),
        const SizedBox(height: HabotSpacing.xs),
        _WriteStatus(store: store),
      ],
    );
  }
}

/// Substep 3's other half: the user can see that a change landed.
///
/// A settings screen that saves silently is indistinguishable from one that
/// does not save at all.
class _WriteStatus extends StatelessWidget {
  const _WriteStatus({required this.store});

  final PreferenceStore store;

  static const Key statusKey = Key('habot.preferences.writeStatus');

  /// Listens to the store in its own right. Sharing the panel's
  /// [AnimatedBuilder] would have left the status line showing the outcome of
  /// the previous write -- a settings screen that lies quietly is worse than
  /// one that says nothing.
  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: store,
      builder: (BuildContext context, Widget? _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: HabotSpacing.md),
        child: Text(_message, key: statusKey, style: text.labelMedium),
      ),
    );
  }

  String get _message {
    if (store.isWriting) {
      return 'Saving...';
    }
    return store.failed.isEmpty
        ? 'All changes saved'
        : 'Some changes could not be saved';
  }
}

/// IS22-RCGLA-022 Atomic Reusability: "NotificationPreferenceSheet UI wrapper
/// block." The same view, presented as a bottom sheet from anywhere in the app.
class NotificationPreferenceSheet {
  const NotificationPreferenceSheet._();

  static Future<void> show(BuildContext context, PreferenceStore store) {
    return HabotBottomSheet.show<void>(
      context: context,
      title: NotificationPreferenceView.title,
      builder: (BuildContext context) =>
          NotificationPreferenceView(store: store),
    );
  }
}
