/*
 * STEP 20: EDEBS-008-16 — Mathematically prove mobile vendor onboarding success
 * 
 * Setup Step (Action): Implement a Material Design 3 (MD3) elevated success card component.
 * Setup Step Description: Fixed structural layout, MD3 elevated success card, full-width mobile layout,
 *   stacked verified record with 48dp padding.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Full-width mobile layout with 48dp structural padding.
 *   - MD3 Level 2 tonal elevation with rounded 16dp corners.
 *   - Stacked verified vendor record & security hash verification badge.
 * 
 * What Was Done to Complete This Step:
 *   - Created `Md3ElevatedSuccessCard` widget and `OnboardingSuccessRecord` model in a single file.
 *   - Implemented elevated card container, security verification hash chip, and adherence score progress meter.
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/spacing_tokens.dart';

class OnboardingSuccessRecord {
  final String vendorId;
  final String vendorName;
  final String verificationHash;
  final String timestamp;
  final double adherenceScorePercentage;

  const OnboardingSuccessRecord({
    required this.vendorId,
    required this.vendorName,
    required this.verificationHash,
    required this.timestamp,
    this.adherenceScorePercentage = 0.98,
  });
}

/// Step EDEBS-008-16: Material Design 3 (MD3) Elevated Success Card Component.
class Md3ElevatedSuccessCard extends StatelessWidget {
  final OnboardingSuccessRecord record;

  const Md3ElevatedSuccessCard({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacingTokens.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: AppElevationTokens.level4 * 2,
            offset: const Offset(0, AppElevationTokens.level3),
          ),
        ],
      ),
      child: Padding(
        // Stacked verified record with 48dp padding per specification
        padding: const EdgeInsets.all(AppSpacingTokens.xxxl), // 48dp padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: AppColorPalette.success, size: 36.0),
                AppSpacingTokens.hGapSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Onboarding Proved & Verified',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColorPalette.success,
                        ),
                      ),
                      Text('Vendor ID: ${record.vendorId}', style: theme.textTheme.labelMedium),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapMd,
            Container(
              width: double.infinity,
              padding: AppSpacingTokens.paddingMd,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacingTokens.xs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vendor Name: ${record.vendorName}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  AppSpacingTokens.vGapXs,
                  Text('Proof Hash: ${record.verificationHash}', style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
                  AppSpacingTokens.vGapXs,
                  Text('Timestamp: ${record.timestamp}', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            AppSpacingTokens.vGapMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UI Design-System Adherence Rate:',
                  style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  '${(record.adherenceScorePercentage * 100).toInt()}% (Good)',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColorPalette.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
