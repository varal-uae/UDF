/*
 * STEP 4: RRCVG-024 — Enforce Binary Checklist Stepper Offboarding Rules
 * 
 * Setup Step (Action): Analyze complex multi-system offboarding manuals provided by Tech, OPS, and HRE teams.
 * Setup Step Description: Define offboarding items, map tool toggles, build vertical stepper UI, code final gate logic.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Auto-advancing to the next step upon successful toggle interaction.
 *   - Clear completed (checkmark) and pending (number) step indicators.
 *   - Smooth accordion expansions and mobile-friendly vertical stepper structure.
 * 
 * What Was Done to Complete This Step:
 *   - Created `BinaryChecklistStepper` widget and `OffboardingStepItem` model in a single file.
 *   - Implemented vertical step progression, interactive toggles, auto-advancing focus, and hard-locked final submission gate.
 */

import 'package:flutter/material.dart';
import '../tokens/spacing_tokens.dart';

class OffboardingStepItem {
  final String id;
  final String title;
  final String description;
  final String targetSystem;
  final bool isCompleted;

  const OffboardingStepItem({
    required this.id,
    required this.title,
    required this.description,
    required this.targetSystem,
    this.isCompleted = false,
  });

  OffboardingStepItem copyWith({bool? isCompleted}) {
    return OffboardingStepItem(
      id: id,
      title: title,
      description: description,
      targetSystem: targetSystem,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Step RRCVG-024: Binary Checklist Stepper for Offboarding Rules.
class BinaryChecklistStepper extends StatefulWidget {
  final List<OffboardingStepItem> initialSteps;
  final ValueChanged<List<OffboardingStepItem>>? onCompletedChanged;

  const BinaryChecklistStepper({
    super.key,
    required this.initialSteps,
    this.onCompletedChanged,
  });

  @override
  State<BinaryChecklistStepper> createState() => _BinaryChecklistStepperState();
}

class _BinaryChecklistStepperState extends State<BinaryChecklistStepper> {
  late List<OffboardingStepItem> _steps;
  int _activeStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _steps = List.from(widget.initialSteps);
  }

  bool get _isAllCompleted => _steps.every((s) => s.isCompleted);

  void _toggleStep(int index, bool value) {
    setState(() {
      _steps[index] = _steps[index].copyWith(isCompleted: value);
      if (value && index < _steps.length - 1) {
        _activeStepIndex = index + 1; // Auto-advance to next step
      }
    });

    widget.onCompletedChanged?.call(_steps);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Stepper(
          currentStep: _activeStepIndex,
          onStepTapped: (idx) => setState(() => _activeStepIndex = idx),
          controlsBuilder: (context, details) => const SizedBox.shrink(),
          steps: _steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;

            return Step(
              title: Text(item.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('System: ${item.targetSystem}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              isActive: idx == _activeStepIndex,
              state: item.isCompleted ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.description, style: theme.textTheme.bodyMedium),
                  AppSpacingTokens.vGapSm,
                  Row(
                    children: [
                      Text('Revoke Access:', style: theme.textTheme.labelMedium),
                      AppSpacingTokens.hGapSm,
                      Switch(
                        value: item.isCompleted,
                        onChanged: (val) => _toggleStep(idx, val),
                      ),
                      AppSpacingTokens.hGapSm,
                      Text(item.isCompleted ? 'YES (Revoked)' : 'NO (Active Risk)',
                          style: TextStyle(
                            color: item.isCompleted ? colorScheme.primary : colorScheme.error,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        AppSpacingTokens.vGapMd,
        Card(
          color: _isAllCompleted ? colorScheme.primaryContainer : colorScheme.errorContainer.withValues(alpha: 0.2),
          child: Padding(
            padding: AppSpacingTokens.paddingMd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _isAllCompleted ? '100% Revocation Confirmed' : 'Offboarding Gate Locked: Active Access Risks Remain',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isAllCompleted ? colorScheme.onPrimaryContainer : colorScheme.error,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _isAllCompleted
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Offboarding successfully completed!')),
                          );
                        }
                      : null, // Hard-locked gate until 100% complete
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Complete Offboarding'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
