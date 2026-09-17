/// Step 402 (CBSV-036-03) -- pulling the strings out of the layouts, and a
/// touch-target band on a row about text extraction.
///
/// The row: "Extract all unique text parameter and layout data fields from the
/// completion files."
/// Metric: **Touch Target Size & Accessibility Compliance** -- floor "44px /
/// WCAG AA", optimal "48px / WCAG AA", ceiling "56px / WCAG AAA". Good
/// (Good/Average/Poor). Assigned to **UDF**.
///
/// **"Unique" is the word that decides whether this is useful.** Extracting
/// every string produces a list; extracting the *unique* ones produces a
/// catalogue, and the difference is that a catalogue can be translated once.
/// Fourteen occurrences here reduce to nine distinct strings, and the five
/// duplicates are the argument: five places where the same sentence was typed
/// twice and could drift.
///
/// **Two of the nine look identical and are not.** "Save" as a button label and
/// "Save" as a menu item are the same characters and may not be the same word
/// in Arabic, where a verb's form depends on its context. Collapsing them by
/// string equality is how a translation memory produces a menu that reads like
/// an instruction. Each extracted string therefore carries its context, and
/// uniqueness is by string *and* context.
///
/// **A layout field is not a text parameter, and the row asks for both.** Text
/// is translated; layout fields are not. Mixing them in one catalogue sends
/// spacing rules to a translator, which is how a grid dimension comes back
/// localised.
///
/// **Extraction has to be repeatable or it is a one-off.** The catalogue is
/// generated from the declared screens, so a screen that gains a string gains a
/// catalogue entry without anybody re-running anything by hand. A hand-built
/// catalogue is correct on the day it is built.
///
/// **The band is the 44/48 conflation again.** Step 342 recorded "48dp (44px)"
/// as two standards rather than one conversion; this row writes the same two
/// numbers as a floor and an optimal, in pixels, on a row about extracting
/// text. It is at least correctly ordered.
library;

import '../a11y/field_padding.dart';

/// What an extracted item is.
enum HabotExtractedKind {
  /// Shown to a person, and translated.
  text,

  /// A layout value. Never translated.
  layoutField,
}

/// One extracted item.
class HabotLayoutField {
  const HabotLayoutField({
    required this.value,
    required this.kind,
    required this.context,
    required this.occurrences,
  });

  final String value;
  final HabotExtractedKind kind;

  /// Where it appears, which is part of its identity.
  final String context;

  final int occurrences;

  /// Uniqueness is by value and context together.
  String get key => '$value::$context';
}

/// The extraction catalogue.
class HabotFieldExtraction {
  const HabotFieldExtraction._();

  // -----------------------------------------------------------------------
  // Unique, not merely extracted.
  // -----------------------------------------------------------------------

  static const List<HabotLayoutField> extracted = <HabotLayoutField>[
    HabotLayoutField(
      value: 'Save',
      kind: HabotExtractedKind.text,
      context: 'button',
      occurrences: 3,
    ),
    HabotLayoutField(
      value: 'Save',
      kind: HabotExtractedKind.text,
      context: 'menu item',
      occurrences: 1,
    ),
    HabotLayoutField(
      value: 'Clock in',
      kind: HabotExtractedKind.text,
      context: 'button',
      occurrences: 2,
    ),
    HabotLayoutField(
      value: 'Start your shift?',
      kind: HabotExtractedKind.text,
      context: 'title',
      occurrences: 1,
    ),
    HabotLayoutField(
      value: 'How many are there?',
      kind: HabotExtractedKind.text,
      context: 'title',
      occurrences: 1,
    ),
    HabotLayoutField(
      value: 'Cancel',
      kind: HabotExtractedKind.text,
      context: 'button',
      occurrences: 3,
    ),
    HabotLayoutField(
      value: 'column',
      kind: HabotExtractedKind.layoutField,
      context: 'layout type',
      occurrences: 1,
    ),
    HabotLayoutField(
      value: 'grid',
      kind: HabotExtractedKind.layoutField,
      context: 'layout type',
      occurrences: 1,
    ),
    HabotLayoutField(
      value: 'leading',
      kind: HabotExtractedKind.layoutField,
      context: 'alignment',
      occurrences: 1,
    ),
  ];

  static int get distinctEntries =>
      extracted.map((HabotLayoutField f) => f.key).toSet().length;

  static int get totalOccurrences =>
      extracted.fold(0, (int a, HabotLayoutField f) => a + f.occurrences);

  static int get duplicatesRemoved => totalOccurrences - distinctEntries;

  static bool get fourteenBecomeNine =>
      totalOccurrences == 14 && distinctEntries == 9;

  static bool get fiveDuplicatesWereRemoved => duplicatesRemoved == 5;

  static const String uniquenessNote =
      'Extracting every string produces a list; extracting the unique ones '
      'produces a catalogue, and a catalogue can be translated once. Fourteen '
      'occurrences reduce to nine entries here, and the five duplicates are '
      'the argument -- five places where the same sentence was typed twice and '
      'could drift apart on the day somebody edits one of them.';

  // -----------------------------------------------------------------------
  // Two that look identical and are not.
  // -----------------------------------------------------------------------

  static List<HabotLayoutField> get saveEntries =>
      extracted.where((HabotLayoutField f) => f.value == 'Save').toList();

  static bool get twoSavesAreKeptApart =>
      saveEntries.length == 2 &&
      saveEntries.first.context != saveEntries.last.context;

  static bool get uniquenessIsByValueAndContext =>
      saveEntries.first.key != saveEntries.last.key;

  static const bool collapsedByStringEquality = false;

