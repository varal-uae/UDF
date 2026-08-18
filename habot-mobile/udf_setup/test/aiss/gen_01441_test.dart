/// AISS GATE -- Step 63 of 65
/// Global Reference ID:       GEN-01441
/// Atomic Steps Reference ID: GEN-01441-A01
/// Setup Step (Action):       "Construct a slide-up filter sheet using the M3
///                             Modal Bottom Sheet component with a drag
///                             handle."
/// Metric: Filter Application Latency -- Floor <1s, Optimal <300ms,
///         Ceiling <2s.
///
/// The gate that matters is G1: this must BE `HabotBottomSheet` from Steps
/// 21-23, which already owns the 32% scrim, the 30/60/95 snap ladder and the
/// drag handle at 32x4dp. A second modal sheet here would duplicate four
/// separately-gated decisions and fail the poka-yoke guard on the first raw
/// value it needed.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/filter_model.dart';
import 'package:udf_setup/design_system/dashboard/filter_sheet.dart';
import 'package:udf_setup/design_system/surfaces/bottom_sheet.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

const HabotFilterFacet _facet = HabotFilterFacet(
  key: 'category',
  label: 'Metric category',
  options: <HabotFilterOption>[
    HabotFilterOption(value: 'intake', label: 'Intake', matchCount: 148),
    HabotFilterOption(value: 'accuracy', label: 'Accuracy', matchCount: 12),
    HabotFilterOption(value: 'flagged', label: 'Flagged', matchCount: 0),
  ],
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  Duration applyTime = Duration.zero;

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

  group('GEN-01441-A01 :: it is the existing sheet', () {
    gate(
      'GEN-01441-G1',
      'Setup Step (Action): "using the M3 MODAL BOTTOM SHEET COMPONENT with a '
          'DRAG HANDLE." + GEN-00055 / GEN-00954 / GEN-00235 (Steps 21-23), '
          'which already gated the chassis, the scrim and the snap point.',
      'The filter sheet routes through HabotBottomSheet and calls no modal '
          'sheet API of its own, so it inherits the 32% scrim, the snap ladder '
          'and the token-sized drag handle rather than declaring them again',
      () {
        final String source = File(
          'lib/design_system/dashboard/filter_sheet.dart',
        )
            .readAsStringSync()
            .split('\n')
            .map((String line) {
              final int i = line.indexOf('//');
              return i == -1 ? line : line.substring(0, i);
            })
            .join('\n');
        return source.contains('HabotBottomSheet.show<HabotFilterSelection>') &&
            !source.contains('showModalBottomSheet') &&
            !source.contains('BottomSheet(') &&
            HabotSheet.scrimOpacity == 0.32 &&
            HabotSheet.snapFractions.contains(HabotSheet.defaultSnapFraction) &&
            HabotSheet.dragHandleWidth > 0;
      },
    );
  });

  group('GEN-01441-A01 :: the selection model', () {
    gate(
      'GEN-01441-G2',
      'Setup Step (Action) -- a filter sheet whose selection is a mutable '
          'blob shared with the dashboard is how a cancelled edit still '
          'applies itself.',
      'Every mutation returns a NEW selection, values within a facet are '
          'OR-ed and facets are AND-ed, and two selections holding the same '
          'values compare equal so a no-op apply can be detected',
      () {
        const HabotFilterSelection empty = HabotFilterSelection();
        final HabotFilterSelection one = empty.toggle('category', 'intake');
        final HabotFilterSelection two = one.toggle('category', 'accuracy');
        final HabotFilterSelection back = two.toggle('category', 'accuracy');
        return empty.isEmpty &&
            !one.isEmpty &&
            one.activeCount == 1 &&
            two.activeCount == 2 &&
            back == one &&
            back.hashCode == one.hashCode &&
            !identical(back, one) &&
            empty.isEmpty &&
            two.clear().isEmpty;
      },
    );

    gate(
      'GEN-01441-G3',
      'Metric: Filter Application Latency -- Floor <1s, Optimal <300ms. '
          'Applying a filter is a pure function over rows already in memory: '
          'there is no round trip to be slow.',
      'Applying a two-facet selection over ten thousand rows completes well '
          'inside the optimal band, and the OR-within / AND-across semantics '
          'are what is actually applied',
      () {
        final List<Map<String, String>> rows = <Map<String, String>>[
          for (int i = 0; i < 10000; i++)
            <String, String>{
              'category': <String>['intake', 'accuracy', 'flagged'][i % 3],
              'shift': i.isEven ? 'day' : 'night',
            },
        ];
        const HabotFilterSelection selection = HabotFilterSelection(
          <String, Set<String>>{
            'category': <String>{'intake', 'accuracy'},
            'shift': <String>{'day'},
          },
        );
        final Stopwatch clock = Stopwatch()..start();
        final List<Map<String, String>> filtered = selection.apply(
          rows,
          (Map<String, String> row, String key) => row[key] ?? '',
        );
        clock.stop();
        applyTime = clock.elapsed;

        final bool semanticsCorrect = filtered.every(
          (Map<String, String> r) =>
              (r['category'] == 'intake' || r['category'] == 'accuracy') &&
              r['shift'] == 'day',
        );
        return semanticsCorrect &&
            filtered.isNotEmpty &&
            filtered.length < rows.length &&
            applyTime < const Duration(milliseconds: 300);
      },
    );
  });

  group('GEN-01441-A01 :: rendered', () {
    testWidgets('[GEN-01441-G4] the sheet slides up, edits a selection and '
        'returns it, and a dismissal returns nothing', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      HabotFilterSelection? applied;
      bool opened = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () async {
                  opened = true;
                  applied = await HabotFilterSheet.show(
                    context: context,
                    facets: const <HabotFilterFacet>[_facet],
                    selection: const HabotFilterSelection(),
                  );
                },
                child: const Text('open filters'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open filters'));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
      expect(find.byKey(HabotFilterSheet.sheetKey), findsOneWidget);
      expect(find.text(HabotFilterSheet.title), findsWidgets);
      expect(find.text('Show all'), findsOneWidget);

      await tester.tap(
        find.byKey(HabotFilterChipRow.chipKeyFor('category', 'intake')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Apply 1'), findsOneWidget);

      await tester.tap(find.byKey(HabotFilterSheet.applyKey));
      await tester.pumpAndSettle();

      expect(find.byKey(HabotFilterSheet.sheetKey), findsNothing);
      expect(applied, isNotNull);
      expect(applied!.isSelected('category', 'intake'), isTrue);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-01441-G4',
          requirementSource:
              'Setup Step (Action): "Construct a SLIDE-UP FILTER SHEET using '
              'the M3 Modal Bottom Sheet component with a drag handle."',
          description:
              'The sheet opens over the dashboard, the apply button reflects '
              'the pending count, and applying returns the edited selection to '
              'the caller',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-01441-G5] clearing inside the sheet is not the same as '
        'dismissing it', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      HabotFilterSelection? result;
      bool returned = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () async {
                  result = await HabotFilterSheet.show(
                    context: context,
                    facets: const <HabotFilterFacet>[_facet],
                    selection: const HabotFilterSelection(
                      <String, Set<String>>{
                        'category': <String>{'intake'},
                      },
                    ),
                  );
                  returned = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(HabotFilterSheet.clearKey));
      await tester.pumpAndSettle();
      expect(find.text('Show all'), findsOneWidget);
      await tester.tap(find.byKey(HabotFilterSheet.applyKey));
      await tester.pumpAndSettle();

      expect(returned, isTrue);
      expect(
        result,
        isNotNull,
        reason: 'Clearing then applying returns an EMPTY selection...',
      );
      expect(result!.isEmpty, isTrue);

      // Now dismiss without applying.
      returned = false;
      result = const HabotFilterSelection();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(HabotFilterSheet.clearKey));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byKey(HabotFilterSheet.sheetKey))).pop();
      await tester.pumpAndSettle();

      expect(returned, isTrue);
      expect(
        result,
        isNull,
        reason: '...while dismissing returns null, so a cancelled edit does '
            'not silently clear the dashboard',
      );

      gates.add(
        const AissGate(
          id: 'GEN-01441-G5',
          requirementSource:
              'Setup Step (Action) -- a modal that cannot distinguish "I chose '
              'nothing" from "I changed my mind" will apply one as the other.',
          description:
              'Clearing then applying returns an empty selection; dismissing '
              'returns null, and the caller can tell them apart',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01441',
        atomicStepReferenceId: 'GEN-01441-A01',
        setupStepAction:
            'Construct a slide-up filter sheet using the M3 Modal Bottom Sheet '
            'component with a drag handle.',
        implementationOrder: 63,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFilterSheet',
          'Component Type': 'M3 modal bottom sheet (reused from Steps 21-23)',
          'Component Properties':
              'scrim ${(HabotSheet.scrimOpacity * 100).toStringAsFixed(0)}%, '
              'default snap '
              '${(HabotSheet.defaultSnapFraction * 100).toStringAsFixed(0)}%, '
              'drag handle ${HabotSheet.dragHandleWidth.toStringAsFixed(0)}x'
              '${HabotSheet.dragHandleHeight.toStringAsFixed(0)}dp -- all '
              'inherited, none redeclared',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Filter Application Latency',
            observed:
                '${applyTime.inMicroseconds / 1000}ms to apply a two-facet '
                'selection over 10,000 rows on the test host. Applying is a '
                'pure function over rows already in memory, so the budget is a '
                'property of the algorithm rather than of the network. Not a '
                'handset reading.',
            floor: '<1s',
            optimal: '<300ms',
            ceiling: '<2s',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/filter_model.dart',
          'lib/design_system/dashboard/filter_sheet.dart',
        ],
      ),
    );
  });
}
