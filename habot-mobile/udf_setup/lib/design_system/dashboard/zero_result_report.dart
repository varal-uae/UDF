/// AISS Step 175 -- GEN-01132
/// Setup Step (Action) / Atomic Step: "Render zero-result search query reports
///   on the catalog operational dashboard."
/// Metric: Dashboard Data Refresh Latency -- Floor "<1 hour",
///         Optimal "<5 minutes", Ceiling "<24 hours". Good / Average / Poor.
///
/// **THE TENSION THIS ROW CONTAINS: THE REPORT IS ONLY USEFUL IF IT SAYS WHAT
/// PEOPLE SEARCHED FOR, AND WHAT PEOPLE TYPE INTO A SEARCH BOX IS THE MOST
/// PERSONAL TEXT IN THE APP.** A zero-result report with the queries removed
/// is a count of failures nobody can act on. A report with the raw queries in
/// it is a warehouse table containing names, addresses, phone numbers and
/// worse, because a search box is where people type anything.
///
/// The resolution is not a compromise, it is a distinction: **a term that is
/// already in the catalogue is public vocabulary, and a term that is not is
/// the user's own words.** So a query is decomposed against the catalogue, the
/// terms that match known vocabulary travel in clear, and the rest travel only
/// as a count and a hash. That gives the catalogue team the thing they
/// actually need — "eleven people searched for a known category we have
/// nothing stocked in" — without ever sending a sentence somebody typed.
///
/// **THE HASH GROUPS REPEATS AND NOTHING ELSE.** Under the Step 157 install
/// salt it cannot be reversed, and because it is per-install the same query
/// from two devices does not collide — which is a deliberate loss. A global
/// hash would group across users and would also be a dictionary attack away
/// from the plaintext.
///
/// **SHAPE FEATURES CARRY MORE THAN THEY LOOK LIKE.** Term count separates a
/// one-word catalogue gap from someone pasting a paragraph; whether filters
/// were active separates "we do not stock it" from "the filters excluded it";
/// and the longest matching prefix says whether the user was close. None of
/// the three is text.
library;

import '../telemetry/event_schema.dart';
import '../telemetry/pii_sanitizer.dart';
import '../tokens/motion_tokens.dart';

/// One zero-result search, reduced to what may travel.
class HabotZeroResultRecord {
  const HabotZeroResultRecord({
    required this.queryHash,
    required this.termCount,
    required this.hadFilters,
    required this.knownTerms,
    required this.longestKnownPrefix,
  });

  /// Groups repeats of the same query on this install. Salted -- see the
  /// header.
  final String queryHash;

  final int termCount;
  final bool hadFilters;

  /// Terms that are already catalogue vocabulary. Public words, so they
  /// travel in clear.
  final List<String> knownTerms;

  /// How many leading characters of the query matched a known term. A high
  /// number on a zero-result search means the user was one letter away.
  final int longestKnownPrefix;

  bool get isEntirelyUnknownVocabulary => knownTerms.isEmpty;

  Map<String, Object?> toRow() => <String, Object?>{
        'query_hash': queryHash,
        'term_count': termCount,
        'had_filters': hadFilters,
        'known_terms': knownTerms.join(' '),
        'longest_known_prefix': longestKnownPrefix,
      };
}

/// Turns a zero-result search into something reportable.
class HabotZeroResultReport {
  const HabotZeroResultReport({required this.catalogueVocabulary});

  /// The terms the catalogue already contains. Public by definition: they are
  /// on category pages and in the app's own navigation.
  final Set<String> catalogueVocabulary;

  /// Reduce one query. **The raw text never leaves this method.**
  HabotZeroResultRecord record({
    required String query,
    required bool hadFilters,
    required String installSalt,
  }) {
    final List<String> terms = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((String t) => t.isNotEmpty)
        .toList();
    final List<String> known =
        terms.where(catalogueVocabulary.contains).toList();
    return HabotZeroResultRecord(
      queryHash: HabotPiiSanitizer.opaqueId(
        query.trim().toLowerCase(),
        installSalt: installSalt,
      ),
      termCount: terms.length,
      hadFilters: hadFilters,
      knownTerms: known,
      longestKnownPrefix: _longestKnownPrefix(terms),
    );
  }

