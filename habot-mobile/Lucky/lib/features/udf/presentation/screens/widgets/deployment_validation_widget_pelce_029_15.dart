// PELCE-029-15 — Deployment Validation Dashboard Widget.
// Enforces the rule: Requirements Defined - Logic Documented = 0. Displays a sticky dashboard widget with large typography, green for 0 and red for >0, halting forward navigation until validation passes.

import 'package:flutter/material.dart';

/// Mock data model representing deployment and requirement tracking fields.
class DeploymentValidationData {
  final String deploymentStatus;
  final String deploymentEnvironment;
  final DateTime deploymentDate;
  final String deploymentVersion;
  final bool rollbackStatus;
  final int requirementsDefined;
  final int logicDocumented;
  final List<String> missingLogicChunks;

  const DeploymentValidationData({
    required this.deploymentStatus,
    required this.deploymentEnvironment,
    required this.deploymentDate,
    required this.deploymentVersion,
    required this.rollbackStatus,
    required this.requirementsDefined,
    required this.logicDocumented,
    required this.missingLogicChunks,
  });

  int get difference => requirementsDefined - logicDocumented;
  bool get isValid => difference == 0;
}

/// Local mock repository providing realistic dummy data.
class MockDeploymentRepository {
  static DeploymentValidationData fetchMockData() {
    return DeploymentValidationData(
      deploymentStatus: 'Pending Review',
      deploymentEnvironment: 'Staging',
      deploymentDate: DateTime(2026, 9, 23),
      deploymentVersion: '1.4.0-build.33866',
      rollbackStatus: false,
      requirementsDefined: 12,
      logicDocumented: 10,
      missingLogicChunks: [
        'Authentication flow edge-case handling',
        'Telemetry payload batching logic',
      ],
    );
  }
}

/// A sticky dashboard widget that enforces deployment validation rules.
/// Halts forward navigation if `Requirements Defined - Logic Documented != 0`.
class DeploymentValidationWidget extends StatelessWidget {
  final DeploymentValidationData data;
  final VoidCallback? onReleaseToTechPressed;

  const DeploymentValidationWidget({
    super.key,
    required this.data,
    this.onReleaseToTechPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isValid = data.isValid;
    final diff = data.difference;

    final indicatorColor = isValid ? Colors.green : Colors.red;
    final statusText = isValid ? 'Good (100%)' : 'Poor (${diff > 0 ? '+' : ''}$diff)';

    return Material(
      elevation: 4.0,
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () => _showMissingLogicDetails(context),
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deployment Validation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isValid ? Icons.check_circle : Icons.error,
                    color: indicatorColor,
                    size: 28.0,
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // Large typography for the resulting score
              Center(
                child: Text(
                  statusText,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: indicatorColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 48.0,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              // Explicit warning banner if validation fails
              if (!isValid)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'System Halted: ${data.missingLogicChunks.length} logic chunk(s) missing. Tap to view details.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              // Target the "Release to Tech" deployment button state
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isValid ? onReleaseToTechPressed : null,
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Release to Tech'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isValid ? colorScheme.primary : colorScheme.surfaceVariant,
                    foregroundColor: isValid ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissingLogicDetails(BuildContext context) {
    if (data.isValid) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
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
                  const SizedBox(height: 16.0),
                  Text(
                    'Missing Logic Chunks',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Requirements Defined: ${data.requirementsDefined}\n'
                    'Logic Documented: ${data.logicDocumented}\n'
                    'Difference: ${data.difference}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 32.0),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: data.missingLogicChunks.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(data.missingLogicChunks[index]),
                          contentPadding: EdgeInsets.zero,
                        );
                      },
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
}

/// Example screen demonstrating sticky placement near the primary action button.
class DeploymentValidationScreen extends StatelessWidget {
  const DeploymentValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = MockDeploymentRepository.fetchMockData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Deployment Dashboard'),
      ),
      body: Stack(
        children: [
          // Background content simulating form or other UI elements
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deployment Environment: ${mockData.deploymentEnvironment}',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8.0),
                      Text('Version: ${mockData.deploymentVersion}',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8.0),
                      Text('Date: ${mockData.deploymentDate.toIso8601String().split('T').first}',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8.0),
                      Text('Rollback Status: ${mockData.rollbackStatus ? 'Active' : 'None'}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              // Add extra space so sticky widget doesn't overlap content
              const SizedBox(height: 300.0),
            ],
          ),
          // Sticky placement near the primary action button (bottom of screen)
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
            child: DeploymentValidationWidget(
              data: mockData,
              onReleaseToTechPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Released to Tech successfully!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
