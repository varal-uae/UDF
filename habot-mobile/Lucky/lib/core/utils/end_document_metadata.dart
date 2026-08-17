// ETMDI-001-12 — EndDocument Metadata State and Bounding coordinates.
// Defines structured EndDocument metadata properties and maps them cleanly.
// Enforces 48dp minimum click bounds on all configuration fields.

import 'package:flutter/material.dart';

/// Schema representation of the EndDocument metadata configuration.
class EndDocumentMetadata {
  const EndDocumentMetadata({
    required this.predecessorId,
    required this.stepExecutionId,
    required this.status,
    required this.timestamp,
    required this.ownerId,
  });

  final String predecessorId;
  final String stepExecutionId;
  final String status;
  final String timestamp;
  final String ownerId;

  Map<String, dynamic> toJson() => {
        'predecessor_id': predecessorId,
        'step_execution_id': stepExecutionId,
        'status': status,
        'timestamp': timestamp,
        'owner_id': ownerId,
      };
}

/// Active field configuration container enforcing 48dp click heights and error highlights.
class EndDocumentField extends StatelessWidget {
  const EndDocumentField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorMessage,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bool hasError = errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Typography matching token specifications
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: hasError ? cs.error : cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        
        // Enforced 48dp input target boundaries
        SizedBox(
          height: 48,
          child: TextFormField(
            initialValue: value,
            onChanged: onChanged,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: hasError ? cs.error : cs.onSurface,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorStyle: const TextStyle(height: 0, fontSize: 0), // Suppress standard error line
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: hasError ? cs.error : cs.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: hasError ? cs.error : cs.outline),
              ),
            ),
          ),
        ),
        
        // Custom MD3 validation text layout
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
