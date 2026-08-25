/// AISS: SSELC-016-A01 -- "Design the Universal Split-Screen Byt Isolation
/// Interface."
/// Setup Step Description: "Design adaptive grid templates displaying EVIDENCE
/// WINDOWS ABOVE INPUT FIELDS on compact views."
/// Data Requirement: "Stack visual layout components vertically when viewport
/// boundaries shift below 600dp metrics."
/// Metric: Design System Token Adoption Rate -- Floor 0.85, Optimal 0.97,
///         Ceiling 1.0.
///
/// CONTAMINATED ROW, RECORDED: ten columns describe signed-URL generation for
/// cloud storage -- Why This Matters ("Persistent or long-lived asset
/// hyperlinks invite link interception attacks"), What Must Be Standardized
/// ("Hardcode a maximum 10-minute validity boundary directly into secure link
/// generator settings"), Expected Output ("A confirmed cloud storage signature
/// configuration contract"), Completion Measures, Poka-Yoke ("Link generation
/// operations fail automatically if incoming configuration files omit unique
/// trace ID strings"), Self-Chasing, UX Translation, Dashboard Implication,
/// Atomic Reusability and Common Library. None are gated.
///
/// The Setup Step and its Description ARE the requirement, and they line up
/// exactly with the Contextual Mirror from Steps 36-38: evidence pane, action
/// pane, stacked below 600dp. So this file CONFIGURES `HabotSplitView`; it
/// does not add a second split container. A gate asserts the stacking
/// breakpoint is the Step 7 token rather than a second 600.
///
/// AISS: GEN-00610-A01 -- "Implement Context-Isolated Split-Screen UI for
/// Mobile MTOI Exception Handling."
/// Setup Step Description: "STRIP PERIPHERAL NAVIGATION ELEMENTS, DRAWERS, AND
/// HEADERS from the scaffold view."
/// Metric: Peripheral Element Count -- Floor 0, Optimal 0, Ceiling 0.
///
/// The most directly gateable metric in the batch: a zero-tolerance count.
/// [HabotPeripheralCensus] names the widget types that count as peripheral and
/// the gate walks the rendered tree of a real task screen asserting none of
/// them exists. Note this repeats Step 81's own UI Implementation column --
/// "hide global navigation (app bars/bottom nav) during the task to maximise
/// focus" -- from a different row, so two rows agree about it.
///
/// AISS: GEN-04042-A01 -- "Configure the layout engine to VALIDATE that
/// incoming task screens WRAP CONTENT INSIDE the Master Split-Screen
/// component."
/// Metric: Layout Wrapper Validation Rate -- Floor 1.0, Optimal 1.0.
///
/// This is RCGLA-018 (Step 8) for task screens, so it is enforced the same
/// way: content that is not inside the chassis cannot render as if it were.
/// [HabotTaskContent] looks for the chassis above it, and when there is none
/// it records a violation and renders a visible notice instead of the task --
/// because a task screen that silently renders unwrapped is exactly what the
/// validation rate is supposed to catch.
library;

import 'package:flutter/material.dart';

import '../layout/master_scaffold.dart';
import '../navigation/adaptive_navigation.dart';
import '../navigation/contextual_header.dart';
import '../shell/adaptive_panes.dart';
import '../shell/contextual_mirror.dart';
import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// GEN-00610: what counts as a peripheral element.
///
/// A closed list, so the count is a count over something named rather than a
/// judgement about what "peripheral" means on the day.
class HabotPeripheralCensus {
  const HabotPeripheralCensus._();

  /// Floor, Optimal and Ceiling are all $0$ in the sheet. One constant.
  static const int allowedCount = 0;

  /// Framework chrome plus this app's own navigation and header components.
  /// Both halves matter: a task screen that avoided `NavigationBar` but kept
  /// `HabotAdaptiveNavigation` would pass a naive scan and fail the intent.
  static final List<Type> peripheralTypes = <Type>[
    NavigationBar,
    NavigationRail,
    BottomNavigationBar,
    Drawer,
    AppBar,
    TabBar,
    HabotAdaptiveNavigation,
    HabotContextualHeader,
  ];

  static bool isPeripheral(Widget widget) =>
      peripheralTypes.contains(widget.runtimeType);

  static int countIn(Iterable<Widget> widgets) =>
      widgets.where(isPeripheral).length;

  static List<String> namesIn(Iterable<Widget> widgets) => widgets
      .where(isPeripheral)
      .map((Widget w) => w.runtimeType.toString())
      .toList();
}

/// GEN-04042: the validation ledger behind the Layout Wrapper Validation Rate.
class HabotTaskLayoutRegistry {
  const HabotTaskLayoutRegistry._();

