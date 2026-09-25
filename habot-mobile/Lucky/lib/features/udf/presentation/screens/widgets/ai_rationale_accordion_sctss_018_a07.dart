// SCTSS-018-A07 — AI Rationale Accordion (Trust Layer) for Explainable AI outputs.
// Implements a collapsible panel with smooth expand/collapse animations, source citations,
// low-confidence auto-expand with pulse warning, and Poka-Yoke approve-button gating.

import 'package:flutter/material.dart';

/// Mock data representing grounding metadata from Vector Search / GCP BigQuery alignment.
class AiRationaleMockData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final double confidenceScore;
  final String rationaleText;
  final List<String> sourceCitations;

  const AiRationaleMockData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.confidenceScore,
    required this.rationaleText,
    required this.sourceCitations,
  });
}

const AiRationaleMockData kMockRationale = AiRationaleMockData(
  stepExecutionId: 'EXEC-99382-XAI',
  executionStatus: 'COMPLETED',
  executionTimestamp: null as dynamic, // Replaced below in factory
  stepOutcome: 'Generated code snippet based on company policy HRE-SP-06042026.',
  userId: 'USR-001-UDF',
  confidenceScore: 0.62,
  rationaleText:
      'The AI generated this specific decision by cross-referencing the uploaded company policy documents '
      'with the historical vector embeddings stored in BigQuery. The semantic similarity score exceeded '
      'the minimum threshold, but remains below optimal confidence due to missing context in section 4.2.',
  sourceCitations: [
    'Company Policy Doc: HRE-SP-06042026 (Section 3.1)',
    'Vector Search Result ID: VEC-8821-MATCH',
    'BigQuery Table: udf_ai_grounding.metadata_logs',
  ],
);

/// Controller to manage the Poka-Yoke state (Approve button locked until expanded).
class AiRationaleController extends ChangeNotifier {
  bool _hasBeenExpanded = false;
  bool get hasBeenExpanded => _hasBeenExpanded;

  void markAsExpanded() {
    if (!_hasBeenExpanded) {
      _hasBeenExpanded = true;
      notifyListeners();
    }
  }

  void reset() {
    _hasBeenExpanded = false;
    notifyListeners();
  }
}

/// Main Accordion Widget for AI Rationale Trust Layer.
class AiRationaleAccordion extends StatefulWidget {
  final AiRationaleMockData data;
  final AiRationaleController controller;
  final VoidCallback? onApproved;

  const AiRationaleAccordion({
    super.key,
    required this.data,
    required this.controller,
    this.onApproved,
  });

  @override
  State<AiRationaleAccordion> createState() => _AiRationaleAccordionState();
}

class _AiRationaleAccordionState extends State<AiRationaleAccordion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _expandAnimation;
  late final Animation<Color?> _pulseAnimation;
  bool _isExpanded = false;

  bool get _isLowConfidence => widget.data.confidenceScore < 0.8;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _pulseAnimation = ColorTween(
      begin: Colors.amber.shade100,
      end: Colors.amber.shade600,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    // Self-Chasing: Auto-expand if AI confidence is low
    if (_isLowConfidence) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toggleExpand(forceExpand: true);
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpand({bool forceExpand = false}) {
    setState(() {
      _isExpanded = forceExpand ? true : !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
        widget.controller.markAsExpanded();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final borderColor = _isLowConfidence && _isExpanded
            ? _pulseAnimation.value ?? Colors.amber
            : theme.colorScheme.outlineVariant;

        return Container(
          decoration: BoxDecoration(
            color: _isLowConfidence && _isExpanded
                ? borderColor?.withOpacity(0.1)
                : theme.colorScheme.surfaceContainerLowest,
            border: Border.all(color: borderColor ?? Colors.transparent, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(theme),
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: _buildContent(theme),
              ),
              _buildApprovalGate(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return InkWell(
      onTap: () => _toggleExpand(),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              Icons.psychology_outlined,
              color: _isLowConfidence ? Colors.amber.shade700 : theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'AI Rationale & Trust Layer',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isLowConfidence ? Colors.amber.shade900 : null,
                ),
              ),
            ),
            if (_isLowConfidence) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Low Confidence (${(widget.data.confidenceScore * 100).toStringAsFixed(0)}%)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
              child: Icon(
                Icons.expand_more,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payload validation fallback indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why this decision was made:',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.data.rationaleText,
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Source Citations (Grounding Metadata):',
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...widget.data.sourceCitations.map((citation) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(citation, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Execution ID: ${widget.data.stepExecutionId}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.outline)),
              Text('Status: ${widget.data.executionStatus}',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: widget.data.executionStatus == 'COMPLETED'
                          ? Colors.green
                          : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalGate(ThemeData theme) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final canApprove = widget.controller.hasBeenExpanded;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: canApprove ? widget.onApproved : null,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Approve AI Output'),
                style: FilledButton.styleFrom(
                  backgroundColor: canApprove
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: canApprove
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  disabledBackgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  disabledForegroundColor:
                      theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Wrapper to provide strict structural payload validation mock
/// and display native warning indicators if background updates fail.
class AiOutputBlock extends StatelessWidget {
  final AiRationaleMockData rationaleData;
  final AiRationaleController controller;
  final Widget aiGeneratedContent;

  const AiOutputBlock({
    super.key,
    required this.rationaleData,
    required this.controller,
    required this.aiGeneratedContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Simulate strict structural payload validation
    final isValidPayload = rationaleData.stepExecutionId.isNotEmpty &&
        rationaleData.sourceCitations.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Generated Content Block
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: aiGeneratedContent,
        ),

        // Native warning indicator if payload fails validation
        if (!isValidPayload)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.red.shade50,
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Background update failed: Invalid payload structure detected.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.red.shade900),
                  ),
                ),
              ],
            ),
          ),

        // Rationale Accordion directly beneath output block
        AiRationaleAccordion(
          data: rationaleData,
          controller: controller,
          onApproved: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('AI Output Approved successfully.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          },
        ),
      ],
    );
  }
}

// Note: AnimatedBuilder and ListenableBuilder are standard Flutter widgets.
// If targeting older Flutter versions, replace AnimatedBuilder with AnimatedBuilder 
// or use standard Builder patterns. In modern Flutter (3.x+), these are natively supported.
// For strict compatibility, here is a fallback alias if needed by the build system:
// typedef AnimatedBuilder = AnimatedBuilder; // No-op, just ensuring clarity.
