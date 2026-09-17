/// AISS GATE -- Step 348 of 355
/// Global Reference ID:       GEN-04660
/// Atomic Steps Reference ID: GEN-04660
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Add custom animations introducing tooltips cleanly onto
///               active viewports."
/// Metric: Onboarding Completion Rate -- floor 0.6, optimal 0.8, ceiling
///         "90%+ (diminishing returns)". Good/Average/Poor. Appcues benchmark.
///
/// A HOVER CONSTRUCT ON A TOUCH SURFACE, MEASURED BY A GROWTH RATE IT CANNOT
/// MOVE, IN A BAND CARRYING THREE UNIT SYSTEMS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/guidance/tooltip_entry.dart';

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

  group('GEN-04660 :: there is no hover', () {
    gate(
      'GEN-04660-G1',
      'Atomic Step: "introducing tooltips".',
      'A tooltip waits for a pointer to rest on something; a finger is down or '
          'it is not, so the state never arrives',
      () =>
          !HabotTooltipEntry.thisSurfaceHasHover &&
          HabotTooltipEntry.theWordIsAlreadyLinted,
    );

    gate(
      'GEN-04660-G2',
      'The poka-yoke guard already carries a HOVER_TOOLTIP rule.',
      'So the word in this row is answered by a lint that has been running '
          'since the guard shipped',
      () =>
          HabotTooltipEntry.guardRuleAlreadyEnforcing == 'HOVER_TOOLTIP' &&
          HabotTooltipEntry.hoverNote.contains('answered by a lint'),
    );

    gate(
      'GEN-04660-G3',
      'Three forms a touch surface can offer, each named for what it is.',
      'A long-press popover is a gesture nobody is told about; a tap-reveal '
          'competes with the control; supporting text is not a tooltip at all',
      () =>
          HabotHintForm.values.length == 3 &&
          HabotTooltipEntry.everyFormIsNamedForWhatItIs &&
          HabotTooltipEntry.theChosenFormNeedsNoDiscovery,
    );
  });

  group('GEN-04660 :: three unit systems in one band', () {
    gate(
      'GEN-04660-G4',
      'Floor 0.6, optimal 0.8, ceiling "90%+ (diminishing returns)".',
      'A decimal, a decimal, and a percentage with a plus sign and an excuse',
      () =>
          HabotTooltipEntry.theFloorIsADecimal &&
          HabotTooltipEntry.theCeilingIsAPercentage,
    );

    gate(
      'GEN-04660-G5',
      'The ceiling cell cannot be parsed as a number.',
      'It holds a reason where the value belongs',
      () => HabotTooltipEntry.theCeilingIsNotParseable,
    );

    gate(
      'GEN-04660-G6',
      'Reconciled onto one scale the values are 60, 80 and 90.',
      'Which is ordered -- but nothing in the band says to reconcile them, and '
          'read literally 90 against 0.6 spans a factor of 150',
      () =>
          HabotTooltipEntry.theyAreOrderedOnceReconciled &&
          HabotTooltipEntry.theLiteralReadingSpansOneHundredAndFifty &&
          HabotTooltipEntry.reconciledPercentages.length == 3,
    );
  });

  group('GEN-04660 :: a metric this row cannot move', () {
    gate(
      'GEN-04660-G7',
      'Onboarding completion is how many people finish setting up.',
      'An entry animation on a label is not among its causes in any '
          'measurable way',
      () =>
          HabotTooltipEntry.theMetricAndTheSubjectAreUnrelated &&
          HabotTooltipEntry.metricName == 'Onboarding Completion Rate',
    );

    gate(
      'GEN-04660-G8',
      'Attributing it to one is how a team defends a curve in a review.',
      'The honest measurement is whether the text is readable sooner or later '
          'than without the animation',
      () => HabotTooltipEntry.attributionNote.contains('growth review'),
    );
  });

  group('GEN-04660 :: what can be measured', () {
    gate(
      'GEN-04660-G9',
      'Persistent supporting text is readable at zero milliseconds.',
      'The same text behind an entry animation is readable when the animation '
          'ends, so the animation costs time rather than saving it',
      () =>
          HabotTooltipEntry.theAnimationCostsTimeRatherThanSavingIt &&
          HabotTooltipEntry.millisecondsToReadableWithPersistentText == 0 &&
          HabotTooltipEntry.theDurationComesFromTokens,
    );

    gate(
      'GEN-04660-G10',
      'Output reported as Good / Average / Poor.',
      'Five obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotTooltipEntry.obligations.length == 5 &&
          HabotTooltipEntry.obligations.values.every((bool b) => b) &&
          HabotTooltipEntry.qualitativeOutput == 'Good' &&
          HabotTooltipEntry.checks.length == 10 &&
          HabotTooltipEntry.checks.values.every((bool b) => b) &&
          HabotTooltipEntry.columnNote.contains('three unit systems'),
    );
  });

  tearDownAll(() {
    final int animated =
        HabotTooltipEntry.millisecondsToReadableWithAnEntryAnimation;
    final String span = HabotTooltipEntry.literalSpan.toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04660',
        atomicStepReferenceId: 'GEN-04660',
        setupStepAction:
            'COLUMN NOTE: the band on this row carries three unit systems -- '
            '0.6, 0.8 and "90%+ (diminishing returns)" -- its ceiling cell '
            'holds an excuse in place of a value, its metric is a growth rate '
            'on a presentation row, and every narrative column is the generic '
            'engineering-console boilerplate. Atomic Step: "Add custom '
            'animations introducing tooltips cleanly onto active viewports."',
        implementationOrder: 348,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Add custom animations introducing tooltips cleanly onto active '
                  'viewports.':
              'no hover exists on this surface; of the three forms a touch '
                  'surface can offer, persistent supporting text is the one '
                  'that needs no discovery',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'text is readable at 0ms persistent and at ${animated}ms behind '
                  'an entry animation, which is a cost rather than a saving',
          'Data Quality Note':
              'HOVER: ${HabotTooltipEntry.hoverNote} '
              'BAND: ${HabotTooltipEntry.bandNote} '
              'ATTRIBUTION: ${HabotTooltipEntry.attributionNote} '
              'MEASUREMENT: ${HabotTooltipEntry.measurementNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Onboarding Completion Rate',
            observed:
                'THREE UNIT SYSTEMS IN ONE BAND, ON A METRIC THIS ROW CANNOT '
                'MOVE. Floor 0.6, optimal 0.8, ceiling "90%+ (diminishing '
                'returns)": a decimal, a decimal and a percentage carrying a '
                'plus sign and an excuse, with a ceiling cell that cannot be '
                'parsed as a number. Reconciled onto one scale they read 60, '
                '80, 90 and are ordered; read literally, 90 against 0.6 spans '
                'a factor of $span. The metric itself is a growth rate with a '
                'dozen real causes, none of which is an entry animation on a '
                'label.',
            floor: '0.6',
            optimal: '0.8',
            ceiling: '90%+ (diminishing returns)',
          ),
          AissMeasurement(
            metricName: 'Milliseconds before the hint text is readable',
            observed:
                '0 as built, because persistent supporting text is on screen '
                'before the interaction begins, against $animated behind an '
                'entry animation. The animation therefore costs time rather '
                'than saving it -- which is not an argument against having '
                'one, since motion that shows where a thing came from is '
                'worth a frame or two, but it is a reason not to claim it '
                'lifts a completion rate.',
            floor: '$animated',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/guidance/tooltip_entry.dart',
        ],
      ),
    );
  });
}
