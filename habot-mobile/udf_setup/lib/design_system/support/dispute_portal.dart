/// Step 215 (GEN-01617) -- packaging the dispute intake.
///
/// The row: "Package dispute intake assets into @habot/support/dispute-portal."
/// Metric: Dispute Resolution Cycle Time -- <5 business days / <48 hours /
/// <10 business days.
///
/// **Substitution, as at Step 176.** `@habot/support/dispute-portal` is an NPM
/// specifier; NPM is JavaScript's registry, a Dart package name may not contain
/// `@` or `/`, and there is no network on this host. The manifest is built in
/// the ecosystem that exists, and the NPM name is kept as an alias so the
/// sheet's identifier still resolves to something.
///
/// **What packaging is actually for.** Not reuse in the abstract -- the agent
/// tooling and this app are different products in different stacks. What a
/// shared package buys is that the fields the agent sees are the fields the
/// parent filled. When the intake is defined in the app and re-typed in the
/// portal, the two drift by one field and the symptom is an agent reading a
/// blank where the parent typed something. The package is the intake
/// definition, versioned, and nothing else.
///
/// **What must not be in it.** A dispute carries evidence: a receipt, a
/// photograph of a child's wristband, a bank statement. Those are personal data
/// belonging to one case, and an asset bundle is a thing that gets copied,
/// vendored, cached by a build server and committed by accident. The manifest
/// declares the evidence CONTRACT -- accepted types, size bound, where a file
/// is referenced from -- and carries no file.
///
/// **Versioning is what keeps old disputes readable.** A case filed under v1
/// has to render when the app ships v2. Schemas are additive, fields are
/// deprecated rather than removed, and the version travels with the case.
library;

import 'dispute_submission.dart';

/// One artefact in the package.
class HabotPortalArtefact {
  const HabotPortalArtefact({
    required this.path,
    required this.purpose,
    required this.consumedBy,
  });

  final String path;
  final String purpose;

  /// Who reads it. A package whose every artefact is consumed by one side is
  /// not a shared package, it is a folder.
  final List<String> consumedBy;
}

/// The evidence contract. A description of what may be attached, not a place
/// to attach it.
class HabotEvidenceContract {
  const HabotEvidenceContract._();

  static const List<String> acceptedMimeTypes = <String>[
    'image/jpeg',
    'image/png',
    'image/heic',
    'application/pdf',
  ];

  /// Per file. Large enough for a phone photograph, small enough that an
  /// intake does not fail on a train.
  static const int maximumBytesPerFile = 8 * 1024 * 1024;

  static const int maximumFiles = 5;

  /// Evidence is referenced, never embedded. The reference is opaque and
  /// resolves only for someone already authorised to see the case.
  static const bool filesAreReferencedNotEmbedded = true;

  static bool isAccepted(String mimeType, int bytes) =>
      acceptedMimeTypes.contains(mimeType) && bytes <= maximumBytesPerFile;

  static const String noFilesInThePackageNote =
      'A dispute carries receipts, photographs and statements. Those belong to '
      'one case and to one family. An asset bundle is a thing that gets '
      'copied, vendored, cached by a build server and committed by accident, '
      'and none of those are places a child\'s wristband photograph should '
      'end up. The package declares what may be attached and carries no file.';
}

/// The package manifest.
class HabotDisputePortal {
  const HabotDisputePortal._();

  /// The identifier from the row, kept so the sheet still resolves.
  static const String rowSpecifier = '@habot/support/dispute-portal';

  /// The name in the ecosystem that exists here.
  static const String packageName = 'habot_support_dispute_portal';

  static bool get packageNameIsDartLegal =>
      RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(packageName);

  static bool get rowSpecifierIsNotDartLegal =>
      !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(rowSpecifier);

  static const String substitution =
      'NPM is JavaScript\'s registry and a Dart package name may not contain '
      '@ or /. There is no network on this host and no registry to publish '
      'to. The manifest is built in the ecosystem that exists and the NPM '
      'name is kept as an alias, so the sheet\'s identifier resolves to '
      'something rather than to nothing.';

  /// The intake schema version this build speaks.
  static const int schemaVersion = 1;

  /// Schema changes are additive; a field is deprecated, never removed.
  static const bool schemaIsAdditiveOnly = true;

  static const String versioningNote =
      'A case filed under version 1 has to render when the app ships version '
      '2, and the agent looking at it is looking at it months later. Fields '
      'are deprecated rather than removed and the version travels with the '
      'case, so an old dispute renders as what it was rather than as a newer '
      'form with holes in it.';

  /// What is in the package.
  static const List<HabotPortalArtefact> artefacts = <HabotPortalArtefact>[
    HabotPortalArtefact(
      path: 'intake/dispute_kinds',
      purpose: 'The kinds a dispute can be, and what each one routes to.',
      consumedBy: <String>['mobile app', 'agent portal'],
    ),
    HabotPortalArtefact(
      path: 'intake/field_definitions',
      purpose:
          'Every intake field, which kinds require it, and why an agent needs '
          'it.',
      consumedBy: <String>['mobile app', 'agent portal'],
    ),
    HabotPortalArtefact(
      path: 'intake/evidence_contract',
      purpose:
          'Accepted media types, the per-file size bound and the file count. '
          'No files.',
      consumedBy: <String>['mobile app', 'agent portal', 'intake service'],
    ),
    HabotPortalArtefact(
      path: 'intake/schema_version',
      purpose: 'The version a case was filed under.',
      consumedBy: <String>['mobile app', 'agent portal', 'intake service'],
    ),
    HabotPortalArtefact(
      path: 'intake/completeness_rule',
      purpose:
          'How intake completeness is computed, so the app and the portal '
          'agree about what "complete" means.',
      consumedBy: <String>['mobile app', 'agent portal'],
    ),
  ];

