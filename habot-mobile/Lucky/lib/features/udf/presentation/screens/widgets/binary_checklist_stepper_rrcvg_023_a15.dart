// RRCVG-023-A15 — Binary Checklist Stepper Component.
// Interactive multi-step vertical checklist stepper with binary toggles, navigation blocking, and poka-yoke completion enforcement.

import 'package:flutter/material.dart';

/// Mock data representing atomic-level checklist items for offboarding verification.
class ChecklistItem {
  final String id;
  final String label;
  final String description;
  bool isCompleted;

  ChecklistItem({
    required this.id,
    required this.label,
    required this.description,
    this.isCompleted = false,
  });
}

/// Mock repository providing initial checklist state.
class MockChecklistRepository {
  static List<ChecklistItem> getInitialItems() {
    return [
      ChecklistItem(
        id: 'SYS_001',
        label: 'Revoke Active Directory Access',
        description: 'Disable user account in corporate AD.',
      ),
      ChecklistItem(
        id: 'SYS_002',
        label: 'Remove Email Forwarding Rules',
        description: 'Clear all automated forwarding configurations.',
      ),
      ChecklistItem(
        id: 'SYS_003',
        label: 'Deactivate ERP Credentials',
        description: 'Invalidate tokens for finance and operations systems.',
      ),
      ChecklistItem(
        id: 'SYS_004',
        label: 'Collect Physical Assets',
        description: 'Confirm return of laptop, badge, and keys.',
      ),
      ChecklistItem(
        id: 'SYS_005',
        label: 'Final Security Sign-off',
        description: 'Ops lead confirms zero residual access vectors.',
      ),
    ];
  }
}

class BinaryChecklistStepper extends StatefulWidget {
  const BinaryChecklistStepper({super.key});

  @override
  State<BinaryChecklistStepper> createState() => _BinaryChecklistStepperState();
}

class _BinaryChecklistStepperState extends State<BinaryChecklistStepper> {
  late List<ChecklistItem> _items;
  int _currentStep = 0;

  // Design token for success color as specified in requirements
  static const Color _successColor = Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();
    _items = MockChecklistRepository.getInitialItems();
  }

  bool get _allCompleted => _items.every((item) => item.isCompleted);

  void _onToggleChanged(int index, bool value) {
    setState(() {
      _items[index].isCompleted = value;
      // Auto-advance if current step is completed and not the last step
      if (value && _currentStep < _items.length - 1) {
        _currentStep = index + 1;
      }
    });
  }

  void _goToNextStep() {
    if (_currentStep < _items.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastStep = _currentStep == _items.length - 1;
    final canProceed = _items[_currentStep].isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offboarding Verification'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final isCurrent = index == _currentStep;
                  final isPast = index < _currentStep;
                  final isFuture = index > _currentStep;

                  // Navigation blocking: future steps are visually dimmed and non-interactive
                  final bool isInteractive = !isFuture;

                  return Opacity(
                    opacity: isFuture ? 0.4 : 1.0,
                    child: IgnorePointer(
                      ignoring: isFuture,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          elevation: isCurrent ? 2.0 : 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : item.isCompleted
                                      ? _successColor
                                      : theme.colorScheme.outlineVariant,
                              width: isCurrent ? 2.0 : 1.0,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            leading: _buildStepIndicator(index, item, theme),
                            title: Text(
                              item.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isFuture ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                item.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isFuture
                                      ? theme.colorScheme.onSurface.withOpacity(0.3)
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: Switch(
                              value: item.isCompleted,
                              activeColor: _successColor,
                              activeTrackColor: _successColor.withOpacity(0.3),
                              onChanged: isInteractive
                                  ? (val) => _onToggleChanged(index, val)
                                  : null,
                            ),
                            onTap: isInteractive
                                ? () {
                                    setState(() {
                                      _currentStep = index;
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildBottomControls(theme, isLastStep, canProceed),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int index, ChecklistItem item, ThemeData theme) {
    if (item.isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _successColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: _successColor,
          size: 24,
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline, width: 1.5),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${index + 1}',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomControls(ThemeData theme, bool isLastStep, bool canProceed) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: _currentStep > 0 ? _goToPreviousStep : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          ),
          if (!isLastStep)
            FilledButton.icon(
              onPressed: canProceed ? _goToNextStep : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Step'),
            )
          else
            // Poka-Yoke: Final button visually disabled until every single toggle reads "Yes"
            FilledButton.icon(
              onPressed: _allCompleted
                  ? () {
                      // Trigger final pipeline data event / completion action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Offboarding completed successfully.'),
                          backgroundColor: _successColor,
                        ),
                      );
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: _allCompleted ? _successColor : theme.colorScheme.surfaceContainerHighest,
                foregroundColor: _allCompleted ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.38),
                disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
              ),
              icon: const Icon(Icons.task_alt),
              label: const Text('Complete Offboarding'),
            ),
        ],
      ),
    );
  }
}
