// RRCVG-023-A08 — Binary Checklist Stepper Component.
// Implements a vertical stepper with strict Pass/Fail binary validation controls, navigation blocking, and mobile-first layout.

import 'package:flutter/material.dart';

/// Represents the outcome of a single checklist step.
enum StepOutcome { pending, pass, fail }

/// Data model for an individual atomic step in the checklist.
class ChecklistStepData {
  final String executionId;
  final String title;
  final String description;
  StepOutcome outcome;
  final DateTime timestamp;
  final String userId;

  ChecklistStepData({
    required this.executionId,
    required this.title,
    required this.description,
    this.outcome = StepOutcome.pending,
    DateTime? timestamp,
    this.userId = 'MOCK_USER_001',
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Mock data repository simulating backend API trace metrics.
class MockChecklistRepository {
  static List<ChecklistStepData> fetchSteps() {
    return [
      ChecklistStepData(
        executionId: 'EXEC-001',
        title: 'Revoke Active Directory Access',
        description: 'Disable user account in corporate AD.',
      ),
      ChecklistStepData(
        executionId: 'EXEC-002',
        title: 'Revoke Email Provisioning',
        description: 'Suspend Exchange Online mailbox and forwarding rules.',
      ),
      ChecklistStepData(
        executionId: 'EXEC-003',
        title: 'Remove MFA Registrations',
        description: 'Clear all registered authenticator apps and hardware keys.',
      ),
      ChecklistStepData(
        executionId: 'EXEC-004',
        title: 'Revoke Cloud IAM Roles',
        description: 'Remove GCP/AWS IAM bindings associated with the user.',
      ),
      ChecklistStepData(
        executionId: 'EXEC-005',
        title: 'Collect Physical Assets',
        description: 'Verify return of laptop, badge, and security tokens.',
      ),
    ];
  }
}

/// Interactive multi-step checklist stepper component.
/// Enforces linear progression and disables completion until all steps pass.
class BinaryChecklistStepper extends StatefulWidget {
  const BinaryChecklistStepper({super.key});

  @override
  State<BinaryChecklistStepper> createState() => _BinaryChecklistStepperState();
}

class _BinaryChecklistStepperState extends State<BinaryChecklistStepper> {
  late List<ChecklistStepData> _steps;
  int _currentActiveIndex = 0;

  // Design token for success color as per requirement (#2ECC71)
  static const Color _successColor = Color(0xFF2ECC71);
  static const Color _errorColor = Colors.redAccent;
  static const Color _pendingColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _steps = MockChecklistRepository.fetchSteps();
  }

  bool get _isAllPassed =>
      _steps.every((step) => step.outcome == StepOutcome.pass);

  void _updateStepOutcome(int index, StepOutcome outcome) {
    setState(() {
      _steps[index].outcome = outcome;
      // Auto-advance if passed and not the last step
      if (outcome == StepOutcome.pass && index < _steps.length - 1) {
        _currentActiveIndex = index + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offboarding Verification'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final isAccessible = index <= _currentActiveIndex;
                final isCompleted = step.outcome == StepOutcome.pass;
                final isFailed = step.outcome == StepOutcome.fail;
                final isLast = index == _steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vertical Progress Line & Indicator
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? _successColor
                                  : isFailed
                                      ? _errorColor
                                      : isAccessible
                                          ? theme.colorScheme.primaryContainer
                                          : _pendingColor.withOpacity(0.3),
                              border: Border.all(
                                color: isAccessible
                                    ? theme.colorScheme.primary
                                    : _pendingColor,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isCompleted
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : isFailed
                                    ? const Icon(Icons.close, color: Colors.white, size: 18)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: isAccessible ? theme.colorScheme.onPrimaryContainer : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 60,
                              color: isCompleted ? _successColor : _pendingColor.withOpacity(0.4),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Flexible Data Card
                    Expanded(
                      child: Card(
                        elevation: isAccessible ? 1.0 : 0.0,
                        color: isAccessible ? null : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isCompleted
                                ? _successColor
                                : isFailed
                                    ? _errorColor
                                    : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isAccessible ? null : _pendingColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isAccessible ? theme.colorScheme.onSurfaceVariant : _pendingColor,
                                ),
                                softWrap: true,
                              ),
                              if (isAccessible) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: step.outcome == StepOutcome.pass
                                            ? null
                                            : () => _updateStepOutcome(index, StepOutcome.pass),
                                        icon: const Icon(Icons.check_circle_outline),
                                        label: const Text('Pass'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _successColor,
                                          side: const BorderSide(color: _successColor),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: step.outcome == StepOutcome.pass
                                            ? null
                                            : () => _updateStepOutcome(index, StepOutcome.fail),
                                        icon: const Icon(Icons.cancel_outlined),
                                        label: const Text('Fail'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _errorColor,
                                          side: const BorderSide(color: _errorColor),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Complete previous steps to unlock.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _pendingColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Bottom Action Bar
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAllPassed
                      ? () {
                          // Trigger final pipeline data event / complete offboarding
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Offboarding Completed Successfully.'),
                              backgroundColor: _successColor,
                            ),
                          );
                        }
                      : null, // Visually disabled until every toggle reads Yes/Pass
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    disabledBackgroundColor: _pendingColor.withOpacity(0.3),
                    disabledForegroundColor: _pendingColor,
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