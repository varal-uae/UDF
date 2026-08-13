/// The app's root screen, and the first one in this codebase that is not a
/// probe.
///
/// It owns the single [HabotMasterScaffold] (RCGLA-018, Step 8) and hands its
/// body to [HabotAppShell] (Steps 36-48), which supplies the navigation
/// surface, the offline banner and the current destination's content.
///
/// The two probe pages from earlier batches are still reachable -- they are
/// destinations here rather than the only way in.
library;

import 'package:flutter/material.dart';

import 'data_entry_probe_page.dart';
import 'design_system/navigation/adaptive_navigation.dart';
import 'design_system/navigation/route_table.dart';
import 'design_system/resilience/connectivity_state.dart';
import 'design_system/shell/app_shell.dart';
import 'design_system/shell/dashboard_grid.dart';
import 'design_system/shell/pane_distribution.dart';
import 'design_system/layout/master_scaffold.dart';
import 'design_system/navigation/contextual_header.dart';
import 'design_system/preferences/notification_preferences.dart';
import 'design_system/preferences/preference_manager.dart';
import 'design_system/shell/adaptive_panes.dart';
import 'design_system/tokens/spacing_tokens.dart';
import 'surfaces_probe_page.dart';

/// The root screen.
class HabotShellPage extends StatefulWidget {
  const HabotShellPage({this.initialLink, super.key});

  /// A deep link to open on launch, as a notification tap supplies.
  final String? initialLink;

  /// Screen name registered with the RCGLA-018 layout audit.
  static const String screenName = 'HabotShellPage';

  @override
  State<HabotShellPage> createState() => _HabotShellPageState();
}

class _HabotShellPageState extends State<HabotShellPage> {
  late final PreferenceStore _preferences = PreferenceStore(
    writer: _writePreference,
  );
  late final HabotConnectivityMonitor _monitor = HabotConnectivityMonitor(
    poll: _poll,
  );
  final HabotRouter _router = HabotShellRoutes.router();
  String _title = 'Overview';

  /// Stand-in for the real backend. The shell is gated on how it behaves when
  /// this succeeds and when it does not, never on what it talks to.
  Future<bool> _poll() async => true;

  Future<HabotPreferenceWriteResult> _writePreference(
    HabotPreferenceColumn column,
    bool value,
  ) async => HabotPreferenceWriteResult.written;

  @override
  void dispose() {
    _monitor.dispose();
    _preferences.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HabotMasterScaffold(
      screenName: HabotShellPage.screenName,
      scrollable: false,
      header: HabotContextualHeader(title: _title, showBack: false),
      body: HabotAppShell(
        router: _router,
        monitor: _monitor,
        initialLink: widget.initialLink,
        onDestinationChanged: (HabotShellDestination d) =>
            setState(() => _title = d.destination.label),
        destinations: _destinations(context),
      ),
    );
  }

  List<HabotShellDestination> _destinations(BuildContext context) =>
      <HabotShellDestination>[
        HabotShellDestination(
          destination: const HabotDestination(
            route: '/overview',
            label: 'Overview',
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
          ),
          builder: (BuildContext context) => const _OverviewContent(),
        ),
        HabotShellDestination(
          destination: const HabotDestination(
            route: '/tasks',
            label: 'Tasks',
            icon: Icons.checklist_outlined,
            selectedIcon: Icons.checklist,
          ),
          builder: (BuildContext context) => const _TasksContent(),
        ),
        HabotShellDestination(
          destination: const HabotDestination(
            route: '/components',
            label: 'Components',
            icon: Icons.widgets_outlined,
            selectedIcon: Icons.widgets,
          ),
          builder: (BuildContext context) => const _ComponentsContent(),
        ),
        HabotShellDestination(
          destination: const HabotDestination(
            route: '/settings',
            label: 'Settings',
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
          ),
          builder: (BuildContext context) =>
              NotificationPreferenceView(store: _preferences),
        ),
      ];
}

/// GEN-00022 / SSTLA-018: the dashboard, stacking to one column on a phone and
/// a 2x2 grid once there is room.
class _OverviewContent extends StatelessWidget {
  const _OverviewContent();

  @override
  Widget build(BuildContext context) {
    return HabotCommandGrid(
      completed: const <String>{'intake'},
      sections: <HabotCommandSection>[
        HabotCommandSection(
          id: 'intake',
          title: 'Intake',
          child: Text('12 waiting', style: _value(context)),
        ),
        HabotCommandSection(
          id: 'review',
          title: 'Review',
          requires: const <String>{'intake'},
          child: Text('4 waiting', style: _value(context)),
        ),
        HabotCommandSection(
          id: 'release',
          title: 'Release',
          requires: const <String>{'review'},
          child: Text('locked', style: _value(context)),
        ),
        HabotCommandSection(
          id: 'archive',
          title: 'Archive',
          requires: const <String>{'release'},
          child: Text('locked', style: _value(context)),
        ),
      ],
    );
  }

  TextStyle? _value(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;
}

/// SSTLA-012 / SSTLA-010: the Contextual Mirror with its pinned metrics.
class _TasksContent extends StatelessWidget {
  const _TasksContent();

  @override
  Widget build(BuildContext context) {
    return HabotSplitView(
      evidence: HabotPinnedMetrics(
        metrics: const <HabotPinnedMetric>[
          HabotPinnedMetric(label: 'Batch', value: 'B-2026-08'),
          HabotPinnedMetric(label: 'Records', value: '148'),
          HabotPinnedMetric(label: 'Flagged', value: '3'),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < 12; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: HabotSpacing.xs),
                child: Text('Source line ${i + 1}'),
              ),
          ],
        ),
      ),
      action: const DataEntryProbeBody(),
    );
  }
}

/// The Steps 21-35 surfaces, now a destination rather than the only way in.
class _ComponentsContent extends StatelessWidget {
  const _ComponentsContent();

  @override
  Widget build(BuildContext context) => const SurfacesProbeBody();
}
