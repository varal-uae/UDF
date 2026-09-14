/// AISS GATE -- Step 250 of 255
/// Global Reference ID:       GEN-02071
/// Atomic Steps Reference ID: GEN-02071
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Render multi-cue error states (color, text, and icon) on the
///               broken field."
/// Metric: Error Recovery Success Rate (%) -- Floor 90, Optimal 98, Ceiling
///         100. High/Medium/Low. Standard cited: WCAG 2.1 Error Recovery &
///         ISO/IEC 25010 Recoverability.
///
/// THE CUE COUNT WAS NEVER THE PROBLEM. Three of the thirteen suggestions
/// cannot be followed in the field they are attached to. REPORTS LOW.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/error_cue_audit.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/validation_state_color.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double recovery = 0;

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

  group('GEN-02071 :: the cues', () {
    gate(
      'GEN-02071-G1',
      'Atomic Step: "multi-cue error states (COLOR, TEXT, AND ICON)."',
      'All three are already carried, and so is a fourth the row omits -- a '
          'semantic announcement -- read from the existing declaration rather '
          'than restated, so the two cannot drift apart',
      () =>
          HabotErrorCueAudit.noCueIsMissing &&
          HabotErrorCueAudit.theRowOmitsOne &&
          HabotErrorCueAudit.declaredCues.length == 4 &&
          HabotErrorCueAudit.declaredCues
              .contains(HabotStateCarrier.semantics) &&
          HabotErrorCueAudit.cueCountWasNotTheProblemNote
              .contains('does not render a fifth'),
    );

    gate(
      'GEN-02071-G2',
      'WCAG 2.1 SC 3.3.3 Error Suggestion (AA).',
      'Every one of the thirteen declared messages states an action rather '
          'than a verdict -- "Enter a date as YYYY-MM-DD" rather than "Invalid '
          'date" -- measured over the declarations rather than assumed',
      () =>
          HabotErrorCueAudit.suggestionRate == 1.0 &&
          HabotErrorCueAudit.fieldsWhoseMessageSuggestsAFix.length ==
              HabotCde.values.length &&
          HabotErrorCueAudit.suggestsAFix('Enter a whole number.') &&
          !HabotErrorCueAudit.suggestsAFix('Invalid date.'),
    );

    gate(
      'GEN-02071-G3',
      'Step 238: dateUs is masked numeric and its pattern needs a slash.',
      'The dateUs message tells the person to enter a date as MM/DD/YYYY and '
          'the field deletes the slash -- a perfectly formed, perfectly '
          'accessible, four-cue error state instructing somebody to do '
          'something the field prevents',
      () =>
          HabotErrorCueAudit.worstCaseIsExactlyTheProblem &&
          HabotErrorCueAudit.worstCaseMessage.contains('MM/DD/YYYY') &&
          !HabotErrorCueAudit.suggestionIsFollowable(HabotCde.dateUs),
    );

    gate(
      'GEN-02071-G4',
      'Nothing in WCAG says the suggestion has to be achievable.',
      'Four requirements are scored and exactly one is below 1 -- the one that '
          'is not a WCAG criterion, because nobody writing WCAG imagined a '
          'field that eats the character it just asked for',
      () =>
          HabotRecoveryRequirement.values.length == 4 &&
          HabotErrorCueAudit.exactlyOneRequirementFails &&
          HabotErrorCueAudit.requirementsBelowOne.single ==
              HabotRecoveryRequirement.suggestionIsFollowable &&
          HabotErrorCueAudit.followableNote
              .contains('not one of the WCAG criteria'),
    );
  });

  group('GEN-02071 :: recovery, measured', () {
    gate(
      'GEN-02071-G5',
      'Metric: Error Recovery Success Rate (%) -- floor 90.',
      'Ten of thirteen fields can be recovered from at all, which is 76.9 and '
          'below the row\'s own floor, so the step reports Low; with Step '
          '238\'s correction adopted the same measurement is 100 and it '
          'reports High',
      () {
        recovery = HabotErrorCueAudit.errorRecoveryRate;
        return (recovery - 1000 / 13).abs() < 1e-9 &&
            recovery < HabotErrorCueAudit.floor &&
            HabotErrorCueAudit.recoverableFields.length == 10 &&
            HabotErrorCueAudit.unrecoverableFields.length == 3 &&
            HabotErrorCueAudit.errorRecoveryRateAfterCorrection == 100;
      },
    );

    gate(
      'GEN-02071-G6',
      'Step 214: a cycle time that happens after the application stops.',
      '"Error Recovery Success Rate" measures whether people recover, so what '
          'is published is the share of fields on which recovery is possible '
          'at all -- the ceiling on any success rate that could ever be '
          'observed',
      () =>
          HabotErrorCueAudit.rateIsAboutThePersonNote
              .contains('ceiling on any') &&
          HabotErrorCueAudit.bandFor(100) == 'High' &&
          HabotErrorCueAudit.bandFor(95) == 'Medium' &&
          HabotErrorCueAudit.bandFor(70) == 'Low',
    );

    gate(
      'GEN-02071-G7',
      'Error Recovery Success Rate -- High/Medium/Low.',
      'All ten checks hold and the step reports LOW on the fields as they '
          'stand, because reporting on the corrected binding would mean '
          'reporting on code that is not wired in -- the third metric in this '
          'batch to detect the same defect',
      () =>
          HabotErrorCueAudit.checks.length == 10 &&
          HabotErrorCueAudit.checks.values.every((bool b) => b) &&
          HabotErrorCueAudit.qualitativeOutput == 'Low' &&
          HabotErrorCueAudit.qualitativeOutputAfterCorrection == 'High' &&
          HabotErrorCueAudit.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String correctedRate = HabotErrorCueAudit
        .errorRecoveryRateAfterCorrection
        .toStringAsFixed(0);
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02071',
        atomicStepReferenceId: 'GEN-02071',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Render multi-cue error states (color, text, and icon) on '
            'the broken field."',
        implementationOrder: 250,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotErrorCueAudit / HabotRecoveryRequirement',
          'Component Properties':
              '${HabotErrorCueAudit.declaredCues.length} cues carried on an '
              'error against the ${HabotErrorCueAudit.cuesTheRowNames.length} '
              'the row names; ${HabotRecoveryRequirement.values.length} '
              'recovery requirements scored; '
              '${HabotErrorCueAudit.recoverableFields.length} of thirteen '
              'fields recoverable',
          'Completion Status': 'LOW -- see note',
          'Data Quality Note':
              'CENSUS: ${HabotErrorCueAudit.cueCountWasNotTheProblemNote} '
              'MEASURED: all thirteen declared messages state an action '
              'rather than a verdict, so SC 3.3.3 holds across the board. '
              'FINDING: ${HabotErrorCueAudit.followableNote} METRIC: '
              '${HabotErrorCueAudit.rateIsAboutThePersonNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Error Recovery Success Rate (%)',
            observed:
                '${recovery.toStringAsFixed(1)} -- '
                '${HabotErrorCueAudit.recoverableFields.length} of thirteen '
                'fields on which recovery is possible at all. Below the '
                'row\'s floor of ${HabotErrorCueAudit.floor}. With Step 238\'s '
                'correction adopted the same measurement is '
                '$correctedRate.',
            floor: '90',
            optimal: '98',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Messages that state an action rather than a verdict',
            observed:
                '${HabotErrorCueAudit.fieldsWhoseMessageSuggestsAFix.length} '
                'of thirteen. SC 3.3.3 is satisfied everywhere; three of '
                'those suggestions cannot be carried out in the field they '
                'are attached to, which is a requirement WCAG does not have.',
            floor: '13 of 13',
            optimal: '13 of 13',
            ceiling: '13 of 13',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/error_cue_audit.dart',
        ],
      ),
    );
  });
}
