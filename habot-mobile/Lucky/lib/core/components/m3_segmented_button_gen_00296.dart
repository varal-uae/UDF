// GEN-00296 — Material 3 Segmented Button component.
// Provides a reusable M3 SegmentedButton wrapper with 48x48dp minimum touch targets, single-select/multi-select support, and Material You color integration.

import 'package:flutter/material.dart';

/// Reusable Material 3 segmented button following MD3 component specifications.
class M3SegmentedButtonGen00296<T> extends StatelessWidget {
  const M3SegmentedButtonGen00296({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = true,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final void Function(Set<T>) onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Material 3 segmented button',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0),
        child: SegmentedButton<T>(
          segments: segments,
          selected: selected,
          onSelectionChanged: onSelectionChanged,
          multiSelectionEnabled: multiSelectionEnabled,
          emptySelectionAllowed: emptySelectionAllowed,
          showSelectedIcon: showSelectedIcon,
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(48.0, 48.0)),
            tapTargetSize: MaterialTapTargetSize.padded,
            visualDensity: VisualDensity.standard,
            textStyle: WidgetStateProperty.all(theme.textTheme.labelLarge),
          ),
        ),
      ),
    );
  }
}
