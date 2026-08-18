/// AISS GATE -- Step 49 of 50
/// Global Reference ID:       IS22-RCGLA-022-AS01
/// Atomic Steps Reference ID: IS22-RCGLA-022-AS01-A01
/// Setup Step (Action):       "Build and deploy a responsive preference manager
///                             panel inside client settings."
///
/// 4 Substeps, verbatim:
///   1. "Map explicit preference columns (allow_promo, allow_transaction)
///       inside user state tables."
///   2. "Render responsive configuration controls linked directly to these
///       column models."
///   3. "Update user database preferences instantly when sliders change on
///       screen."
///   4. "Connect configuration choices directly to notification dispatch
///       services."
///
/// Poka-Yoke: "Selection inputs freeze screen transitions until changes write
/// to database rows."
/// Completion Measure: "Preference changes write to the database accurately
/// during interface evaluation loops."
/// Atomic Reusability: "NotificationPreferenceSheet UI wrapper block."
///
/// ESTIMATE NOTE, RECORDED: this row's Estimated Time reads "5 Minutes" for a
/// responsive settings panel with database writes, a rollback path and a
/// transition guard. Treated as an estimation error in the sheet rather than
/// as a scope signal; the implementation is sized to the four substeps.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/preferences/preference_manager.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int writesObserved = 0;
  int writesLanded = 0;

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

  Widget panel(PreferenceStore store) => MaterialApp(
    theme: HabotTheme.light(),
    home: Scaffold(body: HabotPreferencePanel(store: store)),
  );

  group('IS22-RCGLA-022 :: substep 1, the column map', () {
    gate(
      'IS22-RCGLA-022-G1',
      'Substep 1: "Map explicit preference columns (ALLOW_PROMO, '
          'ALLOW_TRANSACTION) inside user state tables."',
      'Both named columns exist, spelled exactly as the sheet spells them, and '
          'the set is closed -- a third column cannot be introduced by passing '
          'a string',
      () {
        final List<String> names = HabotPreferenceColumn.values
            .map((HabotPreferenceColumn c) => c.columnName)
            .toList();
        return names.length == 2 &&
            names.contains('allow_promo') &&
            names.contains('allow_transaction') &&
            HabotPreferenceColumn.allowPromo.columnName == 'allow_promo' &&
            HabotPreferenceColumn.allowTransaction.columnName ==
                'allow_transaction';
      },
    );

    gate(
      'IS22-RCGLA-022-G2',
      'Substep 4: "Connect configuration choices directly to NOTIFICATION '
          'DISPATCH SERVICES." A dispatcher reads a record, not a widget.',
      'The store serialises to exactly the two database columns with boolean '
          'values, and transactional messages default on while promotional '
          'ones default off -- a user who has never been asked has not opted '
          'in to marketing, and has not opted out of receipts',
      () {
        final PreferenceStore store = PreferenceStore(
          writer: (HabotPreferenceColumn c, bool v) async =>
              HabotPreferenceWriteResult.written,
        );
        final Map<String, bool> record = store.toRecord();
        return record.length == 2 &&
            record['allow_promo'] == false &&
            record['allow_transaction'] == true &&
            HabotPreferenceColumn.allowTransaction.defaultValue &&
            !HabotPreferenceColumn.allowPromo.defaultValue;
      },
    );
  });

  group('IS22-RCGLA-022 :: substep 3, the instant write', () {
    test('[IS22-RCGLA-022-G3] the switch moves at once and the write follows, '
        'with the column marked in flight until it lands', () async {
      final Completer<HabotPreferenceWriteResult> pending =
          Completer<HabotPreferenceWriteResult>();
      final PreferenceStore store = PreferenceStore(
        writer: (HabotPreferenceColumn c, bool v) {
          writesObserved++;
          return pending.future;
        },
      );

      expect(store.valueOf(HabotPreferenceColumn.allowPromo), isFalse);
      final Future<HabotPreferenceWriteResult> write = store.set(
        HabotPreferenceColumn.allowPromo,
        true,
      );

      expect(
        store.valueOf(HabotPreferenceColumn.allowPromo),
        isTrue,
        reason: 'Substep 3 says INSTANTLY; a control that waits on a round '
            'trip reads as broken',
      );
      expect(store.isWriting, isTrue);
      expect(
        store.isWritingColumn(HabotPreferenceColumn.allowTransaction),
        isFalse,
        reason: 'The freeze is scoped to the column being written',
      );

      pending.complete(HabotPreferenceWriteResult.written);
      expect(await write, HabotPreferenceWriteResult.written);
      writesLanded++;

      expect(store.isWriting, isFalse);
      expect(store.valueOf(HabotPreferenceColumn.allowPromo), isTrue);
      expect(store.toRecord()['allow_promo'], isTrue);
      expect(store.failed, isEmpty);

      gates.add(
        const AissGate(
          id: 'IS22-RCGLA-022-G3',
          requirementSource:
              'Substep 3: "Update user database preferences INSTANTLY when '
              'sliders change on screen."',
          description:
              'The value flips before the writer is awaited, the column is '
              'reported in flight while it is outstanding, and the record '
              'reflects the new value once it lands',
          passed: true,
        ),
      );
    });

    test('[IS22-RCGLA-022-G4] a failed write rolls the value back and says '
        'which column failed', () async {
      final PreferenceStore store = PreferenceStore(
        writer: (HabotPreferenceColumn c, bool v) async {
          writesObserved++;
          return HabotPreferenceWriteResult.failed;
        },
      );

      final HabotPreferenceWriteResult result = await store.set(
        HabotPreferenceColumn.allowTransaction,
        false,
      );

      expect(result, HabotPreferenceWriteResult.failed);
      expect(
        store.valueOf(HabotPreferenceColumn.allowTransaction),
        isTrue,
        reason: 'Completion Measure: preference changes write ACCURATELY. A '
            'switch left in a position the database never accepted is the '
            'inaccuracy the measure is about',
      );
      expect(store.failed, <HabotPreferenceColumn>[
        HabotPreferenceColumn.allowTransaction,
      ]);
      expect(store.isWriting, isFalse);

      gates.add(
        const AissGate(
          id: 'IS22-RCGLA-022-G4',
          requirementSource:
              'Completion Measure: "Preference changes write to the database '
              'ACCURATELY during interface evaluation loops."',
          description:
              'A rejected write restores the previous value and records the '
              'column in the failed list rather than leaving the UI ahead of '
              'the database',
          passed: true,
        ),
      );
    });

    test('[IS22-RCGLA-022-G5] a writer that throws is a failed write, not an '
        'unhandled exception', () async {
      final PreferenceStore store = PreferenceStore(
        writer: (HabotPreferenceColumn c, bool v) async {
          writesObserved++;
          throw StateError('connection lost');
        },
      );

      final HabotPreferenceWriteResult result = await store.set(
        HabotPreferenceColumn.allowPromo,
        true,
      );

      expect(result, HabotPreferenceWriteResult.failed);
      expect(store.valueOf(HabotPreferenceColumn.allowPromo), isFalse);

      gates.add(
        const AissGate(
          id: 'IS22-RCGLA-022-G5',
          requirementSource:
              'Completion Measure -- a settings screen that crashes on a '
              'dropped connection has not written accurately either.',
          description:
              'A writer that throws is folded into the same rollback path as '
              'a rejected write, with no exception escaping the store',
          passed: true,
        ),
      );
    });
  });

  group('IS22-RCGLA-022 :: the poka-yoke', () {
    test('[IS22-RCGLA-022-G6] a screen transition is blocked while a write is '
        'outstanding and released when it lands', () async {
      final Completer<HabotPreferenceWriteResult> pending =
          Completer<HabotPreferenceWriteResult>();
      final PreferenceStore store = PreferenceStore(
        writer: (HabotPreferenceColumn c, bool v) => pending.future,
      );
      final PreferenceTransitionGuard guard = PreferenceTransitionGuard(store);

      expect(guard.mayLeave, isTrue);

      final Future<HabotPreferenceWriteResult> write = store.set(
        HabotPreferenceColumn.allowPromo,
        true,
      );
      expect(
        guard.mayLeave,
        isFalse,
        reason: 'Poka-Yoke: "Selection inputs freeze screen transitions until '
            'changes write to database rows."',
      );

      bool left = false;
      final Future<bool> leaving = guard.requestLeave().then((bool ok) {
        left = true;
        return ok;
      });

      await Future<void>.delayed(Duration.zero);
      expect(
        left,
        isFalse,
        reason: 'The transition is waiting, not abandoned',
      );

      pending.complete(HabotPreferenceWriteResult.written);
      await write;

      expect(await leaving, isTrue);
      expect(guard.mayLeave, isTrue);

      gates.add(
        const AissGate(
          id: 'IS22-RCGLA-022-G6',
          requirementSource:
              'Poka-Yoke: "Selection inputs freeze screen transitions until '
              'changes write to database rows."',
          description:
              'The guard refuses to leave while a write is in flight, resumes '
              'once it lands, and reports success so a failed write can keep '
              'the user on the screen',
          passed: true,
        ),
      );
    });
  });

  group('IS22-RCGLA-022 :: substep 2, the rendered panel', () {
    testWidgets('[IS22-RCGLA-022-G7] one switch per column, each at least the '
        'minimum touch target tall', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final PreferenceStore store = PreferenceStore(
        writer: (HabotPreferenceColumn c, bool v) async =>
            HabotPreferenceWriteResult.written,
      );
      await tester.pumpWidget(panel(store));
      await tester.pumpAndSettle();

      expect(
        find.byType(SwitchListTile),
        findsNWidgets(HabotPreferenceColumn.values.length),
      );
      for (final HabotPreferenceColumn column
          in HabotPreferenceColumn.values) {
        expect(find.text(column.label), findsOneWidget);
        final Size size = tester.getSize(
          find.ancestor(
            of: find.text(column.label),
            matching: find.byType(SwitchListTile),
          ),
        );
        expect(
          size.height,
          greaterThanOrEqualTo(HabotPreferencePanel.rowMinHeight),
          reason: '${column.columnName} row is a touch target like any other',
        );
      }
      expect(
        HabotPreferencePanel.rowMinHeight,
        HabotDensity.minTouchTarget,
        reason: 'TTMAC-011 (Step 12) fixed this number; settings rows are not '
            'an exception to it',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'IS22-RCGLA-022-G7',
          requirementSource:
              'Substep 2: "Render RESPONSIVE configuration controls LINKED '
              'DIRECTLY to these column models." + TTMAC-011 touch target '
              'floor.',
          description:
              'The panel renders exactly one M3 switch per declared column, '
              'each row at or above the 48dp touch target',
          passed: true,
        ),
      );
    });

    testWidgets('[IS22-RCGLA-022-G8] flipping a switch on screen writes the '
        'column, and the control is frozen until it lands', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final Completer<HabotPreferenceWriteResult> pending =
          Completer<HabotPreferenceWriteResult>();
      final List<String> written = <String>[];
      final PreferenceStore store = PreferenceStore(
        writer: (HabotPreferenceColumn c, bool v) {
          written.add('${c.columnName}=$v');
          writesObserved++;
          return pending.future;
        },
      );

      await tester.pumpWidget(panel(store));
      await tester.pumpAndSettle();

      await tester.tap(find.text(HabotPreferenceColumn.allowPromo.label));
      await tester.pump();

      expect(written, <String>['allow_promo=true']);
      final SwitchListTile tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(HabotPreferenceColumn.allowPromo.label),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(tile.value, isTrue, reason: 'the control moved instantly');
      expect(
        tile.onChanged,
        isNull,
        reason: 'and cannot be flipped again until the write lands, so a '
            'double tap cannot race the database',
      );

      pending.complete(HabotPreferenceWriteResult.written);
      await tester.pumpAndSettle();
      writesLanded++;

      final SwitchListTile settled = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(HabotPreferenceColumn.allowPromo.label),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(settled.onChanged, isNotNull);
      expect(store.toRecord()['allow_promo'], isTrue);

      gates.add(
        AissGate(
          id: 'IS22-RCGLA-022-G8',
          requirementSource:
              'Substeps 2 and 3 together, and the Poka-Yoke, measured on the '
              'rendered control rather than on the store alone.',
          description:
              'A tap on the rendered switch writes allow_promo=true, disables '
              'the control until the write lands, and re-enables it afterwards',
          passed: true,
          detail: 'writer calls: ${written.join(', ')}',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'IS22-RCGLA-022-AS01',
        atomicStepReferenceId: 'IS22-RCGLA-022-AS01-A01',
        setupStepAction:
            'Build and deploy a responsive preference manager panel inside '
            'client settings.',
        implementationOrder: 49,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'PreferenceStore / HabotPreferencePanel',
          'Component Type': 'Preference manager panel with M3 switches',
          'Component Properties':
              'columns allow_promo, allow_transaction; optimistic write with '
              'rollback; row floor '
              '${HabotPreferencePanel.rowMinHeight.toStringAsFixed(0)}dp',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'ESTIMATE MISMATCH -- the sheet estimates "5 Minutes" for a '
              'responsive settings panel with database writes, a rollback path '
              'and a transition guard. Recorded as an estimation error; scope '
              'was taken from the four substeps.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Preference write accuracy during interface evaluation loops',
            observed:
                '$writesObserved writes driven through the store and the '
                'rendered panel; $writesLanded accepted and reflected in the '
                'record, the rest rejected or thrown and rolled back with the '
                'column named. No write left the UI ahead of the database.',
            floor: 'every accepted write reflected, every rejected one rolled '
                'back',
            optimal: 'as floor',
            ceiling: 'as floor',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/preferences/preference_manager.dart',
        ],
      ),
    );
  });
}
