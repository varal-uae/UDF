/// AISS GATE -- Step 126 of 135
/// Global Reference ID:       GEN-02256
/// Atomic Steps Reference ID: GEN-02256
/// Atomic Step: "Establish secure websocket connections for silent security
///               assurance on mobile apps."
/// Metric: Process Execution Accuracy -- Floor 0.9, Optimal 0.97,
///         Ceiling 0.999.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// NO PACKAGE ADDED: the security rules are decidable against a URL and a
/// handshake with no I/O, so the policy is pure and the transport is an
/// interface with an in-memory implementation here.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/socket_transport.dart';

import 'aiss_reporter.dart';

/// An in-memory transport. Records what it was asked to do, so a gate can
/// assert that a refusal never reached it.
class _FakeTransport implements HabotSocketTransport {
  _FakeTransport({this.protocol = 'habot.v1'});

  final String protocol;

  int opens = 0;
  int closes = 0;
  final List<String> sent = <String>[];
  final StreamController<String> _in = StreamController<String>.broadcast();

  HabotSocketStatus _status = HabotSocketStatus.closed;

  @override
  HabotSocketStatus get status => _status;

  @override
  String? get negotiatedProtocol =>
      _status == HabotSocketStatus.open ? protocol : null;

  @override
  Stream<String> get inbound => _in.stream;

  @override
  Future<void> open(String url, {required String token}) async {
    opens++;
    _status = HabotSocketStatus.open;
  }

  @override
  Future<void> send(String message) async => sent.add(message);

  @override
  Future<void> close() async {
    closes++;
    _status = HabotSocketStatus.closed;
  }
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  double accuracy = 0;
  int casesChecked = 0;

  const HabotSocketPolicy policy = HabotSocketPolicy(
    allowedHosts: <String>{'stream.habot.example', 'eu.stream.habot.example'},
    subprotocol: 'habot.v1',
  );

