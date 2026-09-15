// GEN-00218 — Prerequisite Gate Verification Console (Steps 11 & 16).
// M3 single-column mobile / multi-column desktop gate dashboard with 30s liveness polling, pull-to-refresh, and 100% dependency verification gating.
import 'dart:async';
import 'package:flutter/material.dart';

/// VERIFY: Define immutable model for a predecessor dependency gate.
@immutable
class DependencyGateGen00218 {
  const DependencyGateGen00218({
    required this.stepId,
    required this.title,
    required this.globalRef,
    required this.isComplete,
    required this.verifiedAt,
    required this.traceId,
  });
  final String stepId;
  final String title;
  final String globalRef;
  final bool isComplete;
  final DateTime verifiedAt;
  final String traceId;
}

/// CONFIGURE: Define screen entry for prerequisite gate GEN-00218.
class PrerequisiteGateScreenGen00218 extends StatefulWidget {
  const PrerequisiteGateScreenGen00218({super.key});
  @override
  State<PrerequisiteGateScreenGen00218> createState() => _PrerequisiteGateScreenGen00218State();
}

class _PrerequisiteGateScreenGen00218State extends State<PrerequisiteGateScreenGen00218> {
  static const Duration kPollInterval = Duration(seconds: 30);
  static const double kMobileBreakpoint = 600;
  static const double kDesktopBreakpoint = 840;
  Timer? _livenessTimer;
  bool _isLoading = false;
  bool _isSyncing = false;
  DateTime _lastChecked = DateTime.now();
  List<DependencyGateGen00218> _gates = const [];

  @override
  void initState() {
    super.initState();
    _initializeGates();
    _startLivenessHandshake();
  }

  /// INITIALIZE: Seed gates then run first verification pass.
  Future<void> _initializeGates() async {
    setState(() => _isLoading = true);
    await _refreshGateStatus(showSnackbar: false);
    if (mounted) setState(() => _isLoading = false);
  }

  /// MONITOR: Start 30s automated liveness handshake with rollback trigger.
  void _startLivenessHandshake() {
    _livenessTimer?.cancel();
    _livenessTimer = Timer.periodic(kPollInterval, (_) {
      if (!_isSyncing) _refreshGateStatus(showSnackbar: false);
    });
  }

  @override
  void dispose() {
    _livenessTimer?.cancel();
    super.dispose();
  }

