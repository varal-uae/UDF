/*
 * FIEVR-008 — Enforce Predictive Word-of-Mouth Selection Dropdowns
 * 
 * Global Reference ID: FIEVR-008
 * Atomic Steps Reference ID: FIEVR-008-A01
 * Setup Step (Action): Enforce Predictive Word-of-Mouth Selection Dropdowns.
 * Setup Step Description: Extract user experience requirements regarding predictive source choices from Marketing teams.
 * 4 Substeps:
 *   1) Input the approved master directory array of target nurseries into front-end models.
 *   2) Design an autocomplete predictive-search selection field inside registration layers.
 *   3) Configure backend form validation filters to block free-text strings on source metrics.
 *   4) Set up an event pipeline linking choice data directly to the attribution matrix.
 * 
 * Decision Group: Onboarding Optimization Strategy.
 * Decision to be Made Before Setup Step: Partner revenue share distribution ratios policy confirmation.
 * Decision Category: Front-End Interaction and Data Architecture.
 * Why This Matters: Prevents underreporting or misclassification of organic local growth trends, capturing offline word-of-mouth value accurately.
 * Mobile App First Implication: Replaces error-prone manual typing blocks with a fluid predictive tap interface, cutting keyboard exhaustion on small screens.
 * UX Translation: A clean, responsive list view matching standard design system overlay criteria.
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Metric Name: Process Execution Quality (%)
 * - Floor Boundary (85%): 85% of the step executed to defined standard.
 * - Optimal Target (95%): 95% of the step executed to defined standard.
 * - Ceiling Boundary (100%): 100% of the step executed to defined standard.
 * Best Qualitative Output: Complete / Partial / Not Complete (Best = Complete)
 * Best Qualitative/Quantitative Output Type: General execution steps in a mature delivery pipeline are expected to meet the defined standard of work within this completion range before sign-off.
 * Assigned Team Member: UX Interface Engineering Lead / Onboarding Growth Specialist
 * Data Collected by System: Step Execution ID; Execution Status; Execution Timestamp; Step Outcome; User ID; Completion Status ('Complete/Partial/Not Complete'); Action/Event Timestamp; User/Session ID
 * 
 * Mobile-First & Responsive UX/UI Google Material Design Decisions & Implementations:
 *   - UX Decision: The selection overlay leverages smart autocomplete patterns to minimize user interaction overhead.
 *   - UI Decision: UI parameters configure standard, native Material 3 Select Components attributes.
 *   - UX Implementation: Redirection layouts suppress heavy multi-select lists to protect small screen real estate.
 *   - UI Implementation: Text presentation utilizes uniform visual hierarchy typography parameters.
 * 
 * Mistake-Proofing (Poka-Yoke): Onboarding continuation triggers physically freeze and throw validation faults if the channel parameter is null.
 * Self-Chasing: Action: If the generic placeholder label "Other" is selected across more than 20% of conversions, the system auto-alerts team members to update options.
 * Vitality & Prosperity (VAP):
 *   - Us: Secures full line-of-sight across organic local growth channels, maximizing budget scaling confidence.
 *   - Customer: Guarantees that parents who act as community advocates receive accurate loyalty perks seamlessly.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Step FIEVR-008 Record Data Model.
class PredictiveDropdownSelectionRecord {
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
  final double processExecutionQuality; // e.g. 100.0%

  const PredictiveDropdownSelectionRecord({
    this.globalRefId = 'FIEVR-008',
    this.atomicStepRefId = 'FIEVR-008-A01',
    this.setupAction = 'Enforce Predictive Word-of-Mouth Selection Dropdowns.',
    this.setupDescription = 'Extract user experience requirements regarding predictive source choices from Marketing teams.',
    this.decisionGroup = 'Onboarding Optimization Strategy.',
    this.decisionCategory = 'Front-End Interaction and Data Architecture.',
    this.whyThisMatters = 'Prevents underreporting or misclassification of organic local growth trends, capturing offline word-of-mouth value accurately.',
    this.mobileAppFirstImplication = 'Replaces error-prone manual typing blocks with a fluid predictive tap interface, cutting keyboard exhaustion on small screens.',
    this.uxTranslation = 'A clean, responsive list view matching standard design system overlay criteria.',
    this.commonLibraryToStore = 'UI Forms Library.',
    this.atomicReusability = 'The predictive selection list component is fully reusable across event subscription form modules.',
    this.gcpBigQueryAlignment = 'Valid forms stream data directly into attribution mapping datasets via secure backend integrations.',
    this.sequenceOrder = 'Level 13 | Phase: EXECUTION | Atomic Step: 1.0 | Row: 3145.0',
    this.estimatedTimeRequired = '1 Week.',
    this.expectedOutput = 'A validated predictive dropdown layout schema and interface configuration scripts.',
    this.completionMeasures = '100% of recorded organic account profiles contain a validated acquisition origin code.',
    this.dependencies = 'Serial Number 5 (Configure JLT Nursery Geofence Coordinates Setup Step).',
    this.domainExpertiseNeeded = 'User Experience Interface Engineering',
    this.assignedTeamMember = 'UX Interface Engineering Lead / Onboarding Growth Specialist',
    this.stepExecutionId = 'EXEC-FIEVR-008-3145',
    this.executionStatus = 'VERIFIED_OPTIMAL',
    required this.executionTimestamp,
    this.stepOutcome = 'ATTRIBUTION_MATRIX_STREAM_ACTIVE',
    this.completionStatus = 'Complete',
    required this.userId,
    required this.userSessionId,
    this.processExecutionQuality = 100.0, // 100% Ceiling Target
  });
}

enum ExecutionQualityGrade {
  ceiling('Ceiling Target (100% Executed to Defined Standard)', AppColorPalette.success, Icons.stars),
  optimal('Optimal Target (95% Executed to Defined Standard)', AppColorPalette.info, Icons.check_circle),
  floor('Floor Boundary (85% Executed to Defined Standard)', AppColorPalette.warning, Icons.warning_amber),
  failing('Failing Quality (<85% Delivery Pipeline Standard)', AppColorPalette.lightError, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const ExecutionQualityGrade(this.label, this.color, this.icon);
}

abstract class ProcessExecutionQualityValidator {
  static ExecutionQualityGrade evaluateGrade(double qualityPercentage) {
    if (qualityPercentage >= 100.0) {
      return ExecutionQualityGrade.ceiling;
    } else if (qualityPercentage >= 95.0) {
      return ExecutionQualityGrade.optimal;
    } else if (qualityPercentage >= 85.0) {
      return ExecutionQualityGrade.floor;
    } else {
      return ExecutionQualityGrade.failing;
    }
  }
}

/// FIEVR-008 Main Component Panel Widget
class PredictiveDropdownSelectionPanel extends StatefulWidget {
  final PredictiveDropdownSelectionRecord record;

  const PredictiveDropdownSelectionPanel({
    super.key,
    required this.record,
  });

  @override
  State<PredictiveDropdownSelectionPanel> createState() => _PredictiveDropdownSelectionPanelState();
}

class _PredictiveDropdownSelectionPanelState extends State<PredictiveDropdownSelectionPanel> {
  final TextEditingController _autocompleteSearchController = TextEditingController();
  
  // Substep 1: Approved Master Directory Array of Target Nurseries
  final List<Map<String, String>> _targetNurseryDirectory = [
    {
      'code': 'ATTRIB-JLT-001',
      'name': 'JLT Sunshine Nursery - Cluster V',
      'region': 'Jumeirah Lakes Towers',
      'category': 'Verified Community Partner',
    },
    {
      'code': 'ATTRIB-DMK-002',
      'name': 'Dubai Marina Kids Care',
      'region': 'Dubai Marina',
      'category': 'Verified Community Partner',
    },
    {
      'code': 'ATTRIB-PJL-003',
      'name': 'Palm Jumeirah Learning Hub',
      'region': 'Palm Jumeirah',
      'category': 'Verified Community Partner',
    },
    {
      'code': 'ATTRIB-BBM-004',
      'name': 'Business Bay Montessori',
      'region': 'Business Bay',
      'category': 'Verified Community Partner',
    },
    {
      'code': 'ATTRIB-DHA-005',
      'name': 'Dubai Hills Academy',
      'region': 'Dubai Hills Estate',
      'category': 'Verified Community Partner',
    },
    {
      'code': 'ATTRIB-OTH-999',
      'name': 'Other / Direct Word of Mouth',
      'region': 'General Organic',
      'category': 'Generic Placeholder (Monitored <20%)',
    },
  ];

  Map<String, String>? _selectedNursery;
  List<Map<String, String>> _filteredCandidates = [];
  bool _isOverlayOpen = false;

  // Substep 3 & Poka-Yoke: Block loose free-text strings
  bool _pokaYokeFreeTextBlocked = true;
  String _validationFaultMessage = '';

  // Substep 4 & Self-Chasing: Attribution Event Pipeline & "Other" Alert Monitoring
  int _totalConversions = 25;
  int _otherSelections = 3; // 3/25 = 12% (<20% limit)
  bool _selfChasingOtherAlertActive = false;
  String _pipelineEventStatus = 'Event Pipeline Active: Streamed 25 origin codes to BigQuery attribution matrix.';

  late double _simulatedExecutionQuality;

  @override
  void initState() {
    super.initState();
    _simulatedExecutionQuality = widget.record.processExecutionQuality;
    _filteredCandidates = List.from(_targetNurseryDirectory);
  }

  @override
  void dispose() {
    _autocompleteSearchController.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _isOverlayOpen = true;
      if (query.isEmpty) {
        _filteredCandidates = List.from(_targetNurseryDirectory);
      } else {
        _filteredCandidates = _targetNurseryDirectory.where((item) {
          final name = item['name']!.toLowerCase();
          final region = item['region']!.toLowerCase();
          final search = query.toLowerCase();
          return name.contains(search) || region.contains(search);
        }).toList();
      }
    });
  }

  void _selectNurseryOption(Map<String, String> candidate) {
    setState(() {
      _selectedNursery = candidate;
      _autocompleteSearchController.text = candidate['name']!;
      _isOverlayOpen = false;
      _validationFaultMessage = '';

      // Check Self-Chasing rule: If "Other" chosen, check ratio
      if (candidate['code'] == 'ATTRIB-OTH-999') {
        _otherSelections++;
      }
      _totalConversions++;

      final otherRatio = _otherSelections / _totalConversions;
      if (otherRatio > 0.20) {
        _selfChasingOtherAlertActive = true;
        _pipelineEventStatus = 'SELF-CHASING ALERT: "Other" label selected in ${(otherRatio * 100).toStringAsFixed(1)}% of conversions (>20% threshold)! System auto-alerted marketing team to update directory options.';
      } else {
        _selfChasingOtherAlertActive = false;
        _pipelineEventStatus = 'SUCCESS: Streamed origin code ${candidate['code']} to BigQuery attribution matrix. "Other" ratio: ${(otherRatio * 100).toStringAsFixed(1)}% (<20%).';
      }
    });
  }

  // Poka-Yoke: Onboarding Continuation Trigger Validation Check
  void _attemptOnboardingContinuation() {
    if (_selectedNursery == null || (_pokaYokeFreeTextBlocked && !_targetNurseryDirectory.contains(_selectedNursery))) {
      setState(() {
        _validationFaultMessage = 'POKA-YOKE FAULT: Free-text entries blocked! You must tap a validated nursery choice from the predictive directory list.';
      });
    } else {
      setState(() {
        _validationFaultMessage = 'SUCCESS: Onboarding continuation validated! Origin code ${_selectedNursery!['code']} confirmed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final qualityGrade = ProcessExecutionQualityValidator.evaluateGrade(_simulatedExecutionQuality);

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
                                color: qualityGrade.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: qualityGrade.color.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(qualityGrade.icon, size: 14, color: qualityGrade.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    qualityGrade.label,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: qualityGrade.color,
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
                              content: Text('Assigned: ${widget.record.assignedTeamMember} | ID: ${widget.record.stepExecutionId}'),
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
                      Icon(Icons.verified_user_outlined, color: AppColorPalette.brandPrimary),
                      AppSpacingTokens.hGapSm,
                      Expanded(
                        child: Text(
                          'Process Execution Quality (%) Metric Boundary Evaluator',
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
                    'General execution steps in a mature delivery pipeline are expected to meet the defined standard of work within this completion range before sign-off.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // Preset Switcher for Floor, Optimal, Ceiling Boundaries
                  Text(
                    'Test Process Execution Quality Targets:',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  AppSpacingTokens.vGapXs,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Floor Boundary (85% Executed Standard)'),
                        selected: _simulatedExecutionQuality == 85.0,
                        selectedColor: AppColorPalette.warningContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedExecutionQuality = 85.0;
                              _pipelineEventStatus = 'Evaluated Floor Boundary (85% Execution Standard Met)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Optimal Target (95% Executed Standard)'),
                        selected: _simulatedExecutionQuality == 95.0,
                        selectedColor: AppColorPalette.infoContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedExecutionQuality = 95.0;
                              _pipelineEventStatus = 'Evaluated Optimal Target (95% Execution Standard Met)';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Ceiling Target (100% Executed Standard)'),
                        selected: _simulatedExecutionQuality == 100.0,
                        selectedColor: AppColorPalette.successContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _simulatedExecutionQuality = 100.0;
                              _pipelineEventStatus = 'Evaluated Ceiling Target (100% Execution Standard Met)';
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
                      color: qualityGrade.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: qualityGrade.color.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        _buildBoundaryRow(
                          title: 'Floor Boundary (85% of Step Executed to Standard)',
                          description: '85% delivery quality baseline across onboarding models.',
                          isMet: _simulatedExecutionQuality >= 85.0,
                          badgeColor: AppColorPalette.warning,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Optimal Target (95% of Step Executed to Standard)',
                          description: '95% execution accuracy with 100% validated organic origin codes.',
                          isMet: _simulatedExecutionQuality >= 95.0,
                          badgeColor: AppColorPalette.info,
                        ),
                        const Divider(height: 16),
                        _buildBoundaryRow(
                          title: 'Ceiling Boundary (100% of Step Executed to Standard)',
                          description: '100% flawless execution with zero unvalidated free-text leaks.',
                          isMet: _simulatedExecutionQuality >= 100.0,
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

          // SUBSTEPS 1-4 PREDICTIVE WORD-OF-MOUTH SELECTION DROPDOWN SANDBOX
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
                          Icon(Icons.touch_app_outlined, color: colorScheme.primary),
                          AppSpacingTokens.hGapSm,
                          Text(
                            'Substeps 1-4: Predictive Autocomplete Onboarding Field',
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
                        child: const Text(
                          'Attribution Data Stream Active',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColorPalette.onSuccessContainer),
                        ),
                      ),
                    ],
                  ),
                  AppSpacingTokens.vGapXs,
                  Text(
                    'Replaces error-prone manual typing blocks with a fluid predictive tap interface, capturing offline word-of-mouth value.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AppSpacingTokens.vGapMd,
                  Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  AppSpacingTokens.vGapSm,

                  // SUBSTEP 2: Autocomplete Predictive Search Input Field (MD3 Select Component)
                  Text(
                    'Substep 2: Where did you hear about us? (Predictive Search):',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  AppSpacingTokens.vGapXs,

                  TextField(
                    controller: _autocompleteSearchController,
                    decoration: InputDecoration(
                      hintText: 'Type nursery name or region (e.g. JLT, Marina)...',
                      prefixIcon: const Icon(Icons.search, color: AppColorPalette.brandPrimary),
                      suffixIcon: _selectedNursery != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedNursery = null;
                                  _autocompleteSearchController.clear();
                                  _onSearchQueryChanged('');
                                });
                              },
                            )
                          : const Icon(Icons.arrow_drop_down),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColorPalette.brandPrimary, width: 2),
                      ),
                    ),
                    onChanged: _onSearchQueryChanged,
                    onTap: () => setState(() => _isOverlayOpen = true),
                  ),

                  // SUBSTEP 2: Predictive Candidate Selection Overlay List View
                  if (_isOverlayOpen) ...[
                    AppSpacingTokens.vGapXs,
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColorPalette.brandPrimary.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _filteredCandidates.length,
                        separatorBuilder: (ctx, idx) => Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.3)),
                        itemBuilder: (ctx, idx) {
                          final candidate = _filteredCandidates[idx];
                          final isSelected = _selectedNursery?['code'] == candidate['code'];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_city_outlined,
                              size: 18,
                              color: isSelected ? AppColorPalette.brandPrimary : colorScheme.onSurfaceVariant,
                            ),
                            title: Text(
                              candidate['name']!,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColorPalette.brandPrimary : colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Region: ${candidate['region']} | Code: ${candidate['code']}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check, color: AppColorPalette.brandPrimary, size: 18)
                                : null,
                            onTap: () => _selectNurseryOption(candidate),
                          );
                        },
                      ),
                    ),
                  ],

                  AppSpacingTokens.vGapMd,

                  // Substep 3 Poka-Yoke Checkpoint Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _attemptOnboardingContinuation,
                          icon: const Icon(Icons.touch_app, size: 16),
                          label: const Text('Test Single-Tap Onboarding Continuation'),
                        ),
                      ),
                    ],
                  ),

                  if (_validationFaultMessage.isNotEmpty) ...[
                    AppSpacingTokens.vGapSm,
                    Container(
                      padding: AppSpacingTokens.paddingSm,
                      decoration: BoxDecoration(
                        color: _validationFaultMessage.contains('POKA-YOKE')
                            ? AppColorPalette.lightError.withOpacity(0.15)
                            : AppColorPalette.successContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _validationFaultMessage,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _validationFaultMessage.contains('POKA-YOKE')
                              ? AppColorPalette.lightError
                              : AppColorPalette.onSuccessContainer,
                        ),
                      ),
                    ),
                  ],

                  AppSpacingTokens.vGapMd,

                  // Substep 4 GCP BigQuery Attribution Event Pipeline Status
                  Container(
                    width: double.infinity,
                    padding: AppSpacingTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: _selfChasingOtherAlertActive
                          ? AppColorPalette.warningContainer.withOpacity(0.5)
                          : AppColorPalette.brandPrimaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selfChasingOtherAlertActive ? Icons.warning_amber_rounded : Icons.hub,
                              color: _selfChasingOtherAlertActive ? AppColorPalette.warning : AppColorPalette.brandPrimary,
                              size: 18,
                            ),
                            AppSpacingTokens.hGapSm,
                            Text(
                              'Substep 4 Attribution Pipeline Status:',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorPalette.onBrandPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        AppSpacingTokens.vGapXs,
                        Text(
                          _pipelineEventStatus,
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
                        'Mistake-Proofing (Poka-Yoke) & Self-Chasing Alert Engine',
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
                    title: const Text('Free-Text Input Block (Poka-Yoke)'),
                    subtitle: const Text('Onboarding continuation triggers physically freeze and throw validation faults if loose free-text is entered.'),
                    value: _pokaYokeFreeTextBlocked,
                    activeColor: AppColorPalette.success,
                    onChanged: (val) => setState(() => _pokaYokeFreeTextBlocked = val),
                  ),

                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: AppColorPalette.warning),
                    title: const Text('"Other" Option Threshold Monitoring (Self-Chasing)'),
                    subtitle: const Text('If "Other" option is selected in >20% of conversions, the system auto-alerts team members to update options.'),
                    trailing: Text(
                      'Current: ${((_otherSelections / _totalConversions) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
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
                        'Vitality & Prosperity (VAP) Business & Parent Impact',
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
                              'Secures full line-of-sight across organic local growth channels, maximizing budget scaling confidence.',
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
                              'Guarantees that parents who act as community advocates receive accurate loyalty perks seamlessly.',
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
