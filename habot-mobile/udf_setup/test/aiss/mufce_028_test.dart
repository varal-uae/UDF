/// AISS GATE -- Step 24 of 35
/// Global Reference ID:       MUFCE-028
/// Atomic Steps Reference ID: MUFCE-028-A01
/// Setup Step (Action):       "Mandatory removal of all mouse hover tooltips and
///                             replacement with touch long-press modal sheets."
///
/// 4 Substeps, verbatim:
///   1. "Strip all .onHover logic actions from mobile codebase templates."
///   2. "Bind formula lookup scripts to explicit touch-and-hold gestures."
///   3. "Route rich metadata descriptions to smooth bottom drawer overlays."
///   4. "Set up an alternative quick-tap option icon next to dynamic labels."
///
/// Metric: Environment / Asset Access Readiness
///   Floor "Located on first attempt" / Optimal "Path version-controlled &
///   documented" / Ceiling "N/A (one-time setup)".
///
/// COLUMN CONTAMINATION, RECORDED: this row's Expected Output reads "Asset
/// Loading Optimization Plan" and its Completion Measure is about bandwidth
/// test cycles -- both belong to a different step. Neither is gated below. The
/// Setup Step, the four substeps and the metric are coherent and are what the
/// implementation is measured against.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/interaction/touch_target.dart';
import 'package:udf_setup/design_system/navigation/contextual_header.dart';
import 'package:udf_setup/design_system/surfaces/bottom_sheet.dart';
import 'package:udf_setup/design_system/surfaces/metadata_disclosure.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

const HabotMetadata _metadata = HabotMetadata(
  title: 'Settlement value',
  description:
      'The amount that will move when this batch is released, after fees and '
      'before any manual adjustment.',
  formula: 'gross - fees - held',
  source: 'Ledger, refreshed hourly',
);

