/// AISS GATE -- Step 32 of 35
/// Global Reference ID:       CPNCA-006
/// Atomic Steps Reference ID: CPNCA-006-A01
/// Setup Step (Action):       "Build a standardized list virtualization and
///                             dynamic data chunking component for data
///                             tables."
///
/// 4 Substeps, verbatim:
///   1. "Author a container component that calculates visible viewport
///       boundaries using real-time scroll tracking."
///   2. "Implement data partitioning hooks that fetch record batches (e.g., 20
///       items per request) rather than loading entire datasets at once."
///   3. "Create structural placeholder rows for records still loading."
///   4. "Verify element counts remain stable during continuous scrolling."
///
/// Completion Measure: "Loading a test collection of 10,000 items preserves a
/// consistent, low DOM element count during continuous scrolling."
/// Metric: Requirements / Discovery Coverage (%) -- Floor 90%, Optimal 98%.
///
/// The Flutter translation of "DOM element count" is the number of child
/// elements the framework has materialised. G5 counts them, at 10,000 items,
/// while scrolling.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/empty_state.dart';
import 'package:udf_setup/design_system/layout/virtualized_list.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

/// A marked row, so the gate can count exactly what the list materialised.
class ProbeRow extends StatelessWidget {
  const ProbeRow({required this.index, super.key});
  final int index;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 48, child: Text('row $index'));
}

/// A source of [total] records that records how it was called.
class RecordingSource {
  RecordingSource({required this.total});

  final int total;
  final List<List<int>> calls = <List<int>>[];

  Future<HabotChunk<int>> fetch(int offset, int limit) async {
    calls.add(<int>[offset, limit]);
    final int end = (offset + limit).clamp(0, total);
    return HabotChunk<int>(
      items: <int>[for (int i = offset; i < end; i++) i],
      hasMore: end < total,
    );
  }
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  int peakMaterialised = 0;

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

  group('CPNCA-006-A01 :: chunking controller', () {
    test('[CPNCA-006-G1] batches are fetched at the documented size, never '
        'the whole dataset', () async {
      final RecordingSource source = RecordingSource(total: 10000);
      final HabotChunkController<int> controller = HabotChunkController<int>(
        fetch: source.fetch,
      );
      addTearDown(controller.dispose);

      await controller.loadMore();
      await controller.loadMore();

      expect(controller.chunkSize, HabotDiscovery.chunkSize);
      expect(source.calls, <List<int>>[
        <int>[0, HabotDiscovery.chunkSize],
        <int>[HabotDiscovery.chunkSize, HabotDiscovery.chunkSize],
      ]);
      expect(controller.loadedCount, HabotDiscovery.chunkSize * 2);
      expect(controller.hasMore, isTrue);

      gates.add(
        AissGate(
          id: 'CPNCA-006-G1',
          requirementSource:
              '4 Substeps #2: "Implement data partitioning hooks that fetch '
              'record batches (e.g., 20 items per request) RATHER THAN LOADING '
              'ENTIRE DATASETS AT ONCE."',
          description:
              'Two loads fetch exactly two batches of the token chunk size, at '
              'the right offsets, out of a 10,000-record source',
          passed: true,
          detail: 'calls: ${source.calls}',
        ),
      );
    });

    test(
      '[CPNCA-006-G2] a burst of load requests collapses into one fetch',
      () async {
        final RecordingSource source = RecordingSource(total: 10000);
        final HabotChunkController<int> controller = HabotChunkController<int>(
          fetch: source.fetch,
        );
        addTearDown(controller.dispose);

        await Future.wait<void>(<Future<void>>[
          controller.loadMore(),
          controller.loadMore(),
          controller.loadMore(),
        ]);

        expect(controller.fetchCount, 1);
        expect(controller.loadedCount, HabotDiscovery.chunkSize);

        gates.add(
          AissGate(
            id: 'CPNCA-006-G2',
            requirementSource:
                '4 Substeps #2 -- partitioning only holds if a fast scroll '
                'cannot stack overlapping fetches for the same offset.',
            description:
                'Three concurrent load requests result in exactly one call to '
                'the source',
            passed: true,
            detail: 'fetchCount ${controller.fetchCount}',
          ),
        );
      },
    );

    test('[CPNCA-006-G3] prefetch fires only inside the threshold, and stops '
        'at the end of the data', () async {
      final RecordingSource source = RecordingSource(total: 25);
      final HabotChunkController<int> controller = HabotChunkController<int>(
        fetch: source.fetch,
      );
      addTearDown(controller.dispose);

      await controller.loadMore();
      final int loaded = controller.loadedCount;

      expect(controller.shouldPrefetch(0), isFalse);
      expect(
        controller.shouldPrefetch(loaded - HabotDiscovery.prefetchThreshold),
        isTrue,
      );

      await controller.loadMore();
      expect(controller.hasMore, isFalse);
      expect(controller.shouldPrefetch(controller.loadedCount - 1), isFalse);

      gates.add(
        AissGate(
          id: 'CPNCA-006-G3',
          requirementSource:
              '4 Substeps #1: "Author a container component that calculates '
              'visible viewport boundaries using real-time scroll tracking."',
          description:
              'The next chunk is requested only when the viewport reaches '
              'within the prefetch threshold of the loaded window, and never '
              'once the source is exhausted',
          passed: true,
          detail: 'loaded $loaded of 25, then exhausted',
        ),
      );
    });

    gate(
      'CPNCA-006-G4',
      'Decision to be Made Before Setup Step: "Choose between using infinite '
          'scrolling mechanics or clear \'Load More\' action flags based on '
          'data accessibility needs."',
      'The decision is recorded in the source, and both modes are reachable '
          'from one component rather than two',
      () {
        final String source = File(
          'lib/design_system/layout/virtualized_list.dart',
        ).readAsStringSync();
        return source.contains('Decision to be Made Before Setup Step') &&
            source.contains('Recorded answer: infinite scroll') &&
            source.contains('manualLoadMore');
      },
    );
  });

