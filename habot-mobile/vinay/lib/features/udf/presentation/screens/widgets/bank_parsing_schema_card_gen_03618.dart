// GEN-03618 — Bank Parsing Schema Alignment Status Card.
// Displays CAMT.053 / MT940 schema alignment health via M3 Elevated Card with 30s background polling and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum SchemaStatus { pass, fail }

class BankParsingSchemaModel {
  final String schemaName;
  final String standard;
  final double alignmentScore;
  final SchemaStatus status;
  final DateTime lastChecked;

  const BankParsingSchemaModel({
    required this.schemaName,
    required this.standard,
    required this.alignmentScore,
    required this.status,
    required this.lastChecked,
  });
}

class MockBankParsingRepository {
  static List<BankParsingSchemaModel> fetchSchemas() {
    return [
      BankParsingSchemaModel(
        schemaName: 'Corporate Account Statement',
        standard: 'CAMT.053',
        alignmentScore: 0.995,
        status: SchemaStatus.pass,
        lastChecked: DateTime.now(),
      ),
      BankParsingSchemaModel(
        schemaName: 'Legacy SWIFT Statement',
        standard: 'MT940',
        alignmentScore: 0.991,
        status: SchemaStatus.pass,
        lastChecked: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      BankParsingSchemaModel(
        schemaName: 'Partner Bank Reconciliation',
        standard: 'CAMT.053',
        alignmentScore: 0.870,
        status: SchemaStatus.fail,
        lastChecked: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}

class BankParsingSchemaCardGen03618 extends StatefulWidget {
  const BankParsingSchemaCardGen03618({super.key});

  @override
  State<BankParsingSchemaCardGen03618> createState() => _BankParsingSchemaCardGen03618State();
}

class _BankParsingSchemaCardGen03618State extends State<BankParsingSchemaCardGen03618> {
  late List<BankParsingSchemaModel> _schemas;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _schemas = MockBankParsingRepository.fetchSchemas();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (!mounted || _isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      setState(() {
        _schemas = MockBankParsingRepository.fetchSchemas();
        _isRefreshing = false;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: theme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16.0 : 24.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Parsing Schema Alignment',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Engineering Console • Read-Only KPI',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (isMobile)
              ..._schemas.map((s) => _buildSchemaCard(context, s))
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _schemas.map((s) => SizedBox(
                  width: 380,
                  child: _buildSchemaCard(context, s),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemaCard(BuildContext context, BankParsingSchemaModel schema) {
    final theme = Theme.of(context);
    final isPass = schema.status == SchemaStatus.pass;
    final meetsFloor = schema.alignmentScore >= 0.99;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 3.0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {},
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                        schema.schemaName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Chip(
                      avatar: Icon(
                        isPass && meetsFloor ? Icons.check_circle : Icons.error,
                        size: 18,
                        color: isPass && meetsFloor
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onErrorContainer,
                      ),
                      label: Text(
                        isPass && meetsFloor ? 'PASS' : 'FAIL',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPass && meetsFloor
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onErrorContainer,
                        ),
                      ),
                      backgroundColor: isPass && meetsFloor
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.errorContainer,
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.description_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Standard: ${schema.standard}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.trending_up, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Alignment: ${(schema.alignmentScore * 100).toStringAsFixed(2)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Floor: 99.00%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: schema.alignmentScore.clamp(0.0, 1.0),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    meetsFloor ? theme.colorScheme.primary : theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Last checked: ${_formatTime(schema.lastChecked)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
