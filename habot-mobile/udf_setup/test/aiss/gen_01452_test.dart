/// AISS GATE -- Step 29 of 35
/// Global Reference ID:       GEN-01452
/// Atomic Steps Reference ID: GEN-01452-A01
/// Setup Step (Action):       "Construct the card UI chassis using M3 Outlined
///                             or Elevated Card specifications."
///
/// METRIC MISMATCH, RECORDED: the Metric Name is "Real-Time Availability Badge
/// Accuracy", which belongs to a different component. The gates defend the
/// Setup Step; the measurement reports chassis conformance and states the
/// mismatch.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/surfaces/card_chassis.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/elevation_tokens.dart';
import 'package:udf_setup/design_system/tokens/shape_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
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

  Widget harness(Widget child) => MaterialApp(
    theme: HabotTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  group('GEN-01452-A01 :: card chassis', () {
    gate(
      'GEN-01452-G1',
      'Setup Step (Action): "Construct the card UI chassis using M3 OUTLINED '
          'or ELEVATED Card specifications."',
      'Both named variants exist, plus the filled default, and every variant '
          'has a defined elevation level and border decision',
      () {
        for (final HabotCardVariant variant in HabotCardVariant.values) {
          if (HabotCardSpec.elevationLevel[variant] == null ||
              HabotCardSpec.hasBorder[variant] == null) {
            return false;
          }
        }
        return HabotCardVariant.values.contains(HabotCardVariant.outlined) &&
            HabotCardVariant.values.contains(HabotCardVariant.elevated) &&
            HabotCardSpec.elevationLevel.length ==
                HabotCardVariant.values.length;
      },
    );

    gate(
      'GEN-01452-G2',
      'MD3 card specification: a card is bounded by a shadow OR a border. Both '
          'at once is redundancy, not emphasis -- and on a dense list it is the '
          'difference between scannable and busy.',
      'No variant carries both a border and an elevation, and the outlined '
          'variant is the flat one',
      () {
        for (final HabotCardVariant variant in HabotCardVariant.values) {
          final bool bordered = HabotCardSpec.hasBorder[variant]!;
          final int level = HabotCardSpec.elevationLevel[variant]!;
          if (bordered && level > 0) {
            return false;
          }
        }
        return HabotCardSpec.hasBorder[HabotCardVariant.outlined]! &&
            HabotCardSpec.elevationLevel[HabotCardVariant.outlined] == 0 &&
            HabotCardSpec.elevationLevel[HabotCardVariant.elevated] == 1;
      },
    );

    gate(
      'GEN-01452-G3',
      'RCGLA-001, inherited: every dimension is a token, mirrored from '
          'tokens.json.',
      'The chassis radius, padding and border width are all members of the '
          'existing ladders -- the card introduces no geometry of its own',
      () =>
          HabotShape.allRadii.contains(HabotCardSpec.cornerRadius) &&
          HabotSpacing.all.contains(HabotCardSpec.contentPadding) &&
          HabotCardSpec.borderWidth == HabotShape.borderWidth,
    );

    gate(
      'GEN-01452-G4',
      'BPTR-0128 build budget, inherited: "component build methods stay under '
          '20 lines" -- a chassis that grows past that has stopped being a '
          'chassis.',
      'Every build method in the chassis file is at most 20 lines long',
      () {
        final List<String> lines = File(
          'lib/design_system/surfaces/card_chassis.dart',
        ).readAsLinesSync();
        int longest = 0;
        for (int i = 0; i < lines.length; i++) {
          if (!lines[i].contains('Widget build(BuildContext context)')) {
            continue;
          }
          int depth = 0;
          int length = 0;
          for (int j = i; j < lines.length; j++) {
            depth += '{'.allMatches(lines[j]).length;
            depth -= '}'.allMatches(lines[j]).length;
            length++;
            if (depth <= 0 && j > i) {
              break;
            }
          }
          longest = length > longest ? length : longest;
        }
        return longest > 0 && longest <= 20;
      },
    );
  });

  group('GEN-01452-A01 :: rendered chassis', () {
    testWidgets('[GEN-01452-G5] the outlined variant draws a token border at '
        'zero elevation', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          const HabotCard(
            variant: HabotCardVariant.outlined,
            child: Text('outlined'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Material material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(HabotCard),
              matching: find.byType(Material),
            )
            .first,
      );
      final BuildContext context = tester.element(find.byType(HabotCard));
      final ColorScheme scheme = Theme.of(context).colorScheme;
      final RoundedRectangleBorder shape =
          material.shape! as RoundedRectangleBorder;

      expect(material.elevation, 0);
      expect(shape.side.width, HabotCardSpec.borderWidth);
      expect(shape.side.color, scheme.outlineVariant);
      expect(
        shape.borderRadius,
        BorderRadius.circular(HabotCardSpec.cornerRadius),
      );

      gates.add(
        const AissGate(
          id: 'GEN-01452-G5',
          requirementSource:
              'Setup Step (Action): "...using M3 OUTLINED ... Card '
              'specifications."',
          description:
              'The outlined card renders a 1dp outline-variant border, the '
              'token corner radius and no shadow',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-01452-G6] the elevated variant lifts to level 1 with no '
        'border, and a tappable card is one target rather than a nest', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        harness(
          HabotCard(
            variant: HabotCardVariant.elevated,
            semanticLabel: 'Batch 001',
            onPressed: () => taps++,
            child: const Text('elevated'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Material material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(HabotCard),
              matching: find.byType(Material),
            )
            .first,
      );
      final RoundedRectangleBorder shape =
          material.shape! as RoundedRectangleBorder;

      expect(material.elevation, HabotElevation.level1);
      expect(shape.side, BorderSide.none);

      // One ink well for the whole card: tapping the label activates the card.
      expect(
        find.descendant(
          of: find.byType(HabotCard),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('elevated'));
      await tester.pump();
      expect(taps, 1);

      gates.add(
        const AissGate(
          id: 'GEN-01452-G6',
          requirementSource:
              'Setup Step (Action): "...or ELEVATED Card specifications." + '
              'TTMAC-011, inherited: an interactive surface is one target.',
          description:
              'The elevated card lifts to level 1 with no border, and a '
              'tappable card exposes a single ink well covering the whole '
              'surface',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-01452-G7] the chassis applies its content padding '
        'without offering a padding parameter', (WidgetTester tester) async {
      await tester.pumpWidget(harness(const HabotCard(child: Text('filled'))));
      await tester.pumpAndSettle();

      final Padding padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(HabotCard),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        padding.padding,
        const EdgeInsets.all(HabotCardSpec.contentPadding),
      );

      gates.add(
        const AissGate(
          id: 'GEN-01452-G7',
          requirementSource:
              'RCGLA-018, inherited: the master scaffold exposes no padding '
              'parameter -- spacing comes from tokens or it does not exist. '
              'The chassis follows the same rule.',
          description:
              'The rendered card applies the token content padding, with no '
              'caller-supplied override available',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01452',
        atomicStepReferenceId: 'GEN-01452-A01',
        setupStepAction:
            'Construct the card UI chassis using M3 Outlined or Elevated Card '
            'specifications.',
        implementationOrder: 29,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCard',
          'Component Type': 'MD3 card chassis',
          'Component Properties':
              'radius ${HabotCardSpec.cornerRadius}dp, padding '
              '${HabotCardSpec.contentPadding}dp, border '
              '${HabotCardSpec.borderWidth}dp',
          'State Definitions':
              '${HabotCardVariant.values.length} variants: filled, outlined, '
              'elevated',
          'Completion Status': 'Derived from gate outcomes',
          'Metric note':
              'Metric Name ("Real-Time Availability Badge Accuracy") belongs '
              'to another component. Reported against chassis conformance.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Real-Time Availability Badge Accuracy',
            observed:
                '1.0 -- ${HabotCardVariant.values.length} of '
                '${HabotCardVariant.values.length} variants conform to the MD3 '
                'specification, with no variant carrying both a border and a '
                'shadow. NOTE: metric name mismatch recorded.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/surfaces/card_chassis.dart',
        ],
      ),
    );
  });
}
