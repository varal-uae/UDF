/// AISS GATE -- Step 106 of 115
/// Global Reference ID:       ETMDI-020-05
/// Atomic Steps Reference ID: ETMDI-020-05-A01
/// Setup Step (Action):       "Design Triangular Check (TC) Rollback Error UI."
/// Setup Step Description:    "Map error view to high-contrast semantic
///                             error-container theme."
/// Metric: Text/UI Contrast Ratio.
///
/// THIN ROW, RECORDED: 21 of 49 columns are populated. No Expected Output, no
/// Completion Measures, no substeps, no estimate. Nothing has been invented to
/// fill them. The step is gated against the two columns that ARE populated and
/// against REF-197 (Step 19), which already owns what a rollback says.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/error_templates.dart';
import 'package:udf_setup/design_system/resilience/rollback_error_view.dart';
import 'package:udf_setup/design_system/tokens/high_contrast_tokens.dart';

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

  const HabotRollbackEvent event = HabotRollbackEvent(
    recordId: 'REC-4102',
    disagreeingLegs: <HabotTriangularLeg>[
      HabotTriangularLeg.derived,
      HabotTriangularLeg.control,
    ],
    revertedToLabel: 'the values as of 09:14',
    category: HabotErrorCategory.conflict,
  );

  group('ETMDI-020-05-A01 :: the two populated columns', () {
    gate(
      'ETMDI-020-05-G1',
      'Setup Step Description: "map error view to HIGH-CONTRAST semantic '
          'ERROR-CONTAINER theme". Metric: Text/UI Contrast Ratio.',
      'The view reads the Step 105 high-contrast error-container pair in both '
          'brightnesses, and the measured ratio clears the AAA floor rather '
          'than the AA one',
      () =>
          HabotRollbackErrorPalette.meetsFloor(Brightness.light) &&
          HabotRollbackErrorPalette.meetsFloor(Brightness.dark) &&
          HabotRollbackErrorPalette.floor == HabotHighContrast.textFloor &&
          HabotRollbackErrorPalette.foregroundRole == 'onErrorContainer' &&
          HabotRollbackErrorPalette.backgroundRole == 'errorContainer',
    );

    gate(
      'ETMDI-020-05-G2',
      'The row names a TRIANGULAR CHECK -- three independently derived values '
          'that must agree.',
      'A rollback event is well formed only when at least two legs disagree; '
          'one leg cannot disagree with itself, and an event claiming it did '
          'is a bug in whatever raised it',
      () {
        const HabotRollbackEvent malformed = HabotRollbackEvent(
          recordId: 'REC-1',
          disagreeingLegs: <HabotTriangularLeg>[HabotTriangularLeg.source],
          revertedToLabel: 'x',
          category: HabotErrorCategory.conflict,
        );
        return event.isWellFormed &&
            !malformed.isWellFormed &&
            HabotTriangularLeg.values.length == 3;
      },
    );

    gate(
      'ETMDI-020-05-G3',
      'REF-197 (Step 19) already owns what a rollback SAYS. This step must '
          'not introduce a second error vocabulary.',
      'The words come from the Step 19 template for the category, and this '
          'step adds exactly one sentence: what the record was put back to',
      () =>
          event.template == HabotErrorTemplates.of(HabotErrorCategory.conflict) &&
          event.message.startsWith(event.template.body) &&
          event.message.contains('the values as of 09:14'),
    );
  });

  group('ETMDI-020-05-A01 :: what the user is left looking at', () {
    widgetGate(
      'ETMDI-020-05-G4',
      'A rolled-back write means the screen changed underneath the user.',
      'The surface announces itself as a live region carrying the full '
          'message, so a screen-reader user is told the record reverted rather '
          'than discovering it later',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            const MaterialApp(
              home: Material(
                child: HabotRollbackErrorView(event: event),
              ),
            ),
          );
          final SemanticsNode node = tester.getSemantics(
            find.byKey(HabotRollbackErrorView.viewKey),
          );
          return node.hasFlag(SemanticsFlag.isLiveRegion) &&
              node.label == event.template.title &&
              node.value.contains('put back to');
        } finally {
          handle.dispose();
        }
      },
    );

    widgetGate(
      'ETMDI-020-05-G5',
      'A retry button on a conflict is an invitation to lose the same work '
          'twice.',
      'Retry is offered only when the Step 19 template says the failure is '
          'retryable -- a conflict shows no retry even when a handler is '
          'supplied',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: HabotRollbackErrorView(event: event, onRetry: () {}),
            ),
          ),
        );
        final bool conflictHidesRetry =
            !HabotErrorTemplates.of(HabotErrorCategory.conflict).retryable &&
            find.byKey(HabotRollbackErrorView.retryKey).evaluate().isEmpty;

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: HabotRollbackErrorView(
                event: const HabotRollbackEvent(
                  recordId: 'REC-2',
                  disagreeingLegs: <HabotTriangularLeg>[
                    HabotTriangularLeg.source,
                    HabotTriangularLeg.derived,
                  ],
                  revertedToLabel: 'the values as of 08:02',
                  category: HabotErrorCategory.timeout,
                ),
                onRetry: () {},
              ),
            ),
          ),
        );
        final bool timeoutOffersRetry =
            HabotErrorTemplates.of(HabotErrorCategory.timeout).retryable &&
            find.byKey(HabotRollbackErrorView.retryKey).evaluate().isNotEmpty;

        return conflictHidesRetry && timeoutOffersRetry;
      },
    );

    gate(
      'ETMDI-020-05-G6',
      'The thin row leaves no Completion Measures, so the evidence has to '
          'carry the record instead.',
      'The event serialises the legs that disagreed, the record it applied to '
          'and what it reverted to -- so a rollback is investigable after the '
          'fact rather than only visible to whoever saw the screen',
      () {
        final Map<String, Object?> j = event.toJson();
        return j['record_id'] == 'REC-4102' &&
            (j['disagreeing_legs']! as List<String>).length == 2 &&
            j['reverted_to'] == 'the values as of 09:14' &&
            j['retryable'] == false;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ETMDI-020-05',
        atomicStepReferenceId: 'ETMDI-020-05-A01',
        setupStepAction: 'Design Triangular Check (TC) Rollback Error UI.',
        implementationOrder: 106,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotRollbackErrorView / HabotRollbackErrorPalette / '
              'HabotRollbackEvent',
          'Component Properties':
              'error-container role pair from the Step 105 high-contrast '
              'scheme in both brightnesses; words from the Step 19 templates; '
              'retry offered only where the template says retryable',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'THIN ROW: 21 of 49 columns populated. No Expected Output, no '
              'Completion Measures, no substeps, no estimate. Nothing was '
              'invented to fill them.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Text/UI Contrast Ratio (the sheet metric, and it '
                'fits)',
            observed:
                'light '
                '${HabotRollbackErrorPalette.ratioFor(Brightness.light).toStringAsFixed(2)}:1, '
                'dark '
                '${HabotRollbackErrorPalette.ratioFor(Brightness.dark).toStringAsFixed(2)}:1, '
                'both against the AAA floor rather than the AA one because '
                'this message is read under stress',
            floor: '4.5:1',
            optimal: '7:1',
            ceiling: '7:1',
          ),
          const AissMeasurement(
            metricName: 'Rollback frequency / triangular-check failure rate',
            observed:
                'NOT PRODUCED. That is a property of the server-side check, '
                'not of the view that reports it. This step owns what the '
                'user sees when it happens.',
            floor: 'not client-observable',
            optimal: 'not client-observable',
            ceiling: 'not client-observable',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/rollback_error_view.dart',
        ],
      ),
    );
  });
}
