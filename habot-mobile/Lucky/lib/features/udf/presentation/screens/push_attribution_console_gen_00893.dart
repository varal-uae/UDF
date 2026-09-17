// GEN-00893 — Screen: Mobile engineering console for push campaign attribution & in-app engagement loop.
// M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).

import 'package:flutter/material.dart';

import '../models/push_attribution_event_gen_00893.dart';
import '../models/push_attribution_metric_gen_00893.dart';
import 'controllers/push_attribution_controller_gen_00893.dart';
import 'widgets/push_attribution_kpi_card_gen_00893.dart';
import 'widgets/push_attribution_status_card_gen_00893.dart';

/// Read-only engineering console screen for GEN-00893.
class PushAttributionConsoleScreen extends StatefulWidget {
  const PushAttributionConsoleScreen({super.key});

  @override
  State<PushAttributionConsoleScreen> createState() =>
      _PushAttributionConsoleScreenState();
}

class _PushAttributionConsoleScreenState
    extends State<PushAttributionConsoleScreen> {
  static const double _mobileBreakpoint = 600;
  static const double _desktopBreakpoint = 840;

  final PushAttributionController _controller = PushAttributionController();
  final EventDispatchLatencyMetric _metric = const EventDispatchLatencyMetric();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _controller.refresh();
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  void _showDrillDown(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Attribution Console'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) {
            final PushAttributionViewState state = _controller.state;
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = constraints.maxWidth;
                  final bool isDesktop = width >= _desktopBreakpoint;
                  final bool isMobile = width < _mobileBreakpoint;
                  final int columns = isDesktop ? 2 : 1;

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: _KpiRow(
                            state: state,
                            metric: _metric,
                            isMobile: isMobile,
                            onDrillDown: _showDrillDown,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisExtent: 132,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 4,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              final PushAttributionEvent event =
                                  state.events[index];
                              return PushAttributionStatusCard(
                                event: event,
                                onTap: () => _showDrillDown(
                                  'trace_id: ${event.traceId}',
                                ),
                              );
                            },
                            childCount: state.events.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.state,
    required this.metric,
    required this.isMobile,
    required this.onDrillDown,
  });

  final PushAttributionViewState state;
  final EventDispatchLatencyMetric metric;
  final bool isMobile;
  final void Function(String message) onDrillDown;

  @override
  Widget build(BuildContext context) {
    final MetricVerdict verdict = metric.evaluate(state.averageLatencyMs);
    final bool isHealthy = verdict == MetricVerdict.optimal ||
        verdict == MetricVerdict.acceptable;

    final Widget latencyCard = PushAttributionKpiCard(
      label: 'Event Dispatch Latency',
      value: state.averageLatencyMs.toString(),
      unitSuffix: 'ms',
      isHealthy: isHealthy,
      onDrillDown: () => onDrillDown(
        'Target ≤ ${metric.optimalTargetMs} ms | Floor ≤ ${metric.floorBoundaryMs} ms',
      ),
    );

    final Widget gateCard = PushAttributionKpiCard(
      label: 'Gate Outcome',
      value: state.overallStatus == CompletionStatus.pass ? 'Pass' : 'Fail',
      unitSuffix: '',
      isHealthy: state.overallStatus == CompletionStatus.pass,
      onDrillDown: () => onDrillDown(
        'Streaming spec: Google Cloud Pub/Sub Streaming',
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          latencyCard,
          const SizedBox(height: 8),
          gateCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: latencyCard),
        const SizedBox(width: 12),
        Expanded(child: gateCard),
      ],
    );
  }
}
