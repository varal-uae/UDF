/// AISS Step 156 -- GEN-03448
/// Setup Step (Action) / Atomic Step: "Standardize UX telemetry event schemas
///   across all mobile views."
/// Metric: UX Telemetry Schema Match -- Floor 1.0, Optimal 1.0, Ceiling 1.0.
/// Best Qualitative Output: Complete.
/// Poka-Yoke: "CI/CD pipeline physically blocks deployment if any gate for
///             this step fails."
/// GCP alignment: "All step execution events stream to BigQuery partitioned by
///                 event_date, clustered by trace_id."
///
/// **THE FIRST STEP OF THE INSTRUMENTATION LAYER, AND IT HAS TO COME FIRST.**
/// Steps 157-165 all emit events. If each of them invents its own shape, the
/// warehouse ends up with twelve near-identical event families that cannot be
/// joined, and the only way to answer "did the form abandonment go up after we
/// shipped the wizard" is a human reading two dashboards side by side. So the
/// schema is declared once, here, and every later step in this batch is built
/// against it.
///
/// **A 1.0 FLOOR MEANS THE SCHEMA IS A TYPE, NOT A CONVENTION.** Floor,
/// optimal and ceiling are all 1.0: every event matches the schema or the step
/// fails. A convention documented in a wiki matches about 80% of events by the
/// second sprint. [HabotEvent] therefore cannot be constructed without its
/// required envelope, and [HabotEventSchema.validate] is what the CI gate runs.
///
/// **THE ENVELOPE IS FIXED; THE PAYLOAD IS NOT.** Every event carries the same
/// seven envelope fields — name, view, trace id, event date, occurred-at,
/// schema version and session ordinal — and whatever payload its own kind
/// needs. That split is the whole design: the envelope is what makes events
/// joinable, and the payload is what makes them worth joining. The GCP row
/// names `event_date` and `trace_id` specifically, and both are envelope
/// fields rather than payload, so partitioning and clustering cannot depend on
/// a field some event kinds forgot to send.
///
/// **`trace_id` IS THE FIELD THAT MAKES THIS WORTH DOING.** One user action
/// produces a funnel event (Step 160), possibly a crash (Step 159), a
/// performance trace (Step 164) and an outbox record (Step 117). Sharing a
/// trace id means the crash can be attributed to the step the user was on;
/// without it, the crash rate and the drop-off rate are two unrelated numbers
/// that happen to move together.
///
/// **NO PAYLOAD FIELD MAY CARRY FREE TEXT.** Free text is where personal data
/// gets into a warehouse, and no amount of downstream sanitising reliably gets
/// it out. Step 157 sanitises what does flow; this schema stops most of it
/// being emitted in the first place, which is the cheaper half of the same
/// problem.
library;

/// The kinds of event this app emits. A closed set, because an open one is a
/// schema that cannot be validated.
enum HabotEventKind {
  /// A view became visible. The unit the funnel is built from.
  viewOpened,

  /// A step in a multi-step flow completed (Step 160).
  stepCompleted,

  /// A flow was abandoned without completing (Steps 160, 163).
  flowAbandoned,

  /// A validation error was shown to the user (Step 163).
  validationRejected,

  /// A search returned nothing (Step 175).
  searchEmpty,

  /// A performance timing was captured (Step 164).
  timingCaptured,

  /// An unhandled error was captured (Step 159).
  errorCaptured,

  /// A health probe completed (Step 162).
  probeCompleted,
}

/// The type a payload field may hold. Deliberately excludes free text.
enum HabotFieldType {
  /// A member of a declared enum, sent as its name.
  enumeration,

  /// A whole number.
  integer,

  /// A duration in milliseconds, held as an integer.
  durationMs,

  /// True or false.
  boolean,

  /// An opaque, non-reversible identifier — a hash or a generated id.
  /// Never a name, an email or anything a person typed.
  opaqueId,
}

/// One payload field a kind of event is allowed to carry.
class HabotEventField {
  const HabotEventField({
    required this.name,
    required this.type,
    required this.required_,
    required this.why,
  });

  final String name;
  final HabotFieldType type;
  final bool required_;

  /// What question this field exists to answer. A field with no question
  /// behind it is a field nobody will ever query and everybody has to carry.
  final String why;
}

/// The payload shape for one kind of event.
class HabotEventDefinition {
  const HabotEventDefinition({
    required this.kind,
    required this.fields,
    required this.owningStep,
  });

  final HabotEventKind kind;
  final List<HabotEventField> fields;
  final String owningStep;

