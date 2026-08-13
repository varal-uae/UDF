/// AISS: GEN-03270-A01 -- "Create responsive split-screen and master-detail
/// layout containers for mobile/tablet screens."
/// Metric: Layout Responsiveness Pass Rate -- Floor = Optimal = Ceiling = 1.0.
///   A single-value metric: every viewport passes, or the step is not done.
///
/// The containers that implement Step 36's blueprint. Two of them, because the
/// sheet names two and they answer different questions:
///
///   * [HabotSplitView] shows evidence and action AT THE SAME TIME. It is the
///     Contextual Mirror.
///   * [HabotMasterDetail] shows a list, then a record. On a wide screen those
///     are two panes; on a phone they are two screens, and the container is
///     what makes that difference invisible to the caller.
///
/// Neither takes a width, a ratio or a breakpoint parameter. They read the
/// viewport and consult the blueprint, which is what stops "responsive" from
/// meaning "each screen decides for itself".
library;

import 'package:flutter/material.dart';

import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'contextual_mirror.dart';

/// The Contextual Mirror, as a widget.
class HabotSplitView extends StatefulWidget {
  const HabotSplitView({
    required this.evidence,
    required this.action,
    this.evidenceLabel = 'Evidence',
    this.actionLabel = 'Action',
    this.initialRatio = ContextualMirrorSpec.defaultRatio,
    super.key,
  });

  final Widget evidence;
  final Widget action;

  /// Used for the tab labels in the fallback arrangement and for semantics.
  final String evidenceLabel;
  final String actionLabel;

  final HabotSplitRatio initialRatio;

  /// The bar the operator double-taps to cycle the split. Public so the gate
  /// finds it by identity rather than by position.
  static const Key panelBarKey = Key('habot.split.panelBar');

  @override
  State<HabotSplitView> createState() => HabotSplitViewState();
}

class HabotSplitViewState extends State<HabotSplitView> {
  late HabotSplitRatio _ratio = widget.initialRatio;

  /// The current stop. Read by the gate after a double-tap.
  HabotSplitRatio get ratio => _ratio;

  /// Flow Impact: "Double-tapping panel bars snaps views between split ratios
  /// instantly." Instantly means instantly -- there is no animation here on
  /// purpose, because the operator asked for a specific size and watching it
  /// travel is not information.
  void cycleRatio() {
    setState(() => _ratio = _ratio.next);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final HabotMirrorLayout layout = ContextualMirrorSpec.resolve(
      width: size.width,
      height: size.height,
      ratio: _ratio,
    );
    return _MirrorBody(layout: layout, owner: widget, onCycle: cycleRatio);
  }
}

class _MirrorBody extends StatelessWidget {
  const _MirrorBody({
    required this.layout,
    required this.owner,
    required this.onCycle,
  });

  final HabotMirrorLayout layout;
  final HabotSplitView owner;
  final VoidCallback onCycle;

  @override
  Widget build(BuildContext context) {
    switch (layout.arrangement) {
      case HabotMirrorArrangement.tabbed:
        return _TabbedPanes(owner: owner);
      case HabotMirrorArrangement.stacked:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _panes(Axis.vertical),
        );
      case HabotMirrorArrangement.sideBySide:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _panes(Axis.horizontal),
        );
    }
  }

  List<Widget> _panes(Axis axis) => <Widget>[
    Expanded(
      flex: (layout.ratio.evidenceShare * 100).round(),
      child: _Pane(role: HabotPaneRole.evidence, child: owner.evidence),
    ),
    _PanelBar(axis: axis, onCycle: onCycle),
    Expanded(
      flex: (layout.ratio.actionShare * 100).round(),
      child: _Pane(role: HabotPaneRole.action, child: owner.action),
    ),
  ];
}

/// The documented fallback for viewports where a split would starve both
/// panes -- an iPhone SE in landscape, for instance.
class _TabbedPanes extends StatelessWidget {
  const _TabbedPanes({required this.owner});

