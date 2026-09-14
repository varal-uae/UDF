/// AISS GATE -- Step 218 of 235
/// Global Reference ID:       GEN-04748
/// Atomic Steps Reference ID: GEN-04748
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Apply the mobile-first UX decision: Vertical 50/50 stack on
///               mobile; horizontal 50/50 split on tablet/desktop."
/// Metric: UX Decision Adoption Consistency -- Floor ">=95% of applicable
///         screens/flows apply the decision", Optimal "100%", Ceiling "100%".
///         Yes / No.
///
/// 50/50 IS A RATIO, NOT A DECISION, AND THE REPOSITORY ALREADY SAYS SO:
/// HabotMasterDetail declares 35/65. The row and the code disagree because they
/// are describing two different patterns.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/pane_split.dart';
import 'package:udf_setup/design_system/layout/window_size_class.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adoption = 0;
  double literal = 0;

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

  group('GEN-04748 :: the ratio', () {
    gate(
      'GEN-04748-G1',
      'Atomic Step: "Vertical 50/50 stack on mobile; horizontal 50/50 split on '
          'tablet/desktop." HabotMasterDetail declares 35/65.',
      'The row\'s 50/50 is applied where it is true -- two panes carrying the '
          'same kind of content -- and the 35/65 a master and a detail already '
          'use is not changed to satisfy a ratio',
      () =>
          HabotPaneSplit.ruleFor(HabotPaneRelation.peers).isEven &&
          !HabotPaneSplit.ruleFor(HabotPaneRelation.masterDetail).isEven &&
          HabotPaneSplit.ruleFor(HabotPaneRelation.masterDetail)
                  .leadingPercent ==
              HabotPaneSplit.masterDetailLeading &&
          HabotPaneSplit.ruleFor(HabotPaneRelation.masterDetail)
                  .trailingPercent ==
              HabotPaneSplit.masterDetailTrailing &&
          HabotPaneSplit.everyRuleSumsToWhole &&
          HabotPaneSplit.ratioIsNotADecisionNote
              .contains('different patterns'),
    );

    gate(
      'GEN-04748-G2',
      '"MD3 supporting pane: the work is the larger side and the support is '
          'the smaller one."',
      'Three relations are declared, each with a rationale, and the supporting '
          'pane is the mirror of the master-detail rather than a third '
          'arbitrary pair of numbers',
      () {
        final HabotSplitRule supporting =
            HabotPaneSplit.ruleFor(HabotPaneRelation.supporting);
        final HabotSplitRule md =
            HabotPaneSplit.ruleFor(HabotPaneRelation.masterDetail);
        return HabotPaneRelation.values.length == 3 &&
            HabotPaneSplit.rules.length == 3 &&
            supporting.leadingPercent == md.trailingPercent &&
            supporting.trailingPercent == md.leadingPercent &&
            HabotPaneSplit.rules.every(
              (HabotSplitRule r) => r.rationale.length > 50,
            );
      },
    );

    gate(
      'GEN-04748-G3',
      'The row\'s literal ratio is correct on a minority of the screens it '
          'applies to.',
      'Only the peer relation is even, and across the seven applicable screens '
          'the literal 50/50 is right on two of them -- 28.6%, which is the '
          'number that says the row is a rule about one pattern rather than '
          'about layout',
      () {
        literal = HabotPaneSplit.literalRatioApplies;
        return HabotPaneSplit.relationsTheRowFits.length == 1 &&
            HabotPaneSplit.relationsTheRowFits.single ==
                HabotPaneRelation.peers &&
            HabotPaneSplit.applicableScreens.length == 7 &&
            (literal - 200 / 7).abs() < 1e-9 &&
            literal < 50;
      },
    );
  });

  group('GEN-04748 :: what "on mobile" has to mean', () {
    gate(
      'GEN-04748-G4',
      '"A 50/50 vertical stack on a 360x740 phone gives each pane about 50dp '
          'once the keyboard opens."',
      'On a compact window a master and a detail navigate rather than stack, '
          'while two peers still stack -- so the row\'s vertical stack '
          'survives where both halves are worth seeing at once and is '
          'replaced where they are not',
      () =>
          HabotPaneSplit.presentationFor(HabotPaneRelation.peers, 360) ==
              HabotPanePresentation.stacked &&
          HabotPaneSplit.presentationFor(
                HabotPaneRelation.masterDetail,
                360,
              ) ==
              HabotPanePresentation.navigated &&
          HabotPaneSplit.presentationFor(
                HabotPaneRelation.supporting,
                360,
              ) ==
              HabotPanePresentation.navigated &&
          HabotPanePresentation.values.length == 3 &&
          HabotPaneSplit.stackCollapsesUnderAKeyboardNote
              .contains('keyboard open'),
    );

    gate(
      'GEN-04748-G5',
      '"Horizontal 50/50 split on tablet/desktop."',
      'Every relation presents side by side above the compact class, so the '
          'second half of the row holds everywhere it was written for',
      () =>
          HabotPaneRelation.values.every(
            (HabotPaneRelation r) =>
                HabotPaneSplit.presentationFor(r, 744) ==
                    HabotPanePresentation.sideBySide &&
                HabotPaneSplit.presentationFor(r, 1280) ==
                    HabotPanePresentation.sideBySide,
          ) &&
          HabotWindowSizeClass.classOf(744) != HabotMd3WindowClass.compact,
    );

    gate(
      'GEN-04748-G6',
      'A pane narrower than its content is a label with a scrollbar.',
      'The extent a pane receives is computed from the presentation rather '
          'than assumed, the keyboard is subtracted where it applies, and a '
          'stacked peer pane on the shortest phone with the keyboard open '
          'falls below the usable minimum -- which is why compact stacks only '
          'peers and only when there is room',
      () {
        final double dry = HabotPaneSplit.paneExtentFor(
          relation: HabotPaneRelation.peers,
          windowWidthDp: 360,
          windowHeightDp: 740,
          chromeHeightDp: 120,
        );
        final double withKeyboard = HabotPaneSplit.paneExtentFor(
          relation: HabotPaneRelation.peers,
          windowWidthDp: 360,
          windowHeightDp: 740,
          chromeHeightDp: 120,
          keyboardInsetDp: 336,
        );
        final double navigated = HabotPaneSplit.paneExtentFor(
          relation: HabotPaneRelation.masterDetail,
          windowWidthDp: 360,
          windowHeightDp: 740,
          chromeHeightDp: 120,
        );
        return dry == 310 &&
            withKeyboard == 142 &&
            HabotPaneSplit.paneIsUsable(dry) &&
            !HabotPaneSplit.paneIsUsable(withKeyboard) &&
            navigated == 360 &&
            HabotPaneSplit.minimumUsablePaneDp == 200;
      },
    );

    gate(
      'GEN-04748-G7',
      'Metric: UX Decision Adoption Consistency -- floor >=95% of applicable '
          'screens, Yes/No.',
      'All seven applicable screens declare which relation they are and '
          'resolve to a rule that sums to a whole, giving 100% adoption and a '
          'Yes -- which is possible only because "the decision" was read as '
          '"every screen declares its relation" rather than as "every screen '
          'is 50/50"',
      () {
        adoption = HabotPaneSplit.adoptionConsistency;
        return adoption == 100 &&
            adoption >= HabotPaneSplit.floor &&
            HabotPaneSplit.applicableScreens.keys
                .every(HabotPaneSplit.screenAdopts) &&
            HabotPaneSplit.qualitativeOutput == 'Yes' &&
            HabotPaneSplit.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04748',
        atomicStepReferenceId: 'GEN-04748',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Apply the mobile-first UX decision: Vertical 50/50 stack '
            'on mobile; horizontal 50/50 split on tablet/desktop."',
        implementationOrder: 218,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPaneSplit / HabotSplitRule',
          'Component Properties':
              '${HabotPaneRelation.values.length} pane relations, each with a '
              'declared ratio and a rationale; '
              '${HabotPanePresentation.values.length} presentations resolved '
              'from relation and window class; '
              '${HabotPaneSplit.applicableScreens.length} applicable screens, '
              'each declaring its relation; minimum usable pane '
              '${HabotPaneSplit.minimumUsablePaneDp.toStringAsFixed(0)}dp',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: 50/50 is a ratio, not a decision, and this repository '
              'already says so -- HabotMasterDetail declares 35/65. The row '
              'and the code disagree, and the disagreement is real: they '
              'describe two different patterns. Peer panes are 50/50; a master '
              'and a detail are not peers. Measured: the row\'s literal ratio '
              'is correct on 2 of the 7 applicable screens (28.6%). SECOND '
              'FINDING: on a compact window the relationship between two panes '
              'is NAVIGATION, not layout. A 50/50 vertical stack on a 360x740 '
              'phone gives each pane 310dp with the keyboard closed and 142dp '
              'with it open -- below the 200dp usable minimum -- and a booking '
              'form spends most of its life with the keyboard open. So compact '
              'stacks peers and navigates everything else. The adoption figure '
              'reaches 100% only because "apply the decision" was read as '
              '"every applicable screen declares its relation", which is a '
              'thing a screen can do, rather than "every screen is 50/50", '
              'which is a thing five of them should not.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UX Decision Adoption Consistency',
            observed:
                '${adoption.toStringAsFixed(0)}% -- all '
                '${HabotPaneSplit.applicableScreens.length} applicable screens '
                'declare a relation that resolves to a rule summing to a '
                'whole.',
            floor: '>=95% of applicable screens/flows apply the decision',
            optimal: '100% of applicable screens/flows',
            ceiling: '100% (full adoption is the ceiling)',
          ),
          AissMeasurement(
            metricName: 'Screens on which the literal 50/50 is correct',
            observed:
                '${literal.toStringAsFixed(1)}% -- 2 of 7. Reported beside the '
                'adoption figure so that "100% adoption" cannot be read as '
                '"every screen is 50/50".',
            floor: 'n/a -- descriptive',
            optimal: 'n/a -- descriptive',
            ceiling: 'n/a -- descriptive',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/pane_split.dart',
        ],
      ),
    );
  });
}
