// GEN-03750 — High-Value Accrual Proposal Mobile Review Screen.
// Implements one-touch review routing for cost-center managers with M3 Elevated Cards, status chips, 30s polling, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum ProposalStatus { pending, approved, rejected }

class AccrualProposal {
  final String id;
  final String title;
  final String costCenter;
  final double amount;
  final ProposalStatus status;
  final DateTime submittedAt;

  const AccrualProposal({
    required this.id,
    required this.title,
    required this.costCenter,
    required this.amount,
    required this.status,
    required this.submittedAt,
  });
}

class MockAccrualRepository {
  static List<AccrualProposal> fetchProposals() {
    return [
      AccrualProposal(
        id: 'ACC-1001',
        title: 'Q3 Infrastructure Upgrade',
        costCenter: 'CC-ENG-01',
        amount: 125000.00,
        status: ProposalStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AccrualProposal(
        id: 'ACC-1002',
        title: 'Vendor Settlement - Cloud Services',
        costCenter: 'CC-OPS-04',
        amount: 84000.50,
        status: ProposalStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AccrualProposal(
        id: 'ACC-1003',
        title: 'Annual Compliance Audit Fees',
        costCenter: 'CC-FIN-02',
        amount: 45000.00,
        status: ProposalStatus.approved,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

class HighValueAccrualReviewScreen extends StatefulWidget {
  const HighValueAccrualReviewScreen({super.key});

  @override
  State<HighValueAccrualReviewScreen> createState() => _HighValueAccrualReviewScreenState();
}

class _HighValueAccrualReviewScreenState extends State<HighValueAccrualReviewScreen> {
  late List<AccrualProposal> _proposals;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _proposals = MockAccrualRepository.fetchProposals();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    _loadData();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  void _showActionSheet(BuildContext context, AccrualProposal proposal) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Review: ${proposal.title}',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Amount: \$${proposal.amount.toStringAsFixed(2)}'),
                Text('Cost Center: ${proposal.costCenter}'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _updateStatus(proposal, ProposalStatus.approved);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Approve'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _updateStatus(proposal, ProposalStatus.rejected);
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Reject'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateStatus(AccrualProposal proposal, ProposalStatus newStatus) {
    setState(() {
      final index = _proposals.indexWhere((p) => p.id == proposal.id);
      if (index != -1) {
        _proposals[index] = AccrualProposal(
          id: proposal.id,
          title: proposal.title,
          costCenter: proposal.costCenter,
          amount: proposal.amount,
          status: newStatus,
          submittedAt: proposal.submittedAt,
        );
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Proposal ${proposal.id} ${newStatus.name}.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _getStatusColor(ProposalStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ProposalStatus.pending:
        return colorScheme.tertiary;
      case ProposalStatus.approved:
        return colorScheme.primary;
      case ProposalStatus.rejected:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accrual Proposals'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
            tooltip: 'Engineering Console Info',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 2 : 1);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isMobile ? 2.8 : 3.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final proposal = _proposals[index];
                        return Card(
                          elevation: 3.0,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: proposal.status == ProposalStatus.pending
                                ? () => _showActionSheet(context, proposal)
                                : null,
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
                                          proposal.title,
                                          style: Theme.of(context).textTheme.titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Chip(
                                        label: Text(
                                          proposal.status.name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusColor(proposal.status, colorScheme),
                                          ),
                                        ),
                                        backgroundColor: _getStatusColor(proposal.status, colorScheme).withOpacity(0.1),
                                        side: BorderSide.none,
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '\$${proposal.amount.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Icon(Icons.business, size: 16, color: colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        proposal.costCenter,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _proposals.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}