  Iterable<HabotEventField> get requiredFields =>
      fields.where((HabotEventField f) => f.required_);
}

/// One emitted event.
class HabotEvent {
  const HabotEvent({
    required this.kind,
    required this.view,
    required this.traceId,
    required this.occurredAt,
    required this.sessionOrdinal,
    this.payload = const <String, Object?>{},
  });

  final HabotEventKind kind;

  /// Which screen produced it. Required, because "the funnel dropped" without
  /// a view is a fact nobody can act on.
  final String view;

  /// Shared across every event, trace, crash and outbox record produced by one
  /// user action. See the header.
  final String traceId;

  final DateTime occurredAt;

  /// Position within the session. Lets a drop-off be distinguished from a
  /// first action without joining to anything.
  final int sessionOrdinal;

  final Map<String, Object?> payload;

  /// The partition key the GCP row names.
  String get eventDate {
    final DateTime d = occurredAt.toUtc();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  Map<String, Object?> toRow() => <String, Object?>{
        'event_name': kind.name,
        'view': view,
        'trace_id': traceId,
        'event_date': eventDate,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        'schema_version': HabotEventSchema.version,
        'session_ordinal': sessionOrdinal,
        ...payload,
      };
}

/// Why an event failed validation.
enum HabotSchemaViolation {
  unknownKind,
  missingEnvelopeField,
  missingRequiredField,
  undeclaredField,
  wrongType,
  freeTextField,
}

/// One failure, with enough detail to fix it.
class HabotSchemaFinding {
  const HabotSchemaFinding({
    required this.violation,
    required this.field,
    required this.detail,
  });

  final HabotSchemaViolation violation;
  final String field;
  final String detail;

  @override
  String toString() => '${violation.name} on "$field": $detail';
}

/// The declared schema.
class HabotEventSchema {
  const HabotEventSchema._();

  /// Bumped when the envelope changes. Carried on every row so a warehouse
  /// query can tell two shapes apart rather than guessing from which fields
  /// happen to be null.
  static const String version = '1.0.0';

  /// The fields every event carries, whatever its kind.
  static const List<String> envelope = <String>[
    'event_name',
    'view',
    'trace_id',
    'event_date',
    'occurred_at',
    'schema_version',
    'session_ordinal',
  ];

  /// The two the GCP alignment row names by name.
  static const String partitionField = 'event_date';
  static const String clusterField = 'trace_id';

