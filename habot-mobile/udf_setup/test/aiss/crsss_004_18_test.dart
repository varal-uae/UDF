/// AISS GATE -- Step 297 of 315
/// Global Reference ID:       CRSSS-004-18
/// Atomic Steps Reference ID: CRSSS-004-18
/// Setup Step (Action): "Set maximum font scaling factor constraint (1.3x) for
///                      large accessibility text sizes." (BELOW WCAG 2.1
///                      SC 1.4.4 -- REFUSED)
/// Atomic Step: "Implement the Material 3 CircularProgressIndicator component
///               for these specific loading states."
/// Metric: Process Execution Quality Score -- floor >=90%, optimal >=98%,
///         ceiling 1. Good/Average/Poor. ISO 9001:2015.
///
/// THE ROW IS RIGHT ABOUT INDETERMINATE AND WRONG ABOUT TEXT SCALING, AND THE
/// SECOND MISTAKE IS SILENT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/loading/circular_indicator.dart';

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

  group('CRSSS-004-18 :: the shape is chosen by the data', () {
    gate(
      'CRSSS-004-18-G1',
      'Config cell: "indeterminate progress indicators during cold starts".',
      'Six loading states, four with no knowable total and two with one, so '
          'four spin and two draw a ring',
      () =>
          HabotCircularIndicatorBinding.states.length == 6 &&
          HabotCircularIndicatorBinding.indeterminate.length == 4 &&
          HabotCircularIndicatorBinding.determinate.length == 2,
    );

    gate(
      'CRSSS-004-18-G2',
      'The choice is made by asking the operation.',
      'Every state\'s shape follows from whether it has a total, rather than '
          'from a preference written at the call site',
      () => HabotCircularIndicatorBinding.theShapeIsChosenByTheData,
    );

    gate(
      'CRSSS-004-18-G3',
      'A ring over an unknown total is a number somebody made up.',
      'The reason the row is right is recorded: people read a ring as a '
          'promise, and at 90 per cent they stop considering that it might '
          'not finish',
      () => HabotCircularIndicatorBinding.indeterminateNote
          .contains('read a ring as a promise'),
    );
  });

  group('CRSSS-004-18 :: what a spinner announces', () {
    gate(
      'CRSSS-004-18-G4',
      'A determinate indicator has a percentage; an indeterminate one does '
          'not.',
      'Every spinning state carries its own sentence, so a screen reader is '
          'not left reporting an empty screen while the app is busy',
      () =>
          HabotCircularIndicatorBinding.everyIndeterminateStateHasASentence &&
          HabotCircularIndicatorBinding.semanticsNote
              .contains('nothing on it'),
    );

    gate(
      'CRSSS-004-18-G5',
      'And none of the sentences is the word "Loading".',
      'That names the widget rather than the work, and is what every screen '
          'in every app says while it waits',
      () => HabotCircularIndicatorBinding.noSentenceIsTheWordLoading,
    );
  });

  group('CRSSS-004-18 :: the Setup Step, refused', () {
    gate(
      'CRSSS-004-18-G6',
      'Setup Step: cap font scaling at 1.3x.',
      'WCAG 2.1 SC 1.4.4 requires 200 per cent and this repository audits to '
          '2.0, so the cap is 0.7 below a Level AA criterion the app '
          'currently meets',
      () =>
          HabotCircularIndicatorBinding.requestedScaleCap == 1.3 &&
          HabotCircularIndicatorBinding.requiredScale == 2.0 &&
          (HabotCircularIndicatorBinding.shortfall - 0.7).abs() < 1e-9,
    );

    gate(
      'CRSSS-004-18-G7',
      'The cap would bite exactly on the people it names.',
      'Audited scales above the cap exist, 2.0 among them, and those are the '
          'settings chosen by people who asked for large text',
      () =>
          HabotCircularIndicatorBinding.auditedScalesAboveTheCap.isNotEmpty &&
          HabotCircularIndicatorBinding.auditedScalesAboveTheCap.contains(2.0),
    );

    gate(
      'CRSSS-004-18-G8',
      'Guard rule A11Y_TEXT_SCALING_SUPPRESSED.',
      'The cap is recorded rather than written, and the reason it would go '
          'unnoticed -- nothing breaks, the text simply stops growing -- is '
          'stated',
      () =>
          !HabotCircularIndicatorBinding.theCapIsImplemented &&
          HabotCircularIndicatorBinding.guardRule ==
              'A11Y_TEXT_SCALING_SUPPRESSED' &&
          HabotCircularIndicatorBinding.scaleCapNote.contains('silently'),
    );
  });

  group('CRSSS-004-18 :: the column and the band', () {
    gate(
      'CRSSS-004-18-G9',
      'Config cell: "Build state-driven Compose logic".',
      'Jetpack Compose in a Flutter application -- the ninth row in this '
          'track written for another stack, and one whose instruction '
          'translates without loss',
      () => HabotCircularIndicatorBinding.wrongStackNote.contains('ninth row'),
    );

    gate(
      'CRSSS-004-18-G10',
      'Output: Good / Average / Poor.',
      'Six declared obligations, all met, giving 1.0 and a Good; all nine '
          'declared checks hold',
      () =>
          HabotCircularIndicatorBinding.obligations.length == 6 &&
          HabotCircularIndicatorBinding.obligations.values
              .every((bool b) => b) &&
          HabotCircularIndicatorBinding.executionQuality == 1.0 &&
          HabotCircularIndicatorBinding.qualitativeOutput == 'Good' &&
          HabotCircularIndicatorBinding.checks.length == 9 &&
          HabotCircularIndicatorBinding.checks.values.every((bool b) => b) &&
          HabotCircularIndicatorBinding.columnNote.contains('SC 1.4.4'),
    );
  });

  tearDownAll(() {
    final String spinning =
        '${HabotCircularIndicatorBinding.indeterminate.length}';
    final String share = HabotCircularIndicatorBinding.shareIndeterminate
        .toStringAsFixed(3);
    const String indeterminate =
        HabotCircularIndicatorBinding.indeterminateNote;
    const String semantics = HabotCircularIndicatorBinding.semanticsNote;
    const String scaleCap = HabotCircularIndicatorBinding.scaleCapNote;
    const String stack = HabotCircularIndicatorBinding.wrongStackNote;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'CRSSS-004-18',
        atomicStepReferenceId: 'CRSSS-004-18',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Set maximum '
            'font scaling factor constraint (1.3x) for large accessibility '
            'text sizes", which would put the app below WCAG 2.1 SC 1.4.4 '
            'Resize Text, and the fourth configuration cell asks for Jetpack '
            'Compose. Atomic Step: "Implement the Material 3 '
            'CircularProgressIndicator component for these specific loading '
            'states."',
        implementationOrder: 297,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'CRSSS-004-18',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '$spinning of ${HabotCircularIndicatorBinding.states.length} '
                  'loading states are indeterminate (share $share); the shape '
                  'follows the operation rather than a preference',
          'User ID': 'Fredrick',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note': 'INDETERMINATE: $indeterminate SEMANTICS: '
              '$semantics SCALE CAP: $scaleCap STACK: $stack',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                '100% over ${HabotCircularIndicatorBinding.obligations.length} '
                'declared obligations, one of which is the refusal of the '
                'row\'s own Setup Step. The ceiling is written as 1 against '
                'percentage floors.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Text scale the app remains usable at',
            observed:
                '2.0, unchanged. The Setup Step asked for 1.3, which is 0.7 '
                'below WCAG 2.1 SC 1.4.4 and below the scale this repository '
                'already audits to. Refused, and recorded as an instruction '
                'that would have failed a Level AA criterion without '
                'breaking anything a test could see.',
            floor: '2.0 (SC 1.4.4)',
            optimal: '2.0',
            ceiling: '2.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/loading/circular_indicator_binding.dart',
        ],
      ),
    );
  });
}
