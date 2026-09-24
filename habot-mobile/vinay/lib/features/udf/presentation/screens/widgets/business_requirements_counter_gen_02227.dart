// GEN-02227 — Business Requirements Counter M3 Status Card.
// Displays the count of defined business requirements with Process Execution Accuracy metrics, M3 Elevated Card layout, and 30-second polling refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum RequirementStatus { pass, fail }

class MockRequirementData {
  final int totalRequirements;
  final int completedRequirements;
  final double processExecutionAccuracy;
  final RequirementStatus status;
  final DateTime lastUpdated;

  const MockRequirementData({
    required this.totalRequirements,
    required this.completedRequirements,
    required this.processExecutionAccuracy,
    required this.status,
    required this.lastUpdated,
  });
}

class MockRequirementRepository {
  static Future<MockRequirementData> fetchRequirements() async {
    await Future.delayed(const Duration(milliseconds: 85));
    return MockRequirementData(
      totalRequirements: 142,
      completedRequirements: 138,
      processExecutionAccuracy: 0.9718,
      status: RequirementStatus.pass,
      lastUpdated: DateTime.now(),
    );
  }
}

class BusinessRequirementsCounterGen02227 extends StatefulWidget {
  const BusinessRequirementsCounterGen02227({super.key});

  @override
  State<BusinessRequirementsCounterGen02227> createState() =>
      _BusinessRequirementsCounterGen02227State();
}

class _BusinessRequirementsCounterGen02227State
    extends State<BusinessRequirementsCounterGen02227> {
  MockRequirementData? _data;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await MockRequirementRepository.fetchRequirements();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Requirements',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading && _data == null)
                const Center(child: CircularProgressIndicator())
              else if (_data != null)
                _buildContent(theme, colorScheme, isMobile)
              else
                const Center(child: Text('Failed to load data.')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    final data = _data!;
    final statusColor = data.status == RequirementStatus.pass
        ? colorScheme.primary
        : colorScheme.error;
    final statusLabel =
        data.status == RequirementStatus.pass ? 'Pass' : 'Fail';

    final cards = [
      _buildMetricCard(
        theme,
        'Defined Requirements',
        '${data.totalRequirements}',
        Icons.list_alt_outlined,
      ),
      _buildMetricCard(
        theme,
        'Completed',
        '${data.completedRequirements}',
        Icons.check_circle_outline,
      ),
      _buildMetricCard(
        theme,
        'Process Execution Accuracy',
        '${(data.processExecutionAccuracy * 100).toStringAsFixed(2)}%',
        Icons.speed_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step Health',
              style: theme.textTheme.titleMedium,
            ),
            Chip(
              avatar: Icon(Icons.circle, size: 12, color: statusColor),
              label: Text(statusLabel),
              backgroundColor: statusColor.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              side: BorderSide.none,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isMobile)
          Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList())
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards.map((c) => SizedBox(width: 280, child: c)).toList(),
          ),
        const SizedBox(height: 24),
        Text(
          'Last updated: ${data.lastUpdated.toIso8601String().substring(0, 19)}Z',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}