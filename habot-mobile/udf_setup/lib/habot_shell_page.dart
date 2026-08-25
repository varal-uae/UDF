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
import 'design_system/notifications/alert_panel.dart';
import 'design_system/notifications/delivery_router.dart';
import 'design_system/notifications/in_app_banner.dart';
import 'design_system/notifications/notification_center.dart';
import 'design_system/notifications/notification_payload.dart';
import 'design_system/notifications/notification_preference_join.dart';
import 'design_system/resilience/connectivity_state.dart';
import 'design_system/shell/app_shell.dart';
import 'design_system/charts/habot_charts.dart';
import 'design_system/dashboard/dashboard_controller.dart';
import 'design_system/dashboard/filter_model.dart';
import 'design_system/dashboard/filter_sheet.dart';
import 'design_system/dashboard/kpi_card.dart';
import 'design_system/dashboard/kpi_grid.dart';
import 'design_system/dashboard/sli_health_view.dart';
import 'design_system/dashboard/summary_strip.dart';
import 'design_system/shell/pane_distribution.dart';
import 'design_system/layout/master_scaffold.dart';
import 'design_system/navigation/contextual_header.dart';
import 'design_system/preferences/notification_preferences.dart';
import 'design_system/preferences/preference_manager.dart';
import 'design_system/forms/field_validation.dart';
import 'design_system/mto/byt_isolation.dart';
import 'design_system/mto/interaction_timer.dart';
import 'design_system/mto/task_queue.dart';
import 'design_system/mto/task_screen.dart';
import 'design_system/mto/worker_task_card.dart';
import 'design_system/notifications/alert_priority.dart';
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

  /// Steps 69-80. Owned here rather than per-screen: an alert panel that is
  /// "global" (FLADE-011-10) and a notification centre that is "universal"
  /// (GEN-02455) cannot be per-destination state.
  final HabotAlertPanelController _alerts = HabotAlertPanelController();
  final HabotBannerController _banners = HabotBannerController();
  final HabotNotificationCenter _centre = HabotNotificationCenter();
  late final HabotPushTokenRegistry _tokens = HabotPushTokenRegistry(
    refresh: () async => 'demo-token',
  );
  late final HabotNotificationPreferenceManager _notificationPreferences =
      HabotNotificationPreferenceManager(
        store: _preferences,
        registry: _tokens,
      );

  /// Steps 81-95. The queue is shell-owned for the same reason the alert panel
  /// is: a task allocated on one destination is still allocated on another.
  final HabotTaskQueue _queue = HabotTaskQueue();
  late final HabotEscalationEngine _escalations = HabotEscalationEngine(
    panel: _alerts,
    preferences: _notificationPreferences,
  );

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
    _queue.dispose();
    _notificationPreferences.dispose();
    _centre.dispose();
    _banners.dispose();
    _alerts.dispose();
    _tokens.dispose();
    _monitor.dispose();
    _preferences.dispose();
    super.dispose();
  }

  /// Every notification the shell shows passes the Step 80 join first. There
  /// is no second path, which is what makes the preference screen mean
  /// something.
  void _present(HabotBannerMessage message) {
    if (!_notificationPreferences.admit(
      id: message.id,
      kind: message.kind,
    )) {
      return;
    }
    _banners.present(message);
    _centre.receive(
      id: message.id,
      kind: message.kind,
      title: message.title,
      body: message.body,
      route: '/settings',
    );
  }

  @override
  Widget build(BuildContext context) {
    return HabotMasterScaffold(
      screenName: HabotShellPage.screenName,
      scrollable: false,
      header: HabotContextualHeader(title: _title, showBack: false),
      // Step 73: the alert layer wraps the whole body. While a critical alert
      // is up nothing beneath it responds -- by construction, not by each
      // screen remembering to check.
      body: HabotAlertPanelLayer(
        controller: _alerts,
        child: HabotAppShell(
          router: _router,
          monitor: _monitor,
          initialLink: widget.initialLink,
          onDestinationChanged: (HabotShellDestination d) =>
              setState(() => _title = d.destination.label),
          destinations: _destinations(context),
        ),
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
            route: '/work',
            label: 'Work',
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment,
          ),
          builder: (BuildContext context) =>
              _WorkContent(queue: _queue, escalations: _escalations),
        ),
        HabotShellDestination(
          destination: const HabotDestination(
            route: '/settings',
            label: 'Settings',
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
          ),
          builder: (BuildContext context) => _SettingsContent(
            preferences: _preferences,
            centre: _centre,
            banners: _banners,
            alerts: _alerts,
            onPresent: _present,
          ),
        ),
      ];
}

/// Steps 51-65: the dashboard, with real content instead of placeholder text.
///
/// The summary strip is pinned outside the scroll view (Step 62), the KPI
/// cards stack on the rule Step 45 already gated (Step 54), tapping a card
/// applies its filter (Step 65), and the filter sheet is the Step 21 bottom
/// sheet rather than a second one (Step 63).
class _OverviewContent extends StatefulWidget {
  const _OverviewContent();

