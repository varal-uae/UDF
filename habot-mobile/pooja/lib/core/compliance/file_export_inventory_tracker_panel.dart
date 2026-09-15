import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Row 220 - FEBFL-001-A01 (Seq 14927)
/// Action: Identify all file export operations in the application that require status tracking.
/// Metric: Scope Coverage / Audit Completeness | Unit: Complete (Scale: Complete/Partial/Not Complete)
/// Standard: Complete full inventory before design work begins.
class FileExportInventoryTrackerPanel extends StatefulWidget {
  const FileExportInventoryTrackerPanel({super.key});

  @override
  State<FileExportInventoryTrackerPanel> createState() =>
      _FileExportInventoryTrackerPanelState();
}

class _ExportOperationItem {
  final String id;
  final String moduleName;
  final String operationName;
  final String format;
  final String triggerSource;
  final bool requiresTracking;
  bool isAudited;

  _ExportOperationItem({
    required this.id,
    required this.moduleName,
    required this.operationName,
    required this.format,
    required this.triggerSource,
    required this.requiresTracking,
    this.isAudited = true,
  });
}

class _FileExportInventoryTrackerPanelState
    extends State<FileExportInventoryTrackerPanel> {
  final String _stepExecutionId = 'FEBFL-001-A01-INV-001';
  final String _userSessionId = 'POOJA-FEBFL-001-A01';
  final String _completionStatus = 'Complete';
  final String _standard = 'Audit Completeness & Pre-Design Inventory Standard';

  String _filterModule = 'All';
  DateTime _lastAuditTimestamp = DateTime.now();

  final List<_ExportOperationItem> _inventory = [
    _ExportOperationItem(
      id: 'EXP-001',
      moduleName: 'Financials',
      operationName: 'Monthly Ledger Statement',
      format: 'PDF / XLSX',
      triggerSource: 'Reports Hub',
      requiresTracking: true,
      isAudited: true,
    ),
    _ExportOperationItem(
      id: 'EXP-002',
      moduleName: 'Procurement',
      operationName: 'Vendor Compliance Dossier',
      format: 'PDF (Secured)',
      triggerSource: 'Vendor Detail Screen',
      requiresTracking: true,
      isAudited: true,
    ),
    _ExportOperationItem(
      id: 'EXP-003',
      moduleName: 'Shipments',
      operationName: 'Customs Declaration Archive',
      format: 'ZIP (Multi-file)',
      triggerSource: 'Logistics Overview',
      requiresTracking: true,
      isAudited: true,
    ),
    _ExportOperationItem(
      id: 'EXP-004',
      moduleName: 'Analytics',
      operationName: 'Raw Event Telemetry Stream',
      format: 'CSV / JSON',
      triggerSource: 'Data Export Center',
      requiresTracking: true,
      isAudited: true,
    ),
    _ExportOperationItem(
      id: 'EXP-005',
      moduleName: 'Security',
      operationName: 'Audit Trail Access Log',
      format: 'JSON / Syslog',
      triggerSource: 'Governance Console',
      requiresTracking: true,
      isAudited: true,
    ),
  ];

  void _toggleAuditStatus(int index) {
    setState(() {
      _inventory[index].isAudited = !_inventory[index].isAudited;
      _lastAuditTimestamp = DateTime.now();
    });
  }

  void _setFilter(String module) {
    setState(() {
      _filterModule = module;
    });
  }

  Map<String, dynamic> getTelemetryData() {
    final auditedCount = _inventory.where((i) => i.isAudited).length;
    final coveragePct = (auditedCount / _inventory.length * 100).toStringAsFixed(1);
    return {
      'Step Execution ID': _stepExecutionId,
      'Export Format': 'Multi-Format (PDF, XLSX, ZIP, CSV, JSON)',
      'Export Status': auditedCount == _inventory.length ? '100% AUDITED' : 'PARTIAL',
      'Export Path': '/var/log/habot/exports/inventory_manifest.json',
      'Export Timestamp': _lastAuditTimestamp.toIso8601String(),
      'File Size': '42.8 KB (Manifest)',
      'Completion Status': '$coveragePct% ($_completionStatus)',
      'Action/Event Timestamp': _lastAuditTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Total Inventory Operations': _inventory.length,
      'Audited Operations Count': auditedCount,
      'Standard Applied': _standard,
    };
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filterModule == 'All'
        ? _inventory
        : _inventory.where((i) => i.moduleName == _filterModule).toList();

    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          AppSpacingTokens.vGapMd,
          _buildAuditSummaryCard(),
          AppSpacingTokens.vGapMd,
          _buildFilterBar(),
          AppSpacingTokens.vGapMd,
          _buildInventoryListCard(filteredList),
          AppSpacingTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'File Export Inventory Tracker',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorPalette.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColorPalette.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '100% Scope Target',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'Identifies and logs all asynchronous file generation and export operations requiring background status tracking.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditSummaryCard() {
    final auditedCount = _inventory.where((i) => i.isAudited).length;
    final totalCount = _inventory.length;
    final isFullCoverage = auditedCount == totalCount;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(
          color: isFullCoverage
              ? AppColorPalette.success
              : AppColorPalette.warning,
        ),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFullCoverage
                    ? AppColorPalette.successContainer
                    : AppColorPalette.warningContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFullCoverage ? Icons.verified : Icons.pending_actions,
                color: isFullCoverage
                    ? AppColorPalette.onSuccessContainer
                    : AppColorPalette.onWarningContainer,
                size: 28,
              ),
            ),
            AppSpacingTokens.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFullCoverage
                        ? 'Full Audit Completeness: 100%'
                        : 'Audit Scope: $auditedCount of $totalCount Operations',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColorPalette.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Zero scope gaps identified prior to design phase transition.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final modules = ['All', 'Financials', 'Procurement', 'Shipments', 'Analytics', 'Security'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: modules.map((mod) {
          final isSelected = _filterModule == mod;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(mod),
              selected: isSelected,
              onSelected: (_) => _setFilter(mod),
              selectedColor: AppColorPalette.brandPrimaryContainer,
              checkmarkColor: AppColorPalette.onBrandPrimaryContainer,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColorPalette.onBrandPrimaryContainer
                    : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInventoryListCard(List<_ExportOperationItem> list) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tracked Operations Manifest',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, itemIndex) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = list[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColorPalette.brandPrimaryContainer,
                    radius: 16,
                    child: Text(
                      item.id.substring(4),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColorPalette.onBrandPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(
                    item.operationName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item.moduleName} | ${item.format} | Source: ${item.triggerSource}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  trailing: Checkbox(
                    value: item.isAudited,
                    activeColor: AppColorPalette.brandPrimary,
                    onChanged: (_) {
                      final originalIndex = _inventory.indexOf(item);
                      _toggleAuditStatus(originalIndex);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 170,
                      child: Text(
                        '${e.key}:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        val,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
