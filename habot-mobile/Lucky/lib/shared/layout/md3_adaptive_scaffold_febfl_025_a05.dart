// FEBFL-025-A05 — Material 3 Adaptive Layout Scaffolds & Viewport Configurations.
// Implements canonical Material Design 3 window size classifications (Compact, Medium, Expanded)
// with single-column mobile stacked layouts, sticky right-aligned filter panels on expanded viewports,
// accessible focus order, and subtle fade-slide transition layers.

import 'package:flutter/material.dart';

/// Material 3 Window Size Classifications
enum M3WindowSizeClass {
  compact,
  medium,
  expanded;

  static M3WindowSizeClass fromWidth(double width) {
    if (width < 600) return M3WindowSizeClass.compact;
    if (width < 840) return M3WindowSizeClass.medium;
    return M3WindowSizeClass.expanded;
  }
}

/// Atomic Configuration Record representing layout and system configuration parameters.
class LayoutConfigurationRecord {
  final String configurationKey;
  final dynamic configurationValue;
  final String configurationType;
  final String validationStatus;
  final DateTime configurationTimestamp;

  const LayoutConfigurationRecord({
    required this.configurationKey,
    required this.configurationValue,
    required this.configurationType,
    required this.validationStatus,
    required this.configurationTimestamp,
  });

  Map<String, dynamic> toMap() => {
    'configurationKey': configurationKey,
    'configurationValue': configurationValue,
    'configurationType': configurationType,
    'validationStatus': validationStatus,
    'configurationTimestamp': configurationTimestamp.toIso8601String(),
  };
}

/// Production-ready Material 3 responsive layout scaffold supporting Compact,
/// Medium, and Expanded viewports.
class M3AdaptiveScaffold extends StatefulWidget {
  final Widget title;
  final Widget body;
  final Widget? stickyFilterPanel;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final VoidCallback? onSettingsTap;
  final void Function(M3WindowSizeClass sizeClass)? onViewportChanged;

  const M3AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.stickyFilterPanel,
    this.floatingActionButton,
    this.actions,
    this.onSettingsTap,
    this.onViewportChanged,
  });

  @override
  State<M3AdaptiveScaffold> createState() => _M3AdaptiveScaffoldState();
}

class _M3AdaptiveScaffoldState extends State<M3AdaptiveScaffold> {
  M3WindowSizeClass? _lastWindowSizeClass;

  void _showConfigurationPopup(BuildContext context) {
    final configRecords = [
      LayoutConfigurationRecord(
        configurationKey: 'viewport_boundary_lock',
        configurationValue: 'sticky_right_dock',
        configurationType: 'LayoutRule',
        validationStatus: 'Passed',
        configurationTimestamp: DateTime.now(),
      ),
      LayoutConfigurationRecord(
        configurationKey: 'screen_reader_order',
        configurationValue: 'sequential_traversal',
        configurationType: 'Accessibility',
        validationStatus: 'Passed',
        configurationTimestamp: DateTime.now(),
      ),
      LayoutConfigurationRecord(
        configurationKey: 'motion_curve',
        configurationValue: 'fade_slide_cubic',
        configurationType: 'Animation',
        validationStatus: 'Passed',
        configurationTimestamp: DateTime.now(),
      ),
    ];

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Layout & System Configurations'),
          content: SizedBox(
            width: 480,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: configRecords.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = configRecords[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    item.configurationKey,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item.configurationType} • Value: ${item.configurationValue}\nStatus: ${item.validationStatus}',
                  ),
                  trailing: Text(
                    '${item.configurationTimestamp.hour.toString().padLeft(2, '0')}:${item.configurationTimestamp.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentClass = M3WindowSizeClass.fromWidth(constraints.maxWidth);

        if (_lastWindowSizeClass != currentClass) {
          _lastWindowSizeClass = currentClass;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onViewportChanged?.call(currentClass);
          });
        }

        final effectiveActions = <Widget>[
          ...?widget.actions,
          IconButton(
            tooltip: 'User Layout Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              if (widget.onSettingsTap != null) {
                widget.onSettingsTap!();
              } else {
                _showConfigurationPopup(context);
              }
            },
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: widget.title,
            actions: effectiveActions,
            centerTitle: currentClass == M3WindowSizeClass.compact,
          ),
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.03),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                );
              },
              child: _buildLayoutForSizeClass(
                key: ValueKey(currentClass),
                sizeClass: currentClass,
                context: context,
              ),
            ),
          ),
          floatingActionButton: currentClass == M3WindowSizeClass.compact
              ? widget.floatingActionButton
              : null,
        );
      },
    );
  }

  Widget _buildLayoutForSizeClass({
    required Key key,
    required M3WindowSizeClass sizeClass,
    required BuildContext context,
  }) {
    switch (sizeClass) {
      case M3WindowSizeClass.compact:
        return Semantics(
          label: 'Mobile single column layout',
          child: SizedBox.expand(
            key: key,
            child: widget.body,
          ),
        );

      case M3WindowSizeClass.medium:
        return Semantics(
          label: 'Medium viewport layout',
          child: SizedBox.expand(
            key: key,
            child: Row(
              children: [
                Expanded(child: widget.body),
                if (widget.stickyFilterPanel != null) ...[
                  const VerticalDivider(width: 1),
                  SizedBox(
                    width: 280,
                    child: widget.stickyFilterPanel,
                  ),
                ],
              ],
            ),
          ),
        );

      case M3WindowSizeClass.expanded:
        return Semantics(
          label: 'Expanded desktop viewport layout with sticky filter panel',
          child: SizedBox.expand(
            key: key,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 7,
                  child: FocusTraversalOrder(
                    order: const NumericFocusOrder(1.0),
                    child: widget.body,
                  ),
                ),
                if (widget.stickyFilterPanel != null) ...[
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 3,
                    child: FocusTraversalOrder(
                      order: const NumericFocusOrder(2.0),
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        child: widget.stickyFilterPanel,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
    }
  }
}
