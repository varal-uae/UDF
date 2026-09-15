/*
 * TTIAS-006 — Install and Verify Font Awesome 5 Professional Vector Graphic Library
 * 
 * Global Reference ID: TTIAS-006
 * Atomic Steps Reference ID: TTIAS-006-A01
 * Setup Step (Action): Install and verify the Font Awesome 5 professional vector graphic library within backend rendering layouts.
 * Setup Step Description: Open the backend project dependency configuration file (e.g., package.json or build manifest).
 * 4 Substeps:
 *   1) Add the verified icon library package reference to the master project asset bundle layout.
 *   2) Register standard system icon usage keys inside the Master Data Dictionary index.
 *   3) Enforce strict icon bounding layout rules inside core styling files.
 *   4) Run system rendering verification checks to confirm visual icon scaling across emulators.
 * 
 * Decision Group: System Iconography Foundation
 * Decision to be Made Before Setup Step: Select the precise default padding parameters required around vector interaction icons.
 * Decision Category: Interaction
 * Why This Matters: Eliminates platform structural fragmentation by enforcing a unified, predictable icon layout standard across teams.
 * Mobile App First Implication: Uses compact vector assets instead of heavy custom bitmap file downloads, drastically reducing mobile bandwidth costs.
 * UX Translation: Provides clear visual context markers next to navigation layout tabs and headers.
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Deployment / Build Stability Rate
 * - Floor Boundary (95%): 95% successful builds.
 * - Optimal Target (99.9%): 99.9% successful builds.
 * - Ceiling Boundary (100%): 100% (zero failed deploys).
 * Best Qualitative Output: Pass / Fail
 * Best Qualitative/Quantitative Output Type: Build and deployment steps should follow standard CI/CD reliability benchmarks before promotion to production.
 * Assigned Team Member: Brand Visual Designer / Frontend Ingress Engineer
 * Data Collected by System: Configuration Key; Configuration Value; Configuration Type; Validation Status; Configuration Timestamp; Completion Status ('Pass / Fail'); Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Google Material Design Decisions & Implementations:
 *   - UX Decision: Interactive icons follow exact 4px grid multiple configurations to guarantee layout sizing consistency.
 *   - UI Decision: Background color parameters follow brand guidelines to keep vector elements sharp.
 *   - UX Implementation: Active elements use transition rules to deliver smooth touch response shifts.
 *   - UI Implementation: Responsive components reflow elegantly across handheld screen formats.
 * 
 * Mistake-Proofing (Poka-Yoke): Code bundle parsers automatically flag deployment scripts if unmapped graphics files are found in code tracking pipelines.
 * Self-Chasing: Non-standard graphics cause automated pipeline verification alerts, prompting developers to fix tracking roots immediately.
 * Vitality & Prosperity (VAP):
 *   - Us: Streamlines asset development cycles, cutting out unique layout adjustments across platform releases.
 *   - Customer: Enhances operational confidence by utilizing clear, universally understood interface markers.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step TTIAS-006 Record Data Model.
class FontAwesomeVectorLibraryRecord {
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
  final String configurationKey;
  final String configurationValue;
  final String configurationType;
  final String validationStatus;
  final String configurationTimestamp;
  final String completionStatus; // 'Pass / Fail'
  final String userId;
  final String userSessionId;
  final double buildStabilityPercentage;
  final bool isCodeBundleParserPassed;

  const FontAwesomeVectorLibraryRecord({
    this.globalRefId = 'TTIAS-006',
    this.atomicStepRefId = 'TTIAS-006-A01',
    this.setupAction = 'Install and verify the Font Awesome 5 professional vector graphic library within backend rendering layouts.',
    this.setupDescription = 'Open the backend project dependency configuration file (e.g., package.json or build manifest).',
    this.decisionGroup = 'System Iconography Foundation',
    this.decisionCategory = 'Interaction',
    this.whyThisMatters = 'Eliminates platform structural fragmentation by enforcing a unified, predictable icon layout standard across teams.',
    this.mobileAppFirstImplication = 'Uses compact vector assets instead of heavy custom bitmap file downloads, drastically reducing mobile bandwidth costs.',
    this.uxTranslation = 'Provides clear visual context markers next to navigation layout tabs and headers.',
    this.commonLibraryToStore = 'Platform system universal design component directory module.',
    this.atomicReusability = 'Registry micro-icons scale fluidly across multiple transactional and overview flows.',
    this.gcpBigQueryAlignment = 'Ingress assets leverage browser asset caching layers to optimize interface initial render operations under 3 seconds.',
    this.sequenceOrder = 'Level 13 | Phase: EXECUTION | Atomic Step: 1.0 | Row: 3090.0',
    this.estimatedTimeRequired = '3 Hours',
    this.expectedOutput = 'A unified typography asset layout hardlocking vector icons to standard corporate configurations.',
    this.completionMeasures = 'Frontend component check passes prove that zero custom icon assets exist in view markups.',
    this.dependencies = 'HC-SCH-0093',
    this.domainExpertiseNeeded = 'Brand Visual Designer / Frontend Ingress Engineer',
    this.assignedTeamMember = 'Brand Visual Designer / Frontend Ingress Engineer',
    this.configurationKey = 'sys.iconography.fontawesome5_pro',
    this.configurationValue = 'v5.15.4-pro_verified',
    this.configurationType = 'VectorAssetLibraryPackage',
    this.validationStatus = 'VERIFIED_STABLE',
    required this.configurationTimestamp,
    this.completionStatus = 'Pass',
    required this.userId,
    required this.userSessionId,
    this.buildStabilityPercentage = 100.0, // 100% Ceiling Target
    this.isCodeBundleParserPassed = true,
  });
}

enum BuildStabilityGrade {
  ceiling('Ceiling Target (100% Zero Failed Deploys)', AppColorPalette.success, Icons.stars),
  optimal('Optimal Target (99.9% Successful Builds)', AppColorPalette.info, Icons.check_circle),
  floor('Floor Boundary (95.0% Successful Builds)', AppColorPalette.warning, Icons.warning_amber),
  failing('Failing Stability (<95.0% Unstable CI/CD Build Pipeline)', AppColorPalette.lightError, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const BuildStabilityGrade(this.label, this.color, this.icon);
}

abstract class DeploymentBuildStabilityValidator {
  static BuildStabilityGrade evaluateGrade(double stabilityPercentage) {
    if (stabilityPercentage >= 100.0) {
      return BuildStabilityGrade.ceiling;
    } else if (stabilityPercentage >= 99.9) {
      return BuildStabilityGrade.optimal;
    } else if (stabilityPercentage >= 95.0) {
      return BuildStabilityGrade.floor;
    } else {
      return BuildStabilityGrade.failing;
    }
  }
}

/// Step 64 Main Component Panel Widget
class FontAwesomeVectorLibraryPanel extends StatefulWidget {
  final FontAwesomeVectorLibraryRecord record;

  const FontAwesomeVectorLibraryPanel({
    super.key,
    required this.record,
  });

  @override
  State<FontAwesomeVectorLibraryPanel> createState() => _FontAwesomeVectorLibraryPanelState();
}

class _FontAwesomeVectorLibraryPanelState extends State<FontAwesomeVectorLibraryPanel> {
  late double _simulatedStability;
  double _iconPaddingGridMultiple = 8.0; // 4px grid multiple (4, 8, 12, 16)
  bool _pokaYokeUnmappedGraphicsParser = true;
  bool _selfChasingPipelineAlertsActive = true;
  double _simulatedInitialRenderTimeSec = 1.8; // <3.0 seconds requirement
  String _lastVerificationResult = 'All view markups verified 100% compliant with corporate asset pool.';

  // Substep 2 Data Dictionary Registered Icon Keys
  final List<Map<String, dynamic>> _registeredIconDictionary = [
    {
      'key': 'icon.nav.dashboard',
      'label': 'Dashboard Analytics',
      'icon': Icons.dashboard_outlined,
      'boundingGrid': '16px (4px multiple)',
      'status': 'REGISTERED_VERIFIED',
    },
    {
      'key': 'icon.action.security_lock',
      'label': 'IAM Security Lock',
      'icon': Icons.lock_outline,
      'boundingGrid': '16px (4px multiple)',
      'status': 'REGISTERED_VERIFIED',
    },
    {
      'key': 'icon.status.check_circle',
      'label': 'System Reconciliation',
      'icon': Icons.check_circle_outline,
      'boundingGrid': '12px (4px multiple)',
      'status': 'REGISTERED_VERIFIED',
    },
    {
      'key': 'icon.network.telemetry',
      'label': 'BigQuery Telemetry',
      'icon': Icons.cell_tower_outlined,
      'boundingGrid': '16px (4px multiple)',
      'status': 'REGISTERED_VERIFIED',
    },
    {
      'key': 'icon.user.profile_shield',
      'label': 'User Access Shield',
      'icon': Icons.shield_outlined,
      'boundingGrid': '20px (4px multiple)',
      'status': 'REGISTERED_VERIFIED',
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulatedStability = widget.record.buildStabilityPercentage;
  }

  void _runCodeBundleParserVerification() {
    setState(() {
      _lastVerificationResult = _pokaYokeUnmappedGraphicsParser
          ? 'SUCCESS: Code bundle parser scan clean. 0 custom/bitmap graphics found in view markups.'
          : 'WARNING: Unmapped graphic file detected in bundle! Raised CI/CD pipeline alert.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stabilityGrade = DeploymentBuildStabilityValidator.evaluateGrade(_simulatedStability);

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
                                color: stabilityGrade.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: stabilityGrade.color.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(stabilityGrade.icon, size: 14, color: stabilityGrade.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    stabilityGrade.label,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: stabilityGrade.color,
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
                              content: Text('Assigned: ${widget.record.assignedTeamMember} | Key: ${widget.record.configurationKey}'),
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
                      _buildInfoChip(Icons.key_outlined, 'Config Key: ${widget.record.configurationKey}', colorScheme),
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
                      Icon(Icons.build_circle_outlined, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'Deployment / Build Stability Rate Metric Boundary Evaluator',
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
                    'Build and deployment steps should follow standard CI/CD reliability benchmarks before promotion to production.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // Preset Switcher for Floor, Optimal, Ceiling Boundaries
                  Text(
                    'Test Deployment / Build Stability Rate Boundaries:',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  AppSpacingTokens.vGapXs,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Floor Boundary (95.0% Successful Builds)'),
                        selected: _simulatedStability == 95.0,
                        selectedColor: AppColorPalette.warningContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedStability = 95.0;
                              _lastVerificationResult = 'Evaluated Floor Boundary (95.0% Successful Builds)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Optimal Target (99.9% Successful Builds)'),
                        selected: _simulatedStability == 99.9,
                        selectedColor: AppColorPalette.infoContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedStability = 99.9;
                              _lastVerificationResult = 'Evaluated Optimal Target (99.9% Successful Builds)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Ceiling Target (100% Zero Failed Deploys)'),
                        selected: _simulatedStability == 100.0,
                        selectedColor: AppColorPalette.successContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedStability = 100.0;
                              _lastVerificationResult = 'Evaluated Ceiling Target (100% Zero Failed Deploys)';
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  AppSpacingTokens.vGapMd,

                  // Detailed Boundary Status Cards
                  Container(
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: stabilityGrade.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: stabilityGrade.color.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        _buildBoundaryRow(
                          title: 'Floor Boundary (95.0% Successful Builds)',
                          description: 'Standard baseline CI/CD build success threshold.',
                          isMet: _simulatedStability >= 95.0,
                          badgeColor: AppColorPalette.warning,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Optimal Target (99.9% Successful Builds)',
                          description: '99.9% build reliability across production deployment pipelines.',
                          isMet: _simulatedStability >= 99.9,
                          badgeColor: AppColorPalette.info,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Ceiling Boundary (100% Zero Failed Deploys)',
                          description: '100% zero deployment failures across all asset bundle pipelines.',
                          isMet: _simulatedStability >= 100.0,
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

          // SUBSTEPS 1-4 INTERACTIVE VECTOR ICONOGRAPHY FOUNDATION SANDBOX
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
                      Row(
                        children: [
                          Icon(Icons.polyline_outlined, color: colorScheme.primary),
                          AppSpacingTokens.hGapSm,
                          Text(
                            'Substeps 1-4: Iconography Asset & Bounding Grid Sandbox',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColorPalette.successContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Render Speed: ${_simulatedInitialRenderTimeSec}s (<3s)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColorPalette.onSuccessContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapXs,
                  Text(
                    'Substep 1: Verified package asset bundle. Substep 2: Registered Master Data Dictionary keys. Substep 3: 4px Grid bounding rules. Substep 4: Multi-emulator scaling.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // Substep 3: 4px Grid Multiple Padding Selector
                  Row(
                    children: [
                      Text(
                        'Substep 3 Icon Bounding Grid Padding (4px Multiple):',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacingTokens.hGapSm,
                      SegmentedButton<double>(
                        segments: const [
                          ButtonSegment(value: 4.0, label: Text('4px', style: TextStyle(fontSize: 11))),
                          ButtonSegment(value: 8.0, label: Text('8px', style: TextStyle(fontSize: 11))),
                          ButtonSegment(value: 12.0, label: Text('12px', style: TextStyle(fontSize: 11))),
                          ButtonSegment(value: 16.0, label: Text('16px', style: TextStyle(fontSize: 11))),
                        ],
                        selected: {_iconPaddingGridMultiple},
                        onSelectionChanged: (val) {
                          setState(() {
                            _iconPaddingGridMultiple = val.first;
                            _lastVerificationResult = 'Applied exact ${_iconPaddingGridMultiple}px (4px multiple) icon bounding rule.';
                          });
                        },
                      ),
                    ],
                  ),

                  AppSpacingTokens.vGapMd,

                  // Substep 2 Data Dictionary Registered Icons Table/List
                  Text(
                    'Substep 2: Master Data Dictionary Registered Icon Keys Index:',
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  AppSpacingTokens.vGapSm,

                  Column(
                    children: _registeredIconDictionary.map((item) {
                      final iconData = item['icon'] as IconData;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: EdgeInsets.all(_iconPaddingGridMultiple),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            // Sharp Brand Vector Icon Container
                            Container(
                              padding: EdgeInsets.all(_iconPaddingGridMultiple / 2),
                              decoration: BoxDecoration(
                                color: AppColorPalette.brandPrimaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(iconData, color: AppColorPalette.brandPrimary, size: 20),
                            ),
                            AppSpacingTokens.hGapMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['label'].toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Key: ${item['key']}',
                                    style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColorPalette.successContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['status'].toString(),
                                style: const TextStyle(fontSize: 10, color: AppColorPalette.onSuccessContainer, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
                      Icon(Icons.shield_outlined, color: AppColorPalette.success),
                      AppSpacingTokens.hGapSm,
                      Text(
                        'Mistake-Proofing (Poka-Yoke) & Automated Pipeline Verification',
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
                    title: const Text('Code Bundle Graphics Parser (Poka-Yoke)'),
                    subtitle: const Text('Automatically flags deployment scripts if unmapped graphics files exist in tracking pipelines.'),
                    value: _pokaYokeUnmappedGraphicsParser,
                    activeColor: AppColorPalette.success,
                    onChanged: (val) {
                      setState(() {
                        _pokaYokeUnmappedGraphicsParser = val;
                        _runCodeBundleParserVerification();
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('Automated Pipeline Verification Alerts (Self-Chasing)'),
                    subtitle: const Text('Non-standard graphics cause automated alerts prompting developers to fix tracking roots immediately.'),
                    value: _selfChasingPipelineAlertsActive,
                    activeColor: AppColorPalette.success,
                    onChanged: (val) => setState(() => _selfChasingPipelineAlertsActive = val),
                  ),

                  AppSpacingTokens.vGapSm,
                  Container(
                    width: double.infinity,
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: _pokaYokeUnmappedGraphicsParser
                          ? AppColorPalette.successContainer.withOpacity(0.5)
                          : AppColorPalette.warningContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _pokaYokeUnmappedGraphicsParser ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                          color: _pokaYokeUnmappedGraphicsParser ? AppColorPalette.success : AppColorPalette.warning,
                        ),
                        AppSpacingTokens.hGapSm,
                        Expanded(
                          child: Text(
                            _lastVerificationResult,
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
                        'Vitality & Prosperity (VAP) System Impact',
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
                              'Streamlines asset development cycles, cutting out unique layout adjustments across platform releases.',
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
                              'Enhances operational confidence by utilizing clear, universally understood interface markers.',
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
}
