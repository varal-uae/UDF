import 'package:flutter/material.dart';
import '../models/step_item.dart';
import '../tokens/spacing_tokens.dart';

class StepDetailPage extends StatelessWidget {
  final StepItem stepItem;

  const StepDetailPage({
    super.key,
    required this.stepItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stepItem.effectiveAtomicCode,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (stepItem.atomicStepCode != null && stepItem.stepCode != stepItem.atomicStepCode) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Global: ${stepItem.stepCode}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              stepItem.title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Chip(
            avatar: Icon(stepItem.category.icon, size: 16, color: colorScheme.primary),
            label: Text(stepItem.category.label, style: TextStyle(fontSize: 12, color: colorScheme.primary)),
            backgroundColor: colorScheme.primaryContainer.withAlpha(80),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
          AppSpacingTokens.hGapMd,
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacingTokens.paddingMd,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Meta Info Card
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHigh,
                    child: Padding(
                      padding: AppSpacingTokens.paddingMd,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(stepItem.icon, color: colorScheme.onPrimaryContainer, size: 24),
                          ),
                          AppSpacingTokens.hGapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stepItem.title,
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                AppSpacingTokens.vGapXs,
                                Text(
                                  stepItem.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacingTokens.vGapLg,

                  // Step Component Viewport (Web & Mobile Responsive)
                  Builder(builder: stepItem.builder),
                  AppSpacingTokens.vGapXl,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
