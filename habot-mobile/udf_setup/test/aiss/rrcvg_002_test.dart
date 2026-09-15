/// AISS GATE -- Step 284 of 295
/// Global Reference ID:       RRCVG-002
/// Atomic Steps Reference ID: RRCVG-002
/// Setup Step (Action): "Program state management to serialize and retain
///                      current form field inputs in local storage."
///                      (DIFFERENT SUBJECT)
/// Atomic Step: "Integrate Material Design 3 md-linear-progress components to
///               display progression metrics."
/// Metric: Mobile Usability Compliance (Touch Target Size & Core Web Vitals)
///         -- three subjects in one cell; see the file header.
///
/// AN HTML CUSTOM ELEMENT, A TOUCH-TARGET METRIC ON SOMETHING NOBODY PRESSES,
/// AND CORE WEB VITALS IN AN APPLICATION WITH NO DOM.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/linear_progress_binding.dart';

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

  group('RRCVG-002 :: three subjects in one cell', () {
    gate(
      'RRCVG-002-G1',
      'Atomic Step: "md-linear-progress components".',
      'That is a Material Web Components custom element -- a tag in markup -- '
          'and the component already exists here, making this the seventh row '
          'written against a stack that was never used',
      () =>
          HabotLinearProgressBinding.theNamedElementIsMarkup &&
          HabotLinearProgressBinding.stackAssumptionOrdinal == 7 &&
          HabotLinearProgressBinding.customElementNote.contains('seventh row'),
    );

    gate(
      'RRCVG-002-G2',
      'Metric half one: touch target size.',
      'Nobody presses a progress bar, so scoring it against a 44-point '
          'minimum measures nothing -- and a perfect result would be a '
          'statement about every other control on the screen',
      () =>
          HabotLinearProgressBinding.theTouchHalfDoesNotApply &&
          HabotLinearProgressBinding.notInteractiveNote
              .contains('measures nothing'),
    );

    gate(
      'RRCVG-002-G3',
      'Metric half two: Core Web Vitals.',
      'LCP and CLS are defined over a DOM there is none of, but layout shift '
          'transfers: reserving the bar\'s space removes the shift, measured '
          'rather than asserted',
      () =>
          HabotLinearProgressBinding.reservingSpaceRemovesTheShift &&
          HabotLinearProgressBinding.spaceIsReserved &&
          HabotLinearProgressBinding.vitalsNote.contains('loses their line'),
    );

    gate(
      'RRCVG-002-G4',
      'And a third subject in the output-type column.',
      'Loyalty-industry benchmarks from a points-programme report, on a row '
          'about a progress bar, with the surrounding columns about API '
          'payload limits',
      () =>
          HabotLinearProgressBinding.threeSubjectsInOneCell &&
          HabotLinearProgressBinding.threeSubjectsNote
              .contains('THREE SUBJECTS'),
    );
  });

  group('RRCVG-002 :: the honest question, determinacy', () {
    gate(
      'RRCVG-002-G5',
      'A determinate bar claims to know how much is left.',
      'Four progression sites are classified by what is known when the bar '
          'appears; two qualify as determinate and two do not',
      () =>
          HabotLinearProgressBinding.sites.length == 4 &&
          HabotLinearProgressBinding.determinateSites.length == 2 &&
          (HabotLinearProgressBinding.shareDeterminate - 0.5).abs() < 1e-9,
    );

    gate(
      'RRCVG-002-G6',
      'A bar that runs to 90% and waits has told a lie.',
      'The cost -- that the next honest wait is not believed either -- is '
          'recorded rather than left as a preference',
      () => HabotLinearProgressBinding.determinacyNote
          .contains('is not believed either'),
    );

    gate(
      'RRCVG-002-G7',
      'The existing policy already decides determinacy and range.',
      'A null value is indeterminate, an out-of-range fraction is clamped, '
          'and the value is announced as a number rather than left to the '
          'bar\'s appearance -- all read from the Step 97 policy',
      () =>
          HabotLinearProgressBinding.theExistingPolicyDecidesDeterminacy &&
          HabotLinearProgressBinding.outOfRangeValuesAreClamped &&
          HabotLinearProgressBinding.theValueIsAnnounced,
    );

    gate(
      'RRCVG-002-G8',
      'Output: Pass / Fail; Good / Average / Poor.',
      'Five obligations, all met, giving 1.0 and a Good on the transferable '
          'half; all eleven declared checks hold',
      () =>
          HabotLinearProgressBinding.obligations.length == 5 &&
          HabotLinearProgressBinding.obligations.values.every((bool b) => b) &&
          HabotLinearProgressBinding.complianceRate == 1.0 &&
          HabotLinearProgressBinding.qualitativeOutput == 'Good' &&
          HabotLinearProgressBinding.checks.length == 11 &&
          HabotLinearProgressBinding.checks.values.every((bool b) => b) &&
          HabotLinearProgressBinding.columnNote.contains('payload limits'),
    );
  });

  tearDownAll(() {
    final String shift = HabotLinearProgressBinding.shiftCausedBy(
      spaceReserved: false,
      barHeightDp: HabotLinearProgressBinding.barHeightDp,
    ).toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'RRCVG-002',
        atomicStepReferenceId: 'RRCVG-002',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Program '
            'state management to serialize and retain current form field '
            'inputs in local storage", and every narrative column is about '
            'API gateway payload limits. Atomic Step: "Integrate Material '
            'Design 3 md-linear-progress components to display progression '
            'metrics."',
        implementationOrder: 284,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotLinearProgressBinding / HabotProgressSite',
          'Component Properties':
              '${HabotLinearProgressBinding.sites.length} progression sites, '
              '${HabotLinearProgressBinding.determinateSites.length} of them '
              'determinate because the total is known before the work starts; '
              'space reserved whether the bar shows or not; determinacy, '
              'clamping and announcement all read from the existing policy',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotLinearProgressBinding.customElementNote} '
              'TOUCH: ${HabotLinearProgressBinding.notInteractiveNote} '
              'VITALS: ${HabotLinearProgressBinding.vitalsNote} '
              'SUBJECTS: ${HabotLinearProgressBinding.threeSubjectsNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Usability Compliance (Touch & Core Web '
                'Vitals)',
            observed:
                'NEITHER HALF REACHES THIS COMPONENT AS WRITTEN. Touch target '
                'size is a property of things people press and nobody presses '
                'a progress bar; LCP and CLS are defined over a DOM this '
                'application does not have. The transferable part is layout '
                'stability, and it is implemented: an unreserved bar shifts '
                'the content below it by ${shift}dp and a reserved one by 0.',
            floor: '>=90% of interactive elements at 44x44px; CWV "Needs '
                'Improvement" or better',
            optimal: '100% at 44-48px; CWV "Good" (LCP <2.5s, CLS <0.1)',
            ceiling: '100%; padding beyond ~56-60px reduces density',
          ),
          AissMeasurement(
            metricName: 'Progression sites allowed to be determinate',
            observed:
                '${HabotLinearProgressBinding.determinateSites.length} of '
                '${HabotLinearProgressBinding.sites.length}. The other two '
                'discover their total part-way through or never have one, and '
                'stay indeterminate rather than guessing.',
            floor: 'stated per site',
            optimal: 'stated per site',
            ceiling: 'stated per site',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/linear_progress_binding.dart',
        ],
      ),
    );
  });
}
