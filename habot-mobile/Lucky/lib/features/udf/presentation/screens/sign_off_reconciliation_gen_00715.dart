// GEN-00715 — End-to-End Mobile Lineage & Design Reconciliation Verification Screen.
// Displays read-only M3 Elevated Cards with status chips for sign-off authorization, supporting 30s background polling and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum SignOffStatus { complete, notComplete, pending }

class SignOffReconciliationScreen extends StatefulWidget {
  const SignOffReconciliationScreen({super.key});

  @override
  State<SignOffReconciliationScreen> createState() => _SignOffReconciliationScreenState();
}

class _SignOffReconciliationScreenState extends State<SignOffReconciliationScreen> {
  SignOffStatus _status = SignOffStatus.pending;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchSignOffStatus();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && !_isRefreshing) {
        _fetchSignOffStatus();
      }
    });
  }

  Future<void> _fetchSignOffStatus() async {
    // Simulated API call to fetch Executive Governance Sign-Off status
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    setState(() {
      // Deterministic mock: replace with actual repository call
      _status = SignOffStatus.complete;
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _fetchSignOffStatus();
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sign-off status synchronized'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(SignOffStatus status, ColorScheme colorScheme) {
    switch (status) {
      case SignOffStatus.complete:
        return colorScheme.primary;
      case SignOffStatus.notComplete:
        return colorScheme.error;
      case SignOffStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _getStatusLabel(SignOffStatus status) {
    switch (status) {
      case SignOffStatus.complete:
        return 'Authorized';
      case SignOffStatus.notComplete:
        return 'Not Complete';
      case SignOffStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Reconciliation Sign-Off'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final crossAxisCount = isDesktop ? 2 : 1;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isDesktop ? 2.5 : 2.0,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildKpiCard(colorScheme, textTheme),
                      _buildMetricCard(colorScheme, textTheme),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpiCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () => _showDetailBottomSheet(),
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
                      'Sign-Off Authorization Status',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _buildStatusChip(colorScheme),
                ],
              ),
              const Spacer(),
              Text(
                'Executive Governance Sign-Off',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                _status == SignOffStatus.complete ? 'Complete' : 'Not Complete',
                style: textTheme.headlineSmall?.copyWith(
                  color: _getStatusColor(_status, colorScheme),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Design Reconciliation Score',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              'Target: 0',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              _status == SignOffStatus.complete ? '0 (Achieved)' : 'Pending',
              style: textTheme.headlineSmall?.copyWith(
                color: _status == SignOffStatus.complete
                    ? colorScheme.primary
                    : colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    return Chip(
      avatar: Icon(
        _status == SignOffStatus.complete
            ? Icons.check_circle_outline
            : _status == SignOffStatus.notComplete
                ? Icons.cancel_outlined
                : Icons.pending_outlined,
        size: 18.0,
        color: _getStatusColor(_status, colorScheme),
      ),
      label: Text(
        _getStatusLabel(_status),
        style: TextStyle(
          color: _getStatusColor(_status, colorScheme),
          fontWeight: FontWeight.w600,
          fontSize: 12.0,
        ),
      ),
      backgroundColor: _getStatusColor(_status, colorScheme).withOpacity(0.12),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showDetailBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Step Details - GEN-00715',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildDetailRow('Atomic ID', 'GEN-00715'),
                        _buildDetailRow('Status', _getStatusLabel(_status)),
                        _buildDetailRow('Metric', 'Sign-Off Authorization Status'),
                        _buildDetailRow('Floor Boundary', 'Authorized'),
                        _buildDetailRow('Dependency', 'GEN-00714'),
                        _buildDetailRow('Estimated Time', '4 Hours'),
                        _buildDetailRow('Output', _status == SignOffStatus.complete ? 'Complete' : 'Not Complete'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.0,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}