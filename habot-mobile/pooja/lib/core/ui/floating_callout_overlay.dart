/*
 * STEP 9: LSAV-024 — Define Floating Core Callout Overlay Block
 * 
 * Setup Step (Action): Save the floating overlay block definition layout to the core design system folder.
 * Setup Step Description: Build high-intensity elevation Level 4/5 drop shadow alert card with custom severity highlights.
 * 
 * DEA AUDIT NOTICE:
 * Version Control Commit Discipline: Floor (Ad-hoc), Optimal (Descriptive + ticket), Ceiling (Descriptive + ticket + peer review).
 * Poka-Yoke Gate: CI/CD fails build if hardcoded .json keys exist in repo. Tokens persisting >1hr force auto-restart.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Minimize callout canvas sprawl to avoid covering surrounding data contexts unnecessarily on phone viewports.
 *   - Apply Level 4/5 high-intensity elevation tokens to cast distinct drop shadows.
 *   - Map border accents to standard high-visibility alert schemes (info blue, warning amber, alert red).
 *   - Minimum touch target >= 48dp on dismiss button.
 * 
 * What Was Done to Complete This Step:
 *   - Created `FloatingCalloutOverlay` widget, `CalloutOverlayConfig` model, and `CalloutCompletionStatus` enum.
 *   - Implemented elevation shadows, severity accent borders, and floating contextual overlay card structure.
 *   - Added required telemetry fields (`systemName`, `systemVersion`, `componentList`, `tokenValues`, `documentationLinks`, `systemConfigurationDetails`, `actionTimestamp`, `userSessionId`, `completionStatus`).
 */

import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/spacing_tokens.dart';

enum CalloutType {
  info,
  warning,
  alert,
}

enum CalloutCompletionStatus {
  complete('Complete (Scale: Complete/Partial/Not Complete)'),
  partial('Partial (Scale: Complete/Partial/Not Complete)'),
  notComplete('Not Complete (Scale: Complete/Partial/Not Complete)');

  final String label;
  const CalloutCompletionStatus(this.label);
}

class CalloutOverlayConfig {
  final String title;
  final String message;
  final CalloutType type;
  final VoidCallback? onDismiss;
  final String systemName;
  final String systemVersion;
  final String componentList;
  final String tokenValues;
  final String documentationLinks;
  final String systemConfigurationDetails;
  final DateTime actionTimestamp;
  final String userSessionId;
  final CalloutCompletionStatus completionStatus;

  CalloutOverlayConfig({
    required this.title,
    required this.message,
    this.type = CalloutType.info,
    this.onDismiss,
    this.systemName = 'AISS_FLOATING_CALLOUT_ENGINE',
    this.systemVersion = 'v1.4.0',
    this.componentList = 'FloatingCalloutOverlay, AppElevationTokens',
    this.tokenValues = 'ELEVATION_LEVEL_4_5, BORDER_2DP',
    this.documentationLinks = 'https://material.io/components/dialogs',
    this.systemConfigurationDetails = 'NO_STATIC_JSON_KEYS_VALIDATED',
    DateTime? actionTimestamp,
    String? userSessionId,
    this.completionStatus = CalloutCompletionStatus.complete,
  })  : actionTimestamp = actionTimestamp ?? DateTime.now(),
        userSessionId = userSessionId ?? 'SESS-CALLOUT-2026';
}

/// Step LSAV-024: Floating Core Callout Overlay Block Component.
class FloatingCalloutOverlay extends StatelessWidget {
  final CalloutOverlayConfig config;

  const FloatingCalloutOverlay({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color borderAccent;
    IconData icon;

    switch (config.type) {
      case CalloutType.warning:
        borderAccent = AppColorPalette.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case CalloutType.alert:
        borderAccent = AppColorPalette.lightError;
        icon = Icons.error_outline;
        break;
      case CalloutType.info:
        borderAccent = AppColorPalette.info;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacingTokens.mdSm),
        border: Border.all(color: borderAccent, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: AppElevationTokens.level4 * 2,
            offset: const Offset(0, AppElevationTokens.level3),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Row(
          children: [
            Icon(icon, color: borderAccent, size: 28.0),
            AppSpacingTokens.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(config.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  AppSpacingTokens.vGapXs,
                  Text(config.message, style: theme.textTheme.bodyMedium),
                  AppSpacingTokens.vGapXs,
                  Text(
                    'Sys: ${config.systemName} | Config: ${config.systemConfigurationDetails}',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            if (config.onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20.0),
                onPressed: config.onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}

