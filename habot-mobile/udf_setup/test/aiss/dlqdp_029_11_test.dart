/// AISS GATE -- Step 221 of 235
/// Global Reference ID:       DLQDP-029-11
/// Atomic Steps Reference ID: DLQDP-029-11
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement M3 Split Screen or supporting pane layout."
/// Metric: UI Design-System Adherence Rate -- Floor >=85%, Optimal >=95%,
///         Ceiling 1. Good/Average/Poor.
///
/// "SPLIT SCREEN" IS NOT A MATERIAL 3 LAYOUT, AND IT IS NOT AN ALTERNATIVE TO
/// A SUPPORTING PANE -- it is the Android system feature that takes one away.
/// Halving a 1024dp tablet window puts the app at 512dp, which is Compact,
/// which is where the supporting pane collapses.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/canonical_layouts.dart';
import 'package:udf_setup/design_system/layout/pane_split.dart';
import 'package:udf_setup/design_system/layout/window_size_class.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

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

  group('DLQDP-029-11 :: the conflation', () {
    gate(
      'DLQDP-029-11-G1',
      'Atomic Step: "Implement M3 SPLIT SCREEN or supporting pane layout." '
          'Material 3 names three canonical layouts: list-detail, supporting '
          'pane and feed.',
      'The name the row uses is not one of them, and all three that are '
          'exist with the MD3 names a designer would use -- so a design '
          'conversation and a code review are about the same three things',
      () =>
          HabotCanonicalLayouts.rowNamesALayoutMd3DoesNotHave &&
          HabotCanonicalLayouts.nameInTheRow == 'Split Screen' &&
          HabotCanonicalLayouts.all.length == 3 &&
          HabotCanonicalLayoutKind.values.length == 3 &&
          HabotCanonicalLayouts.of(HabotCanonicalLayoutKind.listDetail)
                  .md3Name ==
              'List-detail' &&
          HabotCanonicalLayouts.of(HabotCanonicalLayoutKind.supportingPane)
                  .md3Name ==
              'Supporting pane' &&
          HabotCanonicalLayouts.of(HabotCanonicalLayoutKind.feed).md3Name ==
              'Feed',
    );

    gate(
      'DLQDP-029-11-G2',
      '"They are not alternatives; they are opposites."',
      'Halving a 1024dp tablet window collapses the supporting pane -- the '
          'system feature the row offers as an alternative is measured doing '
          'exactly what it would replace',
      () =>
          HabotCanonicalLayouts.systemSplitCollapsesLayout(
            HabotCanonicalLayoutKind.supportingPane,
            1024,
          ) &&
          HabotCanonicalLayouts.systemSplitCollapsesLayout(
            HabotCanonicalLayoutKind.listDetail,
            1024,
          ) &&
          HabotCanonicalLayouts.windowWidthUnderSystemSplit(1024) == 512 &&
          HabotWindowSizeClass.classOf(512) ==
              HabotMd3WindowClass.compact &&
          HabotCanonicalLayouts.conflationNote.contains('takes one away'),
    );

    gate(
      'DLQDP-029-11-G3',
      '"The app does not choose system split-screen."',
      'It is declared as an input to the window class rather than as a layout '
          'the app selects, which is the same property Step 216 insists on -- '
          'the class comes from the window, not the hardware',
      () =>
          !HabotCanonicalLayouts.appChoosesIt &&
          HabotCanonicalLayouts.systemFeature.contains('Split View') &&
          HabotWindowSizeClass.classIsAPropertyOfTheWindow &&
          HabotCanonicalLayouts.systemFeatureIsAnInputNote
              .contains('Step 216'),
    );
  });

  group('DLQDP-029-11 :: the three that exist', () {
    gate(
      'DLQDP-029-11-G4',
      'Each canonical layout has to say what it does when there is no room '
          'for both panes.',
      'All three collapse at the compact class, and each maps onto one of the '
          'three declared pane relations rather than two of them sharing one',
      () =>
          HabotCanonicalLayouts.all.every(
            (HabotCanonicalLayout l) =>
                l.collapsesAtOrBelow == HabotMd3WindowClass.compact,
          ) &&
          HabotCanonicalLayouts.all
                  .map((HabotCanonicalLayout l) => l.relation)
                  .toSet()
                  .length ==
              3 &&
          HabotPaneRelation.values.length == 3,
    );

    gate(
      'DLQDP-029-11-G5',
      'A list-detail and a feed collapse differently, and the difference is '
          'the point.',
      'List-detail and supporting pane navigate on compact -- one pane at a '
          'time -- while a feed stacks, because both halves of a feed are the '
          'same kind of thing and seeing two at once is what a feed is for',
      () =>
          HabotCanonicalLayouts.of(HabotCanonicalLayoutKind.listDetail)
                  .compactBehaviour ==
              HabotPanePresentation.navigated &&
          HabotCanonicalLayouts.of(HabotCanonicalLayoutKind.supportingPane)
                  .compactBehaviour ==
              HabotPanePresentation.navigated &&
          HabotCanonicalLayouts.of(HabotCanonicalLayoutKind.feed)
                  .compactBehaviour ==
              HabotPanePresentation.stacked &&
          HabotPaneSplit.presentationFor(
                HabotCanonicalLayouts.of(HabotCanonicalLayoutKind.feed)
                    .relation,
                360,
              ) ==
              HabotPanePresentation.stacked,
    );

    gate(
      'DLQDP-029-11-G6',
      'A layout that stops collapsing above compact would be a layout that '
          'never runs on a phone.',
      'Above the compact class every canonical layout presents both panes, so '
          'the collapse is a compact-only behaviour rather than a habit',
      () => HabotCanonicalLayouts.all.every(
        (HabotCanonicalLayout l) =>
            HabotPaneSplit.presentationFor(l.relation, 840) ==
                HabotPanePresentation.sideBySide &&
            HabotPaneSplit.presentationFor(l.relation, 600) ==
                HabotPanePresentation.sideBySide,
      ),
    );

    gate(
      'DLQDP-029-11-G7',
      'Metric: UI Design-System Adherence Rate -- floor >=85%, optimal >=95%.',
      'All eight adherence checks hold, giving 1.0 and a Good -- including the '
          'two that are about the row rather than about the code: that the '
          'name it uses is not an MD3 layout, and that the feature it offers '
          'as an alternative is the one that removes the alternative',
      () {
        adherence = HabotCanonicalLayouts.adherenceRate;
        return HabotCanonicalLayouts.adherenceChecks.length == 8 &&
            HabotCanonicalLayouts.adherenceChecks.values
                .every((bool b) => b) &&
            adherence == 1.0 &&
            adherence >= HabotCanonicalLayouts.optimal &&
            HabotCanonicalLayouts.qualitativeOutput == 'Good' &&
            HabotCanonicalLayouts.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'DLQDP-029-11',
        atomicStepReferenceId: 'DLQDP-029-11',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement M3 Split Screen or supporting pane layout."',
        implementationOrder: 221,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCanonicalLayouts / HabotCanonicalLayout',
          'Component Properties':
              '${HabotCanonicalLayouts.all.length} MD3 canonical layouts with '
              'their MD3 names, each mapped onto one of the '
              '${HabotPaneRelation.values.length} pane relations and each '
              'declaring the class at which it collapses and what it does '
              'then; the Android system feature declared separately as an '
              'input to the window class',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: "Split Screen" is not a Material 3 layout. MD3 names '
              'three canonical layouts -- list-detail, supporting pane and '
              'feed -- and split-screen is the Android SYSTEM feature in which '
              'two apps share a display. The row joins them with an "or", as '
              'though they were alternatives. They are opposites: system '
              'split-screen SHRINKS the app\'s window, which moves it down the '
              'size-class ladder. Measured: halving a 1024dp tablet window '
              'puts the app at 512dp, which is Compact, which is exactly where '
              'a supporting pane collapses -- so implementing "split screen" '
              'literally means implementing the thing that takes the '
              'supporting pane away. The three canonical layouts are declared '
              'with the class at which each collapses, and the system feature '
              'is declared as an input to the window class rather than as a '
              'layout the app selects. SECOND READING: list-detail and '
              'supporting pane navigate on compact while a feed stacks, '
              'because both halves of a feed are the same kind of thing.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '${adherence.toStringAsFixed(2)} over '
                '${HabotCanonicalLayouts.adherenceChecks.length} checks: three '
                'canonical layouts with MD3 names, each on a distinct pane '
                'relation, each declaring its compact behaviour, and the two '
                'findings about the row itself.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Window width under system split-screen',
            observed:
                '512dp from a 1024dp display -- Compact. The supporting pane '
                'and the list-detail both collapse. The feature the row offers '
                'as an alternative to a supporting pane is measured removing '
                'one.',
            floor: 'n/a -- demonstration',
            optimal: 'n/a -- demonstration',
            ceiling: 'n/a -- demonstration',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/canonical_layouts.dart',
        ],
      ),
    );
  });
}
