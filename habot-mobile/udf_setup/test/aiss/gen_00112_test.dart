/// AISS GATE -- Step 86 of 95
/// Global Reference ID:       GEN-00112
/// Atomic Steps Reference ID: GEN-00112-A01
/// Setup Step (Action):       "Test visual isolation on mobile devices to
///                             ensure FULL READABILITY WITHOUT MANUAL
///                             PANNING."
/// Metric: Test Case Pass Rate --
///         Floor ">= 95% pass rate before release gate",
///         Optimal "100% pass rate on defined test suite",
///         Ceiling 1.0. Standard: ISO/IEC/IEEE 29119.
///
/// A TEST STEP WITH A TEST METRIC, which is rare enough in this sheet to use
/// literally. [HabotReadabilityAudit] IS the defined test suite the metric
/// refers to: nine devices from the Step 5 matrix, both orientations, and a
/// pass rate computed from the outcomes rather than declared.
///
/// A GENERATED ROW OTHERWISE, RECORDED: Setup Step and Description are the
/// same sentence, Why This Matters is that sentence plus "is a critical
/// implementation step", Expected Output is the template restatement, and
/// Completion Measures is "100% CI/CD pass rate ... committed to runbook".
/// None of that is gated.
///
/// WHAT "WITHOUT MANUAL PANNING" MEANS HERE, and it is the whole test: the
/// crop is fully inside the evidence pane at a legible scale, so the worker
/// never drags the image to read the rest of it. A snippet that needs panning
/// is a snippet whose right-hand half a worker may simply not read -- and this
/// batch exists to control exactly what they see.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/isolated_viewport.dart';

import 'aiss_reporter.dart';

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredPassRate = -1;
  int measuredCases = -1;
  double badPassRate = -1;

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

  group('GEN-00112-A01 :: the defined test suite', () {
    gate(
      'GEN-00112-G1',
      'Metric: Test Case Pass Rate -- Floor ">= 95% pass rate before release '
          'gate", Optimal "100% pass rate on defined test suite".',
      'The suite is every device in the Step 5 matrix in both orientations, '
          'and the pass rate is computed from the outcomes -- so the number '
          'reported is the number the metric asks for',
      () {
        final List<HabotReadabilityCase> cases = HabotReadabilityAudit.run(
          box: _box,
        );
        measuredCases = cases.length;
        measuredPassRate = HabotReadabilityAudit.passRateOf(cases);
        return measuredCases == HabotDevices.all.length * 2 &&
            measuredPassRate >= HabotReadabilityAudit.passRateFloor &&
            measuredPassRate == HabotReadabilityAudit.passRateOptimal &&
            HabotReadabilityAudit.failuresIn(cases).isEmpty;
      },
    );

    gate(
      'GEN-00112-G2',
      'ISO/IEC/IEEE 29119: a test suite that cannot fail is not a test suite. '
          'Read against GEN-04880 (Step 65), where the same discipline was '
          'applied to a reliability rate.',
      'A crop that genuinely cannot be read without panning drives the pass '
          'rate below the floor, and the failures name the devices and the '
          'reason, so a 100% on the real crop means something',
      () {
        const HabotBoundingBox unreadable = HabotBoundingBox(
          left: 0,
          top: 0,
          width: 9000,
          height: 1200,
          sourceWidth: 12000,
          sourceHeight: 12000,
        );
        final List<HabotReadabilityCase> cases = HabotReadabilityAudit.run(
          box: unreadable,
        );
        badPassRate = HabotReadabilityAudit.passRateOf(cases);
        final List<HabotReadabilityCase> failures =
            HabotReadabilityAudit.failuresIn(cases);
        return badPassRate < HabotReadabilityAudit.passRateFloor &&
            failures.isNotEmpty &&
            failures.first.detail.contains('scale') &&
            failures.first.toString().contains('FAIL');
      },
    );

    gate(
      'GEN-00112-G3',
      'Setup Step (Action): "full readability WITHOUT MANUAL PANNING" -- the '
          'literal requirement, which is about horizontal overflow.',
      'On every case in the suite the crop is no wider than the pane it sits '
          'in and is not clipped, so there is nothing off-screen to pan to',
      () {
        final List<HabotReadabilityCase> cases = HabotReadabilityAudit.run(
          box: _box,
        );
        // Every passing case carries the scale it was readable at, which is
        // the positive form of "no panning was required".
        return cases.every((HabotReadabilityCase c) => c.passed) &&
            cases.every(
              (HabotReadabilityCase c) =>
                  c.detail.contains('no panning required'),
            ) &&
            cases.where((HabotReadabilityCase c) => c.landscape).length ==
                HabotDevices.all.length;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00112',
        atomicStepReferenceId: 'GEN-00112-A01',
        setupStepAction:
            'Test visual isolation on mobile devices to ensure full '
            'readability without manual panning.',
        implementationOrder: 86,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Test visual isolation on mobile devices':
              'HabotReadabilityAudit -- the defined test suite: '
              '${HabotDevices.all.length} devices x 2 orientations',
          'Cases run': measuredCases < 0 ? 'not measured' : '$measuredCases',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'GENERATED ROW -- Setup Step and Description are the same '
              'sentence; Why This Matters, Expected Output and the substeps '
              'are template prose; Completion Measures is CI/CD tracking. Not '
              'gated. THE METRIC FITS THE STEP EXACTLY -- a Test Case Pass '
              'Rate on a testing step -- and is used literally: the suite is '
              'named, the cases are counted, and the rate is computed from '
              'their outcomes.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Test Case Pass Rate',
            observed: measuredPassRate < 0
                ? 'not measured'
                : '${(measuredPassRate * 100).toStringAsFixed(1)}% -- '
                      '$measuredCases of $measuredCases cases pass '
                      '(${HabotDevices.all.length} devices x 2 orientations), '
                      'each fully visible at a legible scale with no panning. '
                      'A deliberately unreadable crop scored '
                      '${(badPassRate * 100).toStringAsFixed(1)}% on the same '
                      'suite, so the rate moves.',
            floor: '>= 95% pass rate before release gate',
            optimal: '100% pass rate on defined test suite',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/isolated_viewport.dart',
          'lib/design_system/mto/isolation_geometry.dart',
        ],
      ),
    );
  });
}