  @override
  State<_OverviewContent> createState() => _OverviewContentState();
}

class _OverviewContentState extends State<_OverviewContent> {
  static const String _facet = 'category';

  late final HabotDashboardController _controller =
      HabotDashboardController(facetKey: _facet);

  static const List<HabotKpi> _kpis = <HabotKpi>[
    HabotKpi(
      id: 'intake',
      label: 'Records in intake',
      value: 148,
      category: HabotMetricCategory.volume,
      filterKey: 'intake',
    ),
    HabotKpi(
      id: 'accuracy',
      label: 'First-pass accuracy',
      value: 96.4,
      previousValue: 94.1,
      category: HabotMetricCategory.rate,
      filterKey: 'accuracy',
    ),
    HabotKpi(
      id: 'latency',
      label: 'Median review time',
      value: 412,
      previousValue: 360,
      category: HabotMetricCategory.latency,
      filterKey: 'latency',
    ),
    HabotKpi(
      id: 'flagged',
      label: 'Flagged for exception',
      value: 3,
      previousValue: 1,
      category: HabotMetricCategory.fault,
      filterKey: 'flagged',
    ),
  ];

  static final List<HabotFilterFacet> _facets = <HabotFilterFacet>[
    HabotFilterFacet(
      key: _facet,
      label: 'Metric category',
      options: <HabotFilterOption>[
        for (final HabotKpi kpi in _kpis)
          HabotFilterOption(value: kpi.filterKey!, label: kpi.label),
      ],
    ),
  ];

  static final HabotChartSeries _trend = HabotChartSeries.fromSparse(
    label: 'First-pass accuracy',
    sparse: const <int, double>{
      0: 91,
      1: 92.5,
      2: 93,
      4: 94.1,
      5: 95.2,
      6: 96.4,
    },
    length: 7,
  );

  static final List<HabotSli> _slis = <HabotSli>[
    HabotSli(
      id: 'submit',
      name: 'Submit round trip',
      objectiveMs: 300,
      history: HabotChartSeries.fromSparse(
        label: 'submit',
        sparse: const <int, double>{0: 280, 1: 291, 2: 305, 3: 288, 4: 274},
        length: 5,
      ),
    ),
    HabotSli(
      id: 'search',
      name: 'Search results',
      objectiveMs: 350,
      history: HabotChartSeries.fromSparse(
        label: 'search',
        sparse: const <int, double>{0: 402, 1: 418, 2: 441, 3: 470, 4: 512},
        length: 5,
      ),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final HabotFilterSelection? applied = await HabotFilterSheet.show(
      context: context,
      facets: _facets,
      selection: _controller.selection,
    );
    if (applied != null) {
      _controller.applyFromSheet(applied);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        final List<HabotKpi> visible = _controller.selection
            .apply<HabotKpi>(_kpis, (HabotKpi k, String _) => k.filterKey ?? '');
        return HabotDashboardSection(
          kpis: _kpis,
          scrollingContent: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _controller.selection.isEmpty
                          ? 'All metrics'
                          : '${visible.length} of ${_kpis.length} metrics',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _openFilters,
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                  ),
                ],
              ),
              const SizedBox(height: HabotSpacing.xs),
              HabotKpiGrid(
                kpis: visible,
                onKpiTapped: _controller.applyFromKpi,
              ),
              const SizedBox(height: HabotSpacing.md),
              Text(
                'First-pass accuracy, last 7 days',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: HabotSpacing.xs),
              HabotInteractiveChart(series: _trend),
              const SizedBox(height: HabotSpacing.md),
              Text(
                'Service level indicators',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: HabotSpacing.xs),
              HabotSliHealthView(indicators: _slis),
            ],
          ),
        );
      },
    );
  }
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

/// Steps 81-95: the MTO worker queue.
///
/// The list is a summary; the crop itself only ever renders inside the task
/// chassis, on a pushed route. That is deliberate -- a list of thumbnails
/// would put nine crops on one screen and undo Step 81.
class _WorkContent extends StatefulWidget {
  const _WorkContent({required this.queue, required this.escalations});

  final HabotTaskQueue queue;
  final HabotEscalationEngine escalations;

  @override
  State<_WorkContent> createState() => _WorkContentState();
}

class _WorkContentState extends State<_WorkContent> {
  final Map<String, HabotInteractionTimer> _timers =
      <String, HabotInteractionTimer>{};

  @override
  void initState() {
    super.initState();
    if (widget.queue.tasks.isEmpty) {
      _seed();
    }
  }

  @override
  void dispose() {
    for (final HabotInteractionTimer timer in _timers.values) {
      timer.dispose();
    }
    super.dispose();
  }

