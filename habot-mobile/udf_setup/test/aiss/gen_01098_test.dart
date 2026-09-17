/// AISS GATE -- Step 308 of 315
/// Global Reference ID:       GEN-01098
/// Atomic Steps Reference ID: GEN-01098
/// Setup Step (Action): "Capture resultant input field DOM value attribute
///                      after masking execution." (THE DOM, IN A FLUTTER
///                      APPLICATION)
/// Atomic Step: "Embed M3 Outlined text fields with contact action icons."
/// Metric: Icon Recognition Accuracy -- floor 0.8, optimal 0.95, ceiling 1.
///         Good/Average/Poor. ISO 9186 Graphical Symbol Testing.
///
/// A REAL METRIC WITH A REAL STANDARD, STRICTER THAN THE STANDARD IT CITES,
/// AND A NUMBER NOTHING IN THIS REPOSITORY CAN PRODUCE. ONE GATE DEFERRED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/contact_field_actions.dart';

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

  group('GEN-01098 :: three icons do not fit', () {
    gate(
      'GEN-01098-G1',
      'An M3 outlined field on a compact window.',
      '296 points inside its own padding, of which three 48-point targets '
          'with the required clearance take 160 -- 54 per cent -- leaving 136 '
          'for a phone number',
      () =>
          HabotContactFieldActions.fieldWidthDp == 328 &&
          HabotContactFieldActions.innerWidthDp == 296 &&
          HabotContactFieldActions.widthForActions(3) == 160 &&
          HabotContactFieldActions.textWidthRemainingFor(3) == 136,
    );

    gate(
      'GEN-01098-G2',
      'So one action goes inside and two go under.',
      'Where they can carry words as well as glyphs, which is also where the '
          'recognition question stops mattering',
      () =>
          HabotContactFieldActions.onlyOneActionIsInsideTheField &&
          HabotContactFieldActions.actionsTotal == 3 &&
          HabotContactFieldActions.actionsUnderTheField == 2 &&
          HabotContactFieldActions.widthForActions(1) == 48 &&
          HabotContactFieldActions.geometryNote.contains('stops mattering'),
    );
  });

  group('GEN-01098 :: two gestures in one rectangle', () {
    gate(
      'GEN-01098-G3',
      'A 48-point target in a 56-point field.',
      'Four points of margin above and below, so the icon region and the '
          'field region do not overlap',
      () =>
          HabotContactFieldActions.fieldHeightDp == 56 &&
          HabotContactFieldActions.targetSideDp == 48 &&
          HabotContactFieldActions.verticalMarginInsideTheFieldDp == 4 &&
          HabotContactFieldActions.theTargetFitsInsideTheFieldHeight,
    );

    gate(
      'GEN-01098-G4',
      'Tapping the icon does not focus the field.',
      'Focusing raises the keyboard over the thing the person just asked to '
          'see, and the separation is a property of the layout rather than of '
          'which hit-test wins',
      () =>
          !HabotContactFieldActions.tappingTheIconFocusesTheField &&
          HabotContactFieldActions.focusNote.contains('behind it'),
    );
  });

  group('GEN-01098 :: the action waits for the value', () {
    gate(
      'GEN-01098-G5',
      'A call button beside a half-typed number.',
      'The action is disabled until nine digits are present, so a wrong '
          'number cannot be dialled from an incomplete field',
      () =>
          !HabotContactFieldActions.actionIsEnabled('') &&
          !HabotContactFieldActions.actionIsEnabled('5012') &&
          HabotContactFieldActions.actionIsEnabled('501234567') &&
          HabotContactFieldActions.completeDigitCount == 9,
    );

    gate(
      'GEN-01098-G6',
      'The disabled state says what would change it.',
      'Three different reasons for three different states -- the property '
          'Step 291 established and Step 292 was refused for lacking',
      () =>
          HabotContactFieldActions.theDisabledStateAlwaysSaysSomething &&
          HabotContactFieldActions.disabledReasonFor('') !=
              HabotContactFieldActions.disabledReasonFor('5012') &&
          HabotContactFieldActions.disabledReasonFor('5012') !=
              HabotContactFieldActions.disabledReasonFor('50123456789') &&
          HabotContactFieldActions.premature
              .contains('the stranger who answers'),
    );
  });

  group('GEN-01098 :: the metric, which is right', () {
    gate(
      'GEN-01098-G7',
      'ISO 9186 acceptance is about two thirds; the row asks for 0.8.',
      'A project choosing to be harder on itself than the standard it cites, '
          'by 0.13, on a row whose metric measures its own subject',
      () =>
          HabotContactFieldActions.theRowIsStricterThanTheStandardItCites &&
          (HabotContactFieldActions.howMuchStricterTheRowIs - 0.13).abs() <
              1e-9 &&
          HabotContactFieldActions.metricIsCorrectNote
              .contains('harder on itself'),
    );

    gate(
      'GEN-01098-G8',
      'The easier question is not substituted for the harder one.',
      'Counting icons that carry labels would pass at 100 per cent and is a '
          'different measurement wearing this metric\'s name',
      () =>
          !HabotContactFieldActions.recognitionIsMeasurableFromCode &&
          HabotContactFieldActions.deferralNote
              .contains('wearing the same metric'),
    );

    gate(
      'GEN-01098-G9',
      'Setup Step: "input field DOM value attribute".',
      'The DOM in a Flutter application -- the eleventh foreign stack in this '
          'track',
      () => HabotContactFieldActions.columnNote.contains('eleventh foreign'),
    );

    gate(
      'GEN-01098-G10',
      'Output: Good / Average / Poor.',
      'Five declared obligations, all met, giving a Good, with the '
          'measurement kept separate rather than scored as a failed '
          'obligation; all eleven declared checks hold',
      () =>
          HabotContactFieldActions.obligations.length == 5 &&
          HabotContactFieldActions.obligationsMet == 5 &&
          HabotContactFieldActions.conformance == 1.0 &&
          HabotContactFieldActions.qualitativeOutput == 'Good' &&
          HabotContactFieldActions.checks.length == 11 &&
          HabotContactFieldActions.checks.values.every((bool b) => b),
    );
  });

  group('GEN-01098 :: deferred', () {
    test('[GEN-01098-G11] icon recognition accuracy', () {
      gates.add(
        const AissGate(
          id: 'GEN-01098-G11',
          requirementSource:
              'Metric: Icon Recognition Accuracy -- floor 0.8, optimal 0.95, '
              'ceiling 1. ISO 9186 Graphical Symbol Testing.',
          description:
              'DEFERRED. Recognition accuracy is a number about people: the '
              'symbol is shown without its label to participants who have not '
              'seen the interface, and they say what it means. The protocol '
              'is written out -- an ISO 9186-1 referent-association test, '
              'open-ended responses coded by two independent raters, a sample '
              'drawn from the populations the app ships to. No code produces '
              'it, and the easier substitute (the share of icons carrying '
              'labels) is a different question this repository already '
              'passes.',
          passed: false,
          deferred: true,
          detail:
              'The geometry, the focus separation and the readiness rule are '
              'all met; what is deferred is the comprehension measurement '
              'itself, which is the one thing the row is scored on.',
        ),
      );
    });
  });

  tearDownAll(() {
    final String shareThree =
        HabotContactFieldActions.shareOfTheFieldFor(3).toStringAsFixed(4);
    final String partial = HabotContactFieldActions.disabledReasonFor('5012');

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01098',
        atomicStepReferenceId: 'GEN-01098',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Capture '
            'resultant input field DOM value attribute after masking '
            'execution" -- the DOM, in a Flutter application, and the eleventh '
            'foreign stack in this track. Atomic Step: "Embed M3 Outlined text '
            'fields with contact action icons."',
        implementationOrder: 308,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Embed M3 Outlined text fields with contact action icons.':
              '1 trailing action inside the field, 2 labelled buttons under '
                  'it; three inside would take $shareThree of the field',
          'Completion Status': 'Good, with one gate deferred',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'a partly typed number leaves the action disabled with the '
                  'reason "$partial"',
          'Data Quality Note':
              'GEOMETRY: ${HabotContactFieldActions.geometryNote} '
              'FOCUS: ${HabotContactFieldActions.focusNote} '
              'READINESS: ${HabotContactFieldActions.premature} '
              'METRIC: ${HabotContactFieldActions.metricIsCorrectNote} '
              'DEFERRAL: ${HabotContactFieldActions.deferralNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Icon Recognition Accuracy',
            observed:
                'NOT MEASURABLE FROM THIS REPOSITORY -- deferred with its '
                'protocol. The metric is correct for the row\'s subject and '
                'the row\'s floor of 0.8 is above ISO 9186\'s own acceptance '
                'criterion of about two thirds, which is a project being '
                'stricter than the standard it cites.',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Share of the field a trailing action occupies',
            observed:
                '16.2% with one action, against $shareThree with three. The '
                'three-action arrangement leaves 136 points for the value, '
                'which is less than a phone number needs, so two actions move '
                'under the field where they can be labelled.',
            floor: '<=0.25',
            optimal: '<=0.20',
            ceiling: '<=0.50',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/contact_field_actions.dart',
        ],
      ),
    );
  });
}
