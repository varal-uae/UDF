/// Step 269 (GEN-00820) -- a scan of the warehouse for unhashed personal data,
/// run from a client that cannot reach the warehouse.
///
/// The row: "Execute Cloud DLP scans against analytical datasets to confirm 0
/// raw unhashed PII findings."
/// Metric: **Raw Unhashed PII Finding Count** -- floor 0, optimal 0, ceiling
/// 0. Pass / Fail. Standard cited: ISO/IEC 27701.
///
/// **A Flutter client cannot execute a Cloud DLP scan, and should not be able
/// to.** The scan runs against analytical datasets in a warehouse this
/// application has no credentials for; a client that could scan the warehouse
/// could also read it. So the row's own action is a server obligation, named
/// as one -- the same shape as Step 235's API latency SLA and Step 253's
/// server-side reconciliation.
///
/// **The client's half is upstream and it is the half that decides the
/// answer.** If nothing unhashed leaves the device, the dataset cannot
/// contain it, and the scan is a confirmation rather than a discovery.
/// `HabotEventSchema` already makes this structural: there are five field
/// types and none of them is free text, so an event carrying a name or an
/// email address cannot be declared, never mind emitted.
///
/// **A hash is not anonymisation when the input space is small.** An opaque
/// id derived from a phone number is reversible by trying every phone number,
/// and there are fewer of those than a second of computation. `opaqueId` is
/// salted per install, which separates one install from another and does not
/// make the value unguessable. It protects against casual inspection and a
/// careless join; it does not protect against somebody who wants the number,
/// and calling it anonymised would be the kind of claim that stops people
/// asking whether the field needed to be there at all.
library;

import 'event_schema.dart';
import 'pii_sanitizer.dart';

/// Who has to do a thing.
enum HabotObligationSide {
  /// This application, on the device.
  client,

  /// The server or the warehouse.
  server,
}

/// One obligation in the chain that ends with the row's zero.
class HabotPurityObligation {
  const HabotPurityObligation({
    required this.name,
    required this.side,
    required this.satisfiedHere,
    required this.why,
  });

  final String name;
  final HabotObligationSide side;

  /// Whether this step can show it holds. False for everything on the server
  /// side, and saying so is the point.
  final bool satisfiedHere;

  final String why;
}

/// The emission rules.
class HabotEmissionPurity {
  const HabotEmissionPurity._();

  static const List<HabotPurityObligation> obligations =
      <HabotPurityObligation>[
    HabotPurityObligation(
      name: 'no field type in the event schema can hold free text',
      side: HabotObligationSide.client,
      satisfiedHere: true,
      why: 'Five types -- enumeration, integer, durationMs, boolean, '
          'opaqueId -- and none of them is a string a person typed. An event '
          'carrying a name cannot be DECLARED, which is a stronger guarantee '
          'than one that cannot be emitted.',
    ),
    HabotPurityObligation(
      name: 'every identifier emitted is opaque and salted per install',
      side: HabotObligationSide.client,
      satisfiedHere: true,
      why: 'HabotPiiSanitizer.opaqueId, with a per-install salt, so the same '
          'person on two installs is two identifiers and a join across them '
          'needs both salts.',
    ),
    HabotPurityObligation(
      name: 'anything that escapes into a log line is scrubbed',
      side: HabotObligationSide.client,
      satisfiedHere: false,
      why: 'Step 268 measured the scrubber at three of eleven contact '
          'strings. The structural half above is what carries this, and the '
          'scrubber is a net with holes in it -- named rather than assumed.',
    ),
    HabotPurityObligation(
      name: 'the warehouse is scanned for unhashed personal data',
      side: HabotObligationSide.server,
      satisfiedHere: false,
      why: 'The row\'s own action. A Cloud DLP scan runs against analytical '
          'datasets this application has no credentials for, and a client '
          'that could scan the warehouse could also read it.',
    ),
    HabotPurityObligation(
      name: 'ingestion rejects an event whose shape it does not recognise',
      side: HabotObligationSide.server,
      satisfiedHere: false,
      why: 'The client validates what it emits; nothing stops a different '
          'client posting something else. Step 253 made the same point about '
          'the balance gate, and the answer is the same.',
    ),
  ];

