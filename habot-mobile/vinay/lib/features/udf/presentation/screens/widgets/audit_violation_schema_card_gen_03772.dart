// GEN-03772 — Audit Violation Schema Alignment Status Card.
// Displays a read-only M3 Elevated Card with inline status chip for audit violation schema alignment in the engineering console. Single-column mobile (<600dp), multi-column desktop (>=840dp). 48x48dp touch targets. Background polling every 30s, pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum SchemaAlignmentStatus { pass, fail, pending }

class AuditViolationSchemaModel {
  final String moduleId;
  final String moduleName;
  final SchemaAlignmentStatus status;
  final DateTime lastChecked;

  const AuditViolationSchemaModel({
    required this.moduleId,
    required this.moduleName,
    required this.status,
    required this.lastChecked,
  });
}

class MockAuditViolationRepository {
  static List<AuditViolationSchemaModel> fetchSchemas() {
    final now = DateTime.now();
    return [
      AuditViolationSchemaModel(
        moduleId: 'MOD-001',
        moduleName: 'Authentication',
        status: SchemaAlignmentStatus.pass,
        lastChecked: now.subtract(const Duration(minutes: 2)),
      ),
      AuditViolationSchemaModel(
        moduleId: 'MOD-002',
        moduleName: 'Billing',
        status: SchemaAlignmentStatus.pass,
        lastChecked: now.subtract(const Duration(minutes: 5)),
      ),
      AuditViolationSchemaModel(
        moduleId: 'MOD-003',
        moduleName: 'Telemetry',
        status: SchemaAlignmentStatus.fail,
        lastChecked: now.subtract(const Duration(minutes: 1)),
      ),
      AuditViolationSchemaModel(
        moduleId: 'MOD-004',
        moduleName: 'UDF Core',
        status: SchemaAlignmentStatus.pending,
        lastChecked: now.subtract(const Duration(minutes: 10)),
      ),
    ];
  }
}

class AuditViolationSchemaCard extends StatefulWidget {
  const AuditViolationSchemaCard({super.key});

  @override
  State<AuditViolationSchemaCard> createState() => _AuditViolationSchemaCardState();
}

class _AuditViolationSchemaCardState extends State<AuditViolationSchemaCard> {
  late List<AuditViolationSchemaModel> _schemas;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _schemas = MockAuditViolationRepository.fetchSchemas();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _schemas = MockAuditViolationRepository.fetchSchemas();
        _isRefreshing = false;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _statusColor(SchemaAlignmentStatus status, ColorScheme cs) {
    switch (status) {
      case SchemaAlignmentStatus.pass:
        return cs.primary;
      case SchemaAlignmentStatus.fail:
        return cs.error;
      case SchemaAlignmentStatus.pending:
        return cs.tertiary;
    }
  }

  String _statusLabel(SchemaAlignmentStatus status) {
    switch (status) {
      case SchemaAlignmentStatus.pass:
        return 'Pass';
      case SchemaAlignmentStatus.fail:
        return 'Fail';
      case SchemaAlignmentStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;
        final crossAxisCount = isDesktop ? 2 : 1;

        return RefreshIndicator(
          onRefresh: _refreshData,
          color: cs.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Audit Violation Schema Alignment',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_isRefreshing)
                const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isDesktop ? 2.5 : 3.0,
                  ),
                  itemCount: _schemas.length,
                  itemBuilder: (context, index) {
                    final schema = _schemas[index];
                    return _buildSchemaCard(schema, cs, theme);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchemaCard(
    AuditViolationSchemaModel schema,
    ColorScheme cs,
    ThemeData theme,
  ) {
    return Card(
      elevation: 3,
      surfaceTintColor: cs.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drill-down for \${schema.moduleName}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
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
                      schema.moduleName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      _statusLabel(schema.status),
                      style: TextStyle(
                        color: _statusColor(schema.status, cs),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _statusColor(schema.status, cs).withOpacity(0.12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.extension_outlined,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    schema.moduleId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Checked: \${_formatTime(schema.lastChecked)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
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

  String _formatTime(DateTime dt) {
    return '\${dt.hour.toString().padLeft(2, '0')}:\${dt.minute.toString().padLeft(2, '0')}';
  }
}
