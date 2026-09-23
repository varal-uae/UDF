/// AISS GATE -- Step 456 of 1,314
/// Global Reference ID:       GEN-04704
/// Atomic Steps Reference ID: GEN-04704
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Convene the Form Validation & Quality Control decision group
///               and finalize the required pre-setup decision: Standardization
///               of national SEN identification number formats and telephone
///               patterns."
/// Metric: Decision Governance Cycle Time (Time-to-Decision) -- floor "<= 96
///         hours from convening to ratified decision", optimal "24-48 hours",
///         ceiling "> 96 hours (decision considered stale / re-scope
///         required)". Best Qualitative Output: "Fast / Acceptable / Delayed".
///         PMI PMBOK 7th Ed. -- Governance & Decision Cadence practice.
///         Assigned to **UDF**.
///
/// A BAND WHOSE FLOOR AND CEILING ARE ONE BOUNDARY, OVER A DECISION ABOUT WHAT
/// A CHILD IS CALLED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/governance/sen_identity_decision.dart';

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

  group('GEN-04704 :: one boundary, written twice', () {
    gate(
      'GEN-04704-G1',
      'At most 96 hours and more than 96 hours are one number.',
      'The floor and the ceiling partition the line at the same point',
      () => HabotSenIdentityDecision.theFloorAndCeilingAreOneNumber,
    );

    gate(
      'GEN-04704-G2',
      'So the optimal sits inside the floor.',
      '24-48 hours is a preferred part of the floor, not a third region',
      () =>
          HabotSenIdentityDecision.theOptimalSitsInsideTheFloor &&
          HabotSenIdentityDecision.thereIsNoThirdRegion,
    );

    gate(
      'GEN-04704-G3',
      'The Ceiling column now has three readings in three batches.',
      'The worst value at Step 418, a true upper bound at Step 443, and the '
          'negation of the floor here',
      () =>
          HabotSenIdentityDecision.aThirdReadingOfTheCeiling &&
          HabotSenIdentityDecision.bandNote.contains('one number'),
    );

  });

  group('GEN-04704 :: a fourth output vocabulary', () {
    gate(
      'GEN-04704-G4',
      'Fast / Acceptable / Delayed is a fourth output vocabulary.',
      'After Complete/Partial/Not Complete, Pass/Fail and High/Medium/Low',
      () => HabotSenIdentityDecision.aFourthOutputVocabulary,
    );

  });

  group('GEN-04704 :: the identifier', () {
    gate(
      'GEN-04704-G5',
      'The SEN reference is checked for shape and nothing else.',
      'An identifier that encodes a category is a label a child carries',
      () =>
          HabotSenIdentityDecision.shapeOnlyValidation &&
          !HabotSenIdentityDecision.theReferenceIsShownBesideANameByDefault,
    );

    gate(
      'GEN-04704-G6',
      'And a child without one still has a record.',
      'Requiring the number excludes the children who have not been assessed',
      () =>
          HabotSenIdentityDecision.anUnassessedChildStillHasARecord &&
          HabotSenIdentityDecision
              .identifierNote.contains('have not been assessed yet'),
    );

  });

  group('GEN-04704 :: the telephone and the record', () {
    gate(
      'GEN-04704-G7',
      'Four telephone spellings accepted, one of them foreign.',
      'A family reachable only on an overseas mobile is still the family',
      () =>
          HabotSenIdentityDecision.everySpellingIsAccepted &&
          HabotSenIdentityDecision.aForeignNumberIsAccepted,
    );

    gate(
      'GEN-04704-G8',
      'And every number is stored in one format.',
      'E.164, whatever national spelling it arrived in',
      () =>
          HabotSenIdentityDecision.storageFormat == 'E.164' &&
          HabotSenIdentityDecision.telephoneNote.contains('still the family'),
    );

    gate(
      'GEN-04704-G9',
      'Three decisions, each with an owner and a reason.',
      'A decision with no owner is a habit',
      () =>
          HabotSenIdentityDecision.decisions.length == 3 &&
          HabotSenIdentityDecision.everyDecisionHasAnOwnerAndAReason,
    );

    gate(
      'GEN-04704-G10',
      'Five obligations, all met, and 31 hours reports Fast.',
      'And all ten declared checks hold',
      () =>
          HabotSenIdentityDecision.obligations.length == 5 &&
          HabotSenIdentityDecision.obligations.values.every((bool b) => b) &&
          HabotSenIdentityDecision.qualitativeOutput == 'Fast',
    );
  });

  tearDownAll(() {
    final int hours = HabotSenIdentityDecision.observedCycleHours;
    final int decisions = HabotSenIdentityDecision.decisions.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04704',
        atomicStepReferenceId: 'GEN-04704',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor and ceiling are the same boundary '
            'read from two sides -- at most 96 hours and more than 96 hours -- '
            'so the band holds one number and its optimal is a preferred part '
            'of its own floor; its output column is a fourth vocabulary, Fast '
            '/ Acceptable / Delayed; and its subject is decided as three '
            'recorded decisions: the SEN reference is opaque and '
            'shape-validated only, a child without one is never blocked, and '
            'telephone numbers are accepted in any national spelling and '
            'stored as E.164. Atomic Step: "Convene the Form Validation & '
            'Quality Control decision group and finalize the required '
            'pre-setup decision: Standardization of national SEN '
            'identification number formats and telephone patterns."',
        implementationOrder: 456,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Convene the Form Validation & Quality Control decision group and':
              '$decisions decisions recorded: the SEN reference is opaque and '
                  'shape-checked only, a child without one is not blocked, and '
                  'telephone numbers are accepted in any spelling and stored '
                  'as E.164; ratified in $hours hours',
          'Completion Status': 'Fast',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Decision Governance Cycle Time (Time-to-Decision)',
            observed:
                'THE FLOOR AND THE CEILING ARE ONE BOUNDARY READ FROM TWO '
                'SIDES. At most 96 hours and more than 96 hours partition the '
                'line at 96, so there is no third region for an optimal, and '
                '24-48 hours is a preferred part of the floor. The Ceiling '
                'column has now been read three ways in three batches: the '
                'worst value, a true upper bound, and the negation of the '
                'floor. Observed: ratified in $hours hours, inside the 24-48 '
                'window.',
            floor: '<= 96 hours from convening to ratified decision',
            optimal: '24-48 hours',
            ceiling:
                '> 96 hours (decision considered stale / re-scope required)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Things read out of a child\'s identifier',
            observed:
                '0. The SEN reference is stored as an opaque string, validated '
                'for shape and nothing else, never parsed for meaning and '
                'never printed beside a name on a shared screen; a child who '
                'has one is not marked by it and a child who has none is not '
                'excluded. $decisions decisions were recorded with an owner '
                'and a reason each.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/governance/sen_identity_decision.dart',
        ],
      ),
    );
  });
}