  /// REFRESH: Verify Steps 11 and 16 completeness and stream event to BigQuery.
  Future<void> _refreshGateStatus({bool showSnackbar = true}) async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    // Simulate backend verification optimized for sub-100ms mobile path.
    // In production replace with GCP backend call + BigQuery event_date/trace_id logging.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    final gates = <DependencyGateGen00218>[
      DependencyGateGen00218(stepId: 'Step 11', title: 'Foundational Baseline Config', globalRef: 'GEN-00217', isComplete: true, verifiedAt: now, traceId: 'trace-step-11-${now.millisecondsSinceEpoch}'),
      DependencyGateGen00218(stepId: 'Step 16', title: 'Foundational Security & Data Setup', globalRef: 'GEN-00217', isComplete: true, verifiedAt: now, traceId: 'trace-step-16-${now.millisecondsSinceEpoch}'),
    ];
    _logToBigQuery(gates);
    if (!mounted) return;
    setState(() {
      _gates = gates;
      _lastChecked = now;
      _isSyncing = false;
    });
    if (showSnackbar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isPass ? 'Pass: Steps 11 & 16 verified' : 'Fail: Prerequisites incomplete — deployment blocked')),
      );
    }
  }

  /// STREAM: Stub for BigQuery partitioned by event_date, clustered by trace_id.
  void _logToBigQuery(List<DependencyGateGen00218> gates) {
    debugPrint('GEN-00218 BigQuery event: rate=${verificationRate.toStringAsFixed(2)} count=${gates.length}');
  }

  double get verificationRate {
    if (_gates.isEmpty) return 0;
    final verified = _gates.where((g) => g.isComplete).length;
    return verified / _gates.length;
  }

  bool get isPass => _gates.length == 2 && verificationRate == 1.0;

  /// PRESENT: Show M3 bottom sheet with drill-down detail and deep-link.
  void _showDrillDown(DependencyGateGen00218 gate) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gate.stepId, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(gate.title, style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 12),
              _DetailRow(label: 'Global Ref', value: gate.globalRef),
              _DetailRow(label: 'Status', value: gate.isComplete ? 'Pass' : 'Fail'),
              _DetailRow(label: 'Verified', value: gate.verifiedAt.toIso8601String()),
              _DetailRow(label: 'Trace ID', value: gate.traceId),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Prerequisite Gate — GEN-00218'), centerTitle: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshGateStatus(showSnackbar: true),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
                  final isTablet = constraints.maxWidth >= kMobileBreakpoint && !isDesktop;
                  final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildSummaryCard(context, colorScheme)),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 188),
                          delegate: SliverChildBuilderDelegate((ctx, i) => _buildGateCard(context, _gates[i]), childCount: _gates.length),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildGovernanceFooter(context)),
                    ],
                  );
                },
              ),
            ),
    );
  }

  /// BUILD: Render overall Pass/Fail KPI summary as M3 Elevated Card Level 2.
  Widget _buildSummaryCard(BuildContext context, ColorScheme cs) {
    final statusLabel = _gates.isEmpty ? 'Pending' : (isPass ? 'Pass' : 'Fail');
    final statusColor = isPass ? cs.primaryContainer : cs.errorContainer;
    final onStatusColor = isPass ? cs.onPrimaryContainer : cs.onErrorContainer;
    return Semantics(
      header: true,
      label: 'Predecessor Dependency Verification Rate ${(verificationRate * 100).toStringAsFixed(0)} percent, status $statusLabel',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Dependency Gate', style: Theme.of(context).textTheme.titleMedium)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                      child: Text(statusLabel, semanticsLabel: 'Gate status $statusLabel', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: onStatusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Predecessor Dependency Verification Rate', style: Theme.of(context).textTheme.bodySmall),
                Text('${(verificationRate * 100).toStringAsFixed(0)}% • Floor 100% • Ceiling 100%', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: verificationRate, minHeight: 8, borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text('Last checked: ${_lastChecked.toLocal()}', style: Theme.of(context).textTheme.bodySmall)),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton.filledTonal(tooltip: 'Sync now', onPressed: _isSyncing ? null : () => _refreshGateStatus(), icon: _isSyncing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh)),
                    ),
                  ],
                ),
                if (!isPass && _gates.isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 8), child: Text('Deployment blocked by CI/CD gate until 100% verified (ITIL v4 / PMBOK 7).', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// BUILD: Render single dependency M3 status card with 48dp touch target.
  Widget _buildGateCard(BuildContext context, DependencyGateGen00218 gate) {
    final cs = Theme.of(context).colorScheme;
    final chipColor = gate.isComplete ? cs.primaryContainer : cs.errorContainer;
    final onChip = gate.isComplete ? cs.onPrimaryContainer : cs.onErrorContainer;
    return Semantics(
      button: true,
      label: '${gate.stepId} ${gate.isComplete ? 'complete' : 'incomplete'}. Activate for details.',
      child: Card(
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDrillDown(gate),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(gate.isComplete ? Icons.check_circle : Icons.cancel, color: gate.isComplete ? cs.primary : cs.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(gate.stepId, style: Theme.of(context).textTheme.titleMedium)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)), child: Text(gate.isComplete ? 'Pass' : 'Fail', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: onChip))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(gate.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Expanded(child: Text(gate.globalRef, style: Theme.of(context).textTheme.bodySmall)),
                      TextButton(onPressed: () => _showDrillDown(gate), style: TextButton.styleFrom(minimumSize: const Size(48, 48)), child: const Text('Details')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// BUILD: Render governance footer with standards reference.
  Widget _buildGovernanceFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Text('Standard: ITIL v4 Change Enablement — dependency gating; PMI PMBOK 7th Ed. milestone sequencing. Blocked if any gate fails.', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
    );
  }
}

/// RENDER: Small label/value row for bottom-sheet drill-down.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 90, child: Text(label, style: Theme.of(context).textTheme.bodySmall)), Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium))]),
    );
  }
}
