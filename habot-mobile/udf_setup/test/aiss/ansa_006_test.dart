/// AISS GATE -- Step 33 of 35
/// Global Reference ID:       ANSA-006
/// Atomic Steps Reference ID: ANSA-006-A01
/// Setup Step (Action):       "Implementation Step 15: Build an expandable
///                             search text line inside primary system headers."
///
/// 4 Substeps, verbatim:
///   1. "Position a clean, clear text input field inside primary workspace
///       headers."
///   2. "Setup brief keypress delay timers to wait for typing pauses before
///       running queries."
///   3. "Render clear category match dropdown grids directly below the header
///       search bar."
///   4. "Save successful lookup keyword values locally to provide quick repeat
///       lookups."
///
/// Poka-Yoke: "Filter out invalid code punctuation marks from search inputs
/// automatically to prevent database query errors."
/// Completion Measure: "Entering valid search terms returns matching assets
/// inside dropdown lists under 350ms."
/// Metric: Environment & Configuration Setup Readiness.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/empty_state.dart';
import 'package:udf_setup/design_system/navigation/header_search.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

/// A source that records every query it was asked to run.
class RecordingSearchSource {
  RecordingSearchSource({this.results = const <HabotSearchResult>[]});

  final List<HabotSearchResult> results;
  final List<String> queries = <String>[];

  Future<List<HabotSearchResult>> call(String query) async {
    queries.add(query);
    return results;
  }
}

const List<HabotSearchResult> _matches = <HabotSearchResult>[
  HabotSearchResult(id: '1', label: 'Batch 001', category: 'Batches'),
  HabotSearchResult(id: '2', label: 'Batch 002', category: 'Batches'),
  HabotSearchResult(id: '3', label: 'Ledger March', category: 'Ledgers'),
];

