/// AISS GATE -- Step 185 of 195
/// Global Reference ID:       GEN-01683
/// Atomic Steps Reference ID: GEN-01683
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Apply 8dp margin tokens between all adjacent components."
/// Metric: Touch Target Separation Compliance (%) -- Floor 98, Optimal 100,
///         Ceiling 100. Pass / Fail.
///
/// SEPARATION IS A PROPERTY OF A PAIR AND EVERY EXISTING CHECK HERE IS A
/// PROPERTY OF ONE COMPONENT. And the denominator is the whole problem:
/// computing compliance over every pair rather than every ADJACENT pair puts a
/// layout with every real gap broken at about 90%, which the row's floor of 98
/// would read as nearly passing.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/touch_standards.dart';
import 'package:udf_setup/design_system/tokens/separation_audit.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double compliance = 0;
  double naive = 0;

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

  /// A toolbar row: five 48dp controls, 8dp apart, laid out left to right.
  List<HabotControlRect> compliantRow() => <HabotControlRect>[
        for (int i = 0; i < 5; i++)
          HabotControlRect(
            'control$i',
            Rect.fromLTWH(i * 56.0, 0, 48, 48),
          ),
      ];

  /// The same row packed to 2dp gaps -- every real gap broken.
  List<HabotControlRect> crowdedRow() => <HabotControlRect>[
        for (int i = 0; i < 5; i++)
          HabotControlRect(
            'control$i',
            Rect.fromLTWH(i * 50.0, 0, 48, 48),
          ),
      ];

  group('GEN-01683 :: the denominator', () {
    gate(
      'GEN-01683-G1',
      'Atomic Step: "Apply 8dp margin tokens between all ADJACENT '
          'components."',
      'The clearance is read from the Step 3 token rather than restated, and '
          'the proximity threshold that defines adjacency is the minimum touch '
          'target -- beyond a finger\'s width, a tap aimed between two '
          'controls lands on neither',
      () =>
          HabotSeparationAudit.clearanceDp == TouchStandards.clearance &&
          HabotSeparationAudit.clearanceDp == HabotSpacing.xs &&
          HabotSeparationAudit.clearanceDp == 8 &&
          HabotSeparationAudit.proximityDp == HabotDensity.minTouchTarget &&
          HabotSeparationAudit.pairNotComponentNote
              .contains('every gap between them is 2dp'),
    );

    gate(
      'GEN-01683-G2',
      '"Twenty controls make 190 pairs, of which perhaps nineteen are '
          'adjacent."',
      'Adjacency is computed rather than assumed: in a five-control row only '
          'the four neighbouring pairs count, not all ten -- and a control on '
          'the far side of the screen is not adjacent to anything',
      () {
        final List<HabotControlRect> row = compliantRow();
        final List<HabotControlRect> spread = <HabotControlRect>[
          const HabotControlRect('left', Rect.fromLTWH(0, 0, 48, 48)),
          const HabotControlRect('right', Rect.fromLTWH(300, 0, 48, 48)),
        ];
        return HabotSeparationAudit.totalPairs(row.length) == 10 &&
            HabotSeparationAudit.adjacentPairs(row).length == 4 &&
            HabotSeparationAudit.adjacentPairs(spread).isEmpty &&
            !HabotSeparationAudit.areAdjacent(
              spread.first.rect,
              spread.last.rect,
            ) &&
            HabotSeparationAudit.areAdjacent(
              row[0].rect,
              row[1].rect,
            );
      },
    );

    gate(
      'GEN-01683-G3',
      'Metric: floor 98, optimal 100. "A layout with every real gap broken '
          'would read as nearly passing."',
      'The compliant row scores 100% and the crowded row scores 0% over '
          'adjacent pairs -- while the flattering all-pairs reading of the '
          'SAME crowded row reports 60%, which is the number that would have '
          'been believed',
      () {
        final List<HabotControlRect> good = compliantRow();
        final List<HabotControlRect> bad = crowdedRow();
        compliance = HabotSeparationAudit.compliancePercent(good);
        naive = HabotSeparationAudit.naiveComplianceOverAllPairs(bad);
        return compliance == 100 &&
            HabotSeparationAudit.violations(good).isEmpty &&
            HabotSeparationAudit.meetsFloor(good) &&
            HabotSeparationAudit.qualitativeOutput(good) == 'Pass' &&
            HabotSeparationAudit.compliancePercent(bad) == 0 &&
            !HabotSeparationAudit.meetsFloor(bad) &&
            HabotSeparationAudit.qualitativeOutput(bad) == 'Fail' &&
            naive == 60 &&
            naive > HabotSeparationAudit.compliancePercent(bad) &&
            HabotSeparationAudit.denominatorNote.contains('nearly passing');
      },
    );

    gate(
      'GEN-01683-G4',
      '"A screen with one control, or with controls nowhere near each other, '
          'has no separation defect."',
      'An empty set and a spread-out set both report 100 rather than 0, '
          'because reporting a failure there would make the metric unreadable '
          'on exactly the screens that are fine',
      () =>
          HabotSeparationAudit.compliancePercent(
            const <HabotControlRect>[],
          ) ==
              100 &&
          HabotSeparationAudit.compliancePercent(<HabotControlRect>[
            const HabotControlRect('only', Rect.fromLTWH(0, 0, 48, 48)),
          ]) ==
              100 &&
          HabotSeparationAudit.totalPairs(1) == 0 &&
          HabotSeparationAudit.totalPairs(0) == 0,
    );
  });

  group('GEN-01683 :: what a violation says', () {
    gate(
      'GEN-01683-G5',
      '"An overlap is not a small gap, it is a different failure."',
      'Two intersecting hit boxes are reported as overlapping with the reason '
          '-- one control is unreachable where they intersect and which one '
          'wins depends on tree order -- rather than as a gap of zero',
      () {
        final List<HabotControlRect> overlapping = <HabotControlRect>[
          const HabotControlRect('a', Rect.fromLTWH(0, 0, 48, 48)),
          const HabotControlRect('b', Rect.fromLTWH(40, 0, 48, 48)),
        ];
        final HabotSeparationFinding f =
            HabotSeparationAudit.violations(overlapping).single;
        return f.failure == HabotSeparationFailure.overlapping &&
            f.gapDp == 0 &&
            f.toString().contains('unreachable') &&
            f.toString().contains('tree order') &&
            HabotSeparationAudit.overlapping(overlapping).length == 1 &&
            HabotSeparationAudit.overlaps(
              overlapping.first.rect,
              overlapping.last.rect,
            );
      },
    );

    gate(
      'GEN-01683-G6',
      'A gap under the clearance is a seam a tap can land on.',
      'A too-close pair names both controls and the measured distance, and '
          'says what goes wrong -- the tap resolves to whichever is nearer, '
          'which is not what the user aimed at',
      () {
        final HabotSeparationFinding f =
            HabotSeparationAudit.violations(crowdedRow()).first;
        return f.failure == HabotSeparationFailure.tooClose &&
            f.gapDp == 2 &&
            f.a == 'control0' &&
            f.b == 'control1' &&
            f.toString().contains('2.0dp apart') &&
            f.toString().contains('under the 8dp clearance') &&
            f.toString().contains('not what the user aimed at');
      },
    );

    gate(
      'GEN-01683-G7',
      '"Two controls that look 12dp apart can have hit boxes that touch."',
      'The audit measures the separating distance on whichever axis separates '
          'the pair, so a vertical stack is judged by its vertical gaps and a '
          'diagonal neighbour by the larger of its two separations',
      () {
        final List<HabotControlRect> column = <HabotControlRect>[
          const HabotControlRect('top', Rect.fromLTWH(0, 0, 200, 48)),
          const HabotControlRect('bottom', Rect.fromLTWH(0, 50, 200, 48)),
        ];
        return HabotSeparationAudit.gapBetween(
              const Rect.fromLTWH(0, 0, 48, 48),
              const Rect.fromLTWH(56, 0, 48, 48),
            ) ==
                8 &&
            HabotSeparationAudit.gapBetween(
                  const Rect.fromLTWH(0, 0, 48, 48),
                  const Rect.fromLTWH(56, 56, 48, 48),
                ) ==
                8 &&
            HabotSeparationAudit.compliancePercent(column) == 0 &&
            HabotSeparationAudit.violations(column).single.gapDp == 2 &&
            HabotSeparationAudit.touchRectNote.contains('hit boxes that touch');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01683',
        atomicStepReferenceId: 'GEN-01683',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Apply 8dp margin tokens between all adjacent components."',
        implementationOrder: 185,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSeparationAudit / HabotSeparationFinding',
          'Component Properties':
              'Clearance ${HabotSeparationAudit.clearanceDp.toStringAsFixed(0)}'
              'dp from the Step 3 token; adjacency threshold '
              '${HabotSeparationAudit.proximityDp.toStringAsFixed(0)}dp; '
              'measured over touch rects rather than painted ones; overlaps '
              'reported as a distinct failure from close gaps',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: separation is a property of a pair and every existing '
              'check in this repository is a property of one component -- Step '
              '108 and Step 184 can both pass on every control in a screen '
              'while every gap between them is 2dp. hasClearance has existed '
              'since Step 3 and takes two scalars on one axis, so the caller '
              'has to already know which two things are adjacent; nothing '
              'calls it with a real layout. DENOMINATOR RECORDED: compliance '
              'is computed over ADJACENT pairs. Over all pairs, a crowded '
              'five-control row with every gap broken reports 60% -- and with '
              'twenty controls it would report about 90%, which the floor of '
              '98 would read as nearly passing.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Touch Target Separation Compliance (%)',
            observed:
                '${compliance.toStringAsFixed(0)}% on a compliant toolbar row '
                '(five 48dp controls, 8dp apart) over its four adjacent pairs. '
                'The same computation reports 0% on the identical row packed '
                'to 2dp gaps, while the all-pairs reading of that crowded row '
                'reports ${naive.toStringAsFixed(0)}% -- which is the number '
                'that would have been believed.',
            floor: '98',
            optimal: '100',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Failure classes distinguished',
            observed:
                '2 -- tooClose and overlapping. An overlap means one control '
                'is unreachable where the hit boxes intersect and which one '
                'wins depends on tree order, so it is reported separately '
                'rather than as a gap of zero.',
            floor: '2',
            optimal: '2',
            ceiling: '2',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/separation_audit.dart',
        ],
      ),
    );
  });
}
