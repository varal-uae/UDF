import 'package:flutter/material.dart';
import 'code_export_modal.dart';
import 'component_code_registry.dart';

/// ISO 9001 Process Adherence Completion Status Enum for PELCE-019-14.
enum CompletionStatus {
  notComplete,
  partial,
  complete,
}

/// Data class holding atomic metadata for ISO 9001 design system tracking.
class LibraryMetadata {
  final String libraryName;
  final String libraryVersion;
  final int componentCount;
  final String installationStatus;
  final List<String> dependencyList;

  const LibraryMetadata({
    required this.libraryName,
    required this.libraryVersion,
    required this.componentCount,
    required this.installationStatus,
    required this.dependencyList,
  });
}

/// Responsive 'Design System Merge Dashboard' Widget (PELCE-019-14).
/// Features:
/// 1. Metadata State Model & ISO 9001 Tracking (completionStatus enum defaulting to notComplete).
/// 2. Responsive Architecture (Mobile Single ListView vs Web/Tablet 2-Column Split Row).
/// 3. Strict Component Preview Rendering: FilledButton with pill shape (borderRadius 100.0) & 56px height.
/// 4. Completion Enforcer: Primary "MERGE REPOSITORY" button is disabled (onPressed: null) unless completionStatus == complete.
class DesignSystemMergeDashboard extends StatefulWidget {
  const DesignSystemMergeDashboard({super.key});

  @override
  State<DesignSystemMergeDashboard> createState() =>
      _DesignSystemMergeDashboardState();
}

