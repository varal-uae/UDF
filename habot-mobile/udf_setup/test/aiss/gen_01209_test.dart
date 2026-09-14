/// AISS GATE -- Step 203 of 215
/// Global Reference ID:       GEN-01209
/// Atomic Steps Reference ID: GEN-01209
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Set structural rules limiting displayed add-on options to a
///               maximum of 3 items per service."
/// Metric: Add-On Attach Rate -- Floor 0.1, Optimal 0.25, Ceiling 0.4.
///         Good/Average/Poor.
///
/// A CAP OF THREE OVER A CATALOGUE OF SEVEN DOES NOT REDUCE CLUTTER, IT ELECTS
/// THREE WINNERS -- and the attach rate then measures the ordering rather than
/// the catalogue. The row sets the cap and leaves the election unspecified.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/booking/addon_display_rules.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double reach = 0;

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

  /// Seven add-ons, one of them mandatory. Deliberately declared out of
  /// priority order so insertion order and ranked order differ.
  List<HabotAddOn> catalogue() => const <HabotAddOn>[
        HabotAddOn(
          id: 'photo',
          name: 'Photo pack',
          priceMinorUnits: 4500,
          operatorPriority: 4,
        ),
        HabotAddOn(
          id: 'lunch',
          name: 'Hot lunch',
          priceMinorUnits: 2500,
          operatorPriority: 1,
        ),
        HabotAddOn(
          id: 'insurance',
          name: 'Activity cover',
          priceMinorUnits: 1000,
          operatorPriority: 0,
          isRequiredByService: true,
        ),
        HabotAddOn(
          id: 'transport',
          name: 'Coach transfer',
          priceMinorUnits: 3000,
          operatorPriority: 2,
        ),
        HabotAddOn(
          id: 'kit',
          name: 'Kit hire',
          priceMinorUnits: 1500,
          operatorPriority: 3,
        ),
        HabotAddOn(
          id: 'extended',
          name: 'Extended hours',
          priceMinorUnits: 6000,
          operatorPriority: 5,
        ),
        // Same priority as 'extended': the tie is broken by price, then id.
        HabotAddOn(
          id: 'aftercare',
          name: 'Aftercare',
          priceMinorUnits: 5500,
          operatorPriority: 5,
        ),
      ];

  group('GEN-01209 :: which three', () {
    gate(
      'GEN-01209-G1',
      'Atomic Step: "limiting DISPLAYED add-on options to a maximum of 3 items '
          'per service." The row sets the cap and not the ordering.',
      'The three shown are chosen by a declared ranking -- operator priority, '
          'then price, then id -- rather than by whatever order the catalogue '
          'yielded, and the ranked result differs from the insertion order it '
          'would otherwise have used',
      () {
        final List<String> ranked = HabotAddOnDisplayRules.visible(catalogue())
            .map((HabotAddOn a) => a.id)
            .toList();
        final List<String> unranked = HabotAddOnDisplayRules.visible(
          catalogue(),
          ranking: HabotAddOnRanking.sourceOrder,
        ).map((HabotAddOn a) => a.id).toList();
        return ranked.length == HabotAddOnDisplayRules.maximumDisplayed &&
            ranked.join(',') == 'lunch,transport,kit' &&
            unranked.join(',') == 'photo,lunch,transport' &&
            ranked.join(',') != unranked.join(',') &&
            HabotAddOnRanking.values.length == 2;
      },
    );

    gate(
      'GEN-01209-G2',
      '"Two runs over the same catalogue must produce the same three."',
      'The ranking is total to the id, so reversing the catalogue does not '
          'change the three that are shown -- while the ordering the row\'s '
          'silence would have produced does change',
      () =>
          HabotAddOnDisplayRules.isDeterministic(catalogue()) &&
          !HabotAddOnDisplayRules.sourceOrderIsDeterministic(catalogue()),
    );

    gate(
      'GEN-01209-G3',
      '"Three are displayed" and "four do not exist" are different products.',
      'The hidden add-ons are reachable and the disclosure names how many '
          'there are rather than saying "More", which could mean anything',
      () {
        final List<HabotAddOn> hidden =
            HabotAddOnDisplayRules.hidden(catalogue());
        return HabotAddOnDisplayRules.hasMore(catalogue()) &&
            hidden.length == 3 &&
            hidden.map((HabotAddOn a) => a.id).join(',') ==
                'photo,aftercare,extended' &&
            HabotAddOnDisplayRules.disclosureLabel(catalogue()) ==
                'Show 3 more options' &&
            HabotAddOnDisplayRules.hiddenIsNotAbsentNote
                .contains('different products');
      },
    );

    gate(
      'GEN-01209-G4',
      '"Hiding a mandatory item behind a disclosure produces a booking whose '
          'price the parent did not see."',
      'The required add-on is not subject to the cap, is not among the three '
          'optional slots, and is excluded from the attach-rate population '
          'because it was never a choice',
      () {
        final List<HabotAddOn> required =
            HabotAddOnDisplayRules.required(catalogue());
        final List<String> visibleIds = HabotAddOnDisplayRules
            .visible(catalogue())
            .map((HabotAddOn a) => a.id)
            .toList();
        final List<String> hiddenIds = HabotAddOnDisplayRules
            .hidden(catalogue())
            .map((HabotAddOn a) => a.id)
            .toList();
        return required.single.id == 'insurance' &&
            !visibleIds.contains('insurance') &&
            !hiddenIds.contains('insurance') &&
            HabotAddOnDisplayRules.requiredIsNotAnAttachmentNote
                .contains('inflates the metric');
      },
    );
  });

  group('GEN-01209 :: what the cap does to the metric', () {
    gate(
      'GEN-01209-G5',
      '"The four hidden add-ons are indistinguishable in the data from add-ons '
          'nobody wanted."',
      'Default reach is 0.5 -- three of the six optional add-ons are visible '
          'without expanding -- so the share of the catalogue the attach rate '
          'is actually measuring is a reportable number rather than an '
          'assumption',
      () {
        reach = HabotAddOnDisplayRules.defaultReach(catalogue());
        return reach == 0.5 &&
            reach < 1 &&
            HabotAddOnDisplayRules.capCreatesARankingNote
                .contains('elects three winners');
      },
    );

    gate(
      'GEN-01209-G6',
      'Metric: Add-On Attach Rate -- floor 0.1, optimal 0.25, CEILING 0.4.',
      'A rate above the ceiling is reported as Poor rather than as excellent: '
          'at that level optional add-ons are most likely being read as '
          'required steps, which converts well and returns as refunds',
      () {
        final double high = HabotAddOnDisplayRules.attachRate(
          bookingsWithAnOptionalAddOn: 55,
          bookings: 100,
        );
        final double good = HabotAddOnDisplayRules.attachRate(
          bookingsWithAnOptionalAddOn: 30,
          bookings: 100,
        );
        final double low = HabotAddOnDisplayRules.attachRate(
          bookingsWithAnOptionalAddOn: 5,
          bookings: 100,
        );
        return high == 0.55 &&
            HabotAddOnDisplayRules.isAboveCeiling(high) &&
            HabotAddOnDisplayRules.qualitativeOutput(high) == 'Poor' &&
            HabotAddOnDisplayRules.qualitativeOutput(good) == 'Good' &&
            HabotAddOnDisplayRules.qualitativeOutput(0.15) == 'Average' &&
            HabotAddOnDisplayRules.qualitativeOutput(low) == 'Poor' &&
            HabotAddOnDisplayRules.ceilingIsAWarningNote
                .contains('a bound, not a target');
      },
    );

    gate(
      'GEN-01209-G7',
      'The attach rate needs bookings and is not producible on this host.',
      'The cap, the ranking and the default reach are structural and are what '
          'is reported; the rate itself is left to real bookings rather than '
          'being invented, and the cap the row asks for is honoured exactly',
      () =>
          HabotAddOnDisplayRules.maximumDisplayed == 3 &&
          HabotAddOnDisplayRules.visible(catalogue()).length == 3 &&
          HabotAddOnDisplayRules.attachRate(
                bookingsWithAnOptionalAddOn: 0,
                bookings: 0,
              ) ==
              0 &&
          HabotAddOnDisplayRules.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01209',
        atomicStepReferenceId: 'GEN-01209',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Set structural rules limiting displayed add-on options to '
            'a maximum of 3 items per service."',
        implementationOrder: 203,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotAddOnDisplayRules / HabotAddOn',
          'Component Properties':
              'Cap of ${HabotAddOnDisplayRules.maximumDisplayed} optional '
              'add-ons; ranking total to the id (operator priority, then '
              'price, then id); service-required add-ons exempt from the cap '
              'and from both sides of the attach rate; remainder reachable '
              'behind a disclosure that names its count',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the row sets a cap and leaves out the decision the cap '
              'creates. Three shown out of seven does not reduce clutter, it '
              'elects three winners -- and the attach rate the row is graded '
              'on then measures the ORDERING rather than the catalogue. '
              'Whichever three the list happens to yield first take every '
              'attachment; the rest are indistinguishable in the data from '
              'add-ons nobody wanted. The ordering is declared, ranked and '
              'total to the id, and demonstrated stable under reversal where '
              'the source ordering is not. SECOND: hidden is not absent -- the '
              'remainder stays reachable behind a disclosure naming its count. '
              'THIRD: a service-required add-on is shown regardless of the cap '
              'and counted on neither side of the rate; hidden behind a '
              'disclosure it produces a booking whose price the parent did not '
              'see, and counted as an attachment it inflates the metric with '
              'items nobody chose. FOURTH: the ceiling of 0.4 is a bound, not '
              'a target -- above it, optional add-ons are most likely being '
              'read as required steps, and that is reported as Poor.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Add-On Attach Rate',
            observed:
                'NOT PRODUCIBLE -- the rate needs real bookings and none is '
                'invented. The grading function is built and exercised: 0.55 '
                'reports Poor because it is past the ceiling, 0.30 Good, 0.15 '
                'Average, 0.05 Poor.',
            floor: '0.1',
            optimal: '0.25',
            ceiling: '0.4',
          ),
          AissMeasurement(
            metricName: 'Default catalogue reach under the cap',
            observed:
                '${reach.toStringAsFixed(2)} -- three of six optional add-ons '
                'are visible without expanding. The share of the catalogue the '
                'attach rate is actually measuring, reported rather than '
                'assumed to be 1.0.',
            floor: 'n/a -- descriptive',
            optimal: 'n/a -- descriptive',
            ceiling: 'n/a -- descriptive',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/booking/addon_display_rules.dart',
        ],
      ),
    );
  });
}
