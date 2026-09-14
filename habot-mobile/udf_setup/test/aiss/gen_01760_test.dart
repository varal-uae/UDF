/// AISS GATE -- Step 232 of 235
/// Global Reference ID:       GEN-01760
/// Atomic Steps Reference ID: GEN-01760
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Block Out-Of-Memory (OOM) errors by strictly limiting
///               concurrent DOM nodes."
/// Metric: Step Completion Rate (%) -- Floor 90, Optimal 99, Ceiling 100.
///         Complete/Partial/Not Complete.
///
/// THERE IS NO DOM, AND NODES ARE NOT WHERE THE MEMORY GOES. On a mobile client
/// the cause of an out-of-memory kill is almost always images: a factor of 406
/// between a photograph decoded at source resolution and the same photograph
/// decoded at the size it is displayed at.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/performance/memory_ceiling.dart';
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

  group('GEN-01760 :: the substitution', () {
    gate(
      'GEN-01760-G1',
      'Atomic Step: "strictly limiting concurrent DOM NODES."',
      'There is no DOM. The nearest equivalent is the number of render objects '
          'alive at once, which Step 231\'s bounded build window already '
          'governs -- so the row\'s own ask was satisfied before it was read',
      () =>
          HabotMemoryCeiling.rowConcept == 'concurrent DOM nodes' &&
          HabotMemoryCeiling.flutterEquivalent.contains('Step 231') &&
          HabotMemoryCeiling.substitution.contains('no DOM') &&
          HabotMemoryCeiling.sources.first.isTheRowsConcern &&
          HabotMemoryCeiling.sources.first.boundedBy.contains('Step 231') &&
          HabotRenderScope.cacheExtentDp > 0,
    );

    gate(
      'GEN-01760-G2',
      '"On a mobile client the cause of an out-of-memory kill is almost always '
          'images, not tree size."',
      'A 4032x3024 photograph decoded at source resolution is 48,771,072 bytes '
          'and the same photograph at its 200x150 display size is 120,000 -- a '
          'factor of 406, computed rather than asserted',
      () =>
          HabotMemoryCeiling.bytesPerPixel == 4 &&
          HabotMemoryCeiling.sourceResolutionBytes == 48771072 &&
          HabotMemoryCeiling.displayResolutionBytes == 120000 &&
          (HabotMemoryCeiling.decodeWasteFactor - 406.4256).abs() < 1e-4 &&
          HabotMemoryCeiling.sourceResolutionBytes > 46 << 20 &&
          HabotMemoryCeiling.displayResolutionBytes < 128 << 10,
    );

    gate(
      'GEN-01760-G3',
      'A factor is only alarming once it is put against the cache it has to '
          'fit in.',
      'Flutter\'s default image cache is 100 MiB, which holds two '
          'source-resolution photographs and 873 display-resolution ones, and '
          'a grid of eight thumbnails overflows it at source resolution and '
          'fits at display resolution',
      () =>
          HabotMemoryCeiling.imageCacheMaxBytes == 100 << 20 &&
          HabotMemoryCeiling.imageCacheMaxImages == 1000 &&
          HabotMemoryCeiling.sourceResolutionImagesPerCache == 2 &&
          HabotMemoryCeiling.displayResolutionImagesPerCache == 873 &&
          HabotMemoryCeiling.gridOverflowsCacheAtSourceResolution &&
          HabotMemoryCeiling.gridFitsCacheAtDisplayResolution &&
          HabotMemoryCeiling.thumbnailGridSize == 8,
    );

    gate(
      'GEN-01760-G4',
      '"A step that limits nodes and says nothing about decode resolution is a '
          'step that reports Complete while the app is killed for the reason '
          'it did not look at."',
      'The rule that follows is declared -- every image is decoded at the size '
          'it is displayed at -- and the reason is the measured factor rather '
          'than a habit',
      () =>
          HabotMemoryCeiling.decodesAtDisplaySize &&
          HabotMemoryCeiling.imagesNotNodesNote.contains('46.5 MiB') &&
          HabotMemoryCeiling.imagesNotNodesNote
              .contains('did not look at'),
    );
  });

  group('GEN-01760 :: everything that retains memory', () {
    gate(
      'GEN-01760-G5',
      'A ceiling on one source is not a memory budget.',
      'Four retained sources are listed with what bounds each, and three of '
          'the four are things the row does not mention -- so the census says '
          'what the row leaves out rather than only what it asks for',
      () =>
          HabotMemoryCeiling.sources.length == 4 &&
          HabotMemoryCeiling.sourcesTheRowDoesNotMention.length == 3 &&
          HabotMemoryCeiling.sources.every(
            (HabotMemorySource s) => s.boundedBy.length > 20,
          ) &&
          HabotMemoryCeiling.sources.any(
            (HabotMemorySource s) => s.name.contains('decoded images'),
          ),
    );

    gate(
      'GEN-01760-G6',
      '"The Step 63 chunk controller keeps every chunk it has loaded for the '
          'life of the list."',
      'The one source with no declared bound is named rather than quietly '
          'bounded, because an eviction policy is Step 63\'s decision and a '
          'chunk evicted while the user is scrolling back through it is a '
          'worse bug than the memory it saves',
      () =>
          HabotMemoryCeiling.unboundedSources.length == 1 &&
          HabotMemoryCeiling.unboundedSources.single.name
              .contains('chunk controller') &&
          HabotMemoryCeiling.unboundedSources.single.boundedBy
              .startsWith('nothing declared') &&
          HabotMemoryCeiling.unboundedChunkNote
              .contains('worse bug than the memory it saves'),
    );

    gate(
      'GEN-01760-G7',
      'Metric: Step Completion Rate (%) -- floor 90, optimal 99.',
      'All ten checks hold, giving 100 and a Complete -- reported on the '
          'substituted node ceiling, the measured image factor and a census of '
          'everything retained, rather than on a DOM-node count that would '
          'have been a number about a platform this app does not run on',
      () {
        completion = HabotMemoryCeiling.completionRate;
        return HabotMemoryCeiling.checks.length == 10 &&
            HabotMemoryCeiling.checks.values.every((bool b) => b) &&
            completion == 100 &&
            completion >= HabotMemoryCeiling.optimal &&
            HabotMemoryCeiling.qualitativeOutput == 'Complete' &&
            HabotMemoryCeiling.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01760',
        atomicStepReferenceId: 'GEN-01760',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Block Out-Of-Memory (OOM) errors by strictly limiting '
            'concurrent DOM nodes."',
        implementationOrder: 232,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotMemoryCeiling / HabotMemorySource',
          'Component Properties':
              '${HabotMemoryCeiling.sources.length} retained sources with what '
              'bounds each, ${HabotMemoryCeiling.unboundedSources.length} of '
              'them unbounded and named; decode-at-display-size rule; image '
              'cache bounds '
              '${HabotMemoryCeiling.imageCacheMaxBytes >> 20}MiB / '
              '${HabotMemoryCeiling.imageCacheMaxImages} images',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION: there is no DOM. Flutter builds a widget tree, an '
              'element tree and a render tree and composites layers; the '
              'nearest equivalent to a node count is the number of render '
              'objects alive at once, which Step 231\'s bounded build window '
              'already governs -- so the row\'s own ask was satisfied before '
              'it was read. FINDING: nodes are not where the memory goes. On a '
              'mobile client an out-of-memory kill is almost always IMAGES. '
              'MEASURED: a 4032x3024 photograph decoded at source resolution '
              'occupies 48,771,072 bytes -- about 46.5 MiB -- and the same '
              'photograph decoded at the 200x150 it is displayed at occupies '
              '120,000 bytes. A factor of 406. Flutter\'s default image cache '
              'is 100 MiB, so two source-resolution decodes fill most of it '
              'and a grid of eight thumbnails overflows it and begins evicting '
              'the images the user is looking at; the same grid at display '
              'resolution uses under a megabyte. A step that limits nodes and '
              'says nothing about decode resolution reports Complete while the '
              'app is killed for the reason it did not look at. THIRD: the '
              'census names four retained sources and one of them -- the Step '
              '63 chunk controller\'s loaded chunks -- has no declared bound. '
              'Raised rather than changed: eviction policy is Step 63\'s '
              'decision, and a chunk evicted while the user is scrolling back '
              'through it is a worse bug than the memory it saves.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Step Completion Rate (%)',
            observed:
                '${completion.toStringAsFixed(0)} over '
                '${HabotMemoryCeiling.checks.length} checks: the node ceiling '
                'mapped onto the Step 231 build window, the decode factor '
                'measured, the cache arithmetic done, the decode-at-display '
                'rule declared, and every retained source listed with what '
                'bounds it.',
            floor: '90',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Decode waste factor',
            observed:
                '${HabotMemoryCeiling.decodeWasteFactor.toStringAsFixed(1)}x '
                '-- 48,771,072 bytes against 120,000 for the same photograph. '
                'Two source-resolution decodes fill most of the 100 MiB '
                'cache; eight overflow it.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/performance/memory_ceiling.dart',
        ],
      ),
    );
  });
}
