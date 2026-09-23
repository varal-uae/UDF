// RECET-006-A07 — Sharjah Entity Data Dictionary Verification Card.
// Mobile-first Material 3 digest card for regulatory record formatting constraints with vertical stacking, high-contrast error typography, graceful wrapping, and comfortable padding.

import 'package:flutter/material.dart';

/// Atomic-level data model for step execution tracking.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });
}

/// Domain-specific field constraint for Sharjah Entity Records.
class SharjahEntityFieldConstraint {
  final String fieldName;
  final String description;
  final RegExp validationRegex;
  final String currentValue;
  final bool isValid;

  const SharjahEntityFieldConstraint({
    required this.fieldName,
    required this.description,
    required this.validationRegex,
    required this.currentValue,
    required this.isValid,
  });
}

/// Mock data repository simulating backend database constraints.
class MockSharjahEntityRepository {
  static final List<SharjahEntityFieldConstraint> mockConstraints = [
    SharjahEntityFieldConstraint(
      fieldName: 'Trade License Number',
      description: 'Must follow Sharjah SEDD format: SHJ-YYYY-NNNNNN where YYYY is year and N is numeric sequence.',
      validationRegex: RegExp(r'^SHJ-\d{4}-\d{6}$'),
      currentValue: 'SHJ-2026-019283',
      isValid: true,
    ),
    SharjahEntityFieldConstraint(
      fieldName: 'Emirates ID Reference',
      description: 'Standard UAE EID format: 784-YYYY-NNNNNNN-N. Mandatory for all entity signatories.',
      validationRegex: RegExp(r'^784-\d{4}-\d{7}-\d$'),
      currentValue: 'INVALID-EID-FORMAT',
      isValid: false,
    ),
    SharjahEntityFieldConstraint(
      fieldName: 'Municipality Code',
      description: 'Three-letter municipality identifier mapped to Sharjah urban planning grid sectors.',
      validationRegex: RegExp(r'^[A-Z]{3}$'),
      currentValue: 'SHJ',
      isValid: true,
    ),
    SharjahEntityFieldConstraint(
      fieldName: 'Activity Code (ISIC)',
      description: 'International Standard Industrial Classification code. Must be exactly 4 to 6 digits without leading zeros unless mandated by local registry mapping controls.',
      validationRegex: RegExp(r'^\d{4,6}$'),
      currentValue: 'ABC',
      isValid: false,
    ),
  ];

  static final StepExecutionRecord mockExecutionRecord = StepExecutionRecord(
    stepExecutionId: 'EXEC-SHJ-006-A07-9999',
    executionStatus: 'COMPLETED',
    executionTimestamp: DateTime(2026, 9, 23, 14, 30),
    stepOutcome: 'Regulatory Compliance Design Specification Completeness: 95%',
    userId: 'USR-DEA-ADMIN-01',
  );
}

/// Evaluates qualitative output based on ISO/IEC/IEEE 42010 benchmark thresholds.
String evaluateCompliance(double score) {
  if (score >= 0.95) return 'Excellent';
  if (score >= 0.85) return 'Adequate';
  return 'Poor';
}

/// Mobile-first responsive verification card implementing Material 3 design tokens.
/// Long multi-column blocks stack vertically into clean digest cards.
/// Out-of-bounds fields highlight text using highly contrasting error typography.
/// Component layout frames wrap content gracefully preventing long descriptions from breaking bounds.
/// Form fields preserve comfortable layout padding to avoid component crowding.
class SharjahEntityVerificationCard extends StatelessWidget {
  final List<SharjahEntityFieldConstraint> constraints;
  final StepExecutionRecord executionRecord;
  final double complianceScore;

  const SharjahEntityVerificationCard({
    super.key,
    required this.constraints,
    required this.executionRecord,
    this.complianceScore = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final qualitativeOutput = evaluateCompliance(complianceScore);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        // Comfortable layout padding to avoid component crowding on compact panels
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Choice Badge visual treatment adhering to high-contrast Material tonal weights
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Sharjah Entity Format Constraints',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildComplianceBadge(context, qualitativeOutput),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Step: ${executionRecord.stepExecutionId} | Status: ${executionRecord.executionStatus}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            // Progress line compresses aspect grids smoothly to preserve layout text clarity
            LinearProgressIndicator(
              value: complianceScore.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                complianceScore >= 0.85 ? colorScheme.primary : colorScheme.error,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 20),

            // Vertical stacking of multi-column data verification blocks into clean digest cards
            ...constraints.map((constraint) => _buildFieldDigestItem(context, constraint)).toList(),

            const SizedBox(height: 24),

            // Feedback text entries leveraging structured, multi-line Material text areas
            _buildFeedbackTextArea(context),

            const SizedBox(height: 20),

            // Workflow actions clustered cleanly inside an inline contextual footer container
            _buildContextualFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceBadge(BuildContext context, String status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color containerColor;
    Color onContainerColor;

    switch (status) {
      case 'Excellent':
        containerColor = colorScheme.primaryContainer;
        onContainerColor = colorScheme.onPrimaryContainer;
        break;
      case 'Adequate':
        containerColor = colorScheme.tertiaryContainer;
        onContainerColor = colorScheme.onTertiaryContainer;
        break;
      default:
        containerColor = colorScheme.errorContainer;
        onContainerColor = colorScheme.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelLarge?.copyWith(
          color: onContainerColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFieldDigestItem(BuildContext context, SharjahEntityFieldConstraint constraint) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Out-of-bounds fields highlight text elements using highly contrasting error typography variables
    final bool isOutOfBounds = !constraint.isValid;
    final TextStyle valueStyle = isOutOfBounds
        ? textTheme.bodyLarge!.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          )
        : textTheme.bodyLarge!.copyWith(
            color: colorScheme.onSurface,
          );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOutOfBounds ? colorScheme.errorContainer.withOpacity(0.15) : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOutOfBounds ? colorScheme.error.withOpacity(0.5) : colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOutOfBounds ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                size: 18,
                color: isOutOfBounds ? colorScheme.error : colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  constraint.fieldName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isOutOfBounds ? colorScheme.error : colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Component layout frames wrap content entries gracefully, preventing long character descriptions from breaking bounds
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              Text(
                constraint.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Text(
              constraint.currentValue,
              style: valueStyle,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTextArea(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evaluation Notes',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Feedback text entries leverage structured, multi-line Material text areas
        TextField(
          maxLines: 4,
          minLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter compliance evaluation feedback...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildContextualFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Workflow actions cluster cleanly inside an inline contextual footer container on compact displays
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Re-validate'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.verified_rounded, size: 18),
            label: const Text('Push to Production'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview wrapper for testing the component layout in isolation.
class SharjahEntityVerificationPreview extends StatelessWidget {
  const SharjahEntityVerificationPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('UDF Regulatory Verification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SharjahEntityVerificationCard(
          constraints: MockSharjahEntityRepository.mockConstraints,
          executionRecord: MockSharjahEntityRepository.mockExecutionRecord,
          complianceScore: 0.95,
        ),
      ),
    );
  }
}
