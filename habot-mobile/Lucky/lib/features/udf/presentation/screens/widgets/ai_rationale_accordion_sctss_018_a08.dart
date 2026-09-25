// SCTSS-018-A08 — AI Rationale Accordion (Trust Layer) component.
// Implements a collapsible panel explaining AI decisions with confidence scores, source citations, strict payload validation, and Poka-Yoke approval locking.

import 'package:flutter/material.dart';

/// Mock data models representing incoming AI rationale payloads.
class AiRationalePayload {
  final String stepExecutionId;
  final String rationaleText;
  final double confidenceScore;
  final List<String> sourceCitations;
  final String executionStatus;
  final DateTime executionTimestamp;

  const AiRationalePayload({
    required this.stepExecutionId,
    required this.rationaleText,
    required this.confidenceScore,
    required this.sourceCitations,
    required this.executionStatus,
    required this.executionTimestamp,
  });
}

/// Strict structural payload validation rules interceptor.
class PayloadValidator {
  static bool isValid(AiRationalePayload? payload) {
    if (payload == null) return false;
    if (payload.stepExecutionId.trim().isEmpty) return false;
    if (payload.rationaleText.trim().isEmpty) return false;
    if (payload.confidenceScore < 0.0 || payload.confidenceScore > 1.0) return false;
    if (payload.sourceCitations.isEmpty) return false;
    return true;
  }
}

/// Hardcoded realistic mock data for local development without backend.
final List<AiRationalePayload> mockAiPayloads = [
  AiRationalePayload(
    stepExecutionId: 'EXEC-001',
    rationaleText: 'The generated code snippet uses the repository pattern to isolate data access logic, complying with company policy HRE-SP-06042026 regarding separation of concerns.',
    confidenceScore: 0.95,
    sourceCitations: ['Company Policy Doc v2.1 - Section 4.2', 'Architecture Guidelines 2025'],
    executionStatus: 'SUCCESS',
    executionTimestamp: DateTime(2026, 9, 25, 10, 30),
  ),
  AiRationalePayload(
    stepExecutionId: 'EXEC-002',
    rationaleText: 'Low confidence decision due to ambiguous input parameters. The system defaulted to standard string parsing instead of regex extraction to prevent data corruption.',
    confidenceScore: 0.42,
    sourceCitations: ['Data Integrity Manual - Page 112'],
    executionStatus: 'WARNING',
    executionTimestamp: DateTime(2026, 9, 25, 11, 15),
  ),
];

/// Controller managing the Poka-Yoke state for the Approve button.
class AiRationaleController extends ChangeNotifier {
  bool _hasBeenExpanded = false;
  bool get isApprovalUnlocked => _hasBeenExpanded;

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

/// The standardized Explainable AI (XAI) UI component block.
/// Placed directly beneath every AI-generated output block.
class AiRationaleAccordion extends StatefulWidget {
  final AiRationalePayload? payload;
  final AiRationaleController controller;
  final VoidCallback? onApprove;

  const AiRationaleAccordion({
    super.key,
    required this.payload,
    required this.controller,
    this.onApprove,
  });

  @override
  State<AiRationaleAccordion> createState() => _AiRationaleAccordionState();
}

class _AiRationaleAccordionState extends State<AiRationaleAccordion>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<Color?> _pulseColorAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseColorAnimation = ColorTween(
      begin: Colors.yellow.shade100,
      end: Colors.yellow.shade700,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    final isLowConfidence = widget.payload != null &&
        PayloadValidator.isValid(widget.payload) &&
        widget.payload!.confidenceScore < 0.7;

    if (isLowConfidence) {
      _isExpanded = true;
      widget.controller.markAsExpanded();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fallback layout hides underlying data errors cleanly
    if (!PayloadValidator.isValid(widget.payload)) {
      return _buildErrorFallback(theme);
    }

    final payload = widget.payload!;
    final isLowConfidence = payload.confidenceScore < 0.7;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Card(
          color: isLowConfidence ? _pulseColorAnimation.value : colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: isLowConfidence ? Colors.yellow.shade800 : colorScheme.outlineVariant,
              width: isLowConfidence ? 2.0 : 1.0,
            ),
          ),
          child: child,
        );
      },
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
          if (expanded) {
            widget.controller.markAsExpanded();
            if (!isLowConfidence) {
              _pulseController.stop();
            }
          }
        },
        title: Row(
          children: [
            Icon(
              Icons.psychology_alt_outlined,
              color: colorScheme.primary,
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              'AI Rationale & Trust Layer',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildConfidenceBadge(payload.confidenceScore, theme),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Execution ID: ${payload.stepExecutionId}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            payload.rationaleText,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16.0),
          const Divider(),
          const SizedBox(height: 8.0),
          Text(
            'Source Citations (Grounding Metadata):',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          ...payload.sourceCitations.map((citation) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.link, size: 16.0, color: colorScheme.primary),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        citation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16.0),
          _buildApprovalButton(theme),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(double score, ThemeData theme) {
    Color bgColor;
    Color fgColor;
    if (score >= 0.8) {
      bgColor = Colors.green.shade100;
      fgColor = Colors.green.shade900;
    } else if (score >= 0.5) {
      bgColor = Colors.orange.shade100;
      fgColor = Colors.orange.shade900;
    } else {
      bgColor = Colors.red.shade100;
      fgColor = Colors.red.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        '${(score * 100).toStringAsFixed(0)}% Confident',
        style: theme.textTheme.labelSmall?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildApprovalButton(ThemeData theme) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isUnlocked = widget.controller.isApprovalUnlocked;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isUnlocked ? widget.onApprove : null,
            icon: Icon(isUnlocked ? Icons.check_circle_outline : Icons.lock_outline),
            label: Text(isUnlocked ? 'Approve AI Output' : 'Read Rationale to Unlock Approval'),
            style: FilledButton.styleFrom(
              backgroundColor: isUnlocked ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
              foregroundColor: isUnlocked ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
          ),
        );
      },
    );
  }

  /// Native warning indicator if background updates fail or payload is invalid.
  Widget _buildErrorFallback(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                'AI Rationale unavailable. Payload validation failed or data missing.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example usage screen demonstrating the accordion attached to generative outputs.
class AiOutputScreen extends StatelessWidget {
  const AiOutputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AiRationaleController();

    return Scaffold(
      appBar: AppBar(title: const Text('AI Generated Outputs')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockAiPayloads.length,
        itemBuilder: (context, index) {
          final payload = mockAiPayloads[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simulated AI Generated Output Block
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Generated Code Snippet #${index + 1}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          'class UserRepository {\n  Future<User> fetchUser(String id) async {\n    return await db.query(id);\n  }\n}',
                          style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Standardized XAI UI component block directly beneath
              AiRationaleAccordion(
                payload: payload,
                controller: controller,
                onApprove: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Approved Execution: ${payload.stepExecutionId}')),
                  );
                },
              ),
              const SizedBox(height: 24.0),
            ],
          );
        },
      ),
    );
  }
}