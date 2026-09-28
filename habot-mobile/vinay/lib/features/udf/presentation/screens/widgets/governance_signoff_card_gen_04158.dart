// GEN-04158 — Governance Approval Sign-off Card for Mobile UI/UX Team.
// Displays a single-column M3 Elevated Card with status chips indicating Pass/Fail governance approval for rejecting multi-column grid layouts on mobile.

import 'dart:async';
import 'package:flutter/material.dart';

enum GovernanceStatus { pending, pass, fail }

class GovernanceSignOffModel {
  final String referenceId;
  final String description;
  final GovernanceStatus status;
  final DateTime timestamp;
  final String approvedBy;

  const GovernanceSignOffModel({
    required this.referenceId,
    required this.description,
    required this.status,
    required this.timestamp,
    required this.approvedBy,
  });
}

class MockGovernanceRepository {
  static const List<GovernanceSignOffModel> mockData = [
    GovernanceSignOffModel(
      referenceId: 'GEN-04158',
      description: 'Rejection of multi-column grid layouts for mobile views.',
      status: GovernanceStatus.pass,
      timestamp: _MockDateTime.mockNow,
      approvedBy: 'Mobile UI/UX Team Lead',
    ),
  ];

  static Future<List<GovernanceSignOffModel>> fetchSignOffs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockData;
  }
}

class _MockDateTime {
  static DateTime get mockNow => DateTime(2026, 9, 28, 10, 30);
}

class GovernanceSignoffCardGen04158 extends StatefulWidget {
  const GovernanceSignoffCardGen04158({super.key});

  @override
  State<GovernanceSignoffCardGen04158> createState() => _GovernanceSignoffCardGen04158State();
}

class _GovernanceSignoffCardGen04158State extends State<GovernanceSignoffCardGen04158> {
  late Future<List<GovernanceSignOffModel>> _signOffsFuture;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Background polling refreshes data every 30 seconds as per requirement
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() {
    setState(() {
      _signOffsFuture = MockGovernanceRepository.fetchSignOffs();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Engineering Console - Governance Gates',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<GovernanceSignOffModel>>(
              future: _signOffsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No governance data available.'));
                }

                final items = snapshot.data!;
                // Single-column layout enforced for mobile (<600dp)
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildElevatedCard(item, theme, colorScheme);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedCard(
    GovernanceSignOffModel item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final bool isPass = item.status == GovernanceStatus.pass;
    final Color chipColor = isPass ? colorScheme.primary : colorScheme.error;
    final IconData statusIcon = isPass ? Icons.check_circle_outline : Icons.cancel_outlined;
    final String statusLabel = isPass ? 'PASS' : 'FAIL';

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.referenceId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  avatar: Icon(statusIcon, size: 16, color: chipColor),
                  label: Text(
                    statusLabel,
                    style: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: chipColor.withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant, thickness: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  item.approvedBy,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${item.timestamp.year}-${item.timestamp.month.toString().padLeft(2, '0')}-${item.timestamp.day.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48, // 48x48dp touch targets
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Drill-down initiated for ${item.referenceId}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new, size: 20),
                label: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}