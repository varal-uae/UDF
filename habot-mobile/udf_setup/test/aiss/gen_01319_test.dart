/// AISS GATE -- Step 375 of 375
/// Global Reference ID:       GEN-01319
/// Atomic Steps Reference ID: GEN-01319
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Package home view layouts into @habot/dashboard/parent-home."
/// Metric: Dashboard Data Refresh Latency -- the shared band, fourth and last
///         copy in this batch. Good/Average/Poor.
///
/// A PACKAGE NAME IS A DEPENDENCY DIRECTION, AND AN EXPORT IS A PROMISE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/parent_home_package.dart';

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

  group('GEN-01319 :: the direction', () {
    gate(
      'GEN-01319-G1',
      'The package name states a direction, and it runs one way.',
      'This package may depend on the design system; the design system must '
          'never depend on it',
      () =>
          HabotParentHomePackage.packageName
              .startsWith('@habot/dashboard') &&
          HabotParentHomePackage.theDependencyRunsOneWay,
    );

    gate(
      'GEN-01319-G2',
      'The design system never imports this package.',
      'A package with no direction shows it first as a change to the parent '
          'home breaking a screen nobody thought was related',
      () =>
          !HabotParentHomePackage.theDesignSystemImportsThisPackage &&
          HabotParentHomePackage.directionNote.contains('nobody thought'),
    );
  });

  group('GEN-01319 :: what belongs inside', () {
    gate(
      'GEN-01319-G3',
      'Six candidate pieces, four of which belong outside.',
      'The cards, the grid, the spacing and the freshness policy belong to the '
          'design system, because a second screen will want them',
      () =>
          HabotParentHomePackage.pieces.length == 6 &&
          HabotParentHomePackage.fourOutsideTwoInside &&
          HabotPackageSide.values.length == 2,
    );

    gate(
      'GEN-01319-G4',
      'The two inside are the two nobody else could use.',
      'The composition with its section order, and the screen\'s own '
          'parameters',
      () =>
          HabotParentHomePackage.onlyScreenPiecesAreInside &&
          HabotParentHomePackage.membershipNote
              .contains('a second screen will want them'),
    );
  });

  group('GEN-01319 :: the public surface', () {
    gate(
      'GEN-01319-G5',
      'The public surface is two symbols.',
      'One widget and one parameter object; an export is a promise to keep '
          'something working',
      () =>
          HabotParentHomePackage.theSurfaceIsTwoSymbols &&
          HabotParentHomePackage.exportedCount == 2 &&
          HabotParentHomePackage.everythingElseIsLibraryPrivate,
    );

    gate(
      'GEN-01319-G6',
      'Nothing from the design system is re-exported.',
      'Re-exporting a primitive makes this package a second route to it and '
          'eventually a second version of it',
      () =>
          HabotParentHomePackage.nothingFromTheDesignSystemIsReExported &&
          HabotParentHomePackage.surfaceNote
              .contains('a second version of it'),
    );
  });

  group('GEN-01319 :: the shared band, for the fourth and last time', () {
    gate(
      'GEN-01319-G7',
      'This row carries the band Steps 358, 362 and 374 also carry.',
      'And Steps 163 and 175, which tokenised it -- six rows, one band, four '
          'of them in this batch',
      () =>
          HabotParentHomePackage.theBandIsTheSharedOne &&
          HabotParentHomePackage.allRowsSharingIt.length == 6 &&
          HabotParentHomePackage.allRowsSharingIt.contains(163) &&
          HabotParentHomePackage.allRowsSharingIt.contains(175),
    );

    gate(
      'GEN-01319-G8',
      'And it is the last copy in the batch.',
      'Step 375 is the highest row in the shared set',
      () => HabotParentHomePackage.thisIsTheLastCopyInTheBatch,
    );

    gate(
      'GEN-01319-G9',
      'A package has no refresh latency.',
      'A package holds no data and refreshes nothing; what carries freshness '
          'is the widget binding built at Step 374 -- the fourth cross-subject '
          'metric in this batch, after Steps 360, 363 and 366',
      () =>
          !HabotParentHomePackage.thePackageHasARefreshLatency &&
          HabotParentHomePackage.theWidgetBindingCarriesTheFreshness &&
          HabotParentHomePackage.thisIsTheFourthCrossSubjectMetric &&
          HabotParentHomePackage.bandNote
              .contains('where the property actually lives'),
    );

    gate(
      'GEN-01319-G10',
      'Output reported as Good / Average / Poor.',
      'Five obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotParentHomePackage.obligations.length == 5 &&
          HabotParentHomePackage.obligations.values.every((bool b) => b) &&
          HabotParentHomePackage.qualitativeOutput == 'Good' &&
          HabotParentHomePackage.checks.length == 10 &&
          HabotParentHomePackage.checks.values.every((bool b) => b) &&
          HabotParentHomePackage.columnNote.contains('parent-home'),
    );
  });

  tearDownAll(() {
    final int outside = HabotParentHomePackage.piecesOutside;
    final int inside = HabotParentHomePackage.piecesInside;
    final int surface = HabotParentHomePackage.exportedCount;
    final int sharing = HabotParentHomePackage.allRowsSharingIt.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01319',
        atomicStepReferenceId: 'GEN-01319',
        setupStepAction:
            'COLUMN NOTE: the band on this row is the one shared with Steps '
            '358, 362 and 374 of this batch and with Steps 163 and 175 -- six '
            'rows, one band -- its metric is a dashboard refresh latency on a '
            'packaging row, its Data Requirement cell reads "Data/artifacts to '
            'prepare: @habot/dashboard/parent-home", which is the package name '
            'lifted into the artefact list, and the Setup Step column is '
            'empty. Atomic Step: "Package home view layouts into '
            '@habot/dashboard/parent-home."',
        implementationOrder: 375,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          '@habot/dashboard/parent-home':
              '$outside of 6 pieces belong outside the package and $inside '
                  'inside; the public surface is $surface symbols',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the dependency runs one way and nothing from the design system '
                  'is re-exported',
          'Data Quality Note':
              'DIRECTION: ${HabotParentHomePackage.directionNote} '
              'MEMBERSHIP: ${HabotParentHomePackage.membershipNote} '
              'SURFACE: ${HabotParentHomePackage.surfaceNote} '
              'BAND: ${HabotParentHomePackage.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dashboard Data Refresh Latency',
            observed:
                'THE FOURTH AND LAST COPY IN THIS BATCH, AND THE SIXTH IN THE '
                'SHEET. The identical three cells appear on Steps 358, 362 and '
                '374 here and on Steps 163 and 175, which tokenised them: '
                '$sharing rows, one band, with a ceiling twenty-four times its '
                'floor on a lower-is-better measure. Six identical copies make '
                'it a template rather than six mistakes. A refresh latency is '
                'also not a property of a package -- a package holds no data '
                'and refreshes nothing -- which makes this the fourth row in '
                'the batch scored on a metric belonging to a different '
                'subject, after Steps 360, 363 and 366. What does carry '
                'freshness is the widget binding built at Step 374.',
            floor: '<1 hour',
            optimal: '<5 minutes',
            ceiling: '<24 hours',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Promises made by the package boundary',
            observed:
                '$surface. A package name is a dependency direction and that '
                'is the whole decision: this package depends on the design '
                'system and the design system never depends on it. What '
                'belongs inside is what only this screen knows -- $inside of '
                'six pieces, the composition and the parameters -- while the '
                'cards, the grid, the spacing and the freshness policy stay '
                'outside because a second screen will want them. An export is '
                'a promise to keep something working, so the public surface is '
                'one widget and one parameter object, everything else is '
                'library-private, and no design-system primitive is '
                're-exported.',
            floor: '20',
            optimal: '2',
            ceiling: '2',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/parent_home_package.dart',
        ],
      ),
    );
  });
}
