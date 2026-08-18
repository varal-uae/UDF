/// The application shell: the thing that makes the design system an app.
///
/// AISS: GEN-02334-A01 (the navigation surfaces it hosts), GEN-02082-A01 (the
/// router it drives), GEN-00999-A01 (the context it restores), GEN-03437-A01
/// (the offline banner it always shows), SSTLA-012-A01 (the master wrapper it
/// extends).
///
/// Before this batch every screen in the codebase was reachable only from a
/// probe page. The shell is what changes that: destinations, a route table, a
/// remembered context per destination, and one place where the offline banner
/// lives so no screen has to remember to show it.
///
/// The shell is a BODY, not a scaffold. The screen that hosts it owns the one
/// [HabotMasterScaffold] -- which is the executable form of SSTLA-012's
/// poka-yoke, "code linters block views that do not extend the master layout
/// wrapper": a destination supplies content and cannot bring a wrapper of its
/// own, because it never gets the chance.
library;

import 'package:flutter/material.dart';

import '../navigation/adaptive_navigation.dart';
import '../navigation/deep_link_context_manager.dart';
import '../navigation/nav_badge.dart';
import '../navigation/route_table.dart';
import '../navigation/tab_switch_budget.dart';
import '../resilience/connectivity_state.dart';
import '../resilience/offline_banner.dart';
import '../tokens/spacing_tokens.dart';

/// One destination, with the content it shows.
class HabotShellDestination {
  const HabotShellDestination({
    required this.destination,
    required this.builder,
  });

  final HabotDestination destination;

  /// Content only. The shell supplies the scaffold, the header and the banner.
  final WidgetBuilder builder;

  String get route => destination.route;
}

/// The shell.
class HabotAppShell extends StatefulWidget {
  const HabotAppShell({
    required this.destinations,
    required this.router,
    this.monitor,
    this.unread,
    this.budget,
    this.initialLink,
    this.onDestinationChanged,
    super.key,
  }) : assert(
         destinations.length >= 2,
         'A shell with one destination is a screen',
       );

  final List<HabotShellDestination> destinations;
  final HabotRouter router;

  /// Injectable so the gates can drive connectivity, unread counts and the
  /// latency budget without waiting on a network or a clock.
  final HabotConnectivityMonitor? monitor;
  final HabotUnreadCounts? unread;
  final HabotTabSwitchBudget? budget;

  /// A deep link to open on launch, as a notification tap would supply.
  final String? initialLink;

  /// Fires when the visible destination changes, so the hosting screen can
  /// retitle its header without owning the selection state.
  final void Function(HabotShellDestination destination)? onDestinationChanged;

  @override
  State<HabotAppShell> createState() => HabotAppShellState();
}

class HabotAppShellState extends State<HabotAppShell> {
  late final HabotUnreadCounts _unread =
      widget.unread ?? HabotUnreadCounts();
  late final HabotTabSwitchBudget _budget =
      widget.budget ?? HabotTabSwitchBudget();
  int _index = 0;

  /// The context the shell restored for the current destination, if any.
  HabotDeepLinkContext? restoredContext;

  int get selectedIndex => _index;
  HabotTabSwitchBudget get budget => _budget;
  HabotUnreadCounts get unread => _unread;

  String get currentRoute => widget.destinations[_index].route;

  @override
  void initState() {
    super.initState();
    final String? link = widget.initialLink;
    if (link != null) {
      openLink(link);
    }
  }

  /// GEN-02082 + GEN-00999: resolve a link to a destination, restore whatever
  /// this user had open there, and select it.
  void openLink(String link) {
    final HabotRouteMatch matched = widget.router.match(link);
    final int index = widget.destinations.indexWhere(
      (HabotShellDestination d) => d.route == matched.route.path,
    );
    restoredContext = widget.router.resolve(link);
    if (index >= 0) {
      select(index);
    }
  }

  /// Selects a destination, timing the switch against the Step 44 budget and
  /// clearing that destination's unread badge.
  void select(int index) {
    if (index == _index) {
      return;
    }
    final String from = currentRoute;
    final String to = widget.destinations[index].route;
    _budget.begin(from: from, to: to);
    setState(() => _index = index);
    _unread.clear(to);
    widget.onDestinationChanged?.call(widget.destinations[index]);
    // The switch is complete once this frame is rendered; the budget is closed
    // by whoever pumped it, which in a test is the gate and in production is
    // the frame callback.
    WidgetsBinding.instance.addPostFrameCallback((_) => _budget.end());
  }

  @override
  Widget build(BuildContext context) {
    final HabotShellDestination current = widget.destinations[_index];
    return _ShellBody(
      destinations: widget.destinations,
      selectedIndex: _index,
      onSelected: select,
      unread: _unread,
      monitor: widget.monitor,
      content: current.builder(context),
    );
  }
}

class _ShellBody extends StatelessWidget {
  const _ShellBody({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.unread,
    required this.monitor,
    required this.content,
  });

  final List<HabotShellDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onSelected;
  final HabotUnreadCounts unread;
  final HabotConnectivityMonitor? monitor;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: unread,
      builder: (BuildContext context, Widget? _) => HabotAdaptiveNavigation(
        destinations: <HabotDestination>[
          for (final HabotShellDestination d in destinations)
            d.destination.copyWith(unreadCount: unread.countFor(d.route)),
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        body: _Content(monitor: monitor, child: content),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.monitor, required this.child});

  final HabotConnectivityMonitor? monitor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (monitor != null) HabotOfflineBanner(monitor: monitor!),
        if (monitor != null) const SizedBox(height: HabotSpacing.xs),
        Expanded(child: child),
      ],
    );
  }
}

/// The routes the shell knows about, in one place so the router and the
/// destination list cannot disagree about what exists.
class HabotShellRoutes {
  const HabotShellRoutes._();

  static const HabotRoute overview = HabotRoute(
    path: '/overview',
    title: 'Overview',
  );
  static const HabotRoute tasks = HabotRoute(path: '/tasks', title: 'Tasks');
  static const HabotRoute task = HabotRoute(
    path: '/tasks/:id',
    title: 'Task',
    requiresId: true,
  );
  static const HabotRoute components = HabotRoute(
    path: '/components',
    title: 'Components',
  );
  static const HabotRoute settings = HabotRoute(
    path: '/settings',
    title: 'Settings',
  );

  static const List<HabotRoute> all = <HabotRoute>[
    overview,
    tasks,
    task,
    components,
    settings,
  ];

  /// An unrecognised link lands on the overview rather than nowhere.
  static const HabotRoute fallback = overview;

  static HabotRouter router({DeepLinkContextManager? contextManager}) =>
      HabotRouter(
        routes: all,
        fallback: fallback,
        contextManager: contextManager,
      );
}
