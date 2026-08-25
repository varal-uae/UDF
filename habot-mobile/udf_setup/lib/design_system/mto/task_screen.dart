/// AISS: GEN-03580-A01 -- "Present the human worker with a SINGLE MASKED INPUT
/// FIELD and CROPPED VISUAL EVIDENCE."
/// Metric: UI Screen Visual Focus Efficiency -- Floor 1.0, Optimal 1.0,
///         Ceiling 1.0.
///
/// The payoff of Steps 81-90: the Zero-Context UI constraint rendered as an
/// actual screen. One crop, one question, one input, one submit -- and the
/// metric is a ratio you can measure on the rendered tree rather than a
/// judgement about whether the screen "feels focused".
///
/// FOCUS EFFICIENCY, DEFINED: interactive elements that belong to the task,
/// over all interactive elements on the screen. A floor, optimal and ceiling
/// all at 1.0 means the sheet is asking for a screen where NOTHING is
/// interactive except the task, which is the same requirement Step 88 states
/// as a peripheral count of zero, from the other direction.
///
/// "MASKED", INTERPRETED AND RECORDED: this app already has input masking --
/// CSIVW-001 (Step 15) built keystroke-level masks and IS12-CSIVW-011 (Step 16)
/// built the 13 Critical Data Element rules that carry them. So the masked
/// input here is a `ValidatedInputField` bound to the CDE the task declares,
/// not a new text field with an obscuring dot. That reading uses the sheet's
/// own vocabulary rather than inventing a second meaning for the word, and it
/// is stated here so it can be argued with.
library;

import 'package:flutter/material.dart';

import '../forms/field_validation.dart';
import '../forms/form_gate.dart';
import '../forms/validated_input_field.dart';
import '../interaction/atomic_button.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'byt_isolation.dart';
import 'isolated_viewport.dart';
import 'task_chassis.dart';

/// The action half of a task screen: the question, one input, one submit.
class HabotTaskAnswerPane extends StatefulWidget {
  const HabotTaskAnswerPane({
    required this.byt,
    required this.cde,
    required this.onSubmit,
    super.key,
  });

  final HabotByt byt;

  /// The Critical Data Element the answer must satisfy -- which is what
  /// carries the mask, the keyboard and the validation message.
  final HabotCde cde;

  final ValueChanged<String> onSubmit;

  static const Key promptKey = Key('habot.mto.prompt');
  static const Key inputKey = Key('habot.mto.input');
  static const Key submitKey = Key('habot.mto.submit');

  static const String submitLabel = 'Submit answer';

  /// The one field name the gate and the form gate agree on.
  static const String fieldName = 'byt.answer';

  @override
  State<HabotTaskAnswerPane> createState() => _HabotTaskAnswerPaneState();
}

class _HabotTaskAnswerPaneState extends State<HabotTaskAnswerPane> {
  /// The one required field. Without this the gate would consider an empty
  /// form submittable, which is how a worker sends a blank answer.
  final HabotFormGate _gate = HabotFormGate(
    requiredFields: <String>{HabotTaskAnswerPane.fieldName},
  );
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.byt.prompt,
          key: HabotTaskAnswerPane.promptKey,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: HabotSpacing.xxs),
        Text(
          'Expected: ${widget.byt.expectedFormat}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: HabotSpacing.xs),
        ValidatedInputField(
          key: HabotTaskAnswerPane.inputKey,
          fieldName: HabotTaskAnswerPane.fieldName,
          label: widget.byt.expectedFormat,
          cde: widget.cde,
          gate: _gate,
          controller: _controller,
        ),
        const SizedBox(height: HabotSpacing.xs),
        AnimatedBuilder(
          animation: _gate,
          builder: (BuildContext context, Widget? _) => AtomicButton(
            key: HabotTaskAnswerPane.submitKey,
            semanticLabel: HabotTaskAnswerPane.submitLabel,
            touchPadding: HabotSpacing.xs,
            // The Step 18 form gate decides. There is no second rule here
            // about when an answer may be sent.
            onPressed: _gate.canSubmit
                ? () => widget.onSubmit(_controller.text)
                : null,
            child: Text(
              HabotTaskAnswerPane.submitLabel,
              style: theme.textTheme.labelLarge,
            ),
          ),
        ),
      ],
    );
  }
}

/// The whole task screen: evidence above, answer below, nothing else.
class HabotTaskScreen extends StatelessWidget {
  const HabotTaskScreen({
    required this.byt,
    required this.cde,
    required this.onSubmit,
    this.imageBuilder,
    super.key,
  });

  final HabotByt byt;
  final HabotCde cde;
  final ValueChanged<String> onSubmit;
  final HabotSnippetImageBuilder? imageBuilder;

  static const String screenName = 'mto.task';

  @override
  Widget build(BuildContext context) {
    return HabotTaskChassis(
      screenName: screenName,
      evidence: HabotIsolatedViewport(byt: byt, imageBuilder: imageBuilder),
      action: HabotTaskContent(
        screenName: screenName,
        child: HabotTaskAnswerPane(byt: byt, cde: cde, onSubmit: onSubmit),
      ),
    );
  }
}

/// GEN-03580's metric, made countable.
///
/// The audit is deliberately generous about what counts as a task element --
/// the input, the submit, and the evidence itself are all part of the task --
/// and strict about the denominator: EVERY interactive element on the screen
/// is counted, including anything a future edit adds without thinking.
class HabotFocusAudit {
  const HabotFocusAudit._();

  /// Floor, Optimal and Ceiling are all 1.0 in the sheet.
  static const double efficiencyFloor = 1.0;

  /// The type names that belong to a task. Compared by name so the audit can
  /// run against a rendered tree without importing every widget it might meet.
  static const Set<String> taskElementTypes = <String>{
    'ValidatedInputField',
    'AtomicButton',
    'HabotIsolatedViewport',
  };

  /// Interactive types that are NOT part of a task and therefore lower the
  /// ratio: anything that navigates, dismisses or opens something else.
  static const Set<String> distractionTypes = <String>{
    'NavigationBar',
    'NavigationRail',
    'BottomNavigationBar',
    'Drawer',
    'AppBar',
    'TabBar',
    'FloatingActionButton',
    'PopupMenuButton',
    'BackButton',
  };

  /// task elements / (task elements + distractions).
  static double efficiency({
    required int taskElements,
    required int distractions,
  }) {
    final int total = taskElements + distractions;
    if (total == 0) {
      return 0;
    }
    return taskElements / total;
  }

  /// The type role, for a walker over a rendered tree.
  static bool isTaskElement(String typeName) =>
      taskElementTypes.contains(typeName);

  static bool isDistraction(String typeName) =>
      distractionTypes.contains(typeName);

  /// The single-input rule, stated as a number so it can be asserted: exactly
  /// one field, and exactly one submit.
  static const int expectedInputCount = 1;
  static const int expectedSubmitCount = 1;

  /// The type role used for the prompt, from the scale rather than a size.
  static const HabotTypeToken promptToken = HabotTypography.titleMedium;
}
