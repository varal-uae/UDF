/// AISS GATE -- Step 241 of 255
/// Global Reference ID:       GEN-03558
/// Atomic Steps Reference ID: GEN-03558
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Standardize the requirement: Standardize input mask
///               components across all subledger interfaces."
/// Metric: Cross-Subledger Mask Standardization -- Floor 0.99, Optimal 1,
///         Ceiling 1. Pass/Fail. Standard cited: UI/UX Consistency Design
///         System.
///
/// THERE ARE NO SUBLEDGER INTERFACES, AND STANDARDISING ON A BROKEN COMPONENT
/// STANDARDISES THE BREAK. REPORTS FAIL on the components as declared.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/mask_standardisation.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double declared = 0;
  double corrected = 0;

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

  group('GEN-03558 :: the substitution', () {
    gate(
      'GEN-03558-G1',
      'Atomic Step: "across all SUBLEDGER INTERFACES."',
      'A subledger is an accounting structure and this is an application a '
          'parent books a child\'s activity in, so the population is named one '
          'surface at a time -- five of them -- rather than left as a phrase '
          'the metric could report 1.0 over',
      () =>
          HabotMaskStandardisation.rowConcept == 'subledger interfaces' &&
          HabotMaskStandardisation.surfaces.length == 5 &&
          HabotMaskStandardisation.substitution
              .contains('population of nothing'),
    );

    gate(
      'GEN-03558-G2',
      'A surface that builds its own formatter is the deviation.',
      'Every one of the five takes the shared component through '
          'ValidatedInputField, so surface adoption is total and the metric '
          'has to find its failure somewhere other than in adoption',
      () =>
          HabotMaskStandardisation.deviatingSurfaces.isEmpty &&
          HabotMaskStandardisation.surfaceAdoptionRate == 1.0,
    );

    gate(
      'GEN-03558-G3',
      'A standardisation claim over two classes out of thirteen is a claim '
          'about nothing.',
      'The five surfaces take twelve of the thirteen declared classes between '
          'them, and the one nobody takes -- dateUs, a US date ordering in an '
          'application whose money is AED -- is named rather than dropped from '
          'the denominator',
      () =>
          HabotMaskStandardisation.classesInUse.length == 12 &&
          HabotMaskStandardisation.classesNotInUse.single == HabotCde.dateUs &&
          (HabotMaskStandardisation.classCoverage - 12 / 13).abs() < 1e-9 &&
          HabotMaskStandardisation.checkTheDenominatorNote
              .contains('claim about nothing'),
    );

    gate(
      'GEN-03558-G4',
      'Two surfaces in two locales correctly show two different strings.',
      'What is standardised is the component rather than the rendered string, '
          'because the group separator is locale-dependent and a rule that '
          'compared output text would push somebody to hard-code one',
      () =>
          HabotMaskStandardisation.localeNote
              .contains('one formatter per class of field') &&
          HabotMaskStandardisation.localeNote.contains('1.234,56'),
    );
  });

  group('GEN-03558 :: the same defect, a second metric', () {
    gate(
      'GEN-03558-G5',
      'Step 238 found three declared fields whose mask contradicts their own '
          'pattern.',
      'Two of the three are actually taken by a surface -- dateIso and '
          'timeOfDay, both on the reports surface -- so standardising on the '
          'components as declared standardises a break rather than a component',
      () =>
          HabotMaskStandardisation.brokenClassesInUse.length == 2 &&
          HabotMaskStandardisation.brokenClassesInUse
              .contains(HabotCde.dateIso) &&
          HabotMaskStandardisation.brokenClassesInUse
              .contains(HabotCde.timeOfDay) &&
          HabotMaskStandardisation.brokenComponentNote
              .contains('standardises the break'),
    );

    gate(
      'GEN-03558-G6',
      'Metric: Cross-Subledger Mask Standardization -- floor 0.99.',
      'Measured over surface-and-class pairs the declared components score '
          '0.867, below the row\'s floor; with Step 238\'s correction adopted '
          'the same measurement is at the ceiling, and both are published',
      () {
        declared = HabotMaskStandardisation.declaredStandardisationRate;
        corrected = HabotMaskStandardisation.correctedStandardisationRate;
        return (declared - 13 / 15).abs() < 1e-9 &&
            declared < HabotMaskStandardisation.floor &&
            corrected == HabotMaskStandardisation.ceiling;
      },
    );

    gate(
      'GEN-03558-G7',
      'Cross-Subledger Mask Standardization -- Pass/Fail.',
      'All ten checks hold and the step reports Fail on the components as they '
          'stand and Pass on the corrected ones, with the surface-level claim '
          'resting on Step 236\'s field model rather than on its own list',
      () =>
          HabotMaskStandardisation.checks.length == 10 &&
          HabotMaskStandardisation.checks.values.every((bool b) => b) &&
          HabotMaskStandardisation.qualitativeOutput == 'Fail' &&
          HabotMaskStandardisation.qualitativeOutputAfterCorrection ==
              'Pass' &&
          HabotMaskStandardisation.restsOnTheStep236Model &&
          HabotMaskStandardisation.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03558',
        atomicStepReferenceId: 'GEN-03558',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Standardize the requirement: Standardize input mask '
            'components across all subledger interfaces."',
        implementationOrder: 241,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotMaskStandardisation / HabotInputSurface',
          'Component Properties':
              '${HabotMaskStandardisation.surfaces.length} input surfaces '
              'taking ${HabotMaskStandardisation.classesInUse.length} of the '
              'thirteen declared field classes; '
              '${HabotMaskStandardisation.deviatingSurfaces.length} surfaces '
              'building their own formatters; '
              '${HabotMaskStandardisation.brokenClassesInUse.length} classes '
              'in use whose declared mask contradicts their own pattern',
          'Completion Status': 'FAIL on the components as declared',
          'Data Quality Note':
              'SUBSTITUTION: ${HabotMaskStandardisation.substitution} '
              'FINDING: ${HabotMaskStandardisation.brokenComponentNote} '
              'BOUNDARY: ${HabotMaskStandardisation.localeNote} '
              'DENOMINATOR: '
              '${HabotMaskStandardisation.checkTheDenominatorNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Cross-Subledger Mask Standardization (substituted: '
                'surfaces that take typed input)',
            observed:
                '${declared.toStringAsFixed(3)} over fifteen '
                'surface-and-class pairs. Adoption of the shared component is '
                'total; the shortfall is entirely the two broken classes the '
                'reports surface takes. With Step 238\'s correction adopted '
                'the same measurement is ${corrected.toStringAsFixed(1)}.',
            floor: '0.99',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Declared field classes no surface takes',
            observed:
                '${HabotMaskStandardisation.classesNotInUse.length} of '
                'thirteen -- dateUs. Named rather than dropped from the '
                'denominator: a declared field nobody uses is worth knowing '
                'about, particularly a US date ordering in an application '
                'whose money is AED.',
            floor: '0',
            optimal: '0',
            ceiling: '13',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/mask_standardisation.dart',
        ],
      ),
    );
  });
}
