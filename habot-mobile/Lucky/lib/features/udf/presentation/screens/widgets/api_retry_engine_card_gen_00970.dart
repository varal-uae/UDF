// GEN-00970 — Real-Time Mobile Ad Spend Pacing & Auto-Pause Execution Engine with Exponential Backoff Retry.
// Implements M3 Elevated Card (Level 2, 3dp) with status chips, background polling every 30s, pull-to-refresh, and mock API retry logic for ad platform pause calls.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Mock data model representing an ad spend pacing execution step.
class AdPacingStep {
  final String id;
  final String name;
  final bool isCompleted;
  final int retryCount;
  final String status; // 'Pass', 'Fail', 'Retrying'

  const AdPacingStep({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.retryCount,
    required this.status,
  });
}

/// Mock repository simulating backend API interactions with exponential backoff.
class MockAdPlatformRepository {
  static const int maxRetryLimit = 5;

  Future<bool> attemptPauseAdCampaign(String campaignId) async {
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms latency simulation
    final random = Random();
    // Simulate occasional failures to trigger retry logic
    return random.nextDouble() > 0.3;
  }

  /// Executes the automated retry logic with exponential backoff.
  Future<AdPacingStep> executeWithExponentialBackoff(AdPacingStep step) async {
    int currentAttempt = 0;
    bool success = false;

    while (currentAttempt < maxRetryLimit && !success) {
      success = await attemptPauseAdCampaign(step.id);
      if (!success) {
        currentAttempt++;
        if (currentAttempt < maxRetryLimit) {
          // Exponential backoff: 2^attempt * baseDelay (simulated shorter for UI demo)
          final backoffMs = pow(2, currentAttempt).toInt() * 100;
          await Future.delayed(Duration(milliseconds: backoffMs));
        }
      }
    }

    return AdPacingStep(
      id: step.id,
      name: step.name,
      isCompleted: success,
      retryCount: currentAttempt,
      status: success ? 'Pass' : 'Fail',
    );
  }
}

/// Main widget implementing the GEN-00970 requirement.
/// Displays M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
class ApiRetryEngineCardGen00970 extends StatefulWidget {
  const ApiRetryEngineCardGen00970({super.key});

  @override
  State<ApiRetryEngineCardGen00970> createState() => _ApiRetryEngineCardGen00970State();
}

class _ApiRetryEngineCardGen00970State extends State<ApiRetryEngineCardGen00970> {
  final MockAdPlatformRepository _repository = MockAdPlatformRepository();
  late List<AdPacingStep> _steps;
  Timer? _pollingTimer;
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _startBackgroundPolling();
  }

  void _initializeMockData() {
    _steps = [
      const AdPacingStep(id: 'CMP-001', name: 'Auto-Pause Campaign Alpha', isCompleted: true, retryCount: 0, status: 'Pass'),
      const AdPacingStep(id: 'CMP-002', name: 'Auto-Pause Campaign Beta', isCompleted: false, retryCount: 2, status: 'Retrying'),
      const AdPacingStep(id: 'CMP-003', name: 'Auto-Pause Campaign Gamma', isCompleted: false, retryCount: 5, status: 'Fail'),
    ];
  }

  void _startBackgroundPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isPolling) {
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isPolling = false);
    
    final updatedSteps = <AdPacingStep>[];
    for (final step in _steps) {
      if (!step.isCompleted && step.status != 'Fail') {
        final result = await _repository.executeWithExponentialBackoff(step);
        updatedSteps.add(result);
      } else {
        updatedSteps.add(step);
      }
    }

    if (mounted) {
      setState(() {
        _steps = updatedSteps;
        _isPolling = true;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useMaterial3: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration Inputs', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('API Retry Limit: ${MockAdPlatformRepository.maxRetryLimit} attempts',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              const Text('Standard: SRE Resilience Patterns'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch target
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configuration saved successfully.')),
                    );
                  },
                  child: const Text('Apply Configuration'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'Pass':
        return colorScheme.primary;
      case 'Fail':
        return colorScheme.error;
      case 'Retrying':
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Spend Pacing Engine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showConfigBottomSheet(context),
            tooltip: 'Configuration',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
            final isDesktop = constraints.maxWidth >= 840;
            final crossAxisCount = isDesktop ? 2 : 1;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isDesktop ? 2.5 : 3.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final step = _steps[index];
                        return _buildStepCard(step, colorScheme, textTheme);
                      },
                      childCount: _steps.length,
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

  Widget _buildStepCard(AdPacingStep step, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Deep-link drill-down simulation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Drilling down into ${step.name}...')),
          );
        },
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
                      step.name,
                      style: textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // M3 Status Chips for health indicators
                  Chip(
                    label: Text(step.status),
                    backgroundColor: _getStatusColor(step.status, colorScheme).withOpacity(0.15),
                    labelStyle: TextStyle(color: _getStatusColor(step.status, colorScheme)),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ID: ${step.id}', style: textTheme.bodySmall),
                  Text('Retries: ${step.retryCount}/${MockAdPlatformRepository.maxRetryLimit}',
                      style: textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}