  int _longestKnownPrefix(List<String> terms) {
    int best = 0;
    for (final String term in terms) {
      for (final String known in catalogueVocabulary) {
        int i = 0;
        while (i < term.length && i < known.length && term[i] == known[i]) {
          i++;
        }
        if (i > best) {
          best = i;
        }
      }
    }
    return best;
  }

  /// The event this becomes in the Step 156 stream.
  HabotEvent toEvent(
    HabotZeroResultRecord record, {
    required String view,
    required String traceId,
    required DateTime at,
    required int sessionOrdinal,
  }) =>
      HabotEvent(
        kind: HabotEventKind.searchEmpty,
        view: view,
        traceId: traceId,
        occurredAt: at,
        sessionOrdinal: sessionOrdinal,
        payload: <String, Object?>{
          'query_hash': record.queryHash,
          'term_count': record.termCount,
          'had_filters': record.hadFilters,
        },
      );

  // ---- what the dashboard shows -------------------------------------------

  /// Known catalogue terms that repeatedly return nothing. **The actionable
  /// output**: a category the catalogue has a name for and no stock in.
  static Map<String, int> stockGaps(Iterable<HabotZeroResultRecord> records) {
    final Map<String, int> out = <String, int>{};
    for (final HabotZeroResultRecord r in records) {
      for (final String term in r.knownTerms) {
        out[term] = (out[term] ?? 0) + 1;
      }
    }
    return out;
  }

  /// Searches whose terms the catalogue does not know at all. Counted, not
  /// itemised: this is where the personal text would have been.
  static int unknownVocabularySearches(
    Iterable<HabotZeroResultRecord> records,
  ) =>
      records
          .where((HabotZeroResultRecord r) => r.isEntirelyUnknownVocabulary)
          .length;

  /// Searches that returned nothing WITH filters on. A different problem from
  /// an empty catalogue, and a fixable one.
  static int filterExclusions(Iterable<HabotZeroResultRecord> records) =>
      records.where((HabotZeroResultRecord r) => r.hadFilters).length;

  /// Near misses: a high prefix match and still nothing. Usually a spelling
  /// or a plural the search does not handle.
  static int nearMisses(
    Iterable<HabotZeroResultRecord> records, {
    int minimumPrefix = 4,
  }) =>
      records
          .where((HabotZeroResultRecord r) =>
              r.longestKnownPrefix >= minimumPrefix && r.knownTerms.isEmpty)
          .length;

  /// Distinct queries, by hash. Repeats of one query by one person are one
  /// signal, not twenty.
  static int distinctQueries(Iterable<HabotZeroResultRecord> records) =>
      records.map((HabotZeroResultRecord r) => r.queryHash).toSet().length;

  // ---- the row's metric ---------------------------------------------------

  static Duration get optimal => HabotMotion.dashboardRefreshOptimal;
  static Duration get floor => HabotMotion.dashboardRefreshFloor;
  static Duration get ceiling => HabotMotion.dashboardRefreshCeiling;

  static String bandFor(Duration age) {
    if (age <= optimal) {
      return 'Good';
    }
    if (age <= floor) {
      return 'Average';
    }
    return age <= ceiling ? 'Average' : 'Poor';
  }

  static bool isStale(Duration age) => age > ceiling;

  static const String tensionNote =
      'A zero-result report with the queries removed is a count of failures '
      'nobody can act on. A report with the raw queries in it is a warehouse '
      'table containing names, addresses and phone numbers, because a search '
      'box is where people type anything.';

  static const String vocabularyDistinction =
      'A term already in the catalogue is public vocabulary -- it is on a '
      'category page and in the app\'s own navigation. A term that is not is '
      'the user\'s own words. Known terms travel in clear; the rest travel as '
      'a count and a salted hash. The catalogue team gets what they need '
      '("eleven people searched a known category we have nothing stocked in") '
      'without a sentence somebody typed ever being sent.';

  static const String perInstallHashNote =
      'The hash is per-install, so the same query from two devices does not '
      'collide. That is a deliberate loss: a global hash would group across '
      'users and would also be one dictionary away from the plaintext.';

  static const String shapeFeaturesNote =
      'Term count separates a one-word catalogue gap from someone pasting a '
      'paragraph; whether filters were on separates "we do not stock it" from '
      '"the filters excluded it"; the longest matching prefix says whether the '
      'user was one letter away. None of the three is text.';
}
