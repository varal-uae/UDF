/// AISS: SPRLC-011-A01 -- "Build Top 10% Leaderboard Anonymity Visuals to
/// decide visual display rules for Top 10% PA score leaderboard ensuring
/// transparency without targeting resentment."
///
/// 4 Substeps, verbatim:
///   1. "Decide if names or just IDs are shown."
///   2. "Set ranking layout."
///   3. "Define automated update frequency visual."
///   4. "Map to APS bonus system UI."
///
/// Decision Before Setup Step: "Decide privacy masking rules."
/// Why This Matters: "Gamification requires visibility, but poorly designed
/// leaderboards can breach privacy or cause toxic environments."
/// Poka-Yoke: "All calculations are system-driven and locked; no manual edits
/// allowed."
/// Completion Measure: "100% accuracy in leaderboard rankings without manual
/// HR intervention."
/// Metric: Requirement & Asset Discovery Coverage (%) -- Floor 0.9, Optimal
/// 1.0.
///
/// SUBSTEP 1 IS THE STEP. "Decide if names or just IDs are shown" reads like a
/// configuration question and is actually the whole design: a leaderboard that
/// names the bottom of the list is a different product from one that does not.
///
/// The decision recorded here: THE TOP IS NAMED, THE REST IS NOT, AND YOU
/// ALWAYS SEE YOURSELF. Visibility for the people being celebrated,
/// pseudonymity for everyone else, and a self-row so the feature still answers
/// "where am I?" -- which is the only question most people open it to ask.
/// [HabotLeaderboardMasking] holds the alternatives so the choice is
/// reviewable rather than implicit in the rendering code.
///
/// COLUMN NOTE: this row's Self-Chasing cell ends mid-sentence in the source
/// sheet ("...to regain ranking and APS bonuses. For Vitality and Prosperity
/// give:"). Recorded, not gated. The Metric Name is a discovery-coverage
/// measure on a build step; it is read as coverage of the four named visual
/// requirements, which is the only honest reading available.
library;

import 'package:flutter/material.dart';

import '../feedback/status_badge.dart';
import '../tokens/dashboard_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// Substep 1: the privacy masking rules, as named alternatives.
enum HabotLeaderboardMasking {
  /// Everyone named. Rejected as the default: it publishes a ranking of
  /// colleagues, which is the "targeting resentment" the Setup Step names.
  namesAll,

  /// Nobody named. Rejected as the default: an entirely anonymous board
  /// cannot celebrate anyone, so it fails the transparency half.
  identifiersOnly,

  /// THE DECISION. The top tier is named; everyone below it is a stable
  /// pseudonymous identifier; the viewer always sees their own row named.
  nameTopTierOnly;

  bool namesRankOf(int rank, int total, bool isViewer) {
    if (isViewer) {
      return true;
    }
    switch (this) {
      case HabotLeaderboardMasking.namesAll:
        return true;
      case HabotLeaderboardMasking.identifiersOnly:
        return false;
      case HabotLeaderboardMasking.nameTopTierOnly:
        return HabotLeaderboardSpec.isInTopTier(rank, total);
    }
  }
}

/// One entry. Constructed by the system from a score, never by a caller
/// choosing a rank -- which is the poka-yoke.
@immutable
class HabotLeaderboardEntry {
  const HabotLeaderboardEntry({
    required this.participantId,
    required this.displayName,
    required this.score,
    this.isViewer = false,
  });

  /// The stable pseudonymous identifier shown when the name is masked.
  final String participantId;

  final String displayName;

  /// The performance-assessment score. The only input to the ranking.
  final double score;

  /// True for the row belonging to the person looking at the board.
  final bool isViewer;
}

/// A ranked entry. There is no public constructor that takes a rank: the only
/// way to obtain one is through [HabotLeaderboard.rank], which sorts.
@immutable
class HabotRankedEntry {
  const HabotRankedEntry._({
    required this.entry,
    required this.rank,
    required this.total,
  });

  final HabotLeaderboardEntry entry;

  /// 1-based.
  final int rank;

  final int total;

  bool get isInTopTier => HabotLeaderboardSpec.isInTopTier(rank, total);

  String labelUnder(HabotLeaderboardMasking masking) =>
      masking.namesRankOf(rank, total, entry.isViewer)
          ? entry.displayName
          : entry.participantId;

  String semanticsLabelUnder(HabotLeaderboardMasking masking) {
    final String who = entry.isViewer ? 'You' : labelUnder(masking);
    final String tier = isInTopTier ? ', in the top tier' : '';
    return 'Rank $rank of $total, $who, score '
        '${score == score.roundToDouble() ? score.round() : score.toStringAsFixed(1)}'
        '$tier';
  }

  double get score => entry.score;
}

/// Substeps 2 and 4: the ranking layout, and the bonus-tier mapping.
class HabotLeaderboardSpec {
  const HabotLeaderboardSpec._();

  /// "Top 10%" -- from the Setup Step itself.
  static const double topTierFraction = 0.10;

  /// A board this short has no meaningful top decile, so the tier is the top
  /// entry alone rather than a rounding artefact.
  static const int minimumBoardSize = 3;

  /// Substep 4: "Map to APS bonus system UI." Being in the top tier is what
  /// the bonus keys off, so it is one predicate used by both the visual and
  /// the eligibility statement, not two that could disagree.
  static bool isInTopTier(int rank, int total) {
    if (total < minimumBoardSize) {
      return rank == 1;
    }
    final int cutoff = (total * topTierFraction).ceil();
    return rank <= (cutoff < 1 ? 1 : cutoff);
  }

  static bool isBonusEligible(int rank, int total) => isInTopTier(rank, total);