  static const List<HabotEventDefinition> definitions =
      <HabotEventDefinition>[
    HabotEventDefinition(
      kind: HabotEventKind.viewOpened,
      owningStep: 'Step 156 GEN-03448',
      fields: <HabotEventField>[
        HabotEventField(
          name: 'entry_point',
          type: HabotFieldType.enumeration,
          required_: true,
          why: 'Separates a deep link arrival from ordinary navigation, which '
              'is what makes Step 171 measurable.',
        ),
      ],
    ),
    HabotEventDefinition(
      kind: HabotEventKind.stepCompleted,
      owningStep: 'Step 160 GEN-04649',
      fields: <HabotEventField>[
        HabotEventField(
          name: 'flow_id',
          type: HabotFieldType.opaqueId,
          required_: true,
          why: 'Which multi-step flow this belongs to.',
        ),
        HabotEventField(
          name: 'step_index',
          type: HabotFieldType.integer,
          required_: true,
          why: 'Position in the flow. Drop-off is computed from this.',
        ),
        HabotEventField(
          name: 'step_count',
          type: HabotFieldType.integer,
          required_: true,
          why: 'Without it, step 4 of 5 and step 4 of 40 look identical.',
        ),
        HabotEventField(
          name: 'time_on_step_ms',
          type: HabotFieldType.durationMs,
          required_: true,
          why: 'The row names time-per-step explicitly.',
        ),
      ],
    ),
    HabotEventDefinition(
      kind: HabotEventKind.flowAbandoned,
      owningStep: 'Step 160 GEN-04649',
      fields: <HabotEventField>[
        HabotEventField(
          name: 'flow_id',
          type: HabotFieldType.opaqueId,
          required_: true,
          why: 'Which flow was left.',
        ),
        HabotEventField(
          name: 'step_index',
          type: HabotFieldType.integer,
          required_: true,
          why: 'Where they stopped -- the only part of an abandonment that is '
              'actionable.',
        ),
        HabotEventField(
          name: 'had_visible_error',
          type: HabotFieldType.boolean,
          required_: true,
          why: 'Step 163 exists to separate "gave up" from "was blocked", and '
              'this is the field that does it.',
        ),
      ],
    ),
    HabotEventDefinition(
      kind: HabotEventKind.validationRejected,
      owningStep: 'Step 163 GEN-01076',
      fields: <HabotEventField>[
        HabotEventField(
          name: 'cde',
          type: HabotFieldType.enumeration,
          required_: true,
          why: 'Which Critical Data Element rejected the entry. An enum, not '
              'the field label, which is translated and would fragment the '
              'counts by language.',
        ),
        HabotEventField(
          name: 'attempt_index',
          type: HabotFieldType.integer,
          required_: true,
          why: 'A first rejection is a typo; a fourth is a field nobody can '
              'satisfy.',
        ),
      ],
    ),
    HabotEventDefinition(
      kind: HabotEventKind.searchEmpty,
      owningStep: 'Step 175 GEN-01132',
      fields: <HabotEventField>[
        HabotEventField(
          name: 'query_hash',
          type: HabotFieldType.opaqueId,
          required_: true,
          why: 'Groups repeats of the same query without carrying what the '
              'user typed. See Step 175 for why the raw text does not travel.',
        ),
        HabotEventField(
          name: 'term_count',
          type: HabotFieldType.integer,
          required_: true,
          why: 'A one-word miss is a catalogue gap; a nine-word miss is '
              'someone pasting a sentence.',
        ),
        HabotEventField(
          name: 'had_filters',
          type: HabotFieldType.boolean,
          required_: true,
          why: 'Separates "we do not stock it" from "the filters excluded it".',
        ),
      ],
    ),
    HabotEventDefinition(
      kind: HabotEventKind.timingCaptured,
      owningStep: 'Step 164 GEN-04253',
      fields: <HabotEventField>[
        HabotEventField(
          name: 'timing_kind',
          type: HabotFieldType.enumeration,
          required_: true,
          why: 'Cold start, warm start or interactivity -- three different '
              'budgets, and averaging them produces a number that describes '
              'nothing.',
        ),
        HabotEventField(
          name: 'elapsed_ms',
          type: HabotFieldType.durationMs,
          required_: true,
          why: 'The measurement.',
        ),
        HabotEventField(
          name: 'foreground',
          type: HabotFieldType.boolean,
          required_: true,
          why: 'Step 166 drops background traces, and this is the field it '
              'drops them by.',
        ),
      ],
    ),
    HabotEventDefinition(
      kind: HabotEventKind.errorCaptured,
      owningStep: 'Step 159 GEN-01054',
      fields: <HabotEventField>[
        HabotEventField(
          name: 'error_class',
          type: HabotFieldType.enumeration,
          required_: true,
          why: 'Unhandled, network timeout or UI break -- the three the row '
              'names.',
        ),
        HabotEventField(
          name: 'fingerprint',
          type: HabotFieldType.opaqueId,
          required_: true,
          why: 'Groups one defect across thousands of sessions. Derived from '
              'the scrubbed frames, never from the message.',
        ),
        HabotEventField(
          name: 'fatal',
          type: HabotFieldType.boolean,
          required_: true,
          why: 'The crash-free session rate counts fatal errors only; a '
              'handled network timeout is not a crash.',
        ),
      ],
    ),
    HabotEventDefinition(
      kind: HabotEventKind.probeCompleted,
      owningStep: 'Step 162 GEN-01021',
      fields: <HabotEventField>[
        HabotEventField(
          name: 'probe',
          type: HabotFieldType.enumeration,
          required_: true,
          why: 'Which dependency was probed.',
        ),
        HabotEventField(
          name: 'healthy',
          type: HabotFieldType.boolean,
          required_: true,
          why: 'The outcome.',
        ),
        HabotEventField(
          name: 'rtt_ms',
          type: HabotFieldType.durationMs,
          required_: true,
          why: 'A probe that succeeds slowly is a dependency about to fail.',
        ),
      ],
    ),
  ];

  static HabotEventDefinition definitionOf(HabotEventKind kind) =>
      definitions.firstWhere((HabotEventDefinition d) => d.kind == kind);

  static bool get coversEveryKind =>
      definitions.map((HabotEventDefinition d) => d.kind).toSet().length ==
      HabotEventKind.values.length;

