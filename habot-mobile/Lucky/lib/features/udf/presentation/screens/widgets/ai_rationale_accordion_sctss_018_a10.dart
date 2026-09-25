// SCTSS-018-A10 — AI Rationale Accordion (Trust Layer) for Explainable AI outputs.
// Implements a collapsible panel displaying AI decision rationale and source citations, with auto-expand on low confidence, pulse animation, and approve-button gating.

import 'package:flutter/material.dart';

/// Mock data representing grounding metadata from Vector Search.
class AiRationaleMockData {
  final String id;
  final String generatedOutput;
  final String rationaleText;
  final List<String> sourceCitations;
  final double confidenceScore;

  const AiRationaleMockData({
    required this.id,
    required this.generatedOutput,
    required this.rationaleText,
    required this.sourceCitations,
    required this.confidenceScore,
  });
}

const List<AiRationaleMockData> kMockAiOutputs = [
  AiRationaleMockData(
    id: 'out_001',
    generatedOutput: 'Approved vendor payment of AED 45,000 for Q3 marketing services.',
    rationaleText:
        'The AI approved this payment because the vendor is listed in the active supplier registry, the invoice matches PO-2026-0891, and the amount falls within the authorized limit for the Marketing department as per company policy document FIN-POL-042.',
    sourceCitations: [
      'FIN-POL-042: Vendor Payment Authorization Limits',
      'PO-2026-0891: Q3 Marketing Services Purchase Order',
      'SUP-REG-2026: Active Supplier Registry'
    ],
    confidenceScore: 0.98,
  ),
  AiRationaleMockData(
    id: 'out_002',
    generatedOutput: 'Rejected expense claim #EXP-9921 for international roaming charges.',
    rationaleText:
        'The AI rejected this claim because the employee did not submit a pre-travel authorization form, which is mandatory for international roaming reimbursement according to HR-POL-112. Additionally, the claimed amount exceeds the daily cap by 40%.',
    sourceCitations: [
      'HR-POL-112: Travel & Expense Reimbursement Policy',
      'EXP-CAP-2026: Daily Expense Caps Table'
    ],
    confidenceScore: 0.45,
  ),
];

/// Poka-Yoke state controller to track if the user has expanded the accordion.
class AiApprovalGateController extends ChangeNotifier {
  bool _hasExpandedRationale = false;

  bool get canApprove => _hasExpandedRationale;

  void markExpanded() {
    if (!_hasExpandedRationale) {
      _hasExpandedRationale = true;
      notifyListeners();
    }
  }

  void reset() {
    _hasExpandedRationale = false;
    notifyListeners();
  }
}

class AiRationaleAccordion extends StatefulWidget {
  final AiRationaleMockData data;
  final AiApprovalGateController gateController;
  final VoidCallback? onApprove;

  const AiRationaleAccordion({
    super.key,
    required this.data,
    required this.gateController,
    this.onApprove,
  });

  @override
  State<AiRationaleAccordion> createState() => _AiRationaleAccordionState();
}

class _AiRationaleAccordionState extends State<AiRationaleAccordion>
    with SingleTickerProviderStateMixin {
  late final ExpansionTileController _tileController;
  late final AnimationController _pulseController;
  bool _isLowConfidence = false;

  static const double _lowConfidenceThreshold = 0.70;

  @override
  void initState() {
    super.initState();
    _tileController = ExpansionTileController();
    _isLowConfidence = widget.data.confidenceScore < _lowConfidenceThreshold;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Self-Chasing: Auto-expand and pulse if confidence is low
    if (_isLowConfidence) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tileController.expand();
        widget.gateController.markExpanded();
        _pulseController.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getPulseColor(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.errorContainer;
    if (!_isLowConfidence) return baseColor;
    return Color.lerp(
          Colors.transparent,
          Colors.yellow.shade700.withOpacity(0.3),
          _pulseController.value,
        ) ??
        Colors.yellow.shade700.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _getPulseColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isLowConfidence
                  ? colorScheme.error.withOpacity(0.5)
                  : colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Generated Output Block
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'AI Generated Output',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _buildConfidenceBadge(theme),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data.generatedOutput,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Rationale Accordion (Trust Layer)
          ExpansionTile(
            controller: _tileController,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              'AI Rationale (Why this decision?)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _isLowConfidence
                  ? 'Low confidence detected. Review required.'
                  : 'Tap to view explainability details.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _isLowConfidence ? colorScheme.error : colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              _isLowConfidence ? Icons.warning_amber_rounded : Icons.expand_more,
              color: _isLowConfidence ? colorScheme.error : null,
            ),
            onExpansionChanged: (expanded) {
              if (expanded) {
                widget.gateController.markExpanded();
                if (!_isLowConfidence && _pulseController.isAnimating) {
                  _pulseController.stop();
                }
              }
            },
            children: [
              Text(
                widget.data.rationaleText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Source Citations (Vector Search Grounding):',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.data.sourceCitations.map(
                (citation) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.link, size: 16, color: colorScheme.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          citation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(ThemeData theme) {
    final isLow = widget.data.confidenceScore < _lowConfidenceThreshold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLow
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${(widget.data.confidenceScore * 100).toStringAsFixed(0)}% Conf',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isLow ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Wrapper demonstrating the Poka-Yoke Approve button lock.
class AiOutputReviewPanel extends StatefulWidget {
  final AiRationaleMockData data;

  const AiOutputReviewPanel({super.key, required this.data});

  @override
  State<AiOutputReviewPanel> createState() => _AiOutputReviewPanelState();
}

class _AiOutputReviewPanelState extends State<AiOutputReviewPanel> {
  late final AiApprovalGateController _gateController;

  @override
  void initState() {
    super.initState();
    _gateController = AiApprovalGateController();
  }

  @override
  void dispose() {
    _gateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AiRationaleAccordion(
              data: widget.data,
              gateController: _gateController,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedBuilder(
                animation: _gateController,
                builder: (context, _) {
                  return FilledButton.icon(
                    onPressed: _gateController.canApprove
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Approved output ${widget.data.id}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            _gateController.reset();
                          }
                        : null, // Poka-Yoke: Locked until expanded
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      _gateController.canApprove
                          ? 'Approve AI Decision'
                          : 'Read Rationale to Approve',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Demo screen to test accordion toggle interactions on desktop and mobile touch devices.
class AiRationaleAccordionDemoScreen extends StatelessWidget {
  const AiRationaleAccordionDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Trust Layer - Rationale Accordion'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: kMockAiOutputs.length,
        itemBuilder: (context, index) {
          return AiOutputReviewPanel(data: kMockAiOutputs[index]);
        },
      ),
    );
  }
}