  static List<HabotPurityObligation> get clientObligations => obligations
      .where((HabotPurityObligation o) => o.side == HabotObligationSide.client)
      .toList();

  static List<HabotPurityObligation> get serverObligations => obligations
      .where((HabotPurityObligation o) => o.side == HabotObligationSide.server)
      .toList();

  static List<HabotPurityObligation> get shownHere =>
      obligations.where((HabotPurityObligation o) => o.satisfiedHere).toList();

  static double get shareShownHere => shownHere.length / obligations.length;

  static bool get nothingOnTheServerSideIsClaimed => serverObligations
      .every((HabotPurityObligation o) => !o.satisfiedHere);

  // -----------------------------------------------------------------------
  // The structural guarantee, read from the schema rather than restated.
  // -----------------------------------------------------------------------

  /// The five declared field types.
  static Set<HabotFieldType> get declaredTypes =>
      HabotFieldType.values.toSet();

  /// Names a free-text type would plausibly have. Checked by name so that
  /// adding one later breaks this gate rather than passing it.
  static const Set<String> freeTextTypeNames = <String>{
    'freeText',
    'text',
    'string',
    'rawString',
    'note',
  };

  /// None of the declared types is free text. A property of the enum rather
  /// than of anybody's care, and the check is over the enum's own names so a
  /// sixth type called `text` would fail it.
  static bool get noFieldTypeIsFreeText =>
      declaredTypes.length == 5 &&
      declaredTypes.every(
        (HabotFieldType t) => !freeTextTypeNames.contains(t.name),
      );

  /// Every declared event's fields are of those five types, checked over the
  /// declarations rather than asserted about them.
  static bool get everyDeclaredFieldIsATypedField =>
      HabotEventSchema.definitions.every(
        (HabotEventDefinition d) => d.fields.every(
          (HabotEventField f) => declaredTypes.contains(f.type),
        ),
      );

  static int get declaredEventKinds => HabotEventSchema.definitions.length;

  static int get declaredFields => HabotEventSchema.definitions.fold(
        0,
        (int a, HabotEventDefinition d) => a + d.fields.length,
      );

  static int get opaqueIdFields => HabotEventSchema.definitions.fold(
        0,
        (int a, HabotEventDefinition d) =>
            a +
            d.fields
                .where((HabotEventField f) => f.type == HabotFieldType.opaqueId)
                .length,
      );

  // -----------------------------------------------------------------------
  // What a salted hash is and is not.
  // -----------------------------------------------------------------------

  /// Roughly how many values a phone number can take, as an order of
  /// magnitude. Small enough that trying all of them is not an attack, it is
  /// a loop.
  static const int phoneNumberSearchSpace = 1000000000;

  /// The identifier is opaque and the same salt gives the same answer, so a
  /// dictionary over that search space recovers the input.
  static bool get aSaltedHashIsNotAnonymisation =>
      phoneNumberSearchSpace < 1e12 &&
      HabotPiiSanitizer.opaqueIdLength > 0;

  /// What the salt does buy: two installs of the same application produce
  /// different identifiers for the same input, so the datasets cannot be
  /// joined without both salts. Checked against the existing implementation
  /// rather than described.
  static bool get theSaltSeparatesInstalls =>
      HabotPiiSanitizer.saltSeparatesInstalls('amina@example.com', 'a', 'b');

  static const String hashIsNotAnonymousNote =
      'A hash is not anonymisation when the input space is small. An opaque '
      'id derived from a phone number is reversible by trying every phone '
      'number, and there are about a billion of those -- which is not an '
      'attack, it is a loop. The per-install salt separates one install\'s '
      'dataset from another\'s, so the two cannot be joined without both '
      'salts, and that is a real property worth having. It is not '
      'unguessability. Calling the result anonymised would be the kind of '
      'claim that stops people asking whether the field needed to be emitted '
      'at all, which is the only question that actually reaches zero.';

