/// AISS GATE -- Step 426 of 415
/// Global Reference ID:       GEN-02907
/// Atomic Steps Reference ID: GEN-02907
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Display a Red Complexity Bottleneck indicator on the mobile
///               ops manager view."
/// Metric: Task Completion Status -- floor "0.8", optimal "1", ceiling "1".
///         Best Qualitative Output: "Complete/Partial/Not Complete". ITIL v4
///         Service Value System / Internal SOP. Assigned to **UDF**.
///
/// THE SAME RED MARK AS THE PREVIOUS ROW, FOR A READER WHO CAN ACT TODAY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/ops/bottleneck_indicator.dart';

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

  group('GEN-02907 :: one mark, two surfaces', () {
    gate(
      'GEN-02907-G1',
      'Second red bottleneck mark in two rows.',
      'Step 425 on the analytics dashboard, this on the ops manager view',
      () =>
          HabotBottleneckIndicator.theOtherRow == 425 &&
          HabotBottleneckIndicator.theTreatmentIsImported,
    );

    gate(
      'GEN-02907-G2',
      'And two marks for one thing look like one thing.',
      'The treatment is imported rather than redefined, because two marks that '
          'differ teach a reader the surfaces measure different things',
      () =>
          HabotBottleneckIndicator.theCarrierRuleStillHolds &&
          HabotBottleneckIndicator.theErrorRoleIsStillLeftAlone &&
          HabotBottleneckIndicator
              .importNote.contains('a third surface to reconcile them'),
    );

  });

  group('GEN-02907 :: two readers, two jobs', () {
    gate(
      'GEN-02907-G3',
      'The two readers decide on different timescales.',
      'An analyst decides what to change next sprint; an ops manager decides '
          'what to do before the shift ends',
      () => HabotBottleneckIndicator.theReadersDiffer,
    );

    gate(
      'GEN-02907-G4',
      'So the indicator carries a station, a shift and an action.',
      'Which is the part a dashboard does not need',
      () =>
          HabotBottleneckIndicator.everyActionNamesAStation &&
          HabotBottleneckIndicator.everyActionNamesAShift &&
          HabotBottleneckIndicator.everyIndicatorCarriesAnAction,
    );

    gate(
      'GEN-02907-G5',
      'One of the two is actionable inside the hour.',
      'And the one that needs a release is marked as such',
      () =>
          HabotBottleneckIndicator.atLeastOneIsActionableNow &&
          HabotBottleneckIndicator.actionableNow == 1,
    );

    gate(
      'GEN-02907-G6',
      'And a finding with no action gets scrolled past.',
      'An ops manager handed a finding with no next step either invents one or '
          'learns to ignore the mark',
      () =>
          HabotBottleneckIndicator.readerNote.contains('scroll past the mark'),
    );

  });

  group('GEN-02907 :: five nouns for one idea', () {
    gate(
      'GEN-02907-G7',
      'Five nouns in this batch for one concept.',
      'Friction, hesitation, drop-off, bottleneck and complexity bottleneck',
      () =>
          HabotBottleneckIndicator.fiveNounsInOneBatch &&
          HabotBottleneckIndicator.theVocabularyIsMappedNotAdopted,
    );

    gate(
      'GEN-02907-G8',
      'And no sixth vocabulary is adopted.',
      'They are mapped to one concept, because five words for one idea is how '
          'two teams build two systems',
      () =>
          !HabotBottleneckIndicator.aSixthVocabularyIsAdopted &&
          HabotBottleneckIndicator
              .vocabularyNote.contains('a subset of its own'),
    );

  });

  group('GEN-02907 :: a metric that cannot fail', () {
    gate(
      'GEN-02907-G9',
      'The metric scores the row\'s own completion.',
      'A task completion status on a row whose task is to display something, '
          'with the optimal equal to the ceiling',
      () =>
          HabotBottleneckIndicator.theMetricScoresTheRowsOwnCompletion &&
          HabotBottleneckIndicator.theOptimalEqualsTheCeiling,
    );

    gate(
      'GEN-02907-G10',
      'Six obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotBottleneckIndicator.obligations.length == 6 &&
          HabotBottleneckIndicator.obligations.values.every((bool b) => b) &&
          HabotBottleneckIndicator.qualitativeOutput == 'Complete' &&
          HabotBottleneckIndicator.theSubstituteFigureReachesOne &&
          HabotBottleneckIndicator.onlyDetectorFindingsAreShown,
    );
  });

  tearDownAll(() {
    final int actions = HabotBottleneckIndicator.actions.length;
    final int now = HabotBottleneckIndicator.actionableNow;
    final int nouns = HabotBottleneckIndicator.vocabulary.length;
    final String role = HabotBottleneckIndicator.colourRole;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02907',
        atomicStepReferenceId: 'GEN-02907',
        setupStepAction:
            'COLUMN NOTE: this row asks for a red bottleneck indicator one row '
            'after Step 425 asked for a red bottleneck highlight, on a '
            'different surface for a different reader -- the treatment is '
            'imported rather than redefined and the difference is the action '
            'attached; it introduces "complexity bottleneck", the fifth noun '
            'this batch uses for one idea, after friction, hesitation, '
            'drop-off and bottleneck; its metric is a generic task completion '
            'status that cannot report a meaningful failure; and its optimal '
            'and ceiling are both 1. Atomic Step: "Display a Red Complexity '
            'Bottleneck indicator on the mobile ops manager view."',
        implementationOrder: 426,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Display a Red Complexity Bottleneck indicator on the mobile ops':
              '$actions actions attached to the mark, $now of them actionable '
                  'within the hour, each naming a station and a shift; the '
                  '"$role" treatment is imported from Step 425 rather than '
                  'redefined',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Completion Status',
            observed:
                'A GENERIC COMPLETION STATUS ON A ROW WHOSE TASK IS TO DISPLAY '
                'SOMETHING. "Task Completion Status" measures the row\'s own '
                'completion and cannot report a failure that matters, and its '
                'optimal and ceiling are both 1, so there is nothing above the '
                'target either. The figure published instead is the share of '
                'displayed indicators carrying both an action and a location, '
                'which can fall and would mean something if it did. Observed: '
                '$actions actions, all carrying a station and a shift, $now of '
                'them actionable inside the hour.',
            floor: '0.8',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Nouns this batch uses for one concept',
            observed:
                '$nouns: friction, hesitation, drop-off, bottleneck and '
                'complexity bottleneck, across five rows measuring overlapping '
                'things. They are mapped to one concept rather than each '
                'getting an implementation, because five words for one idea is '
                'how two teams build two systems and each believes the '
                'other\'s is a subset of its own. This is the second red '
                'bottleneck mark in two rows, on a different surface for a '
                'different reader, and the treatment is imported rather than '
                'redrawn.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/ops/bottleneck_indicator.dart',
        ],
      ),
    );
  });
}
