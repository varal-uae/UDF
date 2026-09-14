/// AISS GATE -- Step 184 of 195
/// Global Reference ID:       GEN-01043
/// Atomic Steps Reference ID: GEN-01043
/// Setup Step (Action): "Define the payload structure for the health
///                       confirmation ping request and response messages."
/// Atomic Step: "Set structural touch target size tokens to a mandatory
///               minimum parameter of 48x48dp."
/// Metric: Touch Target Size -- Floor ">=44x44dp", Optimal "48x48dp",
///         Ceiling "<=56x56dp". Pass / Fail.
///
/// THE MINIMUM HAS BEEN IN PLACE SINCE STEP 3. The ceiling is the new part,
/// and it is the half that gets left out: nothing here has ever checked the
/// upper bound the row gives. And the band applies to the SHORT side, or every
/// full-width button in the product fails it.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/touch_standards.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/tokens/touch_target_band.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double compliance = 0;

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

  group('GEN-01043 :: the band, in both directions', () {
    gate(
      'GEN-01043-G1',
      'Atomic Step: "...a mandatory minimum parameter of 48x48dp." Metric '
          'floor ">=44x44dp", optimal "48x48dp", ceiling "<=56x56dp".',
      'All three bounds are held as tokens, the optimal is read from the Step '
          '3 declaration rather than restated, and the WCAG 2.1 SC 2.5.5 AAA '
          'figure is the floor',
      () =>
          HabotTouchBand.optimalDp == HabotDensity.minTouchTarget &&
          HabotTouchBand.optimalDp == 48 &&
          HabotTouchBand.floorDp == 44 &&
          HabotTouchBand.ceilingDp == 56 &&
          HabotTouchBand.tokenSitsAtOptimal &&
          HabotTouchBand.qualitativeOutput == 'Pass',
    );

    gate(
      'GEN-01043-G2',
      '"A bound enforced only downwards is half a specification."',
      'The verdict reaches every state, including the one nothing in this '
          'repository had ever produced: a target past the ceiling',
      () =>
          HabotTouchBand.verdictFor(const Size(48, 48)) ==
              HabotTouchVerdict.optimal &&
          HabotTouchBand.verdictFor(const Size(46, 46)) ==
              HabotTouchVerdict.withinFloor &&
          HabotTouchBand.verdictFor(const Size(52, 52)) ==
              HabotTouchVerdict.withinCeiling &&
          HabotTouchBand.verdictFor(const Size(40, 40)) ==
              HabotTouchVerdict.tooSmall &&
          HabotTouchBand.verdictFor(const Size(72, 72)) ==
              HabotTouchVerdict.tooLarge &&
          HabotTouchVerdict.values.length == 5,
    );

    gate(
      'GEN-01043-G3',
      '"A full-width submit button is 48dp tall and 328dp wide; bounding both '
          'axes at 56dp would fail every primary action in the product."',
      'The band constrains the short side only: a wide button passes, a tall '
          'narrow strip passes, and a genuinely oversized square does not',
      () =>
          HabotTouchBand.minorOf(const Size(328, 48)) == 48 &&
          HabotTouchBand.majorOf(const Size(328, 48)) == 328 &&
          HabotTouchBand.isWithinBand(const Size(328, 48)) &&
          HabotTouchBand.isWithinBand(const Size(48, 200)) &&
          !HabotTouchBand.isWithinBand(const Size(72, 72)) &&
          !HabotTouchBand.isWithinBand(const Size(40, 300)) &&
          HabotTouchBand.minorAxisNote.contains('deliberately unbounded'),
    );

    gate(
      'GEN-01043-G4',
      '"A 72dp hit box around a 24dp icon fires when the user taps 24dp away '
          'from anything visible."',
      'A finding says which direction it failed in and by how much, so an '
          'oversized target is reported as its own defect rather than as a '
          'generic size failure',
      () {
        final HabotTouchFinding tooLarge =
            HabotTouchBand.measure('icon.hitbox', const Size(72, 72));
        final HabotTouchFinding tooSmall =
            HabotTouchBand.measure('chip.close', const Size(32, 32));
        return tooLarge.isFailure &&
            tooLarge.toString().contains('past the 56dp ceiling') &&
            tooLarge.toString().contains('24dp away') &&
            tooSmall.isFailure &&
            tooSmall.toString().contains('below the 44dp floor') &&
            tooSmall.toString().contains('A finger misses it') &&
            !HabotTouchBand.measure('ok', const Size(48, 48)).isFailure &&
            HabotTouchBand.tooLargeIsADefectNote.contains('8dp clearance');
      },
    );
  });

  group('GEN-01043 :: applied to what the design system ships', () {
    gate(
      'GEN-01043-G5',
      'Step 3 pads a glyph up to the target size. "Padding is only ever added '
          'to reach the floor, never beyond it."',
      'Every icon size the design system offers resolves to a target at the '
          'optimum rather than merely above the floor -- which is what the new '
          'ceiling makes checkable, because a padding rule that overshot would '
          'previously have passed',
      () {
        final List<HabotTouchFinding> icons = HabotTouchBand.auditIconSizes();
        return icons.length == HabotIconSize.values.length &&
            icons.every(
              (HabotTouchFinding f) =>
                  f.verdict == HabotTouchVerdict.optimal && !f.isFailure,
            ) &&
            TouchStandards.targetFor(TouchStandards.iconSizeFor(
                  HabotIconSize.dense,
                )) ==
                const Size(48, 48);
      },
    );

    gate(
      'GEN-01043-G6',
      'A compliance rate over a declared set is what turns a rule into a '
          'measurement.',
      'The rate falls when a control leaves the band in either direction, and '
          'the violations are named rather than counted',
      () {
        const Map<String, Size> clean = <String, Size>{
          'submit': Size(328, 48),
          'back': Size(48, 48),
          'filter': Size(56, 48),
        };
        const Map<String, Size> mixed = <String, Size>{
          'submit': Size(328, 48),
          'chipClose': Size(32, 32),
          'avatarTap': Size(72, 72),
          'back': Size(48, 48),
        };
        compliance = HabotTouchBand.complianceRate(clean);
        return compliance == 1.0 &&
            HabotTouchBand.violations(clean).isEmpty &&
            HabotTouchBand.complianceRate(mixed) == 0.5 &&
            HabotTouchBand.violations(mixed).length == 2 &&
            HabotTouchBand.violations(mixed)
                .any((HabotTouchFinding f) => f.label == 'chipClose') &&
            HabotTouchBand.violations(mixed)
                .any((HabotTouchFinding f) => f.label == 'avatarTap') &&
            HabotTouchBand.complianceRate(const <String, Size>{}) == 1.0;
      },
    );

    gate(
      'GEN-01043-G7',
      'A finding recorded rather than resolved: the guard and the token '
          'manifest disagree about what a token file is.',
      'touch_standards.dart is exempted by the poka-yoke guard as a metric '
          'declaration site and is not a declared family in the Step 176 '
          'manifest; the disagreement is written down rather than settled by '
          'quietly adding it to one of them',
      () =>
          !HabotTouchBand.touchStandardsIsDeclaredFamily &&
          HabotTouchBand.declarationSiteInconsistency
              .contains('touch_standards.dart') &&
          HabotTouchBand.declarationSiteInconsistency
              .contains('Recorded rather than resolved') &&
          HabotTouchBand.columnNote.contains('health-ping payload'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01043',
        atomicStepReferenceId: 'GEN-01043',
        setupStepAction:
            'COLUMN NOTE: the Setup Step names a health-ping payload '
            'structure; the Atomic Step names touch target tokens. Atomic '
            'Step: "Set structural touch target size tokens to a mandatory '
            'minimum parameter of 48x48dp."',
        implementationOrder: 184,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTouchBand / HabotTouchFinding',
          'Component Properties':
              'Floor ${HabotTouchBand.floorDp.toStringAsFixed(0)}dp, optimal '
              '${HabotTouchBand.optimalDp.toStringAsFixed(0)}dp, ceiling '
              '${HabotTouchBand.ceilingDp.toStringAsFixed(0)}dp, applied to '
              'the minor dimension; ${HabotTouchVerdict.values.length} '
              'verdicts including two failure directions',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'THE CEILING IS THE NEW PART. The 48dp minimum has been in place '
              'since Step 3 and Step 108 audits against it; nothing had ever '
              'checked the upper bound the row gives. A too-large target is a '
              'real defect: a 72dp hit box around a 24dp icon fires when the '
              'user taps 24dp from anything visible, and oversized neighbours '
              'grow into the 8dp clearance between them. THE BAND APPLIES TO '
              'THE SHORT SIDE, because bounding both axes at 56dp would fail '
              'every full-width primary action. FINDING RECORDED: '
              'touch_standards.dart is a metric declaration site to the guard '
              'and not a declared family in the Step 176 manifest -- the two '
              'disagree about what a token file is.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Touch Target Size',
            observed:
                'The declared token sits at the optimum '
                '(${HabotTouchBand.optimalDp.toStringAsFixed(0)}dp) and every '
                'icon size the design system offers resolves to a '
                '48x48dp target -- optimal rather than merely above the floor. '
                'The band now rejects in both directions: 40dp reads tooSmall '
                'and 72dp reads tooLarge, the latter being a state nothing in '
                'this repository could previously produce.',
            floor: '>=44x44dp',
            optimal: '48x48dp',
            ceiling: '<=56x56dp',
          ),
          AissMeasurement(
            metricName: 'Compliance over a declared control set',
            observed:
                '${(compliance * 100).toStringAsFixed(0)}% on a clean set. The '
                'same computation reports 50% on a set containing one '
                'undersized chip close and one oversized avatar tap, naming '
                'both -- so the figure is a measurement rather than a '
                'constant.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/touch_target_band.dart',
        ],
      ),
    );
  });
}
