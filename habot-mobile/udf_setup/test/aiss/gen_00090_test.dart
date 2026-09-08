/// AISS GATE -- Step 108 of 115
/// Global Reference ID:       GEN-00090
/// Atomic Steps Reference ID: GEN-00090-A01
/// Setup Step (Action):       "Test tap accuracy across various mobile screen
///                             sizes and thumb zones."
/// Metric: restates the TTMAC-011 touch standard -- 44px floor, 48dp optimal,
///         56dp ceiling.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// THE METRIC RESTATES STEP 10, RECORDED. Step 10 already declares and gates
/// 44/48/56. This step consumes those numbers rather than redeclaring them,
/// and measures the thing Step 10 did not: whether the finger lands on the
/// target.
///
/// PROVENANCE, STATED PLAINLY: the offset and scatter figures are a MODEL, not
/// telemetry from this product. Nothing here is reported as an observed
/// accuracy rate.
library;

import 'dart:ui' show Rect, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/tap_accuracy.dart';
import 'package:udf_setup/design_system/interaction/touch_target.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late List<HabotTapAccuracyResult> audit;

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

  setUpAll(() {
    audit = HabotTapAccuracyAudit.audit();
  });

  group('GEN-00090-A01 :: one definition of a touch target', () {
    gate(
      'GEN-00090-G1',
      'The metric restates TTMAC-011 (Step 10). Two definitions of a touch '
          'target is one more than this project can keep consistent.',
      'The touch minimum and safety margin are READ from Step 10, not '
          'redeclared, so changing the standard changes this model too',
      () =>
          HabotTapAccuracy.minTargetDp == TouchTargetPolicy.minimumDp &&
          HabotTapAccuracy.safetyMarginDp == TouchTargetPolicy.safetyMarginDp,
    );

    gate(
      'GEN-00090-G2',
      'Setup Step (Action): "test tap accuracy across various MOBILE SCREEN '
          'SIZES and THUMB ZONES".',
      'The audit covers every phone profile in the Step 5 device matrix, in '
          'both one-handed grips, at nine screen positions -- and the reach '
          'band is derived from the Step 39 thumb geometry rather than a '
          'second definition of reachable',
      () {
        final int phones = HabotDevices.ofType(HabotDeviceType.phone).length;
        return phones > 0 &&
            audit.length == phones * 2 * 9 &&
            audit.map((HabotTapAccuracyResult r) => r.deviceName).toSet().length ==
                phones &&
            HabotTapAccuracyAudit.isInThumbBand(
              const Rect.fromLTWH(0, 600, 48, 48),
              const Size(375, 667),
            );
      },
    );
  });

  group('GEN-00090-A01 :: size is not accuracy', () {
    gate(
      'GEN-00090-G3',
      'Step 10 asks whether the target is big enough. This asks whether the '
          'finger lands on it.',
      'The model discriminates: a 48dp target is hit throughout the natural '
          'and stretch bands and MISSED out of reach, so the audit produces a '
          'map of where a compliant control is still too small for where it '
          'has been put',
      () {
        final List<HabotTapAccuracyResult> misses =
            HabotTapAccuracyAudit.misses();
        return misses.isNotEmpty &&
            misses.every(
              (HabotTapAccuracyResult r) =>
                  r.band == HabotReachBand.outOfReach,
            ) &&
            misses.every(
              (HabotTapAccuracyResult r) => r.meetsSizeStandard,
            ) &&
            audit
                .where(
                  (HabotTapAccuracyResult r) =>
                      r.band != HabotReachBand.outOfReach,
                )
                .every((HabotTapAccuracyResult r) => r.hits);
      },
    );

    gate(
      'GEN-00090-G4',
      'A control at the bottom centre is the easy case and must never be a '
          'miss; a control at the far top corner is the hard one.',
      'Bottom-centre targets are hit in both grips on every device, and the '
          'misses are confined to the far top corner -- which is the result '
          'the step exists to produce',
      () {
        final Iterable<HabotTapAccuracyResult> bottomCentre = audit.where(
          (HabotTapAccuracyResult r) => r.targetLabel == 'bottom-centre',
        );
        final Iterable<HabotTapAccuracyResult> misses =
            HabotTapAccuracyAudit.misses();
        return bottomCentre.isNotEmpty &&
            bottomCentre.every((HabotTapAccuracyResult r) => r.hits) &&
            misses.every(
              (HabotTapAccuracyResult r) => r.targetLabel.startsWith('top-'),
            );
      },
    );

    gate(
      'GEN-00090-G5',
      'A model is not permitted to argue for a control smaller than the '
          'standard.',
      'The required size never falls below the Step 10 floor, and it only '
          'rises above it out of reach -- a finding worth stating: 48dp is '
          'adequate everywhere a thumb actually goes',
      () {
        final double natural = HabotTapAccuracyAudit.sizeRequiredFor(
          HabotReachBand.natural,
        );
        final double stretch = HabotTapAccuracyAudit.sizeRequiredFor(
          HabotReachBand.stretch,
        );
        final double out = HabotTapAccuracyAudit.sizeRequiredFor(
          HabotReachBand.outOfReach,
        );
        return natural == TouchTargetPolicy.minimumDp &&
            stretch == TouchTargetPolicy.minimumDp &&
            out > TouchTargetPolicy.minimumDp;
      },
    );

    gate(
      'GEN-00090-G6',
      'The systematic offset and the scatter ADD; treating them as '
          'alternatives is how a model concludes every target is fine.',
      'Displacement grows monotonically with reach, and the model is declared '
          'as named constants so real telemetry can replace it later without '
          'rewriting the audit',
      () {
        double dy(HabotReachBand b) =>
            HabotTapAccuracy.worstCaseDisplacement(
              HabotGrip.rightThumb,
              b,
            ).dy;
        return dy(HabotReachBand.natural) < dy(HabotReachBand.stretch) &&
            dy(HabotReachBand.stretch) < dy(HabotReachBand.outOfReach) &&
            HabotTapAccuracy.baseScatterDp > 0 &&
            HabotTapAccuracy.scatterFor(HabotReachBand.natural) ==
                HabotTapAccuracy.baseScatterDp;
      },
    );
  });

  tearDownAll(() {
    final List<HabotTapAccuracyResult> misses =
        HabotTapAccuracyAudit.misses();
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00090',
        atomicStepReferenceId: 'GEN-00090-A01',
        setupStepAction:
            'Test tap accuracy across various mobile screen sizes and thumb '
            'zones.',
        implementationOrder: 108,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTapAccuracy / HabotTapAccuracyAudit',
          'Component Properties':
              '${HabotDevices.ofType(HabotDeviceType.phone).length} phone '
              'profiles x 2 grips x 9 positions = ${audit.length} measured '
              'targets; contact-patch scatter '
              '${HabotTapAccuracy.baseScatterDp}dp, stretch penalty '
              '${HabotTapAccuracy.stretchPenaltyDp}dp, out-of-reach penalty '
              '${HabotTapAccuracy.outOfReachPenaltyDp}dp',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'The metric restates the Step 10 touch standard verbatim. Those '
              'numbers are consumed, not redeclared; what is measured here is '
              'accuracy, which Step 10 did not cover.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Modelled tap accuracy on a 48dp target',
            observed:
                '${audit.length - misses.length} of ${audit.length} '
                'positions hit. Every miss is in the out-of-reach band and '
                'every miss is on a target that PASSES the Step 10 size '
                'check -- which is the point: the far top corner of a phone '
                'is a placement problem, not a sizing one.',
            floor: '44px (WCAG)',
            optimal: '48dp (Material)',
            ceiling: '56dp',
          ),
          const AissMeasurement(
            metricName: 'Observed tap accuracy for this product',
            observed:
                'NOT PRODUCED. The offset and scatter figures are a model '
                'consistent with the touch literature the 44/48/56 bands come '
                'from, not a measurement of this app users. Real telemetry '
                'needs the Step 123 sync loop to carry it, and the constants '
                'are named so it can replace them.',
            floor: 'no telemetry pipeline yet',
            optimal: 'no telemetry pipeline yet',
            ceiling: 'no telemetry pipeline yet',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/tap_accuracy.dart',
        ],
      ),
    );
  });
}
