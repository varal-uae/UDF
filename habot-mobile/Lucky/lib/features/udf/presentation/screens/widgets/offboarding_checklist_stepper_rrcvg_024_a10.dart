// RRCVG-024-A10 — Offboarding Checklist Stepper Component.
// A vertical stepper guiding admins through binary tool-by-tool access revocation with auto-advance, severity badges, and a disabled completion button until all toggles are confirmed.

import 'package:flutter/material.dart';

/// Mock data representing backend API response for offboarding steps.
class _MockOffboardingRepository {
  static List<OffboardingStep> fetchSteps() {
    return [
      OffboardingStep(
        stepExecutionId: 'EXEC-001',
        title: 'Revoke Email Access',
        description: 'Disable corporate email and calendar integrations.',
        isCritical: true,
      ),
      OffboardingStep(
        stepExecutionId: 'EXEC-002',
        title: 'Revoke IAM / SSO Access',
        description: 'Remove user from Single Sign-On identity provider.',
        isCritical: true,
      ),
      OffboardingStep(
        stepExecutionId: 'EXEC-003',
        title: 'Revoke Slack / Teams Access',
        description: 'Deactivate messaging platform accounts.',
        isCritical: false,
      ),
      OffboardingStep(
        stepExecutionId: 'EXEC-004',
        title: 'Revoke Cloud Infrastructure (GCP/AWS)',
        description: 'Terminate cloud console permissions and service accounts.',
        isCritical: true,
      ),
      OffboardingStep(
        stepExecutionId: 'EXEC-005',
        title: 'Revoke HRIS Portal Access',
        description: 'Remove access to payroll and benefits systems.',
        isCritical: false,
      ),
    ];
  }
}

class OffboardingStep {
  final String stepExecutionId;
  final String title;
  final String description;
  final bool isCritical;

  OffboardingStep({
    required this.stepExecutionId,
    required this.title,
    required this.description,
    required this.isCritical,
  });
}

class OffboardingChecklistStepper extends StatefulWidget {
  const OffboardingChecklistStepper({super.key});

  @override
  State<OffboardingChecklistStepper> createState() =>
      _OffboardingChecklistStepperState();
}

class _OffboardingChecklistStepperState
    extends State<OffboardingChecklistStepper> {
  late final List<OffboardingStep> _steps;
  late final Map<String, bool> _toggleStates;
  int _activeStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _steps = _MockOffboardingRepository.fetchSteps();
    _toggleStates = {for (var step in _steps) step.stepExecutionId: false};
  }

  bool get _allTogglesCompleted =>
      _toggleStates.values.every((isOn) => isOn);

  double get _completionPercentage {
    if (_steps.isEmpty) return 0.0;
    final completed = _toggleStates.values.where((isOn) => isOn).length;
    return completed / _steps.length;
  }

  Color _getSeverityColor(BuildContext context) {
    final theme = Theme.of(context);
    if (_completionPercentage >= 0.99) return Colors.green;
    if (_completionPercentage >= 0.95) return theme.colorScheme.primary;
    if (_completionPercentage >= 0.50) return Colors.orange;
    return theme.colorScheme.error;
  }

  void _handleToggle(String stepId, bool value) {
    setState(() {
      _toggleStates[stepId] = value;
      if (value && _activeStepIndex < _steps.length - 1) {
        // Auto-advance to next step upon successful toggle interaction
        _activeStepIndex++;
      }
    });
  }

  void _completeOffboarding() {
    if (!_allTogglesCompleted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Offboarding completed successfully. All access revoked.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offboarding Checklist'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              label: Text(
                '${(_completionPercentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _getSeverityColor(context).withOpacity(0.2),
              side: BorderSide(color: _getSeverityColor(context)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final isCompleted = _toggleStates[step.stepExecutionId] ?? false;
                final isActive = index == _activeStepIndex;

                return _ChecklistStepperTile(
                  stepNumber: index + 1,
                  step: step,
                  isCompleted: isCompleted,
                  isActive: isActive,
                  onToggleChanged: (val) =>
                      _handleToggle(step.stepExecutionId, val),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _allTogglesCompleted ? _completeOffboarding : null,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _allTogglesCompleted ? colorScheme.primary : colorScheme.surfaceVariant,
                    foregroundColor:
                        _allTogglesCompleted ? colorScheme.onPrimary : colorScheme.onSurfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Complete Offboarding',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistStepperTile extends StatelessWidget {
  final int stepNumber;
  final OffboardingStep step;
  final bool isCompleted;
  final bool isActive;
  final ValueChanged<bool> onToggleChanged;

  const _ChecklistStepperTile({
    required this.stepNumber,
    required this.step,
    required this.isCompleted,
    required this.isActive,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.green
              : isActive
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
          width: isCompleted || isActive ? 2.0 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ExpansionTile(
        initiallyExpanded: isActive,
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: _buildIndicator(context),
        title: Row(
          children: [
            Expanded(
              child: Text(
                step.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? colorScheme.onSurface.withOpacity(0.6) : colorScheme.onSurface,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (step.isCritical)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'CRITICAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Switch(
          value: isCompleted,
          activeColor: Colors.green,
          onChanged: onToggleChanged,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                step.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isCompleted) {
      return CircleAvatar(
        backgroundColor: Colors.green,
        radius: 14,
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    }
    return CircleAvatar(
      backgroundColor: isActive ? colorScheme.primaryContainer : colorScheme.surfaceVariant,
      radius: 14,
      child: Text(
        '$stepNumber',
        style: TextStyle(
          color: isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