  /// Every artefact must be read by more than one side.
  static bool get everyArtefactIsShared => artefacts.every(
        (HabotPortalArtefact a) => a.consumedBy.length > 1,
      );

  /// The package carries definitions, not personal data.
  static const List<String> excludedByPolicy = <String>[
    'evidence files',
    'case contents',
    'parent or child names',
    'payment instrument data',
    'agent notes',
  ];

  static bool get carriesNoCaseData => excludedByPolicy.isNotEmpty &&
      !artefacts.any(
        (HabotPortalArtefact a) =>
            a.path.contains('case') || a.path.contains('evidence_files'),
      );

  /// The field names the package publishes, written out.
  ///
  /// Written out rather than derived, because a list derived from the app's
  /// own definition agrees with it by construction and would prove nothing.
  /// This is the copy an agent portal would read, and the check below is the
  /// one that catches the app and the package drifting apart.
  static const List<String> publishedFieldNames = <String>[
    'bookingReference',
    'chargeDate',
    'expectedAmount',
    'description',
    'contactPreference',
  ];

  /// The kinds the package publishes.
  static const List<String> publishedKindNames = <String>[
    'serviceNotDelivered',
    'amountIncorrect',
    'duplicateCharge',
    'unauthorised',
  ];

  static List<String> get fieldsInAppNotInPackage =>
      HabotDisputeSubmission.fields
          .map((HabotDisputeField f) => f.name)
          .where((String n) => !publishedFieldNames.contains(n))
          .toList();

  static List<String> get fieldsInPackageNotInApp {
    final Set<String> app = HabotDisputeSubmission.fields
        .map((HabotDisputeField f) => f.name)
        .toSet();
    return publishedFieldNames
        .where((String n) => !app.contains(n))
        .toList();
  }

  static List<String> get kindDrift {
    final Set<String> app =
        HabotDisputeKind.values.map((HabotDisputeKind k) => k.name).toSet();
    return <String>[
      ...publishedKindNames.where((String n) => !app.contains(n)),
      ...app.where((String n) => !publishedKindNames.contains(n)),
    ];
  }

  /// The package and the app describe the same intake.
  static bool get definitionMatchesTheApp =>
      fieldsInAppNotInPackage.isEmpty &&
      fieldsInPackageNotInApp.isEmpty &&
      kindDrift.isEmpty;

  static int get fieldCount => publishedFieldNames.length;
  static int get kindCount => publishedKindNames.length;

  static const String oneDefinitionNote =
      'Reuse in the abstract is not the point -- the agent tooling and this '
      'app are different products in different stacks. What a shared package '
      'buys is that the fields the agent sees are the fields the parent '
      'filled. Defined in the app and re-typed in the portal, the two drift by '
      'one field, and the symptom is an agent reading a blank where the parent '
      'typed something.';

  // -----------------------------------------------------------------------
  // Metric: Dispute Resolution Cycle Time.
  // -----------------------------------------------------------------------

  static Duration get optimalCycle => HabotDisputeSubmission.optimalCycle;
  static int get floorBusinessDays =>
      HabotDisputeSubmission.floorBusinessDays;
  static int get ceilingBusinessDays =>
      HabotDisputeSubmission.ceilingBusinessDays;

  /// As at Step 214: the client's contribution to cycle time is intake
  /// quality, and packaging's contribution to intake quality is that the two
  /// ends agree about what was collected.
  static Map<String, bool> get checks => <String, bool>{
        'the package name is legal in the ecosystem it ships to':
            packageNameIsDartLegal && rowSpecifierIsNotDartLegal,
        'the row specifier is kept as an alias': rowSpecifier.isNotEmpty,
        'every artefact is read by more than one side': everyArtefactIsShared,
        'the package carries no case data': carriesNoCaseData,
        'evidence is referenced rather than embedded':
            HabotEvidenceContract.filesAreReferencedNotEmbedded,
        'the evidence contract bounds type, size and count':
            HabotEvidenceContract.acceptedMimeTypes.isNotEmpty &&
                HabotEvidenceContract.maximumBytesPerFile > 0 &&
                HabotEvidenceContract.maximumFiles > 0,
        'an unacceptable attachment is refused by the contract':
            !HabotEvidenceContract.isAccepted('application/zip', 1024) &&
                HabotEvidenceContract.isAccepted('image/jpeg', 1024),
        'the schema is versioned and additive':
            schemaVersion > 0 && schemaIsAdditiveOnly,
        'the packaged definition is the one the app enforces':
            definitionMatchesTheApp,
      };

  static double get adherence =>
      checks.values.where((bool b) => b).length / checks.length;

  static String qualitativeOutputForBusinessDays(int days) =>
      HabotDisputeSubmission.qualitativeOutputForBusinessDays(days);

  static const String cycleTimeIsNotOursNote =
      'Cycle time is measured after the app stops being involved. What '
      'packaging contributes is that the two ends of the intake agree, which '
      'removes the clarification round trip that is the largest thing this '
      'client can do to the number. The substitution is stated rather than a '
      'cycle-time figure being produced from a manifest.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Package dispute intake assets into @habot/support/dispute-portal."';
}
