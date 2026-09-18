// GEN-01236 — M3 Segmented Button for Recurring Billing Frequency Selection.
// Implements a Material 3 SegmentedButton for selecting Weekly or Monthly billing frequencies with mock data, 48x48dp touch targets, and responsive layout support.

import 'package:flutter/material.dart';

/// Enum representing the available recurring billing frequencies.
enum BillingFrequency {
  weekly,
  monthly;

  String get label {
    switch (this) {
      case BillingFrequency.weekly:
        return 'Weekly';
      case BillingFrequency.monthly:
        return 'Monthly';
    }
  }
}

/// Mock data provider for billing frequency configuration.
class BillingFrequencyMockData {
  static const List<BillingFrequency> availableFrequencies = [
    BillingFrequency.weekly,
    BillingFrequency.monthly,
  ];

  static const BillingFrequency defaultFrequency = BillingFrequency.monthly;
}

/// A Material 3 Segmented Button component for selecting recurring billing frequencies.
///
/// Features:
/// - M3 SegmentedButton styling with Material You dynamic color support.
/// - Minimum 48x48dp touch targets for mobile-first accessibility.
/// - Single-column responsive layout compatibility (<600dp).
/// - Local mock data integration for standalone operation without backend.
class BillingFrequencySegmentedButton extends StatefulWidget {
  /// Callback triggered when the user selects a different billing frequency.
  final ValueChanged<BillingFrequency>? onFrequencySelected;

  /// Initial selected frequency. Defaults to [BillingFrequencyMockData.defaultFrequency].
  final BillingFrequency initialFrequency;

  /// Whether the segmented button is enabled for interaction.
  final bool isEnabled;

  const BillingFrequencySegmentedButton({
    super.key,
    this.onFrequencySelected,
    this.initialFrequency = BillingFrequency.defaultFrequency,
    this.isEnabled = true,
  });

  @override
  State<BillingFrequencySegmentedButton> createState() => _BillingFrequencySegmentedButtonState();
}

class _BillingFrequencySegmentedButtonState extends State<BillingFrequencySegmentedButton> {
  late Set<BillingFrequency> _selectedFrequency;

  @override
  void initState() {
    super.initState();
    _selectedFrequency = {widget.initialFrequency};
  }

  @override
  void didUpdateWidget(covariant BillingFrequencySegmentedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFrequency != widget.initialFrequency) {
      setState(() {
        _selectedFrequency = {widget.initialFrequency};
      });
    }
  }

  void _handleSelectionChanged(Set<BillingFrequency> newSelection) {
    if (newSelection.isEmpty) return;

    setState(() {
      _selectedFrequency = newSelection;
    });

    final selected = newSelection.first;
    widget.onFrequencySelected?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Recurring billing frequency selector',
      hint: 'Select between weekly or monthly billing frequency',
      container: true,
      child: ConstrainedBox(
        // Enforce minimum 48dp height for touch target compliance
        constraints: const BoxConstraints(minHeight: 48.0),
        child: SegmentedButton<BillingFrequency>(
          segments: BillingFrequencyMockData.availableFrequencies
              .map(
                (frequency) => ButtonSegment<BillingFrequency>(
                  value: frequency,
                  label: Text(
                    frequency.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: _selectedFrequency.contains(frequency)
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  icon: Icon(
                    frequency == BillingFrequency.weekly
                        ? Icons.calendar_view_week_rounded
                        : Icons.calendar_month_rounded,
                    size: 20.0,
                  ),
                ),
              )
              .toList(),
          selected: _selectedFrequency,
          onSelectionChanged: widget.isEnabled ? _handleSelectionChanged : null,
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
          showSelectedIcon: false,
          style: ButtonStyle(
            // Ensure 48x48dp minimum touch targets
            minimumSize: WidgetStateProperty.all(const Size(48.0, 48.0)),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.secondaryContainer;
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.onSecondaryContainer;
              }
              if (states.contains(WidgetState.disabled)) {
                return colorScheme.onSurface.withOpacity(0.38);
              }
              return colorScheme.onSurface;
            }),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.onSecondaryContainer.withOpacity(0.08);
              }
              return colorScheme.onSurface.withOpacity(0.08);
            }),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: colorScheme.outline,
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Preview wrapper demonstrating the component in an M3 Elevated Card
/// with single-column mobile layout (<600dp) as per requirements.
class BillingFrequencyCardPreview extends StatelessWidget {
  const BillingFrequencyCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sync_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24.0,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Recurring Billing Frequency',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    // M3 Status Chip for health indicator
                    Chip(
                      avatar: const Icon(Icons.check_circle_outline, size: 16.0),
                      label: const Text('Active'),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      labelStyle: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Select how often you would like to be billed.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24.0),
                Center(
                  child: BillingFrequencySegmentedButton(
                    onFrequencySelected: (frequency) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Billing frequency set to ${frequency.label}'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}