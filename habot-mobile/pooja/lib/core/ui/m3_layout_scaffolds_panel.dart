/*
 * FEBFL-025 — Deploy Material 3 Layout Scaffolds
 * 
 * Global Reference ID: FEBFL-025
 * Atomic Steps Reference ID: FEBFL-025-A01
 * Setup Step (Action): Deploy Material 3 Layout Scaffolds.
 * Setup Step Description: Open the primary marketplace view directory within the front-end application.
 * 4 Substeps:
 *   1) Apply adaptive "Feed" card layouts onto primary service discovery views.
 *   2) Configure side-by-side "List-Detail" presentation rules for expanded viewport windows.
 *   3) Structure a collapsible "Supporting Pane" to house filtering metrics elegantly.
 *   4) Implement automated responsive scaffolds to shift configurations to single-column streams on compact screens.
 * 
 * Decision Group: Front-End Layout Engineering.
 * Decision to be Made Before Setup Step: Establish the explicit width pixel dimensions for the supporting parameter pane on large viewports.
 * Decision Category: Front-End Interaction and UX Architecture.
 * Why This Matters: Minimizes customer conversion friction by replacing erratic layout behavior with predictable, intuitive interface mechanics.
 * Mobile App First Implication: Sets single-column stacked scrolling parameters as the root application layout, ensuring smooth gesture tracking on small screens.
 * UX Translation: Clean, structured asset delivery that scales layout containers seamlessly across smartphone form factors.
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: File/Asset Discovery Accuracy - the primary marketplace view directory within the front-end
 * - Floor Boundary: Correct target located within 3 attempts or under 5 minutes of manual search.
 * - Optimal Target: Correct target located on first attempt via documented path/index reference, under 1 minute.
 * - Ceiling Boundary: Automated tooling (IDE symbol search, CLI script, or repo index) resolves target instantly with 100% path accuracy.
 * Best Qualitative Output: Pass/Fail
 * Best Qualitative/Quantitative Output Type: Benchmark against standard software-discoverability practice (documented repository structure, IDE go-to-definition). The team should never rely on tribal knowledge to find the target asset.
 * Assigned Team Member: User Experience Interface Engineering Lead
 * Data Collected by System: Object Type; Object Location/Path; Open Status; Timestamp; File Handle ID; Completion Status ('Pass/Fail'); Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Google Material Design Decisions & Implementations:
 *   - UX Decision: Large screen options preserve a sticky filter panel parameter lock on the right boundary.
 *   - UI Decision: Mobile configurations apply a single-column layout flow backed by floating call-to-action triggers.
 *   - UX Implementation: Layout layers implement sequential tab configurations to optimize accessibility screen-reader logic.
 *   - UI Implementation: Transition effects leverage subtle fade-slide animations to eliminate jarring visual cuts.
 * 
 * Mistake-Proofing (Poka-Yoke): Core CSS configurations force rigid snap-to-grid constraints, physically blocking misaligned card elements from rendering.
 * Self-Chasing: Interface loading speeds are tracked autonomously; slow-rendering layout panels register optimization tickets instantly.
 * Vitality & Prosperity (VAP):
 *   - Us: Speeds up selection velocity metrics, accelerating daily marketplace transaction volume milestones.
 *   - Customer: Delivers fluid "Quick View" interaction fields, allowing families to evaluate options without navigation confusion.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step FEBFL-025 Record Data Model.
class M3LayoutScaffoldsRecord {
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
  final String objectType;
  final String objectLocationPath;
  final String openStatus;
  final String timestamp;
  final String fileHandleId;
  final String completionStatus; // 'Pass' or 'Fail'
  final String userId;
  final String userSessionId;
  final double discoveryAccuracyScore;
  final bool isAutomatedToolingResolved;

  const M3LayoutScaffoldsRecord({
    this.globalRefId = 'FEBFL-025',
    this.atomicStepRefId = 'FEBFL-025-A01',
    this.setupAction = 'Deploy Material 3 Layout Scaffolds.',
    this.setupDescription = 'Open the primary marketplace view directory within the front-end application.',
    this.decisionGroup = 'Front-End Layout Engineering.',
    this.decisionCategory = 'Front-End Interaction and UX Architecture.',
    this.whyThisMatters = 'Minimizes customer conversion friction by replacing erratic layout behavior with predictable, intuitive interface mechanics.',
    this.mobileAppFirstImplication = 'Sets single-column stacked scrolling parameters as the root application layout, ensuring smooth gesture tracking on small screens.',
    this.uxTranslation = 'Clean, structured asset delivery that scales layout containers seamlessly across smartphone form factors.',
    this.commonLibraryToStore = 'MD3 Canonical Layout Library.',
    this.atomicReusability = 'The modular listing card component architecture is 100% reusable across recommended dashboard fields.',
    this.gcpBigQueryAlignment = 'Processing engines log device resize occurrences to evaluate and optimize layout performance across user segments.',
    this.sequenceOrder = 'Level 13 | Phase: EXECUTION | Atomic Step: 1.0 | Row: 3068.0',
    this.estimatedTimeRequired = '2 Days.',
    this.expectedOutput = 'Verified responsive page layout designs and integrated component blueprints.',
    this.completionMeasures = 'Cross-device rendering tests prove smooth, bug-free panel rearrangement when viewports alter.',
    this.dependencies = 'Serial Number 12 (Hardcode Material 3 Custom Typeface Tokens Setup Step)',
    this.domainExpertiseNeeded = 'User Experience Interface Engineering.',
    this.assignedTeamMember = 'User Experience Interface Engineering Lead',
    this.objectType = 'Front-End Marketplace Layout Scaffold',
    this.objectLocationPath = 'lib/core/ui/m3_layout_scaffolds_panel.dart',
    this.openStatus = 'OPENED_AND_LOGGED',
    required this.timestamp,
    required this.fileHandleId,
    this.completionStatus = 'Pass',
    required this.userId,
    required this.userSessionId,
    this.discoveryAccuracyScore = 1.0, // 100% accuracy
    this.isAutomatedToolingResolved = true,
  });
}

enum AssetDiscoveryGrade {
  ceiling('Ceiling Boundary (Automated Tooling Resolves Target Instantly - 100% Accuracy)', AppColorPalette.success, Icons.stars),
  optimal('Optimal Target (First Attempt via Documented Path <1 min)', AppColorPalette.info, Icons.check_circle),
  floor('Floor Boundary (Target Located within 3 attempts / <5 min)', AppColorPalette.warning, Icons.warning_amber),
  failing('Failing Discovery (Path Undocumented / Tribal Knowledge Required)', AppColorPalette.lightError, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const AssetDiscoveryGrade(this.label, this.color, this.icon);
}

abstract class AssetDiscoveryAccuracyValidator {
  static AssetDiscoveryGrade evaluateGrade(double score, bool automatedResolved) {
    if (score >= 1.0 && automatedResolved) {
      return AssetDiscoveryGrade.ceiling;
    } else if (score >= 1.0) {
      return AssetDiscoveryGrade.optimal;
    } else if (score >= 0.80) {
      return AssetDiscoveryGrade.floor;
    } else {
      return AssetDiscoveryGrade.failing;
    }
  }
}

enum SimulatedViewportMode {
  compactMobile(360, 'Compact Mobile (360dp)', Icons.smartphone),
  mediumTablet(720, 'Medium Tablet (720dp)', Icons.tablet),
  expandedDesktop(1080, 'Expanded Desktop (1080dp)', Icons.desktop_windows);

  final double width;
  final String label;
  final IconData icon;
  const SimulatedViewportMode(this.width, this.label, this.icon);
}

/// FEBFL-025 Main Component Panel Widget
class M3LayoutScaffoldsPanel extends StatefulWidget {
  final M3LayoutScaffoldsRecord record;

  const M3LayoutScaffoldsPanel({
    super.key,
    required this.record,
  });

  @override
  State<M3LayoutScaffoldsPanel> createState() => _M3LayoutScaffoldsPanelState();
}

class _M3LayoutScaffoldsPanelState extends State<M3LayoutScaffoldsPanel>
    with SingleTickerProviderStateMixin {
  SimulatedViewportMode _viewportMode = SimulatedViewportMode.compactMobile;
  int _activeTabNavIndex = 0;
  int? _selectedCardDetailIndex = 0; // Default selecting 1st item for List-Detail
  bool _isSupportingPaneExpanded = true;

  // Metric Evaluation Simulated State
  late double _simulatedAccuracyScore;
  late bool _simulatedAutomatedTooling;

  // Poka-Yoke & Self-Chasing State
  bool _strictSnapToGridActive = true;
  bool _loadingSpeedTicketTrackerActive = true;
  double _simulatedRenderSpeedMs = 24.5;
  String _lastActionTriggered = 'Scaffold Engine Ready';

  late TabController _tabController;

  final List<Map<String, String>> _marketplaceFeedItems = [
    {
      'title': 'Enterprise Family Care Service',
      'category': 'Care Management',
      'rating': '4.9 ★',
      'price': '\$120/hr',
      'description': 'Comprehensive family care management with real-time telemetry and verified caregiver mapping.',
      'metrics': 'Response Time: < 5 min | Verification: 100%',
    },
    {
      'title': 'Senior Home Assistance Package',
      'category': 'Assisted Care',
      'rating': '4.8 ★',
      'price': '\$95/hr',
      'description': 'On-demand specialized assistance for senior family members with daily activity monitoring.',
      'metrics': 'Caregivers: 45 Active | Satisfaction: 98%',
    },
    {
      'title': 'Pediatric Specialized Nursing',
      'category': 'Pediatric Care',
      'rating': '5.0 ★',
      'price': '\$150/hr',
      'description': 'Certified pediatric nurses providing home medical support and continuous vital logging.',
      'metrics': 'Certification: ICU Level | Coverage: 24/7',
    },
    {
      'title': 'After-School Learning Companion',
      'category': 'Educational Care',
      'rating': '4.7 ★',
      'price': '\$65/hr',
      'description': 'Interactive learning companions helping children with stem coursework and daily routines.',
      'metrics': 'Subjects: Math, Science | Verified Background',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _simulatedAccuracyScore = widget.record.discoveryAccuracyScore;
    _simulatedAutomatedTooling = widget.record.isAutomatedToolingResolved;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final discoveryGrade = AssetDiscoveryAccuracyValidator.evaluateGrade(
      _simulatedAccuracyScore,
      _simulatedAutomatedTooling,
    );

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
                                color: discoveryGrade.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: discoveryGrade.color.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(discoveryGrade.icon, size: 14, color: discoveryGrade.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    discoveryGrade.label,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: discoveryGrade.color,
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
                              content: Text('Assigned: ${widget.record.assignedTeamMember} | File Handle: ${widget.record.fileHandleId}'),
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
                      _buildInfoChip(Icons.folder_open_outlined, 'Path: ${widget.record.objectLocationPath}', colorScheme),
                      _buildInfoChip(Icons.hub_outlined, 'Decision: ${widget.record.decisionGroup}', colorScheme),
                      _buildInfoChip(Icons.shield_outlined, 'Status: ${widget.record.completionStatus}', colorScheme),
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
                      Icon(Icons.find_in_page_outlined, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'File/Asset Discovery Accuracy Boundary Evaluator',
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
                    'Benchmark against standard software-discoverability practice. The team should never rely on tribal knowledge to find target assets.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // Preset Switcher for Floor, Optimal, Ceiling Boundaries
                  Text(
                    'Test Asset Discovery Accuracy Boundaries:',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  AppSpacingTokens.vGapXs,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Floor Boundary (Within 3 attempts / <5 min)'),
                        selected: _simulatedAccuracyScore == 0.80 && !_simulatedAutomatedTooling,
                        selectedColor: AppColorPalette.warningContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedAccuracyScore = 0.80;
                              _simulatedAutomatedTooling = false;
                              _lastActionTriggered = 'Evaluated Floor Boundary (Within 3 Attempts)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Optimal Target (First Attempt <1 min)'),
                        selected: _simulatedAccuracyScore == 1.0 && !_simulatedAutomatedTooling,
                        selectedColor: AppColorPalette.infoContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedAccuracyScore = 1.0;
                              _simulatedAutomatedTooling = false;
                              _lastActionTriggered = 'Evaluated Optimal Target (First Attempt via Documented Path)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Ceiling Target (Automated Tooling Resolves Instantly)'),
                        selected: _simulatedAccuracyScore == 1.0 && _simulatedAutomatedTooling,
                        selectedColor: AppColorPalette.successContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedAccuracyScore = 1.0;
                              _simulatedAutomatedTooling = true;
                              _lastActionTriggered = 'Evaluated Ceiling Target (Automated IDE/CLI Tooling Instant Resolution)';
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  AppSpacingTokens.vGapMd,

                  // Detailed Boundary Row Statuses
                  Container(
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: discoveryGrade.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: discoveryGrade.color.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        _buildBoundaryRow(
                          title: 'Floor Boundary (Target Located within 3 attempts / <5 min)',
                          description: 'Manual search locates target file without blocking development.',
                          isMet: _simulatedAccuracyScore >= 0.80,
                          badgeColor: AppColorPalette.warning,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Optimal Target (First attempt via documented path <1 min)',
                          description: 'Target located instantly on first attempt using index documentation.',
                          isMet: _simulatedAccuracyScore >= 1.0,
                          badgeColor: AppColorPalette.info,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Ceiling Boundary (Automated tooling resolves target with 100% accuracy)',
                          description: 'Automated IDE symbol search, CLI script, or repo index resolves target instantly.',
                          isMet: _simulatedAccuracyScore >= 1.0 && _simulatedAutomatedTooling,
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

          // Substep 4 & UX Requirement: Viewport Size Class Switcher (Compact, Medium, Expanded)
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
                      Icon(Icons.dashboard_customize_outlined, color: colorScheme.primary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'M3 Window Size Class Scaffolding Simulator',
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
                    'Obey standard M3 window size classifications (Compact, Medium, Expanded) and test fluid layout rearrangement.',
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
                        _lastActionTriggered = 'Switched to ${_viewportMode.label} Viewport Scaffold';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          AppSpacingTokens.vGapLg,

          // MAIN MATERIAL 3 LAYOUT SCAFFOLD SANDBOX
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: _viewportMode == SimulatedViewportMode.expandedDesktop
                  ? double.infinity
                  : _viewportMode.width,
            ),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  // App Bar Header with Sequential Tab Configuration
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColorPalette.brandPrimaryContainer.withOpacity(0.6),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront_outlined, color: AppColorPalette.brandPrimary),
                            AppSpacingTokens.hGapSm,
                            Expanded(
                              child: Text(
                                'Marketplace Primary View (${_viewportMode.label})',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorPalette.onBrandPrimaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Toggle Supporting Parameter Pane',
                              icon: Icon(
                                _isSupportingPaneExpanded ? Icons.tune : Icons.tune_outlined,
                                color: AppColorPalette.brandPrimary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isSupportingPaneExpanded = !_isSupportingPaneExpanded;
                                  _lastActionTriggered = 'Toggled Supporting Parameter Pane';
                                });
                              },
                            ),
                          ],
                        ),
                        // Sequential Tab Configurations for Accessibility Logic
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColorPalette.onBrandPrimaryContainer,
                          indicatorColor: AppColorPalette.brandPrimary,
                          tabs: const [
                            Tab(text: 'Discovery Feed'),
                            Tab(text: 'List-Detail Matrix'),
                            Tab(text: 'Supporting Pane Metrics'),
                          ],
                          onTap: (index) {
                            setState(() {
                              _activeTabNavIndex = index;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Scaffold Body Layout (List-Detail + Supporting Pane)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey('tab_${_activeTabNavIndex}_${_viewportMode.name}'),
                      child: _buildTabScaffoldBody(context, theme, colorScheme),
                    ),
                  ),
                ],
              ),
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
                      Icon(Icons.gavel_outlined, color: AppColorPalette.success),
                      AppSpacingTokens.hGapSm,
                      Text(
                        'Mistake-Proofing (Poka-Yoke) & Autonomous Self-Chasing',
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
                    title: const Text('Rigid Snap-to-Grid CSS Constraints (Poka-Yoke)'),
                    subtitle: const Text('Physically blocks misaligned card elements from rendering on grid layouts.'),
                    value: _strictSnapToGridActive,
                    activeColor: AppColorPalette.success,
                    onChanged: (val) => setState(() => _strictSnapToGridActive = val),
                  ),

                  SwitchListTile(
                    title: const Text('Autonomous Interface Loading Speed Tracker (Self-Chasing)'),
                    subtitle: const Text('Monitors render speeds in real time; registers optimization tickets instantly if >100ms.'),
                    value: _loadingSpeedTicketTrackerActive,
                    activeColor: AppColorPalette.success,
                    onChanged: (val) => setState(() => _loadingSpeedTicketTrackerActive = val),
                  ),

                  AppSpacingTokens.vGapSm,
                  Container(
                    width: double.infinity,
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: AppColorPalette.successContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, color: AppColorPalette.success),
                        AppSpacingTokens.hGapSm,
                        Expanded(
                          child: Text(
                            'Current Render Latency: ${_simulatedRenderSpeedMs.toStringAsFixed(1)}ms (Optimal) | Action: $_lastActionTriggered',
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
                        'Vitality & Prosperity (VAP) Marketplace Impact',
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
                              'Speeds up selection velocity metrics, accelerating daily marketplace transaction volume milestones.',
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
                              'Delivers fluid "Quick View" interaction fields, allowing families to evaluate options without navigation confusion.',
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

  Widget _buildTabScaffoldBody(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final isCompact = _viewportMode == SimulatedViewportMode.compactMobile;
    final isExpanded = _viewportMode == SimulatedViewportMode.expandedDesktop;

    return Padding(
      padding: AppSpacingTokens.paddingMd,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: List / Feed Cards (Substep 1 & 2)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Substep 1 & 2: Primary Discovery Feed & List Cards',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    AppSpacingTokens.vGapXs,
                    Text(
                      isCompact
                          ? 'Single-column stacked scrolling flow with floating call-to-action triggers.'
                          : 'Side-by-side List-Detail presentation layout enabled.',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    AppSpacingTokens.vGapSm,
                    Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                    AppSpacingTokens.vGapSm,

                    // Listing Cards Stream
                    Column(
                      children: List.generate(_marketplaceFeedItems.length, (idx) {
                        final item = _marketplaceFeedItems[idx];
                        final isSelected = _selectedCardDetailIndex == idx;
                        return Card(
                          elevation: isSelected ? 3 : 1,
                          color: isSelected
                              ? AppColorPalette.brandPrimaryContainer.withOpacity(0.3)
                              : colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColorPalette.brandPrimary
                                  : colorScheme.outlineVariant.withOpacity(0.4),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedCardDetailIndex = idx;
                                _lastActionTriggered = 'Selected Listing: ${item['title']}';
                              });
                            },
                            child: Padding(
                              padding: AppSpacingTokens.paddingMd,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['title']!,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        item['price']!,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColorPalette.brandPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacingTokens.vGapXs,
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item['category']!,
                                          style: TextStyle(fontSize: 10, color: colorScheme.onSecondaryContainer),
                                        ),
                                      ),
                                      AppSpacingTokens.hGapSm,
                                      Text(item['rating']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                                    ],
                                  ),
                                  AppSpacingTokens.vGapSm,
                                  Text(
                                    item['description']!,
                                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Detail Frame (Substep 2 List-Detail presentation on Expanded or Medium)
              if (!isCompact && _selectedCardDetailIndex != null) ...[
                AppSpacingTokens.hGapMd,
                Expanded(
                  flex: 5,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: colorScheme.surface,
                    child: Padding(
                      padding: AppSpacingTokens.paddingMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Substep 2: Quick View Detail Frame',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColorPalette.successContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Side-by-Side Presentation',
                                  style: TextStyle(fontSize: 10, color: AppColorPalette.onSuccessContainer, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          AppSpacingTokens.vGapSm,
                          Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                          AppSpacingTokens.vGapSm,
                          Text(
                            _marketplaceFeedItems[_selectedCardDetailIndex!]['title']!,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          AppSpacingTokens.vGapXs,
                          Text(
                            _marketplaceFeedItems[_selectedCardDetailIndex!]['description']!,
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          AppSpacingTokens.vGapMd,
                          Container(
                            padding: AppSpacingTokens.paddingSm,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _marketplaceFeedItems[_selectedCardDetailIndex!]['metrics']!,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          AppSpacingTokens.vGapMd,
                          FilledButton.icon(
                            onPressed: () {
                              setState(() {
                                _lastActionTriggered = 'Booked Service: ${_marketplaceFeedItems[_selectedCardDetailIndex!]['title']}';
                              });
                            },
                            icon: const Icon(Icons.flash_on, size: 16),
                            label: const Text('Book Care Service Now'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Substep 3: Collapsible Supporting Pane (Sticky on Large Screens)
              if (isExpanded && _isSupportingPaneExpanded) ...[
                AppSpacingTokens.hGapMd,
                SizedBox(
                  width: 260,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: AppColorPalette.brandPrimaryContainer.withOpacity(0.2),
                    child: Padding(
                      padding: AppSpacingTokens.paddingMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.push_pin, size: 16, color: AppColorPalette.brandPrimary),
                              AppSpacingTokens.hGapSm,
                              Text(
                                'Substep 3: Sticky Supporting Pane',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorPalette.onBrandPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          AppSpacingTokens.vGapXs,
                          const Text(
                            'Right boundary parameter lock for filtering metrics on large viewports.',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          AppSpacingTokens.vGapSm,
                          const Divider(),
                          AppSpacingTokens.vGapXs,
                          const Text('Category Filters:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const CheckboxListTile(
                            value: true,
                            onChanged: null,
                            dense: true,
                            title: Text('Care Management', style: TextStyle(fontSize: 11)),
                          ),
                          const CheckboxListTile(
                            value: true,
                            onChanged: null,
                            dense: true,
                            title: Text('Assisted Senior Care', style: TextStyle(fontSize: 11)),
                          ),
                          const CheckboxListTile(
                            value: true,
                            onChanged: null,
                            dense: true,
                            title: Text('Pediatric Care', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Substep 4 Mobile: Floating Call-to-Action Trigger
          if (isCompact)
            Positioned(
              bottom: 8,
              right: 8,
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _lastActionTriggered = 'Triggered Mobile Floating CTA Quick Action';
                  });
                },
                icon: const Icon(Icons.flash_on),
                label: const Text('Quick Filter'),
                backgroundColor: AppColorPalette.brandPrimary,
                foregroundColor: Colors.white,
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
}
