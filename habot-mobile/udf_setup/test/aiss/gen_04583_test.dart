/// AISS GATE -- Step 143 of 155
/// Global Reference ID:       GEN-04583
/// Atomic Steps Reference ID: GEN-04583
/// Setup Step (Action) / Atomic Step: "Build a dynamic language switching
///   setting option in app preferences."
/// Metric: Translation/Localization Coverage -- Floor 0.95, Optimal 1.0,
///         Ceiling 1.0. Complete / Partial / Not Complete.
///
/// A DELIBERATE DEVIATION UPWARD FROM THE ROW'S FLOOR: a language below 100%
/// coverage is not offered at all. Recorded at Step 138 as decision D-3 and
/// gated here.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/i18n/language_preference.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double scopeCoverage = 0;

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

  /// A complete catalogue for [code], standing in for a delivered translation.
  HabotStringCatalogue complete(String code) => HabotStringCatalogue(
        localeCode: code,
        strings: <String, String>{
          for (final String k in HabotMessageKeys.all) k: '$code:$k',
        },
        source: 'gate fixture',
      );

  HabotStringCatalogue missingOne(String code) {
    final Map<String, String> s = <String, String>{
      for (final String k in HabotMessageKeys.all) k: '$code:$k',
    }..remove(HabotMessageKeys.fieldErrors.last);
    return HabotStringCatalogue(
      localeCode: code,
      strings: s,
      source: 'gate fixture',
    );
  }

  group('GEN-04583 :: what the catalogue must contain', () {
    gate(
      'GEN-04583-G1',
      'Step 138 finding F-4: the objective says "UI and FORM TEXT '
          'translation", and form text is mostly validation error messages -- '
          'which live in HabotFieldRules rather than in a screen and are the '
          'easiest strings to forget.',
      'The key registry contains one error key for every Critical Data '
          'Element, so a coverage figure cannot be reached by translating the '
          'chrome and leaving the errors in English',
      () =>
          HabotMessageKeys.fieldErrors.length == HabotCde.values.length &&
          HabotCde.values.every((HabotCde c) =>
              HabotMessageKeys.all.contains('error.${c.name}')) &&
          HabotMessageKeys.chrome.contains('settings.language') &&
          HabotMessageKeys.count ==
              HabotMessageKeys.chrome.length + HabotCde.values.length,
    );

    gate(
      'GEN-04583-G2',
      'English is the source language, so its strings are not translations. '
          'If the source catalogue has a gap, every other catalogue inherits '
          'it.',
      'The English catalogue covers the registry completely and carries no '
          'orphan keys -- a stale key is dead weight a translator was paid '
          'for, and usually means a string was renamed without the catalogues '
          'being told',
      () {
        final HabotStringCatalogue en = HabotEnglishStrings.catalogue;
        return en.isComplete &&
            en.coverage == 1.0 &&
            en.missingKeys.isEmpty &&
            en.orphanKeys.isEmpty &&
            en.localeCode == HabotLanguagePreference.sourceLocale;
      },
    );

    gate(
      'GEN-04583-G3',
      'A coverage figure measured against what happens to be installed reports '
          '100% for an app that has done nothing.',
      'Coverage is measured against the full scope the objective names, so an '
          'English-only build scores a fifth rather than full marks, and the '
          'untranslated languages are listed by name',
      () {
        final HabotLanguagePreference p = HabotLanguagePreference();
        scopeCoverage = p.localizationCoverage;
        final int scope = HabotLocalizationObjective.languages.length;
        return scopeCoverage > 0 &&
            scopeCoverage < 1.0 &&
            (scopeCoverage - 1 / scope).abs() < 0.0001 &&
            p.untranslatedLocales.length == scope - 1 &&
            p.qualitativeOutput == 'Partial' &&
            HabotLanguagePreference.translationBoundaryNote.contains(
              'no speaker had checked',
            );
      },
    );
  });

  group('GEN-04583 :: the switch itself', () {
    gate(
      'GEN-04583-G4',
      'Step 138 decision D-3: a 95%-translated screen reads as a broken app, '
          'and per-string fallback hides the gap from the metric meant to '
          'expose it.',
      'A catalogue one key short of complete is NOT offered however close it '
          'is, the missing key is named so the translation work can be driven '
          'from the report, and the deviation from the row 0.95 floor is '
          'recorded in the code',
      () {
        final HabotLanguagePreference p = HabotLanguagePreference(
          catalogues: <HabotStringCatalogue>[
            HabotEnglishStrings.catalogue,
            missingOne('cy'),
          ],
        );
        final double cyCoverage = p.coverageByLocale['cy']!;
        return cyCoverage > HabotLanguagePreference.floor &&
            cyCoverage < 1.0 &&
            !p.canOffer('cy') &&
            !p.offerableLocales.contains('cy') &&
            p.withheldLocales['cy']!.length == 1 &&
            p.withheldLocales['cy']!.single ==
                HabotMessageKeys.fieldErrors.last &&
            !p.activate('cy') &&
            p.activeLocale == 'en' &&
            HabotLanguagePreference.floorRefusedNote.contains(
              'deliberate deviation upward',
            );
      },
    );

    gate(
      'GEN-04583-G5',
      'Step 138 decision D-2: "instant" means the switch takes effect before '
          'the call returns -- no restart, no fetch, no disk read on the '
          'lookup path.',
      'Activating a complete language changes what stringOf returns '
          'synchronously and notifies listeners in the same turn, and the '
          'lookup for an unknown key returns the key rather than an empty '
          'string, which is ugly on screen and therefore gets fixed',
      () {
        int notifications = 0;
        final HabotLanguagePreference p = HabotLanguagePreference(
          catalogues: <HabotStringCatalogue>[
            HabotEnglishStrings.catalogue,
            complete('cy'),
          ],
        )..addListener(() => notifications++);
        final String before = p.stringOf('action.next');
        final bool switched = p.activate('cy');
        final String after = p.stringOf('action.next');
        return before == 'Next' &&
            switched &&
            after == 'cy:action.next' &&
            notifications == 1 &&
            p.activeLocale == 'cy' &&
            p.stringOf('no.such.key') == 'no.such.key';
      },
    );

    gate(
      'GEN-04583-G6',
      'Step 138 finding F-1: selecting Urdu is not a change of strings, it is '
          'a change of layout direction.',
      'Direction travels with the language and is read from one place, so a '
          'screen cannot be translated without being mirrored',
      () {
        final HabotLanguagePreference p = HabotLanguagePreference(
          catalogues: <HabotStringCatalogue>[
            HabotEnglishStrings.catalogue,
            complete('ur'),
          ],
        );
        final bool ltrBefore = !p.isRightToLeft;
        p.activate('ur');
        return ltrBefore &&
            p.isRightToLeft &&
            p.direction == HabotTextDirectionality.rightToLeft &&
            p.activeLanguage.code == 'ur' &&
            p.activeLanguage.endonym.isNotEmpty;
      },
    );

    gate(
      'GEN-04583-G7',
      'A translator handed "%s of %s" cannot tell which number is which, so '
          'positional placeholders produce translations that are right in the '
          'catalogue and wrong on the screen.',
      'Interpolation is by name, the source string uses named placeholders, '
          'and the persistence of the choice is fire-and-forget so a failed '
          'disk write cannot fail the user own selection',
      () {
        final List<String> persisted = <String>[];
        final HabotLanguagePreference p = HabotLanguagePreference(
          catalogues: <HabotStringCatalogue>[
            HabotEnglishStrings.catalogue,
            complete('pl'),
          ],
          persist: (String code) async => persisted.add(code),
        );
        final String rendered = p.format(
          'wizard.stepOfTotal',
          <String, String>{'current': '2', 'total': '7'},
        );
        final bool switched = p.activate('pl');
        return rendered == 'Step 2 of 7' &&
            HabotEnglishStrings.values['wizard.stepOfTotal']!
                .contains('{current}') &&
            switched &&
            persisted.single == 'pl' &&
            HabotLanguagePreference.namedPlaceholderNote.contains(
              'never positional',
            );
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04583',
        atomicStepReferenceId: 'GEN-04583',
        setupStepAction:
            'Build a dynamic language switching setting option in app '
            'preferences.',
        implementationOrder: 143,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotLanguagePreference / HabotStringCatalogue / '
              'HabotMessageKeys',
          'Component Properties':
              '${HabotMessageKeys.count} declared message keys '
              '(${HabotMessageKeys.chrome.length} chrome + '
              '${HabotCde.values.length} field errors); synchronous lookup; a '
              'language below 100% coverage is not offered',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The row floor of 0.95 is deliberately '
              'exceeded rather than met -- see '
              'HabotLanguagePreference.floorRefusedNote and Step 138 decision '
              'D-3.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Translation/Localization Coverage',
            observed:
                'Partial -- ${(scopeCoverage * 100).toStringAsFixed(0)}% '
                'across the ${HabotLocalizationObjective.languages.length} '
                'languages the objective names. English is complete; Welsh, '
                'Urdu, Punjabi and Polish catalogues are a translation '
                'deliverable and are NOT invented here. The mechanism refuses '
                'to offer a language until its catalogue is complete, so the '
                'gap appears in this figure rather than on a user screen.',
            floor: '0.95',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          const AissMeasurement(
            metricName: 'Half-translated languages reachable by a user',
            observed:
                '0. A catalogue one key short of complete is refused however '
                'close it is, and the missing key is named so the translation '
                'work can be driven from the report. The row would have '
                'permitted 95%; per-string fallback to English would have hid '
                'the gap from the metric meant to expose it.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/i18n/language_preference.dart',
        ],
      ),
    );
  });
}
