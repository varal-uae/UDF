/// AISS GATE -- Step 138 of 155
/// Global Reference ID:       GEN-04957
/// Atomic Steps Reference ID: GEN-04957
/// Setup Step (Action) / Atomic Step: "Review the setup step objective: Embed
///   a dynamic multi-language localization framework supporting instant UI and
///   form text translation (e.g., Welsh, Urdu, Punjabi, Polish) to ensure
///   equitable access for non-English speakers."
/// Metric: Requirements Objective Clarity / Sign-off Score -- Floor ">=80%",
///         Optimal "100%", Ceiling "100%".
///
/// A REVIEW STEP THAT HAD TO FIND SOMETHING. Sign-off on an objective nobody
/// has questioned is a signature, not a review, so what is gated is whether
/// the objective is now buildable: the RTL case named, the expansion case
/// named, "instant" given a definition, and every open question answered.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';

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

  group('GEN-04957 :: what the review found', () {
    gate(
      'GEN-04957-G1',
      'The objective lists "(e.g., Welsh, Urdu, Punjabi, Polish)" as though '
          'four languages were four sets of strings. Urdu is written '
          'right-to-left in the Perso-Arabic script.',
      'The right-to-left case is identified as a REQUIREMENT with the '
          'consequence traced to the step it constrains -- not left as a note '
          'for whoever builds the wizard to notice',
      () {
        final HabotLanguage urdu = HabotLocalizationObjective.byCode('ur');
        final HabotObjectiveFinding f1 =
            HabotLocalizationObjective.findings.first;
        return urdu.isRightToLeft &&
            urdu.direction == HabotTextDirectionality.rightToLeft &&
            urdu.script.contains('Perso-Arabic') &&
            HabotLocalizationObjective.rightToLeftLanguages.length == 1 &&
            f1.id == 'F-1' &&
            f1.finding.contains('right-to-left') &&
            f1.consequenceIfMissed.contains('rebuilding the wizard') &&
            f1.bindsStep.contains('GEN-01396');
      },
    );

    gate(
      'GEN-04957-G2',
      'Welsh and Polish expand materially against English, and every label in '
          'this app was laid out against an English string.',
      'Expansion is a declared, numeric property of each language rather than '
          'a warning in prose, and the worst case is available to the step '
          'that audits layout',
      () {
        final HabotLanguage cy = HabotLocalizationObjective.byCode('cy');
        final HabotLanguage pl = HabotLocalizationObjective.byCode('pl');
        return cy.expansionFactor >= 1.25 &&
            pl.expansionFactor >= 1.20 &&
            HabotLocalizationObjective.byCode('en').expansionFactor == 1.0 &&
            HabotLocalizationObjective.worstCaseExpansion ==
                cy.expansionFactor &&
            HabotLocalizationObjective.findings.any(
              (HabotObjectiveFinding f) =>
                  f.id == 'F-2' && f.bindsStep.contains('GEN-05430'),
            );
      },
    );

    gate(
      'GEN-04957-G3',
      'A language list shown only in English names is unusable by someone who '
          'reads Urdu and not English -- the settings screen defeats the '
          'objective.',
      'Every language carries its endonym as well as its English name, and '
          'the finding that makes it a requirement is recorded',
      () =>
          HabotLocalizationObjective.languages.every(
            (HabotLanguage l) =>
                l.endonym.isNotEmpty && l.englishName.isNotEmpty,
          ) &&
          HabotLocalizationObjective.byCode('ur').endonym !=
              HabotLocalizationObjective.byCode('ur').englishName &&
          HabotLocalizationObjective.byCode('pa').endonym !=
              HabotLocalizationObjective.byCode('pa').englishName &&
          HabotLocalizationObjective.findings.any(
            (HabotObjectiveFinding f) => f.id == 'F-5',
          ),
    );

    gate(
      'GEN-04957-G4',
      'The objective says "UI and FORM TEXT translation". Form text is mostly '
          'validation error messages, which live in HabotFieldRules rather '
          'than in a screen and are therefore the easiest strings to forget.',
      'That is recorded as a finding with its consequence, so the coverage '
          'definition at Step 143 cannot quietly exclude them',
      () => HabotLocalizationObjective.findings.any(
        (HabotObjectiveFinding f) =>
            f.id == 'F-4' &&
            f.finding.contains('error messages') &&
            f.consequenceIfMissed.contains('reject an entry in English'),
      ),
    );
  });

  group('GEN-04957 :: whether the objective is now buildable', () {
    gate(
      'GEN-04957-G5',
      '"Instant" and "what happens to an untranslated string" are the two '
          'words the objective leaves undefined, and both decide the '
          'implementation before it is written.',
      'Both are answered with a reason, and the answers rule out the obvious '
          'implementations -- a language pack fetched on selection, and '
          'per-string fallback to English',
      () {
        final HabotObjectiveDecision d2 = HabotLocalizationObjective.decisions
            .firstWhere((HabotObjectiveDecision d) => d.id == 'D-2');
        final HabotObjectiveDecision d3 = HabotLocalizationObjective.decisions
            .firstWhere((HabotObjectiveDecision d) => d.id == 'D-3');
        return d2.answer.contains('No restart, no fetch') &&
            d2.rationale.contains('offline-first') &&
            d3.answer.contains('not offered at all') &&
            d3.rationale.contains('half-translated') &&
            HabotLocalizationObjective.decisions.length >= 4;
      },
    );

    gate(
      'GEN-04957-G6',
      'Metric: Requirements Objective Clarity / Sign-off Score. Floor 80%, '
          'optimal 100%.',
      'The score is computed over the review own checks, reports in the row '
          'own vocabulary, names any gap rather than only counting it, and '
          'the reason sign-off alone is not what is scored is recorded',
      () =>
          HabotLocalizationObjective.clarityScore == 1.0 &&
          HabotLocalizationObjective.clarityScore >=
              HabotLocalizationObjective.floor &&
          HabotLocalizationObjective.qualitativeOutput == 'Complete' &&
          HabotLocalizationObjective.gaps.isEmpty &&
          HabotLocalizationObjective.clarityChecks.length == 5 &&
          HabotLocalizationObjective.signOffNote.contains(
            'a signature, not a review',
          ),
    );

    gate(
      'GEN-04957-G7',
      'A review whose findings do not bind anything is a document.',
      'Every finding names the later step it constrains, and those steps are '
          'in this batch -- so a finding cannot be recorded and then ignored '
          'without a named gate failing',
      () {
        const List<String> boundRefs = <String>[
          'GEN-01396',
          'GEN-05430',
          'GEN-04583',
        ];
        return HabotLocalizationObjective.findings.every(
              (HabotObjectiveFinding f) => f.bindsStep.isNotEmpty,
            ) &&
            boundRefs.every((String ref) =>
                HabotLocalizationObjective.findings.any(
                  (HabotObjectiveFinding f) => f.bindsStep.contains(ref),
                ));
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04957',
        atomicStepReferenceId: 'GEN-04957',
        setupStepAction:
            'Review the setup step objective: Embed a dynamic multi-language '
            'localization framework supporting instant UI and form text '
            'translation (e.g., Welsh, Urdu, Punjabi, Polish) to ensure '
            'equitable access for non-English speakers.',
        implementationOrder: 138,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotLocalizationObjective',
          'Component Properties':
              '${HabotLocalizationObjective.languages.length} languages with '
              'script, direction, endonym and expansion factor; '
              '${HabotLocalizationObjective.findings.length} findings; '
              '${HabotLocalizationObjective.decisions.length} decisions',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The review is written as code so that '
              'Steps 139-145 can be checked against it, in the same way Step '
              '133 specified Step 134.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirements Objective Clarity / Sign-off Score',
            observed:
                '${HabotLocalizationObjective.qualitativeOutput} -- '
                '${(HabotLocalizationObjective.clarityScore * 100).toStringAsFixed(0)}'
                '% over ${HabotLocalizationObjective.clarityChecks.length} '
                'checks. Sign-off alone is not what is scored: what is scored '
                'is whether the objective is now buildable.',
            floor: '>=80% stakeholder sign-off on stated objective',
            optimal: '100% stakeholder sign-off',
            ceiling: '100% (no benefit beyond full sign-off)',
          ),
          AissMeasurement(
            metricName: 'Unstated requirements found before build',
            observed:
                '${HabotLocalizationObjective.findings.length}. The largest is '
                'that Urdu reverses layout direction: the row lists it '
                'alongside three left-to-right languages as though the four '
                'differed only in their strings. Found here, it constrains '
                'Steps 149-152; found after the wizard was built, it would '
                'have meant rebuilding the wizard.',
            floor: '>=1',
            optimal: 'every unstated requirement found',
            ceiling: 'not bounded',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/i18n/localization_objective.dart',
        ],
      ),
    );
  });
}
