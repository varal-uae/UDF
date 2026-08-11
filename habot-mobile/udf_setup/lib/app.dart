/// AISS: TTMCS-001-A01 -- the global theme configuration adapter, instantiated
/// once at the root of the widget tree.
///
/// The probe screen below exercises every primitive Steps 1-10 produced, so
/// `flutter run` demonstrates them and the widget gates have something real to
/// pump. It is scaffolding, not product UI.
library;

import 'package:flutter/material.dart';

import 'design_system/interaction/touch_target.dart';
import 'design_system/layout/fluid_container.dart';
import 'design_system/layout/grid_wireframe.dart';
import 'design_system/layout/master_scaffold.dart';
import 'design_system/navigation/contextual_header.dart';
import 'design_system/theme/habot_theme.dart';
import 'design_system/theme/habot_theme_scope.dart';
import 'design_system/theme/theme_controller.dart';
import 'design_system/tokens/grid_tokens.dart';
import 'design_system/tokens/spacing_tokens.dart';

/// Root of the Habot mobile client.
///
/// Owns exactly one [HabotThemeController] and hands it to [MaterialApp] via
/// [HabotThemeScope]. No other widget builds a [ThemeData].
class HabotApp extends StatefulWidget {
  const HabotApp({this.controller, super.key});

  /// Injectable so gates can drive theme state without touching the OS.
  final HabotThemeController? controller;

  @override
  State<HabotApp> createState() => _HabotAppState();
}

class _HabotAppState extends State<HabotApp> {
  late final HabotThemeController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? HabotThemeController();
    _controller.startListening();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    } else {
      _controller.stopListening();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HabotThemeScope(
      notifier: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          return MaterialApp(
            title: 'Habot',
            debugShowCheckedModeBanner: false,
            theme: HabotTheme.light(),
            darkTheme: HabotTheme.dark(),
            themeMode: _controller.mode,
            home: const DesignSystemProbePage(),
          );
        },
      ),
    );
  }
}

/// Exercises the theme, grid, layout boundary, master scaffold, contextual
/// header and touch-target framework in one screen.
class DesignSystemProbePage extends StatefulWidget {
  const DesignSystemProbePage({super.key});

  /// Screen name registered with the RCGLA-018 layout audit.
  static const String screenName = 'DesignSystemProbePage';

  @override
  State<DesignSystemProbePage> createState() => _DesignSystemProbePageState();
}

class _DesignSystemProbePageState extends State<DesignSystemProbePage> {
  final ScrollController _scrollController = ScrollController();
  bool _wireframe = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.sizeOf(context).width;
    final HabotThemeController controller = HabotThemeScope.of(context);

    return GridWireframeOverlay(
      enabled: _wireframe,
      child: HabotMasterScaffold(
        screenName: DesignSystemProbePage.screenName,
        header: HabotContextualHeader(
          title: 'Habot Design System Foundations',
          showBack: false,
          scrollController: _scrollController,
          actions: <HabotHeaderAction>[
            HabotHeaderAction(
              icon: controller.isDark ? Icons.dark_mode : Icons.light_mode,
              label: 'Theme mode: ${controller.mode.name}',
              priority: 3,
              onPressed: () => HabotThemeScope.read(context).toggle(),
            ),
            HabotHeaderAction(
              icon: Icons.grid_on,
              label: 'Toggle grid wireframe',
              priority: 2,
              onPressed: () => setState(() => _wireframe = !_wireframe),
            ),
            HabotHeaderAction(
              icon: Icons.straighten,
              label: 'Measurements',
              onPressed: () {},
            ),
            HabotHeaderAction(
              icon: Icons.accessibility_new,
              label: 'Accessibility report',
              onPressed: () {},
            ),
          ],
        ),
        body: HabotFluidContainer(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Text('Grid decision (SSTLA-004)', style: theme.textTheme.titleMedium),
            const GridDecisionReadout(),
            Text('Column matrix (RCGLA-032)', style: theme.textTheme.titleMedium),
            HabotColumnMatrix(
              children: const <HabotGridSpan>[
                HabotGridSpan(span: 2, child: _ProbeCard(label: 'span 2')),
                HabotGridSpan(span: 2, child: _ProbeCard(label: 'span 2')),
                HabotGridSpan(
                  span: HabotGrid.compactColumns,
                  child: _ProbeCard(label: 'span 4'),
                ),
              ],
            ),
            Text('Touch targets (TTMAC-011)', style: theme.textTheme.titleMedium),
            HabotTouchRow(
              children: <Widget>[
                HabotTouchTarget(
                  semanticLabel: 'Approve',
                  onPressed: () {},
                  child: const Icon(Icons.check),
                ),
                HabotTouchTarget(
                  semanticLabel: 'Reject',
                  onPressed: () {},
                  child: const Icon(Icons.close),
                ),
                HabotTouchTarget(
                  semanticLabel: 'Flag for review',
                  onPressed: () {},
                  child: const Icon(Icons.flag_outlined),
                ),
              ],
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Token-styled input'),
            ),
            FilledButton(
              onPressed: () {},
              child: const Text('Primary action'),
            ),
            SizedBox(height: width),
          ],
        ),
      ),
    );
  }
}

class _ProbeCard extends StatelessWidget {
  const _ProbeCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HabotSpacing.md),
        child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
