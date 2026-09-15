/*
 * ERMWD-024-A01 — Micro Task Outsourcing Template Panel
 * 
 * Setup Step (Action): Open the Compose UI template file for the Micro Task Outsourcing Interface (MTOI).
 * Metric Name: Environment / Asset Access Readiness (Target: Path version-controlled & documented, Unit: Complete)
 * Quality Standard: Source files and directories referenced under version control and discoverable without tribal knowledge.
 * Telemetry: Template Name; Template Version; Template Type; Template Configuration; Object Type; Object Location/Path; Open Status; Timestamp; File Handle ID; Completion Status ('Complete'); Action/Event Timestamp; User/Session ID
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

class MicroTaskOutsourcingTemplatePanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const MicroTaskOutsourcingTemplatePanel({
    super.key,
    this.globalRefId = 'ERMWD-024',
    this.atomicStepRefId = 'ERMWD-024-A01',
    this.sequenceOrder = '13986',
  });

  @override
  State<MicroTaskOutsourcingTemplatePanel> createState() =>
      _MicroTaskOutsourcingTemplatePanelState();
}

class _MicroTaskOutsourcingTemplatePanelState
    extends State<MicroTaskOutsourcingTemplatePanel> {
  final String _templateName = 'MicroTaskOutsourcingCardTemplate';
  final String _templateVersion = 'v1.4.2-mtoi';
  final String _templatePath = 'lib/core/ui/templates/mtoi_card_template_v1.dart';
  final String _fileHandleId = 'FH-MTOI-2026-0909';
  final String _userSessionId = 'POOJA-ERMWD-024-A01';
  final String _completionStatus = 'Complete';

  Map<String, dynamic> getTelemetryData() {
    return {
      'stepExecutionId': 'EXEC-ERMWD-024-A01-2026',
      'templateName': _templateName,
      'templateVersion': _templateVersion,
      'templateType': 'Reflex Gig-Worker Micro-Task Layout',
      'objectLocationPath': _templatePath,
      'fileHandleId': _fileHandleId,
      'openStatus': 'OPEN_VERSION_CONTROLLED',
      'readinessStandard': '100% Discoverable & Documented in Git',
      'completionStatus': _completionStatus,
      'actionEventTimestamp': DateTime.now().toIso8601String(),
      'userSessionId': _userSessionId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: AppSpacingTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorPalette.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacingTokens.sm),
                decoration: BoxDecoration(
                  color: AppColorPalette.brandPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: AppColorPalette.brandPrimary,
                  size: 24,
                ),
              ),
              AppSpacingTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColorPalette.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Micro Task Outsourcing UI Template',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorPalette.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'MTOI Ready',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColorPalette.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacingTokens.vGapMd,
          // MTOI Template Preview Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: AppSpacingTokens.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.crop, size: 36, color: AppColorPalette.brandPrimary),
                          SizedBox(height: 4),
                          Text('Cropped Snippet Image Slot (TRN / Invoice)', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  AppSpacingTokens.vGapMd,
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter numerical digits strictly...',
                      labelText: 'Digitized Value',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                  AppSpacingTokens.vGapMd,
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('MTOI Reflex submission recorded in 1.4s')),
                        );
                      },
                      child: const Text('SUBMIT DATA (REFLEX ACTION)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacingTokens.vGapMd,
          Container(
            padding: AppSpacingTokens.paddingMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Template Version Control Metadata:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                AppSpacingTokens.vGapXs,
                Text('Path: $_templatePath', style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
                Text('Version: $_templateVersion | Handle: $_fileHandleId', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
