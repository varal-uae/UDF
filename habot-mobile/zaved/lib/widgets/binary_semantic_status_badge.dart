import 'package:flutter/material.dart';
import '../theme/semantic_colors.dart';

/// TTMCS-002-A01: Binary Semantic Status Badge
/// Applies strict bold text treatments (`FontWeight.bold`) alongside semantic
/// color flags to maximize legibility for field workers under harsh outdoor sunlight.
class BinarySemanticStatusBadge extends StatelessWidget {
  final bool isCompliant;
  final String? customLabel;
  final IconData? customIcon;
  final bool compact;

  const BinarySemanticStatusBadge({
    super.key,
    required this.isCompliant,
    this.customLabel,
    this.customIcon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final semantic =
        Theme.of(context).extension<SemanticColors>() ?? SemanticColors.light;

    final backgroundColor =
        isCompliant ? semantic.successContainer : semantic.errorContainer;
    final foregroundColor =
        isCompliant ? semantic.onSuccessContainer : semantic.onErrorContainer;
    final borderColor = isCompliant ? semantic.success : semantic.error;

    final defaultLabel =
        isCompliant ? 'COMPLIANT (TRUE)' : 'NON-COMPLIANT (FALSE)';
    final label = customLabel ?? defaultLabel;
    final icon = customIcon ??
        (isCompliant ? Icons.check_circle_rounded : Icons.cancel_rounded);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 14 : 18,
            color: foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold, // Strict bold treatment for outdoor visibility
              fontSize: compact ? 11 : 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
