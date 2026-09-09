// BPTR-0437-A04 — Mobile Wizard Binary Checklist Stepper.
// Initializes a Material 3 horizontal wizard layout that enforces linear, one-at-a-time progression and disables completion until every binary toggle reads 'Yes'.

import 'package:flutter/material.dart';

class WizardChecklistStepItem {
  const WizardChecklistStepItem({required this.label, this.description});
  final String label;
  final String? description;
}

class MobileWizardChecklistStepper extends StatefulWidget {
  const MobileWizardChecklistStepper({
    super.key,
    required this.steps,
    this.onComplete,
    this.nextLabel = 'Next',
    this.backLabel = 'Back',
    this.completeLabel = 'Complete',
  }) : assert(steps.length > 0);

  final List<WizardChecklistStepItem> steps;
  final VoidCallback? onComplete;
  final String nextLabel;
  final String backLabel;
  final String completeLabel;

  @override
  State<MobileWizardChecklistStepper> createState() => _MobileWizardChecklistStepperState();
}

class _MobileWizardChecklistStepperState extends State<MobileWizardChecklistStepper> {
  late final PageController _pageController;
  int _currentStep = 0;
  late final List<bool?> _answers;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _answers = List<bool?>.filled(widget.steps.length, null);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isCurrentConfirmed => _answers[_currentStep] == true;
  bool get _allConfirmed => _answers.every((answer) => answer == true);

  void _goToStep(int target) {
    if (target < 0 || target >= widget.steps.length || target == _currentStep) return;
    if (target > _currentStep && !_isCurrentConfirmed) return;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _setAnswer(int index, bool value) {
    setState(() {
      _answers[index] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Step ${_currentStep + 1} of ${widget.steps.length}',
          style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentStep + 1) / widget.steps.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.steps.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isActive = index == _currentStep;
              final isConfirmed = _answers[index] == true;
              return CircleAvatar(
                radius: 16,
                backgroundColor: isConfirmed
                    ? colorScheme.primary
                    : isActive
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                child: Icon(
                  isConfirmed ? Icons.check : Icons.circle_outlined,
                  size: 16,
                  color: isConfirmed ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: _isCurrentConfirmed ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemCount: widget.steps.length,
            onPageChanged: (index) => setState(() => _currentStep = index),
            itemBuilder: (context, index) {
              final step = widget.steps[index];
              final answer = _answers[index];
              final isRiskOpen = answer != true;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.label, style: theme.textTheme.titleLarge),
                    if (step.description != null) ...[
                      const SizedBox(height: 8),
                      Text(step.description!, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Select Yes to clear this step.',
                      style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    ToggleButtons<bool>(
                      isSelected: [answer == true, answer == false],
                      onPressed: (option) => _setAnswer(index, option == 0),
                      borderRadius: BorderRadius.circular(12),
                      selectedColor: colorScheme.onPrimary,
                      fillColor: colorScheme.primary,
                      color: colorScheme.onSurfaceVariant,
                      constraints: const BoxConstraints(minWidth: 96, minHeight: 48),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Yes'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('No'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isRiskOpen)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: colorScheme.onErrorContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Active Risk — complete this step before moving forward.',
                                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: () => _goToStep(_currentStep - 1),
                  child: Text(widget.backLabel),
                )
              else
                const SizedBox.shrink(),
              const Spacer(),
              if (_currentStep < widget.steps.length - 1)
                FilledButton.tonal(
                  onPressed: _isCurrentConfirmed ? () => _goToStep(_currentStep + 1) : null,
                  child: Text(widget.nextLabel),
                )
              else
                FilledButton(
                  onPressed: _allConfirmed ? widget.onComplete : null,
                  child: Text(widget.completeLabel),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