  void gate(
    String id,
    String source,
    String description,
    Future<bool> Function() run,
  ) {
    test('[$id] $description', () async {
      bool passed = false;
      try {
        passed = await run();
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

  group('GEN-02256 :: the connection is safe or it does not open', () {
    gate(
      'GEN-02256-G1',
      'Atomic Step: "establish SECURE websocket connections".',
      'A cleartext ws:// endpoint is refused with the scheme named, and the '
          'only permitted scheme is declared once so a gate can assert there '
          'is no second one',
      () async {
        final HabotSocketVerdict v = policy.evaluate(
          url: 'ws://stream.habot.example/live',
          token: 'tok',
        );
        return !v.allowed &&
            v.refusal == HabotSocketRefusal.notEncrypted &&
            v.detail!.contains('"ws" is not wss') &&
            HabotSocketPolicy.scheme == 'wss';
      },
    );

    gate(
      'GEN-02256-G2',
      'A wildcard is how a staging host ends up trusted in production, and '
          'nobody notices because nothing visibly breaks.',
      'Hosts are an exact allow-list: a look-alike host and a host that merely '
          'ends with an allowed one are both refused',
      () async {
        final List<String> hostile = <String>[
          'wss://stream.habot.example.attacker.tld/live',
          'wss://evil-stream.habot.example/live',
          'wss://other.example/live',
        ];
        return hostile.every((String u) {
          final HabotSocketVerdict v = policy.evaluate(url: u, token: 'tok');
          return !v.allowed &&
              v.refusal == HabotSocketRefusal.hostNotAllowed;
        });
      },
    );

    gate(
      'GEN-02256-G3',
      'An unauthenticated socket is an open channel to whatever the server '
          'streams.',
      'A missing or blank credential is refused, and a malformed endpoint is '
          'refused as malformed rather than falling through to another reason',
      () async {
        final HabotSocketVerdict noToken = policy.evaluate(
          url: 'wss://stream.habot.example/live',
          token: null,
        );
        final HabotSocketVerdict blank = policy.evaluate(
          url: 'wss://stream.habot.example/live',
          token: '   ',
        );
        final HabotSocketVerdict junk = policy.evaluate(
          url: 'not a url at all',
          token: 'tok',
        );
        return noToken.refusal == HabotSocketRefusal.unauthenticated &&
            blank.refusal == HabotSocketRefusal.unauthenticated &&
            junk.refusal == HabotSocketRefusal.malformedEndpoint;
      },
    );

    gate(
      'GEN-02256-G4',
      'A handshake that returns without the negotiated protocol is a server '
          'that did not understand us; talking to it anyway is how a client '
          'parses something it did not expect.',
      'A downgraded handshake is refused AFTER the open and the socket is '
          'closed again, rather than being left open and unused',
      () async {
        final _FakeTransport downgraded = _FakeTransport(protocol: 'other');
        final HabotSecureSocket socket = HabotSecureSocket(
          policy: policy,
          transport: downgraded,
        );
        final HabotSocketVerdict v = await socket.connect(
          url: 'wss://stream.habot.example/live',
          token: 'tok',
        );
        return !v.allowed &&
            v.refusal == HabotSocketRefusal.protocolDowngrade &&
            downgraded.opens == 1 &&
            downgraded.closes == 1 &&
            downgraded.status == HabotSocketStatus.closed;
      },
    );
  });

  group('GEN-02256 :: silent to the user, loud in the evidence', () {
    gate(
      'GEN-02256-G5',
      '"Silent security assurance" means the USER is never asked to make a '
          'security decision -- not that the refusal is invisible.',
      'A refused endpoint never reaches the transport at all, and every '
          'refusal is recorded with its reason for the evidence',
      () async {
        final _FakeTransport t = _FakeTransport();
        final HabotSecureSocket socket = HabotSecureSocket(
          policy: policy,
          transport: t,
        );
        await socket.connect(
          url: 'ws://stream.habot.example/live',
          token: 'tok',
        );
        await socket.connect(url: 'wss://evil.example/live', token: 'tok');
        return t.opens == 0 &&
            socket.attempts == 2 &&
            socket.refused == 2 &&
            socket.verdicts.every(
              (HabotSocketVerdict v) => v.detail != null,
            ) &&
            HabotSecureSocket.silentAssuranceReading.contains(
              'never asked to make a security decision',
            );
      },
    );

    gate(
      'GEN-02256-G6',
      'A guard that refuses everything is not a guard either.',
      'A well-formed endpoint on an allowed host with a credential and a '
          'matching subprotocol DOES open',
      () async {
        final _FakeTransport t = _FakeTransport();
        final HabotSecureSocket socket = HabotSecureSocket(
          policy: policy,
          transport: t,
        );
        final HabotSocketVerdict v = await socket.connect(
          url: 'wss://eu.stream.habot.example/live',
          token: 'tok',
        );
        return v.allowed &&
            t.opens == 1 &&
            t.closes == 0 &&
            t.status == HabotSocketStatus.open &&
            socket.refused == 0;
      },
    );

    gate(
      'GEN-02256-G7',
      'Metric: Process Execution Accuracy, 0.9 / 0.97 / 0.999. Read as: over '
          'endpoints whose correct outcome is known, the share classified '
          'correctly.',
      'Across the declared case set the policy is right every time -- and the '
          'accuracy function is capable of reporting less than 1, so the '
          'figure means something',
      () async {
        const List<(String, String?, bool)> cases = <(String, String?, bool)>[
          ('wss://stream.habot.example/live', 'tok', true),
          ('wss://eu.stream.habot.example/live', 'tok', true),
          ('ws://stream.habot.example/live', 'tok', false),
          ('wss://stream.habot.example.attacker.tld/live', 'tok', false),
          ('wss://other.example/live', 'tok', false),
          ('wss://stream.habot.example/live', null, false),
          ('wss://stream.habot.example/live', '  ', false),
          ('nonsense', 'tok', false),
        ];
        final List<bool> expected = <bool>[];
        final List<bool> actual = <bool>[];
        for (final (String url, String? token, bool ok) in cases) {
          expected.add(ok);
          actual.add(policy.evaluate(url: url, token: token).allowed);
        }
        accuracy = HabotSecureSocket.executionAccuracy(
          expectedAllowed: expected,
          actualAllowed: actual,
        );
        casesChecked = cases.length;
        final double deliberatelyWrong = HabotSecureSocket.executionAccuracy(
          expectedAllowed: <bool>[true, true],
          actualAllowed: <bool>[true, false],
        );
        return accuracy == 1.0 &&
            accuracy >= HabotSecureSocket.ceiling &&
            deliberatelyWrong == 0.5 &&
            HabotSecureSocket.packageNote.contains('web_socket_channel');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02256',
        atomicStepReferenceId: 'GEN-02256',
        setupStepAction:
            'Establish secure websocket connections for silent security '
            'assurance on mobile apps.',
        implementationOrder: 126,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSocketPolicy / HabotSecureSocket',
          'Component Properties':
              'wss only; exact host allow-list; credential required; '
              'subprotocol checked after the handshake; '
              '${HabotSocketRefusal.values.length} named refusal reasons, all '
              'silent to the user and recorded in full',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row. No websocket package '
              'was added -- web_socket_channel cannot be resolved here, and '
              'the rules are decidable without I/O.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Accuracy (endpoint classification)',
            observed:
                '${accuracy.toStringAsFixed(3)} over $casesChecked endpoints '
                'whose correct outcome was declared in advance, including two '
                'that must be allowed and six that must be refused. The '
                'accuracy function was separately shown to report 0.5 on a '
                'deliberately wrong pairing, so a perfect score here is a '
                'result rather than an artefact.',
            floor: '0.9',
            optimal: '0.97',
            ceiling: '0.999',
          ),
          const AissMeasurement(
            metricName: 'Live socket behaviour',
            observed:
                'NOT PRODUCED. No socket is opened: the transport is an '
                'interface and this gate supplies an in-memory one. What was '
                'measured is the decision layer, which is the part that '
                'determines whether a connection is safe and is fully '
                'decidable without I/O.',
            floor: 'no live server available',
            optimal: 'no live server available',
            ceiling: 'no live server available',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/socket_transport.dart',
        ],
      ),
    );
  });
}
