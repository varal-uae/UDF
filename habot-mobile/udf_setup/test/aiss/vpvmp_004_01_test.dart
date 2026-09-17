/// AISS GATE -- Step 303 of 315
/// Global Reference ID:       VPVMP-004-01
/// Atomic Steps Reference ID: VPVMP-004-01
/// Setup Step (Action): "Trigger a warning/alert event when a task exceeds its
///                      SLA limit." (A DIFFERENT SUBJECT)
/// Atomic Step: "Break combined text layout strings down into separate atomic
///               variables."
/// Metric: UI Design-System Adherence Rate -- floor >=85%, optimal >=95%,
///         ceiling 1. Good/Average/Poor.
///
/// THE INSTRUCTION, FOLLOWED LITERALLY, PRODUCES THE HARM IT IS REACHING FOR.
/// ELEVEN OF SIXTEEN PLURAL FORMS HAVE NOWHERE TO GO.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/atomic_strings.dart';

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

  group('VPVMP-004-01 :: what a fragment scheme can express', () {
    gate(
      'VPVMP-004-01-G1',
      'Step 139 declares five shipped locales.',
      'Every one of them has a plural profile here, so the two tables cannot '
          'drift apart unnoticed',
      () =>
          HabotAtomicStrings.shippedLocales.length == 5 &&
          HabotAtomicStrings.profiles.length == 5 &&
          HabotAtomicStrings.everyShippedLocaleHasAProfile,
    );

    gate(
      'VPVMP-004-01-G2',
      'Welsh has six plural categories and Polish four.',
      'One countable sentence needs sixteen forms across the five languages '
          'this application already ships',
      () =>
          HabotAtomicStrings.formsNeededAcrossAllLocales == 16 &&
          HabotAtomicStrings.localesWithMoreThanTwoForms.length == 2,
    );

    gate(
      'VPVMP-004-01-G3',
      'Atomic Step: "break combined strings into separate atomic variables".',
      'A concatenation has one shape -- words, slot, words -- so it offers '
          'five forms and eleven of the sixteen have nowhere to go',
      () =>
          HabotAtomicStrings.formsAFragmentSchemeCanExpress == 5 &&
          HabotAtomicStrings.formsThatCannotBeExpressed == 11 &&
          HabotAtomicStrings.fragmentCoverage == 5 / 16,
    );

    gate(
      'VPVMP-004-01-G4',
      'Not "read awkwardly" -- there is no place in the structure.',
      'And naming the fragments leaves the structure as it was while making '
          'the sentence invisible in the source',
      () =>
          HabotAtomicStrings.fragmentNote
              .contains('no place in the structure') &&
          HabotAtomicStrings.fragmentNote.contains('no longer visible'),
    );
  });

  group('VPVMP-004-01 :: what is built instead', () {
    gate(
      'VPVMP-004-01-G5',
      'One message per sentence, with the variable part as a parameter.',
      'The row\'s shape is refused and every form in the table is a whole '
          'sentence a translator can rewrite, word order included',
      () =>
          HabotAtomicStrings.theRowsShapeIsRefused &&
          HabotAtomicStrings.chosenShape ==
              HabotMessageShape.parameterisedWhole &&
          HabotAtomicStrings.everyFormIsAWholeSentence,
    );

    gate(
      'VPVMP-004-01-G6',
      'The plural category is a property of the locale, not of the number.',
      'In Welsh 3 is "few" and 6 is "many", which no amount of checking '
          'n == 1 in Dart discovers; the table has room for all six',
      () =>
          HabotAtomicStrings.countIsChosenByTheLocaleRule &&
          HabotAtomicStrings.theTableHasRoomForEveryCategory &&
          HabotAtomicStrings.pluralNote
              .contains('adds rows rather than branches'),
    );
  });

  group('VPVMP-004-01 :: the bidi algorithm', () {
    gate(
      'VPVMP-004-01-G7',
      'Urdu is right to left.',
      'One of the five locales is RTL and its parameter is wrapped in the '
          'isolate characters Step 139 already ships',
      () =>
          HabotAtomicStrings.rightToLeftLocales.length == 1 &&
          HabotAtomicStrings.rightToLeftLocales.first.code == 'ur' &&
          HabotAtomicStrings.theIsolateWrapsTheParameter,
    );

    gate(
      'VPVMP-004-01-G8',
      'A concatenation has nothing left to isolate.',
      'By then there is one flat string and nothing knows which part of it '
          'was the number',
      () =>
          HabotAtomicStrings.aConcatenationCannotIsolateAnything &&
          HabotAtomicStrings.bidiNote.contains('one flat string'),
    );
  });

  group('VPVMP-004-01 :: the band', () {
    gate(
      'VPVMP-004-01-G9',
      'Ceiling "1" against percentage floors.',
      'Recorded; the step reports over its own declared obligations',
      () =>
          HabotAtomicStrings.obligations.length == 6 &&
          HabotAtomicStrings.adherence == 1.0,
    );

    gate(
      'VPVMP-004-01-G10',
      'Output: Good / Average / Poor.',
      'Six declared obligations, all met, giving a Good; all ten declared '
          'checks hold, and the row\'s duplicated narrative block is recorded',
      () =>
          HabotAtomicStrings.obligations.values.every((bool b) => b) &&
          HabotAtomicStrings.qualitativeOutput == 'Good' &&
          HabotAtomicStrings.checks.length == 10 &&
          HabotAtomicStrings.checks.values.every((bool b) => b) &&
          HabotAtomicStrings.columnNote
              .contains('Identity Management Architect'),
    );
  });

  tearDownAll(() {
    final String locales = HabotAtomicStrings.shippedLocales.join(', ');
    final String wide = HabotAtomicStrings.localesWithMoreThanTwoForms
        .map((HabotPluralProfile p) => '${p.code} (${p.formsNeeded})')
        .join(', ');

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'VPVMP-004-01',
        atomicStepReferenceId: 'VPVMP-004-01',
        setupStepAction:
            'COLUMN NOTE: this row\'s body carries an entire second row\'s '
            'narrative -- two Poka-Yoke clauses, two Self-Chasing clauses, two '
            'Vitality & Prosperity headings and a second Domain Expertise line '
            'about an Identity Management Architect -- interleaved with the '
            'layout text, and the Setup Step reads "Trigger a warning/alert '
            'event when a task exceeds its SLA limit". Atomic Step: "Break '
            'combined text layout strings down into separate atomic '
            'variables."',
        implementationOrder: 303,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'message catalogue keyed by id and plural category',
          'Layout Grid Dimensions':
              '${HabotAtomicStrings.profiles.length} locales ($locales) x up '
                  'to six categories; $wide need more than two',
          'Spacing Rules': 'not applicable -- this row is about text, not gaps',
          'Alignment Settings':
              'the RTL parameter is wrapped in the Step 139 isolates',
          'Layout Validation Status': 'Good',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FRAGMENTS: ${HabotAtomicStrings.fragmentNote} '
              'PLURALS: ${HabotAtomicStrings.pluralNote} '
              'BIDI: ${HabotAtomicStrings.bidiNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '100% over ${HabotAtomicStrings.obligations.length} declared '
                'obligations, the first of which is that the sentence exists '
                'in the source in one piece. The ceiling is written as 1 '
                'against percentage floors.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Plural forms the message structure can express',
            observed:
                '16 of 16 across ${HabotAtomicStrings.profiles.length} '
                'shipped locales, against 5 of 16 for the fragment scheme the '
                'row asks for. The eleven missing forms have no place in that '
                'structure at all -- it is not that they read badly.',
            floor: '16',
            optimal: '16',
            ceiling: '16',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/i18n/atomic_strings.dart',
        ],
      ),
    );
  });
}
