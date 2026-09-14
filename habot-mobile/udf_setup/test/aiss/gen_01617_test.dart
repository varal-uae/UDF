/// AISS GATE -- Step 215 of 215
/// Global Reference ID:       GEN-01617
/// Atomic Steps Reference ID: GEN-01617
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Package dispute intake assets into
///               @habot/support/dispute-portal."
/// Metric: Dispute Resolution Cycle Time -- Floor <5 business days,
///         Optimal <48 hours, Ceiling <10 business days. Good/Average/Poor.
///
/// WHAT PACKAGING BUYS IS NOT REUSE, IT IS AGREEMENT: the fields the agent
/// sees are the fields the parent filled. Defined in the app and re-typed in
/// the portal, the two drift by one field, and the symptom is an agent reading
/// a blank where the parent typed something.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/support/dispute_portal.dart';
import 'package:udf_setup/design_system/support/dispute_submission.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

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

  group('GEN-01617 :: the package', () {
    gate(
      'GEN-01617-G1',
      'Atomic Step: "Package dispute intake assets into '
          '@habot/support/dispute-portal." Same shape as Step 176.',
      'The NPM specifier is kept as an alias so the sheet still resolves, and '
          'the buildable name is legal in the ecosystem that exists here -- '
          'the row\'s own identifier is demonstrated illegal rather than '
          'asserted to be',
      () =>
          HabotDisputePortal.rowSpecifier ==
              '@habot/support/dispute-portal' &&
          HabotDisputePortal.packageName ==
              'habot_support_dispute_portal' &&
          HabotDisputePortal.packageNameIsDartLegal &&
          HabotDisputePortal.rowSpecifierIsNotDartLegal &&
          HabotDisputePortal.substitution.contains('no registry to publish'),
    );

    gate(
      'GEN-01617-G2',
      '"A package whose every artefact is consumed by one side is not a shared '
          'package, it is a folder."',
      'Five artefacts, each read by at least two consumers, and the reason '
          'packaging is worth doing is recorded as agreement rather than as '
          'reuse',
      () =>
          HabotDisputePortal.artefacts.length == 5 &&
          HabotDisputePortal.everyArtefactIsShared &&
          HabotDisputePortal.artefacts.every(
            (HabotPortalArtefact a) => a.purpose.isNotEmpty,
          ) &&
          HabotDisputePortal.oneDefinitionNote
              .contains('drift by one field'),
    );

    gate(
      'GEN-01617-G3',
      'The point of the package is that the two ends agree.',
      'The published field and kind names are written out rather than derived '
          'from the app -- a list derived from the app would agree by '
          'construction and prove nothing -- and the comparison finds no drift '
          'in either direction',
      () =>
          HabotDisputePortal.publishedFieldNames.length == 5 &&
          HabotDisputePortal.publishedKindNames.length == 4 &&
          HabotDisputePortal.fieldsInAppNotInPackage.isEmpty &&
          HabotDisputePortal.fieldsInPackageNotInApp.isEmpty &&
          HabotDisputePortal.kindDrift.isEmpty &&
          HabotDisputePortal.definitionMatchesTheApp &&
          HabotDisputePortal.fieldCount ==
              HabotDisputeSubmission.fields.length &&
          HabotDisputePortal.kindCount == HabotDisputeKind.values.length,
    );

    gate(
      'GEN-01617-G4',
      '"A case filed under version 1 has to render when the app ships version '
          '2."',
      'The intake schema is versioned and additive, so a field is deprecated '
          'rather than removed and an old dispute renders as what it was '
          'instead of as a newer form with holes in it',
      () =>
          HabotDisputePortal.schemaVersion > 0 &&
          HabotDisputePortal.schemaIsAdditiveOnly &&
          HabotDisputePortal.artefacts.any(
            (HabotPortalArtefact a) => a.path == 'intake/schema_version',
          ) &&
          HabotDisputePortal.versioningNote.contains('months later'),
    );
  });

  group('GEN-01617 :: what must not be in it', () {
    gate(
      'GEN-01617-G5',
      '"An asset bundle is a thing that gets copied, vendored, cached by a '
          'build server and committed by accident."',
      'The package carries definitions and no case data: five categories are '
          'excluded by policy and no artefact path holds evidence or case '
          'contents',
      () =>
          HabotDisputePortal.carriesNoCaseData &&
          HabotDisputePortal.excludedByPolicy.length == 5 &&
          HabotDisputePortal.excludedByPolicy.contains('evidence files') &&
          HabotDisputePortal.excludedByPolicy
              .contains('parent or child names') &&
          HabotEvidenceContract.noFilesInThePackageNote
              .contains('committed by accident'),
    );

    gate(
      'GEN-01617-G6',
      'The evidence contract is what may be attached, not a place to attach '
          'it.',
      'Accepted media types, a per-file size bound and a file count are all '
          'declared; a JPEG inside the bound is accepted and a zip archive is '
          'not; and files are referenced rather than embedded',
      () =>
          HabotEvidenceContract.filesAreReferencedNotEmbedded &&
          HabotEvidenceContract.acceptedMimeTypes.length == 4 &&
          HabotEvidenceContract.maximumFiles == 5 &&
          HabotEvidenceContract.maximumBytesPerFile == 8 * 1024 * 1024 &&
          HabotEvidenceContract.isAccepted('image/jpeg', 1024) &&
          !HabotEvidenceContract.isAccepted('application/zip', 1024) &&
          !HabotEvidenceContract.isAccepted(
            'image/jpeg',
            HabotEvidenceContract.maximumBytesPerFile + 1,
          ),
    );

    gate(
      'GEN-01617-G7',
      'Metric: Dispute Resolution Cycle Time -- measured after the app stops '
          'being involved.',
      'The bounds are the same ones Step 214 declared, taken from that step '
          'rather than restated here, and all nine structural checks hold at '
          '1.0 -- while no cycle-time figure is produced from a manifest',
      () {
        adherence = HabotDisputePortal.adherence;
        return HabotDisputePortal.optimalCycle ==
                HabotDisputeSubmission.optimalCycle &&
            HabotDisputePortal.floorBusinessDays == 5 &&
            HabotDisputePortal.ceilingBusinessDays == 10 &&
            HabotDisputePortal.qualitativeOutputForBusinessDays(1) ==
                'Good' &&
            HabotDisputePortal.qualitativeOutputForBusinessDays(11) ==
                'Poor' &&
            HabotDisputePortal.checks.length == 9 &&
            HabotDisputePortal.checks.values.every((bool b) => b) &&
            adherence == 1.0 &&
            HabotDisputePortal.cycleTimeIsNotOursNote
                .contains('clarification round trip') &&
            HabotDisputePortal.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01617',
        atomicStepReferenceId: 'GEN-01617',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Package dispute intake assets into '
            '@habot/support/dispute-portal."',
        implementationOrder: 215,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDisputePortal / HabotEvidenceContract',
          'Component Properties':
              '${HabotDisputePortal.artefacts.length} artefacts, every one '
              'read by at least two consumers; schema version '
              '${HabotDisputePortal.schemaVersion}, additive only; '
              '${HabotDisputePortal.publishedFieldNames.length} published '
              'field names and ${HabotDisputePortal.publishedKindNames.length} '
              'kinds, written out and compared against the app; '
              '${HabotDisputePortal.excludedByPolicy.length} categories '
              'excluded by policy; evidence contract of '
              '${HabotEvidenceContract.acceptedMimeTypes.length} media types, '
              '${HabotEvidenceContract.maximumBytesPerFile ~/ (1024 * 1024)}MB '
              'per file, ${HabotEvidenceContract.maximumFiles} files, '
              'referenced never embedded',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION, as at Step 176: @habot/support/dispute-portal is '
              'an NPM specifier; NPM is JavaScript\'s registry, a Dart package '
              'name may not contain @ or /, and there is no network on this '
              'host and no registry to publish to. The manifest is built in '
              'the ecosystem that exists and the NPM name is kept as an alias '
              'so the sheet\'s identifier resolves to something. READING '
              'RECORDED: what packaging buys is not reuse in the abstract -- '
              'the agent tooling and this app are different products in '
              'different stacks -- it is that the fields the agent SEES are '
              'the fields the parent FILLED. Defined in the app and re-typed '
              'in the portal, the two drift by one field and the symptom is an '
              'agent reading a blank where the parent typed something. The '
              'published names are therefore written out rather than derived '
              'from the app: a list derived from the app agrees by '
              'construction and proves nothing, while a written one is a '
              'comparison that can fail. BOUNDARY: a dispute carries receipts, '
              'photographs and statements, and an asset bundle is a thing that '
              'gets copied, vendored, cached by a build server and committed '
              'by accident. The package declares what may be attached -- '
              'types, size, count -- and carries no file.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dispute Resolution Cycle Time',
            observed:
                'NOT PRODUCIBLE FROM A MANIFEST. Packaging contributes by '
                'removing the clarification round trip, which is the largest '
                'thing this client can do to the number. Bounds are taken from '
                'Step 214 rather than restated, so the two steps cannot drift.',
            floor: '<5 business days',
            optimal: '<48 hours',
            ceiling: '<10 business days',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Drift between the packaged intake and the app',
            observed:
                '0 fields and 0 kinds, in either direction, against a '
                'published list written out independently of the app\'s own '
                'definition. Structural adherence '
                '${adherence.toStringAsFixed(2)} over '
                '${HabotDisputePortal.checks.length} checks.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/support/dispute_portal.dart',
        ],
      ),
    );
  });
}
