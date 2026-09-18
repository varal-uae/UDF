// GEN-01468 — UDF Tab Containers: About, Reviews, Schedule, and Policies.
// Defines M3-compliant tab containers with responsive layout, mock data, status chips, and 48x48dp touch targets.

import 'package:flutter/material.dart';

enum ReviewAuthenticity { good, average, poor }

class _MockTabData {
  final String title;
  final String description;
  final ReviewAuthenticity authenticity;
  final double verificationRate;

  const _MockTabData({
    required this.title,
    required this.description,
    required this.authenticity,
    required this.verificationRate,
  });
}

const List<_MockTabData> _kMockTabs = [
  _MockTabData(
    title: 'About',
    description: 'General information about the entity.',
    authenticity: ReviewAuthenticity.good,
    verificationRate: 0.98,
  ),
  _MockTabData(
    title: 'Reviews',
    description: 'Customer reviews and ratings per ISO 20488.',
    authenticity: ReviewAuthenticity.good,
    verificationRate: 0.95,
  ),
  _MockTabData(
    title: 'Schedule',
    description: 'Operational schedule and availability windows.',
    authenticity: ReviewAuthenticity.average,
    verificationRate: 0.91,
  ),
  _MockTabData(
    title: 'Policies',
    description: 'Terms, conditions, and FTC Endorsement compliance.',
    authenticity: ReviewAuthenticity.good,
    verificationRate: 0.99,
  ),
];

class UdfTabContainersGen01468 extends StatefulWidget {
  const UdfTabContainersGen01468({super.key});

  @override
  State<UdfTabContainersGen01468> createState() => _UdfTabContainersGen01468State();
}

class _UdfTabContainersGen01468State extends State<UdfTabContainersGen01468>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _kMockTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _authenticityColor(ReviewAuthenticity auth, ColorScheme cs) {
    switch (auth) {
      case ReviewAuthenticity.good:
        return cs.primary;
      case ReviewAuthenticity.average:
        return cs.tertiary;
      case ReviewAuthenticity.poor:
        return cs.error;
    }
  }

  String _authenticityLabel(ReviewAuthenticity auth) {
    switch (auth) {
      case ReviewAuthenticity.good:
        return 'Good';
      case ReviewAuthenticity.average:
        return 'Average';
      case ReviewAuthenticity.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;

        if (isDesktop) {
          return _buildMultiColumnLayout(theme, cs);
        }
        return _buildSingleColumnLayout(theme, cs);
      },
    );
  }

  Widget _buildSingleColumnLayout(ThemeData theme, ColorScheme cs) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: theme.textTheme.labelLarge,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: _kMockTabs
              .map((t) => SizedBox(
                    height: 48,
                    child: Tab(text: t.title),
                  ))
              .toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _kMockTabs.map((t) => _buildStatusCard(t, cs)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiColumnLayout(ThemeData theme, ColorScheme cs) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _kMockTabs.length,
      itemBuilder: (context, index) {
        return _buildStatusCard(_kMockTabs[index], cs);
      },
    );
  }

  Widget _buildStatusCard(_MockTabData data, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  Chip(
                    label: Text(
                      _authenticityLabel(data.authenticity),
                      style: TextStyle(color: cs.onPrimaryContainer, fontSize: 12),
                    ),
                    backgroundColor: _authenticityColor(data.authenticity, cs).withOpacity(0.15),
                    side: BorderSide(color: _authenticityColor(data.authenticity, cs), width: 1),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(data.description, style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
              const Spacer(),
              Row(
                children: [
                  Text('Verification Rate: ', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  Text('${(data.verificationRate * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary)),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                width: 48,
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Drill-down into ${data.title} details.')),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'View Details',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
