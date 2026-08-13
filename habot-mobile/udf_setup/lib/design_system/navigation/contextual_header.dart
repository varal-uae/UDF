/// AISS: ANSA-012-A01 -- "Establish Contextual Navigation Header Framework."
///
/// 4 Substeps:
///   1. "Cap maximum string titles to protect horizontal grid boundaries."
///   2. "Embed standard high-contrast action vector icons for core paths."
///   3. "Inject scroll-listening hooks to adjust header elevations dynamically."
///   4. "Link the master back arrow component to secure state management targets."
///
/// Mobile-First rows:
///   UX  : "Hide excessive, low-priority shortcut items inside unified trailing
///          overflow menus on tight displays."
///   UI  : "Align textual header targets strictly to standard left grid baselines."
///   UXI : "Compress header spacing scales smoothly as parent view boundaries contract."
///   UII : "Secure the top app container height to an unyielding 64dp profile line."
library;

import 'package:flutter/material.dart';

import '../interaction/touch_target.dart';
import '../surfaces/bottom_sheet.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';
import 'back_navigation.dart';

/// One action in the header. Actions beyond [HabotContextualHeader.maxVisibleActions]
/// collapse into the trailing overflow menu on tight displays.
@immutable
class HabotHeaderAction {
  const HabotHeaderAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.priority = 0,
  });

  final IconData icon;

  /// Also used as the tooltip and the semantics label -- a header icon with no
  /// label is unusable with a screen reader.
  final String label;

  final VoidCallback onPressed;

  /// Higher wins a visible slot. Ties keep declaration order.
  final int priority;
}

/// Truncation policy for header titles (substep 1).
///
/// Pure and static so it can be unit-tested without building a widget.
class HeaderTitlePolicy {
  const HeaderTitlePolicy._();

  static const int maxChars = HabotDensity.maxHeaderTitleChars;
  static const String ellipsis = '\u2026';

  /// Caps [title] so it cannot push past the horizontal grid boundary.
  static String cap(String title) {
    final String trimmed = title.trim();
    if (trimmed.length <= maxChars) {
      return trimmed;
    }
    // Cut on a word boundary where one exists in the last quarter of the
    // budget, otherwise hard-cut. Either way the result is never longer than
    // maxChars including the ellipsis.
    final int budget = maxChars - 1;
    final String slice = trimmed.substring(0, budget);
    final int lastSpace = slice.lastIndexOf(' ');
    final String base = lastSpace >= (budget * 3) ~/ 4
        ? slice.substring(0, lastSpace)
        : slice;
    return '${base.trimRight()}$ellipsis';
  }

  static bool isWithinBounds(String title) => cap(title).length <= maxChars;
}

/// Resolves the elevation of the header from scroll offset (substep 3).
class HeaderElevationPolicy {
  const HeaderElevationPolicy._();

  /// Scroll offset past which the header lifts off the content.
  static const double liftThreshold = 4;

  static HabotElevationLevel levelFor(double scrollOffset) =>
      scrollOffset > liftThreshold
      ? HabotElevationLevel.level2
      : HabotElevationLevel.level0;

  static double dpFor(double scrollOffset) =>
      HabotElevation.dp[levelFor(scrollOffset)]!;
}

/// The standardised top app bar. Every screen uses this; none builds its own.
class HabotContextualHeader extends StatefulWidget
    implements PreferredSizeWidget {
  const HabotContextualHeader({
    required this.title,
    this.actions = const <HabotHeaderAction>[],
    this.showBack = true,
    this.backNavigator,
    this.scrollController,
    super.key,
  });

  final String title;
  final List<HabotHeaderAction> actions;
  final bool showBack;

  /// Injectable so the gate can drive the double-tap guard deterministically.
  final HabotBackNavigator? backNavigator;

  /// When supplied, the header listens for scroll and lifts its elevation.
  final ScrollController? scrollController;

  /// Visible action slots on a tight display. Everything else goes to overflow.
  static const int maxVisibleActionsCompact = 2;
  static const int maxVisibleActionsWide = 4;

  static int maxVisibleActionsFor(double width) =>
      HabotGrid.windowClassFor(width) == HabotWindowClass.compact
      ? maxVisibleActionsCompact
      : maxVisibleActionsWide;

  /// UI implementation row: "an unyielding 64dp profile line".
  @override
  Size get preferredSize => const Size.fromHeight(HabotDensity.appBarHeight);

  @override
  State<HabotContextualHeader> createState() => _HabotContextualHeaderState();
}

