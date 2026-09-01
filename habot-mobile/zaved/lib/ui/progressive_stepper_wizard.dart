// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Architecture Pattern: Progressive Stepper Wizard with 200ms Animation Lock
// Component Hierarchy: ProgressiveStepperWizard -> AnimatedSwitcher -> StepCard -> ActionRow
// Motion & Animation System: 200ms Slide Transition + 5s Inactivity Chaser Pulse
// Accessibility: Reduced Motion Bypass (MediaQuery.disableAnimations)
// Completion Status: Complete (Ref: REF-377-A12)
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';

/// Step Model for Progressive Stepper Wizard
class WizardStepItem {
  final String id;
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final Widget content;

  const WizardStepItem({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.content,
  });
}

/// REF-377-A12: Progressive Stepper Wizard
/// Features:
/// 1. 200ms Animation Lock (Poka-Yoke): During transition, Next and Previous
///    buttons are physically disabled (onPressed: null) to eliminate double-clicks.
/// 2. The Chaser Pulse (UX): Inactivity timer triggers after 5 seconds of stalling,
///    wrapping the Next button in a subtle pulsing animation.
/// 3. Reduced Motion Support: Reads MediaQuery.disableAnimations to transition instantly.
/// 4. DOM Unmounting: Offscreen steps are unmounted automatically.
class ProgressiveStepperWizard extends StatefulWidget {
  final VoidCallback? onCompleted;

  const ProgressiveStepperWizard({
    super.key,
    this.onCompleted,
  });

  @override
  State<ProgressiveStepperWizard> createState() =>
      _ProgressiveStepperWizardState();
}