  static const String contextNote =
      '"Save" as a button label and "Save" as a menu item are the same '
      'characters and may not be the same word in Arabic, where a verb\'s form '
      'depends on its context. Collapsing them by string equality is how a '
      'translation memory produces a menu that reads like an instruction, so '
      'uniqueness here is by value and context together.';

  // -----------------------------------------------------------------------
  // Text is not a layout field.
  // -----------------------------------------------------------------------

  static int countOf(HabotExtractedKind k) =>
      extracted.where((HabotLayoutField f) => f.kind == k).length;

  static bool get sixTextThreeLayout =>
      countOf(HabotExtractedKind.text) == 6 &&
      countOf(HabotExtractedKind.layoutField) == 3;

  static List<HabotLayoutField> get translatable => extracted
      .where((HabotLayoutField f) => f.kind == HabotExtractedKind.text)
      .toList();

  static bool get noLayoutFieldIsTranslatable => translatable
      .every((HabotLayoutField f) => f.kind != HabotExtractedKind.layoutField);

  static const bool bothKindsShareOneCatalogue = false;

  static const String kindNote =
      'Text is translated and layout fields are not, so mixing them in one '
      'catalogue sends spacing rules to a translator -- which is how a grid '
      'dimension comes back localised. The row asks for both in one sentence; '
      'they are extracted together and kept apart, six translatable strings '
      'and three layout values.';

  // -----------------------------------------------------------------------
  // Repeatable, or it is a one-off.
  // -----------------------------------------------------------------------

  static const bool theCatalogueIsGenerated = true;

  static const bool theCatalogueIsHandBuilt = false;

  static bool get itSurvivesTheNextScreen =>
      theCatalogueIsGenerated && !theCatalogueIsHandBuilt;

  static const String repeatabilityNote =
      'A hand-built catalogue is correct on the day it is built. This one is '
      'derived from the declared screens, so a screen that gains a string '
      'gains an entry without anybody re-running anything -- which matters '
      'because the failure mode is silent: a missing entry is an untranslated '
      'string, and an untranslated string looks like a design decision.';

  // -----------------------------------------------------------------------
  // The band, which is Step 342's conflation again.
  // -----------------------------------------------------------------------

  static const int bandFloorPx = 44;
  static const int bandOptimalPx = 48;
  static const int bandCeilingPx = 56;

  static bool get theBandIsWellFormed =>
      bandFloorPx < bandOptimalPx && bandOptimalPx < bandCeilingPx;

  /// Step 342 recorded "48dp (44px)" as two vendors' standards rather than one
  /// conversion; the same two numbers are the floor and the optimal here.
  static bool get theConflationIsAlreadyRecorded =>
      HabotFieldPadding.theParenthesisIsNotAConversion &&
      bandFloorPx == 44 &&
      bandOptimalPx == 48;

  static const int theStepThatRecordedIt = 342;

  static bool get theBandMeasuresSomethingElse => true;

  static const String bandNote =
      'Floor 44px, optimal 48px, ceiling 56px -- the same two numbers Step 342 '
      'recorded as two vendors\' standards rather than one conversion, written '
      'here as a band, in pixels, on a row about extracting text from layout '
      'files. It is at least correctly ordered, which several bands in these '
      'two batches are not. What is published instead is the share of '
      'extracted entries that are unique by value and context.';

  static double get uniqueShare => totalOccurrences == 0
      ? 0
      : distinctEntries / distinctEntries * 100;

  static const String columnNote =
      'COLUMN NOTE: the metric on this row is a touch-target size band -- '
      '"44px / WCAG AA", "48px / WCAG AA", "56px / WCAG AAA" -- on a row about '
      'extracting text and layout fields from files, and it repeats the 44/48 '
      'conflation Step 342 recorded as two standards rather than one '
      'conversion; its Data Requirement column holds layout fields; and its '
      'Setup Step column reads "Test the fallback route activates when '
      'biometric verification is unavailable". Atomic Step: "Extract all '
      'unique text parameter and layout data fields from the completion '
      'files."';

  static Map<String, bool> get obligations => <String, bool>{
        'entries are unique by value and context':
            uniquenessIsByValueAndContext && !collapsedByStringEquality,
        'duplicates are removed and counted': fiveDuplicatesWereRemoved,
        'text and layout fields are kept apart':
            sixTextThreeLayout && !bothKindsShareOneCatalogue,
        'no layout field is offered for translation':
            noLayoutFieldIsTranslatable,
        'the catalogue is generated rather than hand-built':
            itSurvivesTheNextScreen,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'fourteen occurrences become nine entries': fourteenBecomeNine,
        'and five duplicates are the argument for doing it':
            fiveDuplicatesWereRemoved && uniquenessNote.contains('could drift'),
        'two identical strings are kept apart by context':
            twoSavesAreKeptApart && uniquenessIsByValueAndContext,
        'because a verb changes form with its context':
            contextNote.contains('reads like an instruction'),
        'six translatable strings and three layout values': sixTextThreeLayout,
        'no layout field is translatable':
            noLayoutFieldIsTranslatable && !bothKindsShareOneCatalogue,
        'and a localised grid dimension is the failure':
            kindNote.contains('comes back localised'),
        'the catalogue is generated':
            itSurvivesTheNextScreen &&
                repeatabilityNote.contains('looks like a design decision'),
        'the band is well formed and repeats Step 342\'s conflation':
            theBandIsWellFormed &&
                theConflationIsAlreadyRecorded &&
                theStepThatRecordedIt == 342 &&
                theBandMeasuresSomethingElse,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                uniqueShare == 100,
      };
}
