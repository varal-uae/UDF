/// A probe screen for the forms and feedback layer (Steps 11-20).
///
/// Like [DesignSystemProbePage] this is scaffolding, not product UI. Its job is
/// to make `flutter run` demonstrate every primitive the batch produced, and to
/// give the widget gates a real tree to pump.
library;

import 'package:flutter/material.dart';

import 'design_system/forms/compound_field.dart';
import 'design_system/forms/field_validation.dart';
import 'design_system/forms/form_gate.dart';
import 'design_system/forms/validated_input_field.dart';
import 'design_system/interaction/atomic_button.dart';
import 'design_system/layout/master_scaffold.dart';
import 'design_system/navigation/contextual_header.dart';
import 'design_system/resilience/error_rollback_boundary.dart';
import 'design_system/tokens/grid_tokens.dart';
import 'design_system/tokens/spacing_tokens.dart';
import 'design_system/wizard/carousel_stepper.dart';
import 'design_system/wizard/step_machine.dart';

class DataEntryProbePage extends StatefulWidget {
  const DataEntryProbePage({this.embedded = false, super.key});

  /// True when the app shell is hosting this as a destination. The shell owns
  /// the master scaffold in that case, so this builds its content only --
  /// there is exactly one wrapper on screen either way.
  final bool embedded;

  static const String screenName = 'DataEntryProbePage';

  static const List<WizardStep> steps = <WizardStep>[
    WizardStep(
      id: 'contact',
      title: 'Contact',
      fieldNames: <String>['contact.name', 'contact.phone', 'contact.email'],
    ),
    WizardStep(
      id: 'address',
      title: 'Address',
      fieldNames: <String>[
        'address.line1',
        'address.line2',
        'address.city',
        'address.postal',
      ],
    ),
    WizardStep(
      id: 'amount',
      title: 'Amount',
      fieldNames: <String>['amount.value', 'amount.quantity', 'notes'],
    ),
  ];

  @override
  State<DataEntryProbePage> createState() => _DataEntryProbePageState();
}

class _DataEntryProbePageState extends State<DataEntryProbePage> {
  final GlobalKey<ErrorRollbackBoundaryState> _boundary =
      GlobalKey<ErrorRollbackBoundaryState>();
  late final HabotFormGate _gate;
  late final WizardStepMachine _machine;

  @override
  void initState() {
    super.initState();
    _gate = HabotFormGate();
    _machine = WizardStepMachine(
      steps: DataEntryProbePage.steps,
      gate: _gate,
    );
  }

  @override
  void dispose() {
    _machine.dispose();
    _gate.dispose();
    super.dispose();
  }

  /// Simulates a server crash so the rollback boundary can be seen working.
  void _simulateFailure() {
    _boundary.currentState?.reportFailure(
      Exception('HTTP 500 server error while committing transaction'),
    );
  }

  Widget _stepCard(BuildContext context, WizardStep step) {
    switch (step.id) {
      case 'contact':
        return CompoundField(
          parts: HabotCompoundFields.contactBlock,
          gate: _gate,
          title: 'Who is this for?',
        );
      case 'address':
        return CompoundField(
          parts: HabotCompoundFields.addressBlock,
          gate: _gate,
          title: 'Where should it go?',
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CompoundField(
              parts: HabotCompoundFields.amountBlock,
              gate: _gate,
              title: 'How much?',
            ),
            const SizedBox(height: HabotGrid.verticalRhythm),
            ValidatedInputField(
              fieldName: 'notes',
              label: 'Notes',
              cde: HabotCde.freeText,
              gate: _gate,
              required: false,
              helperText: 'Optional. Plain text only.',
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _body(context);
    }
    return HabotMasterScaffold(
      screenName: DataEntryProbePage.screenName,
      header: HabotContextualHeader(
        title: 'Guided data entry',
        actions: <HabotHeaderAction>[
          HabotHeaderAction(
            icon: Icons.bug_report_outlined,
            label: 'Simulate a server failure',
            priority: 1,
            onPressed: _simulateFailure,
          ),
        ],
      ),
      body: _body(context),
    );
  }

  /// The content, without a scaffold, so the app shell (Step 36+) can host
  /// this as a destination rather than as a pushed page.
  Widget _body(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ErrorRollbackBoundary(
      key: _boundary,
      baseline: _machine.draft,
      onRollback: _machine.restoreDraft,
      onRetry: _simulateFailure,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Steps 11-20: motion, atomic interaction, masking, validation, '
            'compound fields, rollback and the guided stepper.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: HabotSpacing.md),
          CarouselStepper(machine: _machine, stepBuilder: _stepCard),
          const SizedBox(height: HabotSpacing.md),
          AtomicButton(
            semanticLabel: 'Simulate a server failure',
            touchPadding: AtomicButton.standardTouchPadding,
            onPressed: _simulateFailure,
            child: Text(
              'Simulate a server failure',
              style: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

/// The data-entry probe as a shell destination: the same content, hosted by
/// the app shell's scaffold instead of its own.
class DataEntryProbeBody extends StatelessWidget {
  const DataEntryProbeBody({super.key});

  @override
  Widget build(BuildContext context) => const DataEntryProbePage(embedded: true);
}
