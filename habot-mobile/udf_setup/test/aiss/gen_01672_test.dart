/// AISS GATE -- Step 217 of 235
/// Global Reference ID:       GEN-01672
/// Atomic Steps Reference ID: GEN-01672
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure Modifier.sizeIn to enforce programmatic minimums."
/// Metric: Automated PR Rejection Rate for Non-Compliance (%) -- Floor 95,
///         Optimal 99.5, Ceiling 100. High/Medium/Low.
///
/// THE ROW ASKS FOR A WIDGET AND THE METRIC ASKS FOR A CI GATE. The second is
/// what makes the first stick, and it has to see something a source-reading
/// linter cannot: the parent a minimum will be clamped by.
library;

import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/size_constraints.dart';
import 'package:udf_setup/design_system/tokens/touch_target_band.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double rejection = 0;
  double sourceOnly = 0;

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

  const HabotConstraintPair roomy = HabotConstraintPair(
    minWidthDp: 0,
    maxWidthDp: 360,
    minHeightDp: 0,
    maxHeightDp: 200,
  );
  const HabotConstraintPair toolbarRow = HabotConstraintPair(
    minWidthDp: 0,
    maxWidthDp: 360,
    minHeightDp: 0,
    maxHeightDp: 40,
  );

  group('GEN-01672 :: the minimums', () {
    gate(
      'GEN-01672-G1',
      'Atomic Step: "Configure MODIFIER.SIZEIN to enforce programmatic '
          'minimums." Modifier.sizeIn is Jetpack Compose.',
      'The substitution names both APIs and says what ports and what does not '
          '-- the behaviour and the failure mode port, the name does not',
      () =>
          HabotSizeConstraints.composeApi == 'Modifier.sizeIn' &&
          HabotSizeConstraints.flutterApi.contains('BoxConstraints') &&
          HabotSizeConstraints.substitution.contains('Jetpack Compose') &&
          HabotSizeConstraints.substitution.contains('clamped'),
    );

    gate(
      'GEN-01672-G2',
      '"A minimum applied at one call site is a minimum somebody forgot at the '
          'next."',
      'Every control kind has a declared minimum with a rationale, and every '
          'one is derived from the Step 184 band rather than written as a '
          'number -- so the figure lives in one place and six kinds read it',
      () =>
          HabotControlKind.values.length == 6 &&
          HabotSizeConstraints.minimums.length == 6 &&
          HabotSizeConstraints.minimums.every(
            (HabotControlMinimum m) => m.rationale.length > 40,
          ) &&
          HabotSizeConstraints.minimumFor(HabotControlKind.iconButton)
                  .minHeightDp ==
              HabotTouchBand.optimalDp &&
          HabotSizeConstraints.minimumFor(HabotControlKind.textField)
                  .minHeightDp ==
              HabotTouchBand.ceilingDp,
    );

    gate(
      'GEN-01672-G3',
      'A kind whose minimum exceeds the band ceiling has to argue for it.',
      'The navigation destination is the only minimum above the band ceiling, '
          'and its rationale names the MD3 figure and the step that resolves '
          'the disagreement',
      () {
        final List<HabotControlMinimum> aboveCeiling =
            HabotSizeConstraints.minimums
                .where(
                  (HabotControlMinimum m) =>
                      m.minHeightDp > HabotTouchBand.ceilingDp,
                )
                .toList();
        return aboveCeiling.length == 1 &&
            aboveCeiling.single.kind ==
                HabotControlKind.navigationDestination &&
            aboveCeiling.single.minHeightDp == 64 &&
            aboveCeiling.single.rationale.contains('Step 228');
      },
    );

    gate(
      'GEN-01672-G4',
      'A list row takes the width it is given.',
      'Only the axis that needs constraining is constrained -- the list row '
          'has a zero width minimum and a band-optimal height minimum -- so a '
          'minimum is not applied to an axis nothing was going to violate',
      () {
        final HabotControlMinimum row =
            HabotSizeConstraints.minimumFor(HabotControlKind.listRow);
        return row.minWidthDp == 0 &&
            row.minHeightDp == HabotTouchBand.optimalDp &&
            HabotSizeConstraints.isCompliant(
              HabotControlKind.listRow,
              const Size(360, 48),
            ) &&
            !HabotSizeConstraints.isCompliant(
              HabotControlKind.listRow,
              const Size(360, 40),
            );
      },
    );
  });

  group('GEN-01672 :: the gate, and what a source linter cannot see', () {
    gate(
      'GEN-01672-G5',
      '"Flutter does not throw when a minimum exceeds the incoming maximum -- '
          'BoxConstraints.enforce clamps it."',
      'A 48dp minimum is satisfiable in a roomy parent and not inside a 40dp '
          'toolbar row, and the unsatisfiable case is reported rather than '
          'left to be clamped away where no source reading can find it',
      () =>
          HabotSizeConstraints.isSatisfiableWithin(
            HabotControlKind.iconButton,
            roomy,
          ) &&
          !HabotSizeConstraints.isSatisfiableWithin(
            HabotControlKind.iconButton,
            toolbarRow,
          ) &&
          roomy.isSelfConsistent &&
          toolbarRow.isSelfConsistent &&
          HabotSizeConstraints.silentClampNote
              .contains('a source-reading linter can never catch'),
    );

    gate(
      'GEN-01672-G6',
      'A refusal a developer cannot act on is a build failure with a stack '
          'trace attached.',
      'Every refusal names the declared size, the minimum it missed and the '
          'rationale for that minimum, and a compliant control produces no '
          'refusal at all',
      () {
        final String refusal = HabotSizeConstraints.refusalFor(
          HabotControlKind.iconButton,
          const Size(24, 24),
        );
        return refusal.contains('24x24dp') &&
            refusal.contains('48x48dp') &&
            refusal.contains('no text') &&
            HabotSizeConstraints.refusalFor(
              HabotControlKind.iconButton,
              const Size(48, 48),
            ).isEmpty;
      },
    );

    gate(
      'GEN-01672-G7',
      'Metric: Automated PR Rejection Rate for Non-Compliance (%) -- floor 95, '
          'optimal 99.5.',
      'This gate rejects every genuine failure in the probe set, giving 100; a '
          'linter that only reads declared sizes reaches 75, below the row\'s '
          'own floor, because the compliant icon button inside a 40dp '
          'toolbar row looks correct in the source and is clamped to 40dp on '
          'the screen',
      () {
        rejection = HabotSizeConstraints.rejectionRate;
        sourceOnly = HabotSizeConstraints.sourceOnlyRejectionRate;
        return HabotSizeConstraints.probeSet.length == 6 &&
            HabotSizeConstraints.genuineFailures.length == 4 &&
            rejection == 100 &&
            rejection >= HabotSizeConstraints.optimal &&
            (sourceOnly - 75).abs() < 1e-9 &&
            sourceOnly < HabotSizeConstraints.floor &&
            HabotSizeConstraints.escapesASourceOnlyLinter.length == 1 &&
            HabotSizeConstraints.escapesASourceOnlyLinter.single
                .contains('40dp toolbar row') &&
            HabotSizeConstraints.qualitativeOutput == 'High' &&
            HabotSizeConstraints.widgetVersusGateNote
                .contains('somebody forgot at the next') &&
            HabotSizeConstraints.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01672',
        atomicStepReferenceId: 'GEN-01672',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Configure Modifier.sizeIn to enforce programmatic '
            'minimums."',
        implementationOrder: 217,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSizeConstraints / HabotControlMinimum',
          'Component Properties':
              '${HabotControlKind.values.length} control kinds, each with a '
              'declared minimum derived from the Step 184 band and a '
              'rationale; satisfiability checked against the parent '
              'constraints as well as the declared size; probe set of '
              '${HabotSizeConstraints.probeSet.length} declarations of which '
              '${HabotSizeConstraints.genuineFailures.length} are genuine '
              'failures',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION: Modifier.sizeIn is Jetpack Compose; the Flutter '
              'equivalent is a BoxConstraints minimum through a '
              'ConstrainedBox. The name does not port, the behaviour and the '
              'failure mode do. FINDING: the row asks for a widget and the '
              'metric asks for a CI gate, and the second is what makes the '
              'first stick. SECOND FINDING, and the one the metric turns on: '
              'Flutter does not throw when a minimum exceeds the incoming '
              'maximum -- BoxConstraints.enforce clamps it. The source then '
              'keeps a compliant minimum while the screen shows a control that '
              'is not, which is the one failure a source-reading linter can '
              'never catch. Measured on the probe set: this gate rejects 4 of '
              '4 genuine failures (100%), a source-only linter rejects 3 of 4 '
              '(75%), below the row\'s own floor of 95. The entry it misses is '
              'a correctly-declared 48dp icon button placed inside a 40dp '
              'toolbar row.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Automated PR Rejection Rate for Non-Compliance (%)',
            observed:
                '${rejection.toStringAsFixed(1)} -- '
                '${HabotSizeConstraints.genuineFailures.length} of '
                '${HabotSizeConstraints.genuineFailures.length} genuine '
                'failures rejected. The denominator is the failures rather '
                'than the population; including the compliant entries would '
                'make the figure a description of the probe set instead of the '
                'gate.',
            floor: '95',
            optimal: '99.5',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'The same rate for a source-reading linter',
            observed:
                '${sourceOnly.toStringAsFixed(1)} -- 3 of 4. Below the row\'s '
                'own floor of 95, because a minimum that is right in the '
                'source and clamped away by its parent looks compliant to '
                'anything that only reads text.',
            floor: '95',
            optimal: '99.5',
            ceiling: '100',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/size_constraints.dart',
        ],
      ),
    );
  });
}
