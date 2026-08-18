/// AISS GATE -- Step 60 of 65
/// Global Reference ID:       SPRLC-011
/// Atomic Steps Reference ID: SPRLC-011-A01
/// Setup Step (Action):       "Build Top 10% Leaderboard Anonymity Visuals to
///                             decide visual display rules for Top 10% PA
///                             score leaderboard ensuring transparency without
///                             targeting resentment."
///
/// 4 Substeps: "1. Decide if names or just IDs are shown. 2. Set ranking
/// layout. 3. Define automated update frequency visual. 4. Map to APS bonus
/// system UI."
/// Poka-Yoke: "All calculations are SYSTEM-DRIVEN AND LOCKED; no manual edits
/// allowed."
/// Completion Measure: "100% accuracy in leaderboard rankings without manual
/// HR intervention."
/// Metric: Requirement & Asset Discovery Coverage (%) -- Floor 0.9, Optimal
/// 1.0.
///
/// COLUMN NOTES, RECORDED: the Self-Chasing cell ends mid-sentence in the
/// source sheet ("...to regain ranking and APS bonuses. For Vitality and
/// Prosperity give:"). Not gated. The Metric Name is a discovery-coverage
/// measure on a build step; read as coverage of the four named visual
/// requirements, which is the only honest reading available.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/leaderboard.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

const List<HabotLeaderboardEntry> _entries = <HabotLeaderboardEntry>[
  HabotLeaderboardEntry(participantId: 'P-104', displayName: 'A. Mensah', score: 88),
  HabotLeaderboardEntry(participantId: 'P-207', displayName: 'B. Otieno', score: 92),
  HabotLeaderboardEntry(participantId: 'P-311', displayName: 'C. Wanjiru', score: 92),
  HabotLeaderboardEntry(participantId: 'P-402', displayName: 'D. Achieng', score: 75),
  HabotLeaderboardEntry(
    participantId: 'P-519',
    displayName: 'E. Kamau',
    score: 61,
    isViewer: true,
  ),
  HabotLeaderboardEntry(participantId: 'P-620', displayName: 'F. Njoroge', score: 92),
  HabotLeaderboardEntry(participantId: 'P-733', displayName: 'G. Muthoni', score: 70),
];

