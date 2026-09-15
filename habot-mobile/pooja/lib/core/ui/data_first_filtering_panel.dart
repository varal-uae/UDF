/*
 * LSAV-036 — Data-First Filtering Layouts
 * 
 * Global Reference ID: LSAV-036
 * Atomic Steps Reference ID: LSAV-036-A01
 * Setup Step (Action): Data-First Filtering Layouts.
 * Setup Step Description: Open the dashboard design template file within the layout package.
 * 4 Substeps:
 *   1) Define mandatory filters.
 *   2) Set logic defaults.
 *   3) Code conflicts.
 *   4) Anchor header.
 * 
 * Decision Group: Analytics & Dashboard Architecture
 * Decision to be Made Before Setup Step: Establish visual hierarchy through Data-First Filtering.
 * Decision Category: Dashboard Design.
 * Why This Matters: Reduces cognitive load by allowing users to hone in on specific insights.
 * Mobile App First Implication: Utilizes mobile "Bottom Sheets" for filter selection to save vital vertical screen real estate.
 * UX Translation: Sticky filter bars above data updating all downstream components.
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Dashboard Data Refresh & Accuracy Rate
 * - Floor Boundary: 95% data accuracy, ≤15 min refresh.
 * - Optimal Target: 99% data accuracy, ≤5 min refresh.
 * - Ceiling Boundary: 99.9% accuracy, near real-time (<1 min).
 * Best Qualitative Output: Good / Average / Poor (Best = Good)
 * Best Qualitative/Quantitative Output Type: Reporting surfaces should meet standard BI freshness/accuracy benchmarks so decisions aren't made on stale data.
 * Assigned Team Member: Analytics / UX Lead
 * Data Collected by System: Template Name; Template Version; Template Type; Template Configuration; Layout Type; Layout Grid Dimensions; Spacing Rules; Alignment Settings; Layout Validation Status; Completion Status ('Good / Average / Poor'); Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Google Material Design Decisions & Implementations:
 *   - UX Decision: Modal bottom sheets for complex filters.
 *   - UI Decision: Touch-optimized filter chips.
 *   - UX Implementation: Fast rendering logic for filter queries.
 *   - UI Implementation: Horizontally scrolling filter chips to save space.
 * 
 * Mistake-Proofing (Poka-Yoke): Pre-fill filters with logical defaults (e.g., "Last 30 Days") so users do not trigger unindexed massive DB queries.
 * Self-Chasing: Selecting conflicting filters automatically disables the conflicting option to prevent dead-end "Zero Results" queries.
 * Vitality & Prosperity (VAP):
 *   - Us: Optimizes Cloud spend while protecting mobile battery life from massive data fetches.
 *   - Customer: Provides targeted, digestible data slices immediately.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step LSAV-036 Record Data Model.
class DataFirstFilteringRecord {
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
  final String templateName;
  final String templateVersion;
  final String templateType;
  final String templateConfiguration;
  final String layoutType;
  final String layoutGridDimensions;
  final String spacingRules;
  final String alignmentSettings;
  final String layoutValidationStatus;
  final String completionStatus; // 'Good', 'Average', 'Poor'
  final String userId;
  final String userSessionId;
  final double dataAccuracyRate; // e.g. 99.9%
  final double dataRefreshTimeMin; // e.g. 0.5 min

  const DataFirstFilteringRecord({
    this.globalRefId = 'LSAV-036',
    this.atomicStepRefId = 'LSAV-036-A01',
    this.setupAction = 'Data-First Filtering Layouts.',
    this.setupDescription = 'Open the dashboard design template file within the layout package.',
    this.decisionGroup = 'Analytics & Dashboard Architecture',
    this.decisionCategory = 'Dashboard Design.',
    this.whyThisMatters = 'Reduces cognitive load by allowing users to hone in on specific insights.',
    this.mobileAppFirstImplication = 'Utilizes mobile "Bottom Sheets" for filter selection to save vital vertical screen real estate.',
    this.uxTranslation = 'Sticky filter bars above data updating all downstream components.',
    this.commonLibraryToStore = 'Universal Component Library Package.',
    this.atomicReusability = 'High. Standardized dashboard template components.',
    this.gcpBigQueryAlignment = 'Optimizes query costs by requesting only filtered data.',
    this.sequenceOrder = 'Level 13 | Phase: EXECUTION | Atomic Step: 1.0 | Row: 3101.0',
    this.estimatedTimeRequired = '24 hours.',
    this.expectedOutput = 'Standardized dashboard template with global filtering.',
    this.completionMeasures = '100% of operational dashboards driven by unified filtering.',
    this.dependencies = '7.0',
    this.domainExpertiseNeeded = 'Analytics / UX',
    this.assignedTeamMember = 'Analytics / UX Lead',
    this.templateName = 'DashboardTemplate_M3_Analytics',
    this.templateVersion = 'v2.4.0',
    this.templateType = 'DataFirstFilteringScaffold',
    this.templateConfiguration = 'StickyHeader_KPI_Table_Stack',
    this.layoutType = 'Filters (Top) -> KPIs (Middle) -> Detailed Tables (Bottom)',
    this.layoutGridDimensions = '12-Column Responsive Grid',
    this.spacingRules = '8px / 16px Padding',
    this.alignmentSettings = 'Top-Anchored Sticky Header Filter Bar',
    this.layoutValidationStatus = 'VALIDATED_OPTIMAL',
    this.completionStatus = 'Good',
    required this.userId,
    required this.userSessionId,
    this.dataAccuracyRate = 99.9, // 99.9% Ceiling Target
    this.dataRefreshTimeMin = 0.5, // Near real-time (<1 min)
  });
}

enum DataFreshnessGrade {
  ceiling('Ceiling Target (99.9% Accuracy, Near Real-Time <1 min)', AppColorPalette.success, Icons.stars),
  optimal('Optimal Target (99.0% Accuracy, ≤5 min Refresh)', AppColorPalette.info, Icons.check_circle),
  floor('Floor Boundary (95.0% Accuracy, ≤15 min Refresh)', AppColorPalette.warning, Icons.warning_amber),
  failing('Failing Freshness (<95.0% Accuracy or Stale Data)', AppColorPalette.lightError, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const DataFreshnessGrade(this.label, this.color, this.icon);
}

abstract class DashboardDataRefreshValidator {
  static DataFreshnessGrade evaluateGrade(double accuracy, double refreshMinutes) {
    if (accuracy >= 99.9 && refreshMinutes <= 1.0) {
      return DataFreshnessGrade.ceiling;
    } else if (accuracy >= 99.0 && refreshMinutes <= 5.0) {
      return DataFreshnessGrade.optimal;
    } else if (accuracy >= 95.0 && refreshMinutes <= 15.0) {
      return DataFreshnessGrade.floor;
    } else {
      return DataFreshnessGrade.failing;
    }
  }
}

/// Step 65 Main Component Panel Widget
class DataFirstFilteringPanel extends StatefulWidget {
  final DataFirstFilteringRecord record;

  const DataFirstFilteringPanel({
    super.key,
    required this.record,
  });

  @override
  State<DataFirstFilteringPanel> createState() => _DataFirstFilteringPanelState();
}

class _DataFirstFilteringPanelState extends State<DataFirstFilteringPanel> {
  // Substep 1 & 2: Mandatory Filters & Logic Defaults (Poka-Yoke default)
  String _selectedDateRange = 'Last 30 Days'; // Poka-Yoke default to prevent unindexed full DB scan
  String _selectedRegion = 'All Regions';
  String _selectedServiceCategory = 'All Services';
  String _selectedRecordStatus = 'Active';

  // Substep 3: Code Conflicts (Self-Chasing Conflict Resolution)
  bool _isConflictResolutionActive = true;
  bool _pokaYokeDefaultFilterActive = true;

  // Simulated Audit Metrics
  late double _simulatedAccuracy;
  late double _simulatedRefreshMin;

  String _lastActionStatus = 'Data-First Dashboard Initialized with Default Filters (Last 30 Days).';

  final List<Map<String, String>> _allRawAnalyticsRecords = [
    {
      'id': 'TX-8801',
      'date': '2026-08-18',
      'region': 'US-East',
      'category': 'Care Management',
      'revenue': '\$12,450',
      'status': 'Active',
      'queryCost': '\$0.02 (Filtered)',
    },
    {
      'id': 'TX-8802',
      'date': '2026-08-17',
      'region': 'EU-Central',
      'category': 'Senior Care',
      'revenue': '\$8,900',
      'status': 'Active',
      'queryCost': '\$0.01 (Filtered)',
    },
    {
      'id': 'TX-8803',
      'date': '2026-08-15',
      'region': 'US-West',
      'category': 'Pediatric Nursing',
      'revenue': '\$15,200',
      'status': 'Active',
      'queryCost': '\$0.03 (Filtered)',
    },
    {
      'id': 'TX-8804',
      'date': '2026-07-28',
      'region': 'US-East',
      'category': 'Care Management',
      'revenue': '\$6,100',
      'status': 'Archived',
      'queryCost': '\$0.01 (Filtered)',
    },
    {
      'id': 'TX-8805',
      'date': '2026-08-10',
      'region': 'AP-South',
      'category': 'Educational Care',
      'revenue': '\$9,400',
      'status': 'Active',
      'queryCost': '\$0.02 (Filtered)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulatedAccuracy = widget.record.dataAccuracyRate;
    _simulatedRefreshMin = widget.record.dataRefreshTimeMin;
  }

  // Substep 3: Code Conflicts — Automatic Conflict Disabling
  void _applyFilterChoice({
    String? dateRange,
    String? region,
    String? category,
    String? status,
  }) {
    setState(() {
      if (dateRange != null) _selectedDateRange = dateRange;
      if (region != null) _selectedRegion = region;
      if (category != null) _selectedServiceCategory = category;
      if (status != null) _selectedRecordStatus = status;

      // Conflict Resolution Logic: If "Archived" status selected with "Today", conflict arises
      if (_isConflictResolutionActive && _selectedRecordStatus == 'Archived' && _selectedDateRange == 'Today') {
        _selectedDateRange = 'Last 30 Days';
        _lastActionStatus = 'Conflict Resolution Triggered: Automatically resolved conflict ("Archived" + "Today" reset to "Last 30 Days") to prevent zero-result dead ends.';
      } else {
        _lastActionStatus = 'Applied Filters: Range=$_selectedDateRange, Region=$_selectedRegion, Service=$_selectedServiceCategory, Status=$_selectedRecordStatus';
      }
    });
  }

  // Mobile Substep 1 & UX Decision: Modal Bottom Sheet for Complex Filters
  void _openFilterModalBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                      Icon(Icons.filter_alt_outlined, color: colorScheme.primary),
                      AppSpacingTokens.hGapSm,
                      Text(
                        'Global Data-First Filtering Sheet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapXs,
                  Text(
                    'Saves vertical screen real estate on mobile screens while anchoring downstream KPI & Table views.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapSm,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // Date Range Selector
                  DropdownButtonFormField<String>(
                    value: _selectedDateRange,
                    decoration: const InputDecoration(
                      labelText: 'Date Range (Mandatory Filter)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Today', child: Text('Today (Real-Time)')),
                      DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
                      DropdownMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days (Logic Default)')),
                      DropdownMenuItem(value: 'Year to Date', child: Text('Year to Date')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => _selectedDateRange = val);
                        _applyFilterChoice(dateRange: val);
                      }
                    },
                  ),
                  AppSpacingTokens.vGapSm,

                  // Region Selector
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    decoration: const InputDecoration(
                      labelText: 'Geographic Region',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All Regions', child: Text('All Regions')),
                      DropdownMenuItem(value: 'US-East', child: Text('US-East')),
                      DropdownMenuItem(value: 'US-West', child: Text('US-West')),
                      DropdownMenuItem(value: 'EU-Central', child: Text('EU-Central')),
                      DropdownMenuItem(value: 'AP-South', child: Text('AP-South')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => _selectedRegion = val);
                        _applyFilterChoice(region: val);
                      }
                    },
                  ),
                  AppSpacingTokens.vGapSm,

                  // Status Selector
                  DropdownButtonFormField<String>(
                    value: _selectedRecordStatus,
                    decoration: const InputDecoration(
                      labelText: 'Record Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active Records')),
                      DropdownMenuItem(value: 'Archived', child: Text('Archived Records')),
                      DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => _selectedRecordStatus = val);
                        _applyFilterChoice(status: val);
                      }
                    },
                  ),

                  AppSpacingTokens.vGapLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _applyFilterChoice(
                            dateRange: 'Last 30 Days',
                            region: 'All Regions',
                            category: 'All Services',
                            status: 'Active',
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset Defaults'),
                      ),
                      AppSpacingTokens.hGapSm,
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Apply Downstream'),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final freshnessGrade = DashboardDataRefreshValidator.evaluateGrade(_simulatedAccuracy, _simulatedRefreshMin);

    // Compute downstream filtered data
    final filteredData = _allRawAnalyticsRecords.where((item) {
      final matchesRegion = _selectedRegion == 'All Regions' || item['region'] == _selectedRegion;
      final matchesCategory = _selectedServiceCategory == 'All Services' || item['category'] == _selectedServiceCategory;
      final matchesStatus = _selectedRecordStatus == 'All' || item['status'] == _selectedRecordStatus;
      return matchesRegion && matchesCategory && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card with Metadata & Step Information
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
                                color: freshnessGrade.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: freshnessGrade.color.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(freshnessGrade.icon, size: 14, color: freshnessGrade.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    freshnessGrade.label,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: freshnessGrade.color,
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
                              content: Text('Assigned: ${widget.record.assignedTeamMember} | Template: ${widget.record.templateName}'),
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
                      _buildInfoChip(Icons.dashboard_customize_outlined, 'Template: ${widget.record.templateName}', colorScheme),
                      _buildInfoChip(Icons.hub_outlined, 'Decision: ${widget.record.decisionGroup}', colorScheme),
                      _buildInfoChip(Icons.verified_outlined, 'Status: ${widget.record.completionStatus}', colorScheme),
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
                      Icon(Icons.analytics_outlined, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'Dashboard Data Refresh & Accuracy Rate Metric Boundary Evaluator',
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
                    'Reporting surfaces should meet standard BI freshness & accuracy benchmarks so operational decisions are not made on stale data.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // Preset Switcher for Floor, Optimal, Ceiling Boundaries
                  Text(
                    'Test Data Freshness & Accuracy Target Boundaries:',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  AppSpacingTokens.vGapXs,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Floor Boundary (95% Accuracy, ≤15 min Refresh)'),
                        selected: _simulatedAccuracy == 95.0 && _simulatedRefreshMin == 15.0,
                        selectedColor: AppColorPalette.warningContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedAccuracy = 95.0;
                              _simulatedRefreshMin = 15.0;
                              _lastActionStatus = 'Evaluated Floor Boundary (95% Accuracy, ≤15 min Refresh)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Optimal Target (99% Accuracy, ≤5 min Refresh)'),
                        selected: _simulatedAccuracy == 99.0 && _simulatedRefreshMin == 5.0,
                        selectedColor: AppColorPalette.infoContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedAccuracy = 99.0;
                              _simulatedRefreshMin = 5.0;
                              _lastActionStatus = 'Evaluated Optimal Target (99% Accuracy, ≤5 min Refresh)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Ceiling Target (99.9% Accuracy, <1 min Real-Time)'),
                        selected: _simulatedAccuracy == 99.9 && _simulatedRefreshMin == 0.5,
                        selectedColor: AppColorPalette.successContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedAccuracy = 99.9;
                              _simulatedRefreshMin = 0.5;
                              _lastActionStatus = 'Evaluated Ceiling Target (99.9% Accuracy, Near Real-Time <1 min)';
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  AppSpacingTokens.vGapMd,

                  // Detailed Boundary Rows
                  Container(
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: freshnessGrade.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: freshnessGrade.color.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        _buildBoundaryRow(
                          title: 'Floor Boundary (95% Accuracy, ≤15 min Refresh)',
                          description: 'Minimum BI reporting freshness baseline.',
                          isMet: _simulatedAccuracy >= 95.0 && _simulatedRefreshMin <= 15.0,
                          badgeColor: AppColorPalette.warning,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Optimal Target (99% Accuracy, ≤5 min Refresh)',
                          description: '99% data accuracy with high-frequency 5-minute synchronization.',
                          isMet: _simulatedAccuracy >= 99.0 && _simulatedRefreshMin <= 5.0,
                          badgeColor: AppColorPalette.info,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Ceiling Boundary (99.9% Accuracy, Near Real-Time <1 min)',
                          description: '99.9% accuracy with sub-minute real-time streaming updates.',
                          isMet: _simulatedAccuracy >= 99.9 && _simulatedRefreshMin <= 1.0,
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

          // STANDARDIZED DASHBOARD TEMPLATE (Substep 4 Layout Order: Filters -> KPIs -> Table)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SUBSTEP 4: ANCHOR HEADER — TOP STICKY FILTER BAR WITH HORIZONTALLY SCROLLING CHIPS
                Container(
                  padding: AppSpacingTokens.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColorPalette.brandPrimaryContainer.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.filter_list, color: AppColorPalette.brandPrimary),
                              AppSpacingTokens.hGapSm,
                              Text(
                                'Top Anchored Filter Bar (Substep 4)',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorPalette.onBrandPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          // Mobile Modal Bottom Sheet Trigger
                          FilledButton.tonalIcon(
                            onPressed: () => _openFilterModalBottomSheet(context),
                            icon: const Icon(Icons.tune, size: 16),
                            label: const Text('Filter Sheet', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,
                      
                      // Touch-Optimized Horizontally Scrolling Filter Chips (UI Decision)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Date Range Chip
                            FilterChip(
                              label: Text('Range: $_selectedDateRange'),
                              selected: true,
                              avatar: const Icon(Icons.calendar_today, size: 14),
                              onSelected: (_) => _openFilterModalBottomSheet(context),
                            ),
                            AppSpacingTokens.hGapSm,
                            // Region Chip
                            FilterChip(
                              label: Text('Region: $_selectedRegion'),
                              selected: _selectedRegion != 'All Regions',
                              avatar: const Icon(Icons.public, size: 14),
                              onSelected: (_) => _openFilterModalBottomSheet(context),
                            ),
                            AppSpacingTokens.hGapSm,
                            // Service Category Chip
                            FilterChip(
                              label: Text('Service: $_selectedServiceCategory'),
                              selected: _selectedServiceCategory != 'All Services',
                              avatar: const Icon(Icons.category_outlined, size: 14),
                              onSelected: (_) => _openFilterModalBottomSheet(context),
                            ),
                            AppSpacingTokens.hGapSm,
                            // Status Chip
                            FilterChip(
                              label: Text('Status: $_selectedRecordStatus'),
                              selected: _selectedRecordStatus != 'Active',
                              avatar: const Icon(Icons.flag_outlined, size: 14),
                              onSelected: (_) => _openFilterModalBottomSheet(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // DASHBOARD MIDDLE SECTOR: RESPONSIVE KPI PERFORMANCE CARDS
                Padding(
                  padding: AppSpacingTokens.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Middle Sector: Filtered KPI Performance Indicators',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      AppSpacingTokens.vGapSm,
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 600;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildKpiCard(
                                title: 'Filtered Revenue',
                                value: '\$${(filteredData.length * 9500).toString()}',
                                subtitle: 'Based on $_selectedDateRange',
                                color: colorScheme.primary,
                                isCompact: isCompact,
                                theme: theme,
                              ),
                              _buildKpiCard(
                                title: 'Matching Insights',
                                value: '${filteredData.length} Records',
                                subtitle: 'Out of ${_allRawAnalyticsRecords.length} total',
                                color: AppColorPalette.success,
                                isCompact: isCompact,
                                theme: theme,
                              ),
                              _buildKpiCard(
                                title: 'Cloud Query Cost',
                                value: '\$0.02 (Saved 85%)',
                                subtitle: 'Filtered fetch optimization',
                                color: AppColorPalette.warning,
                                isCompact: isCompact,
                                theme: theme,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // DASHBOARD BOTTOM SECTOR: DETAILED DATA TABLES (Substep 4 Layout Order)
                Padding(
                  padding: AppSpacingTokens.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bottom Sector: Downstream Detailed Analytics Table',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${filteredData.length} Rows Rendered',
                              style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer),
                            ),
                          ),
                        ],
                      ),
                      AppSpacingTokens.vGapSm,

                      if (filteredData.isEmpty)
                        Container(
                          padding: AppSpacingTokens.paddingLg,
                          alignment: Alignment.center,
                          child: const Text('No records match active filters.'),
                        )
                      else
                        Column(
                          children: filteredData.map((row) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: AppSpacingTokens.paddingSm,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.table_chart_outlined, size: 16, color: colorScheme.primary),
                                  AppSpacingTokens.hGapSm,
                                  Expanded(
                                    flex: 2,
                                    child: Text(row['id']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(row['category']!, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(row['region']!, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                  ),
                                  Text(row['revenue']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.primary)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacingTokens.vGapLg,

          // Mistake-Proofing (Poka-Yoke) & Self-Chasing Panel
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
                      Icon(Icons.shield_outlined, color: AppColorPalette.success),
                      AppSpacingTokens.hGapSm,
                      Text(
                        'Mistake-Proofing (Poka-Yoke) & Self-Chasing Conflict Resolution',
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
                    title: const Text('Logical Default Filter Pre-Filling (Poka-Yoke)'),
                    subtitle: const Text('Pre-fills "Last 30 Days" so users do not trigger unindexed massive database queries.'),
                    value: _pokaYokeDefaultFilterActive,
                    activeColor: AppColorPalette.success,
                    onChanged: (val) => setState(() => _pokaYokeDefaultFilterActive = val),
                  ),

                  SwitchListTile(
                    title: const Text('Automatic Conflicting Filter Disabling (Self-Chasing)'),
                    subtitle: const Text('Selecting conflicting options automatically resolves filters to prevent zero-result dead ends.'),
                    value: _isConflictResolutionActive,
                    activeColor: AppColorPalette.success,
                    onChanged: (val) => setState(() => _isConflictResolutionActive = val),
                  ),

                  AppSpacingTokens.vGapSm,
                  Container(
                    width: double.infinity,
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: AppColorPalette.brandPrimaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Execution Status:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColorPalette.onBrandPrimaryContainer,
                          ),
                        ),
                        AppSpacingTokens.vGapXs,
                        Text(
                          _lastActionStatus,
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
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
                        'Vitality & Prosperity (VAP) Business & Customer Impact',
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
                              'Optimizes Cloud spend while protecting mobile battery life from massive data fetches.',
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
                              'Provides targeted, digestible data slices immediately without cognitive overload.',
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isCompact,
    required ThemeData theme,
  }) {
    return Container(
      width: isCompact ? double.infinity : 180,
      padding: AppSpacingTokens.paddingMd,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
          AppSpacingTokens.vGapXs,
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
}
