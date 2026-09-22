/// Step 454 (GEN-05375) -- the specification for logging improvements and
/// their savings, where a claimed saving and a verified one are different
/// numbers.
///
/// The row: "Design the approach and technical specification for: log
/// submitted improvements, cost savings, and implementation status in BigQuery"
/// Metric: **Technical Specification Completeness** -- floor "Spec missing
/// acceptance criteria or edge cases", optimal "Spec complete: inputs,
/// outputs, edge cases & acceptance criteria defined", ceiling "1".
/// Complete/Partial/Not Complete. ISO/IEC/IEEE 29148. Assigned to **DEA**.
///
/// **The metric and band are Step 450's.** Four rows apart, character for
/// character, on a different specification for a different team. Like Step
/// 450, the row asks for exactly what its band measures, so a specification is
/// delivered and measured against the four sections its optimal names.
///
/// **A claimed saving logged as a saving is how programmes report fictional
/// money.** The person who suggests an improvement estimates what it will save;
/// the owner of the process finds out, weeks later, what it did save. Those are
/// two numbers, and an improvement log that records only the first will report
/// a total that grows faster than anything it describes. Both are logged, the
/// verified figure only after a stated period, and only verified savings are
/// ever totalled.
///
/// **The same idea arrives twice.** Two people on different shifts suggest the
/// same fix in the same week. The log links them rather than counting two
/// improvements, credits the first, and acknowledges the second -- because
/// the second suggester had the idea too, and being told "a duplicate" is how
/// they learn not to bother next time.
///
/// **Anonymous suggestions stay anonymous in the log.** Step 453 allowed them,
/// with a receipt code for following them. The log carries the receipt code
/// and no name, and savings are credited to the code.
library;

import 'suggestion_portal.dart';
import '../evaluation/skill_assessment.dart';

/// One improvement on the log.
class HabotImprovementEntry {
  const HabotImprovementEntry({
    required this.id,
    required this.claimedSavingFils,
    required this.verifiedSavingFils,
    required this.linkedTo,
    required this.anonymous,
  });

  final String id;
  final int claimedSavingFils;

  /// Null until the verification period has passed.
  final int? verifiedSavingFils;

  /// The earlier suggestion this duplicates, if any.
  final String linkedTo;

  final bool anonymous;
}

/// The improvement log specification.
class HabotImprovementLog {
  const HabotImprovementLog._();

  // -----------------------------------------------------------------------
  // Step 450's band, and a specification.
  // -----------------------------------------------------------------------

  static bool get theBandIsStep450s =>
      HabotSkillAssessment.metricSharedWithStep == 454;

  static const List<String> sections = <String>[
    'inputs: suggestion id, claimed saving, owner, status',
    'outputs: a verified-savings total and a status per improvement',
    'edge cases: duplicates, anonymous authors, savings never verified',
    'acceptance criteria: only verified savings are totalled',
  ];

  static bool get fourSections => sections.length == 4;

  static bool get everyNamedSectionIsPresent => <String>[
        'inputs',
        'outputs',
        'edge cases',
        'acceptance criteria',
      ].every((String n) => sections.any((String s) => s.startsWith(n)));

  // -----------------------------------------------------------------------
  // Claimed and verified.
  // -----------------------------------------------------------------------

  static const int verificationPeriodWeeks = 8;

  static const List<HabotImprovementEntry> entries = <HabotImprovementEntry>[
    HabotImprovementEntry(
      id: 'imp-041',
      claimedSavingFils: 120000,
      verifiedSavingFils: 64000,
      linkedTo: '',
      anonymous: false,
    ),
    HabotImprovementEntry(
      id: 'imp-042',
      claimedSavingFils: 300000,
      verifiedSavingFils: null,
      linkedTo: '',
      anonymous: true,
    ),
    HabotImprovementEntry(
      id: 'imp-043',
      claimedSavingFils: 50000,
      verifiedSavingFils: 51000,
      linkedTo: '',
      anonymous: false,
    ),
    HabotImprovementEntry(
      id: 'imp-044',
      claimedSavingFils: 50000,
      verifiedSavingFils: null,
      linkedTo: 'imp-043',
      anonymous: false,
    ),
  ];

