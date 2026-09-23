/*
 * CPNCA-007-A03 — Grouped Data Interaction Steps
 * 
 * Setup Step (Action): Group complex, disorganized data elements into clearly simplified, digestible interaction steps.
 * Metric Name: General Implementation Task Compliance (Complete/Partial/Not Complete)
 * Quality Standard: Confirm the atomic step's output matches the parent Implementation Step's stated intent exactly, with no scope drift, before marking it complete.
 * Assigned Member: Pooja
 */

import 'package:flutter/material.dart';

class ExceptionStepItem {
  final String stepId;
  final String title;
  final String description;
  final Map<String, String> dataFields;
  final bool isCompleted;

  const ExceptionStepItem({
    required this.stepId,
    required this.title,
    required this.description,
    required this.dataFields,
    this.isCompleted = false,
  });
}

class GroupedDataInteractionStepsPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final String sequenceOrder;

  const GroupedDataInteractionStepsPanel({
    super.key,
    this.globalRefId = 'CPNCA-007',
    this.atomicStepRefId = 'CPNCA-007-A03',
    this.sequenceOrder = '8327',
  });

  @override
  State<GroupedDataInteractionStepsPanel> createState() =>
      _GroupedDataInteractionStepsPanelState();
}

class _GroupedDataInteractionStepsPanelState
    extends State<GroupedDataInteractionStepsPanel> {
  int _activeStepIndex = 0;
  final List<bool> _stepCompletion = [false, false, false];

  final List<ExceptionStepItem> _steps = const [
    ExceptionStepItem(
      stepId: 'STEP-01-INGRESS',
      title: 'Step 1: Payload Ingress Validation',
      description: 'Isolate corrupted packet headers and confirm inbound digest checksum.',
      dataFields: {
        'Packet ID': 'PKT-9041-A8',
        'Checksum SHA': '8e2b...41f0',
        'Source Node': 'KAFKA-CLUSTER-04',
      },
    ),
    ExceptionStepItem(
      stepId: 'STEP-02-LEDGER',
      title: 'Step 2: Ledger Delta Re-calculation',
      description: 'Reconcile points liabilities against dual-entry accounting journals.',
      dataFields: {
        'Ledger Entry': 'LDG-2026-0908',
        'Liability Delta': '-5,000 Points',
        'Balanced State': 'True (Validated)',
      },
    ),
    ExceptionStepItem(
      stepId: 'STEP-03-CONFIRM',
      title: 'Step 3: Operator State Authorization',
      description: 'Apply operator sign-off and dispatch state transition notification.',
      dataFields: {
        'Operator': 'POOJA-QA-LEAD',
        'Authorization Tier': 'TIER-3-CHIEF',
        'Action': 'RELEASE_STATE_LOCK',
      },
    ),
  ];

  void _nextStep() {
    if (_activeStepIndex < _steps.length - 1) {
      setState(() {
        _stepCompletion[_activeStepIndex] = true;
        _activeStepIndex++;
      });
    } else {
      setState(() {
        _stepCompletion[_activeStepIndex] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ All Grouped Exception Interaction Steps Verified & Completed!'),
          backgroundColor: GroupedDataInteractionStepsPanelTokens.success,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _prevStep() {
    if (_activeStepIndex > 0) {
      setState(() {
        _activeStepIndex--;
      });
    }
  }

  Map<String, dynamic> toExecutionLogJson() {
    final allComplete = _stepCompletion.every((element) => element);
    return {
      'stepExecutionId': 'EXEC-${widget.globalRefId}-2026',
      'executionStatus': allComplete ? 'COMPLETE' : 'IN_PROGRESS',
      'executionTimestamp': DateTime.now().toUtc().toIso8601String(),
      'stepOutcome': allComplete ? 'SUCCESS' : 'PENDING_ACTIONS',
      'userId': 'USER-AUTO-B14',
      'completionStatus': allComplete ? 'Complete' : 'Partial',
      'actionEventTimestamp': DateTime.now().toUtc().toIso8601String(),
      'userSessionId': 'SESSION-${widget.globalRefId}',
      'metadata': {
        'taskCode': widget.globalRefId,
        'atomicStepCode': widget.atomicStepRefId,
        'row': 139,
        'seq': widget.sequenceOrder,
        'assigned': 'Pooja',
        'metricName': 'General Implementation Task Compliance',
        'floor': 'Task functionally implemented, not yet peer-reviewed',
        'target': 'Task implemented, peer-reviewed, matches parent objective',
        'ceiling': 'N/A (gate, not a range)',
        'unit': 'Complete/Partial/Not Complete',
        'activeStep': _activeStepIndex + 1,
        'totalSteps': _steps.length,
        'isAllCompleted': allComplete,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allDone = _stepCompletion.every((element) => element);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final isExpanded = constraints.maxWidth >= 840;
        final contentPadding = isCompact
            ? GroupedDataInteractionStepsPanelTokens.paddingSm
            : (isExpanded ? GroupedDataInteractionStepsPanelTokens.paddingLg : GroupedDataInteractionStepsPanelTokens.paddingMd);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: allDone
                  ? GroupedDataInteractionStepsPanelTokens.success
                  : GroupedDataInteractionStepsPanelTokens.brandPrimary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: GroupedDataInteractionStepsPanelTokens.brandPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.layers_rounded,
                        color: GroupedDataInteractionStepsPanelTokens.brandPrimary,
                        size: 24,
                      ),
                    ),
                    GroupedDataInteractionStepsPanelTokens.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.globalRefId} / ${widget.atomicStepRefId}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: GroupedDataInteractionStepsPanelTokens.brandPrimary,
                              fontSize: isExpanded ? 16 : 14,
                            ),
                          ),
                          Text(
                            'Grouped Data Interaction Steps (Seq: ${widget.sequenceOrder})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: isCompact ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: allDone
                            ? GroupedDataInteractionStepsPanelTokens.successContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        allDone ? 'Complete (3/3)' : 'Step ${_activeStepIndex + 1}/3',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: allDone
                              ? GroupedDataInteractionStepsPanelTokens.onSuccessContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                GroupedDataInteractionStepsPanelTokens.vGapMd,

                // Progress Indicator
                LinearProgressIndicator(
                  value: (_activeStepIndex + (_stepCompletion[_activeStepIndex] ? 1 : 0.5)) / _steps.length,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: GroupedDataInteractionStepsPanelTokens.brandPrimary,
                ),
                GroupedDataInteractionStepsPanelTokens.vGapMd,

                // Step Content Card
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey<int>(_activeStepIndex),
                    padding: GroupedDataInteractionStepsPanelTokens.paddingMd,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _steps[_activeStepIndex].title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: GroupedDataInteractionStepsPanelTokens.brandPrimary,
                              ),
                            ),
                            Icon(
                              _stepCompletion[_activeStepIndex]
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: _stepCompletion[_activeStepIndex]
                                  ? GroupedDataInteractionStepsPanelTokens.success
                                  : Colors.grey,
                              size: 18,
                            ),
                          ],
                        ),
                        GroupedDataInteractionStepsPanelTokens.vGapXs,
                        Text(
                          _steps[_activeStepIndex].description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        GroupedDataInteractionStepsPanelTokens.vGapMd,
                        const Text(
                          'Digestible Data Fields (Max 3-5 fields per card):',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        GroupedDataInteractionStepsPanelTokens.vGapXs,
                        ..._steps[_activeStepIndex].dataFields.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                Text(entry.value,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace')),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                GroupedDataInteractionStepsPanelTokens.vGapMd,

                // Navigation Controls (Min 48x48dp interactive touch target)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: OutlinedButton.icon(
                        onPressed: _activeStepIndex > 0 ? _prevStep : null,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Previous'),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: FilledButton.icon(
                        onPressed: _nextStep,
                        icon: Icon(allDone ? Icons.done_all_rounded : Icons.arrow_forward_rounded),
                        label: Text(allDone ? 'Re-confirm Step' : (_activeStepIndex == _steps.length - 1 ? 'Complete All' : 'Next Step')),
                        style: FilledButton.styleFrom(
                          backgroundColor: GroupedDataInteractionStepsPanelTokens.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// File-Local Standalone Design Tokens & Constants
// ============================================================================
abstract final class GroupedDataInteractionStepsPanelTokens {
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
            child: GroupedDataInteractionStepsPanel(),
          ),
        ),
      ),
    ),
  );
}