  /// Demo deliveries. Every one goes through the Step 81 contract, so a crop
  /// the backend has not stamped never reaches this list.
  void _seed() {
    const List<List<String>> seeds = <List<String>>[
      <String>['byt-1', 'Read the invoice total', 'digits and a decimal point'],
      <String>['byt-2', 'Read the issue date', 'YYYY-MM-DD'],
      <String>['byt-3', 'Read the account number', 'digits only'],
    ];
    final DateTime now = DateTime.now();
    for (int i = 0; i < seeds.length; i++) {
      const HabotBoundingBox box = HabotBoundingBox(
        left: 120,
        top: 240,
        width: 640,
        height: 180,
        sourceWidth: 2480,
        sourceHeight: 3508,
      );
      final HabotByt? byt = HabotByt.fromDelivery(
        id: seeds[i][0],
        box: box,
        snippet: Uri.parse(
          'https://assets.habot.internal/crops/${seeds[i][0]}.png'
          '?crop=${HabotCropContract.signatureFor(box)}',
        ),
        prompt: seeds[i][1],
        expectedFormat: seeds[i][2],
      );
      if (byt == null) {
        continue;
      }
      widget.queue.enqueue(
        HabotMtoTask(
          byt: byt,
          priority: HabotAlertPriority.values[i % 3],
          queuedAt: now.subtract(Duration(minutes: i * 3)),
        ),
      );
    }
  }

  void _open(BuildContext context, HabotMtoTask task) {
    final HabotInteractionTimer timer = _timers.putIfAbsent(
      task.id,
      () => HabotInteractionTimer(taskId: task.id),
    )..start();
    widget.queue.allocate('me');
    // Opening a task is also when the shell notices anything else has gone
    // past its SLA. Step 95's engine raises through the Step 73 panel.
    widget.escalations.sweep(widget.queue, DateTime.now());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => HabotTaskScreen(
          byt: task.byt,
          cde: HabotCde.quantity,
          imageBuilder: _demoSnippet,
          onSubmit: (String answer) {
            timer.stop();
            widget.queue.complete(task.id);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  /// The demo has no asset service, so the evidence pane renders a stand-in
  /// at the crop's own aspect ratio rather than a broken image.
  Widget _demoSnippet(BuildContext context, HabotByt byt) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: SizedBox(
      width: byt.box.width,
      height: byt.box.height,
      child: Center(
        child: Text(
          'Cropped evidence for ${byt.id}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.queue,
      builder: (BuildContext context, Widget? _) {
        final List<HabotMtoTask> ranked = widget.queue.ranked();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '${widget.queue.waitingCount} waiting - '
              '${widget.queue.inProgressCount} in progress',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: HabotSpacing.xs),
            for (final HabotMtoTask task in ranked)
              Padding(
                padding: const EdgeInsets.only(bottom: HabotSpacing.xs),
                child: HabotWorkerTaskCard(
                  task: task,
                  timer: _timers[task.id],
                  onOpen: () => _open(context, task),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The Steps 21-35 surfaces, now a destination rather than the only way in.
class _ComponentsContent extends StatelessWidget {
  const _ComponentsContent();

  @override
  Widget build(BuildContext context) => const SurfacesProbeBody();
}

/// Steps 66-80, reachable: the preference screen from Step 50, the in-app
/// banner slot from Step 69, and the notification centre from Step 75.
class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.preferences,
    required this.centre,
    required this.banners,
    required this.alerts,
    required this.onPresent,
  });

  final PreferenceStore preferences;
  final HabotNotificationCenter centre;
  final HabotBannerController banners;
  final HabotAlertPanelController alerts;
  final void Function(HabotBannerMessage message) onPresent;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HabotInAppBanner(controller: banners),
          const SizedBox(height: HabotSpacing.xs),
          NotificationPreferenceView(store: preferences),
          const SizedBox(height: HabotSpacing.md),
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: HabotSpacing.xs),
          Row(
            children: <Widget>[
              // Both routed through the Step 80 join, so switching "Offers and
              // product news" off in the panel above actually silences the
              // first one. That is the whole point of the join.
              TextButton(
                onPressed: () => onPresent(
                  HabotBannerMessage(
                    id: 'demo-${DateTime.now().microsecondsSinceEpoch}',
                    kind: HabotNotificationKind.informational,
                    title: 'Product news',
                    body: 'A new dashboard filter is available.',
                  ),
                ),
                child: const Text('Send promo'),
              ),
              TextButton(
                onPressed: () => alerts.raise(
                  const HabotSystemAlert(
                    id: 'demo-breach',
                    severity: HabotAlertSeverity.critical,
                    headline: 'Manual override in effect',
                    detail: 'A P1 architectural breach is being investigated.',
                  ),
                ),
                child: const Text('Raise P1'),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: centre,
            builder: (BuildContext context, Widget? _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  centre.entries.isEmpty
                      ? 'Nothing here yet.'
                      : '${centre.unreadCount} unread of '
                            '${centre.entries.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                for (final HabotNotificationEntry entry in centre.entries)
                  ListTile(
                    title: Text(entry.title),
                    subtitle: Text(entry.body),
                    onTap: () => centre.markRead(entry.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
