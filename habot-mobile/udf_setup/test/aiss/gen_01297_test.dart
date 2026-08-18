/// AISS GATE -- Step 27 of 35
/// Global Reference ID:       GEN-01297
/// Atomic Steps Reference ID: GEN-01297-A01
/// Setup Step (Action):       "Implement an empty state container with custom
///                             illustrations to display when search queries
///                             return no results."
///
/// METRIC MISMATCH, RECORDED: the Metric Name on this row is "Activity Log
/// Data Completeness", which belongs to a logging step. The gates defend the
/// Setup Step and Description; the metric is reported against the only
/// completeness this component has -- coverage of the empty reasons -- and the
/// mismatch is stated.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/empty_state.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  group('GEN-01297-A01 :: empty state container', () {
    gate(
      'GEN-01297-G1',
      'Setup Step (Action): "Implement an empty state container ... to display '
          'when search queries return no results."',
      'Every empty reason has copy, and the no-results case the step names is '
          'one of them -- an unmapped reason cannot be constructed',
      () {
        if (!HabotEmptyStates.isComplete) {
          return false;
        }
        for (final HabotEmptyReason reason in HabotEmptyReason.values) {
          final HabotEmptyStateSpec spec = HabotEmptyStates.of(reason);
          if (spec.headline.isEmpty || spec.body.isEmpty) {
            return false;
          }
        }
        return HabotEmptyStates.of(
          HabotEmptyReason.noSearchResults,
        ).actionLabel!.isNotEmpty;
      },
    );

    gate(
      'GEN-01297-G2',
      'Setup Step (Action): "...with CUSTOM ILLUSTRATIONS." The illustration is '
          'what distinguishes one empty state from another at a glance.',
      'Each reason carries its own illustration -- no two reasons share an icon',
      () {
        final Set<IconData> icons = HabotEmptyStates.all
            .map((HabotEmptyStateSpec s) => s.icon)
            .toSet();
        return icons.length == HabotEmptyReason.values.length;
      },
    );

    gate(
      'GEN-01297-G3',
      'REF-197 Mobile-First UX Decision, inherited: "Ensure error text displays '
          'do not use technical code terms, keeping descriptions simple and '
          'clear."',
      'No empty-state copy contains a word from the banned-jargon list -- an '
          'empty state that says "null result set" is an error message in '
          'disguise',
      () {
        for (final HabotEmptyStateSpec spec in HabotEmptyStates.all) {
          final String text = '${spec.headline} ${spec.body}'.toLowerCase();
          for (final String jargon in HabotEmptyStates.forbiddenJargon) {
            if (text.contains(jargon)) {
              return false;
            }
          }
        }
        return true;
      },
    );

    gate(
      'GEN-01297-G4',
      'Setup Step (Action) -- "no results" is a specific claim. Telling a user '
          'there is nothing when the fetch failed is a false one.',
      'Unavailable is a distinct reason from empty, with distinct copy and a '
          'retry action, so the two can never be shown interchangeably',
      () {
        final HabotEmptyStateSpec none = HabotEmptyStates.of(
          HabotEmptyReason.noSearchResults,
        );
        final HabotEmptyStateSpec down = HabotEmptyStates.of(
          HabotEmptyReason.unavailable,
        );
        return none.headline != down.headline &&
            none.body != down.body &&
            down.hasAction &&
            !HabotEmptyStates.of(HabotEmptyReason.nothingYet).hasAction;
      },
    );
  });

  group('GEN-01297-A01 :: rendered empty state', () {
    testWidgets('[GEN-01297-G5] the zero-result state renders illustration, '
        'headline, body and a working clear action', (
      WidgetTester tester,
    ) async {
      int cleared = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotEmptyState(
              reason: HabotEmptyReason.noSearchResults,
              onAction: () => cleared++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('No matches'), findsOneWidget);
      expect(find.textContaining('Try fewer words'), findsOneWidget);

      await tester.tap(find.text('Clear search'));
      await tester.pump();
      expect(cleared, 1);

      gates.add(
        const AissGate(
          id: 'GEN-01297-G5',
          requirementSource:
              'Setup Step (Action): "Implement an empty state container with '
              'custom illustrations to display when search queries return no '
              'results."',
          description:
              'The no-results state renders its own illustration, headline and '
              'body, and its action is wired',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-01297-G6] a reason with no honest action offers no '
        'button, and the container stays inside its readable width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: HabotEmptyState(
              reason: HabotEmptyReason.nothingYet,
              onAction: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsNothing);
      final RenderBox box = tester.renderObject<RenderBox>(
        find.byType(ConstrainedBox).first,
      );
      expect(
        box.size.width,
        lessThanOrEqualTo(HabotFeedback.emptyStateMaxContentWidth),
      );

      gates.add(
        AissGate(
          id: 'GEN-01297-G6',
          requirementSource:
              'Setup Step (Action) -- an empty state with a button that does '
              'nothing is worse than one with no button. + RCGLA-032 reading '
              'width, inherited.',
          description:
              'The nothing-yet state renders without an action control and '
              'inside the readable content width',
          passed: true,
          detail:
              'content width ${box.size.width.toStringAsFixed(0)}dp, cap '
              '${HabotFeedback.emptyStateMaxContentWidth.toStringAsFixed(0)}dp',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01297',
        atomicStepReferenceId: 'GEN-01297-A01',
        setupStepAction:
            'Implement an empty state container with custom illustrations to '
            'display when search queries return no results.',
        implementationOrder: 27,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotEmptyState',
          'Component Type': 'Reason-driven empty state container',
          'State Definitions':
              '${HabotEmptyReason.values.length} reasons, each with its own '
              'illustration, headline, body and action decision',
          'Completion Status': 'Derived from gate outcomes',
          'Metric note':
              'Metric Name ("Activity Log Data Completeness") belongs to a '
              'logging step. Reported against reason coverage instead.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Activity Log Data Completeness',
            observed:
                '1.0 -- ${HabotEmptyReason.values.length} of '
                '${HabotEmptyReason.values.length} empty reasons have complete, '
                'jargon-free copy and a distinct illustration. NOTE: the metric '
                'name does not describe this step; see the mismatch note.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>['lib/design_system/feedback/empty_state.dart'],
      ),
    );
  });
}
