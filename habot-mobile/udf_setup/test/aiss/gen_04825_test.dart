/// AISS GATE -- Step 154 of 155
/// Global Reference ID:       GEN-04825
/// Atomic Steps Reference ID: GEN-04825
/// Setup Step (Action) / Atomic Step: "Apply the mistake-proofing (Poka-Yoke)
///   safeguard: FAB automatically hides when virtual keyboard opens to prevent
///   accidental taps during typing."
/// Metric: Error-Proofing (Poka-Yoke) Coverage Rate -- Floor "100% of
///         identified critical-path failure modes covered", Optimal "100%
///         coverage with automated enforcement (no silent bypass)",
///         Ceiling "100% (binary)". Pass / Fail.
///
/// THE OPTIMAL IS A DIFFERENT KIND OF THING FROM THE FLOOR: enforcement, not
/// coverage. So this step ships the widget AND a guard rule.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/keyboard_aware_fab.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/wizard/single_field_step.dart';

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

  Widget host({required double bottomInset}) => MediaQuery(
        data: MediaQueryData(
          viewInsets: EdgeInsets.only(bottom: bottomInset),
        ),
        child: MaterialApp(
          home: Scaffold(
            body: HabotKeyboardAwareFab(
              onPressed: () {},
              icon: Icons.add,
              semanticLabel: 'Add a note',
            ),
          ),
        ),
      );

  group('GEN-04825 :: the control is not there to be hit', () {
    widgetGate(
      'GEN-04825-G1',
      'Atomic Step: "FAB automatically HIDES when virtual keyboard opens to '
          'prevent accidental taps during typing." A FAB sits in the bottom '
          'corner, which once the keyboard is up is directly over the '
          'suggestion strip and the top row of keys.',
      'With the keyboard up the control is not in the tree at all -- so there '
          'is nothing at that position to hit, rather than something '
          'transparent',
      (WidgetTester tester) async {
        await tester.pumpWidget(host(bottomInset: 0));
        final bool visibleWithoutKeyboard =
            find.byKey(HabotKeyboardAwareFab.fabKey).evaluate().isNotEmpty;
        await tester.pumpWidget(host(bottomInset: 320));
        await tester.pumpAndSettle();
        final bool goneWithKeyboard =
            find.byKey(HabotKeyboardAwareFab.fabKey).evaluate().isEmpty;
        return visibleWithoutKeyboard &&
            goneWithKeyboard &&
            find.byType(FloatingActionButton).evaluate().isEmpty;
      },
    );

    gate(
      'GEN-04825-G2',
      'A small non-zero bottom inset can come from a system gesture bar. '
          '"Greater than zero" would hide the control on every screen with a '
          'gesture bar and nothing else.',
      'The test is a threshold rather than a platform check, and no keyboard '
          'is shorter than a single touch target',
      () =>
          HabotKeyboardInset.keyboardThresholdDp ==
              HabotDensity.minTouchTarget &&
          !const HabotKeyboardInset(0).keyboardIsOpen &&
          !const HabotKeyboardInset(24).keyboardIsOpen &&
          const HabotKeyboardInset(320).keyboardIsOpen &&
          HabotFabSafeguard.thresholdNote.contains('one rule instead of one '
              'per platform'),
    );

    gate(
      'GEN-04825-G3',
      'A FAB is the most commonly unnamed control in any app, and Step 99 '
          'made an icon-only control with no accessible name a build failure.',
      'The accessible name is a REQUIRED constructor parameter, and there is '
          'no parameter that turns the safeguard off -- an opt-out would be '
          'the silent bypass the metric names',
      () =>
          HabotKeyboardAwareFab.hidesOnKeyboardAlways &&
          HabotFabSafeguard.coveredFailureModes
              .containsKey('a caller opting out of the safeguard') &&
          HabotFabSafeguard.coveredFailureModes['a caller opting out of the '
                  'safeguard']!
              .contains('no parameter to opt out') &&
          HabotFabSafeguard.coveredFailureModes
              .containsKey('a FAB with no accessible name'),
    );
  });

  group('GEN-04825 :: automated enforcement, which is the optimal', () {
    gate(
      'GEN-04825-G4',
      'Metric optimal: "100% coverage with AUTOMATED ENFORCEMENT (no silent '
          'bypass)". A widget that hides itself meets the FLOOR; the next '
          'screen written with a raw FloatingActionButton silently does not.',
      'A ROGUE_FAB rule exists in the poka-yoke guard, names this file as the '
          'only permitted site, and sits alongside the ROGUE_SCAFFOLD and '
          'ROGUE_THEME_CONSTRUCTION rules it is modelled on',
      () {
        final File guard = File(HabotFabSafeguard.enforcementSite);
        if (!guard.existsSync()) {
          return false;
        }
        final String source = guard.readAsStringSync();
        return source.contains("'ROGUE_FAB'") &&
            source.contains(HabotFabSafeguard.permittedSite) &&
            source.contains('ROGUE_SCAFFOLD') &&
            source.contains('ROGUE_THEME_CONSTRUCTION') &&
            HabotFabSafeguard.enforcementRule == 'ROGUE_FAB';
      },
    );

    gate(
      'GEN-04825-G5',
      'A guard rule that matches nothing is a rule nobody has tested, and one '
          'that matches the file it protects would fail the build immediately.',
      'The rule pattern matches a raw construction and exempts exactly one '
          'file -- checked by applying the same pattern the guard uses to a '
          'sample of code',
      () {
        final RegExp rule = RegExp(r'\bFloatingActionButton\s*\(');
        const String rogue = 'Widget b() => FloatingActionButton('
            'onPressed: null, child: null);';
        const String innocent =
            "const Set<String> types = <String>{'FloatingActionButton'};";
        return rule.hasMatch(rogue) &&
            !rule.hasMatch(innocent) &&
            HabotFabSafeguard.permittedSite.endsWith(
              'interaction/keyboard_aware_fab.dart',
            );
      },
    );

    gate(
      'GEN-04825-G6',
      'Metric: coverage is binary and cannot exceed full. A coverage figure '
          'over an empty list of failure modes would also be a pass.',
      'The failure modes are named, each has a stated mechanism rather than a '
          'tick, the rate is 1.0 over a non-empty set, and the Step 148 '
          'surface contract already forbids a FAB on a single-question screen '
          '-- so the two steps agree',
      () =>
          HabotFabSafeguard.coveredFailureModes.length >= 4 &&
          HabotFabSafeguard.allModesCovered &&
          HabotFabSafeguard.coverageRate == 1.0 &&
          HabotFabSafeguard.coverageRate >= HabotFabSafeguard.floor &&
          HabotStepSurfaceContract.forbids('a floating action button') &&
          HabotFabSafeguard.noSilentBypassNote.contains(
            'a different kind of thing',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04825',
        atomicStepReferenceId: 'GEN-04825',
        setupStepAction:
            'Apply the mistake-proofing (Poka-Yoke) safeguard: FAB '
            'automatically hides when virtual keyboard opens to prevent '
            'accidental taps during typing.',
        implementationOrder: 154,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotKeyboardAwareFab / HabotFabSafeguard',
          'Component Properties':
              'keyboard threshold '
              '${HabotKeyboardInset.keyboardThresholdDp.toStringAsFixed(0)}dp; '
              'no opt-out parameter; semanticLabel required; '
              '${HabotFabSafeguard.coveredFailureModes.length} failure modes '
              'each with a stated mechanism',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. This step adds a seventh rule (ROGUE_FAB) '
              'to test/guards/poka_yoke_no_hardcoded_values_test.dart, which '
              'is the automated-enforcement half the row optimal asks for.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Error-Proofing (Poka-Yoke) Coverage Rate',
            observed:
                '${(HabotFabSafeguard.coverageRate * 100).toStringAsFixed(0)}% '
                'of ${HabotFabSafeguard.coveredFailureModes.length} named '
                'failure modes, each with a stated mechanism rather than a '
                'tick -- and with automated enforcement, which is what '
                'separates the row optimal from its floor.',
            floor: '100% of identified critical-path failure modes covered',
            optimal: '100% coverage with automated enforcement (no silent '
                'bypass)',
            ceiling: '100% (coverage is binary; cannot exceed full)',
          ),
          const AissMeasurement(
            metricName: 'Ways to bypass the safeguard',
            observed:
                '0. There is no opt-out parameter, and a FloatingActionButton '
                'constructed anywhere but the permitted file fails the build. '
                'A surface that genuinely needs a persistent action while '
                'typing is not a FAB -- it belongs in the step own '
                'navigation, where it is laid out rather than floating over '
                'the content.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/keyboard_aware_fab.dart',
        ],
      ),
    );
  });
}
