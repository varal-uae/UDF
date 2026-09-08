/// AISS GATE -- Step 99 of 115
/// Global Reference ID:       GEN-04572
/// Atomic Steps Reference ID: GEN-04572-A01
/// Setup Step (Action):       "Add accessibility hints detailing results of
///                             performing actions on complex interactive
///                             components."
/// Metric: Accessibility Conformance Score -- Floor 90% (partial AA),
///         Optimal 100% (full AA).
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row, so the usual three-column derivation had
/// two distinct inputs rather than three.
///
/// THE METRIC FITS, which is rare. A conformance score over an enumerable set
/// of controls is exactly what this produces: the share of declared action
/// kinds that announce their consequence, measured by walking a rendered
/// semantics tree rather than by counting source lines.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/semantic_hints.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int kindsChecked = 0;
  int kindsAnnouncing = 0;

  void record(String id, String source, String description, bool passed) {
    gates.add(
      AissGate(
        id: id,
        requirementSource: source,
        description: description,
        passed: passed,
      ),
    );
  }

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        record(id, source, description, passed);
      }
    });
  }

  void widgetGate(
    String id,
    String source,
    String description,
    Future<bool> Function(WidgetTester tester) run,
  ) {
    testWidgets('[$id] $description', (WidgetTester tester) async {
      bool passed = false;
      try {
        passed = await run(tester);
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        record(id, source, description, passed);
      }
    });
  }

  group('GEN-04572-A01 :: the catalogue', () {
    gate(
      'GEN-04572-G1',
      'Setup Step (Action): "add accessibility hints ... on COMPLEX '
          'INTERACTIVE COMPONENTS".',
      'Every declared action kind has a hint, and the completeness check is a '
          'property of the data rather than a promise -- adding a kind without '
          'a hint fails here',
      () => HabotHints.isComplete && HabotHints.missing.isEmpty,
    );

    gate(
      'GEN-04572-G2',
      'Setup Step (Action): the hint details "RESULTS of performing actions" '
          '-- a consequence, not a name.',
      'No hint merely restates the control: each describes what changes, and '
          'every irreversible action says that it cannot be undone',
      () =>
          HabotHints.irreversibleWithoutWarning.isEmpty &&
          HabotHints.all.every(
            (HabotHint h) => h.hint.length > 25 && !h.hint.startsWith('the '),
          ),
    );

    gate(
      'GEN-04572-G3',
      'MUFCE-028 (Step 24): hover affordances are unreachable on touch.',
      'A hint is semantic and renders nothing, so this step cannot '
          'reintroduce anything hover-shaped',
      () => HabotHints.all.every(
        (HabotHint h) =>
            !h.hint.toLowerCase().contains('hover') &&
            !h.hint.toLowerCase().contains('tooltip'),
      ),
    );
  });

  group('GEN-04572-A01 :: what a screen reader actually gets', () {
    widgetGate(
      'GEN-04572-G4',
      'Metric: Accessibility Conformance Score -- floor 90%, optimal 100%, '
          'measured over the controls that declare a consequence.',
      'Every action kind, rendered, announces its label AND its consequence '
          'hint in the semantics tree',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          for (final HabotActionKind kind in HabotActionKind.values) {
            kindsChecked++;
            await tester.pumpWidget(
              MaterialApp(
                home: HabotHintedAction(
                  kind: kind,
                  label: 'Control ${kind.name}',
                  child: const Text('x'),
                ),
              ),
            );
            final SemanticsNode node = tester.getSemantics(
              find.byType(HabotHintedAction),
            );
            final bool ok =
                node.label == 'Control ${kind.name}' &&
                node.hint == HabotHints.of(kind).hint &&
                node.hint.isNotEmpty;
            if (ok) {
              kindsAnnouncing++;
            }
          }
          return kindsChecked > 0 && kindsAnnouncing == kindsChecked;
        } finally {
          handle.dispose();
        }
      },
    );

    widgetGate(
      'GEN-04572-G5',
      'A hint announced twice, or a label the reader reads through the visual '
          'child as well, is noise.',
      'The visual child is excluded from semantics, so the control announces '
          'exactly once rather than once for the wrapper and once for the text '
          'inside it',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            const MaterialApp(
              home: HabotHintedAction(
                kind: HabotActionKind.approveBatch,
                label: 'Approve',
                child: Text('Approve batch B-2026-08'),
              ),
            ),
          );
          final SemanticsNode node = tester.getSemantics(
            find.byType(HabotHintedAction),
          );
          return node.label == 'Approve' &&
              !node.label.contains('B-2026-08') &&
              node.hint.contains('cannot be undone');
        } finally {
          handle.dispose();
        }
      },
    );

    widgetGate(
      'GEN-04572-G6',
      'SC 4.1.2 Name, Role, Value: a control must announce its role and its '
          'enabled state, not only its name.',
      'The wrapper declares the button role and carries the disabled state '
          'through, so a reader says "dimmed" rather than offering an action '
          'that will not happen',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            const MaterialApp(
              home: HabotHintedAction(
                kind: HabotActionKind.submitTask,
                label: 'Submit',
                enabled: false,
                child: Text('Submit'),
              ),
            ),
          );
          final SemanticsNode node = tester.getSemantics(
            find.byType(HabotHintedAction),
          );
          return node.hasFlag(SemanticsFlag.isButton) &&
              !node.hasFlag(SemanticsFlag.isEnabled) &&
              node.hasFlag(SemanticsFlag.hasEnabledState);
        } finally {
          handle.dispose();
        }
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04572',
        atomicStepReferenceId: 'GEN-04572-A01',
        setupStepAction:
            'Add accessibility hints detailing results of performing actions '
            'on complex interactive components.',
        implementationOrder: 99,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotHints / HabotHintedAction',
          'Component Properties':
              '${HabotActionKind.values.length} action kinds, each with a '
              'consequence hint; '
              '${HabotHints.all.where((HabotHint h) => !h.reversible).length} '
              'declared irreversible and each saying so in the announcement',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Accessibility Conformance Score (hints on complex '
                'controls)',
            observed:
                '$kindsAnnouncing of $kindsChecked action kinds announce both '
                'their label and their consequence in a rendered semantics '
                'tree',
            floor: '90% (partial AA)',
            optimal: '100% (full AA)',
            ceiling: '100%',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/semantic_hints.dart',
        ],
      ),
    );
  });
}
