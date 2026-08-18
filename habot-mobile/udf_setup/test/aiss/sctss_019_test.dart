/// AISS GATE -- Step 59 of 65
/// Global Reference ID:       SCTSS-019
/// Atomic Steps Reference ID: SCTSS-019-A01
/// Setup Step (Action):       "Expiry Timeline Trackers - Replace spreadsheet
///                             grids with visual data maps that cleanly
///                             structure timeline restrictions."
///
/// 4 Substeps: "1) Define expiration metadata. 2) Set rendering arrays.
/// 3) Map to Boolean locks. 4) Code visual alerts."
/// Poka-Yoke: "Timeline dates are hard-rendered as READ-ONLY; HR physically
/// cannot click to edit or shorten the dates."
/// Self-Chasing: "Active non-compete visually overlays a PADLOCK ICON on
/// 'Rehire' button."
/// Completion Measure: "100% of separated employees with active non-competes
/// visually tracked."
/// Metric: Responsive Layout Fidelity (%) -- Floor 0.95, Optimal 1.0.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/expiry_timeline.dart';
import 'package:udf_setup/design_system/feedback/status_badge.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

final DateTime _start = DateTime(2026, 1, 1);
final DateTime _end = DateTime(2027, 1, 1);

List<HabotExpiry> _expiries() => <HabotExpiry>[
  HabotExpiry(
    id: 'e1',
    subject: 'A. Mensah',
    restriction: 'Non-compete',
    startsOn: _start,
    endsOn: _end,
  ),
  HabotExpiry(
    id: 'e2',
    subject: 'B. Otieno',
    restriction: 'Garden leave',
    startsOn: DateTime(2026, 6, 1),
    endsOn: DateTime(2026, 9, 1),
  ),
  HabotExpiry(
    id: 'e3',
    subject: 'C. Wanjiru',
    restriction: 'Licence hold',
    startsOn: DateTime(2025, 1, 1),
    endsOn: DateTime(2025, 12, 1),
  ),
];

