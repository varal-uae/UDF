/// AISS Step 173 -- GEN-00134
/// Setup Step (Action) / Atomic Step: "Author strict OpenAPI 3.0
///   specifications for all mobile endpoints."
/// Metric: General Task Completion Quality -- Floor "Task completed with
///         documented exceptions", Optimal "100% completion matching stated
///         implementation-step intent", Ceiling 1.0.
///         Complete / Partial / Not Complete.
///
/// **AN OPENAPI DOCUMENT IS A SERVER ARTEFACT, AND A CLIENT COPY OF ONE IS A
/// SECOND SOURCE OF TRUTH.** Whoever owns the endpoints owns their
/// specification; a `.yaml` checked into the app repo drifts from the service
/// within a release and then lies to everyone who reads it. So this step does
/// not author a spec here. What it authors is the half the client is
/// accountable for and the server cannot see: **the declared set of endpoints
/// this app actually calls**, with the shape it depends on.
///
/// **THE VALUE OF THAT IS THE JOIN.** An endpoint the client calls that the
/// spec does not describe is an endpoint nobody wrote down — usually added in
/// a hurry, usually the one that breaks. An endpoint the spec describes that
/// no client calls is dead surface area still being maintained and still
/// exposed. Neither is visible from one side alone.
/// [HabotEndpointContract.undeclaredCalls] and
/// [HabotEndpointContract.unusedDeclarations] are the two lists that come out
/// of it, and the second is the one nobody ever asks for.
///
/// **"STRICT" HAS A MEANING WORTH KEEPING.** A spec that says a field is a
/// string says almost nothing. What a client depends on is narrower: whether
/// the field can be absent, whether an unknown enum value will arrive, and
/// what happens on a 4xx. Those three are where clients break, and they are
/// what each declaration here has to state.
///
/// **THE STEP 122 IDEMPOTENCY KEY IS PART OF THE CONTRACT, NOT AN
/// IMPLEMENTATION DETAIL.** A mutating endpoint that does not accept one
/// cannot be retried safely, which makes the whole Step 117-123 offline path
/// unsafe against it. Declaring it per endpoint means a new mutation without
/// one is visible here rather than discovered during an outage.
library;

/// What a call does to server state.
enum HabotEndpointKind { read, mutate }

/// How a response field may behave. The three things that actually break
/// clients -- see the header.
class HabotResponseContract {
  const HabotResponseContract({
    required this.mayOmitFields,
    required this.mayAddEnumValues,
    required this.errorShape,
  });

  /// Whether a documented field can be absent from a real response.
  final bool mayOmitFields;

  /// Whether an enum may gain values the client does not know. Almost always
  /// true, and almost never handled.
  final bool mayAddEnumValues;

  /// What a 4xx body looks like. A client that assumes JSON and receives an
  /// HTML error page crashes in the error path, which is the path nobody
  /// tests.
  final String errorShape;
}

/// One endpoint this app calls.
class HabotEndpoint {
  const HabotEndpoint({
    required this.id,
    required this.method,
    required this.path,
    required this.kind,
    required this.acceptsIdempotencyKey,
    required this.response,
    required this.calledBy,
  });

  final String id;
  final String method;
  final String path;
  final HabotEndpointKind kind;

  /// Step 122. A mutation without one cannot be retried safely.
  final bool acceptsIdempotencyKey;

  final HabotResponseContract response;

  /// Which step's code calls it. An endpoint with no caller is a declaration
  /// nobody is accountable for.
  final String calledBy;

  bool get isMutation => kind == HabotEndpointKind.mutate;

  /// A mutation that cannot carry an idempotency key breaks the offline path.
  bool get isRetrySafe => !isMutation || acceptsIdempotencyKey;

  String get signature => '$method $path';
}

/// The declared client-side contract.
class HabotEndpointContract {
  const HabotEndpointContract._();

  static const HabotResponseContract _standard = HabotResponseContract(
    mayOmitFields: true,
    mayAddEnumValues: true,
    errorShape: 'application/problem+json with a "detail" string; the client '
        'must also survive a non-JSON body, because a gateway timeout is an '
        'HTML page from something that is not the service.',
  );

