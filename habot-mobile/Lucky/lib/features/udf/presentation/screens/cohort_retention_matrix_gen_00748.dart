// GEN-00748 — Automated Mobile Cohort Retention Matrix Engine UI.
// Implements M3 responsive layout with single-column on mobile (<600dp) and multi-column on desktop (>=840dp), featuring Elevated Cards Level 2, Status Chips, Bottom Sheet configuration, pull-to-refresh, and 30-second background polling.

import 'dart:async';
import 'package:flutter/material.dart';

enum SegmentationStatus { complete, notComplete }

class CohortSegmentationData {
  final String utmSource;
  final String adCreative;
  final String os;
  final SegmentationStatus status;
  final double accuracy;

  const CohortSegmentationData({
    required this.utmSource,
    required this.adCreative,
    required this.os,
    required this.status,
    required this.accuracy,
  });
}

class CohortRetentionMatrixScreen extends StatefulWidget {
  const CohortRetentionMatrixScreen({super.key});

  @override
  State<CohortRetentionMatrixScreen> createState() => _CohortRetentionMatrixScreenState();
}

class _CohortRetentionMatrixScreenState extends State<CohortRetentionMatrixScreen> {
  Timer? _pollingTimer;
  bool _isSyncing = false;
  List<CohortSegmentationData> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isSyncing = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _data = [
        const CohortSegmentationData(
          utmSource: 'google_ads',
          adCreative: 'summer_campaign_v1',
          os: 'iOS',
          status: SegmentationStatus.complete,
          accuracy: 1.0,
        ),
        const CohortSegmentationData(
          utmSource: 'meta_social',
          adCreative: 'retarget_q3',
          os: 'Android',
          status: SegmentationStatus.notComplete,
          accuracy: 0.98,
        ),
      ];
      _isSyncing = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manual sync completed successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openConfigBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration Inputs',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Masking Input Field',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Apply Configuration'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cohort Retention Matrix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Open Configuration',
            onPressed: () => _openConfigBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 840;

            if (_isSyncing && _data.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final gridView = GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isDesktop ? 2.5 : 3.0,
              ),
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final item = _data[index];
                return _buildM3ElevatedCard(context, item);
              },
            );

            return Stack(
              children: [
                gridView,
                if (_isSyncing)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildM3ElevatedCard(BuildContext context, CohortSegmentationData item) {
    final theme = Theme.of(context);
    final bool isComplete = item.status == SegmentationStatus.complete;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.os} • ${item.utmSource}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(
                      isComplete ? Icons.check_circle_outline : Icons.error_outline,
                      size: 18,
                      color: isComplete ? Colors.green : Colors.red,
                    ),
                    label: Text(
                      isComplete ? 'Complete' : 'Not Complete',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isComplete ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    backgroundColor: isComplete
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Ad Creative: ${item.adCreative}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Segmentation Accuracy:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(item.accuracy * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.accuracy >= 1.0
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
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
}