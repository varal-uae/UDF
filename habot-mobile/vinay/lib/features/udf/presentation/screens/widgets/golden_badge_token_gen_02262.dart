// GEN-02262 — Golden/Highlighted Badge Token for Top 10% Mobile UI.
// Displays M3 Elevated Card with status chip indicating top 10% badge state. Includes mock data, 48x48dp touch targets, Material You dynamic color, and responsive single-column layout.

import 'package:flutter/material.dart';

enum BadgeType { golden, highlighted }

class MockBadgeData {
  final String userId;
  final String userName;
  final double designSystemAdherenceRate;
  final BadgeType badgeType;
  final bool isTopTenPercent;
  final DateTime timestamp;

  const MockBadgeData({
    required this.userId,
    required this.userName,
    required this.designSystemAdherenceRate,
    required this.badgeType,
    required this.isTopTenPercent,
    required this.timestamp,
  });
}

const List<MockBadgeData> kMockBadgeList = [
  MockBadgeData(
    userId: 'USR-001',
    userName: 'Alice Engineer',
    designSystemAdherenceRate: 0.96,
    badgeType: BadgeType.golden,
    isTopTenPercent: true,
    timestamp: DateTime(2026, 9, 24, 10, 0),
  ),
  MockBadgeData(
    userId: 'USR-002',
    userName: 'Bob Developer',
    designSystemAdherenceRate: 0.88,
    badgeType: BadgeType.highlighted,
    isTopTenPercent: true,
    timestamp: DateTime(2026, 9, 24, 10, 5),
  ),
  MockBadgeData(
    userId: 'USR-003',
    userName: 'Charlie Coder',
    designSystemAdherenceRate: 0.72,
    badgeType: BadgeType.highlighted,
    isTopTenPercent: false,
    timestamp: DateTime(2026, 9, 24, 10, 10),
  ),
];

class GoldenBadgeTokenScreen extends StatefulWidget {
  const GoldenBadgeTokenScreen({super.key});

  @override
  State<GoldenBadgeTokenScreen> createState() => _GoldenBadgeTokenScreenState();
}

class _GoldenBadgeTokenScreenState extends State<GoldenBadgeTokenScreen> {
  late List<MockBadgeData> _badges;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _badges = kMockBadgeList;
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      setState(() {
        _badges = List.from(kMockBadgeList);
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final crossAxisCount = isDesktop ? 2 : 1;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isDesktop ? 2.5 : 3.0,
              ),
              itemCount: _badges.length,
              itemBuilder: (context, index) {
                return _GoldenBadgeCard(data: _badges[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _GoldenBadgeCard extends StatelessWidget {
  final MockBadgeData data;

  const _GoldenBadgeCard({required this.data});

  Color _badgeColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!data.isTopTenPercent) return colorScheme.surfaceVariant;
    return data.badgeType == BadgeType.golden
        ? Colors.amber.shade700
        : colorScheme.primary;
  }

  String _statusLabel() {
    if (!data.isTopTenPercent) return 'Standard';
    return data.badgeType == BadgeType.golden ? 'Golden' : 'Highlighted';
  }

  String _adherenceResult() {
    return data.designSystemAdherenceRate >= 0.85 ? 'Pass' : 'Fail';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final badgeCol = _badgeColor(context);
    final passFail = _adherenceResult();

    return Semantics(
      label: '${data.userName}, ${_statusLabel()} badge, Design System Adherence $passFail',
      child: Card(
        elevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: badgeCol.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      data.isTopTenPercent ? Icons.workspace_premium : Icons.person_outline,
                      color: badgeCol,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.userName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${data.userId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (data.isTopTenPercent)
                    Chip(
                      avatar: Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: badgeCol,
                      ),
                      label: Text(
                        _statusLabel(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: badgeCol,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: badgeCol.withOpacity(0.12),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
              const Spacer(),
              Divider(height: 24, thickness: 1, color: colorScheme.outlineVariant),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _KpiMetric(
                    label: 'Adherence Rate',
                    value: '${(data.designSystemAdherenceRate * 100).toStringAsFixed(0)}%',
                    theme: theme,
                  ),
                  _KpiMetric(
                    label: 'Validation',
                    value: passFail,
                    theme: theme,
                    valueColor: passFail == 'Pass'
                        ? Colors.green.shade700
                        : colorScheme.error,
                  ),
                  _KpiMetric(
                    label: 'Top 10%',
                    value: data.isTopTenPercent ? 'Yes' : 'No',
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiMetric extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  const _KpiMetric({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