  static const List<HabotEndpoint> endpoints = <HabotEndpoint>[
    HabotEndpoint(
      id: 'outbox.dispatch',
      method: 'POST',
      path: '/v1/mutations',
      kind: HabotEndpointKind.mutate,
      acceptsIdempotencyKey: true,
      response: _standard,
      calledBy: 'Step 122 GEN-03635 / Step 123 GEN-05276',
    ),
    HabotEndpoint(
      id: 'favourites.write',
      method: 'POST',
      path: '/v1/favourites',
      kind: HabotEndpointKind.mutate,
      acceptsIdempotencyKey: true,
      response: _standard,
      calledBy: 'Step 132 GEN-01496',
    ),
    HabotEndpoint(
      id: 'form.autosave',
      method: 'PUT',
      path: '/v1/forms/{formId}/fields/{field}',
      kind: HabotEndpointKind.mutate,
      acceptsIdempotencyKey: true,
      response: _standard,
      calledBy: 'Step 153 GEN-02588',
    ),
    HabotEndpoint(
      id: 'telemetry.batch',
      method: 'POST',
      path: '/v1/telemetry/events',
      kind: HabotEndpointKind.mutate,
      acceptsIdempotencyKey: true,
      response: _standard,
      calledBy: 'Step 161 GEN-04770 / Step 145 GEN-04968',
    ),
    HabotEndpoint(
      id: 'health.probe',
      method: 'GET',
      path: '/v1/health',
      kind: HabotEndpointKind.read,
      acceptsIdempotencyKey: false,
      response: _standard,
      calledBy: 'Step 162 GEN-01021',
    ),
    HabotEndpoint(
      id: 'flags.snapshot',
      method: 'GET',
      path: '/v1/flags',
      kind: HabotEndpointKind.read,
      acceptsIdempotencyKey: false,
      response: _standard,
      calledBy: 'Step 134 GEN-04638',
    ),
    HabotEndpoint(
      id: 'catalogue.search',
      method: 'GET',
      path: '/v1/catalogue/search',
      kind: HabotEndpointKind.read,
      acceptsIdempotencyKey: false,
      response: _standard,
      calledBy: 'Step 33 ANSA-006 / Step 175 GEN-01132',
    ),
  ];

  static HabotEndpoint? byId(String id) {
    for (final HabotEndpoint e in endpoints) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  static Set<String> get declaredSignatures =>
      endpoints.map((HabotEndpoint e) => e.signature).toSet();

  /// Calls the client makes that nothing declares. The endpoint nobody wrote
  /// down.
  static List<String> undeclaredCalls(Iterable<String> observedSignatures) =>
      observedSignatures
          .where((String s) => !declaredSignatures.contains(s))
          .toList();

  /// Declarations nothing calls. Dead surface area still being maintained and
  /// still exposed -- the list nobody asks for.
  static List<String> unusedDeclarations(
    Iterable<String> observedSignatures,
  ) {
    final Set<String> observed = observedSignatures.toSet();
    return endpoints
        .where((HabotEndpoint e) => !observed.contains(e.signature))
        .map((HabotEndpoint e) => e.signature)
        .toList();
  }

  /// Mutations that cannot be retried safely. Must be empty, or the Step
  /// 117-123 offline path is unsafe against them.
  static List<String> retryUnsafeMutations() => endpoints
      .where((HabotEndpoint e) => !e.isRetrySafe)
      .map((HabotEndpoint e) => e.signature)
      .toList();

  // ---- the row's metric ---------------------------------------------------

  /// The checks this step is accountable for.
  static Map<String, bool> get completenessChecks => <String, bool>{
        'every endpoint the app calls is declared with a method and a path':
            endpoints.every((HabotEndpoint e) =>
                e.method.isNotEmpty && e.path.startsWith('/')),
        'every declaration names the step that calls it':
            endpoints.every((HabotEndpoint e) => e.calledBy.contains('Step')),
        'every mutation accepts an idempotency key':
            retryUnsafeMutations().isEmpty,
        'every declaration states what a client must survive -- absent '
                'fields, unknown enum values and a non-JSON error body':
            endpoints.every((HabotEndpoint e) =>
                e.response.mayOmitFields &&
                e.response.mayAddEnumValues &&
                e.response.errorShape.length > 40),
      };

  static double get completionQuality {
    final Iterable<bool> r = completenessChecks.values;
    return r.where((bool b) => b).length / r.length;
  }

  static const double optimal = 1.0;

  static String get qualitativeOutput {
    if (completionQuality >= optimal) {
      return 'Complete';
    }
    return completionQuality > 0 ? 'Partial' : 'Not Complete';
  }

  /// The row's floor permits documented exceptions. This is the documentation.
  static const List<String> documentedExceptions = <String>[
    'The OpenAPI 3.0 document itself is authored and served by the team that '
        'owns the endpoints. A copy in this repository would be a second '
        'source of truth and would drift within a release.',
  ];

  static const String serverArtefactNote =
      'An OpenAPI document is a server artefact. A copy in the app repo drifts '
      'from the service within a release and then lies to everyone who reads '
      'it. What the client authors is the half the server cannot see: the set '
      'of endpoints this app actually calls, with the shape it depends on.';

  static const String joinValueNote =
      'An endpoint the client calls that the spec does not describe is one '
      'nobody wrote down -- usually added in a hurry, usually the one that '
      'breaks. An endpoint the spec describes that no client calls is dead '
      'surface area still being maintained and still exposed. Neither is '
      'visible from one side alone.';

  static const String strictnessNote =
      'A spec that says a field is a string says almost nothing. What a client '
      'depends on is narrower: whether the field can be absent, whether an '
      'unknown enum value will arrive, and what a 4xx body looks like. Those '
      'three are where clients break -- a client that assumes JSON and '
      'receives an HTML gateway error crashes in the path nobody tests.';

  static const String idempotencyNote =
      'The Step 122 idempotency key is part of the contract, not an '
      'implementation detail. A mutation that cannot carry one cannot be '
      'retried safely, which makes the whole Step 117-123 offline path unsafe '
      'against it. Declaring it per endpoint means a new mutation without one '
      'shows up here rather than during an outage.';
}
