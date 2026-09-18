// GEN-01368 — Bottom Screen Thumb-Zone CTA Boundary Component.
// Defines thumb-zone boundaries for primary call-to-action placement using M3 Elevated Cards, status chips, 48x48dp touch targets, single-column mobile layout, and background polling every 30 seconds with pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum CtaCompletionStatus { good, average, poor }

class MockCtaThumbZoneData {
  final String ctaLabel;
  final CtaCompletionStatus completionStatus;
  final DateTime actionTimestamp;
  final String sessionId;
  final double conversionRate;

  const MockCtaThumbZoneData({
    required this.ctaLabel,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.sessionId,
    required this.conversionRate,
  });
}

const List<MockCtaThumbZoneData> mockCtaDataSet = [
  MockCtaThumbZoneData(
    ctaLabel: 'Submit Application',
    completionStatus: CtaCompletionStatus.good,
    actionTimestamp: null as dynamic,
    sessionId: 'sess_001',
    conversionRate: 0.85,
  ),
  MockCtaThumbZoneData(
    ctaLabel: 'Confirm Payment',
    completionStatus: CtaCompletionStatus.average,
    actionTimestamp: null as dynamic,
    sessionId: 'sess_002',
    conversionRate: 0.65,
  ),
  MockCtaThumbZoneData(
    ctaLabel: 'Verify Identity',
    completionStatus: CtaCompletionStatus.poor,
    actionTimestamp: null as dynamic,
    sessionId: 'sess_003',
    conversionRate: 0.45,
  ),
];

class ThumbZoneCtaBoundaryGen01368 extends StatefulWidget {
  const ThumbZoneCtaBoundaryGen01368({super.key});

  @override
  State<ThumbZoneCtaBoundaryGen01368> createState() => _ThumbZoneCtaBoundaryGen01368State();
}

class _ThumbZoneCtaBoundaryGen01368State extends State<ThumbZoneCtaBoundaryGen01368> {
  late List<MockCtaThumbZoneData> _data;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _data = mockCtaDataSet.map((e) => MockCtaThumbZoneData(
      ctaLabel: e.ctaLabel,
      completionStatus: e.completionStatus,
      actionTimestamp: DateTime.now(),
      sessionId: e.sessionId,
      conversionRate: e.conversionRate,
    )).toList();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isRefreshing = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _data = mockCtaDataSet.map((e) => MockCtaThumbZoneData(
        ctaLabel: e.ctaLabel,
        completionStatus: e.completionStatus,
        actionTimestamp: DateTime.now(),
        sessionId: e.sessionId,
        conversionRate: e.conversionRate,
      )).toList();
      _isRefreshing = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchData();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _statusColor(CtaCompletionStatus status, ColorScheme cs) {
    switch (status) {
      case CtaCompletionStatus.good:
        return cs.primary;
      case CtaCompletionStatus.average:
        return cs.tertiary;
      case CtaCompletionStatus.poor:
        return cs.error;
    }
  }

  String _statusLabel(CtaCompletionStatus status) {
    switch (status) {
      case CtaCompletionStatus.good:
        return 'Good';
      case CtaCompletionStatus.average:
        return 'Average';
      case CtaCompletionStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('CTA Thumb-Zone Boundaries'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: cs.primary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isDesktop ? 2.5 : 2.8,
              ),
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final item = _data[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.ctaLabel,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Chip(
                              label: Text(
                                _statusLabel(item.completionStatus),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: _statusColor(item.completionStatus, cs),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Conversion Rate: ${(item.conversionRate * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Session: ${item.sessionId}',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () {
                                _showConfigBottomSheet(context, item);
                              },
                              tooltip: 'Drill-down configuration',
                              iconSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Primary CTA triggered within thumb-zone boundary.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: cs.primaryContainer,
                  contentTextStyle: TextStyle(color: cs.onPrimaryContainer),
                ),
              );
            },
            icon: const Icon(Icons.touch_app),
            label: const Text('Primary Call-to-Action'),
          ),
        ),
      ),
    );
  }

  void _showConfigBottomSheet(BuildContext context, MockCtaThumbZoneData item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Configure: ${item.ctaLabel}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Thumb-Zone Boundary Offset (dp)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuration saved successfully.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save Configuration'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}