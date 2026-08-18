/// AISS: FIEVR-033-A01 -- "Build Multi-Step Guided Carousel Layout Stepper."
///
/// Substep 2: "Build an atomic horizontal stepper container under 20 lines of
///             total functional code."
/// Substep 3: "Program smooth transition animations to glide form steps left or
///             right cleanly during navigation."
/// Substep 4: "Code an integrated bottom layout progress dot row to show users
///             their step counts instantly."
///
/// Completion Measure: "Forms glide across steps cleanly in under 200ms, with
/// progress indicator bars updating accurately."
///
/// UI implementation row: "Automatically close system keyboards during slide
/// transitions to keep interfaces clean."
/// REF-377 Poka-Yoke: "Unmounts previous steps from DOM to prevent accidental
/// back-edits" -- only the active step is built, so an off-screen field cannot
/// be edited or focused.
library;

import 'package:flutter/material.dart';

import '../forms/form_gate.dart';
import '../interaction/atomic_button.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'step_machine.dart';

/// The atomic horizontal stepper container.
class CarouselStepper extends StatelessWidget {
  const CarouselStepper({
    required this.machine,
    required this.stepBuilder,
    super.key,
  });

  final WizardStepMachine machine;
  final Widget Function(BuildContext, WizardStep) stepBuilder;

  // BUILD-BUDGET: FIEVR-033 substep 2 caps this method at 20 lines.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: machine,
      builder: (BuildContext context, Widget? _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          StepSlideTransition(
            index: machine.index,
            // Only the active step exists -- REF-377 poka-yoke.
            child: stepBuilder(context, machine.current),
          ),
          const SizedBox(height: HabotSpacing.md),
          StepperProgressDots(machine: machine),
          const SizedBox(height: HabotSpacing.xs),
          StepperNavigation(machine: machine),
        ],
      ),
    );
  }
}

/// Substep 3: glides the incoming step in from the correct side.
class StepSlideTransition extends StatelessWidget {
  const StepSlideTransition({
    required this.index,
    required this.child,
    super.key,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: HabotMotionPolicy.resolve(context, HabotMotion.stepperSlideIn),
      reverseDuration: HabotMotionPolicy.resolve(
        context,
        HabotMotion.stepperSlideOut,
      ),
      switchInCurve: HabotMotionPolicy.resolveCurve(
        context,
        HabotEasing.stepperEnter,
      ),
      switchOutCurve: HabotMotionPolicy.resolveCurve(
        context,
        HabotEasing.stepperExit,
      ),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey<int>(index), child: child),
    );
  }
}

/// Substep 4: the bottom progress dot row.
class StepperProgressDots extends StatelessWidget {
  const StepperProgressDots({required this.machine, super.key});

  final WizardStepMachine machine;

  /// tokens.json -> forms.stepper_progress_dot_dp / _active_dp
  static const double dotSize = HabotSpacing.xs;
  static const double activeDotWidth = HabotSpacing.lg;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Step ${machine.index + 1} of ${machine.stepCount}',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < machine.stepCount; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: HabotSpacing.xs),
            AnimatedContainer(
              duration: HabotMotionPolicy.resolve(
                context,
                HabotMotion.stepperSlideIn,
              ),
              curve: HabotMotionPolicy.resolveCurve(
                context,
                HabotEasing.stepperEnter,
              ),
              width: i == machine.index ? activeDotWidth : dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                // Active step is wider AND a different colour -- shape carries
                // the meaning too, not colour alone (WCAG 1.4.1).
                color: i == machine.index
                    ? scheme.primary
                    : scheme.outlineVariant,
                borderRadius: BorderRadius.circular(HabotShape.full),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// UX decision row: "Keep navigation actions easy to access with distinct next
/// and back buttons."
class StepperNavigation extends StatelessWidget {
  const StepperNavigation({required this.machine, super.key});

  final WizardStepMachine machine;

  /// UI implementation row: close the keyboard during a slide transition.
  static void dismissKeyboard(BuildContext context) =>
      FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canGoForward = machine.canAdvance;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AtomicButton(
          semanticLabel: 'Back',
          touchPadding: AtomicButton.standardTouchPadding,
          onPressed: machine.isFirst
              ? null
              : () {
                  dismissKeyboard(context);
                  machine.previous();
                },
          child: Text('Back', style: theme.textTheme.labelLarge),
        ),
        AtomicButton(
          semanticLabel: machine.isLast ? 'Submit' : 'Next',
          touchPadding: AtomicButton.standardTouchPadding,
          // The gate is what disables this, not a local flag.
          onPressed: canGoForward && !machine.isLast
              ? () {
                  dismissKeyboard(context);
                  machine.next();
                }
              : null,
          child: Text(
            machine.isLast ? 'Submit' : 'Next',
            style: theme.textTheme.labelLarge?.copyWith(
              color: canGoForward
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Convenience wrapper: a stepper whose gate is created and disposed with it.
class GuidedForm extends StatefulWidget {
  const GuidedForm({
    required this.steps,
    required this.stepBuilder,
    super.key,
  });

  final List<WizardStep> steps;
  final Widget Function(BuildContext, WizardStep, HabotFormGate) stepBuilder;

  @override
  State<GuidedForm> createState() => _GuidedFormState();
}

class _GuidedFormState extends State<GuidedForm> {
  late final HabotFormGate _gate;
  late final WizardStepMachine _machine;

  @override
  void initState() {
    super.initState();
    _gate = HabotFormGate();
    _machine = WizardStepMachine(steps: widget.steps, gate: _gate);
  }

  @override
  void dispose() {
    _machine.dispose();
    _gate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselStepper(
      machine: _machine,
      stepBuilder: (BuildContext context, WizardStep step) =>
          widget.stepBuilder(context, step, _gate),
    );
  }
}
