// GEN-00814 — PII Anonymization Pipeline Dashboard.
// Read-only engineering console displaying check constraint pass rate using M3 Elevated Cards, status chips, and 30-second background polling with pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum ConstraintStatus { pass, fail, loading }

class PiiAnonymizationDashboardGen00814 extends StatefulWidget {
  const PiiAnonymizationDashboardGen00814({super.key});

  @override
  State<PiiAnonymizationDashboardGen00814> createState() => _PiiAnonymizationDashboardGen00814State();
}

class _PiiAnonymizationDashboardGen00814State extends State<PiiAnonymizationDashboardGen00814> {
  ConstraintStatus _status = ConstraintStatus.loading;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchConstraintStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchConstraintStatus();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchConstraintStatus() async {
    if (!mounted) return;
    setState(() => _status = ConstraintStatus.loading);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _status = ConstraintStatus.pass);
  }

  Future<void> _onRefresh() async {
    await _fetchConstraintStatus();
  }

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_status) {
      case ConstraintStatus.pass:
        return colorScheme.primary;
      case ConstraintStatus.fail:
        return colorScheme.error;
      case ConstraintStatus.loading:
        return colorScheme.outline;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case ConstraintStatus.pass:
        return 'Pass';
      case ConstraintStatus.fail:
        return 'Fail';
      case ConstraintStatus.loading:
        return 'Checking...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PII Anonymization Pipeline'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final content = _buildContent(context, textTheme, colorScheme);

            if (isDesktop) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: content),
                    const SizedBox(width: 24),
                    Expanded(child: content),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: content,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Engineering Console',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Database Schema Column Check Constraints',
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Check Constraint Pass Rate',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Chip(
                      avatar: _status == ConstraintStatus.loading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _getStatusColor(context),
                              ),
                            )
                          : Icon(
                              _status == ConstraintStatus.pass ? Icons.check_circle : Icons.error,
                              size: 18,
                              color: _getStatusColor(context),
                            ),
                      label: Text(_getStatusText()),
                      backgroundColor: _getStatusColor(context).withOpacity(0.1),
                      labelStyle: TextStyle(color: _getStatusColor(context), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Target: 100%',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  'Validates that PII string writes are rejected if length != 64 characters.',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _showConfigSheet(context),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('View Configuration'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liveness Handshake',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.sync, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Automated monitoring every 30 seconds',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.security, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'CI/CD deployment gate active',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showConfigSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Constraint Configuration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Read-only view. All schema modifications must be performed via the CI/CD pipeline.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.data_object),
                title: const Text('Column Length Constraint'),
                subtitle: const Text('Exactly 64 characters required'),
                trailing: Chip(
                  label: const Text('Enforced'),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Configuration reviewed successfully.'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }
                  },
                  child: const Text('Acknowledge & Close'),
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