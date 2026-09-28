// GEN-04269 — Governance Approval Gate Status Card.
// Displays the sign-off status for centralized design tokens deprecation using M3 ElevatedCard with inline status chip, single-column mobile layout, and mock data.

import 'dart:async';
import 'package:flutter/material.dart';

enum GovernanceStatus { pass, fail, pending }

class GovernanceApprovalData {
  final String atomicId;
  final String title;
  final GovernanceStatus status;
  final DateTime timestamp;
  final String approvedBy;

  const GovernanceApprovalData({
    required this.atomicId,
    required this.title,
    required this.status,
    required this.timestamp,
    required this.approvedBy,
  });
}

class MockGovernanceRepository {
  static const GovernanceApprovalData currentApproval = GovernanceApprovalData(
    atomicId: 'GEN-04269',
    title: 'Complete deprecation of custom styling sheets in favor of centralized design tokens.',
    status: GovernanceStatus.pass,
    timestamp: DateTime(2026, 9, 28, 10, 30),
    approvedBy: 'Mobile Systems & UI Architecture Team',
  );

  static Future<GovernanceApprovalData> fetchApprovalStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return currentApproval;
  }
}

class GovernanceApprovalCardGen04269 extends StatefulWidget {
  const GovernanceApprovalCardGen04269({super.key});

  @override
  State<GovernanceApprovalCardGen04269> createState() => _GovernanceApprovalCardGen04269State();
}

class _GovernanceApprovalCardGen04269State extends State<GovernanceApprovalCardGen04269> {
  GovernanceApprovalData? _data;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    try {
      final data = await MockGovernanceRepository.fetchApprovalStatus();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await _loadData();
  }

  Color _statusColor(GovernanceStatus status, ColorScheme colorScheme) {
    switch (status) {
      case GovernanceStatus.pass:
        return colorScheme.primary;
      case GovernanceStatus.fail:
        return colorScheme.error;
      case GovernanceStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _statusLabel(GovernanceStatus status) {
    switch (status) {
      case GovernanceStatus.pass:
        return 'Pass';
      case GovernanceStatus.fail:
        return 'Fail';
      case GovernanceStatus.pending:
        return 'Pending';
    }
  }

  IconData _statusIcon(GovernanceStatus status) {
    switch (status) {
      case GovernanceStatus.pass:
        return Icons.check_circle_outline;
      case GovernanceStatus.fail:
        return Icons.error_outline;
      case GovernanceStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 64.0 : 16.0,
          vertical: 16.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 800 : 600),
            child: _isLoading && _data == null
                ? const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  )
                : _buildCard(theme, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, ColorScheme colorScheme) {
    final data = _data ?? MockGovernanceRepository.currentApproval;

    return Semantics(
      label: 'Governance Approval Gate Status: ${_statusLabel(data.status)}',
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Governance Approval Gate',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Chip(
                    avatar: Icon(
                      _statusIcon(data.status),
                      size: 18.0,
                      color: _statusColor(data.status, colorScheme),
                    ),
                    label: Text(
                      _statusLabel(data.status),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _statusColor(data.status, colorScheme),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: _statusColor(data.status, colorScheme).withValues(alpha: 0.12),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Atomic ID: ${data.atomicId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                data.title,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24.0),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 16.0),
              _buildInfoRow(
                theme,
                icon: Icons.groups_outlined,
                label: 'Approved By',
                value: data.approvedBy,
              ),
              const SizedBox(height: 12.0),
              _buildInfoRow(
                theme,
                icon: Icons.access_time,
                label: 'Timestamp',
                value: '${data.timestamp.year}-${data.timestamp.month.toString().padLeft(2, '0')}-${data.timestamp.day.toString().padLeft(2, '0')} ${data.timestamp.hour.toString().padLeft(2, '0')}:${data.timestamp.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 12.0),
              _buildInfoRow(
                theme,
                icon: Icons.description_outlined,
                label: 'Standard',
                value: 'ITIL v4 Change Enablement; ISO 9001',
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                height: 48.0,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Drill-down details opened.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new, size: 20.0),
                  label: const Text('View Full Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.0, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}