class _DesignSystemMergeDashboardState
    extends State<DesignSystemMergeDashboard> {
  // Requirement 1: Metadata State Model
  final LibraryMetadata _metadata = const LibraryMetadata(
    libraryName: '@acme/m3-flutter-tokens',
    libraryVersion: 'v2.4.0-rc.1',
    componentCount: 42,
    installationStatus: 'ISO-9001 Verified Audit',
    dependencyList: ['flutter_material3', 'google_fonts', 'vector_graphics'],
  );

  // Requirement 1: State variable for completionStatus (Default: notComplete)
  CompletionStatus _completionStatus = CompletionStatus.notComplete;

  void _handleExecuteMerge() {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.merge, color: colorScheme.onPrimary),
            const SizedBox(width: 8.0),
            const Text('SUCCESS: Repository merged into main branch!'),
          ],
        ),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openCodeExportModal() {
    final specData = ComponentCodeRegistry.getCodeSpec(
      globalRefId: 'PELCE-019-14',
      title: 'Design System Merge Dashboard',
      category: 'Dashboards & Analytics',
    );
    CodeExportModalDialog.show(
      context: context,
      globalRefId: 'PELCE-019-14',
      title: 'Design System Merge Dashboard',
      fileName: specData['fileName']!,
      widgetClassName: specData['widgetClassName']!,
      category: 'Dashboards & Analytics',
      sourceCode: specData['sourceCode']!,
      integrationGuide: '''// -------------------------------------------------------------
// INTEGRATION GUIDE: [PELCE-019-14] Design System Merge Dashboard
// -------------------------------------------------------------

1. File Setup:
   Create lib/ui/${specData['fileName']} in your target Flutter application.

2. Dependencies:
   Ensure useMaterial3: true is set in your ThemeData.

3. Import & Usage:
   import 'package:your_app/ui/${specData['fileName']}';

   @override
   Widget build(BuildContext context) {
     return const ${specData['widgetClassName']}();
   }

4. Responsiveness & Completion Enforcer Rules:
   - Web/Tablet (>600dp): Displays 2-column split view (Left: Metadata, Right: Component Preview).
   - Mobile (<=600dp): Displays single-column scrollable list.
   - Process Adherence: Primary "MERGE REPOSITORY" button is locked (onPressed: null) until completionStatus is set to complete.
''',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('[PELCE-019-14] Design System Merge Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Export Code & Integration Guide',
            onPressed: _openCodeExportModal,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktopWebTablet = constraints.maxWidth > 600;

          if (isDesktopWebTablet) {
            return _buildWebTabletTwoColumnLayout(theme);
          } else {
            return _buildMobileListViewLayout(theme);
          }
        },
      ),
    );
  }

  /// Web/Tablet View Layout (maxWidth > 600): 2-Column Split Row (Left: Metadata, Right: Preview)
  Widget _buildWebTabletTwoColumnLayout(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Metadata & ISO 9001 Process Status Controls
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildMetadataCard(theme),
                    const SizedBox(height: 20.0),
                    _buildCompletionStatusCard(theme),
                  ],
                ),
              ),
              const SizedBox(width: 24.0),

              // Right Column: Component Preview Card & Merge Action Enforcer
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildComponentPreviewCard(theme, isMobile: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mobile View Layout (maxWidth <= 600): Single ListView Stacking Cards
  Widget _buildMobileListViewLayout(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Component Preview Card (Stacked top on mobile)
          _buildComponentPreviewCard(theme, isMobile: true),
          const SizedBox(height: 16.0),

          // Metadata Card
          _buildMetadataCard(theme),
          const SizedBox(height: 16.0),

          // Completion Status Selector Card
          _buildCompletionStatusCard(theme),
        ],
      ),
    );
  }

  /// Metadata Card displaying ISO 9001 tracking fields
  Widget _buildMetadataCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.source_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8.0),
                Text(
                  'Library Metadata (ISO 9001 Audit)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24.0),
            _buildMetaRow('Library Name:', _metadata.libraryName, theme),
            _buildMetaRow('Version Tag:', _metadata.libraryVersion, theme),
            _buildMetaRow(
              'Component Count:',
              '${_metadata.componentCount} Atomic Tokens',
              theme,
            ),
            _buildMetaRow('Audit Status:', _metadata.installationStatus, theme),
            const SizedBox(height: 8.0),
            Text(
              'Dependencies:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6.0),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: _metadata.dependencyList.map((dep) {
                return Chip(
                  labelStyle: const TextStyle(fontSize: 11.0),
                  padding: EdgeInsets.zero,
                  label: Text(dep),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Completion Enforcer Selector Card
  Widget _buildCompletionStatusCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt, color: theme.colorScheme.primary),
                const SizedBox(width: 8.0),
                Text(
                  'ISO 9001 Process Adherence Gate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Process Enforcer: Primary MERGE action is locked (onPressed: null) until Completion Status is set to COMPLETE.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16.0),

            // Dropdown Selector for completionStatus
            DropdownButtonFormField<CompletionStatus>(
              initialValue: _completionStatus,
              decoration: const InputDecoration(
                labelText: 'Merge Readiness Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: CompletionStatus.notComplete,
                  child: Text('🔴 Not Complete (Locked)'),
                ),
                DropdownMenuItem(
                  value: CompletionStatus.partial,
                  child: Text('🟡 Partial Verification (Locked)'),
                ),
                DropdownMenuItem(
                  value: CompletionStatus.complete,
                  child: Text('🟢 Complete (Unlocked for Merge)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _completionStatus = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Requirement 3 & 4: Strict Component Preview Card
  Widget _buildComponentPreviewCard(ThemeData theme, {required bool isMobile}) {
    // Requirement 4: Disabled unless completionStatus == complete
    final isUnlocked = _completionStatus == CompletionStatus.complete;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8.0),
                Text(
                  'Component Preview (Pill CTA)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Poka-Yoke Rule: Native FilledButton with strict borderRadius 100.0 pill shape and machine verb label.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),

            // Requirement 3: Component Preview Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Center(
                child: SizedBox(
                  width: isMobile ? double.infinity : 400.0,
                  height: 56.0,
                  child: FilledButton.icon(
                    // Requirement 3: Native FilledButton with borderRadius 100.0
                    style: FilledButton.styleFrom(
                      minimumSize: Size(
                        isMobile ? double.infinity : 400.0,
                        56.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0), // Strict Pill Shape
                      ),
                    ),
                    // Requirement 4: Completion Enforcer check
                    onPressed: isUnlocked ? _handleExecuteMerge : null,
                    icon: const Icon(Icons.merge_type),
                    label: const Text(
                      'MERGE REPOSITORY', // Machine-action verb
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Status Banner
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Icon(
                    isUnlocked ? Icons.check_circle : Icons.lock_clock,
                    color: isUnlocked
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      isUnlocked
                          ? 'STATUS: UNLOCKED - Ready to execute merge pipeline.'
                          : 'STATUS: LOCKED - Set Merge Readiness Status to COMPLETE to unlock.',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String val, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              val,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
