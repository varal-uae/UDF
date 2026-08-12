import 'package:flutter/material.dart';
import '../theme/semantic_status_colors.dart';

/// ValidationStatusAlert component using strict theme extension indirection.
class ValidationStatusAlert extends StatelessWidget {
  const ValidationStatusAlert({
    super.key,
    required this.isValid,
    required this.message,
  });

  final bool isValid;
  final String message;

  @override
  Widget build(BuildContext context) {
    // Dynamic theme extension extraction
    final statusColors = Theme.of(context).extension<SemanticStatusColors>()!;
    final statusColor = isValid ? statusColors.success : statusColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: statusColor,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.error_outline,
            color: statusColor,
          ),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold, // Bold text treatment
              ),
            ),
          ),
        ],
      ),
    );
  }
}
