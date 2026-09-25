// SMCS-009 — Automated Campaign ID Token Mapping Generation Module Configuration & SSL Policy Dashboard.
// Implements Material 3 diagnostic variance dashboards for connection protocol metrics, enforcing TLS 1.3 standards with mock configuration data.

import 'package:flutter/material.dart';

/// Represents a single SSL/TLS configuration entry.
class SslConfigEntry {
  final String configurationKey;
  final String configurationValue;
  final String configurationType;
  final bool validationStatus;
  final DateTime configurationTimestamp;

  const SslConfigEntry({
    required this.configurationKey,
    required this.configurationValue,
    required this.configurationType,
    required this.validationStatus,
    required this.configurationTimestamp,
  });
}

/// Mock repository providing local data for the SSL Policy dashboard.
class MockSslConfigRepository {
  static List<SslConfigEntry> getConfigurations() {
    return [
      SslConfigEntry(
        configurationKey: 'MIN_TLS_VERSION',
        configurationValue: 'TLS_1_3',
        configurationType: 'Protocol',
        validationStatus: true,
        configurationTimestamp: DateTime(2026, 9, 25, 10, 0),
      ),
      SslConfigEntry(
        configurationKey: 'CAMPAIGN_TOKEN_MAPPING_MODE',
        configurationValue: 'AUTOMATED_1_TO_1',
        configurationType: 'Mapping',
        validationStatus: true,
        configurationTimestamp: DateTime(2026, 9, 25, 10, 5),
      ),
      SslConfigEntry(
        configurationKey: 'CIPHER_SUITE_POLICY',
        configurationValue: 'MODERN_ONLY',
        configurationType: 'Security',
        validationStatus: true,
        configurationTimestamp: DateTime(2026, 9, 24, 14, 30),
      ),
      SslConfigEntry(
        configurationKey: 'ORPHANED_TOKEN_VALIDATION',
        configurationValue: 'STRICT_DROP',
        configurationType: 'Validation',
        validationStatus: false,
        configurationTimestamp: DateTime(2026, 9, 23, 9, 15),
      ),
    ];
  }

  static double getUnmappedTokenClickRate() => 0.000008;
}

/// Main screen implementing the diagnostic variance dashboard.
class SslPolicyDashboardScreenSmcs009 extends StatelessWidget {
  const SslPolicyDashboardScreenSmcs009({super.key});

  @override
  Widget build(BuildContext context) {
    final configs = MockSslConfigRepository.getConfigurations();
    final unmappedRate = MockSslConfigRepository.getUnmappedTokenClickRate();
    final isOptimal = unmappedRate <= 0.00001;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SSL Policy & Token Mapping'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success accent highlight for conversion/metrics
            Card(
              color: isOptimal
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      isOptimal ? Icons.verified_user : Icons.warning_amber_rounded,
                      color: isOptimal
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unmapped Token Click Rate',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isOptimal
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onErrorContainer,
                                ),
                          ),
                          Text(
                            '${(unmappedRate * 100).toStringAsFixed(5)}%',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isOptimal
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onErrorContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Protocol Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Material 3 Grid components organizing analytical card breakdowns
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: configs.length,
                  itemBuilder: (context, index) {
                    final config = configs[index];
                    return _SslConfigCard(config: config);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual configuration card using OutlinedCard and monospace typography for values.
class _SslConfigCard extends StatelessWidget {
  final SslConfigEntry config;

  const _SslConfigCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    config.configurationKey,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  config.validationStatus ? Icons.lock_outline : Icons.lock_open,
                  size: 18,
                  color: config.validationStatus
                      ? colorScheme.primary
                      : colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Monospace data typography scales (md.sys.typescale.body-small)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                config.configurationValue,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Type: ${config.configurationType}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}