List<File> _libDartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart'))
    .toList();

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

  Widget harness(Widget child) => MaterialApp(
    theme: HabotTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  group('MUFCE-028-A01 :: hover removal', () {
    gate(
      'MUFCE-028-G1',
      '4 Substeps #1: "Strip all .onHover logic actions from mobile codebase '
          'templates." + Setup Step: "Mandatory removal of ALL mouse hover '
          'tooltips."',
      'Zero hover callbacks and zero Tooltip widgets exist anywhere under lib/ '
          '-- the removal is complete, not partial',
      () {
        final List<String> offenders = <String>[];
        for (final File file in _libDartFiles()) {
          final String code = file.readAsStringSync();
          if (RegExp(r'\bTooltip\s*\(').hasMatch(code) ||
              RegExp(r'\bonHover\s*:').hasMatch(code)) {
            offenders.add(file.path);
          }
        }
        return offenders.isEmpty;
      },
    );

    gate(
      'MUFCE-028-G2',
      'Setup Step: "...replacement with touch long-press modal sheets." A '
          'removal with no replacement loses the information.',
      'The replacement exists and is the only metadata route: '
          'HabotMetadataDisclosure opens the bottom drawer, and it is what the '
          'touch target now calls',
      () {
        final String touchTarget = File(
          'lib/design_system/interaction/touch_target.dart',
        ).readAsStringSync();
        final String disclosure = File(
          'lib/design_system/surfaces/metadata_disclosure.dart',
        ).readAsStringSync();
        return touchTarget.contains('HabotMetadataDisclosure.show') &&
            !touchTarget.contains('Tooltip(') &&
            disclosure.contains('HabotBottomSheet.show');
      },
    );

    gate(
      'MUFCE-028-G3',
      'Metric: Environment / Asset Access Readiness. Floor "Located on first '
          'attempt", Optimal "Path version-controlled & documented".',
      'The replacement component sits at one documented, version-controlled '
          'path, named in the codebase README',
      () {
        final File component = File(
          'lib/design_system/surfaces/metadata_disclosure.dart',
        );
        final File readme = File('../README.md');
        return component.existsSync() &&
            readme.existsSync() &&
            readme.readAsStringSync().contains('HabotMetadataDisclosure');
      },
    );
  });

  group('MUFCE-028-A01 :: long-press and quick-tap', () {
    testWidgets('[MUFCE-028-G4] a long-press on a touch target routes its '
        'rich metadata to the bottom drawer', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          const HabotTouchTarget(
            semanticLabel: 'Settlement value',
            detail: 'How this number is derived',
            child: Icon(Icons.calculate),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HabotSheetSurface), findsNothing);
      await tester.longPress(find.byType(HabotTouchTarget));
      await tester.pumpAndSettle();

      // Substep 3: the detail arrives in the drawer, not in an overlay tooltip.
      expect(find.byType(HabotSheetSurface), findsOneWidget);
      expect(find.text('How this number is derived'), findsOneWidget);

      gates.add(
        const AissGate(
          id: 'MUFCE-028-G4',
          requirementSource:
              '4 Substeps #2: "Bind formula lookup scripts to explicit '
              'touch-and-hold gestures." + #3: "Route rich metadata '
              'descriptions to smooth bottom drawer overlays."',
          description:
              'Long-press on a touch target opens the metadata drawer carrying '
              'the detail text, with no tooltip anywhere in the tree',
          passed: true,
        ),
      );
    });

    testWidgets('[MUFCE-028-G5] the drawer carries the formula and the source, '
        'which a tooltip could never have held', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          Builder(
            builder: (BuildContext context) => FilledButton(
              onPressed: () => HabotMetadataDisclosure.show(context, _metadata),
              child: const Text('disclose'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('disclose'));
      await tester.pumpAndSettle();

      expect(find.text('Settlement value'), findsOneWidget);
      expect(find.textContaining('after fees'), findsOneWidget);
      expect(find.text('gross - fees - held'), findsOneWidget);
      expect(find.text('Ledger, refreshed hourly'), findsOneWidget);

      gates.add(
        const AissGate(
          id: 'MUFCE-028-G5',
          requirementSource:
              '4 Substeps #2: "Bind FORMULA LOOKUP scripts to explicit '
              'touch-and-hold gestures." + #3: "Route RICH metadata '
              'descriptions to smooth bottom drawer overlays."',
          description:
              'The drawer presents description, derivation formula and source '
              'together -- the full metadata, not a truncated phrase',
          passed: true,
        ),
      );
    });

    testWidgets('[MUFCE-028-G6] a dynamic label carries a quick-tap icon that '
        'meets the 48dp target and opens the same drawer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          const HabotMetadataLabel(
            label: 'Settlement value',
            metadata: _metadata,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder icon = find.byIcon(HabotMetadataLabel.disclosureIcon);
      expect(icon, findsOneWidget);

      final RenderBox target = tester.renderObject<RenderBox>(
        find.byType(HabotTouchTarget),
      );
      expect(
        target.size.width,
        greaterThanOrEqualTo(HabotDensity.minTouchTarget),
      );
      expect(
        target.size.height,
        greaterThanOrEqualTo(HabotDensity.minTouchTarget),
      );

      await tester.tap(icon);
      await tester.pumpAndSettle();
      expect(find.byType(HabotSheetSurface), findsOneWidget);
      expect(find.textContaining('after fees'), findsOneWidget);

      gates.add(
        AissGate(
          id: 'MUFCE-028-G6',
          requirementSource:
              '4 Substeps #4: "Set up an alternative quick-tap option icon next '
              'to dynamic labels."',
          description:
              'The trailing disclosure icon is a compliant touch target and a '
              'single tap opens the same drawer the long-press does',
          passed: true,
          detail:
              'quick-tap target ${target.size.width.toStringAsFixed(0)}x'
              '${target.size.height.toStringAsFixed(0)}dp',
        ),
      );
    });

    testWidgets('[MUFCE-028-G7] the header overflow is a drawer, not a popup '
        'menu -- the last hover tooltip in the app is gone', (
      WidgetTester tester,
    ) async {
      // A PopupMenuButton is wrapped in a Tooltip by the framework with no way
      // to switch it off, so removing hover meant replacing the menu itself.
      for (final File file in _libDartFiles()) {
        expect(
          file.readAsStringSync().contains('PopupMenuButton'),
          isFalse,
          reason: '${file.path} still uses PopupMenuButton',
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            appBar: HabotContextualHeader(
              title: 'Overflow',
              showBack: false,
              actions: <HabotHeaderAction>[
                for (int i = 0; i < 5; i++)
                  HabotHeaderAction(
                    icon: Icons.circle,
                    label: 'Action $i',
                    onPressed: () {},
                  ),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.byType(HabotSheetSurface), findsOneWidget);
      expect(find.text('More actions'), findsOneWidget);

      gates.add(
        const AissGate(
          id: 'MUFCE-028-G7',
          requirementSource:
              'Setup Step: "Mandatory removal of ALL mouse hover tooltips." '
              '+ ANSA-012 UX row: "Hide excessive, low-priority shortcut items '
              'inside unified trailing overflow menus on tight displays."',
          description:
              'The header overflow opens as a bottom drawer and no '
              'PopupMenuButton (which the framework always wraps in a Tooltip) '
              'remains under lib/',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MUFCE-028',
        atomicStepReferenceId: 'MUFCE-028-A01',
        setupStepAction:
            'Mandatory removal of all mouse hover tooltips and replacement '
            'with touch long-press modal sheets.',
        implementationOrder: 24,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Library Name': 'habot_design_system :: surfaces',
          'Library Version': '0.1.0',
          'Component Count':
              '2 (HabotMetadataDisclosure, HabotMetadataLabel) + '
              'HeaderOverflowSheet',
          'Installation Status': 'Installed in place of Tooltip',
          'Library Location Path':
              'lib/design_system/surfaces/metadata_disclosure.dart',
          'Completion Status': 'Derived from gate outcomes',
          'Excluded columns':
              'Expected Output ("Asset Loading Optimization Plan") and '
              'Completion Measures (bandwidth test cycles) are contaminated '
              'and are not gated',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Environment / Asset Access Readiness',
            observed:
                'Path version-controlled and documented -- one component path, '
                'named in the README, with hover reintroduction blocked by the '
                'poka-yoke guard',
            floor: 'Located on first attempt',
            optimal: 'Path version-controlled & documented',
            ceiling: 'N/A (one-time setup)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/surfaces/metadata_disclosure.dart',
          'lib/design_system/interaction/touch_target.dart',
          'lib/design_system/navigation/contextual_header.dart',
          'test/guards/poka_yoke_no_hardcoded_values_test.dart',
        ],
      ),
    );
  });
}