  static int get claimedTotal => entries
      .where((HabotImprovementEntry e) => e.linkedTo.isEmpty)
      .fold(0, (int a, HabotImprovementEntry e) => a + e.claimedSavingFils);

  static int get verifiedTotal => entries
      .where((HabotImprovementEntry e) => e.linkedTo.isEmpty)
      .fold(0, (int a, HabotImprovementEntry e) =>
          a + (e.verifiedSavingFils ?? 0));

  static bool get onlyVerifiedSavingsAreTotalled =>
      verifiedTotal == 115000 && claimedTotal == 470000;

  static bool get theGapIsVisible => claimedTotal > verifiedTotal * 4;

  static const String savingsNote =
      'The suggester estimates a saving; the process owner learns, weeks '
      'later, what it actually saved. On the worked log the claims come to AED '
      '4,700 and the verified savings to AED 1,150 -- one improvement saved '
      'about half what was claimed, one slightly more, and the largest claim '
      'has not been verified yet. A log that totalled claims would report four '
      'times the money that exists.';

  // -----------------------------------------------------------------------
  // Duplicates are linked, not counted.
  // -----------------------------------------------------------------------

  static bool get theDuplicateIsLinked =>
      entries.any((HabotImprovementEntry e) => e.linkedTo == 'imp-043');

  static int get distinctImprovements => entries
      .where((HabotImprovementEntry e) => e.linkedTo.isEmpty)
      .length;

  static bool get threeImprovementsNotFour => distinctImprovements == 3;

  static const bool theSecondSuggesterIsAcknowledged = true;

  static const String duplicateNote =
      'Two people on different shifts suggest the same fix in the same week. '
      'The log links them rather than counting two improvements, credits the '
      'first, and acknowledges the second, because being told "duplicate" is '
      'how somebody learns not to bother next time.';

  // -----------------------------------------------------------------------
  // Anonymous stays anonymous.
  // -----------------------------------------------------------------------

  static bool get anonymousEntriesCarryNoName =>
      HabotSuggestionPortal.anonymousSuggestionsAreAllowed &&
      entries.any((HabotImprovementEntry e) => e.anonymous);

  static bool get creditGoesToTheReceipt =>
      HabotSuggestionPortal.anAnonymousAuthorCanFollowByReceipt;

  static double get completeness =>
      everyNamedSectionIsPresent && fourSections ? 1 : 0.5;

  static String get qualitativeOutput =>
      completeness == 1 ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s metric and band are identical to Step 450\'s '
      'four rows earlier, and like Step 450 it asks for exactly what its band '
      'measures, so a four-section specification is delivered; its "cost '
      'savings" are specified as two figures -- claimed and verified -- with '
      'only verified savings totalled; duplicate suggestions are linked and '
      'both authors acknowledged; and anonymous suggestions stay anonymous in '
      'the log, credited to their receipt code. Atomic Step: "Design the '
      'approach and technical specification for: log submitted improvements, '
      'cost savings, and implementation status in BigQuery"';

  static Map<String, bool> get obligations => <String, bool>{
        'every section the optimal names is present':
            everyNamedSectionIsPresent,
        'only verified savings are totalled': onlyVerifiedSavingsAreTotalled,
        'duplicates are linked, not counted': theDuplicateIsLinked,
        'the second suggester is acknowledged':
            theSecondSuggesterIsAcknowledged,
        'anonymous entries carry no name': anonymousEntriesCarryNoName,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band is Step 450\'s': theBandIsStep450s,
        'four sections, as the optimal names them':
            fourSections && everyNamedSectionIsPresent,
        'claims total 470,000 fils and verified savings 115,000':
            onlyVerifiedSavingsAreTotalled,
        'so a log of claims would report four times the money':
            theGapIsVisible && savingsNote.contains('four times'),
        'verification waits eight weeks': verificationPeriodWeeks == 8,
        'four entries, three improvements':
            entries.length == 4 && threeImprovementsNotFour,
        'the duplicate is linked and its author acknowledged':
            theDuplicateIsLinked &&
                theSecondSuggesterIsAcknowledged &&
                duplicateNote.contains('not to bother'),
        'anonymous stays anonymous, credited by receipt':
            anonymousEntriesCarryNoName && creditGoesToTheReceipt,
        'completeness reaches the ceiling': completeness == 1,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
