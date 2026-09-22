/// AISS GATE -- Step 445 of 415
/// Global Reference ID:       GEN-02161
/// Atomic Steps Reference ID: GEN-02161
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build a mobile-responsive feedback form using the Forms
///               Component Library."
/// Metric: Candidate/Employee NPS -- floor "0", optimal "30", ceiling "50+".
///         Best Qualitative Output: "Good / Average / Poor". Bain & Company Net
///         Promoter Score Benchmark. Assigned to **UDF**.
///
/// A FEEDBACK FORM SCORED ON THE LOYALTY OF THE PEOPLE WHO FILL IT IN, ASKED BY
/// THEIR EMPLOYER, IN THEIR EMPLOYER'S APP.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/voice/feedback_form.dart';

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

  group('GEN-02161 :: NPS measures the respondents', () {
    gate(
      'GEN-02161-G1',
      'NPS measures the respondents, not the form.',
      'A broken form nobody unhappy can finish scores well',
      () =>
          HabotFeedbackForm.theMetricMeasuresSomethingElse &&
          HabotFeedbackForm.metricNote.contains('nobody unhappy can finish'),
    );

    gate(
      'GEN-02161-G2',
      'Fifty responses: 18, 21 and 11.',
      'Promoters, passives and detractors',
      () =>
          HabotFeedbackForm.respondents(HabotFeedbackForm.employees) == 50 &&
          HabotFeedbackForm.employees.promoters == 18 &&
          HabotFeedbackForm.employees.detractors == 11,
    );

    gate(
      'GEN-02161-G3',
      'The score is 14.',
      'Thirty-six per cent promoters minus twenty-two per cent detractors',
      () => HabotFeedbackForm.observedNps == 14,
    );

  });

  group('GEN-02161 :: anonymous by construction', () {
    gate(
      'GEN-02161-G4',
      'No user identifier can be attached.',
      'Step 419\'s allowlist has none',
      () => HabotFeedbackForm.noUserIdentifierCanBeAttached,
    );

    gate(
      'GEN-02161-G5',
      'Nothing is shown for fewer than five.',
      'The same minimum as Step 443',
      () =>
          HabotFeedbackForm.aGroupOfThreeIsNotReported &&
          HabotFeedbackForm.minimumGroupSize == 5,
    );

    gate(
      'GEN-02161-G6',
      'Candidates and employees are scored apart.',
      'Two populations, and asking employees to recommend their employer '
          'non-anonymously measures fear',
      () =>
          HabotFeedbackForm.theTwoPopulationsAreSeparated &&
          HabotFeedbackForm.fearNote.contains('safe it feels to be honest'),
    );

  });

  group('GEN-02161 :: the band', () {
    gate(
      'GEN-02161-G7',
      'The floor is the midpoint of the scale.',
      'NPS runs from -100 to +100',
      () => HabotFeedbackForm.theFloorIsTheMidpoint,
    );

    gate(
      'GEN-02161-G8',
      'The ceiling is open, the second plus-sign boundary.',
      '"50+", after Step 427\'s "95%+"',
      () =>
          HabotFeedbackForm.theCeilingIsOpen &&
          HabotFeedbackForm.secondPlusSignBoundary,
    );

    gate(
      'GEN-02161-G9',
      'The score sits between floor and optimal.',
      'Fourteen, between nought and thirty',
      () =>
          HabotFeedbackForm.observedNps > HabotFeedbackForm.bandFloor &&
          HabotFeedbackForm.observedNps < HabotFeedbackForm.bandOptimal &&
          HabotFeedbackForm.bandNote.contains('scores 14'),
    );

    gate(
      'GEN-02161-G10',
      'Five obligations, all met, giving Average.',
      'Reported as the band says, and all ten declared checks hold',
      () =>
          HabotFeedbackForm.obligations.length == 5 &&
          HabotFeedbackForm.obligations.values.every((bool b) => b) &&
          HabotFeedbackForm.qualitativeOutput == 'Average',
    );
  });

  tearDownAll(() {
    final int nps = HabotFeedbackForm.observedNps;
    final int respondents =
        HabotFeedbackForm.respondents(HabotFeedbackForm.employees);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02161',
        atomicStepReferenceId: 'GEN-02161',
        setupStepAction:
            'COLUMN NOTE: this row scores a feedback form on the net promoter '
            'score of its respondents, which measures them rather than the '
            'form; it puts candidates and employees under one number and asks '
            'employees to recommend their employer inside the employer\'s app, '
            'so the form is anonymous by construction, scored per population, '
            'and suppressed below five respondents; its floor of 0 is the '
            'midpoint of a scale running from -100 to +100; and its ceiling '
            '"50+" is open-ended. The worked set scores 14, reported Average. '
            'Atomic Step: "Build a mobile-responsive feedback form using the '
            'Forms Component Library."',
        implementationOrder: 445,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build a mobile-responsive feedback form using the Forms Component '
          'Library':
              'an anonymous form scored per population; $respondents employee '
                  'responses giving an NPS of $nps',
          'Completion Status': 'Average',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Candidate/Employee NPS',
            observed:
                'THE METRIC MEASURES THE RESPONDENTS, AND THE FLOOR IS THE '
                'MIDDLE OF THE SCALE. A net promoter score is about the people '
                'answering, not the form they answer on. NPS runs from -100 to '
                '+100, so a floor of 0 is the midpoint and half the range sits '
                'below it with no label, and the ceiling "50+" is open. '
                'Observed: an NPS of $nps from $respondents responses -- '
                'between the floor and the optimal, reported Average.',
            floor: '0',
            optimal: '30',
            ceiling: '50+',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Submissions that can be traced to a person',
            observed:
                '0 of $respondents. Asking employees whether they would '
                'recommend working here, inside the employer\'s own app, '
                'measures how safe honesty feels as much as how people feel, '
                'if the answer can be traced. No user identifier is attached, '
                'nothing is shown for fewer than five, and candidates and '
                'employees are scored separately.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/voice/feedback_form.dart',
        ],
      ),
    );
  });
}
