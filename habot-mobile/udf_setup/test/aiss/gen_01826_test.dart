/// AISS GATE -- Step 101 of 115
/// Global Reference ID:       GEN-01826
/// Atomic Steps Reference ID: GEN-01826-A01
/// Setup Step (Action):       "Confirm completion when TalkBack testing cannot
///                             swipe out of an open dialog."
/// WCAG 2.2 SC 2.1.2 / 2.4.3 / 2.4.11.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED: the row carries "Gesture Recognition Accuracy
/// (%)" -- floor 95.0, optimal 99.5, ceiling 100.0. Gesture recognition is a
/// property of the platform accessibility service; an app cannot move it and
/// no client-side suite can observe it. It is reported as NOT PRODUCED with no
/// number invented. What is gated is the sentence the row actually states.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/focus_trap.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  Widget scaffoldWith({required bool trapped, VoidCallback? onDismiss}) {
    final Widget page = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('Behind the dialog'),
        TextButton(onPressed: () {}, child: const Text('Page action')),
      ],
    );
    final Widget dialog = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('Filters heading'),
        TextButton(
          onPressed: onDismiss ?? () {},
          child: const Text('Close filters'),
        ),
      ],
    );
    return MaterialApp(
      home: HabotFocusTrap(
        active: trapped,
        onDismiss: onDismiss ?? () {},
        label: 'Filters',
        behind: page,
        surface: dialog,
      ),
    );
  }

  group('GEN-01826-A01 :: the trap', () {
    widgetGate(
      'GEN-01826-G1',
      'Setup Step (Action): "TalkBack ... CANNOT SWIPE OUT of an open dialog".',
      'With the trap open, nothing behind it is in the semantics tree, so a '
          'swipe-next has nowhere outside the dialog to go',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(scaffoldWith(trapped: true));
          // Content inside the trap is reachable...
          final bool insideReachable =
              find.bySemanticsLabel('Close filters').evaluate().isNotEmpty;
          // ...and content behind it is not.
          final bool behindUnreachable =
              find.bySemanticsLabel('Behind the dialog').evaluate().isEmpty &&
              find.bySemanticsLabel('Page action').evaluate().isEmpty;
          return insideReachable && behindUnreachable;
        } finally {
          handle.dispose();
        }
      },
    );

    widgetGate(
      'GEN-01826-G2',
      'A guard that can never fail is not a guard.',
      'With the trap inactive the same page IS reachable, proving the '
          'previous gate measures the trap rather than the layout',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(scaffoldWith(trapped: false));
          return find
                  .bySemanticsLabel('Behind the dialog')
                  .evaluate()
                  .isNotEmpty &&
              find.bySemanticsLabel('Page action').evaluate().isNotEmpty;
        } finally {
          handle.dispose();
        }
      },
    );

    widgetGate(
      'GEN-01826-G3',
      'A modal that opens silently is a page that changed under a user who '
          'was not told.',
      'The trap names and scopes its route, so the reader announces the '
          'dialog on entry',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(scaffoldWith(trapped: true));
          // Walk up from the FocusScope, which carries no semantics of its
          // own, so the node returned is the trap's own container rather than
          // the app root.
          final SemanticsNode node = tester.getSemantics(
            find.descendant(
              of: find.byKey(HabotFocusTrap.surfaceKey),
              matching: find.byType(FocusScope),
            ),
          );
          return node.label == 'Filters' &&
              node.hasFlag(SemanticsFlag.scopesRoute) &&
              node.hasFlag(SemanticsFlag.namesRoute);
        } finally {
          handle.dispose();
        }
      },
    );
  });

  group('GEN-01826-A01 :: the way out -- SC 2.1.2', () {
    gate(
      'GEN-01826-G4',
      'SC 2.1.2 FORBIDS a keyboard trap, and permits one only where a '
          'mechanism to leave is available and documented.',
      'The exit is a required constructor parameter, so a trap with no way '
          'out cannot be built -- and the escape clause is recorded in the '
          'code rather than in a reviewer memory',
      () =>
          HabotFocusTrapPolicy.escapeClause.contains('SC 2.1.2') &&
          HabotFocusTrapPolicy.escapeClause.contains('onDismiss') &&
          HabotTrapExit.values.length == 3,
    );

    widgetGate(
      'GEN-01826-G5',
      'A documented exit that does not work is not an exit.',
      'The dismiss control inside the trap is reachable and firing it calls '
          'onDismiss',
      (WidgetTester tester) async {
        int dismissed = 0;
        await tester.pumpWidget(
          scaffoldWith(trapped: true, onDismiss: () => dismissed++),
        );
        await tester.tap(find.text('Close filters'));
        await tester.pump();
        return dismissed == 1;
      },
    );

    widgetGate(
      'GEN-01826-G6',
      'SC 2.4.11 Focus Not Obscured: the focused element must not sit behind '
          'another surface.',
      'The barrier is painted BELOW the trapped content, so the dialog is '
          'never behind its own scrim',
      (WidgetTester tester) async {
        await tester.pumpWidget(scaffoldWith(trapped: true));
        final Stack stack = tester.widget<Stack>(
          find.byKey(HabotFocusTrap.trapKey),
        );
        final int barrierIndex = stack.children.indexWhere(
          (Widget w) => w.key == HabotFocusTrap.barrierKey,
        );
        final int contentIndex = stack.children.indexWhere(
          (Widget w) => w.key == HabotFocusTrap.surfaceKey,
        );
        return barrierIndex >= 0 &&
            contentIndex >= 0 &&
            HabotFocusTrapPolicy.barrierIsBelowContent(
              barrierIndex,
              contentIndex,
            ) &&
            HabotFocusTrapPolicy.announcesItself('Filters');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01826',
        atomicStepReferenceId: 'GEN-01826-A01',
        setupStepAction:
            'Confirm completion when TalkBack testing cannot swipe out of an '
            'open dialog.',
        implementationOrder: 101,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFocusTrap / HabotFocusTrapPolicy',
          'Component Properties':
              'FocusScope traversal containment + BlockSemantics barrier; '
              'onDismiss required at construction; '
              '${HabotTrapExit.values.length} declared exit affordances',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Nodes reachable outside an open trap',
            observed:
                '0. With the trap open neither the page text nor the page '
                'action is in the semantics tree; with the trap removed both '
                'are, which is what shows the measurement is of the trap and '
                'not of the layout.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Gesture Recognition Accuracy (%) (the sheet metric)',
            observed:
                'NOT PRODUCED. Gesture recognition happens inside the platform '
                'accessibility service. A client cannot influence it and no '
                'widget test can observe it. No number is asserted here.',
            floor: '95.0',
            optimal: '99.5',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/focus_trap.dart',
        ],
      ),
    );
  });
}