class _ProgressiveStepperWizardState extends State<ProgressiveStepperWizard>
    with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  bool _isAnimating = false;
  bool _isTransitionForward = true;
  int _completedStepsCount = 0;

  // Inactivity / Chaser Pulse Controller
  Timer? _inactivityTimer;
  late final AnimationController _chaserController;
  late final Animation<double> _chaserScaleAnimation;

  // Form State Demo variables
  String _selectedRole = 'Operator';
  String _selectedRegion = 'North America (us-east-1)';
  bool _acknowledgementChecked = false;

  @override
  void initState() {
    super.initState();

    // Chaser Pulse: subtle scale between 1.0x and 1.07x
    _chaserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chaserScaleAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(
        parent: _chaserController,
        curve: Curves.easeInOut,
      ),
    );

    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _chaserController.dispose();
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_chaserController.isAnimating) {
      _chaserController.stop();
      _chaserController.reset();
    }
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isAnimating) {
        _chaserController.repeat(reverse: true);
      }
    });
  }

  List<WizardStepItem> _buildSteps() {
    return [
      WizardStepItem(
        id: 'STEP-101',
        stepNumber: '01',
        title: 'Identity Verification & Role',
        description: 'Select your operational role to provision security scopes.',
        icon: Icons.badge_outlined,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Security Role',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Operator', 'Field Supervisor', 'Security Auditor']
                  .map((role) => ChoiceChip(
                        label: Text(role),
                        selected: _selectedRole == role,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRole = role);
                            _resetInactivityTimer();
                          }
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Assigned Scope: $_selectedRole with Poka-Yoke Level 2 enforcement.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      WizardStepItem(
        id: 'STEP-102',
        stepNumber: '02',
        title: 'Infrastructure Zone Allocation',
        description: 'Designate the target low-latency region for workload routing.',
        icon: Icons.cloud_queue_outlined,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Deployment Region',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRegion,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              items: [
                'North America (us-east-1)',
                'Europe (eu-central-1)',
                'Asia Pacific (ap-south-1)',
                'Latin America (sa-east-1)',
              ]
                  .map((region) => DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedRegion = val);
                  _resetInactivityTimer();
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.speed, size: 16, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Estimated latency: 24ms (High-availability tier)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      WizardStepItem(
        id: 'STEP-103',
        stepNumber: '03',
        title: 'Validation & Gate Clearance',
        description: 'Review system constraints and clear deployment authorization.',
        icon: Icons.check_circle_outline,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _acknowledgementChecked,
              onChanged: (val) {
                setState(() => _acknowledgementChecked = val ?? false);
                _resetInactivityTimer();
              },
              title: const Text(
                'I verify that all inputs comply with strict WCAG AAA and design system tokens.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'State locks will release upon final confirmation.',
                style: TextStyle(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_clock,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Poka-Yoke Status: 200ms lock active on transitions. Inactivity chaser triggers at 5s.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  void _navigateToStep(int targetIndex, bool isForward) {
    final steps = _buildSteps();
    if (_isAnimating || targetIndex < 0 || targetIndex >= steps.length) {
      return;
    }

    _resetInactivityTimer();

    final bool reducedMotion = MediaQuery.of(context).disableAnimations;

    if (reducedMotion) {
      // Instant transition when user prefers reduced motion
      setState(() {
        _isTransitionForward = isForward;
        _currentStepIndex = targetIndex;
        if (targetIndex > _completedStepsCount) {
          _completedStepsCount = targetIndex;
        }
      });
      return;
    }

    // Lock interactions during the exact 200ms slide animation (Poka-Yoke)
    setState(() {
      _isAnimating = true;
      _isTransitionForward = isForward;
      _currentStepIndex = targetIndex;
      if (targetIndex > _completedStepsCount) {
        _completedStepsCount = targetIndex;
      }
    });

    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
        _resetInactivityTimer();
      }
    });
  }

  void _handleNext() {
    final steps = _buildSteps();
    if (_currentStepIndex < steps.length - 1) {
      _navigateToStep(_currentStepIndex + 1, true);
    } else {
      _inactivityTimer?.cancel();
      _chaserController.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Progressive Stepper Wizard Completed Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onCompleted?.call();
    }
  }

  void _handlePrevious() {
    if (_currentStepIndex > 0) {
      _navigateToStep(_currentStepIndex - 1, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool reducedMotion = MediaQuery.of(context).disableAnimations;
    final Duration duration =
        reducedMotion ? Duration.zero : const Duration(milliseconds: 200);

    final steps = _buildSteps();
    final currentStep = steps[_currentStepIndex];
    final bool isLastStep = _currentStepIndex == steps.length - 1;

    return Container(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header & Progress Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROGRESSIVE STEPPER WIZARD',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Step ${currentStep.stepNumber} of ${steps.length}: ${currentStep.title}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isAnimating
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAnimating ? Icons.lock : Icons.lock_open,
                      size: 14,
                      color: _isAnimating
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isAnimating ? '200ms Lock Active' : 'Interactions Ready',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isAnimating
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear Step Indicator Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStepIndex + 1) / steps.length,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),

          // Animated Switcher with 200ms Slide Transition (Previous Step Unmounted)
          AnimatedSwitcher(
            duration: duration,
            switchInCurve: Curves.easeOutQuad,
            switchOutCurve: Curves.easeInQuad,
            transitionBuilder: (child, animation) {
              if (reducedMotion) return child;

              final isIncoming =
                  (child.key as ValueKey<int>).value == _currentStepIndex;
              final inOffset = _isTransitionForward
                  ? const Offset(1.0, 0.0)
                  : const Offset(-1.0, 0.0);
              final outOffset = _isTransitionForward
                  ? const Offset(-1.0, 0.0)
                  : const Offset(1.0, 0.0);

              final offsetTween = isIncoming
                  ? Tween<Offset>(begin: inOffset, end: Offset.zero)
                  : Tween<Offset>(begin: Offset.zero, end: outOffset);

              return SlideTransition(
                position: offsetTween.animate(animation),
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentStepIndex),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.onPrimaryContainer,
                            child: Icon(currentStep.icon, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentStep.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currentStep.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      currentStep.content,
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Poka-Yoke Navigation Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  // Physically disabled during 200ms transition lock or when on first step
                  onPressed: (_isAnimating || _currentStepIndex == 0)
                      ? null
                      : _handlePrevious,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ScaleTransition(
                  scale: _chaserScaleAnimation,
                  child: ElevatedButton.icon(
                    // Physically disabled during 200ms transition lock
                    onPressed: _isAnimating ? null : _handleNext,
                    icon: Icon(
                      isLastStep ? Icons.check_circle : Icons.arrow_forward,
                    ),
                    label: Text(
                      isLastStep ? 'Complete Wizard' : 'Next Step',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Center(
            child: Text(
              reducedMotion
                  ? '♿ Reduced motion active: Slide animations bypassed.'
                  : '⚡ 200ms lock prevents double clicks | 5s inactivity chaser pulse active.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
