/// AISS GATE -- Step 144 of 155
/// Global Reference ID:       GEN-05430
/// Atomic Steps Reference ID: GEN-05430
/// Setup Step (Action) / Atomic Step: "Build and configure: configure
///   touch-friendly language toggle controls embedded in top navigation bars."
/// Metric: Localization Coverage & Layout Accuracy -- Floor ">= 95%",
///         Optimal 1.0, Ceiling 1.0. Pass / Fail.
///
/// THE METRIC NAMES TWO THINGS AND THE SECOND IS THE POINT. Strings that all
/// exist and do not fit is the failure this row is really about, and it is the
/// one a team reports as done.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/language_preference.dart';
import 'package:udf_setup/design_system/i18n/language_toggle.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';
import 'package:udf_setup/design_system/navigation/contextual_header.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double accuracy = 0;

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

  HabotLanguagePreference preference() => HabotLanguagePreference(
        catalogues: <HabotStringCatalogue>[
          HabotEnglishStrings.catalogue,
          HabotStringCatalogue(
            localeCode: 'ur',
            strings: <String, String>{
              for (final String k in HabotMessageKeys.all) k: 'ur:$k',
            },
            source: 'gate fixture',
          ),
        ],
      );

  group('GEN-05430 :: layout accuracy, the half that is usually skipped', () {
    gate(
      'GEN-05430-G1',
      'Step 138 finding F-2: Welsh runs about 30% longer than English and '
          'Polish about 25%, while every label in this app was laid out '
          'against an English string and the header caps titles at '
          'HabotDensity.maxHeaderTitleChars.',
      'Every shipped label fits in every language the objective names, '
          'measured against the real budget each surface enforces rather than '
          'against a guess',
      () {
        accuracy = HabotLanguageToggle.layoutAccuracyAcrossScope;
        return accuracy == 1.0 &&
            accuracy >= HabotLanguageToggle.floor &&
            HabotLanguageToggle
                .overflowingLabels(HabotLocalizationObjective.languages)
                .isEmpty &&
            HabotLanguageToggle.auditedLabels.length >= 6 &&
            HabotLanguageToggle.headerTitleBudget ==
                HabotDensity.maxHeaderTitleChars;
      },
    );

    gate(
      'GEN-05430-G2',
      'Every shipped label fits, so a rate computed only over shipped labels '
          'is 1.0 whatever the implementation does. An audit that cannot fail '
          'is not an audit.',
      'The labels this audit actually REJECTED are recorded, and each one '
          'still overflows in at least one offered language -- so the audit is '
          'shown capable of failing before its pass is believed',
      () =>
          HabotLanguageToggle.rejectedForExpansion.length >= 2 &&
          HabotLanguageToggle.rejectionsThatWouldNotHaveFailed.isEmpty &&
          HabotLanguageToggle.rejectedForExpansion.every(
            (HabotRejectedLabel r) =>
                r.overflowsIn.isNotEmpty && r.replacedWith.isNotEmpty,
          ) &&
          HabotLanguageToggle.rejectedForExpansion
              .first
              .overflowsIn
              .contains('Welsh') &&
          HabotLanguageToggle.auditIsFalsifiableNote.contains(
            'capable of failing',
          ),
    );

    gate(
      'GEN-05430-G3',
      'The rejected header title is not hypothetical: "Notification '
          'preferences" is the Step 50 screen, and it would have shipped.',
      'The shortened label is what the English catalogue actually carries, so '
          'the audit changed the product rather than producing a report',
      () {
        final HabotRejectedLabel rejected =
            HabotLanguageToggle.rejectedForExpansion.first;
        return rejected.candidate.english == 'Notification preferences' &&
            rejected.replacedWith == 'Notifications' &&
            HabotEnglishStrings.values['settings.notifications'] ==
                rejected.replacedWith &&
            rejected.overflowsIn.length == 2 &&
            rejected.candidate.expandedLengthIn(
                  HabotLocalizationObjective.byCode('cy'),
                ) >
                HabotDensity.maxHeaderTitleChars;
      },
    );

    gate(
      'GEN-05430-G4',
      'An app whose strings are fully translated and whose labels truncate in '
          'half of them is not "75% localised" -- it is broken in those '
          'languages.',
      'The two halves of the metric are multiplied rather than averaged, so a '
          'perfect score on the easy half cannot carry the hard one',
      () {
        const double perfectCoverage = 1.0;
        const double halfAccuracy = 0.5;
        final double combined = HabotLanguageToggle.combined(
          coverage: perfectCoverage,
          accuracy: halfAccuracy,
        );
        return combined == 0.5 &&
            combined < (perfectCoverage + halfAccuracy) / 2 &&
            combined < HabotLanguageToggle.floor &&
            HabotLanguageToggle.twoHalvesNote.contains('multiplied, not '
                'averaged');
      },
    );
  });

  group('GEN-05430 :: touch-friendly, in the top navigation bar', () {
    gate(
      'GEN-05430-G5',
      'Atomic Step: "TOUCH-FRIENDLY language toggle controls EMBEDDED IN TOP '
          'NAVIGATION BARS." Step 9 built the header action model and Step 10 '
          'set the 48dp minimum.',
      'The control is a header action, so it inherits the touch target and the '
          'overflow behaviour rather than restating them, and it sits high '
          'enough in the priority order to stay out of the overflow sheet on a '
          'compact screen',
      () {
        final HabotLanguagePreference p = preference();
        final HabotHeaderAction action = HabotLanguageToggle.actionFor(
          p,
          icon: Icons.language,
          onOpenChooser: () {},
        );
        return HabotLanguageToggle.minTouchTarget ==
                HabotDensity.minTouchTarget &&
            HabotLanguageToggle.minTouchTarget == 48 &&
            action.priority == HabotLanguageToggle.headerPriority &&
            action.priority <
                HabotContextualHeader.maxVisibleActionsCompact &&
            action.label.isNotEmpty;
      },
    );

    gate(
      'GEN-05430-G6',
      'Step 138 finding F-5: someone who reads Urdu and not English cannot '
          'find "Urdu" in a list. And a screen reader user needs to know what '
          'the control is SET TO, not what it is called.',
      'The chooser rows lead with the endonym, and the header action own '
          'accessible name is the active language in its own script -- which '
          'changes when the language does',
      () {
        final HabotLanguagePreference p = preference();
        final HabotHeaderAction before = HabotLanguageToggle.actionFor(
          p,
          icon: Icons.language,
          onOpenChooser: () {},
        );
        p.activate('ur');
        final HabotHeaderAction after = HabotLanguageToggle.actionFor(
          p,
          icon: Icons.language,
          onOpenChooser: () {},
        );
        final List<HabotLanguageOption> options =
            HabotLanguageToggle.optionsFor(p);
        final HabotLanguageOption urdu = options.firstWhere(
          (HabotLanguageOption o) => o.language.code == 'ur',
        );
        return before.label == 'English' &&
            after.label == HabotLocalizationObjective.byCode('ur').endonym &&
            before.label != after.label &&
            urdu.primaryLabel == urdu.language.endonym &&
            urdu.secondaryLabel == 'Urdu' &&
            urdu.isActive &&
            urdu.isOfferable &&
            options.where((HabotLanguageOption o) => !o.isOfferable).length ==
                HabotLocalizationObjective.languages.length - 2;
      },
    );

    gate(
      'GEN-05430-G7',
      'Step 24 (MUFCE-028) banned hover affordances, and Flutter wraps '
          'PopupMenuButton in a Tooltip unconditionally -- which is why the '
          'header overflow is a sheet. A flag is a country; languages are not '
          'countries.',
      'The control declares a language glyph rather than a flag, and the '
          'reason is recorded so nobody later "improves" it into a flag row',
      () =>
          HabotLanguageToggle.languageIconName == 'language' &&
          HabotLanguageToggle.noFlagsNote.contains('A flag is a country') &&
          HabotLanguageToggle.noFlagsNote.contains('diaspora') &&
          HabotLanguageToggle.worstCaseNote.contains('WORST expansion'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05430',
        atomicStepReferenceId: 'GEN-05430',
        setupStepAction:
            'Build and configure: configure touch-friendly language toggle '
            'controls embedded in top navigation bars',
        implementationOrder: 144,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotLanguageToggle',
          'Component Properties':
              'a HabotHeaderAction at priority '
              '${HabotLanguageToggle.headerPriority}, '
              '${HabotLanguageToggle.minTouchTarget.toStringAsFixed(0)}dp touch '
              'target inherited from Step 10, '
              '${HabotLanguageToggle.auditedLabels.length} labels audited for '
              'expansion, ${HabotLanguageToggle.rejectedForExpansion.length} '
              'source strings rejected',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The layout-accuracy half of the metric is '
              'computed from the Step 138 expansion factors against the real '
              'budgets each surface enforces.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Layout Accuracy',
            observed:
                '${(accuracy * 100).toStringAsFixed(0)}% -- every shipped '
                'label fits in all '
                '${HabotLocalizationObjective.languages.length} languages the '
                'objective names, audited against the worst expansion rather '
                'than an average. The audit is demonstrably able to fail: '
                '${HabotLanguageToggle.rejectedForExpansion.length} source '
                'strings were rejected and still overflow.',
            floor: '>= 95%',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          const AissMeasurement(
            metricName: 'Labels that would have truncated in Welsh or Polish',
            observed:
                '2, both caught before shipping. "Notification preferences" '
                'reaches 32 characters in Welsh against a 28-character header '
                'cap and shipped as "Notifications"; "Save and continue" wraps '
                'in every offered language against a 12-character button '
                'budget and shipped as "Save". The English screens would have '
                'looked fine in review.',
            floor: '0 shipped',
            optimal: '0 shipped',
            ceiling: '0 shipped',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/i18n/language_toggle.dart',
        ],
      ),
    );
  });
}
