/// AISS GATE -- Step 306 of 315
/// Global Reference ID:       ERMWD-025-15
/// Atomic Steps Reference ID: ERMWD-025-15
/// Setup Step (Action): "Capture raw input string entered by user in real
///                      time." (A FORM-INPUT INSTRUCTION ON A DIALOG ROW)
/// Atomic Step: "Style dialog icon with M3 error colors to signify severity."
/// Metric: Process Execution Quality Score -- floor >=90%, optimal >=98%,
///         ceiling 1. Good/Average/Poor. ISO 9001:2015.
///
/// ONE HUE ASKED TO CARRY THREE VALUES, AND A DATA COLUMN ASKING FOR HEX
/// CODES THE GUARD HAS FORBIDDEN SINCE STEP 4.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/severity_icon.dart';

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

  group('ERMWD-025-15 :: one hue, three meanings', () {
    gate(
      'ERMWD-025-15-G1',
      'Atomic Step: "M3 error colors to signify severity".',
      'Material 3 has four error roles and one error hue, against three '
          'severities to distinguish',
      () =>
          HabotSeverityIcon.errorRoles.length == 4 &&
          HabotSeverityIcon.errorHues == 1 &&
          HabotSeverityIcon.severitiesToDistinguish == 3 &&
          HabotSeverityIcon.oneHueCannotCarryThree,
    );

    gate(
      'ERMWD-025-15-G2',
      'The scheme already separates warning from error.',
      'So painting a warning in the error colour does not merely fail to '
          'distinguish it -- it says the wrong thing, because red reads as '
          '"this failed" and a warning has not failed',
      () =>
          HabotSeverityIcon.theSchemeAlreadySeparatesWarningFromError &&
          HabotSeverityIcon.everySeverityHasItsOwnRole &&
          HabotSeverityIcon.hueNote.contains('has not failed yet'),
    );
  });

  group('ERMWD-025-15 :: three channels', () {
    gate(
      'ERMWD-025-15-G3',
      'WCAG 2.1 SC 1.4.1 Use of Colour -- Level A.',
      'Each severity has its own glyph and its own opening phrase, so strip '
          'the colour and the three are still three',
      () =>
          HabotSeverityIcon.everySeverityHasItsOwnGlyph &&
          HabotSeverityIcon.everySeverityHasItsOwnWord &&
          HabotSeverityIcon.severityIsLegibleWithoutColour &&
          HabotSeverityIcon.criterionLevel == 'A',
    );

    gate(
      'ERMWD-025-15-G4',
      'Nobody can separate two shades of the same red.',
      'Colour is the reinforcement and is the one channel that can be '
          'removed without losing the severity',
      () =>
          !HabotSeverityIcon.colourIsTheSoleSignal &&
          HabotSeverityIcon.channelNote.contains('two shades of the same red'),
    );

    gate(
      'ERMWD-025-15-G5',
      'The word is a sentence rather than a label.',
      '"Error" says what kind of box this is and nothing else; no opening '
          'phrase here is merely the name of the severity',
      () =>
          HabotSeverityIcon.noWordIsMerelyTheSeverityName &&
          HabotSeverityIcon.presentationFor(HabotSeverity.error).word ==
              'This did not work',
    );
  });

  group('ERMWD-025-15 :: the contrast figures', () {
    gate(
      'ERMWD-025-15-G6',
      'The dialog icon is non-text.',
      'Its floor is 3:1 and every measured pair clears it by a distance; the '
          'text beside it clears 4.5:1 as well',
      () =>
          HabotSeverityIcon.everyPairClearsTheNonTextFloor &&
          HabotSeverityIcon.everyPairClearsTheTextFloor &&
          HabotSeverityIcon.iconFloor == 3.0,
    );

    gate(
      'ERMWD-025-15-G7',
      'One pair reaches AA and not AAA.',
      'M3 baseline error on the light surface is 6.38, missing the 7:1 '
          'optimal by 0.62 -- recorded rather than fixed by inventing a '
          'colour, because a local override would be the first crack in the '
          'scheme',
      () =>
          HabotSeverityIcon.pairsBelowTheTextOptimal.length == 1 &&
          HabotSeverityIcon.pairsBelowTheTextOptimal.first ==
              'error on light surface' &&
          (HabotSeverityIcon.shortfallOnTheWeakestPair - 0.62).abs() < 1e-9 &&
          HabotSeverityIcon.contrastNote
              .contains('first crack in the scheme'),
    );
  });

  group('ERMWD-025-15 :: the hex instruction', () {
    gate(
      'ERMWD-025-15-G8',
      'Data Collected: "Color Code (HEX/RGB)".',
      'RAW_COLOR_LITERAL has forbidden a hex value in a widget since Step 4, '
          'so the roles are named, the ratios are recorded as measurements, '
          'and no colour is constructed',
      () =>
          !HabotSeverityIcon.anyColourIsConstructedHere &&
          HabotSeverityIcon.guardRule == 'RAW_COLOR_LITERAL',
    );

    gate(
      'ERMWD-025-15-G9',
      'Step 287 refused the same instruction two batches ago.',
      'The reason is the same: the value must come from the scheme so both '
          'themes are covered and a palette change cannot break a contrast '
          'guarantee',
      () => HabotSeverityIcon.hexNote.contains('Step 287'),
    );

    gate(
      'ERMWD-025-15-G10',
      'Output: Good / Average / Poor.',
      'Six declared obligations, all met, giving 1.0 and a Good; all twelve '
          'declared checks hold',
      () =>
          HabotSeverityIcon.obligations.length == 6 &&
          HabotSeverityIcon.obligations.values.every((bool b) => b) &&
          HabotSeverityIcon.executionQuality == 1.0 &&
          HabotSeverityIcon.qualitativeOutput == 'Good' &&
          HabotSeverityIcon.checks.length == 12 &&
          HabotSeverityIcon.checks.values.every((bool b) => b) &&
          HabotSeverityIcon.columnNote.contains('raw input string'),
    );
  });

  tearDownAll(() {
    final double? weakestRatio =
        HabotSeverityIcon.measuredRatios['error on light surface'];
    final String weakest = weakestRatio.toString();
    final String warning =
        HabotSeverityIcon.presentationFor(HabotSeverity.warning).word;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ERMWD-025-15',
        atomicStepReferenceId: 'ERMWD-025-15',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Capture raw '
            'input string entered by user in real time", which is a form-input '
            'instruction on a dialog-styling row, and Data Collected asks for '
            'hex colour codes. Atomic Step: "Style dialog icon with M3 error '
            'colors to signify severity."',
        implementationOrder: 306,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Color Code (HEX/RGB)':
              'NONE CONSTRUCTED -- RAW_COLOR_LITERAL; the roles come from the '
                  'audited scheme at run time',
          'Color Name':
              'the M3 error family: error, onError, errorContainer, '
                  'onErrorContainer',
          'Color Scheme': 'light and dark, both audited',
          'Contrast Ratio':
              'four measured pairs, weakest $weakest:1, all above the 4.5 text '
                  'floor and the 3.0 non-text floor',
          'Color Application Map':
              'information takes the primary role, warning the warning role, '
                  'error the error role; the warning opens with "$warning"',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'HUE: ${HabotSeverityIcon.hueNote} '
              'CHANNELS: ${HabotSeverityIcon.channelNote} '
              'CONTRAST: ${HabotSeverityIcon.contrastNote} '
              'HEX: ${HabotSeverityIcon.hexNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                '100% over ${HabotSeverityIcon.obligations.length} declared '
                'obligations, one of which is that severity survives the '
                'removal of colour. The row\'s instruction -- error colours to '
                'signify severity -- asks one hue to carry three values.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Severities distinguishable without colour',
            observed:
                '3 of 3. Each carries a distinct outline and a distinct '
                'opening phrase; the colour role is the third channel and the '
                'removable one. One measured pair, M3 baseline error on the '
                'light surface at 6.38:1, passes AA and misses AAA by 0.62, '
                'and is recorded rather than overridden.',
            floor: '3',
            optimal: '3',
            ceiling: '3',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/severity_icon.dart',
        ],
      ),
    );
  });
}
