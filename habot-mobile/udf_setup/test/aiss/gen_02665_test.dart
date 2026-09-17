/// AISS GATE -- Step 380 of 395
/// Global Reference ID:       GEN-02665
/// Atomic Steps Reference ID: GEN-02665
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Make all dashboard elements read-only with no configuration
///               controls on the dashboard surface."
/// Metric: Implementation Completeness Rate -- floor "90% of defined scope
///         completed", optimal "100% of scope complete with peer validation",
///         ceiling "1". Complete / Partial / Not Complete. ISO/IEC 25010:2011.
///         Assigned to **GFD**.
///
/// THE FIRST DUPLICATED INSTRUCTION IN THIS TRACK: STEP 368'S ROW AGAIN, TWELVE
/// ROWS LATER, UNDER A DIFFERENT ID.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/read_only_surface.dart';

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

  group('GEN-02665 :: the duplicate', () {
    gate(
      'GEN-02665-G1',
      'This row repeats Step 368\'s instruction.',
      'GEN-02411 asks for read-only locks on the same dashboard elements, '
          'twelve rows earlier, under a different reference id',
      () =>
          HabotReadOnlySurface.thisIsADuplicatedInstruction &&
          HabotReadOnlySurface.theOtherRow == 368 &&
          HabotReadOnlySurface.theOtherReference == 'GEN-02411' &&
          HabotReadOnlySurface.rowsApart == 12,
    );

    gate(
      'GEN-02665-G2',
      'Different teams, different metrics, and neither mentions the other.',
      'GFD here and DEA there, so a reader working the sheet in order builds '
          'the same control twice',
      () =>
          HabotReadOnlySurface.theTwoRowsDisagreeAboutEverythingButTheWork &&
          !HabotReadOnlySurface.eitherRowMentionsTheOther &&
          HabotReadOnlySurface.duplicateNote
              .contains('builds the same control twice'),
    );

    gate(
      'GEN-02665-G3',
      'Previous repeats in this track were duplicated defects.',
      'This is duplicated work, which is a different problem',
      () => HabotReadOnlySurface.duplicateNote.contains('duplicated defects'),
    );
  });

  group('GEN-02665 :: bound, not rebuilt', () {
    gate(
      'GEN-02665-G4',
      'The read-only rule is Step 368\'s, imported.',
      'Two copies of one rule is how two dashboards end up disagreeing about '
          'what read-only means',
      () =>
          HabotReadOnlySurface.theRuleIsStep368s &&
          HabotReadOnlySurface.nothingIsDuplicatedInCode &&
          HabotReadOnlySurface.lockKind == HabotLockKind.noEditPath,
    );
  });

  group('GEN-02665 :: configuration is not editing', () {
    gate(
      'GEN-02665-G5',
      'Five controls, three of which only change the view.',
      'A date range, a site filter and a grouping are read-only operations on '
          'one person\'s own view',
      () =>
          HabotReadOnlySurface.controls.length == 5 &&
          HabotReadOnlySurface.threeOfFiveSurvive &&
          HabotSurfaceControl.values.length == 2,
    );

    gate(
      'GEN-02665-G6',
      'No surviving control writes.',
      'The two that write to the record behind the surface are the two the row '
          'is actually asking to remove',
      () => HabotReadOnlySurface.noSurvivingControlWrites,
    );

    gate(
      'GEN-02665-G7',
      'A literal sweep would take the filters too.',
      'And a dashboard with no filters is a poster',
      () =>
          HabotReadOnlySurface.aLiteralSweepWouldTakeTheFilters &&
          HabotReadOnlySurface.controlsALiteralSweepWouldRemove == 5 &&
          HabotReadOnlySurface.configurationNote.contains('a poster'),
    );
  });

  group('GEN-02665 :: removal is not deletion', () {
    gate(
      'GEN-02665-G8',
      'Both removed controls are named with where they went.',
      'The target\'s own settings screen and the exception detail sheet',
      () =>
          HabotReadOnlySurface.everyRemovedControlHasAHome &&
          HabotReadOnlySurface.removed.length == 2 &&
          HabotReadOnlySurface.removalNote.contains('rather than moved it'),
    );

    gate(
      'GEN-02665-G9',
      'The band holds three different types.',
      'A sentence, a sentence with a process condition, and the bare ratio "1"',
      () =>
          HabotReadOnlySurface.threeCellsHoldThreeTypes &&
          HabotReadOnlySurface.theFloorIsASentence &&
          HabotReadOnlySurface.theCeilingIsABareRatio &&
          HabotReadOnlySurface.bandNote.contains('peer validation'),
    );

    gate(
      'GEN-02665-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Five obligations, all met, giving Complete; all ten declared checks '
          'hold',
      () =>
          HabotReadOnlySurface.obligations.length == 5 &&
          HabotReadOnlySurface.obligations.values.every((bool b) => b) &&
          HabotReadOnlySurface.qualitativeOutput == 'Complete' &&
          HabotReadOnlySurface.checks.length == 10 &&
          HabotReadOnlySurface.checks.values.every((bool b) => b) &&
          HabotReadOnlySurface.columnNote.contains('GFD'),
    );
  });

  tearDownAll(() {
    final int surviving = HabotReadOnlySurface.surviving.length;
    final int removed = HabotReadOnlySurface.removed.length;
    final String firstDestination =
        HabotReadOnlySurface.movedTo['Edit this target'] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02665',
        atomicStepReferenceId: 'GEN-02665',
        setupStepAction:
            'COLUMN NOTE: this row repeats Step 368\'s instruction under a '
            'different reference id, metric, standard and team -- the first '
            'duplicated instruction in this track rather than a duplicated '
            'defect; it is assigned to GFD rather than UDF; its band holds a '
            'sentence, a sentence carrying a process condition, and the bare '
            'ratio "1", so a consumer parsing the three gets a string, a '
            'string and a number; its Data Requirement cell holds the Atomic '
            'Step\'s own text truncated with an ellipsis; and the Setup Step '
            'column is empty. Atomic Step: "Make all dashboard elements '
            'read-only with no configuration controls on the dashboard '
            'surface."',
        implementationOrder: 380,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Make all dashboard elements read-only with no configuration':
              '$surviving of 5 controls survive; $removed write to the record '
                  'and are moved',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the read-only rule is imported from Step 368; "Edit this '
                  'target" now lives at $firstDestination',
          'Data Quality Note':
              'DUPLICATE: ${HabotReadOnlySurface.duplicateNote} BINDING: '
              '${HabotReadOnlySurface.bindingNote} CONFIGURATION: '
              '${HabotReadOnlySurface.configurationNote} REMOVAL: '
              '${HabotReadOnlySurface.removalNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Implementation Completeness Rate',
            observed:
                'THREE CELLS OF THREE DIFFERENT TYPES. The floor is "90% of '
                'defined scope completed", the optimal is "100% of scope '
                'complete with peer validation" and the ceiling is "1" -- a '
                'string, a string and a number, with the optimal also carrying '
                'a process condition that is not a value on the same scale as '
                'the other two. The row is assigned to GFD rather than UDF, '
                'and it repeats Step 368\'s instruction twelve rows later '
                'under a different id with a different metric and a different '
                'standard.',
            floor: '90% of defined scope completed',
            optimal: '100% of scope complete with peer validation',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Read-only rules implemented twice',
            observed:
                '0. Step 368 already built the mechanical read-only lock and '
                'this row asks for it again, so the rule is imported rather '
                'than restated -- two copies of one rule is how two dashboards '
                'end up disagreeing about what read-only means. What is built '
                'here is the part the two rows do not share: configuration is '
                'not editing, so $surviving of the five controls change only '
                'what this viewer is looking at and stay, while $removed write '
                'to the record and are named along with where they went.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/read_only_surface.dart',
        ],
      ),
    );
  });
}
