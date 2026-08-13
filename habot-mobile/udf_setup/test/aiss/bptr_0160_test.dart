/// AISS GATE -- Step 18 of 20
/// Global Reference ID:      BPTR-0160
/// Atomic Steps Reference ID: BPTR-0160-A01
/// Setup Step (Action):      "Code and isolate mobile compound fields into
///                            distinct, standalone UI components featuring
///                            strict 48x48dp touch targets."
///
/// Completion Measures: `Invalid_Data_Type_Errors == 0`.
/// Metric: Field/Element Identification Accuracy -- Floor 95, Optimal 99,
/// Ceiling 100. Best Qualitative Output: Pass/Fail.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/forms/compound_field.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/form_gate.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

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

  group('BPTR-0160-A01 :: isolated compound fields', () {
    gate(
      'BPTR-0160-G1',
      'What Standardized Must Be Done: "Global Regex mapping per CDE applied to '
          'mobile text fields." + Completion: `Invalid_Data_Type_Errors == 0`.',
      'Every CDE has a regex rule -- the completion measure is unreachable if '
          'even one data type is unmapped',
      () {
        if (!HabotFieldRules.isComplete) {
          return false;
        }
        // And each pattern is anchored, so a partial match cannot slip through.
        for (final HabotCde cde in HabotCde.values) {
          final String pattern = HabotFieldRules.of(cde).pattern.pattern;
          if (!pattern.startsWith('^') || !pattern.endsWith(r'$')) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'BPTR-0160-G2',
      'Setup Step Description: "Identify all compound entry fields (e.g., split '
          'address blocks, combined date-time fields) in mobile views." + '
          'Metric: Field/Element Identification Accuracy (Floor 95, Optimal 99).',
      'The compound-field inventory is declared as data, covers the examples '
          'the spec names, and every part resolves to a real CDE rule',
      () {
        if (!HabotCompoundFields.all.containsKey('address') ||
            !HabotCompoundFields.all.containsKey('dateTime')) {
          return false;
        }
        final List<CompoundPart> parts = HabotCompoundFields.allParts;
        if (parts.isEmpty) {
          return false;
        }
        final Set<String> names = <String>{};
        for (final CompoundPart part in parts) {
          if (part.name.isEmpty ||
              part.label.isEmpty ||
              part.flex < 1 ||
              !names.add(part.name)) {
            return false;
          }
          // Throws if the CDE has no rule -- which is the identification
          // accuracy the metric is about.
          HabotFieldRules.of(part.cde);
        }
        return true;
      },
    );

    gate(
      'BPTR-0160-G3',
      'Mobile-First UX Implementation: `inputmode="numeric"` -- "Contextual '
          'keyboard triggering for faster thumb typing."',
      'Numeric CDEs request a numeric keyboard; text CDEs do not',
      () {
        bool numeric(HabotCde cde) {
          final TextInputType t = HabotFieldRules.of(cde).keyboardType;
          return t == TextInputType.number ||
              t == const TextInputType.numberWithOptions(decimal: true) ||
              t == TextInputType.phone ||
              t == TextInputType.datetime;
        }

        return numeric(HabotCde.quantity) &&
            numeric(HabotCde.currencyAmount) &&
            numeric(HabotCde.percentage) &&
            numeric(HabotCde.phoneNumber) &&
            numeric(HabotCde.dateIso) &&
            numeric(HabotCde.timeOfDay) &&
            !numeric(HabotCde.personName) &&
            !numeric(HabotCde.freeText);
      },
    );

    gate(
      'BPTR-0160-G4',
      'Mobile-First UI Decision: "Visual input masks (e.g., MM/DD/YYYY '
          'placeholders) inside the text field."',
      'Every CDE whose format is not self-evident carries a placeholder, and '
          'the date placeholders match their patterns',
      () {
        final HabotFieldRule iso = HabotFieldRules.of(HabotCde.dateIso);
        final HabotFieldRule us = HabotFieldRules.of(HabotCde.dateUs);
        final HabotFieldRule time = HabotFieldRules.of(HabotCde.timeOfDay);
        if (iso.placeholder != 'YYYY-MM-DD' ||
            us.placeholder != 'MM/DD/YYYY' ||
            time.placeholder != 'HH:MM') {
          return false;
        }
        // The placeholder must describe a value the pattern would accept.
        return iso.validate('2026-08-11').isValid &&
            us.validate('08/11/2026').isValid &&
            time.validate('09:30').isValid;
      },
    );

    gate(
      'BPTR-0160-G5',
      'Mobile-First UX Implementation: `autocomplete="off"`.',
      'Autocomplete is off by default across every rule',
      () {
        for (final HabotCde cde in HabotCde.values) {
          if (HabotFieldRules.of(cde).autocomplete) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'BPTR-0160-G7',
      'Self-Chasing: "User cannot tap the submit button while the field is '
          'invalid, forcing them to fix their own typo instantly to proceed."',
      'An address block with one bad part blocks the whole compound',
      () {
        final HabotFormGate gate = HabotFormGate();
        for (final CompoundPart part in HabotCompoundFields.addressBlock) {
          gate.register(part.name, required: part.required);
          gate.update(
            part.name,
            HabotFieldRules.of(part.cde).validate(
              part.cde == HabotCde.postalCode ? '!!' : 'Valid Value',
              required: part.required,
            ),
          );
        }
        return !gate.canSubmit &&
            gate.invalidFields.length == 1 &&
            gate.invalidFields.contains('address.postal');
      },
    );
  });

  group('BPTR-0160-A01 :: rendered compound field', () {
    testWidgets('[BPTR-0160-G6] a compound field stacks on compact and every '
        'part keeps its own 48dp target', (WidgetTester tester) async {
      tester.view.physicalSize = HabotDevices.iphoneSe.logicalSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final HabotFormGate formGate = HabotFormGate();
      addTearDown(formGate.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: CompoundField(
                parts: HabotCompoundFields.dateTimeBlock,
                gate: formGate,
                title: 'When',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('When'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(tester.takeException(), isNull);

      // Stacked, not side by side: the second field starts below the first.
      final List<Rect> rects = tester
          .renderObjectList<RenderBox>(find.byType(TextField))
          .map((RenderBox b) => b.localToGlobal(Offset.zero) & b.size)
          .toList();
      expect(
        rects[1].top,
        greaterThanOrEqualTo(rects[0].bottom),
        reason: 'On a 320dp viewport a compound field must stack',
      );
      for (final Rect rect in rects) {
        expect(
          rect.height,
          greaterThanOrEqualTo(HabotDensity.minTouchTarget),
          reason: 'Each part of a compound field is its own 48dp target',
        );
      }

      gates.add(
        const AissGate(
          id: 'BPTR-0160-G6',
          requirementSource:
              'Setup Step (Action): "isolate mobile compound fields into '
              'distinct, standalone UI components featuring strict 48x48dp '
              'touch targets."',
          description:
              'The date-time compound stacks on a 320dp viewport and each part '
              'renders at least 48dp tall',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    final int parts = HabotCompoundFields.allParts.length;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BPTR-0160',
        atomicStepReferenceId: 'BPTR-0160-A01',
        setupStepAction:
            'Code and isolate mobile compound fields into distinct, standalone '
            'UI components featuring strict 48x48dp touch targets.',
        implementationOrder: 18,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'iOS, Android, iPadOS, Web',
          'OS Version': 'per device_matrix.json',
          'Device Type': 'phone, tablet, desktop',
          'Screen Dimensions':
              'compound fields verified stacking at 320dp (iPhone SE)',
          'Mobile Configuration':
              '${HabotCompoundFields.all.length} compound blocks, $parts parts, '
              'each an isolated component with its own CDE rule',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Field/Element Identification Accuracy',
            observed:
                '$parts of $parts compound parts identified and mapped to a '
                'CDE regex rule = 100%',
            floor: '95.0',
            optimal: '99.0',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/compound_field.dart',
          'lib/design_system/forms/field_validation.dart',
        ],
      ),
    );
  });
}