  /// Substep 2: row layout.
  static const double rowHeight = 56;
  static const double avatarSize = HabotSpacing.xl;
  static const double rankColumnWidth = HabotSpacing.xxl;

  /// Substep 3: "Define automated update FREQUENCY visual." The board says how
  /// fresh it is, because a ranking with no timestamp invites the belief that
  /// it is live -- and then the belief that it is wrong.
  static const Duration updateInterval = Duration(hours: 24);

  static String freshnessLabel(Duration sinceUpdate) {
    if (sinceUpdate.inMinutes < 60) {
      return 'Updated ${sinceUpdate.inMinutes} min ago';
    }
    if (sinceUpdate.inHours < 24) {
      return 'Updated ${sinceUpdate.inHours}h ago';
    }
    final int days = sinceUpdate.inDays;
    return 'Updated $days day${days == 1 ? '' : 's'} ago';
  }

  /// True when the board is older than one update cycle and should say so
  /// more loudly than usual.
  static bool isStale(Duration sinceUpdate) => sinceUpdate > updateInterval;

  /// The avatar initial. A guarded first character: an empty display name is a
  /// data problem, not a reason for the board to throw.
  static String initialOf(String label) =>
      label.isEmpty ? '?' : label.characters.first.toUpperCase();
}

/// The ranking engine.
class HabotLeaderboard {
  const HabotLeaderboard._();

  /// Poka-Yoke: "All calculations are SYSTEM-DRIVEN AND LOCKED; no manual
  /// edits allowed."
  ///
  /// Rank is computed here from score and nowhere else. Equal scores share a
  /// rank -- competition ranking -- because breaking a tie arbitrarily is a
  /// manual edit wearing a sort function's clothes.
  static List<HabotRankedEntry> rank(List<HabotLeaderboardEntry> entries) {
    final List<HabotLeaderboardEntry> sorted =
        List<HabotLeaderboardEntry>.from(entries)
          ..sort((HabotLeaderboardEntry a, HabotLeaderboardEntry b) =>
              b.score.compareTo(a.score));
    final int total = sorted.length;
    final List<HabotRankedEntry> out = <HabotRankedEntry>[];
    int rank = 0;
    double? lastScore;
    for (int i = 0; i < sorted.length; i++) {
      if (lastScore == null || sorted[i].score != lastScore) {
        rank = i + 1;
        lastScore = sorted[i].score;
      }
      out.add(
        HabotRankedEntry._(entry: sorted[i], rank: rank, total: total),
      );
    }
    return out;
  }

  /// Completion Measure: "100% accuracy in leaderboard rankings without manual
  /// HR intervention." Accuracy here means the ranking agrees with the scores:
  /// no entry outranks a higher-scoring one.
  static bool rankingIsConsistent(List<HabotRankedEntry> ranked) {
    for (int i = 1; i < ranked.length; i++) {
      if (ranked[i].score > ranked[i - 1].score) {
        return false;
      }
      if (ranked[i].rank < ranked[i - 1].rank) {
        return false;
      }
    }
    return true;
  }
}

/// The board.
class HabotLeaderboardView extends StatelessWidget {
  const HabotLeaderboardView({
    required this.entries,
    required this.sinceUpdate,
    this.masking = HabotLeaderboardMasking.nameTopTierOnly,
    super.key,
  });

  final List<HabotLeaderboardEntry> entries;

  /// How long since the scores were recomputed. Substep 3.
  final Duration sinceUpdate;

  final HabotLeaderboardMasking masking;

  static const Key boardKey = Key('habot.leaderboard');
  static const Key freshnessKey = Key('habot.leaderboard.freshness');
  static Key rowKeyFor(String participantId) =>
      Key('habot.leaderboard.$participantId');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<HabotRankedEntry> ranked = HabotLeaderboard.rank(entries);
    return Column(
      key: boardKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: HabotSpacing.xxs),
          child: Text(
            HabotLeaderboardSpec.freshnessLabel(sinceUpdate),
            key: HabotLeaderboardView.freshnessKey,
            style: theme.textTheme.labelSmall?.copyWith(
              color: HabotLeaderboardSpec.isStale(sinceUpdate)
                  ? HabotStatuses.onContainerColor(
                      theme.colorScheme,
                      HabotStatusRole.warning,
                    )
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final HabotRankedEntry row in ranked)
          _LeaderboardRow(row: row, masking: masking),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.row, required this.masking});

  final HabotRankedEntry row;
  final HabotLeaderboardMasking masking;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool highlight = row.entry.isViewer;
    return Semantics(
      key: HabotLeaderboardView.rowKeyFor(row.entry.participantId),
      label: row.semanticsLabelUnder(masking),
      container: true,
      excludeSemantics: true,
      child: Container(
        height: HabotLeaderboardSpec.rowHeight,
        padding: const EdgeInsets.symmetric(vertical: HabotSpacing.xxs),
        color: highlight
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.transparent,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: HabotLeaderboardSpec.rankColumnWidth,
              child: Text(
                '${row.rank}',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            CircleAvatar(
              radius: HabotLeaderboardSpec.avatarSize / 2,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Text(
                HabotLeaderboardSpec.initialOf(row.labelUnder(masking)),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: HabotSpacing.xs),
            Expanded(
              child: Text(
                row.labelUnder(masking),
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (row.isInTopTier)
              Padding(
                padding: const EdgeInsets.only(right: HabotSpacing.xxs),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  size: HabotDashboardTokens.chipIconSize,
                  color: HabotStatuses.onContainerColor(
                    theme.colorScheme,
                    HabotStatusRole.success,
                  ),
                ),
              ),
            Text(
              row.score == row.score.roundToDouble()
                  ? row.score.round().toString()
                  : row.score.toStringAsFixed(1),
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
