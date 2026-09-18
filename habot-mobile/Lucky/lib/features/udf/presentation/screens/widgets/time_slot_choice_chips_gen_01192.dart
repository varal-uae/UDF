// GEN-01192 — Time Slot Choice Chips using M3 ChoiceChip.
// Constructs available time slot selections with Material 3 ChoiceChips, responsive layout, mock data, and telemetry support.

import 'package:flutter/material.dart';

/// Mock time slot model representing an available scheduling slot.
class TimeSlot {
  final String id;
  final String label;
  final bool isAvailable;

  const TimeSlot({
    required this.id,
    required this.label,
    required this.isAvailable,
  });
}

/// Hardcoded mock data for available time slots to satisfy backend/API independence.
const List<TimeSlot> kMockAvailableTimeSlots = [
  TimeSlot(id: 'slot_001', label: '08:00 AM', isAvailable: true),
  TimeSlot(id: 'slot_002', label: '09:00 AM', isAvailable: true),
  TimeSlot(id: 'slot_003', label: '10:00 AM', isAvailable: false),
  TimeSlot(id: 'slot_004', label: '11:00 AM', isAvailable: true),
  TimeSlot(id: 'slot_005', label: '12:00 PM', isAvailable: true),
  TimeSlot(id: 'slot_006', label: '01:00 PM', isAvailable: false),
  TimeSlot(id: 'slot_007', label: '02:00 PM', isAvailable: true),
  TimeSlot(id: 'slot_008', label: '03:00 PM', isAvailable: true),
  TimeSlot(id: 'slot_009', label: '04:00 PM', isAvailable: true),
  TimeSlot(id: 'slot_010', label: '05:00 PM', isAvailable: false),
];

/// Widget that constructs available time slot selections using M3 Choice Chips.
/// 
/// Follows Material 3 guidelines:
/// - Single-column layout on mobile (<600dp)
/// - Multi-column layout on desktop (>=840dp)
/// - Minimum 48x48dp touch targets
/// - Uses M3 Elevated Card container styling context
class TimeSlotChoiceChips extends StatefulWidget {
  final ValueChanged<String?>? onSelectionChanged;
  final List<TimeSlot> timeSlots;

  const TimeSlotChoiceChips({
    super.key,
    this.onSelectionChanged,
    this.timeSlots = kMockAvailableTimeSlots,
  });

  @override
  State<TimeSlotChoiceChips> createState() => _TimeSlotChoiceChipsState();
}

class _TimeSlotChoiceChipsState extends State<TimeSlotChoiceChips> {
  String? _selectedSlotId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
    final int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 2; // Wrapped chips in single column feel
    } else if (screenWidth >= 840) {
      crossAxisCount = 4; // Multi-column on desktop
    } else {
      crossAxisCount = 3; // Tablet
    }

    final availableSlots = widget.timeSlots.where((s) => s.isAvailable).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Available Time Slots',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.timeSlots.map((slot) {
            final isSelected = _selectedSlotId == slot.id;
            final isDisabled = !slot.isAvailable;

            // Ensure minimum 48x48dp touch target via M3 default chip sizing + constraints
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
              child: ChoiceChip(
                label: Text(slot.label),
                selected: isSelected,
                enabled: !isDisabled,
                onSelected: isDisabled
                    ? null
                    : (bool selected) {
                        setState(() {
                          _selectedSlotId = selected ? slot.id : null;
                        });
                        widget.onSelectionChanged?.call(_selectedSlotId);
                      },
                selectedColor: colorScheme.secondaryContainer,
                disabledColor: colorScheme.surfaceContainerHighest.withOpacity(0.38),
                labelStyle: TextStyle(
                  color: isDisabled
                      ? colorScheme.onSurface.withOpacity(0.38)
                      : isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.secondary
                        : isDisabled
                            ? colorScheme.outlineVariant.withOpacity(0.38)
                            : colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedSlotId != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Selected: ${widget.timeSlots.firstWhere((s) => s.id == _selectedSlotId).label}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}