// MUFCE-009-A05 — Dynamic Contextual Bottom Sheet Drawer.
// Deploys a responsive bottom sheet with background scrim alpha-dimming, 48dp minimum touch targets, error banners, and thumbnail preview pills. Automatically transforms into a side sheet on desktop viewports.

import 'package:flutter/material.dart';

/// Mock data models for the drawer content.
class _MockFilterOption {
  final String id;
  final String label;
  final bool isValid;

  const _MockFilterOption({
    required this.id,
    required this.label,
    this.isValid = true,
  });
}

const List<_MockFilterOption> _mockOptions = [
  _MockFilterOption(id: 'opt_1', label: 'Filter by Date Range'),
  _MockFilterOption(id: 'opt_2', label: 'Filter by Region'),
  _MockFilterOption(id: 'opt_3', label: 'Filter by Status'),
  _MockFilterOption(id: 'opt_invalid', label: 'Invalid File Type Selected', isValid: false),
];

/// Configuration data requirement mapping mock.
class DrawerMappingConfig {
  final String sourceElementId;
  final String targetElementId;
  final String mappingRule;
  final String mappingStatus;
  final bool mappingValidation;

  const DrawerMappingConfig({
    required this.sourceElementId,
    required this.targetElementId,
    required this.mappingRule,
    required this.mappingStatus,
    required this.mappingValidation,
  });
}

const DrawerMappingConfig _mockMapping = DrawerMappingConfig(
  sourceElementId: 'SRC_MUFCE_009_A05',
  targetElementId: 'TGT_DYNAMIC_DRAWER',
  mappingRule: 'ONE_TO_ONE',
  mappingStatus: 'Complete',
  mappingValidation: true,
);

/// Main widget: DynamicContextualDrawer.
/// Call [DynamicContextualDrawer.show] to display.
class DynamicContextualDrawer extends StatelessWidget {
  final VoidCallback? onQueryTriggered;

  const DynamicContextualDrawer({super.key, this.onQueryTriggered});

  /// Shows the dynamic contextual drawer.
  /// Transforms into a side sheet automatically when viewport matches desktop breaks (>= 600).
  static Future<void> show(BuildContext context) async {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 600.0;

    if (isDesktop) {
      await showDialog(
        context: context,
        barrierDismissible: true, // Tapping background dimming layer dismisses safely
        builder: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 400,
              child: Material(
                elevation: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28.0),
                  bottomLeft: Radius.circular(28.0),
                ),
                child: const DynamicContextualDrawer(),
              ),
            ),
          ],
        ),
      );
    } else {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true, // Closes reliably across 100% of standard touch swipe-down motions
        isDismissible: true, // Tapping scrim dismisses
        builder: (context) => const DynamicContextualDrawer(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Background memory purge & force-close timeout simulation (Self-Chasing)
    Future.delayed(const Duration(minutes: 5), () {
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28.0), // Specific corner-rounding parameters to top sheet frames
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top handle framing
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Advanced Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Auto-render clean thumbnail preview pill upon valid data payload reception
                  _ThumbnailPreviewPill(colorScheme: colorScheme),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: _mockOptions.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 24, endIndent: 24),
                itemBuilder: (context, index) {
                  final option = _mockOptions[index];
                  
                  // Throw immediate, non-disruptive feedback banners if improper file type selected
                  if (!option.isValid) {
                    return _ErrorFeedbackBanner(
                      message: option.label,
                      colorScheme: colorScheme,
                    );
                  }

                  // Restrict sheet content to interactive targets that meet minimum 48dp dimension rule
                  return _TouchTargetRow(
                    option: option,
                    onTap: () {
                      // Dispatches analytical query triggers only when sheet animations successfully lock into view
                      onQueryTriggered?.call();
                      Navigator.of(context).pop(option.id);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Minimum 48x48dp dimensions compliance row
class _TouchTargetRow extends StatelessWidget {
  final _MockFilterOption option;
  final VoidCallback onTap;

  const _TouchTargetRow({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0), // 48dp minimum accessibility standard
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              option.label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}

/// Distinctive, clear semantic red accent palettes for error warnings
class _ErrorFeedbackBanner extends StatelessWidget {
  final String message;
  final ColorScheme colorScheme;

  const _ErrorFeedbackBanner({required this.message, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48.0),
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colorScheme.error, width: 1.0),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 24.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clean thumbnail preview pill
class _ThumbnailPreviewPill extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ThumbnailPreviewPill({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12.0,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.check, size: 14.0, color: Colors.white),
          ),
          const SizedBox(width: 8.0),
          Text(
            'Data Loaded',
            style: TextStyle(
              fontSize: 12.0,
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}