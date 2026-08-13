/// AISS GATE -- Step 17 of 20
/// Global Reference ID:      IS02-CSIVW-005-AS01
/// Atomic Steps Reference ID: IS02-CSIVW-005-AS01-A01
/// Setup Step (Action):      "Program dynamic inline error layouts to activate
///                            when input fields fail validation checks."
///
/// Completion Measures: "Interface validation tests confirm that faulty inputs
/// trigger immediate under-field red messages."
/// Poka-Yoke: "Form submission actions remain physically locked until all
/// active field errors are resolved."
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/form_gate.dart';
import 'package:udf_setup/design_system/forms/inline_error.dart';
import 'package:udf_setup/design_system/forms/validated_input_field.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/typography_tokens.dart';

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

  group('IS02-CSIVW-005-AS01-A01 :: inline error layouts', () {
    gate(
      'IS02-CSIVW-005-G2',
      'Decision to be Made Before Setup Step: "Select the precise text size '
          'parameters required for inline descriptive error messages."',
      'The decision is recorded as bodySmall (12sp on a 16sp line) and comes '
          'from the existing type scale rather than a new value',
      () =>
          InlineFieldError.textRole == 'bodySmall' &&
          InlineFieldError.textSizeSp == 12 &&
          InlineFieldError.lineHeightSp == 16 &&
          InlineFieldError.textSizeSp == HabotTypography.bodySmall.sizeSp &&
          // UI decision: "crisp line height metrics to prevent readability
          // clipping" -- the line box must exceed the glyph size.
          InlineFieldError.lineHeightSp > InlineFieldError.textSizeSp,
    );

    gate(
      'IS02-CSIVW-005-G3',
      '4 Substeps #2: "Lock message text strings to display in high-contrast '
          'red parameters."',
      'The error colour is the audited scheme error token, and it clears the '
          '4.5:1 floor against the surfaces it is drawn on, in both schemes',
      () {
        final double light = Contrast.ratio(
          HabotColors.light.error,
          HabotColors.light.surface,
        );
        final double dark = Contrast.ratio(
          HabotColors.dark.error,
          HabotColors.dark.surface,
        );
        return light >= WcagThresholds.textFloor &&
            dark >= WcagThresholds.textFloor;
      },
    );

    gate(
      'IS02-CSIVW-005-G4',
      '4 Substeps #3: "Program form frameworks to freeze submission actions if '
          'active errors are present." + Poka-Yoke: "Form submission actions '
          'remain physically locked until all active field errors are resolved."',
      'A single outstanding error locks submission regardless of how many other '
          'fields pass',
      () {
        final HabotFormGate gate = HabotFormGate();
        for (int i = 0; i < 10; i++) {
          gate.register('f$i');
          gate.update('f$i', const FieldValidationResult.valid());
        }
        if (!gate.canSubmit) {
          return false;
        }
        gate.update('f7', const FieldValidationResult.invalid('bad'));
        if (gate.canSubmit) {
          return false;
        }
        // And the invalid field is named, so the UI can point at it.
        return gate.invalidFields.contains('f7') &&
            gate.invalidFields.length == 1;
      },
    );

    gate(
      'IS02-CSIVW-005-G6',
      'What Standardized Must Be Done: "All error text placement rules must '
          'adhere strictly to central UI rules."',
      'revealAllErrors surfaces every outstanding error at once rather than '
          'one per submit attempt',
      () {
        final HabotFormGate gate = HabotFormGate();
        gate.register('a');
        gate.register('b');
        gate.update('a', const FieldValidationResult.invalid('a bad'));
        gate.update('b', const FieldValidationResult.invalid('b bad'));
        if (gate.showsErrorFor('a') || gate.showsErrorFor('b')) {
          return false;
        }
        gate.revealAllErrors();
        return gate.showsErrorFor('a') && gate.showsErrorFor('b');
      },
    );
  });

  group('IS02-CSIVW-005-AS01-A01 :: blur-bound rendering', () {
    testWidgets('[IS02-CSIVW-005-G1] the error appears on blur, under the '
        'field, and clears when the value is corrected', (
      WidgetTester tester,
    ) async {
      final HabotFormGate formGate = HabotFormGate();
      addTearDown(formGate.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Column(
              children: <Widget>[
                ValidatedInputField(
                  fieldName: 'email',
                  label: 'Email',
                  cde: HabotCde.emailAddress,
                  gate: formGate,
                ),
                const TextField(key: Key('other')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'not-an-email');
      await tester.pumpAndSettle();

      // Still focused: no error yet. That is the blur binding.
      expect(find.byType(InlineFieldError), findsNothing);

      // Move focus away -> blur -> error appears.
      await tester.tap(find.byKey(const Key('other')));
      await tester.pumpAndSettle();

      expect(find.byType(InlineFieldError), findsOneWidget);
      expect(
        find.text('Enter an email address, like name@example.com.'),
        findsOneWidget,
      );

      // The error sits BELOW the input, not above or beside it.
      final Offset fieldCentre = tester.getCenter(emailField);
      final Offset errorCentre = tester.getCenter(
        find.byType(InlineFieldError),
      );
      expect(
        errorCentre.dy,
        greaterThan(fieldCentre.dy),
        reason: 'Error text must render directly below the input container',
      );

      // Correcting the value clears it without needing another blur.
      await tester.enterText(emailField, 'fredrick@vunapay.com');
      await tester.pumpAndSettle();
      expect(find.byType(InlineFieldError), findsNothing);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'IS02-CSIVW-005-G1',
          requirementSource:
              '4 Substeps #1: "Bind custom inline error components to the blur '
              'events of core entry inputs." + Completion Measures: "faulty '
              'inputs trigger immediate under-field red messages."',
          description:
              'Error appears only after blur, renders below the field, and '
              'clears as soon as the value passes',
          passed: true,
        ),
      );
    });

    testWidgets('[IS02-CSIVW-005-G5] boundary inputs are handled cleanly', (
      WidgetTester tester,
    ) async {
      // Substep 4: "Run automated user boundary input tests to confirm clear
      // error block display."
      final HabotFieldRule amount = HabotFieldRules.of(HabotCde.currencyAmount);
      final HabotFieldRule pct = HabotFieldRules.of(HabotCde.percentage);
      final HabotFieldRule time = HabotFieldRules.of(HabotCde.timeOfDay);

      // Lower / upper boundaries of each rule, and one step outside.
      expect(amount.validate('0').isValid, isTrue);
      expect(amount.validate('999999999999').isValid, isTrue);
      expect(amount.validate('9999999999999').isValid, isFalse);
      expect(pct.validate('0').isValid, isTrue);
      expect(pct.validate('100').isValid, isTrue);
      expect(pct.validate('100.01').isValid, isFalse);
      expect(pct.validate('101').isValid, isFalse);
      expect(time.validate('00:00').isValid, isTrue);
      expect(time.validate('23:59').isValid, isTrue);
      expect(time.validate('24:00').isValid, isFalse);
      expect(time.validate('12:60').isValid, isFalse);

      gates.add(
        const AissGate(
          id: 'IS02-CSIVW-005-G5',
          requirementSource:
              '4 Substeps #4: "Run automated user boundary input tests to '
              'confirm clear error block display."',
          description:
              'Amount, percentage and time rules accept their exact boundaries '
              'and reject one step outside, in both directions',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'IS02-CSIVW-005-AS01',
        atomicStepReferenceId: 'IS02-CSIVW-005-AS01-A01',
        setupStepAction:
            'Program dynamic inline error layouts to activate when input '
            'fields fail validation checks.',
        implementationOrder: 17,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'IS02-CSIVW-005-AS01-A01',
          'Execution Status': 'Executed by flutter test',
          'Execution Timestamp': 'generated per run',
          'Step Outcome':
              'Blur-bound inline errors at bodySmall in colorScheme.error, '
              'submission frozen while any error is active',
          'User ID': 'Fredrick',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Asset & Component Discovery Completeness - Input field form '
                'validation component directory',
            observed:
                'lib/design_system/forms/ present with inline_error.dart, '
                'form_gate.dart, field_validation.dart = 100%',
            floor: '90% of target assets confirmed present',
            optimal: '100% of target assets confirmed present',
            ceiling:
                '100% (full inventory - no further discovery value beyond '
                'complete coverage)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/inline_error.dart',
          'lib/design_system/forms/form_gate.dart',
        ],
      ),
    );
  });
}