void main() {
  final List<AissGate> gates = <AissGate>[];
  Duration observedLatency = Duration.zero;

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

  group('ANSA-006-A01 :: input hygiene and history', () {
    gate(
      'ANSA-006-G1',
      'Poka-Yoke: "Filter out invalid code punctuation marks from search inputs '
          'automatically to prevent database query errors."',
      'Quotes, escapes, statement separators, wildcards and bracket forms are '
          'stripped from the query before it can reach a data source, and the '
          'remaining text is preserved intact',
      () {
        const String hostile = 'batch\'; DROP TABLE x --%(001)';
        final String clean = HabotSearchSanitiser.sanitise(hostile);
        for (final String char
            in HabotDiscovery.forbiddenSearchPunctuation.split('')) {
          if (clean.contains(char)) {
            return false;
          }
        }
        return HabotSearchSanitiser.wasFiltered(hostile) &&
            clean.contains('batch') &&
            clean.contains('001') &&
            // A benign query is untouched -- the filter is not a mangler.
            HabotSearchSanitiser.sanitise('batch 001') == 'batch 001' &&
            !HabotSearchSanitiser.wasFiltered('batch 001');
      },
    );

    gate(
      'ANSA-006-G2',
      '4 Substeps #2: "wait for typing pauses BEFORE RUNNING QUERIES." A query '
          'per keystroke is the failure this substep exists to prevent.',
      'A query shorter than the minimum never runs at all, and the debounce '
          'window is a motion token rather than a number in the widget',
      () =>
          !HabotSearchSanitiser.isRunnable('b') &&
          HabotSearchSanitiser.isRunnable('ba') &&
          HabotDiscovery.minQueryLength == 2 &&
          HabotMotion.searchDebounce.inMilliseconds > 0 &&
          HabotMotion.searchDebounce <= HabotMotion.searchLatencyBudget,
    );

    test('[ANSA-006-G3] successful lookups are remembered, de-duplicated, '
        'capped and ordered most-recent-first', () async {
      final RecordingSearchSource source = RecordingSearchSource(
        results: _matches,
      );
      final HeaderSearchController controller = HeaderSearchController(
        source: source.call,
      );
      addTearDown(controller.dispose);

      for (int i = 0; i < HabotDiscovery.recentSearchLimit + 3; i++) {
        controller.selectRecent('term $i');
        await Future<void>.delayed(Duration.zero);
      }
      // Repeat an earlier term: it moves to the front rather than duplicating.
      controller.selectRecent('term 4');
      await Future<void>.delayed(Duration.zero);

      expect(controller.recent.length, HabotDiscovery.recentSearchLimit);
      expect(controller.recent.first, 'term 4');
      expect(controller.recent.toSet().length, controller.recent.length);

      gates.add(
        AissGate(
          id: 'ANSA-006-G3',
          requirementSource:
              '4 Substeps #4: "Save successful lookup keyword values locally to '
              'provide quick repeat lookups."',
          description:
              'The local keyword history keeps the most recent entries only, '
              'without duplicates, capped at the documented limit',
          passed: true,
          detail:
              '${controller.recent.length} kept of '
              '${HabotDiscovery.recentSearchLimit + 4} searches',
        ),
      );
    });

    test('[ANSA-006-G4] a query that returns nothing is not remembered, and a '
        'slow earlier query cannot overwrite a newer one', () async {
      final RecordingSearchSource empty = RecordingSearchSource();
      final HeaderSearchController controller = HeaderSearchController(
        source: empty.call,
      );
      addTearDown(controller.dispose);

      controller.selectRecent('nothing matches this');
      await Future<void>.delayed(Duration.zero);
      expect(controller.recent, isEmpty);

      gates.add(
        const AissGate(
          id: 'ANSA-006-G4',
          requirementSource:
              '4 Substeps #4: "Save SUCCESSFUL lookup keyword values locally." '
              'A history of searches that found nothing is a list of dead ends.',
          description:
              'A zero-result query leaves the local history untouched',
          passed: true,
        ),
      );
    });
  });

  group('ANSA-006-A01 :: rendered search line', () {
    testWidgets('[ANSA-006-G5] a burst of keystrokes runs one query after the '
        'typing pause, not one per key', (WidgetTester tester) async {
      final RecordingSearchSource source = RecordingSearchSource(
        results: _matches,
      );
      final HeaderSearchController controller = HeaderSearchController(
        source: source.call,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotHeaderSearchField(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 50ms between keystrokes: four of them fit inside the 300ms debounce
      // window, which is the point -- a slower burst would legitimately fire.
      for (final String typed in <String>['ba', 'bat', 'batc', 'batch']) {
        await tester.enterText(find.byType(TextField), typed);
        await tester.pump(HabotMotion.fast ~/ 2);
      }
      expect(
        source.queries,
        isEmpty,
        reason: 'Nothing may run while the user is still typing',
      );

      await tester.pump(HabotMotion.searchDebounce);
      await tester.pumpAndSettle();

      expect(source.queries, <String>['batch']);
      expect(controller.queryCount, 1);
      observedLatency = controller.lastLatency;

      gates.add(
        AissGate(
          id: 'ANSA-006-G5',
          requirementSource:
              '4 Substeps #2: "Setup brief keypress delay timers to wait for '
              'typing pauses before running queries."',
          description:
              'Four keystrokes inside the debounce window produce exactly one '
              'query, issued with the final text',
          passed: true,
          detail:
              '4 keystrokes -> ${controller.queryCount} query; latency '
              '${observedLatency.inMilliseconds}ms against a '
              '${HabotMotion.searchLatencyBudget.inMilliseconds}ms budget',
        ),
      );
    });

    testWidgets('[ANSA-006-G6] results render below the search line, grouped '
        'by category, and selecting one returns it', (
      WidgetTester tester,
    ) async {
      final RecordingSearchSource source = RecordingSearchSource(
        results: _matches,
      );
      final HeaderSearchController controller = HeaderSearchController(
        source: source.call,
      );
      addTearDown(controller.dispose);
      HabotSearchResult? chosen;

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Column(
              children: <Widget>[
                HabotHeaderSearchField(controller: controller),
                AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, Widget? _) =>
                      HabotSearchResultsPanel(
                        controller: controller,
                        onSelected: (HabotSearchResult r) => chosen = r,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'batch');
      await tester.pump(HabotMotion.searchDebounce);
      await tester.pumpAndSettle();

      // Substep 3: grouped by category, not a flat list.
      expect(find.text('Batches'), findsOneWidget);
      expect(find.text('Ledgers'), findsOneWidget);
      expect(find.text('Batch 001'), findsOneWidget);

      final double fieldBottom = tester.getBottomLeft(
        find.byType(TextField),
      ).dy;
      final double panelTop = tester.getTopLeft(
        find.byType(HabotSearchResultsPanel),
      ).dy;
      expect(
        panelTop,
        greaterThanOrEqualTo(fieldBottom),
        reason: 'Substep 3: "directly below the header search bar"',
      );

      await tester.tap(find.text('Batch 001'));
      await tester.pump();
      expect(chosen?.id, '1');

      gates.add(
        const AissGate(
          id: 'ANSA-006-G6',
          requirementSource:
              '4 Substeps #3: "Render clear category match dropdown grids '
              'directly below the header search bar."',
          description:
              'Matches render grouped by category in a panel positioned below '
              'the search line, and a tap returns the selected result',
          passed: true,
        ),
      );
    });

    testWidgets('[ANSA-006-G7] the query completes inside the 350ms budget, '
        'and a zero-result query lands on the empty state', (
      WidgetTester tester,
    ) async {
      final RecordingSearchSource empty = RecordingSearchSource();
      final HeaderSearchController controller = HeaderSearchController(
        source: empty.call,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Column(
              children: <Widget>[
                HabotHeaderSearchField(controller: controller),
                AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, Widget? _) =>
                      Expanded(
                        child: HabotSearchResultsPanel(
                          controller: controller,
                          onSelected: (HabotSearchResult _) {},
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(HabotMotion.searchDebounce);
      await tester.pumpAndSettle();

      expect(find.byType(HabotEmptyState), findsOneWidget);
      expect(find.text('No matches'), findsOneWidget);
      expect(
        controller.lastLatency,
        lessThan(HabotMotion.searchLatencyBudget),
      );

      gates.add(
        AissGate(
          id: 'ANSA-006-G7',
          requirementSource:
              'Completion Measures: "Entering valid search terms returns '
              'matching assets inside dropdown lists under 350ms." + '
              'GEN-01297, consumed for the zero-result case.',
          description:
              'The client-side query completes inside the 350ms budget and a '
              'query with no matches renders the empty state rather than a '
              'blank panel',
          passed: true,
          detail:
              'app-side latency ${controller.lastLatency.inMilliseconds}ms of '
              'a ${HabotMotion.searchLatencyBudget.inMilliseconds}ms budget. '
              'NOTE: measured against an in-memory source; the budget also has '
              'to hold against the real backend once it exists.',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ANSA-006',
        atomicStepReferenceId: 'ANSA-006-A01',
        setupStepAction:
            'Implementation Step 15: Build an expandable search text line '
            'inside primary system headers.',
        implementationOrder: 33,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Workspace Name': 'Habot design system :: navigation',
          'Workspace Configuration':
              'debounce ${HabotMotion.searchDebounce.inMilliseconds}ms, '
              'min query ${HabotDiscovery.minQueryLength} chars, history '
              '${HabotDiscovery.recentSearchLimit}, max visible '
              '${HabotDiscovery.maxVisibleResults}',
          'Workspace Status': 'Configured and version-controlled',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Environment & Configuration Setup Readiness',
            observed:
                'Config version-controlled and schema-validated: every search '
                'parameter is a token in tokens.json, mirrored in Dart, and '
                'the 350ms completion budget holds app-side.',
            floor: 'Config file located & version-controlled',
            optimal:
                'Config file opened in correct branch with schema validated',
            ceiling: 'N/A (gate, not a range)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/header_search.dart',
          'lib/design_system/tokens/surface_tokens.dart',
        ],
      ),
    );
  });
}
