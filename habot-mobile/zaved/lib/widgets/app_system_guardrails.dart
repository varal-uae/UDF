import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';

/// Phase 4 & Phase 5: Application Logic, Hard Locks & Policy Enforcement

// ============================================================================
// 4.1 Three-Tier AI Confidence Alerting Container
// ============================================================================
enum AiConfidenceTier { high, medium, low }

class AppAiConfidenceContainer extends StatelessWidget {
  final double confidenceScore; // e.g. 0.95 (95%), 0.80 (80%), 0.55 (55%)
  final String extractedDataLabel;
  final String extractedValue;
  final VoidCallback? onRouteToHumanReview;

  const AppAiConfidenceContainer({
    super.key,
    required this.confidenceScore,
    required this.extractedDataLabel,
    required this.extractedValue,
    this.onRouteToHumanReview,
  });

  AiConfidenceTier get tier {
    if (confidenceScore >= 0.90) return AiConfidenceTier.high;
    if (confidenceScore >= 0.70) return AiConfidenceTier.medium;
    return AiConfidenceTier.low;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (confidenceScore * 100).toStringAsFixed(1);

    switch (tier) {
      case AiConfidenceTier.high:
        return Container(
          padding: const EdgeInsets.all(AppDesignTokens.spaceM),
          decoration: BoxDecoration(
            color: AppDesignTokens.successContainer,
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
            border: Border.all(color: AppDesignTokens.successMain),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppDesignTokens.successDark),
              const SizedBox(width: AppDesignTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI High Confidence ($percentage%) - Auto-Approve Enabled',
                      style: AppDesignTokens.titleSmall.copyWith(
                        color: AppDesignTokens.successDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$extractedDataLabel: $extractedValue',
                      style: AppDesignTokens.bodyMedium.copyWith(
                        color: AppDesignTokens.successDark,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: const Text('AUTO-APPROVED'),
                backgroundColor: AppDesignTokens.successMain,
                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      case AiConfidenceTier.medium:
        return Container(
          padding: const EdgeInsets.all(AppDesignTokens.spaceM),
          decoration: BoxDecoration(
            color: AppDesignTokens.warningContainer,
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
            border: Border.all(color: AppDesignTokens.warningMain),
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: AppDesignTokens.warningDark),
              const SizedBox(width: AppDesignTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Medium Confidence ($percentage%) - Proceed with Caution',
                      style: AppDesignTokens.titleSmall.copyWith(
                        color: AppDesignTokens.warningText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$extractedDataLabel: $extractedValue',
                      style: AppDesignTokens.bodyMedium.copyWith(
                        color: AppDesignTokens.warningText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case AiConfidenceTier.low:
        return Container(
          padding: const EdgeInsets.all(AppDesignTokens.spaceM),
          decoration: BoxDecoration(
            color: AppDesignTokens.errorContainer,
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
            border: Border.all(color: AppDesignTokens.errorMain, width: 2.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: AppDesignTokens.errorDark, size: 28),
                  const SizedBox(width: AppDesignTokens.spaceS),
                  Text(
                    'MANDATORY LOW CONFIDENCE ALERT ($percentage%)',
                    style: AppDesignTokens.titleMedium.copyWith(
                      color: AppDesignTokens.errorDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDesignTokens.spaceS),
              Text(
                'Downstream automated processing HAS BEEN PAUSED for safety. Extracted Payload "$extractedDataLabel: $extractedValue" requires human verification.',
                style: AppDesignTokens.bodyMedium.copyWith(
                  color: AppDesignTokens.errorDark,
                ),
              ),
              const SizedBox(height: AppDesignTokens.spaceM),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignTokens.errorMain,
                  foregroundColor: Colors.white,
                ),
                onPressed: onRouteToHumanReview,
                icon: const Icon(Icons.person_search),
                label: const Text('Route to Human Review Queue'),
              ),
            ],
          ),
        );
    }
  }
}

// ============================================================================
// 4.2 Hard Lock / Navigation Isolation Guard
// ============================================================================
class AppHardLockNavigationGuard extends StatelessWidget {
  final bool isDataEntryActive;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Widget child;

  const AppHardLockNavigationGuard({
    super.key,
    required this.isDataEntryActive,
    required this.onSave,
    required this.onCancel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isDataEntryActive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isDataEntryActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppDesignTokens.errorMain,
              content: const Text(
                'HARD LOCK ACTIVE: Complete or Cancel active data entry before navigating away!',
              ),
            ),
          );
        }
      },
      child: Column(
        children: [
          if (isDataEntryActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppDesignTokens.warningContainer,
              child: Row(
                children: [
                  const Icon(Icons.lock_clock, color: AppDesignTokens.warningDark),
                  const SizedBox(width: AppDesignTokens.spaceS),
                  Expanded(
                    child: Text(
                      'HARD LOCK ACTIVE: Global navigation isolated until explicit Save/Cancel.',
                      style: AppDesignTokens.labelSmall.copyWith(
                        color: AppDesignTokens.warningDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: AppDesignTokens.spaceS),
                  FilledButton(
                    onPressed: onSave,
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ============================================================================
// 5.2 System Lock & Capacity Breach Controller
// ============================================================================
class AppCapacityBreachAlertCard extends StatelessWidget {
  final double currentCapacityPercent; // e.g. 104.5%
  final String systemName;
  final String lockReason;
  final String isoTimestamp;

  const AppCapacityBreachAlertCard({
    super.key,
    required this.currentCapacityPercent,
    required this.systemName,
    required this.lockReason,
    required this.isoTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.spaceM),
      decoration: BoxDecoration(
        color: AppDesignTokens.errorContainer,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        border: Border.all(color: AppDesignTokens.errorMain, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block, color: AppDesignTokens.errorDark, size: 32),
              const SizedBox(width: AppDesignTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SYSTEM BREACH LOCK ACTIVATED (${currentCapacityPercent.toStringAsFixed(1)}% of Cap)',
                      style: AppDesignTokens.titleMedium.copyWith(
                        color: AppDesignTokens.errorDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Infrastructure Operations locked to READ-ONLY state.',
                      style: AppDesignTokens.bodySmall.copyWith(
                        color: AppDesignTokens.errorDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            'Target System: $systemName',
            style: AppDesignTokens.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Lock Reason: $lockReason',
            style: AppDesignTokens.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Lock Timestamp: $isoTimestamp',
            style: AppDesignTokens.monospaceToken.copyWith(
              fontSize: 12.0,
              color: AppDesignTokens.errorDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5.3 Immutable Audit Logger Display
// ============================================================================
class AppImmutableAuditLogCard extends StatelessWidget {
  final String actionName;
  final String triggerSource;
  final String isoTimestamp;
  final String verificationHash;

  const AppImmutableAuditLogCard({
    super.key,
    required this.actionName,
    required this.triggerSource,
    required this.isoTimestamp,
    required this.verificationHash,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDesignTokens.elevation1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        side: const BorderSide(color: AppDesignTokens.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  actionName,
                  style: AppDesignTokens.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(triggerSource),
                  backgroundColor: AppDesignTokens.infoContainer,
                  labelStyle: AppDesignTokens.labelSmall.copyWith(
                    color: AppDesignTokens.infoDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'TIMESTAMP: $isoTimestamp',
              style: AppDesignTokens.monospaceToken.copyWith(fontSize: 12.0),
            ),
            const SizedBox(height: 4),
            Text(
              'HASH: $verificationHash',
              style: AppDesignTokens.monospaceToken.copyWith(
                fontSize: 11.0,
                color: AppDesignTokens.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
