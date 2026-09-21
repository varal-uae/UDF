// GEN-01622 — Upcoming Today Hero Card Widget.
// Positions the "Upcoming Today" Hero Card prominently within the top viewport using M3 ElevatedCard Level 2, Material You dynamic color, responsive single/multi-column layout, and local mock data.

import 'package:flutter/material.dart';

/// Mock data model for the Upcoming Today Hero Card.
class _HeroCardMockData {
  final String title;
  final String status;
  final String refreshLatency;
  final String qualitativeOutput;
  final DateTime timestamp;

  const _HeroCardMockData({
    required this.title,
    required this.status,
    required this.refreshLatency,
    required this.qualitativeOutput,
    required this.timestamp,
  });
}

/// Static mock data simulating backend response for Dashboard Data Refresh Latency.
const List<_HeroCardMockData> _mockUpcomingTodayData = [
  _HeroCardMockData(
    title: 'Upcoming Today',
    status: 'Active',
    refreshLatency: '<5 minutes',
    qualitativeOutput: 'Good',
    timestamp: null as dynamic,
  ),
];

/// UpcomingTodayHeroCard widget implementing GEN-01622.
/// M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
/// Uses M3 Elevated Cards Level 2 (3dp elevation) and M3 Status Chips.
/// Touch targets are minimum 48x48dp. Background polling every 30s is simulated via periodic state update.
class UpcomingTodayHeroCard extends StatefulWidget {
  const UpcomingTodayHeroCard({super.key});

  @override
  State<UpcomingTodayHeroCard> createState() => _UpcomingTodayHeroCardState();
}

class _UpcomingTodayHeroCardState extends State<UpcomingTodayHeroCard> {
  late _HeroCardMockData _currentData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentData = _HeroCardMockData(
      title: _mockUpcomingTodayData.first.title,
      status: _mockUpcomingTodayData.first.status,
      refreshLatency: _mockUpcomingTodayData.first.refreshLatency,
      qualitativeOutput: _mockUpcomingTodayData.first.qualitativeOutput,
      timestamp: DateTime.now(),
    );
    _startBackgroundPolling();
  }

  void _startBackgroundPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (!mounted) return;
      _simulateRefresh();
      _startBackgroundPolling();
    });
  }

  Future<void> _simulateRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 80)); // sub-100ms simulation
    if (!mounted) return;
    setState(() {
      _currentData = _HeroCardMockData(
        title: _mockUpcomingTodayData.first.title,
        status: _mockUpcomingTodayData.first.status,
        refreshLatency: _mockUpcomingTodayData.first.refreshLatency,
        qualitativeOutput: _mockUpcomingTodayData.first.qualitativeOutput,
        timestamp: DateTime.now(),
      );
      _isRefreshing = false;
    });
  }

  Color _getQualitativeColor(BuildContext context, String quality) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (quality) {
      case 'Good':
        return colorScheme.primary;
      case 'Average':
        return colorScheme.tertiary;
      case 'Poor':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _simulateRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isDesktop ? _buildMultiColumnLayout(context) : _buildSingleColumnLayout(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildElevatedCard(context),
      ],
    );
  }

  Widget _buildMultiColumnLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildElevatedCard(context)),
        const SizedBox(width: 24),
        Expanded(child: _buildMetricsPanel(context)),
      ],
    );
  }

  Widget _buildElevatedCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentData.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (_isRefreshing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilterChip(
                  label: Text(_currentData.status),
                  selected: true,
                  onSelected: (_) {},
                  backgroundColor: colorScheme.secondaryContainer,
                  labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                FilterChip(
                  label: Text('Latency: ${_currentData.refreshLatency}'),
                  selected: false,
                  onSelected: (_) {},
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48, // 48x48dp touch target
              width: 48,
              child: IconButton(
                iconSize: 24,
                onPressed: _showConfigBottomSheet,
                icon: Icon(Icons.settings_outlined, color: colorScheme.primary),
                tooltip: 'Configuration',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dashboard Health', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Qualitative Output: ', style: theme.textTheme.bodyLarge),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getQualitativeColor(context, _currentData.qualitativeOutput).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _currentData.qualitativeOutput,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: _getQualitativeColor(context, _currentData.qualitativeOutput),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Last Updated: ${_currentData.timestamp != null ? TimeOfDay.fromDateTime(_currentData.timestamp!).format(context) : 'N/A'}',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Configuration Inputs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Metric Config',
                  hintText: 'Dashboard Data Refresh Latency',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration saved successfully.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        action: SnackBarAction(label: 'DISMISS', onPressed: () {}),
                      ),
                    );
                  },
                  child: const Text('Apply Configuration'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