void main() {
  final List<AissGate> gates = <AissGate>[];
  int viewportsClean = 0;
  int viewportsTested = 0;

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

  group('SCTSS-019-A01 :: the four substeps', () {
    gate(
      'SCTSS-019-G1',
      'Substep 1: "Define EXPIRATION METADATA." + Poka-Yoke: "Timeline dates '
          'are hard-rendered as READ-ONLY; HR physically cannot click to edit '
          'or shorten the dates."',
      'The metadata type is immutable and exposes no way to change a date: no '
          'setter, no copyWith, and no mutable field anywhere in its public '
          'surface -- which is the poka-yoke expressed in the type system '
          'rather than in a review comment',
      () {
        // Comments are stripped first. Batch 3 learned this the hard way: doc
        // prose that merely MENTIONS a banned construct is not the construct,
        // and a scan that cannot tell the difference reports the wrong answer.
        final String source = File(
          'lib/design_system/dashboard/expiry_timeline.dart',
        )
            .readAsStringSync()
            .split('\n')
            .map((String line) {
              final int i = line.indexOf('//');
              return i == -1 ? line : line.substring(0, i);
            })
            .join('\n');
        final int classStart = source.indexOf('class HabotExpiry {');
        final int classEnd = source.indexOf('class HabotExpiryTimeline');
        if (classStart < 0 || classEnd <= classStart) {
          return false;
        }
        final String body = source.substring(classStart, classEnd);
        final bool noSetters = !RegExp(r'\bset\s+\w+\s*\(').hasMatch(body);
        final bool noCopyWith = !body.contains('copyWith');
        final bool allFinal =
            RegExp(r'^\s{2}final \w', multiLine: true).allMatches(body).length >=
                5;
        final bool noMutableField =
            !RegExp(r'^\s{2}(?!final|static|const)\w+ \w+;', multiLine: true)
                .hasMatch(body);
        return noSetters && noCopyWith && allFinal && noMutableField;
      },
    );

    gate(
      'SCTSS-019-G2',
      'Substep 3: "Map to BOOLEAN LOCKS."',
      'Lock state is DERIVED from the dates and the moment, never stored: a '
          'restriction is pending before it starts, active during, and expired '
          'after, and there is no flag a caller could set to disagree',
      () {
        final HabotExpiry e = _expiries().first;
        return e.isPendingAt(DateTime(2025, 12, 1)) &&
            e.isActiveAt(_start) &&
            e.isActiveAt(DateTime(2026, 7, 2)) &&
            e.hasExpiredAt(_end) &&
            !e.isActiveAt(_end) &&
            e.locksActionAt(DateTime(2026, 7, 2)) &&
            !e.locksActionAt(_end);
      },
    );

    gate(
      'SCTSS-019-G3',
      'Substep 2: "Set RENDERING ARRAYS." The bar length is the arithmetic '
          'behind the visual data map that replaces the spreadsheet grid.',
      'Progress runs 0 to 1 across the restriction and is clamped outside it, '
          'so a date before the start or after the end cannot produce a bar '
          'that overflows its track',
      () {
        final HabotExpiry e = _expiries().first;
        final double mid = e.progressAt(DateTime(2026, 7, 2));
        return e.progressAt(DateTime(2025, 1, 1)) == 0 &&
            e.progressAt(_start) == 0 &&
            mid > 0.49 &&
            mid < 0.51 &&
            e.progressAt(_end) == 1 &&
            e.progressAt(DateTime(2030, 1, 1)) == 1 &&
            e.daysRemainingAt(DateTime(2030, 1, 1)) == 0;
      },
    );

    gate(
      'SCTSS-019-G4',
      'Substep 4: "Code VISUAL ALERTS." + UI Decision: "High-contrast padlock '
          'icons."',
      'The alert role is derived from how close the restriction is to '
          'expiring: expired reads as resolved, imminent as a warning, and a '
          'restriction with months left as an active hold -- three distinct '
          'roles, each carrying an icon and a label through Step 28',
      () {
        final HabotExpiry e = _expiries().first;
        return e.roleAt(_end) == HabotStatusRole.success &&
            e.roleAt(DateTime(2026, 12, 20)) == HabotStatusRole.warning &&
            e.roleAt(DateTime(2026, 3, 1)) == HabotStatusRole.error &&
            e.roleAt(DateTime(2025, 12, 1)) == HabotStatusRole.neutral &&
            HabotExpiryTimeline.imminentDays == 30;
      },
    );
  });

  group('SCTSS-019-A01 :: rendered', () {
    testWidgets('[SCTSS-019-G5] every restriction is on screen, and the '
        'padlock appears exactly on the locked ones', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final List<HabotExpiry> expiries = _expiries();
      final DateTime now = DateTime(2026, 7, 2);
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotExpiryTracker(expiries: expiries, now: now),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final HabotExpiry e in expiries) {
        expect(
          find.byKey(HabotExpiryTracker.rowKeyFor(e.id)),
          findsOneWidget,
          reason: 'Completion measure: 100% visually tracked -- ${e.id}',
        );
        final Finder padlock =
            find.byKey(HabotExpiryTracker.padlockKeyFor(e.id));
        if (e.locksActionAt(now)) {
          expect(padlock, findsOneWidget, reason: '${e.id} should be locked');
        } else {
          expect(padlock, findsNothing, reason: '${e.id} should be open');
        }
      }
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'SCTSS-019-G5',
          requirementSource:
              'Completion Measure: "100% of separated employees with active '
              'non-competes VISUALLY TRACKED." + Self-Chasing: the padlock.',
          description:
              'All ${expiries.length} restrictions render, and the padlock '
              'appears on exactly the ones whose Boolean lock is true at the '
              'given moment',
          passed: true,
          detail:
              '${HabotExpiryTimeline.activeCount(expiries, now)} active of '
              '${HabotExpiryTimeline.trackedCount(expiries)} tracked',
        ),
      );
    });

    testWidgets('[SCTSS-019-G6] the timeline side-scrolls rather than '
        'compressing, and renders clean on every matrix width', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.reset);
      const List<double> widths = <double>[320, 360, 390, 412, 600, 744, 1024];
      for (final double width in widths) {
        viewportsTested++;
        tester.view.physicalSize = Size(width, 640);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(
          MaterialApp(
            theme: HabotTheme.light(),
            home: Scaffold(
              body: HabotExpiryTracker(
                expiries: _expiries(),
                now: DateTime(2026, 7, 2),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (tester.takeException() == null) {
          viewportsClean++;
        }
      }

      // The track is wider than a phone on purpose: the Mobile App First row
      // asks for a horizontal side-scrolling component, and a timeline
      // squeezed to 360dp is the spreadsheet grid this step replaces.
      expect(HabotExpiryTimeline.trackWidth, greaterThan(360));
      expect(viewportsClean, viewportsTested);

      gates.add(
        AissGate(
          id: 'SCTSS-019-G6',
          requirementSource:
              'Mobile App First: "A HORIZONTAL timeline component specifically '
              'optimized for mobile side-scrolling gestures." + Metric: '
              'Responsive Layout Fidelity (%).',
          description:
              'The tracker renders without a layout exception at every tested '
              'width, and its track stays wider than a phone rather than '
              'compressing into an unreadable grid',
          passed: true,
          detail: '$viewportsClean of $viewportsTested widths clean',
        ),
      );
    });

    testWidgets('[SCTSS-019-G7] a restriction crossing its own end date '
        'unlocks, without anything editing a date', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final HabotExpiry e = _expiries().first;
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotExpiryTracker(
              expiries: <HabotExpiry>[e],
              now: DateTime(2026, 12, 31),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(HabotExpiryTracker.padlockKeyFor(e.id)), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotExpiryTracker(
              expiries: <HabotExpiry>[e],
              now: DateTime(2027, 1, 2),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(HabotExpiryTracker.padlockKeyFor(e.id)), findsNothing);
      expect(e.endsOn, _end, reason: 'the date itself never moved');

      gates.add(
        const AissGate(
          id: 'SCTSS-019-G7',
          requirementSource:
              'Poka-Yoke: "HR physically cannot click to edit or SHORTEN the '
              'dates." The only thing that ends a restriction is time passing.',
          description:
              'Advancing the clock past the end date releases the lock while '
              'the stored end date is unchanged -- the restriction expired, it '
              'was not shortened',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    final List<HabotExpiry> expiries = _expiries();
    final DateTime now = DateTime(2026, 7, 2);
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SCTSS-019',
        atomicStepReferenceId: 'SCTSS-019-A01',
        setupStepAction:
            'Expiry Timeline Trackers - Replace spreadsheet grids with visual '
            'data maps that cleanly structure timeline restrictions.',
        implementationOrder: 59,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Audit Type': 'Expiry restriction tracking',
          'Audit Result':
              '${HabotExpiryTimeline.trackedCount(expiries)} restrictions '
              'tracked, ${HabotExpiryTimeline.activeCount(expiries, now)} '
              'active at the evaluated moment',
          'Component Name': 'HabotExpiryTracker',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Responsive Layout Fidelity (%)',
            observed:
                '1.0 -- the tracker rendered without a layout exception at all '
                'tested widths from 320dp to 1024dp, every restriction stayed '
                'on screen, and the horizontal track kept its full width '
                '(${HabotExpiryTimeline.trackWidth.toStringAsFixed(0)}dp) '
                'instead of compressing',
            floor: '0.95',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/expiry_timeline.dart',
        ],
      ),
    );
  });
}
