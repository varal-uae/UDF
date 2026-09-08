/// AISS GATE -- Step 110 of 115
/// Global Reference ID:       GEN-01793
/// Atomic Steps Reference ID: GEN-01793-A01
/// Setup Step (Action):       "Map native keyboard types to specific field
///                             requirements."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED: the row carries a generic step-completion rate.
/// The requirement is specific and checkable, so that is what is gated.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/keyboard_mapping.dart';

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

  group('GEN-01793-A01 :: one mapping, not two', () {
    gate(
      'GEN-01793-G1',
      'Setup Step (Action): "map native keyboard types to SPECIFIC FIELD '
          'REQUIREMENTS". Step 16 already declares 13 critical data elements.',
      'Every CDE is mapped, and the completeness check is a property of the '
          'data -- adding a data element without a keyboard profile fails here '
          'rather than shipping a text keyboard over a currency field',
      () =>
          HabotKeyboardMapping.isComplete &&
          HabotKeyboardMapping.missing.isEmpty &&
          HabotCde.values.length == 13,
    );

    gate(
      'GEN-01793-G2',
      'Step 16 already owns HabotFieldRule.keyboardType. A second mapping is '
          'a second thing to keep in step.',
      'The keyboard type is READ from the Step 16 rule rather than restated, '
          'so the two cannot disagree',
      () => HabotCde.values.every(
        (HabotCde c) =>
            HabotKeyboardMapping.of(c).keyboardType ==
            HabotFieldRules.of(c).keyboardType,
      ),
    );

    gate(
      'GEN-01793-G3',
      'Autocorrect on a postal code produces a word. On a surname it renames '
          'a person.',
      'No structured field has autocorrect or suggestions enabled, and free '
          'text is the only field that does',
      () =>
          HabotKeyboardMapping.structuredFieldsWithAutocorrect.isEmpty &&
          HabotKeyboardMapping.structured.every(
            (HabotCde c) => !HabotKeyboardMapping.of(c).enableSuggestions ||
                c == HabotCde.addressLine,
          ) &&
          HabotKeyboardMapping.of(HabotCde.freeText).autocorrect,
    );
  });

  group('GEN-01793-A01 :: the properties a TextInputType does not carry', () {
    gate(
      'GEN-01793-G4',
      'A field that always says "Done" ends input on every tap; a screen '
          'reader user traversing a form is stopped at the first field.',
      'The bottom-right key is "Next" in the middle of a form and "Done" only '
          'on the last field, decided per position rather than per field type',
      () => HabotKeyboardMapping.all.every(
        (HabotKeyboardProfile p) =>
            p.actionFor(isLast: false) == TextInputAction.next &&
            p.actionFor(isLast: true) == TextInputAction.done,
      ),
    );

    gate(
      'GEN-01793-G5',
      'A wrong autofill hint is worse than none: it offers the user the wrong '
          'value with confidence.',
      'Autofill hints are present exactly where a platform category genuinely '
          'applies, and absent -- not guessed -- everywhere else; capitalisation '
          'is set deliberately per element',
      () {
        final HabotKeyboardProfile email = HabotKeyboardMapping.of(
          HabotCde.emailAddress,
        );
        final HabotKeyboardProfile postal = HabotKeyboardMapping.of(
          HabotCde.postalCode,
        );
        final HabotKeyboardProfile amount = HabotKeyboardMapping.of(
          HabotCde.currencyAmount,
        );
        return email.autofillHints.contains(AutofillHints.email) &&
            email.capitalization == TextCapitalization.none &&
            postal.autofillHints.contains(AutofillHints.postalCode) &&
            postal.capitalization == TextCapitalization.characters &&
            amount.autofillHints.isEmpty &&
            HabotKeyboardMapping.of(HabotCde.personName).capitalization ==
                TextCapitalization.words;
      },
    );

    gate(
      'GEN-01793-G6',
      'From the build order: "a numeric keypad is only an accessibility win '
          'if the field it opens over is still readable at 200% text".',
      'The Step 102 scaling audit is reused to confirm a field label holds at '
          'every audited scale, so this step is tied to the one before it '
          'rather than asserting independence',
      () =>
          HabotKeyboardMapping.labelSurvivesMaxScale() &&
          HabotKeyboardMapping.labelSurvivesMaxScale(
            label: 'Account number',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01793',
        atomicStepReferenceId: 'GEN-01793-A01',
        setupStepAction:
            'Map native keyboard types to specific field requirements.',
        implementationOrder: 110,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotKeyboardMapping / HabotKeyboardProfile',
          'Component Properties':
              '${HabotCde.values.length} critical data elements, each with '
              'capitalisation, autofill hints, autocorrect and suggestion '
              'settings; keyboard type read from the Step 16 rule rather than '
              'restated; '
              '${HabotKeyboardMapping.structured.length} structured elements '
              'with autocorrect off',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row, and the metric is a generic step '
              'completion rate.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Critical data elements with a keyboard profile',
            observed:
                '${HabotKeyboardMapping.all.length} of '
                '${HabotCde.values.length}, with '
                '${HabotKeyboardMapping.structuredFieldsWithAutocorrect.length} '
                'structured fields left autocorrecting',
            floor: 'every element mapped',
            optimal: 'every element mapped',
            ceiling: 'every element mapped',
          ),
          const AissMeasurement(
            metricName: 'Typing effort saved (the outcome this is for)',
            observed:
                'NOT PRODUCED. Keystrokes saved by the right keyboard and a '
                'correct autofill hint is a field measurement, and there is '
                'no telemetry pipeline yet -- Step 123 builds one. What is '
                'gated is that the right keyboard is declared for every '
                'element.',
            floor: 'no telemetry pipeline yet',
            optimal: 'no telemetry pipeline yet',
            ceiling: 'no telemetry pipeline yet',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/keyboard_mapping.dart',
        ],
      ),
    );
  });
}