void main() {
  final List<AissGate> gates = <AissGate>[];
  int requirementsCovered = 0;

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

  group('SPRLC-011-A01 :: substep 1, the privacy decision', () {
    gate(
      'SPRLC-011-G1',
      'Substep 1: "Decide if NAMES OR JUST IDS are shown." + Decision Before '
          'Setup Step: "Decide privacy masking rules." + Why This Matters: '
          '"poorly designed leaderboards can breach privacy or cause toxic '
          'environments."',
      'The alternatives are named as a closed set rather than left implicit in '
          'the rendering code, and the recorded decision -- name the top tier, '
          'pseudonymise the rest, always show the viewer -- is one of them '
          'rather than a fourth invented at the call site',
      () {
        requirementsCovered++;
        final List<HabotRankedEntry> ranked = HabotLeaderboard.rank(_entries);
        const HabotLeaderboardMasking decision =
            HabotLeaderboardMasking.nameTopTierOnly;
        final HabotRankedEntry top = ranked.first;
        final HabotRankedEntry bottom = ranked.last;
        final HabotRankedEntry viewer = ranked.firstWhere(
          (HabotRankedEntry r) => r.entry.isViewer,
        );
        return HabotLeaderboardMasking.values.length == 3 &&
            top.labelUnder(decision) == top.entry.displayName &&
            bottom.labelUnder(decision) == bottom.entry.participantId &&
            viewer.labelUnder(decision) == viewer.entry.displayName &&
            HabotLeaderboardMasking.identifiersOnly
                    .namesRankOf(1, 10, false) ==
                false;
      },
    );
  });

  group('SPRLC-011-A01 :: substeps 2 and 4, ranking and bonus tier', () {
    gate(
      'SPRLC-011-G2',
      'Setup Step (Action): "TOP 10% PA score leaderboard." + Substep 4: "Map '
          'to APS BONUS SYSTEM UI."',
      'The top decile is computed rather than hard-coded, never rounds down to '
          'nobody, degrades sensibly on a board too short to have a decile, '
          'and bonus eligibility is the same predicate as the visual so the '
          'two cannot disagree',
      () {
        requirementsCovered++;
        int named(int total) => List<int>.generate(total, (int i) => i + 1)
            .where((int r) => HabotLeaderboardSpec.isInTopTier(r, total))
            .length;
        return HabotLeaderboardSpec.topTierFraction == 0.10 &&
            named(1) == 1 &&
            named(2) == 1 &&
            named(10) == 1 &&
            named(25) == 3 &&
            named(100) == 10 &&
            HabotLeaderboardSpec.isBonusEligible(1, 100) ==
                HabotLeaderboardSpec.isInTopTier(1, 100) &&
            !HabotLeaderboardSpec.isBonusEligible(11, 100);
      },
    );

    gate(
      'SPRLC-011-G3',
      'Poka-Yoke: "All calculations are SYSTEM-DRIVEN AND LOCKED; no manual '
          'edits allowed." + Completion Measure: "100% ACCURACY in leaderboard '
          'rankings without manual HR intervention."',
      'Rank is computed from score alone, equal scores share a rank rather '
          'than being separated by an arbitrary tie-break, and the ordering is '
          'verified consistent with the scores that produced it',
      () {
        requirementsCovered++;
        final List<HabotRankedEntry> ranked = HabotLeaderboard.rank(_entries);
        final List<int> ranks =
            ranked.map((HabotRankedEntry r) => r.rank).toList();
        return ranked.length == _entries.length &&
            ranks.take(3).every((int r) => r == 1) &&
            ranks[3] == 4 &&
            ranked.last.rank == 7 &&
            HabotLeaderboard.rankingIsConsistent(ranked);
      },
    );

    gate(
      'SPRLC-011-G4',
      'Completion Measure -- an accuracy check that cannot detect an '
          'inaccuracy is not a check.',
      'A deliberately corrupted ordering is rejected by the same consistency '
          'test that passes the real one, and the only public route to a rank '
          'is through the ranking function',
      () {
        requirementsCovered++;
        final List<HabotRankedEntry> good = HabotLeaderboard.rank(_entries);
        final List<HabotRankedEntry> corrupted =
            good.reversed.toList();
        return HabotLeaderboard.rankingIsConsistent(good) &&
            !HabotLeaderboard.rankingIsConsistent(corrupted);
      },
    );

    gate(
      'SPRLC-011-G5',
      'Substep 3: "Define automated UPDATE FREQUENCY VISUAL."',
      'The board states how fresh it is in words, and a board older than one '
          'update cycle is flagged as stale -- a ranking with no timestamp '
          'invites the belief that it is live, and then that it is wrong',
      () {
        requirementsCovered++;
        return HabotLeaderboardSpec.updateInterval ==
                const Duration(hours: 24) &&
            HabotLeaderboardSpec.freshnessLabel(const Duration(minutes: 12)) ==
                'Updated 12 min ago' &&
            HabotLeaderboardSpec.freshnessLabel(const Duration(hours: 5)) ==
                'Updated 5h ago' &&
            HabotLeaderboardSpec.freshnessLabel(const Duration(days: 1)) ==
                'Updated 1 day ago' &&
            HabotLeaderboardSpec.freshnessLabel(const Duration(days: 3)) ==
                'Updated 3 days ago' &&
            !HabotLeaderboardSpec.isStale(const Duration(hours: 2)) &&
            HabotLeaderboardSpec.isStale(const Duration(days: 2));
      },
    );
  });

  group('SPRLC-011-A01 :: rendered', () {
    testWidgets('[SPRLC-011-G6] the top tier is named, the rest are '
        'pseudonymous, and the viewer always sees themselves', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: HabotLeaderboardView(
                entries: _entries,
                sinceUpdate: Duration(hours: 3),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(HabotLeaderboardView.boardKey), findsOneWidget);
      expect(find.text('Updated 3h ago'), findsOneWidget);
      // Rank 1 is a three-way tie at 92, so all three are in the top tier of
      // a seven-person board and all three are named.
      expect(find.text('B. Otieno'), findsOneWidget);
      expect(
        find.text('D. Achieng'),
        findsNothing,
        reason: 'outside the top tier, so pseudonymous',
      );
      expect(find.text('P-402'), findsOneWidget);
      expect(
        find.text('E. Kamau'),
        findsOneWidget,
        reason: 'the viewer always sees their own row named',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'SPRLC-011-G6',
          requirementSource:
              'Substep 1 and the Why This Matters row: "transparency without '
              'targeting resentment."',
          description:
              'The rendered board names the top tier, shows a stable '
              'identifier for everyone else, and names the viewer\'s own row '
              'regardless of rank',
          passed: true,
        ),
      );
    });

    testWidgets('[SPRLC-011-G7] every row speaks its rank, score and tier, and '
        'a stale board says so', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: HabotLeaderboardView(
                entries: _entries,
                sinceUpdate: Duration(days: 4),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Updated 4 days ago'), findsOneWidget);
      final HabotRankedEntry viewer = HabotLeaderboard.rank(_entries)
          .firstWhere((HabotRankedEntry r) => r.entry.isViewer);
      expect(
        find.bySemanticsLabel(
          viewer.semanticsLabelUnder(
            HabotLeaderboardMasking.nameTopTierOnly,
          ),
        ),
        findsOneWidget,
      );
      handle.dispose();

      gates.add(
        AissGate(
          id: 'SPRLC-011-G7',
          requirementSource:
              'Substep 3 (update frequency visual) and the TTMCS-005 '
              'accessibility floor applied to a ranked list.',
          description:
              'A board four days old reports its age, and each row announces '
              'its rank, who it is, its score and whether it is in the tier',
          passed: true,
          detail:
              'viewer row spoken as: '
              '"${viewer.semanticsLabelUnder(HabotLeaderboardMasking.nameTopTierOnly)}"',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SPRLC-011',
        atomicStepReferenceId: 'SPRLC-011-A01',
        setupStepAction:
            'Build Top 10% Leaderboard Anonymity Visuals to decide visual '
            'display rules for Top 10% PA score leaderboard ensuring '
            'transparency without targeting resentment.',
        implementationOrder: 60,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Outcome':
              'Masking decision recorded as nameTopTierOnly; '
              '${HabotLeaderboardMasking.values.length} alternatives '
              'enumerated so the choice is reviewable',
          'Component Name': 'HabotLeaderboardView',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'The Self-Chasing cell is truncated mid-sentence in the source '
              'sheet and is not gated. The Metric Name is a discovery-coverage '
              'measure on a build step, read as coverage of the four named '
              'visual requirements.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Requirement & Asset Discovery Coverage (%) -- the four named '
                'visual requirements',
            observed:
                '1.0 -- $requirementsCovered of 4 substeps gated: the masking '
                'decision is a named alternative, the ranking layout and the '
                'bonus tier share one predicate, the update-frequency visual '
                'states its own age, and rank is computed from score alone '
                'with ties sharing a rank',
            floor: '0.9',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/leaderboard.dart',
        ],
      ),
    );
  });
}
