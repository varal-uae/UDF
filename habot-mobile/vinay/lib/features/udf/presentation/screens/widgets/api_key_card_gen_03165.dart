// GEN-03165 — Render API keys using Material 3 Outlined Card components on mobile.
// Displays API key data in M3 OutlinedCards with status chips, 48x48dp touch targets,
// single-column layout (<600dp), background polling every 30s, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model representing an API key entry.
class ApiKeyEntry {
  final String id;
  final String name;
  final String keyValue;
  final String status; // 'Active', 'Expired', 'Revoked'
  final DateTime createdAt;

  const ApiKeyEntry({
    required this.id,
    required this.name,
    required this.keyValue,
    required this.status,
    required this.createdAt,
  });
}

/// Hardcoded mock repository simulating backend API response.
class MockApiKeyRepository {
  static const List<ApiKeyEntry> _mockKeys = [
    ApiKeyEntry(
      id: 'key_001',
      name: 'Production API Key',
      keyValue: 'pk_live_9f8e7d6c5b4a3210zyxwvutsrqponmlk',
      status: 'Active',
      createdAt: DateTime(2026, 1, 15),
    ),
    ApiKeyEntry(
      id: 'key_002',
      name: 'Staging API Key',
      keyValue: 'sk_test_1a2b3c4d5e6f7g8h9i0jklmnopqrstuv',
      status: 'Active',
      createdAt: DateTime(2026, 3, 22),
    ),
    ApiKeyEntry(
      id: 'key_003',
      name: 'Legacy Integration Key',
      keyValue: 'pk_legacy_zzz999yyy888xxx777www666vvv555uuu',
      status: 'Expired',
      createdAt: DateTime(2024, 11, 5),
    ),
    ApiKeyEntry(
      id: 'key_004',
      name: 'Partner Webhook Key',
      keyValue: 'whsec_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6',
      status: 'Revoked',
      createdAt: DateTime(2025, 8, 10),
    ),
  ];

  Future<List<ApiKeyEntry>> fetchApiKeys() async {
    // Simulate sub-100ms network latency
    await Future.delayed(const Duration(milliseconds: 80));
    return _mockKeys;
  }
}

/// Main widget rendering API keys using M3 Outlined Cards.
/// Implements background polling (30s) and pull-to-refresh.
class ApiKeyCardList extends StatefulWidget {
  const ApiKeyCardList({super.key});

  @override
  State<ApiKeyCardList> createState() => _ApiKeyCardListState();
}

class _ApiKeyCardListState extends State<ApiKeyCardList> {
  final MockApiKeyRepository _repository = MockApiKeyRepository();
  List<ApiKeyEntry> _apiKeys = [];
  bool _isLoading = true;
  String? _error;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Background polling refreshes data every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadData(showLoading: false);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final keys = await _repository.fetchApiKeys();
      if (mounted) {
        setState(() {
          _apiKeys = keys;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'active':
        return theme.colorScheme.primary;
      case 'expired':
        return theme.colorScheme.error;
      case 'revoked':
        return theme.colorScheme.outline;
      default:
        return theme.colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load API keys', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            // 48x48dp touch target
            SizedBox(
              height: 48,
              width: 48,
              child: IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Retry',
              ),
            ),
          ],
        ),
      );
    }

    // Pull-to-refresh triggers manual sync
    return RefreshIndicator(
      onRefresh: () => _loadData(showLoading: false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // M3 responsive layout: single-column on mobile (<600dp)
          final isMobile = constraints.maxWidth < 600;
          final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 2 : 1);

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: isMobile ? 3.2 : 3.5,
            ),
            itemCount: _apiKeys.length,
            itemBuilder: (context, index) {
              final keyEntry = _apiKeys[index];
              return _ApiKeyOutlinedCard(
                entry: keyEntry,
                statusColor: _getStatusColor(keyEntry.status, theme),
                onDeepLink: () {
                  // M3 Snackbar for confirmations / deep-link drill-down simulation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Drill-down triggered for ${keyEntry.name}'),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'DISMISS',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Individual M3 Outlined Card component for a single API key.
class _ApiKeyOutlinedCard extends StatelessWidget {
  final ApiKeyEntry entry;
  final Color statusColor;
  final VoidCallback onDeepLink;

  const _ApiKeyOutlinedCard({
    required this.entry,
    required this.statusColor,
    required this.onDeepLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maskedKey = entry.keyValue.length > 12
        ? '${entry.keyValue.substring(0, 8)}...${entry.keyValue.substring(entry.keyValue.length - 4)}'
        : entry.keyValue;

    // M3 Outlined Card
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDeepLink,
        // 48x48dp minimum touch target enforced by parent grid aspect ratio
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // M3 Status Chip for health indicator
                  _StatusChip(
                    label: entry.status,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                maskedKey,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Created: ${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom M3-style Status Chip.
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.4), width: 1.0),
      ),
      // Ensures minimum touch target area if interacted independently
      constraints: const BoxConstraints(minHeight: 32),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