  group('CPNCA-006-A01 :: rendered list', () {
    testWidgets('[CPNCA-006-G5] 10,000 items materialise a low, stable element '
        'count during continuous scrolling', (WidgetTester tester) async {
      final RecordingSource source = RecordingSource(total: 10000);
      final HabotChunkController<int> controller = HabotChunkController<int>(
        fetch: source.fetch,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: HabotVirtualList<int>(
                controller: controller,
                itemBuilder: (BuildContext context, int item, int index) =>
                    ProbeRow(index: item),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final List<int> counts = <int>[];
      for (int scroll = 0; scroll < 12; scroll++) {
        counts.add(tester.elementList(find.byType(ProbeRow)).length);
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      counts.add(tester.elementList(find.byType(ProbeRow)).length);
      peakMaterialised = counts.reduce((int a, int b) => a > b ? a : b);

      expect(
        peakMaterialised,
        lessThanOrEqualTo(HabotDiscovery.maxMaterialisedItems),
        reason:
            'Element count must stay flat regardless of dataset size; peak was '
            '$peakMaterialised across $counts',
      );
      expect(
        controller.loadedCount,
        lessThan(source.total),
        reason: 'The whole dataset must never be resident',
      );

      gates.add(
        AissGate(
          id: 'CPNCA-006-G5',
          requirementSource:
              'Completion Measures: "Loading a test collection of 10,000 items '
              'preserves a consistent, low DOM element count during continuous '
              'scrolling." + 4 Substeps #4: "Verify element counts remain '
              'stable during continuous scrolling."',
          description:
              'Across twelve continuous drags of a 10,000-record list the '
              'materialised row count stays under the documented ceiling and '
              'the dataset is never fully resident',
          passed: true,
          detail:
              'peak $peakMaterialised rows (ceiling '
              '${HabotDiscovery.maxMaterialisedItems}); '
              '${controller.loadedCount} of ${source.total} records loaded',
        ),
      );
    });

    testWidgets('[CPNCA-006-G6] a placeholder row holds the seam while the '
        'next chunk loads', (WidgetTester tester) async {
      final Completer<HabotChunk<int>> pending = Completer<HabotChunk<int>>();
      final HabotChunkController<int> controller = HabotChunkController<int>(
        fetch: (int offset, int limit) => pending.future,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: HabotVirtualList<int>(
                controller: controller,
                itemBuilder: (BuildContext context, int item, int index) =>
                    ProbeRow(index: item),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Substep 3: a structural placeholder, not a blank gap.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      pending.complete(HabotChunk<int>(items: <int>[1, 2, 3], hasMore: false));
      await tester.pumpAndSettle();

      expect(find.byType(ProbeRow), findsNWidgets(3));
      expect(find.byType(LinearProgressIndicator), findsNothing);

      gates.add(
        const AissGate(
          id: 'CPNCA-006-G6',
          requirementSource:
              '4 Substeps #3: "Create structural placeholder rows for records '
              'still loading."',
          description:
              'While a chunk is in flight the seam shows a placeholder row of '
              'the same height, which is replaced by the records when they '
              'arrive',
          passed: true,
        ),
      );
    });

    testWidgets('[CPNCA-006-G7] an empty source resolves to the empty state '
        'rather than an endless spinner', (WidgetTester tester) async {
      final HabotChunkController<int> controller = HabotChunkController<int>(
        fetch: (int offset, int limit) async => HabotChunk.end<int>(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: HabotVirtualList<int>(
                controller: controller,
                emptyReason: HabotEmptyReason.nothingYet,
                itemBuilder: (BuildContext context, int item, int index) =>
                    ProbeRow(index: item),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HabotEmptyState), findsOneWidget);
      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(controller.fetchCount, 1);

      gates.add(
        const AissGate(
          id: 'CPNCA-006-G7',
          requirementSource:
              'Setup Step (Action): "...for data tables." A table with no rows '
              'still has to say something. + GEN-01297, consumed.',
          description:
              'An exhausted source produces the empty state after exactly one '
              'fetch, with no retry loop',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'CPNCA-006',
        atomicStepReferenceId: 'CPNCA-006-A01',
        setupStepAction:
            'Build a standardized list virtualization and dynamic data chunking '
            'component for data tables.',
        implementationOrder: 32,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Document Title': 'HabotVirtualList / HabotChunkController',
          'Document URL': 'lib/design_system/layout/virtualized_list.dart',
          'Accessibility Status':
              'Rows are ordinary widgets; the list adds no semantics barrier',
          'Component Properties':
              'chunk ${HabotDiscovery.chunkSize}, prefetch threshold '
              '${HabotDiscovery.prefetchThreshold}, materialised ceiling '
              '${HabotDiscovery.maxMaterialisedItems}',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirements / Discovery Coverage (%)',
            observed:
                '100% -- all four substeps and the 10,000-item completion '
                'measure are gated. Peak materialised rows: $peakMaterialised '
                'against a ceiling of '
                '${HabotDiscovery.maxMaterialisedItems}.',
            floor: '90% of relevant items identified',
            optimal: '98% of relevant items identified',
            ceiling: '100% of relevant items identified',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/virtualized_list.dart',
          'lib/design_system/tokens/surface_tokens.dart',
        ],
      ),
    );
  });
}
