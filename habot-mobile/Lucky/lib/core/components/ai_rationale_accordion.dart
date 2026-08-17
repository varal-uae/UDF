// ARCPE-004-11 — AI Rationale Accordion Trust Layer Component.
// Employs progressive disclosure via smooth height animations (AnimatedSize).
// Applies conditional badge colors based on trust score threshold bands.

import 'package:flutter/material.dart';

/// Trust score bands matching DCDF classification rules.
enum TrustBand { high, medium, low }

/// AI Rationale Accordion implementing clean detail disclosures and score styling.
class AiRationaleAccordion extends StatefulWidget {
  const AiRationaleAccordion({
    super.key,
    required this.score,
    required this.rationales,
    this.initiallyExpanded = false,
  });

  /// The trust score metric (0.0 to 1.0)
  final double score;

  /// Ordered list of logical steps explaining the AI reasoning
  final List<String> rationales;

  final bool initiallyExpanded;

  @override
  State<AiRationaleAccordion> createState() => _AiRationaleAccordionState();
}

class _AiRationaleAccordionState extends State<AiRationaleAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  TrustBand get _trustBand {
    if (widget.score >= 0.90) return TrustBand.high;
    if (widget.score >= 0.70) return TrustBand.medium;
    return TrustBand.low;
  }

  Color _resolveBadgeColor(ColorScheme cs) {
    switch (_trustBand) {
      case TrustBand.high:
        return const Color(0xFF21B373); // M3 Success Color
      case TrustBand.medium:
        return const Color(0xFFFF9800); // M3 Warning Color
      case TrustBand.low:
        return const Color(0xFFE31B23); // M3 Error Color
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final badgeColor = _resolveBadgeColor(cs);

    final scoreText = '${(widget.score * 100).toStringAsFixed(0)}% Confidence';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Header / Summary Row - Enforces standard 48dp minimum targets
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI Processing Rationale',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Score Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor),
                    ),
                    child: Text(
                      scoreText,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Rotation icon indicator
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          
          // Details Block - Smooth height transition
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Container(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: cs.outlineVariant, width: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.rationales.map((rationale) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.arrow_right, size: 20, color: cs.secondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  rationale,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}
