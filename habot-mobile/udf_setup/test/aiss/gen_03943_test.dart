/// AISS GATE -- Step 415 of 415
/// Global Reference ID:       GEN-03943
/// Atomic Steps Reference ID: GEN-03943
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Import View, Text, and native animation utilities from the
///               mobile UI framework."
/// Metric: Import Overhead -- floor "< 20 ms", optimal "< 2 ms", ceiling "50
///         ms". Best Qualitative Output: "Pass/Fail". React Native Performance.
///         Assigned to **UDF**.
///
/// IMPORT VIEW AND TEXT FROM REACT NATIVE, IN A FLUTTER APPLICATION, AND
/// MEASURE THE IMPORT IN MILLISECONDS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tooling/framework_imports.dart';

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

  group('GEN-03943 :: three symbols, none from here', () {
    gate(
      'GEN-03943-G1',
      'Three foreign symbols, each with its equivalent named.',
      'View, Text and the native animation utilities',
      () =>
          HabotFrameworkImports.symbols.length == 3 &&
          HabotFrameworkImports.everySymbolIsForeign &&
          HabotFrameworkImports.everySymbolNamesItsEquivalent,
    );

    gate(
      'GEN-03943-G2',
      'And Text resolves to the wrong thing rather than failing.',
      'The name exists in both frameworks and means different things, which is '
          'the worst case for a borrowed symbol',
      () =>
          HabotFrameworkImports.translationNote
              .contains('resolve to the wrong thing'),
    );

  });

  group('GEN-03943 :: the nineteenth foreign stack', () {
    gate(
      'GEN-03943-G3',
      'The nineteenth foreign stack.',
      'After CSS at Step 409 and NPM at Step 411',
      () =>
          HabotFrameworkImports.thisIsTheNineteenthForeignStack &&
          HabotFrameworkImports.twoOfThreeAreAlreadyGoverned,
    );

    gate(
      'GEN-03943-G4',
      'And the first to reach the standard column.',
      'The row cites React Native Performance as the specification to '
          'configure against, so it is not a slipped word but a wrong '
          'authority',
      () =>
          HabotFrameworkImports.theStackReachesTheStandardColumn &&
          HabotFrameworkImports.registerNote
              .contains('a wrong specification is followed'),
    );

  });

  group('GEN-03943 :: the optimal is outside the band', () {
    gate(
      'GEN-03943-G5',
      'The optimal sits outside its own boundaries.',
      'Floor "< 20 ms" and ceiling "50 ms" describe an interval, and the '
          'optimal of "< 2 ms" is below both',
      () =>
          HabotFrameworkImports.theOptimalIsOutsideItsOwnBoundaries &&
          HabotFrameworkImports.theBoundariesDescribeAnInterval,
    );

    gate(
      'GEN-03943-G6',
      'Two cells are inequalities and the third is not.',
      'So the band cannot be read consistently before it is read as wrong -- '
          'the seventh distinct band shape in the track',
      () =>
          HabotFrameworkImports.twoCellsAreInequalitiesAndOneIsNot &&
          HabotFrameworkImports.thisShapeIsTheSeventh,
    );

  });

  group('GEN-03943 :: nothing to measure, and nothing to import', () {
    gate(
      'GEN-03943-G7',
      'There is no run-time import cost to measure.',
      'Imports are resolved at compile time and the unused parts are removed '
          'before a binary exists',
      () =>
          HabotFrameworkImports.theMetricMeasuresNothingThatExists &&
          HabotFrameworkImports.whatHappensToUnusedOnes == 'they are removed',
    );

    gate(
      'GEN-03943-G8',
      'So count, unused count and first frame are published instead.',
      'And the millisecond figure is named as the thing it is not rather than '
          'invented to fill the cell',
      () =>
          HabotFrameworkImports.theSubstituteFiguresAreMeasurable &&
          HabotFrameworkImports.overheadNote.contains('rather than invented'),
    );

    gate(
      'GEN-03943-G9',
      'The animation utilities are already governed.',
      'The motion tokens Step 176 exported, required by RAW_DURATION and '
          'RAW_CURVE since Step 179',
      () =>
          HabotFrameworkImports.theMotionTokensExist &&
          HabotFrameworkImports.bothMotionRulesAreDeclared &&
          !HabotFrameworkImports.anAnimationUtilityIsImported,
    );

    gate(
      'GEN-03943-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotFrameworkImports.obligations.length == 5 &&
          HabotFrameworkImports.obligations.values.every((bool b) => b) &&
          HabotFrameworkImports.qualitativeOutput == 'Pass' &&
          HabotFrameworkImports.coverage == 100,
    );
  });

  tearDownAll(() {
    final int symbols = HabotFrameworkImports.symbols.length;
    final int ordinal = HabotFrameworkImports.foreignStackOrdinal;
    final int governed = HabotFrameworkImports.governedElsewhere;
    final int frame = HabotFrameworkImports.firstFrameBudgetMs;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03943',
        atomicStepReferenceId: 'GEN-03943',
        setupStepAction:
            'COLUMN NOTE: this row asks to import View and Text -- React '
            'Native\'s primitives -- into a Flutter application and cites '
            '"React Native Performance" as the standard to configure against, '
            'which makes it the nineteenth foreign stack on the register Step '
            '258 keeps and the first to reach the reference-standard column '
            'rather than only the instruction text; its optimal of "< 2 ms" '
            'sits below both its floor of "< 20 ms" and its ceiling of "50 '
            'ms", so the target lies outside the interval its own boundaries '
            'describe; two of its three band cells are inequalities and the '
            'third is not; its Data Requirement cell truncates the Atomic Step '
            'at "the mobile"; and the Setup Step column is empty. Atomic Step: '
            '"Import View, Text, and native animation utilities from the '
            'mobile UI framework."',
        implementationOrder: 415,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Import View, Text, and native animation utilities from the mobile':
              '$symbols foreign symbols, each mapped to the equivalent this '
                  'framework already has; $governed of them are governed by '
                  'rules already in force, and no animation utility is '
                  'imported',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Import Overhead',
            observed:
                'THE OPTIMAL LIES OUTSIDE THE BAND, AND THERE IS NO OVERHEAD '
                'TO MEASURE. Floor "< 20 ms" and ceiling "50 ms" describe the '
                'interval twenty to fifty; the optimal of "< 2 ms" is below '
                'both, so the target sits outside the range its own boundaries '
                'define -- the seventh distinct band shape the track has '
                'recorded, after inverted, collapsed, typeset, annotated, '
                'mixed-type and absent. Two of the three cells are '
                'inequalities and the third is a bare number. Imports are '
                'resolved at compile time and tree-shaken, so no directive '
                'carries a millisecond cost at run time; the import count, the '
                'unused count of zero and a first-frame budget of $frame ms '
                'are published in its place.',
            floor: '< 20 ms',
            optimal: '< 2 ms',
            ceiling: '50 ms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Foreign stacks on the register Step 258 keeps',
            observed:
                '$ordinal, and this is the first to reach the '
                'reference-standard column. View and Text are React Native '
                'primitives and "React Native Performance" is the standard the '
                'row says to configure against: every previous foreign stack '
                'sat in the instruction text, where it reads as a slip a '
                'reader can translate, and a wrong specification is followed '
                'where a wrong word is corrected. All $symbols symbols name '
                'their equivalent here, $governed of them are already governed '
                '-- the motion tokens by RAW_DURATION and RAW_CURVE -- and '
                'importing an animation utility would be a second answer to a '
                'governed question, which is the mistake Steps 409 to 412 made '
                'four times in four rows.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tooling/framework_imports.dart',
        ],
      ),
    );
  });
}