  static final List<String> _wrapped = <String>[];
  static final List<String> _unwrapped = <String>[];

  static List<String> get wrapped => List<String>.unmodifiable(_wrapped);
  static List<String> get unwrapped => List<String>.unmodifiable(_unwrapped);

  static void recordWrapped(String screenName) => _wrapped.add(screenName);

  static void recordUnwrapped(String screenName) => _unwrapped.add(screenName);

  static void reset() {
    _wrapped.clear();
    _unwrapped.clear();
  }

  /// Metric: Layout Wrapper Validation Rate. Floor, Optimal and Ceiling are
  /// all 1.0, so anything below is a failure rather than a slipping average.
  static double get validationRate {
    final int total = _wrapped.length + _unwrapped.length;
    return total == 0 ? 1 : _wrapped.length / total;
  }

  static int get checkedCount => _wrapped.length + _unwrapped.length;
}

/// Marks the subtree as being inside the task chassis. Private constructor:
/// only [HabotTaskChassis] can put one in the tree, so its presence is proof
/// of wrapping rather than a claim about it.
class _TaskChassisScope extends InheritedWidget {
  const _TaskChassisScope({required this.screenName, required super.child});

  final String screenName;

  static _TaskChassisScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TaskChassisScope>();

  @override
  bool updateShouldNotify(_TaskChassisScope oldWidget) =>
      oldWidget.screenName != screenName;
}

/// SSELC-016 + GEN-00610: the universal task chassis.
///
/// Evidence above input on compact, side by side when there is room -- both
/// decided by `ContextualMirrorSpec`, never by the caller. There is no
/// `showNavigation` parameter and no `header` parameter, which is how the
/// peripheral count stays at zero without anyone remembering.
class HabotTaskChassis extends StatelessWidget {
  const HabotTaskChassis({
    required this.screenName,
    required this.evidence,
    required this.action,
    super.key,
  });

  /// Registered with the Step 8 screen inventory, exactly as every other
  /// screen in the app is.
  final String screenName;

  /// The crop. Step 85's viewport goes here.
  final Widget evidence;

  /// The one input and its submit. Step 91's content goes here.
  final Widget action;

  static const Key chassisKey = Key('habot.mto.chassis');

  /// The Data Requirement's "below 600dp" IS the Step 7 medium breakpoint.
  /// Read, not restated.
  static const double stackBelow = HabotGrid.breakpointMedium;

  /// Compact stacks vertically with evidence first; the arrangement comes from
  /// the blueprint so a task screen and a dashboard agree about what a narrow
  /// window means.
  static HabotMirrorArrangement arrangementFor(double width) =>
      ContextualMirrorSpec.preferredArrangementFor(width);

  static bool stacksAt(double width) =>
      arrangementFor(width) == HabotMirrorArrangement.stacked;

  @override
  Widget build(BuildContext context) {
    HabotTaskLayoutRegistry.recordWrapped(screenName);
    return HabotMasterScaffold(
      key: chassisKey,
      screenName: screenName,
      scrollable: false,
      // No header, no footer, no floating action: GEN-00610's peripheral
      // count is zero because there is nowhere to put a peripheral element.
      body: _TaskChassisScope(
        screenName: screenName,
        child: HabotSplitView(
          evidence: evidence,
          action: action,
          evidenceLabel: 'Evidence',
          actionLabel: 'Your answer',
        ),
      ),
    );
  }
}

/// GEN-04042: content that must be inside the chassis.
///
/// Wrap the action half of a task screen in this. If it finds no chassis above
/// it, the validation rate drops and the worker sees a notice rather than a
/// task presented as though it were properly isolated.
class HabotTaskContent extends StatelessWidget {
  const HabotTaskContent({
    required this.screenName,
    required this.child,
    super.key,
  });

  final String screenName;
  final Widget child;

  static const Key unwrappedKey = Key('habot.mto.unwrapped');

  static const String unwrappedMessage =
      'This task cannot be shown here. It was opened outside the isolated '
      'task layout, so the evidence around it has not been checked.';

  @override
  Widget build(BuildContext context) {
    final _TaskChassisScope? scope = _TaskChassisScope.maybeOf(context);
    if (scope == null) {
      HabotTaskLayoutRegistry.recordUnwrapped(screenName);
      return _UnwrappedNotice(screenName: screenName);
    }
    return child;
  }
}

class _UnwrappedNotice extends StatelessWidget {
  const _UnwrappedNotice({required this.screenName});

  final String screenName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      key: HabotTaskContent.unwrappedKey,
      liveRegion: true,
      label: HabotTaskContent.unwrappedMessage,
      container: true,
      excludeSemantics: true,
      child: ColoredBox(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(HabotSpacing.md),
          child: Text(
            HabotTaskContent.unwrappedMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}
