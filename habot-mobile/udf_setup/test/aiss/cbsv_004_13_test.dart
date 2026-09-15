/// AISS GATE -- Step 287 of 295
/// Global Reference ID:       CBSV-004-13
/// Atomic Steps Reference ID: CBSV-004-13
/// Setup Step (Action): "Set the default state of the child expansion
///                      sub-panel to remain hidden from the layout view
///                      track." (BELONGS TO THE DISCLOSURE ROWS)
/// Atomic Step: "Render clean drop-down pickers for predefined emirates to
///               completely prevent manual handwriting inputs."
/// Metric: Process Execution Quality Score -- Floor ">=90%", Optimal ">=98%",
///         Ceiling 1. Good / Average / Poor. ISO 9001:2015.
///
/// THE ROW'S PALETTE INSTRUCTION WOULD FAIL THE POKA-YOKE GUARD, AND ITS
/// "DROP-DOWN" IS NOT ONE ON A PHONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/emirate_picker.dart';

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

  group('CBSV-004-13 :: the set decides the affordance', () {
    gate(
      'CBSV-004-13-G1',
      'Atomic Step: "predefined emirates".',
      'Seven, closed, no duplicates, and small enough to scan -- which is '
          'what makes a picker right here rather than a preference',
      () =>
          HabotEmiratePicker.emirates.length == 7 &&
          HabotEmiratePicker.theSetIsClosedAndSmall,
    );

    gate(
      'CBSV-004-13-G2',
      '"Completely prevent manual input" is right here and wrong as a rule.',
      'The rule is about the set: closed and small takes a picker, closed and '
          'large takes filtering, open takes text, and all three cases are '
          'exercised',
      () =>
          HabotEmiratePicker.emiratesGetAPlainPicker &&
          HabotEmiratePicker.countriesGetFiltering &&
          HabotEmiratePicker.anAddressLineStaysText &&
          HabotEmiratePicker.everySetKindHasAnAffordance,
    );

    gate(
      'CBSV-004-13-G3',
      'Stating which case it is stops the next person applying the third.',
      'The rule is recorded with the reasoning, not only the outcome',
      () => HabotEmiratePicker.theRuleIsAboutTheSetNote
          .contains('applying it to the third'),
    );
  });

  group('CBSV-004-13 :: the surface, the default and the palette', () {
    gate(
      'CBSV-004-13-G4',
      'Atomic Step: "drop-down pickers".',
      'A drop-down is a web control and this application has no select; Step '
          '225\'s rule gives a modal sheet on a phone and an anchored popover '
          'on a wide window',
      () =>
          HabotEmiratePicker.aPhoneGetsASheetRatherThanADropDown &&
          HabotEmiratePicker.dropDownIsAWebWordNote
              .contains('has no select at all'),
    );

    gate(
      'CBSV-004-13-G5',
      'Dismissing without choosing is a valid outcome.',
      'The sheet may be swiped away, which is what distinguishes a choice '
          'from a decision in the existing taxonomy',
      () => HabotEmiratePicker.dismissingWithoutChoosingIsAllowed,
    );

    gate(
      'CBSV-004-13-G6',
      'A picker that opens on the first entry is submitted unread.',
      'Nothing is pre-selected, the unanswered state is its own value, and a '
          'value off the list is refused however it arrived',
      () =>
          HabotEmiratePicker.nothingIsPreSelected &&
          HabotEmiratePicker.anUnansweredPickerIsDistinguishable &&
          HabotEmiratePicker.aValueOffTheListIsRefused &&
          HabotEmiratePicker.noDefaultNote.contains('can be asked about'),
    );

    gate(
      'CBSV-004-13-G7',
      'Row design note: "#FFFFFF or #F4F7F9".',
      'Two raw colour literals, which the guard has refused since Step 97, '
          'and both light -- so the instruction is also a dark-mode defect. '
          'Refused with its reason rather than written and linted out later',
      () =>
          HabotEmiratePicker.theRowsPaletteWouldFailTheGuard &&
          HabotEmiratePicker.guardRuleThatWouldRefuseThem ==
              'RAW_COLOR_LITERAL' &&
          HabotEmiratePicker.paletteRefusalNote.contains('linted out'),
    );

    gate(
      'CBSV-004-13-G8',
      'Row design note: "broad gutter gaps of 16px".',
      'Sixteen is already on the spacing scale, so the figure agrees with a '
          'token -- and the token is still what is used, because a literal '
          'that is right today stops being right when the scale changes',
      () =>
          HabotEmiratePicker.theRowsFigureMatchesADeclaredToken &&
          HabotEmiratePicker.gutterNote.contains('stops being right'),
    );

    gate(
      'CBSV-004-13-G9',
      'Metric: Process Execution Quality Score -- 90% / 98% / 1.',
      'Eight declared obligations, all met, giving Good; all eleven declared '
          'checks hold',
      () =>
          HabotEmiratePicker.obligations.length == 8 &&
          HabotEmiratePicker.obligations.values.every((bool b) => b) &&
          HabotEmiratePicker.qualityScore == 1.0 &&
          HabotEmiratePicker.qualitativeOutput == 'Good' &&
          HabotEmiratePicker.checks.length == 11 &&
          HabotEmiratePicker.checks.values.every((bool b) => b) &&
          HabotEmiratePicker.columnNote.contains('sub-panel'),
    );
  });

  tearDownAll(() {
    final String options = '${HabotEmiratePicker.emirates.length}';
    final String threshold = '${HabotEmiratePicker.filterThreshold}';
    final String gutter = HabotEmiratePicker.gutterUsed.toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'CBSV-004-13',
        atomicStepReferenceId: 'CBSV-004-13',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Set the '
            'default state of the child expansion sub-panel to remain hidden '
            'from the layout view track", which belongs to the disclosure '
            'rows earlier in this batch. Atomic Step: "Render clean drop-down '
            'pickers for predefined emirates to completely prevent manual '
            'handwriting inputs."',
        implementationOrder: 287,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Definition Name': 'emirate',
          'Definition Parameters':
              '$options closed options, no default selection, filter '
                  'threshold $threshold, ${gutter}dp gutter from the declared '
                  'scale',
          'Definition Type': 'single choice from a closed small set',
          'Validation Status':
              'a value off the list is refused; unanswered is a distinct '
                  'value rather than the first option',
          'Component Properties':
              'surface chosen by the Step 225 rule -- modal sheet on a phone, '
                  'anchored popover when wide; the row\'s two hex literals '
                  'refused',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotEmiratePicker.paletteRefusalNote} '
              'RULE: ${HabotEmiratePicker.theRuleIsAboutTheSetNote} '
              'SURFACE: ${HabotEmiratePicker.dropDownIsAWebWordNote} '
              'DEFAULT: ${HabotEmiratePicker.noDefaultNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                '100% over ${HabotEmiratePicker.obligations.length} declared '
                'obligations: the set, the affordance rule across all three '
                'kinds of answer set, the surface from the existing rule, no '
                'default, refusal of off-list values, and the gutter token.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Raw colour literals introduced',
            observed:
                '0. The row asks for two; both are recorded as strings in the '
                'refusal note and neither is written as a colour, so the '
                'guard rule that has stood since Step 97 is not broken to '
                'satisfy a design column.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/emirate_picker.dart',
        ],
      ),
    );
  });
}
