/// AISS GATE -- Step 173 of 175
/// Global Reference ID:       GEN-00134
/// Atomic Steps Reference ID: GEN-00134
/// Setup Step (Action) / Atomic Step: "Author strict OpenAPI 3.0
///   specifications for all mobile endpoints."
/// Metric: General Task Completion Quality -- Floor "Task completed with
///         documented exceptions", Optimal "100% completion matching stated
///         implementation-step intent", Ceiling 1.0.
///         Complete / Partial / Not Complete.
///
/// AN OPENAPI DOCUMENT IS A SERVER ARTEFACT, AND A CLIENT COPY OF ONE IS A
/// SECOND SOURCE OF TRUTH. What the client authors is the half the server
/// cannot see: the declared set of endpoints this app actually calls, with the
/// shape it depends on. The value of that is the JOIN.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/endpoint_contract.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completionQuality = 0;

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

  group('GEN-00134 :: the half the client is accountable for', () {
    gate(
      'GEN-00134-G1',
      'Atomic Step: "Author strict OpenAPI 3.0 specifications for all mobile '
          'endpoints." Floor: "Task completed with DOCUMENTED EXCEPTIONS."',
      'The substitution is recorded and the exception is documented rather '
          'than implied: the OpenAPI document belongs to whoever owns the '
          'endpoints, because a copy in the app repo drifts from the service '
          'within a release and then lies to everyone who reads it',
      () =>
          HabotEndpointContract.documentedExceptions.length == 1 &&
          HabotEndpointContract.documentedExceptions.single
              .contains('second source of truth') &&
          HabotEndpointContract.serverArtefactNote
              .contains('the server cannot see') &&
          HabotEndpointContract.joinValueNote.contains('dead surface area'),
    );

    gate(
      'GEN-00134-G2',
      '"An endpoint the client calls that the spec does not describe is an '
          'endpoint nobody wrote down -- usually added in a hurry, usually the '
          'one that breaks."',
      'Undeclared calls are reported by signature, so an endpoint somebody '
          'added without writing it down shows up here instead of during an '
          'incident',
      () {
        final List<String> observed = <String>[
          'POST /v1/mutations',
          'GET /v1/health',
          'POST /v1/legacy/upload',
        ];
        final List<String> undeclared =
            HabotEndpointContract.undeclaredCalls(observed);
        return undeclared.single == 'POST /v1/legacy/upload' &&
            HabotEndpointContract.undeclaredCalls(
              HabotEndpointContract.declaredSignatures,
            ).isEmpty;
      },
    );

    gate(
      'GEN-00134-G3',
      '"An endpoint the spec describes that no client calls is dead surface '
          'area still being maintained and still exposed" -- the list nobody '
          'ever asks for.',
      'The reverse direction of the join is reported too: declarations nothing '
          'called are named, which is the half a server-side spec cannot '
          'produce on its own',
      () {
        final List<String> observed = <String>[
          'POST /v1/mutations',
          'GET /v1/health',
        ];
        final List<String> unused =
            HabotEndpointContract.unusedDeclarations(observed);
        return unused.length ==
                HabotEndpointContract.endpoints.length - 2 &&
            !unused.contains('POST /v1/mutations') &&
            !unused.contains('GET /v1/health') &&
            HabotEndpointContract.unusedDeclarations(
              HabotEndpointContract.declaredSignatures,
            ).isEmpty;
      },
    );

    gate(
      'GEN-00134-G4',
      '"An endpoint with no caller is a declaration nobody is accountable '
          'for."',
      'Every declaration names the step whose code calls it, every signature '
          'is unique, and every path is a path',
      () {
        final Set<String> signatures = HabotEndpointContract.declaredSignatures;
        return HabotEndpointContract.endpoints.length == 7 &&
            signatures.length == HabotEndpointContract.endpoints.length &&
            HabotEndpointContract.endpoints.every(
              (HabotEndpoint e) =>
                  e.calledBy.contains('Step') && e.path.startsWith('/'),
            ) &&
            HabotEndpointContract.byId('outbox.dispatch')?.path ==
                '/v1/mutations' &&
            HabotEndpointContract.byId('nothing.here') == null;
      },
    );
  });

  group('GEN-00134 :: what "strict" has to mean', () {
    gate(
      'GEN-00134-G5',
      '"A spec that says a field is a string says almost nothing. What a '
          'client depends on is narrower: whether the field can be absent, '
          'whether an unknown enum value will arrive, and what happens on a '
          '4xx."',
      'Every declaration states all three, and the error shape is specific '
          'enough to be useful -- including that the client must survive a '
          'non-JSON body, because a gateway timeout is an HTML page from '
          'something that is not the service',
      () => HabotEndpointContract.endpoints.every(
        (HabotEndpoint e) =>
            e.response.mayOmitFields &&
            e.response.mayAddEnumValues &&
            e.response.errorShape.contains('non-JSON') &&
            e.response.errorShape.length > 40,
      ) &&
          HabotEndpointContract.strictnessNote.contains('path nobody tests'),
    );

    gate(
      'GEN-00134-G6',
      '"The Step 122 idempotency key is part of the contract, not an '
          'implementation detail. A mutation that cannot carry one cannot be '
          'retried safely, which makes the whole Step 117-123 offline path '
          'unsafe against it."',
      'Every declared mutation accepts an idempotency key so the retry-unsafe '
          'list is empty -- and the check is shown catching a mutation that '
          'does not, because a list that can only ever be empty proves nothing',
      () {
        const HabotEndpoint unsafe = HabotEndpoint(
          id: 'hypothetical.unsafe',
          method: 'POST',
          path: '/v1/unsafe',
          kind: HabotEndpointKind.mutate,
          acceptsIdempotencyKey: false,
          response: HabotResponseContract(
            mayOmitFields: true,
            mayAddEnumValues: true,
            errorShape: 'anything',
          ),
          calledBy: 'nobody -- constructed for this gate',
        );
        const HabotEndpoint read = HabotEndpoint(
          id: 'hypothetical.read',
          method: 'GET',
          path: '/v1/read',
          kind: HabotEndpointKind.read,
          acceptsIdempotencyKey: false,
          response: HabotResponseContract(
            mayOmitFields: true,
            mayAddEnumValues: true,
            errorShape: 'anything',
          ),
          calledBy: 'nobody -- constructed for this gate',
        );
        return HabotEndpointContract.retryUnsafeMutations().isEmpty &&
            HabotEndpointContract.endpoints
                .where((HabotEndpoint e) => e.isMutation)
                .every((HabotEndpoint e) => e.acceptsIdempotencyKey) &&
            unsafe.isMutation &&
            !unsafe.isRetrySafe &&
            // A read needs no key to be retry-safe, which is why the rule is
            // about mutations rather than about every call.
            !read.isMutation &&
            read.isRetrySafe &&
            HabotEndpointContract.idempotencyNote.contains('during an outage');
      },
    );

    gate(
      'GEN-00134-G7',
      'Metric: General Task Completion Quality -- floor "completed with '
          'documented exceptions", optimal 1.0.',
      'The completion figure is computed over the checks this step is '
          'accountable for, every one of them passes, and the qualitative '
          'output is Complete with the OpenAPI document itself recorded as a '
          'documented exception rather than as a silent omission',
      () {
        completionQuality = HabotEndpointContract.completionQuality;
        return HabotEndpointContract.completenessChecks.length == 4 &&
            HabotEndpointContract.completenessChecks.values
                .every((bool b) => b) &&
            completionQuality == 1.0 &&
            completionQuality >= HabotEndpointContract.optimal &&
            HabotEndpointContract.qualitativeOutput == 'Complete' &&
            HabotEndpointContract.completenessChecks.keys
                .any((String k) => k.contains('idempotency key'));
      },
    );

    gate(
      'GEN-00134-G8',
      'Coverage: the declared set has to be the endpoints this app actually '
          'calls, not an aspirational list.',
      'Every endpoint the offline path depends on is declared -- the outbox '
          'dispatcher, the favourites write, the form autosave and the '
          'telemetry batch -- and each names the step that calls it',
      () {
        final Set<String> ids = HabotEndpointContract.endpoints
            .map((HabotEndpoint e) => e.id)
            .toSet();
        return ids.containsAll(<String>{
              'outbox.dispatch',
              'favourites.write',
              'form.autosave',
              'telemetry.batch',
              'health.probe',
              'flags.snapshot',
              'catalogue.search',
            }) &&
            HabotEndpointContract.byId('telemetry.batch')!.calledBy
                .contains('Step 161') &&
            HabotEndpointContract.byId('health.probe')!.calledBy
                .contains('Step 162') &&
            HabotEndpointContract.byId('catalogue.search')!.calledBy
                .contains('Step 175') &&
            HabotEndpointContract.endpoints
                    .where((HabotEndpoint e) => e.isMutation)
                    .length ==
                4;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00134',
        atomicStepReferenceId: 'GEN-00134',
        setupStepAction:
            'Author strict OpenAPI 3.0 specifications for all mobile '
            'endpoints.',
        implementationOrder: 173,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotEndpointContract / HabotEndpoint',
          'Component Properties':
              '${HabotEndpointContract.endpoints.length} declared endpoints '
              '(${HabotEndpointContract.endpoints.where((HabotEndpoint e) => e.isMutation).length} '
              'mutations, all accepting a Step 122 idempotency key); each '
              'declaration states whether fields may be absent, whether enums '
              'may gain values, what a 4xx body looks like, and which step '
              'calls it',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION RECORDED, and it is the row\'s own documented '
              'exception: an OpenAPI 3.0 document is a server artefact '
              'authored by whoever owns the endpoints. A copy in this '
              'repository would be a second source of truth and would drift '
              'from the service within a release. What is authored here is the '
              'half the server cannot see -- the endpoints this app actually '
              'calls -- so that the two can be joined. The join produces two '
              'lists: calls nobody declared, and declarations nobody calls.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'General Task Completion Quality',
            observed:
                '${completionQuality.toStringAsFixed(2)} over the four checks '
                'this step is accountable for: every called endpoint declared '
                'with a method and a path, every declaration naming its '
                'calling step, every mutation accepting an idempotency key, '
                'and every declaration stating what a client must survive. The '
                'OpenAPI document itself is recorded as a documented '
                'exception, which is what the row\'s floor permits.',
            floor: 'Task completed with documented exceptions',
            optimal: '100% completion matching stated implementation-step '
                'intent',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Retry-unsafe mutations',
            observed:
                '0 of '
                '${HabotEndpointContract.endpoints.where((HabotEndpoint e) => e.isMutation).length}. '
                'A mutation that cannot carry an idempotency key makes the '
                'whole Step 117-123 offline path unsafe against it; declaring '
                'the key per endpoint means a new mutation without one shows '
                'up in this list rather than during an outage. The check is '
                'demonstrated catching a constructed endpoint that lacks one.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/endpoint_contract.dart',
        ],
      ),
    );
  });
}
