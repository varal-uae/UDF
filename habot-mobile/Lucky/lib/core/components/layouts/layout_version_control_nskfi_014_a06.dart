// NSKFI-014-A06 — Layout Version Control & Validation Service.
// Establishes mobile creative layout version control with Material Design 3 compliance, 48dp minimum touch targets, 16px outer margins, and visual regression validation using local mock data.

import 'package:flutter/material.dart';

/// Represents the validation status of a specific layout version.
enum LayoutValidationStatus {
  approved,
  pending,
  rejected,
}

/// Data model representing a versioned mobile layout configuration.
class LayoutVersionConfig {
  final String versionTag;
  final String layoutType;
  final double layoutGridWidth;
  final double layoutGridHeight;
  final double spacingRules;
  final double alignmentSettings;
  final LayoutValidationStatus validationStatus;
  final DateTime createdAt;
  final bool meetsTouchTargetRequirements;
  final bool hasOverlappingTargets;

  const LayoutVersionConfig({
    required this.versionTag,
    required this.layoutType,
    required this.layoutGridWidth,
    required this.layoutGridHeight,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.validationStatus,
    required this.createdAt,
    required this.meetsTouchTargetRequirements,
    required this.hasOverlappingTargets,
  });

  /// Returns true if this layout is safe to deploy to production.
  bool get isDeployable =>
      validationStatus == LayoutValidationStatus.approved &&
      meetsTouchTargetRequirements &&
      !hasOverlappingTargets;

  Map<String, dynamic> toJson() => {
        'versionTag': versionTag,
        'layoutType': layoutType,
        'layoutGridDimensions': '${layoutGridWidth}x$layoutGridHeight',
        'spacingRules': spacingRules,
        'alignmentSettings': alignmentSettings,
        'validationStatus': validationStatus.name,
        'createdAt': createdAt.toIso8601String(),
        'meetsTouchTargetRequirements': meetsTouchTargetRequirements,
        'hasOverlappingTargets': hasOverlappingTargets,
      };
}

/// Mock repository simulating GCP Artifact Registry for component hashes
/// and layout version storage. Provides realistic local data as per requirements.
class LayoutVersionMockRepository {
  static const double _globalOuterMargin = 16.0;
  static const double _minimumTouchTargetSize = 48.0;

  static List<LayoutVersionConfig> getMockVersions() {
    return [
      LayoutVersionConfig(
        versionTag: 'v1.0.0-staging',
        layoutType: 'ResponsiveFlexbox',
        layoutGridWidth: 360.0,
        layoutGridHeight: 640.0,
        spacingRules: 8.0,
        alignmentSettings: 0.5,
        validationStatus: LayoutValidationStatus.approved,
        createdAt: DateTime(2026, 5, 1),
        meetsTouchTargetRequirements: true,
        hasOverlappingTargets: false,
      ),
      LayoutVersionConfig(
        versionTag: 'v1.1.0-beta',
        layoutType: 'ResponsiveFlexbox',
        layoutGridWidth: 390.0,
        layoutGridHeight: 844.0,
        spacingRules: 12.0,
        alignmentSettings: 0.5,
        validationStatus: LayoutValidationStatus.pending,
        createdAt: DateTime(2026, 6, 5),
        meetsTouchTargetRequirements: true,
        hasOverlappingTargets: false,
      ),
      LayoutVersionConfig(
        versionTag: 'v0.9.0-broken',
        layoutType: 'FixedGrid',
        layoutGridWidth: 320.0,
        layoutGridHeight: 480.0,
        spacingRules: 4.0,
        alignmentSettings: 0.0,
        validationStatus: LayoutValidationStatus.rejected,
        createdAt: DateTime(2026, 4, 15),
        meetsTouchTargetRequirements: false,
        hasOverlappingTargets: true,
      ),
    ];
  }

  static double get globalOuterMargin => _globalOuterMargin;
  static double get minimumTouchTargetSize => _minimumTouchTargetSize;
}

/// Service responsible for managing layout versions, enforcing Poka-Yoke
/// (mistake-proofing) rules, and ensuring only approved layouts reach users.
class LayoutVersionControlService {
  final List<LayoutVersionConfig> _versionHistory;
  LayoutVersionConfig? _activeVersion;

  LayoutVersionControlService()
      : _versionHistory = LayoutVersionMockRepository.getMockVersions() {
    // Initialize with the latest approved version
    _activeVersion = _versionHistory.lastWhere(
      (v) => v.isDeployable,
      orElse: () => _versionHistory.first,
    );
  }

  LayoutVersionConfig? get activeVersion => _activeVersion;
  List<LayoutVersionConfig> get versionHistory =>
      List.unmodifiable(_versionHistory);

  /// Attempts to promote a layout version to active.
  /// Poka-Yoke: Unapproved or overlapping layouts cannot replace active UX.
  bool promoteVersion(String versionTag) {
    final candidate = _versionHistory.firstWhere(
      (v) => v.versionTag == versionTag,
      orElse: () => throw StateError('Version $versionTag not found in registry.'),
    );

    if (!candidate.isDeployable) {
      debugPrint(
          '[NSKFI-014-A06] Poka-Yoke Block: Version $versionTag is not deployable. '
          'Status: ${candidate.validationStatus.name}, '
          'TouchTargetsOK: ${candidate.meetsTouchTargetRequirements}, '
          'NoOverlap: ${!candidate.hasOverlappingTargets}');
      return false;
    }

    _activeVersion = candidate;
    debugPrint('[NSKFI-014-A06] Successfully promoted $versionTag to active.');
    return true;
  }

  /// Rolls back to a previous approved version.
  /// Completion Measure: Previous UI versions can be successfully rolled back in under 60 seconds.
  bool rollbackToVersion(String versionTag) {
    return promoteVersion(versionTag);
  }

  /// Validates that a given size meets the Material Design 48dp minimum touch target.
  static bool validateTouchTarget(Size size) {
    return size.width >= LayoutVersionMockRepository.minimumTouchTargetSize &&
        size.height >= LayoutVersionMockRepository.minimumTouchTargetSize;
  }
}

/// A standardized wrapper widget that enforces the 16px global outer margin
/// and applies the currently active layout version configuration.
class VersionedLayoutWrapper extends StatelessWidget {
  final Widget child;
  final LayoutVersionControlService versionControlService;

  const VersionedLayoutWrapper({
    super.key,
    required this.child,
    required this.versionControlService,
  });

  @override
  Widget build(BuildContext context) {
    final activeConfig = versionControlService.activeVersion;

    return Padding(
      padding: EdgeInsets.all(LayoutVersionMockRepository.globalOuterMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (activeConfig != null)
            _LayoutVersionBanner(config: activeConfig),
          const SizedBox(height: 16.0),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _LayoutVersionBanner extends StatelessWidget {
  final LayoutVersionConfig config;

  const _LayoutVersionBanner({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Active Layout: ${config.versionTag}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Icon(
            config.isDeployable ? Icons.verified_user : Icons.warning,
            color: config.isDeployable
                ? Colors.green
                : theme.colorScheme.error,
            size: 20.0,
          ),
        ],
      ),
    );
  }
}

/// A compliant button widget that strictly enforces the 48dp x 48dp
/// minimum touch area borders as specified in Mobile-First Material Design.
class CompliantTouchTargetButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const CompliantTouchTargetButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 48.0,
        minHeight: 48.0,
      ),
      child: FilledButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}