class _HabotContextualHeaderState extends State<HabotContextualHeader> {
  late final HabotBackNavigator _back;
  final Stopwatch _clock = Stopwatch()..start();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _back = widget.backNavigator ?? HabotBackNavigator();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _clock.stop();
    super.dispose();
  }

  void _onScroll() {
    final double offset = widget.scrollController?.offset ?? 0;
    final bool wasLifted =
        HeaderElevationPolicy.levelFor(_scrollOffset) !=
        HabotElevationLevel.level0;
    final bool isLifted =
        HeaderElevationPolicy.levelFor(offset) != HabotElevationLevel.level0;
    _scrollOffset = offset;
    // Only rebuild when the elevation actually changes -- a setState on every
    // scroll frame would be exactly the "full component reflow" TTMCS-004
    // spent a gate avoiding.
    if (wasLifted != isLifted) {
      setState(() {});
    }
  }

  void _handleBack() {
    _back.maybePop(Navigator.of(context), _clock.elapsed);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.sizeOf(context).width;
    final int visibleSlots = HabotContextualHeader.maxVisibleActionsFor(width);

    final List<HabotHeaderAction> ordered =
        <HabotHeaderAction>[...widget.actions]..sort(
          (HabotHeaderAction a, HabotHeaderAction b) =>
              b.priority.compareTo(a.priority),
        );
    final List<HabotHeaderAction> visible = ordered.take(visibleSlots).toList();
    final List<HabotHeaderAction> overflow = ordered
        .skip(visibleSlots)
        .toList();

    return AppBar(
      toolbarHeight: HabotDensity.appBarHeight,
      elevation: HeaderElevationPolicy.dpFor(_scrollOffset),
      scrolledUnderElevation: HeaderElevationPolicy.dpFor(_scrollOffset),
      // UI decision: align the title to the left grid baseline.
      centerTitle: false,
      titleSpacing: widget.showBack ? 0 : HabotGrid.outerMargin,
      leading: widget.showBack
          ? HabotTouchTarget(
              semanticLabel: 'Back',
              onPressed: _handleBack,
              child: const Icon(Icons.arrow_back),
            )
          : null,
      title: Text(
        HeaderTitlePolicy.cap(widget.title),
        style: theme.textTheme.titleLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
        for (final HabotHeaderAction action in visible)
          HabotTouchTarget(
            semanticLabel: action.label,
            detail: action.label,
            onPressed: action.onPressed,
            child: Icon(action.icon),
          ),
        if (overflow.isNotEmpty)
          HabotTouchTarget(
            semanticLabel: 'More actions',
            onPressed: () => HeaderOverflowSheet.show(context, overflow),
            child: const Icon(Icons.more_vert),
          ),
        const SizedBox(width: HabotSpacing.xs),
      ],
    );
  }
}

/// MUFCE-028: the trailing overflow menu, as a bottom drawer.
///
/// It used to be a Material popup menu button, which the framework always
/// wraps in a tooltip -- a hover artefact this step exists to remove, and one
/// the API gives no way to switch off. A sheet is also the better mobile
/// surface: the
/// items land under the thumb rather than at the top corner the finger just
/// left.
class HeaderOverflowSheet {
  const HeaderOverflowSheet._();

  static Future<void> show(
    BuildContext context,
    List<HabotHeaderAction> actions,
  ) {
    return HabotBottomSheet.show<void>(
      context: context,
      title: 'More actions',
      draggable: false,
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final HabotHeaderAction action in actions)
            _OverflowRow(action: action),
        ],
      ),
    );
  }
}

class _OverflowRow extends StatelessWidget {
  const _OverflowRow({required this.action});

  final HabotHeaderAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        action.onPressed();
      },
      child: SizedBox(
        height: HabotDensity.minTouchTarget,
        child: Row(
          children: <Widget>[
            Icon(action.icon),
            const SizedBox(width: HabotSheet.contentGap),
            Text(action.label, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
