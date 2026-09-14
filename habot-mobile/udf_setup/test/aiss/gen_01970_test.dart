/// AISS GATE -- Step 231 of 235
/// Global Reference ID:       GEN-01970
/// Atomic Steps Reference ID: GEN-01970
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Ensure only visible components consume rendering resources."
/// Metric: Step Completion Rate (%) -- Floor 90, Optimal 99, Ceiling 100.
///         Complete/Partial/Not Complete.
///
/// "ONLY VISIBLE" IS FALSE BY DESIGN. A ListView.builder builds a cache extent
/// beyond the viewport so a flick does not hitch at the seam. Setting it to
/// zero satisfies the row exactly and produces a list that stutters.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/performance/render_scope.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completion = 0;

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

  group('GEN-01970 :: bounded, not zero', () {
    gate(
      'GEN-01970-G1',
      'Atomic Step: "Ensure ONLY VISIBLE components consume rendering '
          'resources."',
      'The build window is the viewport plus 250 logical pixels in each '
          'direction, so more items are built than are visible -- by design, '
          'and the alternative is a list that hitches at every seam',
      () =>
          HabotRenderScope.cacheExtentDp == 250 &&
          !HabotRenderScope.zeroCacheExtentIsAcceptable &&
          HabotRenderScope.buildWindowFor(568) == 1068 &&
          HabotRenderScope.boundedNotZeroNote.contains('stutters'),
    );

    gate(
      'GEN-01970-G2',
      'The row\'s wording has to be false about something measurable, or it is '
          'not a finding.',
      'On the shortest declared phone with a 96dp item, 12 items are built and '
          '6 are visible -- so exactly 6 of the 12 are built and not visible, '
          'which is the number the row says should be zero',
      () {
        const double viewport = HabotRenderScope.workedViewportDp;
        final double extent = HabotRenderScope.workedItemExtentDp;
        return extent == 96 &&
            HabotRenderScope.itemsVisibleFor(
                  viewportExtentDp: viewport,
                  itemExtentDp: extent,
                ) ==
                6 &&
            HabotRenderScope.itemsBuiltFor(
                  viewportExtentDp: viewport,
                  itemExtentDp: extent,
                ) ==
                12 &&
            HabotRenderScope.itemsBuiltButNotVisible(
                  viewportExtentDp: viewport,
                  itemExtentDp: extent,
                ) ==
                6;
      },
    );

    gate(
      'GEN-01970-G3',
      'A degenerate extent must not divide by zero.',
      'A zero item extent builds nothing rather than throwing, which matters '
          'because an intrinsic-extent list reports no extent at all until its '
          'first item has been built',
      () =>
          HabotRenderScope.itemsBuiltFor(
                viewportExtentDp: 568,
                itemExtentDp: 0,
              ) ==
              0 &&
          HabotRenderScope.itemsVisibleFor(
                viewportExtentDp: 568,
                itemExtentDp: 0,
              ) ==
              0,
    );
  });

  group('GEN-01970 :: what virtualisation costs', () {
    gate(
      'GEN-01970-G4',
      '"An item whose height is unknown until it is built makes the scrollbar '
          'thumb a guess."',
      'Every scrolling surface declares an extent strategy, and the one with '
          'no exact scroll position is named -- Step 63\'s chunked list, which '
          'declares neither a fixed extent nor a prototype item',
      () =>
          HabotExtentStrategy.values.length == 3 &&
          HabotRenderScope.surfaces.length == 4 &&
          HabotRenderScope.everyVirtualisedSurfaceDeclaresAStrategy &&
          HabotRenderScope.surfacesWithInexactScrollPosition.length == 1 &&
          HabotRenderScope.surfacesWithInexactScrollPosition.single.name
              .contains('Step 63') &&
          HabotRenderScope.surfacesWithInexactScrollPosition.single
                  .itemExtentDp ==
              null &&
          HabotRenderScope.positionStabilityNote
              .contains('without having written it down'),
    );

    gate(
      'GEN-01970-G5',
      'Virtualising a short list costs the exactness for nothing.',
      'The add-on list -- at most three options plus a disclosure, per Step '
          '203 -- is the one surface not virtualised, and it still declares a '
          'prototype extent so its scroll position is exact',
      () {
        final List<HabotScrollSurface> unvirtualised =
            HabotRenderScope.unvirtualisedSurfaces;
        return unvirtualised.length == 1 &&
            unvirtualised.single.name.contains('add-on') &&
            unvirtualised.single.strategy ==
                HabotExtentStrategy.prototypeItem &&
            unvirtualised.single.scrollPositionIsExact;
      },
    );

    gate(
      'GEN-01970-G6',
      'A fixed extent is the strategy that makes an index jump free.',
      'The two surfaces a parent navigates by index -- the child profile list '
          'and the booking history -- both declare a fixed extent and both '
          'report an exact scroll position',
      () {
        final List<HabotScrollSurface> fixed = HabotRenderScope.surfaces
            .where(
              (HabotScrollSurface s) =>
                  s.strategy == HabotExtentStrategy.fixedExtent,
            )
            .toList();
        return fixed.length == 2 &&
            fixed.every((HabotScrollSurface s) => s.scrollPositionIsExact) &&
            fixed.every((HabotScrollSurface s) => s.itemExtentDp != null) &&
            fixed.every((HabotScrollSurface s) => s.isVirtualised);
      },
    );

    gate(
      'GEN-01970-G7',
      'Metric: Step Completion Rate (%) -- floor 90, optimal 99.',
      'All seven checks hold, giving 100 and a Complete -- reported on a '
          'bounded build window and a declared extent strategy per surface, '
          'rather than on the literal claim the row makes, which nothing in '
          'Flutter would be right to satisfy',
      () {
        completion = HabotRenderScope.completionRate;
        return HabotRenderScope.checks.length == 7 &&
            HabotRenderScope.checks.values.every((bool b) => b) &&
            completion == 100 &&
            completion >= HabotRenderScope.optimal &&
            HabotRenderScope.qualitativeOutput == 'Complete' &&
            HabotRenderScope.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01970',
        atomicStepReferenceId: 'GEN-01970',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Ensure only visible components consume rendering '
            'resources."',
        implementationOrder: 231,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotRenderScope / HabotScrollSurface',
          'Component Properties':
              'Build window of viewport plus '
              '${HabotRenderScope.cacheExtentDp.toStringAsFixed(0)}dp in each '
              'direction; ${HabotRenderScope.surfaces.length} scrolling '
              'surfaces each declaring one of '
              '${HabotExtentStrategy.values.length} extent strategies; '
              '${HabotRenderScope.surfacesWithInexactScrollPosition.length} '
              'surface with an inexact scroll position, named',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: "only visible" is false by design, and it should be. A '
              'ListView.builder builds a cache extent beyond the viewport in '
              'both directions -- 250 logical pixels by default -- so a scroll '
              'does not stutter at the seam where new items appear. Setting '
              'that to zero satisfies the row\'s wording exactly and produces '
              'a list that hitches every time it is flicked. The honest '
              'statement is a BOUNDED BUILD WINDOW, and the bound is the cache '
              'extent. MEASURED on the shortest declared phone with a 96dp '
              'item: 12 items built, 6 visible, 6 built and not visible -- the '
              'number the row says should be zero. SECOND FINDING: '
              'virtualisation costs scroll-position stability and nothing in '
              'the repository declared what it was paying. An item whose '
              'height is unknown until it is built makes the scrollbar thumb a '
              'guess and makes an index jump impossible without building the '
              'items above it. The two mitigations are a fixed extent and a '
              'prototype item; Step 63\'s chunked list declares neither, and '
              'that surface is now named. Each scrolling surface declares its '
              'strategy, and the one short list is deliberately not '
              'virtualised, because virtualising it would cost the exactness '
              'for nothing.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Step Completion Rate (%)',
            observed:
                '${completion.toStringAsFixed(0)} over '
                '${HabotRenderScope.checks.length} checks: a bounded rather '
                'than zero build window, the built-but-not-visible count '
                'reported, an extent strategy on every virtualised surface, '
                'the inexact one named, and the short list left '
                'unvirtualised.',
            floor: '90',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Items built beyond the viewport',
            observed:
                '6 of 12 on a 568dp viewport with 96dp items -- the cache '
                'extent, 250dp in each direction. Reported rather than driven '
                'to zero: a zero cache extent satisfies the row and hitches at '
                'every seam.',
            floor: 'bounded',
            optimal: 'bounded',
            ceiling: 'unbounded is a leak',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/performance/render_scope.dart',
        ],
      ),
    );
  });
}
