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
      padding: MicroTaskOutsourcingTemplatePanelTokens.paddingLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MicroTaskOutsourcingTemplatePanelTokens.lightOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(MicroTaskOutsourcingTemplatePanelTokens.sm),
                decoration: BoxDecoration(
                  color: MicroTaskOutsourcingTemplatePanelTokens.brandPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: MicroTaskOutsourcingTemplatePanelTokens.brandPrimary,
                  size: 24,
                ),
              ),
              MicroTaskOutsourcingTemplatePanelTokens.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.atomicStepRefId} (Seq: ${widget.sequenceOrder})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: MicroTaskOutsourcingTemplatePanelTokens.brandPrimary,
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
                  color: MicroTaskOutsourcingTemplatePanelTokens.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'MTOI Ready',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MicroTaskOutsourcingTemplatePanelTokens.onSuccessContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          MicroTaskOutsourcingTemplatePanelTokens.vGapMd,
          // MTOI Template Preview Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: MicroTaskOutsourcingTemplatePanelTokens.paddingLg,
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
                          Icon(Icons.crop, size: 36, color: MicroTaskOutsourcingTemplatePanelTokens.brandPrimary),
                          SizedBox(height: 4),
                          Text('Cropped Snippet Image Slot (TRN / Invoice)', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  MicroTaskOutsourcingTemplatePanelTokens.vGapMd,
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter numerical digits strictly...',
                      labelText: 'Digitized Value',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                  MicroTaskOutsourcingTemplatePanelTokens.vGapMd,
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
          MicroTaskOutsourcingTemplatePanelTokens.vGapMd,
          Container(
            padding: MicroTaskOutsourcingTemplatePanelTokens.paddingMd,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Template Version Control Metadata:', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                MicroTaskOutsourcingTemplatePanelTokens.vGapXs,
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

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class MicroTaskOutsourcingTemplatePanelTokens {
  // Brand & Semantic Color Tokens
  static const Color brandPrimary = Color(0xFF2E86C1);
  static const Color onBrandPrimary = Color(0xFFFFFFFF);
  static const Color brandPrimaryContainer = Color(0xFFD6EAF8);
  static const Color onBrandPrimaryContainer = Color(0xFF1B4F72);
  static const Color brandPrimaryHoverOverlay = Color(0x1F2E86C1);
  static const Color brandPrimaryActiveOverlay = Color(0x3D2E86C1);

  static const Color primary = brandPrimary;
  static const Color primarySeed = Color(0xFF6750A4);
  static const Color secondarySeed = Color(0xFF625B71);
  static const Color tertiarySeed = Color(0xFF7D5260);
  static const Color neutralSeed = Color(0xFF605D62);

  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD0F8CE);
  static const Color onSuccessContainer = Color(0xFF002204);

  static const Color warning = Color(0xFFED6C02);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDCC6);
  static const Color onWarningContainer = Color(0xFF341100);

  static const Color info = Color(0xFF0288D1);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCBE6FF);
  static const Color onInfoContainer = Color(0xFF001E30);

  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF21005D);

  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF1D192B);

  static const Color lightTertiary = Color(0xFF7D5260);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color lightOnTertiaryContainer = Color(0xFF31111D);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF9DEDC);
  static const Color lightOnErrorContainer = Color(0xFF410E0B);

  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightSurface = Color(0xFFFEF7FF);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  static const Color neutralLight = Color(0xFFF5F5F5);
  static const Color neutralDark = Color(0xFF212121);

  // Elevation Tokens
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;

  // Spacing & Layout Tokens (4dp Metric Grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double mdSm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  static const Widget vGapXs = SizedBox(height: xs);
  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget vGapXl = SizedBox(height: xl);

  static const Widget hGapXs = SizedBox(width: xs);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGapMd = SizedBox(width: md);
  static const Widget hGapLg = SizedBox(width: lg);
  static const Widget hGapXl = SizedBox(width: xl);
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: MicroTaskOutsourcingTemplatePanel(),
          ),
        ),
      ),
    ),
  );
}
