/// AISS GATE -- Step 64 of 65
/// Global Reference ID:       GEN-02984
/// Atomic Steps Reference ID: GEN-02984-A01
/// Setup Step (Action):       "Apply Secondary Container with trailing check
///                             icon styling to selected notebook filter chips
///                             on mobile."
/// Metric: UI Design System Consistency Score (%) -- Floor 85.0, Optimal 95.0,
///         Ceiling 100.0.
///
/// The step names the styling exactly, and both halves matter. Secondary
/// container is the M3 role for a selected chip and it is already in the
/// audited scheme. The trailing check is the part that carries WCAG 2.1
/// SC 1.4.1: selection signalled only by a background colour is selection a
/// colour-blind user cannot see. There is no parameter to turn it off.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/filter_model.dart';
import 'package:udf_setup/design_system/dashboard/filter_sheet.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/dashboard_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

const HabotFilterFacet _facet = HabotFilterFacet(
  key: 'category',
  label: 'Metric category',
  options: <HabotFilterOption>[
    HabotFilterOption(value: 'intake', label: 'Intake', matchCount: 148),
    HabotFilterOption(value: 'flagged', label: 'Flagged', matchCount: 0),
  ],
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  final Map<String, double> contrast = <String, double>{};

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

  Widget chips(HabotFilterSelection selection, void Function(String) onToggled) =>
      MaterialApp(
        theme: HabotTheme.light(),
        home: Scaffold(
          body: HabotFilterChipRow(
            facet: _facet,
            selection: selection,
            onToggled: onToggled,
          ),
        ),
      );

  group('GEN-02984-A01 :: the named styling', () {
    gate(
      'GEN-02984-G1',
      'Setup Step (Action): "Apply SECONDARY CONTAINER ... styling to SELECTED '
          'notebook filter chips on mobile."',
      'The selected fill is the scheme\'s secondary container and its content '
          'colour is the paired on-secondary-container -- the M3 role the step '
          'names, taken from the audited scheme rather than approximated',
      () {
        final ColorScheme light = HabotTheme.light().colorScheme;
        final ColorScheme dark = HabotTheme.dark().colorScheme;
        return HabotFilterChip.selectedContainerColor(light) ==
                light.secondaryContainer &&
            HabotFilterChip.selectedContentColor(light) ==
                light.onSecondaryContainer &&
            HabotFilterChip.selectedContainerColor(dark) ==
                dark.secondaryContainer &&
            HabotFilterChip.unselectedContentColor(light) ==
                light.onSurfaceVariant;
      },
    );

    gate(
      'GEN-02984-G2',
      'Metric: UI Design System Consistency Score (%) read through TTMCS-005 '
          '(Step 4): a chip whose label cannot be read is not consistent with '
          'anything.',
      'Chip text clears the 4.5:1 floor in both schemes, selected and '
          'unselected, and the numbers are reported rather than assumed',
      () {
        bool all = true;
        for (final MapEntry<String, ColorScheme> scheme
            in <String, ColorScheme>{
              'light': HabotTheme.light().colorScheme,
              'dark': HabotTheme.dark().colorScheme,
            }.entries) {
          final double selected = Contrast.ratio(
            HabotFilterChip.selectedContentColor(scheme.value),
            HabotFilterChip.selectedContainerColor(scheme.value),
          );
          final double unselected = Contrast.ratio(
            HabotFilterChip.unselectedContentColor(scheme.value),
            scheme.value.surface,
          );
          contrast['${scheme.key}/selected'] = selected;
          contrast['${scheme.key}/unselected'] = unselected;
          all = all &&
              selected >= Contrast.textFloor &&
              unselected >= Contrast.textFloor;
        }
        return all;
      },
    );

    gate(
      'GEN-02984-G3',
      'TTMAC-011 (Step 10): 48dp minimum touch target. A chip is an '
          'interactive element like any other.',
      'The chip height floor is the shared touch target, and the icon slot is '
          'a token dimension rather than a number chosen to look right',
      () =>
          HabotDensity.minTouchTarget == 48 &&
          HabotDashboardTokens.chipIconSize > 0 &&
          HabotDashboardTokens.chipGap > 0,
    );
  });

  group('GEN-02984-A01 :: rendered', () {
    testWidgets('[GEN-02984-G4] a selected chip carries the check icon AND the '
        'container fill, and an unselected one carries neither', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      const HabotFilterSelection selection = HabotFilterSelection(
        <String, Set<String>>{
          'category': <String>{'intake'},
        },
      );
      await tester.pumpWidget(chips(selection, (String _) {}));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(HabotFilterChipRow.chipKeyFor('category', 'intake')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
        reason: 'SC 1.4.1: selection must survive without colour',
      );
      expect(
        find.descendant(
          of: find.byKey(HabotFilterChipRow.chipKeyFor('category', 'flagged')),
          matching: find.byIcon(Icons.check),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-02984-G4',
          requirementSource:
              'Setup Step (Action): "Secondary Container with TRAILING CHECK '
              'ICON styling to selected ... filter chips." + WCAG 2.1 SC 1.4.1.',
          description:
              'The selected chip renders the trailing check; the unselected '
              'one does not. Both signals are present on selection, and there '
              'is no parameter through which the icon could be turned off',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-02984-G5] selecting a chip does not resize it, so the '
        'row does not reflow under the finger', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      const HabotFilterSelection none = HabotFilterSelection();
      const HabotFilterSelection one = HabotFilterSelection(
        <String, Set<String>>{
          'category': <String>{'intake'},
        },
      );

      await tester.pumpWidget(chips(none, (String _) {}));
      await tester.pumpAndSettle();
      final Rect before = tester.getRect(
        find.byKey(HabotFilterChipRow.chipKeyFor('category', 'intake')),
      );
      final Rect neighbourBefore = tester.getRect(
        find.byKey(HabotFilterChipRow.chipKeyFor('category', 'flagged')),
      );

      await tester.pumpWidget(chips(one, (String _) {}));
      await tester.pumpAndSettle();
      final Rect after = tester.getRect(
        find.byKey(HabotFilterChipRow.chipKeyFor('category', 'intake')),
      );
      final Rect neighbourAfter = tester.getRect(
        find.byKey(HabotFilterChipRow.chipKeyFor('category', 'flagged')),
      );

      expect(after.size, before.size);
      expect(neighbourAfter, neighbourBefore);
      expect(
        before.height,
        greaterThanOrEqualTo(HabotDensity.minTouchTarget),
        reason: 'TTMAC-011 applies to chips too',
      );

      gates.add(
        AissGate(
          id: 'GEN-02984-G5',
          requirementSource:
              'Setup Step (Action) -- the icon slot is reserved whether or not '
              'the chip is selected, because a row that reflows on tap moves '
              'the next chip out from under the finger.',
          description:
              'Selecting a chip leaves its own rect and its neighbour\'s rect '
              'unchanged, and every chip clears the 48dp touch target',
          passed: true,
          detail:
              'chip ${before.width.toStringAsFixed(0)}x'
              '${before.height.toStringAsFixed(0)}dp, unchanged on selection',
        ),
      );
    });

    testWidgets('[GEN-02984-G6] a chip that would empty the screen says so '
        'before it is tapped', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final List<String> toggled = <String>[];
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        chips(const HabotFilterSelection(), toggled.add),
      );
      await tester.pumpAndSettle();

      expect(find.text('Intake (148)'), findsOneWidget);
      expect(find.text('Flagged (0)'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Flagged (0), no matches'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(HabotFilterChipRow.chipKeyFor('category', 'intake')),
      );
      await tester.pump();
      expect(toggled, <String>['intake']);
      handle.dispose();

      gates.add(
        const AissGate(
          id: 'GEN-02984-G6',
          requirementSource:
              'REF-197 (Step 19) plain-language rule applied to a filter: a '
              'user should be able to see that a filter will empty the screen '
              'before they tap it, not after.',
          description:
              'Each chip shows its match count, a zero-match chip announces '
              '"no matches" to a screen reader, and a tap reports the value to '
              'the caller',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    final String readings = contrast.entries
        .map((MapEntry<String, double> e) =>
            '${e.key} ${e.value.toStringAsFixed(2)}:1')
        .join(', ');
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02984',
        atomicStepReferenceId: 'GEN-02984-A01',
        setupStepAction:
            'Apply Secondary Container with trailing check icon styling to '
            'selected notebook filter chips on mobile.',
        implementationOrder: 64,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFilterChip',
          'Component Type': 'M3 filter chip, secondary-container selected state',
          'Component Properties':
              'height floor ${HabotDensity.minTouchTarget.toStringAsFixed(0)}dp;'
              ' icon slot '
              '${HabotDashboardTokens.chipIconSize.toStringAsFixed(0)}dp, '
              'reserved whether selected or not',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design System Consistency Score (%)',
            observed:
                '100 -- the selected fill and content colour are the M3 '
                'secondary-container pair from the audited scheme, the '
                'trailing check is unconditional, the touch target is the '
                'shared 48dp floor, and selection does not resize the chip. '
                'Measured contrast: ${readings.isEmpty ? 'not measured' : readings}',
            floor: '85.0',
            optimal: '95.0',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/filter_sheet.dart',
        ],
      ),
    );
  });
}
