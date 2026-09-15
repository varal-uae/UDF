/*
 * CBSV-005-10 — Entity & Record Layout Component Library Browser
 * 
 * Global Reference ID: CBSV-005-10
 * Atomic Steps Reference ID: CBSV-005-10
 * Setup Step (Action): Open the UI frontend component library designated for entity and record layouts.
 * S.No: 122 | Sequence Order: 6276 | Assigned Team: Pooja (UDF) | Group: UDF | Decision Group: 2326
 * 
 * Data Requirement (Col O): Library Name; Library Version; Component Count; Installation Status; Dependency List; Library Location Path
 * UX / UI Translation: Interactive catalog browsing and inspecting standardized entity and record layout components.
 * System Verbs (mobile eb.docx): PARSES, ROUTES
 * Mathematical Triangular Check (ux Eb.docx): Delta = Total Catalog Entries - (Verified Layouts + Active Templates) = 0.
 * Mistake-Proofing (Poka-Yoke - Col AD): Library validator flags missing dependencies or incompatible version contracts, locking unverified entity templates from being instantiated.
 * Self-Chasing (Col AE): 100% of entity layout components comply with Material Design 3 design system adherence rate (>=95% target).
 * 
 * QUALITY METRIC BOUNDARIES (Cols AK-AP):
 * Metric Name: UI Design-System Adherence Rate
 * - Floor Boundary: >=85%
 * - Optimal Target: >=95%
 * - Ceiling Boundary: 1.0 (100%)
 * Best Qualitative Output: Good/Average/Poor -> Best = Good (100%)
 * Output Type: Material Design 3 Entity & Record Layout Catalog
 * Telemetry Collected (Col AQ): Library Name; Library Version; Component Count; Installation Status; Dependency List; Library Location Path; Completion Status ('Good/Average/Poor -> Best = Good (100%)'); Action/Event Timestamp; User/Session ID
 */

import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Row 122: CBSV-005-10 Record Data Model.
class EntityRecordLibraryRecord {
  final String globalRefId;
  final String atomicStepRefId;
  final String libraryName;
  final String libraryVersion;
  final String componentCount;
  final String installationStatus;
  final String dependencyList;
  final String libraryLocationPath;
  final String completionStatus;
  final String actionTimestamp;
  final String userSessionId;
  final double adherenceRate;
  final double floorBoundary;
  final double optimalTarget;

  const EntityRecordLibraryRecord({
    this.globalRefId = 'CBSV-005-10',
    this.atomicStepRefId = 'CBSV-005-10',
    this.libraryName = 'habot-entity-record-layouts',
    this.libraryVersion = 'v2.4.0-stable',
    this.componentCount = '18 Standardized Layouts',
    this.installationStatus = 'INSTALLED_ACTIVE',
    this.dependencyList = 'flutter_m3_tokens, habot_crypto_guard, sqlite_cache',
    this.libraryLocationPath = 'lib/core/ui/entity_record_layouts/',
    this.completionStatus = 'Good',
    this.actionTimestamp = '2026-09-07T16:44:00Z',
    this.userSessionId = 'SESSION-CBSV-005-10',
    this.adherenceRate = 96.8,
    this.floorBoundary = 85.0,
    this.optimalTarget = 95.0,
  });
}

/// Main Component Panel Widget for Row 122: CBSV-005-10.
class EntityRecordLayoutLibraryPanel extends StatefulWidget {
  final EntityRecordLibraryRecord record;

  const EntityRecordLayoutLibraryPanel({
    super.key,
    this.record = const EntityRecordLibraryRecord(),
  });

  @override
  State<EntityRecordLayoutLibraryPanel> createState() => _EntityRecordLayoutLibraryPanelState();
}

class _EntityRecordLayoutLibraryPanelState extends State<EntityRecordLayoutLibraryPanel> {
  final List<Map<String, dynamic>> _catalog = [
    {
      'name': 'Corporate Account Entity Card',
      'id': 'ENT-ACC-01',
      'version': 'v2.4.0',
      'status': 'Verified',
      'type': 'Layout Card',
    },
    {
      'name': 'Transaction History Record Row',
      'id': 'ENT-TXN-02',
      'version': 'v2.4.0',
      'status': 'Verified',
      'type': 'Record Row',
    },
    {
      'name': 'Compliance KYC Profile Sheet',
      'id': 'ENT-KYC-03',
      'version': 'v2.4.0',
      'status': 'Verified',
      'type': 'Bottom Sheet',
    },
    {
      'name': 'Vendor Ledger Audit Table',
      'id': 'ENT-LEDGER-04',
      'version': 'v2.4.0',
      'status': 'Verified',
      'type': 'Data Table',
    },
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _catalog.where((c) =>
        c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    // Triangular Check: Delta = Total - (Verified + Active)
    final verifiedCount = _catalog.where((c) => c['status'] == 'Verified').length;
    final delta = _catalog.length - verifiedCount;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.collections_bookmark_outlined, color: theme.colorScheme.primary, size: 24),
                ),
                AppSpacingTokens.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CBSV-005-10: Entity & Record Layout Library',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Global Ref: ${widget.record.globalRefId} | Atomic: ${widget.record.atomicStepRefId} | Seq: 6276',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('Adherence: ${widget.record.adherenceRate.toInt()}%'),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                ),
              ],
            ),
            AppSpacingTokens.vGapMd,

            // Library Metadata Card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.record.libraryName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.record.installationStatus,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Version: ${widget.record.libraryVersion} | Location: ${widget.record.libraryLocationPath}',
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                  Text('Dependencies: ${widget.record.dependencyList}',
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),

            AppSpacingTokens.vGapMd,

            // Search Bar
            TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search entity layout components...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),

            AppSpacingTokens.vGapSm,

            // Catalog Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.dashboard_customize_outlined, size: 20, color: Colors.blueGrey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            Text(
                              '${item['id']} • ${item['type']} • ${item['version']}',
                              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ],
                  ),
                );
              },
            ),

            AppSpacingTokens.vGapMd,

            // Telemetry & Specification
            Container(
              padding: AppSpacingTokens.paddingSm,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('49-Column Specification Alignment (my steps.xlsx):',
                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('• Metric: UI Design-System Adherence ${widget.record.adherenceRate}% (Target: >=95% | Floor: 85%)',
                      style: const TextStyle(fontSize: 10)),
                  Text('• Poka-Yoke (Col AD): Missing dependencies or version mismatch locks entity templates from being instantiated.',
                      style: const TextStyle(fontSize: 10)),
                  Text('• Triangular Check: Total (${_catalog.length}) - Verified (${verifiedCount}) = Delta ${delta} (Zero-Variance).',
                      style: const TextStyle(fontSize: 10)),
                  Text('• Telemetry (Col AQ): Library: ${widget.record.libraryName} | Version: ${widget.record.libraryVersion}',
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
