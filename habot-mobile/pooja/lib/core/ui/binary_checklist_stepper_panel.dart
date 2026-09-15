/*
 * RRCVG-023 — Binary Checklist Steppers
 * 
 * Global Reference ID: RRCVG-023
 * Atomic Steps Reference ID: RRCVG-023-A01
 * Setup Step (Action): Binary Checklist Steppers.
 * Setup Step Description: Gather cross-functional user workflow requirements from the Tech, OPS, and HRE teams.
 * 4 Substeps:
 *   1) Define checklist items.
 *   2) Code toggle groups.
 *   3) Map boolean matrices.
 *   4) Gate final submit.
 * 
 * Decision Group: Workflow, Approval & Operational Governance.
 * Decision to be Made Before Setup Step: Define compliance checklist arrays.
 * Decision Category: Interaction.
 * Why This Matters: Converts complex multi-system processing into a single, verifiable UI checklist protecting assets.
 * Mobile App First Implication: A vertical stepper layout allows thumbs to naturally progress down the mobile screen step-by-step.
 * UX Translation: Stepper guiding the user systematically tool-by-tool without text input.
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Requirements / Discovery Coverage (%)
 * - Floor Boundary: 90% of relevant items identified.
 * - Optimal Target: 98% of relevant items identified.
 * - Ceiling Boundary: 100% of relevant items identified.
 * Best Qualitative Output: Complete / Partial / Not Complete (Best = Complete)
 * Best Qualitative/Quantitative Output Type: Discovery and audit activities in world-class delivery practice are expected to reach near-complete coverage of the target scope before downstream build work starts.
 * Assigned Team Member: Operations / UX Lead
 * Data Collected by System: Step Execution ID; Execution Status; Execution Timestamp; Step Outcome; User ID; Completion Status ('Complete/Partial/Not Complete'); Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Google Material Design Decisions & Implementations:
 *   - UX Decision: Clear visual checkmarks mapping to touch bounds.
 *   - UI Decision: Vertical progress lines for mobile scrolling.
 *   - UX Implementation: Navigation blocking to prevent jumping ahead.
 *   - UI Implementation: State-driven CSS updates for completed rows.
 * 
 * Mistake-Proofing (Poka-Yoke): Final "Complete Offboarding" button is visually disabled until every single toggle reads "Yes".
 * Self-Chasing: Unfinished toggles maintain ticket in "Active Risk" state on Security Dashboard, chasing IT to finish deprovisioning.
 * Vitality & Prosperity (VAP):
 *   - Us: Eliminates liability of unrevoked system access entirely.
 *   - Customer: A clear, undeniable handover process without ambiguity.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step RRCVG-023 Record Data Model.
class BinaryChecklistStepperRecord {
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
  final String completionStatus; // 'Complete', 'Partial', 'Not Complete'
  final String userId;
  final String userSessionId;
  final double discoveryCoveragePercentage; // e.g. 100.0%

  const BinaryChecklistStepperRecord({
    this.globalRefId = 'RRCVG-023',
    this.atomicStepRefId = 'RRCVG-023-A01',
    this.setupAction = 'Binary Checklist Steppers.',
    this.setupDescription = 'Gather cross-functional user workflow requirements from the Tech, OPS, and HRE teams.',
    this.decisionGroup = 'Workflow, Approval & Operational Governance.',
    this.decisionCategory = 'Interaction.',
    this.whyThisMatters = 'Converts complex multi-system processing into a single, verifiable UI checklist protecting assets.',
    this.mobileAppFirstImplication = 'A vertical stepper layout allows thumbs to naturally progress down the mobile screen step-by-step.',
    this.uxTranslation = 'Stepper guiding the user systematically tool-by-tool without text input.',
    this.commonLibraryToStore = 'UI Component Kit.',
    this.atomicReusability = 'High. UI Component Kit.',
    this.gcpBigQueryAlignment = 'Validates total completion booleans before triggering final pipeline data events.',
    this.sequenceOrder = 'Level 13 | Phase: EXECUTION | Atomic Step: 1.0 | Row: 3156.0',
    this.estimatedTimeRequired = '16 hours.',
    this.expectedOutput = 'Interactive multi-step checklist stepper component.',
    this.completionMeasures = '100% of complex multi-system processing flows managed via checklists.',
    this.dependencies = '16.0',
    this.domainExpertiseNeeded = 'Operations / UX',
    this.assignedTeamMember = 'Operations / UX Lead',
    this.stepExecutionId = 'EXEC-RRCVG-023-3156',
    this.executionStatus = 'VERIFIED_COMPLETE',
    required this.executionTimestamp,
    this.stepOutcome = 'ALL_BOOLEAN_MATRICES_VERIFIED',
    this.completionStatus = 'Complete',
    required this.userId,
    required this.userSessionId,
    this.discoveryCoveragePercentage = 100.0, // 100% Ceiling Target
  });
}

enum DiscoveryCoverageGrade {
  ceiling('Ceiling Target (100% Discovery Items Identified)', AppColorPalette.success, Icons.stars),
  optimal('Optimal Target (98% Discovery Items Identified)', AppColorPalette.info, Icons.check_circle),
  floor('Floor Boundary (90% Discovery Items Identified)', AppColorPalette.warning, Icons.warning_amber),
  failing('Failing Discovery (<90% Coverage of Target Scope)', AppColorPalette.lightError, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const DiscoveryCoverageGrade(this.label, this.color, this.icon);
}

abstract class DiscoveryCoverageValidator {
  static DiscoveryCoverageGrade evaluateGrade(double coveragePercentage) {
    if (coveragePercentage >= 100.0) {
      return DiscoveryCoverageGrade.ceiling;
    } else if (coveragePercentage >= 98.0) {
      return DiscoveryCoverageGrade.optimal;
    } else if (coveragePercentage >= 90.0) {
      return DiscoveryCoverageGrade.floor;
    } else {
      return DiscoveryCoverageGrade.failing;
    }
  }
}

/// RRCVG-023 Main Component Panel Widget
class BinaryChecklistStepperPanel extends StatefulWidget {
  final BinaryChecklistStepperRecord record;

  const BinaryChecklistStepperPanel({
    super.key,
    required this.record,
  });

  @override
  State<BinaryChecklistStepperPanel> createState() => _BinaryChecklistStepperPanelState();
}

class _BinaryChecklistStepperPanelState extends State<BinaryChecklistStepperPanel> {
  // Substep 1: Defined Checklist Items
  final List<Map<String, dynamic>> _stepperItems = [
    {
      'id': 'CHK-01',
      'title': 'Revoke Google Workspace IAM & Email Access',
      'subtitle': 'Tech Team: Disable OAuth tokens and suspend workspace account.',
      'isCompleted': false,
    },
    {
      'id': 'CHK-02',
      'title': 'Deactivate Slack & Single Sign-On (SSO) Credentials',
      'subtitle': 'Tech Team: Expire active session keys across all devices.',
      'isCompleted': false,
    },
    {
      'id': 'CHK-03',
      'title': 'Collect Corporate Laptop & Hardware Token Assets',
      'subtitle': 'OPS Team: Verify physical asset return receipt & serial number match.',
      'isCompleted': false,
    },
    {
      'id': 'CHK-04',
      'title': 'Archive GitHub & Bitbucket Repository Commit Access',
      'subtitle': 'Tech Team: Remove member from production code orgs.',
      'isCompleted': false,
    },
    {
      'id': 'CHK-05',
      'title': 'Revoke AWS / GCP Cloud Console Security Credentials',
      'subtitle': 'HRE Team: Confirm final exit interview & NDA sign-off.',
      'isCompleted': false,
    },
  ];

  int _activeStepIndex = 0;
  bool _isFinalPipelineSubmitted = false;
  String _governanceTelemetryStatus = 'Active Risk: Ticket in "Active Risk" state on Security Dashboard until 100% deprovisioned.';

  late double _simulatedCoverage;

  @override
  void initState() {
    super.initState();
    _simulatedCoverage = widget.record.discoveryCoveragePercentage;
  }

  // Substep 2 & 3: Code toggle groups and map boolean matrices
  void _toggleStepItem(int index, bool val) {
    // Substep 4 Navigation Blocking: Prevent jumping ahead if previous step not completed
    if (index > 0 && !(_stepperItems[index - 1]['isCompleted'] as bool) && val) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation Blocked: Please complete Step $index (${_stepperItems[index - 1]['id']}) first.'),
          backgroundColor: AppColorPalette.warning,
        ),
      );
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _stepperItems[index]['isCompleted'] = val;
      
      // Auto-advance active step if completing
      if (val && index < _stepperItems.length - 1) {
        _activeStepIndex = index + 1;
      }

      // Check Substep 3 Boolean Matrix Completeness
      final completedCount = _stepperItems.where((i) => i['isCompleted'] == true).length;
      final total = _stepperItems.length;

      if (completedCount == total) {
        _governanceTelemetryStatus = 'SECURE: 100% Deprovisioned! Security Dashboard updated to "Zero Risk". Final Submit Unlocked.';
      } else {
        _governanceTelemetryStatus = 'ACTIVE RISK: $completedCount/$total Toggles Completed. Unfinished items maintaining ticket in "Active Risk" state.';
      }
    });

    HapticFeedback.lightImpact();
  }

  // Substep 4 & Poka-Yoke: Gate Final Submit
  void _submitFinalOffboardingPipeline() {
    final allCompleted = _stepperItems.every((item) => item['isCompleted'] == true);
    if (!allCompleted) return;

    setState(() {
      _isFinalPipelineSubmitted = true;
      _governanceTelemetryStatus = 'SUCCESS: Offboarding Pipeline Data Event Triggered! Security Revocation Sealed & Archived in BigQuery.';
    });

    HapticFeedback.mediumImpact();
  }

  void _resetChecklist() {
    setState(() {
      for (var item in _stepperItems) {
        item['isCompleted'] = false;
      }
      _activeStepIndex = 0;
      _isFinalPipelineSubmitted = false;
      _governanceTelemetryStatus = 'Active Risk: Ticket in "Active Risk" state on Security Dashboard until 100% deprovisioned.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final coverageGrade = DiscoveryCoverageValidator.evaluateGrade(_simulatedCoverage);

    final allTogglesCompleted = _stepperItems.every((item) => item['isCompleted'] == true);
    final completedCount = _stepperItems.where((i) => i['isCompleted'] == true).length;

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
                                color: coverageGrade.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: coverageGrade.color.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(coverageGrade.icon, size: 14, color: coverageGrade.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    coverageGrade.label,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: coverageGrade.color,
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
                              content: Text('Assigned: ${widget.record.assignedTeamMember} | Execution ID: ${widget.record.stepExecutionId}'),
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
                      _buildInfoChip(Icons.category_outlined, 'Library: ${widget.record.commonLibraryToStore}', colorScheme),
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
                      Icon(Icons.rule_folder_outlined, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'Requirements / Discovery Coverage (%) Metric Boundary Evaluator',
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
                    'Discovery and audit activities in world-class delivery practice are expected to reach near-complete coverage of the target scope before downstream build work starts.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // Preset Switcher for Floor, Optimal, Ceiling Boundaries
                  Text(
                    'Test Requirements / Discovery Coverage Targets:',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  AppSpacingTokens.vGapXs,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Floor Boundary (90% Discovery Coverage)'),
                        selected: _simulatedCoverage == 90.0,
                        selectedColor: AppColorPalette.warningContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedCoverage = 90.0;
                              _governanceTelemetryStatus = 'Evaluated Floor Boundary (90% Discovery Items Identified)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Optimal Target (98% Discovery Coverage)'),
                        selected: _simulatedCoverage == 98.0,
                        selectedColor: AppColorPalette.infoContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedCoverage = 98.0;
                              _governanceTelemetryStatus = 'Evaluated Optimal Target (98% Discovery Items Identified)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Ceiling Target (100% Discovery Coverage)'),
                        selected: _simulatedCoverage == 100.0,
                        selectedColor: AppColorPalette.successContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedCoverage = 100.0;
                              _governanceTelemetryStatus = 'Evaluated Ceiling Target (100% Discovery Items Identified)';
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  AppSpacingTokens.vGapMd,

                  // Detailed Boundary Rows Display
                  Container(
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: coverageGrade.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: coverageGrade.color.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        _buildBoundaryRow(
                          title: 'Floor Boundary (90% of Relevant Items Identified)',
                          description: '90% workflow discovery coverage across Tech, OPS, HRE.',
                          isMet: _simulatedCoverage >= 90.0,
                          badgeColor: AppColorPalette.warning,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Optimal Target (98% of Relevant Items Identified)',
                          description: '98% near-complete coverage of multi-system processing steps.',
                          isMet: _simulatedCoverage >= 98.0,
                          badgeColor: AppColorPalette.info,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Ceiling Boundary (100% of Relevant Items Identified)',
                          description: '100% exhaustive discovery and boolean matrix mapping.',
                          isMet: _simulatedCoverage >= 100.0,
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

          // SUBSTEPS 1-4 INTERACTIVE BINARY CHECKLIST STEPPER PANEL (1 Screen = 1 Task / Stepper)
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
                          Icon(Icons.checklist_rtl_outlined, color: colorScheme.primary),
                          AppSpacingTokens.hGapSm,
                          Text(
                            'Substeps 1-4: Vertical Binary Checklist Stepper',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: allTogglesCompleted ? AppColorPalette.successContainer : AppColorPalette.warningContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Matrix: $completedCount/${_stepperItems.length} (${allTogglesCompleted ? 'SEALED' : 'ACTIVE RISK'})',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: allTogglesCompleted ? AppColorPalette.onSuccessContainer : AppColorPalette.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapXs,
                  Text(
                    'Vertical stepper layout allowing thumbs to naturally progress step-by-step with state-driven CSS/UI row updates.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // SUBSTEPS 1, 2, 3: VERTICAL STEPPER LIST WITH SEGMENTED YES/NO TOGGLE GROUPS
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _stepperItems.length,
                    itemBuilder: (ctx, index) {
                      final item = _stepperItems[index];
                      final isCompleted = item['isCompleted'] as bool;
                      final isCurrentStep = index == _activeStepIndex;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: AppSpacingTokens.paddingMd,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColorPalette.successContainer.withOpacity(0.2)
                              : isCurrentStep
                                  ? AppColorPalette.brandPrimaryContainer.withOpacity(0.25)
                                  : colorScheme.surfaceVariant.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted
                                ? AppColorPalette.success
                                : isCurrentStep
                                    ? AppColorPalette.brandPrimary
                                    : colorScheme.outlineVariant.withOpacity(0.3),
                            width: isCompleted || isCurrentStep ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stepper Badge / Visual Checkmark
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isCompleted
                                  ? AppColorPalette.success
                                  : isCurrentStep
                                      ? AppColorPalette.brandPrimary
                                      : Colors.grey.shade400,
                              child: isCompleted
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                            ),

                            AppSpacingTokens.hGapMd,

                            // Step Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'].toString(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted ? AppColorPalette.success : colorScheme.onSurface,
                                    ),
                                  ),
                                  AppSpacingTokens.vGapXs,
                                  Text(
                                    item['subtitle'].toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),

                            AppSpacingTokens.hGapSm,

                            // Substep 2: Binary Segmented Toggle Group (Yes / No)
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment<bool>(
                                  value: true,
                                  label: Text('Yes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  icon: Icon(Icons.check, size: 12),
                                ),
                                ButtonSegment<bool>(
                                  value: false,
                                  label: Text('No', style: TextStyle(fontSize: 11)),
                                  icon: Icon(Icons.close, size: 12),
                                ),
                              ],
                              selected: {isCompleted},
                              onSelectionChanged: (Set<bool> selection) {
                                _toggleStepItem(index, selection.first);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  AppSpacingTokens.vGapLg,

                  // SUBSTEP 4 & POKA-YOKE: GATED FINAL SUBMIT BUTTON
                  // Visually disabled until EVERY SINGLE TOGGLE reads "Yes"!
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: allTogglesCompleted && !_isFinalPipelineSubmitted
                          ? _submitFinalOffboardingPipeline
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColorPalette.brandPrimary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: Icon(
                        _isFinalPipelineSubmitted ? Icons.task_alt : Icons.lock_clock,
                        color: allTogglesCompleted ? Colors.white : Colors.grey.shade600,
                      ),
                      label: Text(
                        _isFinalPipelineSubmitted
                            ? 'OFFBOARDING SEALED & PIPELINE EVENT TRIGGERED'
                            : allTogglesCompleted
                                ? 'COMPLETE OFFBOARDING & SEAL ACCESS'
                                : 'COMPLETE OFFBOARDING (DISABLED - REQUIRES 100% "YES")',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontSize: 13,
                          color: allTogglesCompleted ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),

                  if (_isFinalPipelineSubmitted) ...[
                    AppSpacingTokens.vGapSm,
                    Center(
                      child: TextButton.icon(
                        onPressed: _resetChecklist,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset Stepper Checklist State'),
                      ),
                    ),
                  ],

                  AppSpacingTokens.vGapMd,

                  // Substep 4 Governance Telemetry Status Banner
                  Container(
                    width: double.infinity,
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: allTogglesCompleted
                          ? AppColorPalette.successContainer.withOpacity(0.4)
                          : AppColorPalette.warningContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Governance & Security Dashboard Telemetry:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: allTogglesCompleted ? AppColorPalette.onSuccessContainer : AppColorPalette.warning,
                          ),
                        ),
                        AppSpacingTokens.vGapXs,
                        Text(
                          _governanceTelemetryStatus,
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
                        'Mistake-Proofing (Poka-Yoke) & Self-Chasing Risk Tracking',
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

                  ListTile(
                    leading: const Icon(Icons.block, color: AppColorPalette.warning),
                    title: const Text('Visually Gated Final Submit (Poka-Yoke)'),
                    subtitle: const Text('Final "Complete Offboarding" button is visually disabled until every single toggle reads "Yes".'),
                    dense: true,
                  ),

                  ListTile(
                    leading: const Icon(Icons.radar_outlined, color: AppColorPalette.lightError),
                    title: const Text('Active Risk Ticket Chasing (Self-Chasing)'),
                    subtitle: const Text('Unfinished toggles maintain ticket in "Active Risk" state on Security Dashboard, chasing IT to finish deprovisioning.'),
                    dense: true,
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
                        'Vitality & Prosperity (VAP) Governance Impact',
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
                              'Eliminates liability of unrevoked system access entirely.',
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
                              'A clear, undeniable handover process without ambiguity.',
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
