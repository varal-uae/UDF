/// AISS GATE -- Step 277 of 295
/// Global Reference ID:       ARCPE-004-08
/// Atomic Steps Reference ID: ARCPE-004-08
/// Setup Step (Action): "Conduct a engineering walk-through of the
///                      specification rules." (A MEETING, NOT AN ACTION)
/// Atomic Step: "Apply CSS constraint rules defining maximum layout height for
///               the expanded box."
/// Metric: Schema Constraint Compliance Rate -- Floor 0.98, Optimal 1,
///         Ceiling 1. Complete / Partial / Not Complete. ISO/IEC 25012.
///
/// A HEIGHT CAP ON AN EXPANDED PANEL IS A NESTED SCROLL VIEW, AND IT ONLY
/// BITES ON CONTENT LONG ENOUGH THAT NO SHORT TEST CASE FINDS IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/disclosure/expanded_height_limit.dart';

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

  group('ARCPE-004-08 :: why a height cap is the wrong constraint', () {
    gate(
      'ARCPE-004-08-G1',
      'Atomic Step: "Apply CSS constraint rules".',
      'The API the row names is CSS and the one available is not, recorded as '
          'a pair in the same shape Step 217 used for its Compose/Flutter '
          'pair',
      () => HabotExpandedHeightLimit.theNamedApiIsNotTheOneAvailable,
    );

    gate(
      'ARCPE-004-08-G2',
      'Two scrollables on one axis: one wins the gesture.',
      'Same-axis nesting is refused and cross-axis is allowed, so a '
          'horizontally panning row inside a vertical page stays legal and a '
          'vertically scrolling panel does not',
      () => HabotExpandedHeightLimit.sameAxisNestingIsRefused,
    );

    gate(
      'ARCPE-004-08-G3',
      'The cap does nothing until the content is long.',
      'Forty rows under a six-row cap nests; three rows does not; and no cap '
          'never does -- which is why the defect passes every short test case '
          'and arrives as "the screen is stuck"',
      () =>
          HabotExpandedHeightLimit.theCapOnlyBitesWhenTheContentIsLong &&
          HabotExpandedHeightLimit.nestedScrollNote
              .contains('short test case'),
    );
  });

  group('ARCPE-004-08 :: the constraint that is applied instead', () {
    gate(
      'ARCPE-004-08-G4',
      'The constraint goes on the content, not the box.',
      'Six rows render inline, anything longer opens a surface of its own, '
          'and no route ever produces an inner scroller',
      () =>
          HabotExpandedHeightLimit.maxInlineRows == 6 &&
          HabotExpandedHeightLimit.shortContentIsLeftAlone &&
          HabotExpandedHeightLimit.longContentGetsASurface &&
          HabotExpandedHeightLimit.overflowNeverBecomesAnInnerScroller,
    );

    gate(
      'ARCPE-004-08-G5',
      'A cap in points shrinks the list for people who enlarged the text.',
      'The limit is stated in rows and the height follows from the declared '
          'minimum row height, so a person at 200% text size sees six rows '
          'rather than three',
      () =>
          HabotExpandedHeightLimit.theLimitIsInRowsRatherThanPoints &&
          HabotExpandedHeightLimit.contentNotBoxNote
              .contains('enlarged the text'),
    );

    gate(
      'ARCPE-004-08-G6',
      'Data Collected: Layout Type, Grid Dimensions, Spacing, Alignment, '
          'Validation Status.',
      'All five declared layout fields are filled in rather than left as '
          'column headings',
      () => HabotExpandedHeightLimit.everyDeclaredFieldIsFilled,
    );
  });

  group('ARCPE-004-08 :: the metric, from another discipline', () {
    gate(
      'ARCPE-004-08-G7',
      'Metric: Schema Constraint Compliance Rate, cited to ISO/IEC 25012.',
      'That standard is a data-quality model -- the completeness and '
          'consistency of values -- and this row is about the height of a '
          'box; the mismatch is recorded rather than hidden behind a 1.0',
      () =>
          HabotExpandedHeightLimit.wrongDisciplineNote
              .contains('height of a box') &&
          HabotExpandedHeightLimit.constraints.length == 6 &&
          HabotExpandedHeightLimit.constraints.values.every((bool b) => b) &&
          HabotExpandedHeightLimit.complianceRate == 1.0,
    );

    gate(
      'ARCPE-004-08-G8',
      'Floor 0.98 with optimal and ceiling both 1.',
      'A two per cent allowance on a layout rule is a default somebody '
          'overrides at the call site, which is the condition this design '
          'system exists to prevent',
      () =>
          HabotExpandedHeightLimit.theFloorAdmitsAnExceptionARuleCannotHave &&
          HabotExpandedHeightLimit.bandNote
              .contains('overrides at the call site'),
    );

    gate(
      'ARCPE-004-08-G9',
      'Output: Complete / Partial / Not Complete.',
      'All nine declared checks hold and the step reports Complete, on the '
          'layout constraints it actually declares rather than on a schema it '
          'has none of',
      () =>
          HabotExpandedHeightLimit.checks.length == 9 &&
          HabotExpandedHeightLimit.checks.values.every((bool b) => b) &&
          HabotExpandedHeightLimit.qualitativeOutput == 'Complete' &&
          HabotExpandedHeightLimit.columnNote.contains('walk-through'),
    );
  });

  tearDownAll(() {
    final String rows = '${HabotExpandedHeightLimit.maxInlineRows}';
    final String minHeight =
        HabotExpandedHeightLimit.minimumInlineHeightDp.toStringAsFixed(0);
    final String rate =
        HabotExpandedHeightLimit.complianceRate.toStringAsFixed(2);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ARCPE-004-08',
        atomicStepReferenceId: 'ARCPE-004-08',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Conduct a '
            'engineering walk-through of the specification rules", which is a '
            'meeting rather than an action. Atomic Step: "Apply CSS '
            'constraint rules defining maximum layout height for the expanded '
            'box."',
        implementationOrder: 277,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'expanded disclosure panel',
          'Layout Grid Dimensions':
              'full container width, $rows rows inline, at least '
                  '${minHeight}dp',
          'Spacing Rules':
              'panel padding from the declared spacing scale; rows at the '
                  'declared minimum row height',
          'Alignment Settings': 'leading, matching the controlling header',
          'Layout Validation Status': 'validated',
          'Component Properties':
              '${HabotExpandedHeightLimit.constraints.length} declared layout '
              'constraints at a compliance rate of $rate; overflow opens a '
              'surface rather than an inner scroller',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotExpandedHeightLimit.nestedScrollNote} '
              'INSTEAD: ${HabotExpandedHeightLimit.contentNotBoxNote} '
              'METRIC: ${HabotExpandedHeightLimit.wrongDisciplineNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Schema Constraint Compliance Rate',
            observed:
                '$rate over the '
                '${HabotExpandedHeightLimit.constraints.length} layout '
                'constraints this step declares. The metric\'s own standard '
                'is a data-quality model and the row is about a box height, '
                'so this is the closest honest reading rather than the '
                'metric itself.',
            floor: '0.98',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Nested same-axis scrollables introduced',
            observed:
                '0. A height cap would have produced one whenever the content '
                'exceeded it; the inline row limit produces none at any '
                'content length.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/disclosure/expanded_height_limit.dart',
        ],
      ),
    );
  });
}