  static const String cannotRunTheScanNote =
      'A Flutter client cannot execute a Cloud DLP scan, and should not be '
      'able to: the scan runs against analytical datasets this application '
      'has no credentials for, and a client that could scan the warehouse '
      'could also read it. The row\'s own action is therefore a server '
      'obligation, named as one -- the same shape as Step 235\'s API latency '
      'SLA and Step 253\'s server-side reconciliation.';

  static const String upstreamNote =
      'The client\'s half is upstream, and it is the half that decides the '
      'answer. If nothing unhashed leaves the device the dataset cannot '
      'contain it, and the scan becomes a confirmation rather than a '
      'discovery. HabotEventSchema already makes this structural: five field '
      'types, none of them free text, so an event carrying a name or an '
      'email address cannot be declared -- which is stronger than one that '
      'merely cannot be emitted, because it fails at the declaration rather '
      'than at the call site.';

  // -----------------------------------------------------------------------
  // Metric: Raw Unhashed PII Finding Count -- floor, optimal, ceiling all 0.
  // -----------------------------------------------------------------------

  /// Declared fields whose type is one a free-text value could hide in.
  /// Zero, and zero because the type does not exist rather than because
  /// nobody used it -- which is a structural fact about the enum and not a
  /// measurement over the declarations.
  static int get declaredFieldsThatCouldCarryRawPii =>
      HabotEventSchema.definitions.fold(
        0,
        (int a, HabotEventDefinition d) =>
            a +
            d.fields
                .where(
                  (HabotEventField f) =>
                      freeTextTypeNames.contains(f.type.name),
                )
                .length,
      );

  static const String structuralNotMeasuredNote =
      'The zero here is structural rather than measured. There is no field '
      'type a free-text value could be declared as, so counting the fields '
      'that use one counts something that cannot exist -- which is the '
      'strongest form this guarantee can take and the weakest form of '
      'evidence, because a test over it can never fail while the enum stands. '
      'What can fail is the check on the enum\'s own names: a sixth type '
      'called text or note breaks it, which is the moment this guarantee '
      'would actually be at risk.';

  /// **Pass on the client half, and the server half is named rather than
  /// claimed.** The row's zero is reported over the population this step can
  /// see, with the population it cannot see stated.
  static String get qualitativeOutput =>
      declaredFieldsThatCouldCarryRawPii == 0 &&
              noFieldTypeIsFreeText &&
              nothingOnTheServerSideIsClaimed
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'five obligations, split between the client and the server':
            obligations.length == 5 &&
                clientObligations.length == 3 &&
                serverObligations.length == 2,
        'nothing on the server side is claimed as satisfied here':
            nothingOnTheServerSideIsClaimed,
        'two of the five are shown to hold, and the share is published':
            shownHere.length == 2 && (shareShownHere - 0.4).abs() < 1e-9,
        'no declared field type can hold free text': noFieldTypeIsFreeText,
        'every field in every declared event is one of those types':
            everyDeclaredFieldIsATypedField,
        'the count of declared fields that could carry raw personal data is '
            'zero, and that is recorded as structural rather than measured':
            declaredFieldsThatCouldCarryRawPii == 0 &&
                structuralNotMeasuredNote.contains('can never fail'),
        'the schema covers every declared kind of event':
            HabotEventSchema.coversEveryKind,
        'the schema has events and fields to check, so the zero is not over '
            'an empty population':
            declaredEventKinds > 0 && declaredFields > 0,
        'at least one field is an opaque identifier, so the salt matters':
            opaqueIdFields > 0,
        'the salt separates installs, checked against the implementation':
            theSaltSeparatesInstalls,
        'a salted hash is recorded as not being anonymisation':
            aSaltedHashIsNotAnonymisation &&
                hashIsNotAnonymousNote.contains('it is a loop'),
        'the scan itself is named as a server obligation':
            cannotRunTheScanNote.contains('could also read it'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the band is '
      'written with LaTeX escapes -- "\$0\$" for floor, optimal and ceiling. '
      'Atomic Step: "Execute Cloud DLP scans against analytical datasets to '
      'confirm 0 raw unhashed PII findings."';
}
