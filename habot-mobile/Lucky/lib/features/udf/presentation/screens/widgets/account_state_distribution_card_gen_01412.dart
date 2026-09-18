// GEN-01412 — Active Account State Distribution Dashboard Card.
// Renders active account state distributions on operational management dashboards using M3 Elevated Cards, responsive layouts, and 30-second background polling with pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum AccountStateStatus { good, average, poor }

class AccountStateDistribution {
  final String stateName;
  final int activeAccounts;
  final AccountStateStatus status;
  final DateTime lastUpdated;

  const AccountStateDistribution({
    required this.stateName,
    required this.activeAccounts,
    required this.status,
    required this.lastUpdated,
  });
}

class MockAccountStateRepository {
  static List<AccountStateDistribution> fetchDistributions() {
    final now = DateTime.now();
    return [
      AccountStateDistribution(
        stateName: 'Dubai',
        activeAccounts: 14520,
        status: AccountStateStatus.good,
        lastUpdated: now.subtract(const Duration(minutes: 2)),
      ),
      AccountStateDistribution(
        stateName: 'Abu Dhabi',
        activeAccounts: 9830,
        status: AccountStateStatus.good,
        lastUpdated: now.subtract(const Duration(minutes: 5)),
      ),
      AccountStateDistribution(
        stateName: 'Sharjah',
        activeAccounts: 4210,
        status: AccountStateStatus.average,
        lastUpdated: now.subtract(const Duration(minutes: 15)),
      ),
      AccountStateDistribution(
        stateName: 'Ajman',
        activeAccounts: 1120,
        status: AccountStateStatus.poor,
        lastUpdated: now.subtract(const Duration(hours: 2)),
      ),
      AccountStateDistribution(
        stateName: 'Ras Al Khaimah',
        activeAccounts: 890,
        status: AccountStateStatus.average,
        lastUpdated: now.subtract(const Duration(minutes: 45)),
      ),
      AccountStateDistribution(
        stateName: 'Fujairah',
        activeAccounts: 540,
        status: AccountStateStatus.good,
        lastUpdated: now.subtract(const Duration(minutes: 10)),
      ),
      AccountStateDistribution(
        stateName: 'Umm Al Quwain',
        activeAccounts: 210,
        status: AccountStateStatus.poor,
        lastUpdated: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }
}

class AccountStateDistributionCard extends StatefulWidget {
  const AccountStateDistributionCard({super.key});

  @override
  State<AccountStateDistributionCard> createState() => _AccountStateDistributionCardState();
}

class _AccountStateDistributionCardState extends State<AccountStateDistributionCard> {
  late List<AccountStateDistribution> _distributions;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _distributions = MockAccountStateRepository.fetchDistributions();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData(showSnackbar: false);
    });
  }

  Future<void> _refreshData({bool showSnackbar = true}) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    await Future.delayed(const Duration(milliseconds: 60)); // Simulate sub-100ms API latency

    if (!mounted) return;
    setState(() {
      _distributions = MockAccountStateRepository.fetchDistributions();
      _isRefreshing = false;
    });

    if (showSnackbar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dashboard data synchronized'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Color _getStatusColor(AccountStateStatus status, ThemeData theme) {
    switch (status) {
      case AccountStateStatus.good:
        return theme.colorScheme.primary;
      case AccountStateStatus.average:
        return theme.colorScheme.tertiary;
      case AccountStateStatus.poor:
        return theme.colorScheme.error;
    }
  }

  String _getStatusLabel(AccountStateStatus status) {
    switch (status) {
      case AccountStateStatus.good:
        return 'Good';
      case AccountStateStatus.average:
        return 'Average';
      case AccountStateStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;
    final crossAxisCount = isDesktop ? 3 : 1;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Operational Management Dashboard'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Engineering Console Info',
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(showSnackbar: true),
        color: theme.colorScheme.primary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Account State Distributions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Read-only KPI cards • Auto-refresh every 30s',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isRefreshing
                        ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                        : GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 16.0,
                              crossAxisSpacing: 16.0,
                              childAspectRatio: isDesktop ? 2.2 : 2.8,
                            ),
                            itemCount: _distributions.length,
                            itemBuilder: (context, index) {
                              final dist = _distributions[index];
                              return _buildM3ElevatedCard(dist, theme);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildM3ElevatedCard(AccountStateDistribution dist, ThemeData theme) {
    final statusColor = _getStatusColor(dist.status, theme);
    final statusLabel = _getStatusLabel(dist.status);

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Deep-link drill-down placeholder
          showModalBottomSheet(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            builder: (ctx) => _buildConfigurationBottomSheet(dist, theme),
          );
        },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dist.stateName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // M3 Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dist.activeAccounts.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Accounts',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated: ${_formatTimeAgo(dist.lastUpdated)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationBottomSheet(AccountStateDistribution dist, ThemeData theme) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Drill-down: ${dist.stateName}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Detailed account distribution metrics for ${dist.stateName}. This read-only view provides deep-link access to the engineering console dashboard health indicators.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.account_tree, color: theme.colorScheme.primary),
                title: const Text('Active Accounts'),
                subtitle: Text('${dist.activeAccounts}'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(Icons.speed, color: theme.colorScheme.primary),
                title: const Text('Refresh Latency Metric'),
                subtitle: Text(_getStatusLabel(dist.status)),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(Icons.update, color: theme.colorScheme.primary),
                title: const Text('Last Synchronized'),
                subtitle: Text(_formatTimeAgo(dist.lastUpdated)),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