  final HabotSplitView owner;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          TabBar(
            tabs: <Widget>[
              Tab(text: owner.evidenceLabel),
              Tab(text: owner.actionLabel),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _Pane(role: HabotPaneRole.evidence, child: owner.evidence),
                _Pane(role: HabotPaneRole.action, child: owner.action),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pane extends StatelessWidget {
  const _Pane({required this.role, required this.child});

  final HabotPaneRole role;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: role == HabotPaneRole.evidence ? 'Evidence pane' : 'Action pane',
      container: true,
      child: Padding(
        padding: const EdgeInsets.all(ContextualMirrorSpec.panePadding),
        child: child,
      ),
    );
  }
}

/// The divider, and the double-tap target that cycles the ratio.
class _PanelBar extends StatelessWidget {
  const _PanelBar({required this.axis, required this.onCycle});

  final Axis axis;
  final VoidCallback onCycle;

  @override
  Widget build(BuildContext context) {
    final Color colour = Theme.of(context).colorScheme.outlineVariant;
    return Semantics(
      key: HabotSplitView.panelBarKey,
      label: 'Panel divider. Double tap to change the split.',
      button: true,
      child: GestureDetector(
        onDoubleTap: onCycle,
        behavior: HitTestBehavior.opaque,
        child: axis == Axis.vertical
            ? SizedBox(
                height: ContextualMirrorSpec.panelBarHeight,
                child: Center(child: Divider(color: colour)),
              )
            : SizedBox(
                width: ContextualMirrorSpec.panelBarHeight,
                child: Center(child: VerticalDivider(color: colour)),
              ),
      ),
    );
  }
}

/// Master-detail: a list and the record it selects.
///
/// On a wide viewport both are visible. On a compact one the detail replaces
/// the list, and [onDetailDismissed] is how the caller learns the user went
/// back -- so a screen written against this container behaves correctly on
/// both without knowing which it is on.
class HabotMasterDetail extends StatelessWidget {
  const HabotMasterDetail({
    required this.master,
    required this.detail,
    this.onDetailDismissed,
    this.detailPlaceholder,
    super.key,
  });

  final Widget master;

  /// Null when nothing is selected.
  final Widget? detail;

  final VoidCallback? onDetailDismissed;

  /// Shown in the detail pane on wide viewports when nothing is selected.
  /// Ignored on compact, where an empty detail simply means "show the list".
  final Widget? detailPlaceholder;

  static const double masterFlex = 35;
  static const double detailFlex = 65;

  /// True when this viewport shows both panes at once.
  static bool isTwoPane(double width) =>
      ContextualMirrorSpec.preferredArrangementFor(width) ==
      HabotMirrorArrangement.sideBySide;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (!isTwoPane(width)) {
      return _SinglePane(
        master: master,
        detail: detail,
        onDetailDismissed: onDetailDismissed,
      );
    }
    return Row(
      children: <Widget>[
        Expanded(flex: masterFlex.round(), child: master),
        const SizedBox(width: HabotSpacing.md),
        Expanded(
          flex: detailFlex.round(),
          child: detail ?? detailPlaceholder ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SinglePane extends StatelessWidget {
  const _SinglePane({
    required this.master,
    required this.detail,
    required this.onDetailDismissed,
  });

  final Widget master;
  final Widget? detail;
  final VoidCallback? onDetailDismissed;

  @override
  Widget build(BuildContext context) {
    final Widget current = detail ?? master;
    return PopScope<Object?>(
      canPop: detail == null,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) {
          onDetailDismissed?.call();
        }
      },
      child: AnimatedSwitcher(
        duration: HabotMotionPolicy.resolve(context, HabotMotion.sheetEnter),
        child: KeyedSubtree(
          key: ValueKey<bool>(detail != null),
          child: current,
        ),
      ),
    );
  }
}
