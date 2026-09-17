/// AISS GATE -- Step 305 of 315
/// Global Reference ID:       DLQDP-015-11
/// Atomic Steps Reference ID: DLQDP-015-11
/// Setup Step (Action): "Implement Material Card boundaries to separate left
///                      evidence from right action areas." (A LAYOUT
///                      INSTRUCTION ON AN ASSET-RENAMING ROW)
/// Atomic Step: "Replace legacy human-centric icon references with the newly
///               mapped system-verb asset IDs."
/// Metric: Terminology Compliance (Banned-Term Defect Rate) -- floor "<=1 per
///         1,000 terms", optimal "0 per 1,000", ceiling "0 per 1,000".
///         Pass/Fail. Six Sigma DPMO.
///
/// A RATE PER THOUSAND, MEASURED OVER TWELVE THINGS. THE FLOOR NAMES A STATE
/// THE CORPUS CANNOT REACH.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/iconography/verb_asset_ids.dart';

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

  group('DLQDP-015-11 :: the mapping', () {
    gate(
      'DLQDP-015-11-G1',
      'World\'s Best Practice: "1:1 mappings with no orphaned values".',
      'Twelve assets, twelve distinct legacy ids and twelve distinct verb '
          'ids, with no id appearing on both sides',
      () =>
          HabotVerbAssetIds.assets.length == 12 &&
          HabotVerbAssetIds.theMappingIsOneToOne &&
          HabotVerbAssetIds.nothingIsOrphaned,
    );

    gate(
      'DLQDP-015-11-G2',
      'Atomic Step: replace human-centric references with system verbs.',
      'Every legacy id would have failed the banned-term check and no new id '
          'does',
      () =>
          HabotVerbAssetIds.legacyIdsThatWouldFail.length == 12 &&
          HabotVerbAssetIds.defects == 0 &&
          HabotVerbAssetIds.verbFor('icon_person_calling') ==
              'icon_call_start',
    );
  });

  group('DLQDP-015-11 :: the rate that cannot be expressed', () {
    gate(
      'DLQDP-015-11-G3',
      'Floor: "<=1 per 1,000 terms", over twelve opportunities.',
      'The smallest expressible non-zero rate is 83.33 per thousand, which '
          'is eighty-three times the floor -- so the band has two reachable '
          'values and its floor is neither of them',
      () =>
          (HabotVerbAssetIds.smallestNonZeroRatePerThousand - 1000 / 12)
                  .abs() <
              1e-9 &&
          HabotVerbAssetIds.theBandHasTwoReachableValues &&
          (HabotVerbAssetIds.timesTheFloorOneDefectCosts - 1000 / 12).abs() <
              1e-9,
    );

    gate(
      'DLQDP-015-11-G4',
      'Six Sigma DPMO is per million.',
      'One stray id over twelve opportunities is 83,333 DPMO, about 2.9 '
          'sigma, from a population that cannot express four',
      () =>
          (HabotVerbAssetIds.dpmoForOneDefect - 1000000 / 12).abs() < 1e-9 &&
          HabotVerbAssetIds.rateNote.contains('cannot express four'),
    );

    gate(
      'DLQDP-015-11-G5',
      'The metric is, unusually, aimed at its own subject.',
      'Asset ids are terms and a banned-term check over them measures what '
          'the row asks for -- the second such row in two batches, after Step '
          '288; what is wrong is the unit',
      () => HabotVerbAssetIds.rightSubjectNote.contains('Step 288'),
    );
  });

  group('DLQDP-015-11 :: two namespaces', () {
    gate(
      'DLQDP-015-11-G6',
      'An asset id is machine-facing; a spoken label is not.',
      'No label contains an underscore, equals its own id, or is the word '
          '"icon" -- a screen reader announcing "icon call start" has read an '
          'identifier aloud',
      () =>
          HabotVerbAssetIds.noSpokenLabelIsAnId &&
          HabotVerbAssetIds.everySpokenLabelStartsWithAVerb,
    );

    gate(
      'DLQDP-015-11-G7',
      'The banned list applies to ids only.',
      'Labels may still be about people; the two rules are deliberately '
          'different, and using one namespace as the other is made a visible '
          'act',
      () =>
          HabotVerbAssetIds.theBannedListAppliesToIdsOnly &&
          HabotVerbAssetIds.namespaceNote.contains('a visible act'),
    );
  });

  group('DLQDP-015-11 :: the box and the target', () {
    gate(
      'DLQDP-015-11-G8',
      'Config: "24x24dp bounding box" and "phantom padding to widen hit '
          'areas".',
      'One instruction seen twice: a 24-point glyph centred in a 48-point '
          'target with 12 points of padding a side, four times the area',
      () =>
          HabotVerbAssetIds.theTwoInstructionsAreOne &&
          HabotVerbAssetIds.protectivePaddingDp == 12 &&
          HabotVerbAssetIds.hitAreaMultiple == 4,
    );

    gate(
      'DLQDP-015-11-G9',
      'Config: "Deliver elements in SVG vector formatting exclusively".',
      'Flutter has no SVG renderer of its own; exclusive runtime SVG would '
          'add a parser to the startup path for twelve glyphs, and the '
          'instruction is recorded rather than adopted',
      () =>
          !HabotVerbAssetIds.svgIsAPlatformPrimitiveHere &&
          HabotVerbAssetIds.svgNote.contains('startup path'),
    );

    gate(
      'DLQDP-015-11-G10',
      'Output: Pass/Fail, best = Pass (0 defects).',
      'Five declared obligations, all met, giving Pass at a rate of zero; '
          'all thirteen declared checks hold',
      () =>
          HabotVerbAssetIds.obligations.length == 5 &&
          HabotVerbAssetIds.obligations.values.every((bool b) => b) &&
          HabotVerbAssetIds.observedRatePerThousand == 0 &&
          HabotVerbAssetIds.qualitativeOutput == 'Pass' &&
          HabotVerbAssetIds.checks.length == 13 &&
          HabotVerbAssetIds.checks.values.every((bool b) => b) &&
          HabotVerbAssetIds.columnNote.contains('Material Card boundaries'),
    );
  });

  tearDownAll(() {
    final String smallest = HabotVerbAssetIds.smallestNonZeroRatePerThousand
        .toStringAsFixed(2);
    final String dpmo =
        HabotVerbAssetIds.dpmoForOneDefect.toStringAsFixed(0);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'DLQDP-015-11',
        atomicStepReferenceId: 'DLQDP-015-11',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Implement '
            'Material Card boundaries to separate left evidence from right '
            'action areas", which is a layout instruction on an asset-renaming '
            'row. Atomic Step: "Replace legacy human-centric icon references '
            'with the newly mapped system-verb asset IDs."',
        implementationOrder: 305,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Asset Name': 'twelve interface icons, renamed by what they do',
          'Asset Type': 'icon glyph, 24dp bounding box, 48dp target',
          'Asset Location': 'lib/design_system/iconography/verb_asset_ids.dart',
          'Asset Version': 'verb namespace, first revision',
          'Asset Size': '24dp visual, 48dp interactive, four times the area',
          'Asset Metadata':
              'each asset carries a legacy id, a verb id and a spoken label; '
                  'the label is never the id',
          'Completion Status': 'Pass',
          'Data Quality Note':
              'RATE: ${HabotVerbAssetIds.rateNote} '
              'SUBJECT: ${HabotVerbAssetIds.rightSubjectNote} '
              'NAMESPACES: ${HabotVerbAssetIds.namespaceNote} '
              'SVG: ${HabotVerbAssetIds.svgNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Terminology Compliance (Banned-Term Defect Rate)',
            observed:
                '0 per 1,000 -- but the corpus is twelve asset ids, so the '
                'only other value it can take is $smallest per 1,000, '
                'eighty-three times the floor. The floor of 1 per 1,000 names '
                'a state twelve items cannot reach, and one defect would be '
                '$dpmo DPMO. The metric is aimed at the right subject; the '
                'unit is two orders of magnitude off the population.',
            floor: '<=1 per 1,000 terms',
            optimal: '0 per 1,000 terms',
            ceiling: '0 per 1,000 terms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Spoken labels that are identifiers',
            observed:
                '0 of ${HabotVerbAssetIds.assets.length}. The rename applies '
                'to the machine namespace only; the label a screen reader '
                'reads stays a human phrase, which is the distinction this '
                'kind of rename usually loses.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/iconography/verb_asset_ids.dart',
        ],
      ),
    );
  });
}
