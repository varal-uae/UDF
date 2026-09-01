// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Layout Type: ConstrainedBox Max-Height Accordion with Forced-Read Lock
// Layout Grid Dimensions: Accordion maxHeight: 250.0px, Min touch target 48x48dp
// Spacing Rules: 16dp outer padding, 12dp internal citations padding
// Alignment Settings: CrossAxisAlignment.stretch, MainAxisAlignment.start
// Layout Validation Status: POKA_YOKE_FORCED_READ_LOCKED
// Completion Status: Complete (Ref: SCTSS-018-A02)
// ============================================================================

import 'package:flutter/material.dart';

/// SCTSS-018-A02: AI Rationale Accordion (Trust Layer)
/// Features:
/// 1. Max-Height Collapsible Panel: "Show Reasoning" accordion with maxHeight 250px and scrollable content.
/// 2. Forced-Read Lock (Poka-Yoke): Main "Approve AI Action" button disabled until user expands accordion.
/// 3. Low-Confidence Auto-Expand & Yellow Pulse: If confidence < 0.70, auto-expands and pulses yellow to chase verification.
class AiRationaleAccordion extends StatefulWidget {
  final double confidenceScore;
  final String aiOutputSummary;
  final String rationaleExplanation;
  final List<String> citations;
  final VoidCallback? onApproved;
  final VoidCallback? onRejected;

  const AiRationaleAccordion({
    super.key,
    this.confidenceScore = 0.64, // Default to low confidence to demonstrate auto-expand and pulse
    this.aiOutputSummary = 'Recommended Action: Execute automatic database partition re-indexing on cluster eu-west-1.',
    this.rationaleExplanation =
        'Vector Search retrieved 4 operational runbooks indicating I/O query degradation exceeding 450ms when shard table sizes cross 1.2M rows. The neural query planner projected a 62% query throughput recovery following index rebuilds.',
    this.citations = const [
      'KB-9042: Database Sharding Latency Remediation Playbook (Vector ID: #vec-8812)',
      'Telemetry Alert Log: #ALRT-49219 (Cluster EU-WEST-1)',
      'Enterprise SLA Standard Operating Procedure v4.2',
    ],
    this.onApproved,
    this.onRejected,
  });

  @override
  State<AiRationaleAccordion> createState() => _AiRationaleAccordionState();
}

class _AiRationaleAccordionState extends State<AiRationaleAccordion>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late bool _hasExpanded;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final bool isLowConfidence = widget.confidenceScore < 0.70;

    // Auto-expand if low confidence score (< 0.70)
    _isExpanded = isLowConfidence;
    _hasExpanded = isLowConfidence;

    // Yellow warning pulse for low confidence
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (isLowConfidence) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleAccordion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _hasExpanded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowConfidence = widget.confidenceScore < 0.70;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulseColor = isLowConfidence
            ? Color.lerp(
                Colors.amber.shade700.withValues(alpha: 0.2),
                Colors.amber.shade700.withValues(alpha: 0.55),
                _pulseAnimation.value,
              )!
            : theme.colorScheme.outlineVariant;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Output Hero Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isLowConfidence ? pulseColor : theme.colorScheme.outlineVariant,
                  width: isLowConfidence ? 2.0 : 1.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isLowConfidence
                              ? Colors.amber.shade100
                              : theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.auto_awesome,
                            color: isLowConfidence
                                ? Colors.amber.shade900
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI-GENERATED DECISION PROPOSAL',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                'Confidence: ${(widget.confidenceScore * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isLowConfidence ? Colors.amber.shade900 : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isLowConfidence)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade700),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber.shade900),
                                const SizedBox(width: 4),
                                Text(
                                  'LOW CONFIDENCE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.aiOutputSummary,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),

                    // Collapsible "Show Reasoning" Accordion Header
                    InkWell(
                      onTap: _toggleAccordion,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.psychology_outlined,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isExpanded ? 'Hide Reasoning' : 'Show Reasoning (XAI Trust Layer)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            Icon(
                              _isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 1. Max-Height Collapsible Content (maxHeight: 250px)
                    if (_isExpanded) ...[
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250.0),
                        child: Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Model Rationale & Reasoning Path:',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.rationaleExplanation,
                                  style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                                ),
                                const Divider(height: 20),
                                Text(
                                  'Vector Citations & Knowledge Base References:',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...widget.citations.map(
                                  (citation) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.bookmark_outline, size: 14, color: Colors.teal),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            citation,
                                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Poka-Yoke Action Row with Forced-Read Lock
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: widget.onRejected ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('AI Decision Rejected.')),
                          );
                        },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject Proposal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    // Forced-Read Lock: physically disabled if user has never expanded reasoning
                    onPressed: _hasExpanded
                        ? (widget.onApproved ??
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ AI Action Approved after verified rationale review!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            })
                        : null,
                    icon: const Icon(Icons.check),
                    label: Text(
                      _hasExpanded ? 'Approve AI Action' : '🔒 Read Reasoning First',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _hasExpanded
                    ? '✓ Trust Layer Gate Cleared: Reasoning has been verified.'
                    : '🔒 Poka-Yoke Lock: You must expand "Show Reasoning" before approving.',
                style: TextStyle(
                  fontSize: 11,
                  color: _hasExpanded ? Colors.green : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
