/// AISS GATE -- Step 276 of 295
/// Global Reference ID:       ARCPE-004-05
/// Atomic Steps Reference ID: ARCPE-004-05
/// Setup Step (Action): "Implement the overlay to trigger when performance
///                      drops below the safety limit." (DIFFERENT SUBJECT)
/// Atomic Step: "Program click and tap event handlers to toggle accordion
///               expansion states."
/// Metric: Touch Target Size & Accessibility Compliance -- Floor "44px / WCAG
///         AA", Optimal "48px / WCAG AA", Ceiling "56px / WCAG AAA".
///         Good / Average / Poor.
///
/// TWO HANDLERS THAT ARE ONE GESTURE, AND A BAND THAT NAMES THE WRONG WCAG
/// LEVEL AT BOTH ENDS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/disclosure/accordion_handlers.dart';

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

  group('ARCPE-004-05 :: one gesture, not two events', () {
    gate(
      'ARCPE-004-05-G1',
      'Atomic Step: "click and tap event handlers".',
      'Every pointer kind arrives on the same callback, recorded as a table '
          'rather than a sentence, so a framework needing a second one would '
          'have a second entry',
      () =>
          HabotAccordionHandlers.everyPointerKindUsesTheSameCallback &&
          HabotAccordionHandlers.handlersTheRowNames == 2 &&
          HabotAccordionHandlers.handlersNeededHere == 1 &&
          HabotPointerKind.values.length == 3,
    );

    gate(
      'ARCPE-004-05-G2',
      'Binding both would toggle twice per tap.',
      'One handler toggles and two leave the panel where it started, so the '
          'literal reading of the row produces a header that appears to do '
          'nothing -- exercised rather than warned about',
      () =>
          HabotAccordionHandlers.oneHandlerToggles &&
          HabotAccordionHandlers.twoHandlersDoNothing &&
          HabotAccordionHandlers.oneGestureNote
              .contains('appears to do nothing'),
    );

    gate(
      'ARCPE-004-05-G3',
      'Row design note: "standard HTML details/summary elements".',
      'The four things that element supplied for free are named, because a '
          'framework without it has to declare all four rather than inherit '
          'them',
      () =>
          HabotAccordionHandlers.everyObligationIsNamed &&
          HabotAccordionHandlers.obligationsDetailsWouldHaveCarried.length == 4,
    );

    gate(
      'ARCPE-004-05-G4',
      'The rule already exists; this is the eighth restatement.',
      'The Step 111 progressive-disclosure rule is exercised rather than '
          'restated, and the census is named as the answer',
      () =>
          HabotAccordionHandlers.theSemanticRuleIsAlreadyDeclared &&
          HabotAccordionHandlers.detailsElementNote.contains('census'),
    );
  });

  group('ARCPE-004-05 :: the target, and the citation', () {
    gate(
      'ARCPE-004-05-G5',
      'Metric: Touch Target Size & Accessibility Compliance.',
      'The whole header is the target and the chevron is not: the header\'s '
          'minimum height is the declared token and a 24-point glyph is below '
          'the declared floor',
      () =>
          HabotAccordionHandlers.theHeaderIsTheTargetRatherThanTheChevron &&
          HabotAccordionHandlers.theExistingBandAgrees &&
          HabotAccordionHandlers.chevronGlyphDp == 24,
    );

    gate(
      'ARCPE-004-05-G6',
      'Floor "44px / WCAG AA".',
      'SC 2.5.8 (AA) is 24x24 and SC 2.5.5 (AAA) is 44x44, so the row\'s '
          'floor is the AAA figure wearing an AA label -- the fourth '
          'mis-citation this track has found',
      () =>
          HabotAccordionHandlers.theFloorIsAaaLabelledAa &&
          HabotAccordionHandlers.wcagAaMinimumPx == 24 &&
          HabotAccordionHandlers.wcagAaaEnhancedPx == 44,
    );

    gate(
      'ARCPE-004-05-G7',
      'Ceiling "56px / WCAG AAA".',
      'Fifty-six appears nowhere in WCAG at either level; it is MD3\'s '
          'comfortable density, and the attribution is recorded rather than '
          'repeated',
      () =>
          HabotAccordionHandlers.theCeilingIsNotInTheSpecification &&
          HabotAccordionHandlers.citationNote
              .contains('appears nowhere in WCAG'),
    );

    gate(
      'ARCPE-004-05-G8',
      'The band is written in px and its citation in dp.',
      'The units differ and nothing in this repository is measured in px, so '
          'the figures are read as points and the discrepancy is recorded; '
          'all ten declared checks hold and the step reports Good',
      () =>
          HabotAccordionHandlers.unitsNote.contains('not the same unit') &&
          HabotAccordionHandlers.checks.length == 10 &&
          HabotAccordionHandlers.checks.values.every((bool b) => b) &&
          HabotAccordionHandlers.qualitativeOutput == 'Good' &&
          HabotAccordionHandlers.columnNote.contains('belongs to neither'),
    );
  });

  tearDownAll(() {
    final String header =
        HabotAccordionHandlers.headerMinHeightDp.toStringAsFixed(0);
    final String chevron =
        HabotAccordionHandlers.chevronGlyphDp.toStringAsFixed(0);
    final String obligations =
        '${HabotAccordionHandlers.obligationsDetailsWouldHaveCarried.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ARCPE-004-05',
        atomicStepReferenceId: 'ARCPE-004-05',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Implement '
            'the overlay to trigger when performance drops below the safety '
            'limit", a different subject. Atomic Step: "Program click and tap '
            'event handlers to toggle accordion expansion states."',
        implementationOrder: 276,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotAccordionHandlers / HabotPointerKind',
          'Component Properties':
              '${HabotPointerKind.values.length} pointer kinds resolving to '
              '${HabotAccordionHandlers.distinctCallbacks.length} callback; '
              '$obligations obligations the HTML element carried, named; '
              'header target ${header}dp against a ${chevron}dp glyph',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotAccordionHandlers.oneGestureNote} '
              'CITATION: ${HabotAccordionHandlers.citationNote} '
              'UNITS: ${HabotAccordionHandlers.unitsNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Touch Target Size & Accessibility Compliance',
            observed:
                'The header is ${header}dp on its minor axis, at the declared '
                'optimal, and the whole row is the hit area. The band\'s own '
                'levels are wrong at both ends: 44 is the AAA figure labelled '
                'AA, and 56 is not a WCAG figure at all.',
            floor: '44px / WCAG AA',
            optimal: '48px / WCAG AA',
            ceiling: '56px / WCAG AAA',
          ),
          AissMeasurement(
            metricName: 'Handlers required for the row\'s two events',
            observed:
                '${HabotAccordionHandlers.handlersNeededHere} of '
                '${HabotAccordionHandlers.handlersTheRowNames}. Binding both '
                'toggles twice per tap and leaves the panel unchanged.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/disclosure/accordion_handlers.dart',
        ],
      ),
    );
  });
}