  /// Validate one event against the schema.
  ///
  /// An empty list is a match. The findings are typed rather than strings, so
  /// the CI gate can say *which* rule an event broke rather than that it
  /// "failed validation".
  static List<HabotSchemaFinding> validate(HabotEvent event) {
    final List<HabotSchemaFinding> out = <HabotSchemaFinding>[];
    final Map<String, Object?> row = event.toRow();

    for (final String f in envelope) {
      final Object? v = row[f];
      if (v == null || (v is String && v.trim().isEmpty)) {
        out.add(
          HabotSchemaFinding(
            violation: HabotSchemaViolation.missingEnvelopeField,
            field: f,
            detail: 'Every event carries the full envelope; this one does not.',
          ),
        );
      }
    }

    final HabotEventDefinition def = definitionOf(event.kind);
    final Map<String, HabotEventField> declared = <String, HabotEventField>{
      for (final HabotEventField f in def.fields) f.name: f,
    };

    for (final HabotEventField f in def.requiredFields) {
      if (!event.payload.containsKey(f.name) ||
          event.payload[f.name] == null) {
        out.add(
          HabotSchemaFinding(
            violation: HabotSchemaViolation.missingRequiredField,
            field: f.name,
            detail: f.why,
          ),
        );
      }
    }

    for (final MapEntry<String, Object?> e in event.payload.entries) {
      final HabotEventField? field = declared[e.key];
      if (field == null) {
        out.add(
          HabotSchemaFinding(
            violation: HabotSchemaViolation.undeclaredField,
            field: e.key,
            detail: 'Not declared for ${event.kind.name}. An undeclared field '
                'is a column nobody agreed to store.',
          ),
        );
        continue;
      }
      final Object? v = e.value;
      if (v == null) {
        continue;
      }
      final bool ok;
      switch (field.type) {
        case HabotFieldType.integer:
        case HabotFieldType.durationMs:
          ok = v is int;
        case HabotFieldType.boolean:
          ok = v is bool;
        case HabotFieldType.enumeration:
        case HabotFieldType.opaqueId:
          ok = v is String;
      }
      if (!ok) {
        out.add(
          HabotSchemaFinding(
            violation: HabotSchemaViolation.wrongType,
            field: e.key,
            detail: 'Declared ${field.type.name}, got ${v.runtimeType}.',
          ),
        );
        continue;
      }
      if (v is String && looksLikeFreeText(v)) {
        out.add(
          HabotSchemaFinding(
            violation: HabotSchemaViolation.freeTextField,
            field: e.key,
            detail: 'Reads as something a person typed. Free text is how '
                'personal data reaches a warehouse, and no amount of '
                'downstream sanitising reliably gets it out again.',
          ),
        );
      }
    }
    return out;
  }

  /// A string with whitespace in it, or with characters an enum name or a
  /// generated id would not contain, is something a person typed.
  ///
  /// Deliberately crude and deliberately strict: the cost of a false positive
  /// is one field renamed, and the cost of a false negative is a name in a
  /// warehouse.
  static bool looksLikeFreeText(String value) {
    if (value.contains(' ')) {
      return true;
    }
    return RegExp(r'[@!?,;:"' r"'" r']').hasMatch(value);
  }

  static bool matches(HabotEvent event) => validate(event).isEmpty;

  /// The row's metric over a batch of events.
  static double schemaMatchRate(Iterable<HabotEvent> events) {
    final List<HabotEvent> all = events.toList();
    if (all.isEmpty) {
      return 1;
    }
    return all.where(matches).length / all.length;
  }

  static const double floor = 1.0;
  static const double optimal = 1.0;

  static const String envelopeNote =
      'The envelope is fixed and the payload is not. The envelope is what '
      'makes events joinable; the payload is what makes them worth joining. '
      'event_date and trace_id are envelope fields specifically because the '
      'GCP row partitions and clusters on them, and a partition key that some '
      'event kinds forget to send is a partition key that does not work.';

  static const String traceIdNote =
      'One user action produces a funnel event, possibly a crash, a '
      'performance trace and an outbox record. Sharing a trace id means the '
      'crash can be attributed to the step the user was on. Without it, the '
      'crash rate and the drop-off rate are two unrelated numbers that happen '
      'to move together.';

  static const String noFreeTextNote =
      'No payload field may carry free text. Free text is how personal data '
      'gets into a warehouse, and no amount of downstream sanitising reliably '
      'gets it out. Step 157 cleans what does flow; this schema stops most of '
      'it being emitted, which is the cheaper half of the same problem.';

  static const String schemaFirstNote =
      'This step comes first in the batch because Steps 157-165 all emit '
      'events. If each invents its own shape, the warehouse ends up with '
      'twelve near-identical event families that cannot be joined, and '
      '"did abandonment rise after the wizard shipped" becomes a person '
      'reading two dashboards side by side.';
}
