/*
 * RCGLA-031 — Build Complex Organism Layout Components
 * 
 * Global Reference ID: RCGLA-031
 * Atomic Steps Reference ID: RCGLA-031-A01
 * Setup Step (Action): RCGLA-031 - Build Complex Organism Layout Components.
 * Setup Step Description: Review the molecular components available for organism-level composition.
 * 4 Substeps:
 *   1) Assemble integrated data cards incorporating header definitions and action matrices.
 *   2) Build responsive table row groups utilizing dynamic text mapping controls.
 *   3) Construct navigation shells mapping viewport size class changes.
 *   4) Integrate action modal layers utilizing high-priority view containers.
 * 
 * Decision Group: Screen Scaffolding Systems.
 * Decision to be Made Before Setup Step: Determine responsive collapsing models for navigation bars on low-resolution displays.
 * Decision Category: Dashboard.
 * Why This Matters: Forms the parent view blocks that organize functional systems inside standard layouts.
 * Mobile App First Implication: Automatically converts side-sheet dashboard panels into fully immersive, swipable bottom-sheet modules on mobile screens to preserve primary workspace context.
 * UX Translation: Integrated view environments handling distinct interaction task loops.
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Scope Coverage / Audit Completeness
 * - Floor Boundary (80%): 80% of relevant items identified.
 * - Optimal Target (100%): 100% of relevant items identified and logged in an inventory register.
 * - Ceiling Boundary (100% + Spec): 100% identified, logged, and cross-checked against the design/architecture spec.
 * Best Qualitative Output: Complete
 * Best Qualitative/Quantitative Output Type: World-class teams complete a full inventory before design work begins; partial audits (below 80%) risk missed edge cases downstream.
 * Assigned Team Member: Full-Scale Interface Engineering Lead
 * Data Collected by System: Step Execution ID; Execution Status; Execution Timestamp; Step Outcome; User ID; Completion Status ('Complete'); Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Google Material Design Decisions & Implementations:
 *   - UX Decision: Maintain unified container layouts to optimize scrolling speeds across mobile screens.
 *   - UI Decision: Match elevation shading patterns with systematic level structures.
 *   - UX Implementation: Implement adaptive navigation shifts between bottom layouts and sidebar rails cleanly.
 *   - UI Implementation: Execute clear structural separation between interaction sectors using thin division accents.
 * 
 * Mistake-Proofing (Poka-Yoke): Enforce strict CSS box layout isolation policies to prevent internal text clipping or cell wrapping failures on tight layouts.
 * Self-Chasing: Automated accessibility spiders crawl generated containers to verify focus routing integrity.
 * Vitality & Prosperity (VAP):
 *   - Us: Radical optimization of global application code reuse across deployment lines.
 *   - Customer: Highly stable, predictable interface response behaviors across all form factor profiles.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step RCGLA-031 Record Data Model.
class ComplexOrganismLayoutRecord {
  final String globalRefId;
  final String atomicStepRefId;
  final String setupAction;
  final String setupDescription;
  final String decisionGroup;
  final String decisionCategory;
  final String whyThisMatters;
  final String mobileAppFirstImplication;
  final String uxTranslation;
  final String commonLibraryToStore;
  final String atomicReusability;
  final String gcpBigQueryAlignment;
  final String sequenceOrder;
  final String estimatedTimeRequired;
  final String expectedOutput;
  final String completionMeasures;
  final String dependencies;
  final String domainExpertiseNeeded;
  final String assignedTeamMember;
  final String stepExecutionId;
  final String executionStatus;
  final String executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String userSessionId;
  final String completionStatus;
  final double scopeCoveragePercentage;
  final bool isCrossCheckedWithSpec;

  const ComplexOrganismLayoutRecord({
    this.globalRefId = 'RCGLA-031',
    this.atomicStepRefId = 'RCGLA-031-A01',
    this.setupAction = 'RCGLA-031 - Build Complex Organism Layout Components.',
    this.setupDescription = 'Review the molecular components available for organism-level composition.',
    this.decisionGroup = 'Screen Scaffolding Systems.',
    this.decisionCategory = 'Dashboard.',
    this.whyThisMatters = 'Forms the parent view blocks that organize functional systems inside standard layouts.',
    this.mobileAppFirstImplication = 'Automatically converts side-sheet dashboard panels into fully immersive, swipable bottom-sheet modules on mobile screens to preserve primary workspace context.',
    this.uxTranslation = 'Integrated view environments handling distinct interaction task loops.',
    this.commonLibraryToStore = 'Universal Component Library Package.',
    this.atomicReusability = 'Master platform container blocks collection (DataTable, WorkspaceCard).',
    this.gcpBigQueryAlignment = 'Coordinates interface update signals with real-time streaming services.',
    this.sequenceOrder = 'Level 13 | Phase: EXECUTION | Atomic Step: 1.0 | Row: 3057.0',
    this.estimatedTimeRequired = '3 Days',
    this.expectedOutput = 'High-level layout components.',
    this.completionMeasures = 'Viewport resizing validations confirm flawless transformation across form factors.',
    this.dependencies = 'HC-DE-0303',
    this.domainExpertiseNeeded = 'Full-Scale Interface Engineering & Responsive Web Architecture.',
    this.assignedTeamMember = 'Full-Scale Interface Engineering Lead',
    required this.stepExecutionId,
    this.executionStatus = 'ACTIVE_SUCCESS',
    required this.executionTimestamp,
    this.stepOutcome = 'ORGANISM_LAYOUT_BUILT_AND_VERIFIED',
    required this.userId,
    required this.userSessionId,
    this.completionStatus = 'Complete',
    this.scopeCoveragePercentage = 1.0, // 100% Optimal Target
    this.isCrossCheckedWithSpec = true,  // 100% Ceiling Target Cross-Checked
  });
}

enum AuditCoverageGrade {
  ceiling('Ceiling Boundary (100% Logged + Architecture Spec Cross-Checked)', AppColorPalette.success, Icons.stars),
  optimal('Optimal Target (100% Relevant Items Identified & Logged in Register)', AppColorPalette.info, Icons.check_circle),
  floor('Floor Boundary (80% Relevant Items Identified)', AppColorPalette.warning, Icons.warning_amber),
  failing('Failing Audit (<80% High Edge-Case Risk)', AppColorPalette.lightError, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const AuditCoverageGrade(this.label, this.color, this.icon);
}

abstract class ScopeCoverageAuditValidator {
  static AuditCoverageGrade evaluateGrade(double coveragePercentage, bool isCrossChecked) {
    if (coveragePercentage >= 1.0 && isCrossChecked) {
      return AuditCoverageGrade.ceiling;
    } else if (coveragePercentage >= 1.0) {
      return AuditCoverageGrade.optimal;
    } else if (coveragePercentage >= 0.80) {
      return AuditCoverageGrade.floor;
    } else {
      return AuditCoverageGrade.failing;
    }
  }
}

enum SimulatedViewportMode {
  compactMobile(360, 'Compact Mobile (360dp)', Icons.smartphone),
  mediumTablet(720, 'Medium Tablet (720dp)', Icons.tablet),
  expandedDesktop(1024, 'Expanded Desktop (1024dp)', Icons.desktop_windows);

  final double width;
  final String label;
  final IconData icon;
  const SimulatedViewportMode(this.width, this.label, this.icon);
}

/// Step 61 Main Component Panel Widget
class ComplexOrganismLayoutPanel extends StatefulWidget {
  final ComplexOrganismLayoutRecord record;

  const ComplexOrganismLayoutPanel({
    super.key,
    required this.record,
  });

  @override
  State<ComplexOrganismLayoutPanel> createState() => _ComplexOrganismLayoutPanelState();
}

class _ComplexOrganismLayoutPanelState extends State<ComplexOrganismLayoutPanel> {
  SimulatedViewportMode _viewportMode = SimulatedViewportMode.compactMobile;
  int _activeNavIndex = 0;
  String _filterSearchQuery = '';
  String _statusFilter = 'All';
  String _densityMode = 'Normal';

  // Audit Boundary Evaluator Simulated Values
  late double _simulatedCoveragePercentage;
  late bool _simulatedCrossCheckSpec;

  bool _pokaYokeStrictLayoutIsolation = true;
  bool _accessibilitySpiderPassed = true;
  String _lastActionTriggered = 'Initial State Ready';

  late List<Map<String, String>> _organismComponents;

  @override
  void initState() {
    super.initState();
    _simulatedCoveragePercentage = widget.record.scopeCoveragePercentage;
    _simulatedCrossCheckSpec = widget.record.isCrossCheckedWithSpec;

    _organismComponents = [
      {
        'id': 'ORG-CARD-101',
        'component': 'HeaderDefinitionCard',
        'type': 'Integrated View Card',
        'elevation': 'Level 2 Shading',
        'mappingKey': 'data.header_def',
        'status': 'Synchronized',
      },
      {
        'id': 'ORG-ROW-102',
        'component': 'ResponsiveRowGroup',
        'type': 'Dynamic Mapping Control',
        'elevation': 'Level 1 Shading',
        'mappingKey': 'data.table_rows',
        'status': 'Active',
      },
      {
        'id': 'ORG-SHELL-103',
        'component': 'AdaptiveNavShell',
        'type': 'Rail/BottomBar Container',
        'elevation': 'Level 3 Shading',
        'mappingKey': 'layout.viewport_shell',
        'status': 'Responsive',
      },
      {
        'id': 'ORG-MODAL-104',
        'component': 'HighPriorityModalLayer',
        'type': 'Swipable BottomSheet / Dialog',
        'elevation': 'Level 4 Floating',
        'mappingKey': 'ui.modal_layer',
        'status': 'Verified',
      },
      {
        'id': 'ORG-MATRIX-105',
        'component': 'ActionMatrixGrid',
        'type': 'Interactive Command Grid',
        'elevation': 'Level 2 Shading',
        'mappingKey': 'actions.matrix_map',
        'status': 'Active',
      },
    ];
  }

  void _showActionModalLayer(BuildContext context) {
    final isCompact = _viewportMode == SimulatedViewportMode.compactMobile;
    final nameController = TextEditingController();
    final keyController = TextEditingController();
    String selectedStatus = 'Active';

    if (isCompact) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                padding: EdgeInsets.only(
                  left: AppSpacingTokens.lg,
                  right: AppSpacingTokens.lg,
                  top: AppSpacingTokens.lg,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacingTokens.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.layers_outlined, color: colorScheme.primary),
                        AppSpacingTokens.hGapSm,
                        Expanded(
                          child: Text(
                            'High-Priority Action Modal Layer',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacingTokens.vGapXs,
                    Text(
                      'Immersive swipable bottom-sheet module preserving primary workspace context.',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    AppSpacingTokens.vGapSm,
                    Divider(color: colorScheme.outlineVariant.withOpacity(0.4), thickness: 1),
                    AppSpacingTokens.vGapSm,

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Molecular Component Name',
                        hintText: 'e.g. WorkspaceCardGroup',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    AppSpacingTokens.vGapSm,
                    TextField(
                      controller: keyController,
                      decoration: const InputDecoration(
                        labelText: 'Dynamic Text Mapping Key',
                        hintText: 'e.g. data.workspace_key',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    AppSpacingTokens.vGapSm,
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Component Status',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Synchronized', child: Text('Synchronized')),
                        DropdownMenuItem(value: 'Responsive', child: Text('Responsive')),
                        DropdownMenuItem(value: 'Verified', child: Text('Verified')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedStatus = val);
                      },
                    ),

                    AppSpacingTokens.vGapMd,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        AppSpacingTokens.hGapSm,
                        FilledButton.icon(
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              setState(() {
                                _organismComponents.add({
                                  'id': 'ORG-CUSTOM-${_organismComponents.length + 101}',
                                  'component': nameController.text,
                                  'type': 'Custom Organism Block',
                                  'elevation': 'Level 2 Shading',
                                  'mappingKey': keyController.text.isNotEmpty ? keyController.text : 'custom.key',
                                  'status': selectedStatus,
                                });
                                _lastActionTriggered = 'Added Component: ${nameController.text} via Mobile BottomSheet Modal';
                              });
                            }
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Component'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.widgets_outlined, color: colorScheme.primary),
                AppSpacingTokens.hGapSm,
                const Text('Action Modal Container (Side-Sheet/Dialog)'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: colorScheme.outlineVariant, thickness: 1),
                AppSpacingTokens.vGapSm,
                Text(
                  'High-priority action view container for desktop/tablet layout mode.',
                  style: theme.textTheme.bodyMedium,
                ),
                AppSpacingTokens.vGapMd,
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Molecular Component Name',
                    hintText: 'e.g. WorkspaceCardGroup',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                AppSpacingTokens.vGapSm,
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Dynamic Text Mapping Key',
                    hintText: 'e.g. data.workspace_key',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                AppSpacingTokens.vGapMd,
                Container(
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColorPalette.brandPrimaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColorPalette.brandPrimary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColorPalette.brandPrimary, size: 20),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'CSS Box Layout Isolation Active: Prevents text clipping & wrapping errors.',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    setState(() {
                      _organismComponents.add({
                        'id': 'ORG-CUSTOM-${_organismComponents.length + 101}',
                        'component': nameController.text,
                        'type': 'Custom Organism Block',
                        'elevation': 'Level 2 Shading',
                        'mappingKey': keyController.text.isNotEmpty ? keyController.text : 'custom.key',
                        'status': 'Active',
                      });
                      _lastActionTriggered = 'Added Component: ${nameController.text} via Desktop Modal';
                    });
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Confirm Execution'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auditGrade = ScopeCoverageAuditValidator.evaluateGrade(_simulatedCoveragePercentage, _simulatedCrossCheckSpec);

    final filteredItems = _organismComponents.where((item) {
      final matchesSearch = _filterSearchQuery.isEmpty ||
          item['component']!.toLowerCase().contains(_filterSearchQuery.toLowerCase()) ||
          item['id']!.toLowerCase().contains(_filterSearchQuery.toLowerCase()) ||
          item['mappingKey']!.toLowerCase().contains(_filterSearchQuery.toLowerCase());
      
      final matchesStatus = _statusFilter == 'All' || item['status'] == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card with Metadata & Current Audit Status
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.surface,
            child: Padding(
              padding: AppSpacingTokens.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColorPalette.brandPrimaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${widget.record.globalRefId} / ${widget.record.atomicStepRefId}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColorPalette.onBrandPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: auditGrade.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: auditGrade.color.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(auditGrade.icon, size: 14, color: auditGrade.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    auditGrade.label,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: auditGrade.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Assigned Member: ${widget.record.assignedTeamMember} | Sequence: ${widget.record.sequenceOrder}'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapMd,
                  Text(
                    widget.record.setupAction,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  AppSpacingTokens.vGapXs,
                  Text(
                    widget.record.setupDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
                  AppSpacingTokens.vGapSm,
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.person_outline, 'Assigned: ${widget.record.assignedTeamMember}', colorScheme),
                      _buildInfoChip(Icons.timer_outlined, 'Est. Time: ${widget.record.estimatedTimeRequired}', colorScheme),
                      _buildInfoChip(Icons.hub_outlined, 'Dep: ${widget.record.dependencies}', colorScheme),
                      _buildInfoChip(Icons.account_tree_outlined, 'Decision: ${widget.record.decisionGroup}', colorScheme),
                      _buildInfoChip(Icons.fingerprint, 'Exec ID: ${widget.record.stepExecutionId}', colorScheme),
                    ],
                  ),
                ],
              ),
            ),
          ),

          AppSpacingTokens.vGapLg,

          // DEDICATED AUDIT BOUNDARIES EVALUATOR CARD (Floor, Optimal, Ceiling)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.surface,
            child: Padding(
              padding: AppSpacingTokens.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fact_check, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'Scope Coverage / Audit Completeness Metric Boundaries Evaluator',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapXs,
                  Text(
                    'World-class teams complete a full inventory before design work begins; partial audits (below 80%) risk missed edge cases downstream.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // 3 Boundary Target Preset Switcher
                  Text(
                    'Test Audit Target Boundaries:',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  AppSpacingTokens.vGapXs,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Floor Boundary (80%)'),
                        selected: _simulatedCoveragePercentage == 0.80 && !_simulatedCrossCheckSpec,
                        selectedColor: AppColorPalette.warningContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedCoveragePercentage = 0.80;
                              _simulatedCrossCheckSpec = false;
                              _lastActionTriggered = 'Set Audit Metric to Floor Boundary (80%)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Optimal Target (100% Logged)'),
                        selected: _simulatedCoveragePercentage == 1.0 && !_simulatedCrossCheckSpec,
                        selectedColor: AppColorPalette.infoContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedCoveragePercentage = 1.0;
                              _simulatedCrossCheckSpec = false;
                              _lastActionTriggered = 'Set Audit Metric to Optimal Target (100% Inventory Logged)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Ceiling Target (100% + Spec Cross-Checked)'),
                        selected: _simulatedCoveragePercentage == 1.0 && _simulatedCrossCheckSpec,
                        selectedColor: AppColorPalette.successContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedCoveragePercentage = 1.0;
                              _simulatedCrossCheckSpec = true;
                              _lastActionTriggered = 'Set Audit Metric to Ceiling Target (100% + Spec Cross-Checked)';
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  AppSpacingTokens.vGapMd,

                  // Detailed 3-Boundary Status Display Cards
                  Container(
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: auditGrade.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: auditGrade.color.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        _buildBoundaryRow(
                          title: 'Floor Boundary (80% Items Identified)',
                          description: 'Minimum required audit threshold to prevent major downstream missed edge cases.',
                          isMet: _simulatedCoveragePercentage >= 0.80,
                          badgeColor: AppColorPalette.warning,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Optimal Target (100% Items Logged in Inventory)',
                          description: '100% of relevant molecular and organism components identified and logged in inventory register.',
                          isMet: _simulatedCoveragePercentage >= 1.0,
                          badgeColor: AppColorPalette.info,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Ceiling Boundary (100% Logged + Arch Spec Cross-Checked)',
                          description: '100% identified, logged, and cross-checked against design/architecture spec with full sign-off.',
                          isMet: _simulatedCoveragePercentage >= 1.0 && _simulatedCrossCheckSpec,
                          badgeColor: AppColorPalette.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          AppSpacingTokens.vGapLg,

          // Substep 3: Viewport Size Class Navigation Shell Selector
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.surfaceVariant.withOpacity(0.4),
            child: Padding(
              padding: AppSpacingTokens.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.aspect_ratio, color: colorScheme.primary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'Substep 3: Navigation Shell Viewport Size Class Mapping',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapXs,
                  Text(
                    'Simulate dynamic screen breakpoint changes and test adaptive nav bar shifts (Bottom Bar on Mobile vs Rail on Tablet/Desktop).',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  SegmentedButton<SimulatedViewportMode>(
                    segments: SimulatedViewportMode.values.map((mode) {
                      return ButtonSegment<SimulatedViewportMode>(
                        value: mode,
                        label: Text(mode.label, style: const TextStyle(fontSize: 12)),
                        icon: Icon(mode.icon, size: 16),
                      );
                    }).toList(),
                    selected: {_viewportMode},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _viewportMode = newSelection.first;
                        _lastActionTriggered = 'Switched to ${_viewportMode.label} Viewport';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          AppSpacingTokens.vGapLg,

          // Main Organism Layout Sandbox Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: _viewportMode.width > 800 ? double.infinity : _viewportMode.width),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top App Bar / Container Header
                Container(
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColorPalette.brandPrimaryContainer.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.widgets_outlined, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'Organism Parent Layout Block (${_viewportMode.label})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColorPalette.onBrandPrimaryContainer,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Tooltip(
                        message: 'Launch Action Modal Layer',
                        child: IconButton(
                          icon: const Icon(Icons.open_in_new, color: AppColorPalette.brandPrimary),
                          onPressed: () => _showActionModalLayer(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Layout Shell Body
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_viewportMode != SimulatedViewportMode.compactMobile)
                      NavigationRail(
                        selectedIndex: _activeNavIndex,
                        onDestinationSelected: (idx) => setState(() => _activeNavIndex = idx),
                        labelType: _viewportMode == SimulatedViewportMode.expandedDesktop
                            ? NavigationRailLabelType.all
                            : NavigationRailLabelType.selected,
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            radius: 18,
                            child: const Icon(Icons.developer_board, size: 18),
                          ),
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.dashboard_outlined),
                            selectedIcon: Icon(Icons.dashboard),
                            label: Text('Data Cards'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.table_chart_outlined),
                            selectedIcon: Icon(Icons.table_chart),
                            label: Text('Row Groups'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.tune_outlined),
                            selectedIcon: Icon(Icons.tune),
                            label: Text('Action Matrix'),
                          ),
                        ],
                      ),

                    if (_viewportMode != SimulatedViewportMode.compactMobile)
                      VerticalDivider(thickness: 1, width: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),

                    Expanded(
                      child: Padding(
                        padding: AppSpacingTokens.paddingMd,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSubstep1DataCard(context, theme, colorScheme),
                            AppSpacingTokens.vGapMd,
                            _buildSubstep2TableRowGroup(context, theme, colorScheme, filteredItems),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (_viewportMode == SimulatedViewportMode.compactMobile)
                  NavigationBar(
                    selectedIndex: _activeNavIndex,
                    onDestinationSelected: (idx) => setState(() => _activeNavIndex = idx),
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: 'Data Cards',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.table_chart_outlined),
                        selectedIcon: Icon(Icons.table_chart),
                        label: 'Row Groups',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.tune_outlined),
                        selectedIcon: Icon(Icons.tune),
                        label: 'Action Matrix',
                      ),
                    ],
                  ),
              ],
            ),
          ),

          AppSpacingTokens.vGapLg,

          // Mistake-Proofing (Poka-Yoke) & Accessibility Spider Crawl Panel
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.surface,
            child: Padding(
              padding: AppSpacingTokens.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: AppColorPalette.success),
                      AppSpacingTokens.hGapSm,
                      Text(
                        'Mistake-Proofing (Poka-Yoke) & Accessibility Spider Crawl',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapSm,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
                  AppSpacingTokens.vGapSm,

                  SwitchListTile(
                    title: const Text('Enforce CSS Box Layout Isolation Policies'),
                    subtitle: const Text('Prevents internal text clipping or cell wrapping failures on tight, low-resolution viewports.'),
                    value: _pokaYokeStrictLayoutIsolation,
                    activeColor: AppColorPalette.success,
                    onChanged: (val) => setState(() => _pokaYokeStrictLayoutIsolation = val),
                  ),

                  SwitchListTile(
                    title: const Text('Automated Accessibility Spider Focus Crawl'),
                    subtitle: const Text('Continuous spiders crawl generated parent view blocks to verify focus routing integrity.'),
                    value: _accessibilitySpiderPassed,
                    activeColor: AppColorPalette.success,
                    onChanged: (val) => setState(() => _accessibilitySpiderPassed = val),
                  ),

                  AppSpacingTokens.vGapSm,
                  Container(
                    width: double.infinity,
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: _pokaYokeStrictLayoutIsolation && _accessibilitySpiderPassed
                          ? AppColorPalette.successContainer.withOpacity(0.5)
                          : AppColorPalette.warningContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _pokaYokeStrictLayoutIsolation && _accessibilitySpiderPassed
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_rounded,
                          color: _pokaYokeStrictLayoutIsolation && _accessibilitySpiderPassed
                              ? AppColorPalette.success
                              : AppColorPalette.warning,
                        ),
                        AppSpacingTokens.hGapSm,
                        Expanded(
                          child: Text(
                            'Last Action: $_lastActionTriggered | Current Grade: ${auditGrade.label}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          AppSpacingTokens.vGapLg,

          // Vitality & Prosperity (VAP) Section
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Padding(
              padding: AppSpacingTokens.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber),
                      AppSpacingTokens.hGapSm,
                      Text(
                        'Vitality & Prosperity (VAP) Business Impact',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapSm,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
                  AppSpacingTokens.vGapSm,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What Creates VAP For Us:',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorPalette.brandPrimary,
                              ),
                            ),
                            AppSpacingTokens.vGapXs,
                            Text(
                              'Radical optimization of global application code reuse across deployment lines.',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      AppSpacingTokens.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What Creates VAP For Customer:',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorPalette.success,
                              ),
                            ),
                            AppSpacingTokens.vGapXs,
                            Text(
                              'Highly stable, predictable interface response behaviors across all form factor profiles.',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoundaryRow({
    required String title,
    required String description,
    required bool isMet,
    required Color badgeColor,
  }) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? badgeColor : Colors.grey,
          size: 20,
        ),
        AppSpacingTokens.hGapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isMet ? badgeColor : Colors.grey.shade700,
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isMet ? badgeColor.withOpacity(0.15) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isMet ? badgeColor.withOpacity(0.4) : Colors.grey.shade400),
          ),
          child: Text(
            isMet ? 'PASS' : 'UNMET',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isMet ? badgeColor : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSubstep1DataCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColorPalette.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacingTokens.hGapSm,
                    Text(
                      'Substep 1: Header Definition Data Card',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Level 2 Shading',
                    style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'Organism-level layout block assembling molecular headers and interactive action matrices.',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            AppSpacingTokens.vGapMd,
            
            Row(
              children: [
                _buildCardMetric('Total Blocks', '${_organismComponents.length}', colorScheme.primary, colorScheme),
                AppSpacingTokens.hGapMd,
                _buildCardMetric('Mapping Rate', '100%', AppColorPalette.success, colorScheme),
                AppSpacingTokens.hGapMd,
                _buildCardMetric('Elevation Levels', 'L1 - L4', AppColorPalette.warning, colorScheme),
              ],
            ),

            AppSpacingTokens.vGapMd,
            Divider(color: colorScheme.outlineVariant.withOpacity(0.4), thickness: 1),
            AppSpacingTokens.vGapSm,

            Text(
              'Action Matrix Operations:',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            AppSpacingTokens.vGapXs,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    setState(() => _lastActionTriggered = 'Action Matrix: Refresh Data Stream Triggered');
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh Matrix', style: TextStyle(fontSize: 12)),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _lastActionTriggered = 'Action Matrix: Streaming Synchronization Active');
                  },
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Sync Telemetry', style: TextStyle(fontSize: 12)),
                ),
                FilledButton.icon(
                  onPressed: () => _showActionModalLayer(context),
                  icon: const Icon(Icons.add_box_outlined, size: 16),
                  label: const Text('Modal Layer', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMetric(String label, String value, Color color, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildSubstep2TableRowGroup(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<Map<String, String>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Substep 2: Responsive Table Row Groups',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Compact', label: Text('Compact', style: TextStyle(fontSize: 10))),
                ButtonSegment(value: 'Normal', label: Text('Normal', style: TextStyle(fontSize: 10))),
              ],
              selected: {_densityMode},
              onSelectionChanged: (val) {
                setState(() => _densityMode = val.first);
              },
            ),
          ],
        ),
        AppSpacingTokens.vGapSm,

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search dynamic text mapping controls...',
                    hintStyle: const TextStyle(fontSize: 11),
                    prefixIcon: const Icon(Icons.search, size: 16),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _filterSearchQuery = val;
                    });
                  },
                ),
              ),
            ),
            AppSpacingTokens.hGapSm,
            DropdownButton<String>(
              value: _statusFilter,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Synchronized', child: Text('Synchronized')),
                DropdownMenuItem(value: 'Responsive', child: Text('Responsive')),
                DropdownMenuItem(value: 'Verified', child: Text('Verified')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _statusFilter = val);
              },
            ),
          ],
        ),

        AppSpacingTokens.vGapSm,
        Divider(color: colorScheme.outlineVariant.withOpacity(0.4), thickness: 1),
        AppSpacingTokens.vGapXs,

        if (items.isEmpty)
          Padding(
            padding: AppSpacingTokens.paddingMd,
            child: Text('No components match search or filter criteria.', style: theme.textTheme.bodySmall),
          )
        else
          Column(
            children: items.map((item) {
              final isCompactDensity = _densityMode == 'Compact';
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: isCompactDensity ? AppSpacingTokens.paddingXs : AppSpacingTokens.paddingSm,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 16, color: colorScheme.primary),
                    AppSpacingTokens.hGapSm,
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['component']!,
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Key: ${item['mappingKey']}',
                            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (_viewportMode != SimulatedViewportMode.compactMobile)
                      Expanded(
                        flex: 2,
                        child: Text(
                          item['elevation']!,
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColorPalette.successContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['status']!,
                        style: const TextStyle(fontSize: 10, color: AppColorPalette.onSuccessContainer, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
