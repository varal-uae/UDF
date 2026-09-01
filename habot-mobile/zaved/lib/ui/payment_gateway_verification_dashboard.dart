// ============================================================================
// TELEMETRY & SUS METADATA BLOCK
// Step Execution ID: NQSDV-003-EXEC-7721
// Execution Status: Verified / Active
// Execution Timestamp: 2026-08-17T09:48:10Z
// Step Outcome: High-Contrast Payment Gateway Dashboard Initialized
// User ID: FIN-OPS-ANALYST-04
// System Usability Scale Completion Status: Good (Target: SUS > 90)
// ============================================================================

import 'package:flutter/material.dart';

/// NQSDV-003: Payment Gateway Verification Dashboard & High-Contrast Cards
class PaymentGatewayVerificationDashboard extends StatefulWidget {
  const PaymentGatewayVerificationDashboard({super.key});

  @override
  State<PaymentGatewayVerificationDashboard> createState() =>
      _PaymentGatewayVerificationDashboardState();
}

class GatewayMetrics {
  final String providerName;
  final String transactionId;
  final String volume;
  final String successRate;
  final String settlementStatus;
  final IconData icon;

  GatewayMetrics({
    required this.providerName,
    required this.transactionId,
    required this.volume,
    required this.successRate,
    required this.settlementStatus,
    required this.icon,
  });
}

class _PaymentGatewayVerificationDashboardState
    extends State<PaymentGatewayVerificationDashboard> {
  bool _hasConnectionError = false; // Mock Security Notification State

  final List<GatewayMetrics> _gatewayCards = [
    GatewayMetrics(
      providerName: 'Stripe Global Gateway',
      transactionId: 'TXN-90218-STP',
      volume: '\$142,500.00',
      successRate: '99.98%',
      settlementStatus: 'Settled (T+0)',
      icon: Icons.credit_card,
    ),
    GatewayMetrics(
      providerName: 'Adyen Enterprise Node',
      transactionId: 'TXN-44102-ADY',
      volume: '\$98,200.00',
      successRate: '99.94%',
      settlementStatus: 'Settled (T+0)',
      icon: Icons.account_balance,
    ),
    GatewayMetrics(
      providerName: 'PayPal Merchant Core',
      transactionId: 'TXN-88123-PYP',
      volume: '\$64,800.00',
      successRate: '99.85%',
      settlementStatus: 'Pending Batch (T+1)',
      icon: Icons.account_balance_wallet,
    ),
    GatewayMetrics(
      providerName: 'Square POS Terminal Link',
      transactionId: 'TXN-30941-SQR',
      volume: '\$32,150.00',
      successRate: '99.90%',
      settlementStatus: 'Settled (T+0)',
      icon: Icons.point_of_sale,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NQSDV-003: Gateway Verification'),
        elevation: 2,
        actions: [
          // Security Alert Simulator Toggle
          Row(
            children: [
              Text(
                'Conn Alert:',
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _hasConnectionError,
                activeThumbColor: theme.colorScheme.error,
                onChanged: (val) {
                  setState(() {
                    _hasConnectionError = val;
                  });
                  if (val) {
                    _showNonBlockingAlert(theme);
                  }
                },
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // 2. Non-Blocking Security Notification (Inline MaterialBanner)
          if (_hasConnectionError)
            MaterialBanner(
              elevation: 2,
              padding: const EdgeInsets.all(12),
              leading: Icon(Icons.warning_amber_rounded,
                  color: theme.colorScheme.error, size: 28),
              backgroundColor: theme.colorScheme.errorContainer,
              content: Text(
                'NON-BLOCKING ALERT: Gateway handshake timeout detected on Adyen Enterprise Node. Secondary fallback active.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hasConnectionError = false;
                    });
                  },
                  child: Text(
                    'DISMISS BANNER',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),

          // 3. Responsive Architecture Layout (ListView vs GridView)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth <= 600;

                return isCompact
                    ? _buildMobileList(theme)
                    : _buildWideGrid(theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Non-Blocking SnackBar Notification (Strict Zero AlertDialogs)
  void _showNonBlockingAlert(ThemeData theme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: theme.colorScheme.error,
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: theme.colorScheme.onError),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Non-blocking connection alert triggered. System remains operational.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile Layout (maxWidth <= 600): Single-column ListView
  Widget _buildMobileList(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _gatewayCards.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return VerificationStatusCard(metrics: _gatewayCards[index]);
      },
    );
  }

  /// Tablet/Web Layout (maxWidth > 600): Dynamic GridView
  Widget _buildWideGrid(ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400.0,
        mainAxisExtent: 220.0,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: _gatewayCards.length,
      itemBuilder: (context, index) {
        return VerificationStatusCard(metrics: _gatewayCards[index]);
      },
    );
  }
}

/// 1. High-Contrast Status Card Component (VerificationStatusCard)
class VerificationStatusCard extends StatelessWidget {
  final GatewayMetrics metrics;

  const VerificationStatusCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Strict 16.0 Padding Requirement
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header Provider Name
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Icon(metrics.icon, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metrics.providerName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        metrics.transactionId,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Interface Separation Line 1 (Divider height: 1, thickness: 1)
            const Divider(height: 1, thickness: 1),

            // Financial Metrics Data Point (titleLarge bold for high contrast)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '24h Volume:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  metrics.volume,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, // High Contrast Metric
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            // Interface Separation Line 2 (Divider height: 1, thickness: 1)
            const Divider(height: 1, thickness: 1),

            // Secondary Data Points (Success Rate & Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Success Rate: ${metrics.successRate}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.colorScheme.primary),
                  ),
                  child: Text(
                    metrics.settlementStatus,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
