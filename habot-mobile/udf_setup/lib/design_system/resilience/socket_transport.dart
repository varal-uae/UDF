/// AISS Step 126 -- GEN-02256
/// Atomic Step: "Establish secure websocket connections for silent security
///               assurance on mobile apps."
/// Metric: Process Execution Accuracy -- Floor 0.9, Optimal 0.97,
///         Ceiling 0.999.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// "SILENT SECURITY ASSURANCE", READ CAREFULLY, because the phrase invites the
/// wrong build. It does NOT mean the security is invisible to the developer --
/// it means the USER is not asked to do anything. There is no certificate
/// prompt, no "trust this connection?" dialog, no security toggle in settings.
/// The connection is either safe or it does not open, and the person using the
/// app never has to have an opinion about it.
///
/// That reading has a direct consequence: **every refusal below is silent to
/// the user and loud in the evidence.** A blocked connection surfaces as the
/// Step 125 offline chip, not as a security dialog nobody can answer.
///
/// NO PACKAGE IS ADDED, AND NO SOCKET IS OPENED HERE. `web_socket_channel`
/// cannot be resolved in this environment. More usefully, it should not be
/// this file's business: what a transport is, is a contract, and the security
/// rules are decidable against a URL and a handshake without any I/O at all.
/// So [HabotSocketPolicy] is pure and fully tested, [HabotSocketTransport] is
/// the interface a real client implements, and the test supplies an in-memory
/// one. Swapping in `web_socket_channel` later is a class, not a rewrite.
///
/// THE METRIC, READ HONESTLY. "Process Execution Accuracy" at 0.9/0.97/0.999
/// is a generic quality band. What this step can actually produce is the share
/// of connection attempts that were correctly classified -- allowed when they
/// should be, refused when they should be -- across a declared set of cases.
/// That is a real accuracy figure over a real process, and it is what is
/// reported. Nothing about live sockets is claimed.
library;

/// Why a connection was refused. Every one of these is silent to the user.
enum HabotSocketRefusal {
  /// `ws://` rather than `wss://`. Cleartext.
  notEncrypted,

  /// A host outside the declared allow-list.
  hostNotAllowed,

  /// No token, or an expired one.
  unauthenticated,

  /// The URL is malformed.
  malformedEndpoint,

  /// A downgrade: the handshake came back without the negotiated protocol.
  protocolDowngrade,
}

/// The outcome of evaluating one endpoint.
class HabotSocketVerdict {
  const HabotSocketVerdict._({required this.allowed, this.refusal, this.detail});

  const HabotSocketVerdict.allowed() : this._(allowed: true);

  const HabotSocketVerdict.refused(
    HabotSocketRefusal refusal,
    String detail,
  ) : this._(allowed: false, refusal: refusal, detail: detail);

  final bool allowed;
  final HabotSocketRefusal? refusal;
  final String? detail;

  Map<String, Object?> toJson() => <String, Object?>{
    'allowed': allowed,
    if (refusal != null) 'refusal': refusal!.name,
    if (detail != null) 'detail': detail,
  };
}

/// The rules. Pure, so they are decidable without a network.
class HabotSocketPolicy {
  const HabotSocketPolicy({
    required this.allowedHosts,
    required this.subprotocol,
  });

  /// Exact hosts this app will open a socket to. A list rather than a pattern
  /// on purpose: a wildcard is how a staging host ends up trusted in
  /// production, and nobody notices because nothing visibly breaks.
  final Set<String> allowedHosts;

  /// The application subprotocol. Checked on the way back -- a handshake that
  /// returns without it is a server that did not understand us, and talking to
  /// it anyway is how a client ends up parsing something it did not expect.
  final String subprotocol;

  /// The one permitted scheme. Declared as a constant rather than written
  /// inline so a gate can assert there is no second one.
  static const String scheme = 'wss';

  HabotSocketVerdict evaluate({
    required String url,
    required String? token,
  }) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      return HabotSocketVerdict.refused(
        HabotSocketRefusal.malformedEndpoint,
        '"$url" is not a usable endpoint',
      );
    }
    if (uri.scheme != scheme) {
      return HabotSocketVerdict.refused(
        HabotSocketRefusal.notEncrypted,
        '"${uri.scheme}" is not $scheme. A cleartext socket carries a worker '
            'task payloads over any network they happen to be on, and no '
            'prompt makes that acceptable.',
      );
    }
    if (!allowedHosts.contains(uri.host)) {
      return HabotSocketVerdict.refused(
        HabotSocketRefusal.hostNotAllowed,
        '"${uri.host}" is not in the allow-list '
            '(${allowedHosts.join(", ")})',
      );
    }
    if (token == null || token.trim().isEmpty) {
      return HabotSocketVerdict.refused(
        HabotSocketRefusal.unauthenticated,
        'no credential was supplied; an unauthenticated socket is an open '
            'channel to whatever the server streams',
      );
    }
    return const HabotSocketVerdict.allowed();
  }

  /// Checked after the handshake. See [subprotocol].
  HabotSocketVerdict evaluateHandshake(String? negotiated) =>
      negotiated == subprotocol
      ? const HabotSocketVerdict.allowed()
      : HabotSocketVerdict.refused(
          HabotSocketRefusal.protocolDowngrade,
          'the server negotiated ${negotiated ?? "nothing"} rather than '
              '"$subprotocol"',
        );
}

/// What the socket is doing.
enum HabotSocketStatus { closed, opening, open, closing }

/// The transport contract. A real implementation wraps a websocket package;
/// the test supplies an in-memory one. Neither is this file's business.
abstract interface class HabotSocketTransport {
  HabotSocketStatus get status;

  /// The subprotocol the server negotiated, once open.
  String? get negotiatedProtocol;

  Stream<String> get inbound;

  Future<void> open(String url, {required String token});

  Future<void> send(String message);

  Future<void> close();
}

/// Opens sockets, or refuses to, and keeps the score.
class HabotSecureSocket {
  HabotSecureSocket({required this.policy, required this.transport});

  final HabotSocketPolicy policy;
  final HabotSocketTransport transport;

  final List<HabotSocketVerdict> _verdicts = <HabotSocketVerdict>[];

  List<HabotSocketVerdict> get verdicts =>
      List<HabotSocketVerdict>.unmodifiable(_verdicts);

  int get attempts => _verdicts.length;
  int get refused =>
      _verdicts.where((HabotSocketVerdict v) => !v.allowed).length;

  /// Evaluate, then open only if allowed. A refusal never reaches the
  /// transport, which is what makes the rule structural rather than advisory.
  Future<HabotSocketVerdict> connect({
    required String url,
    required String? token,
  }) async {
    final HabotSocketVerdict verdict = policy.evaluate(
      url: url,
      token: token,
    );
    _verdicts.add(verdict);
    if (!verdict.allowed) {
      return verdict;
    }
    await transport.open(url, token: token!);
    final HabotSocketVerdict handshake = policy.evaluateHandshake(
      transport.negotiatedProtocol,
    );
    if (!handshake.allowed) {
      _verdicts.add(handshake);
      await transport.close();
      return handshake;
    }
    return verdict;
  }

  /// The producible reading of the row's metric: over a set of endpoints whose
  /// correct outcome is known, the share this policy classified correctly.
  static double executionAccuracy({
    required List<bool> expectedAllowed,
    required List<bool> actualAllowed,
  }) {
    if (expectedAllowed.isEmpty ||
        expectedAllowed.length != actualAllowed.length) {
      return 0;
    }
    int correct = 0;
    for (int i = 0; i < expectedAllowed.length; i++) {
      if (expectedAllowed[i] == actualAllowed[i]) {
        correct++;
      }
    }
    return correct / expectedAllowed.length;
  }

  static const double floor = 0.9;
  static const double optimal = 0.97;
  static const double ceiling = 0.999;

  static const String silentAssuranceReading =
      '"Silent security assurance" is read as: the USER is never asked to make '
      'a security decision. There is no certificate prompt and no trust '
      'toggle. A refused connection surfaces as the Step 125 offline chip, not '
      'as a dialog nobody can answer. The refusal itself is recorded in full.';

  static const String packageNote =
      'No websocket package is added: web_socket_channel cannot be resolved '
      'here. The security rules are decidable against a URL and a handshake '
      'with no I/O, so the policy is pure and fully tested and the transport '
      'is an interface. Swapping in a real client later is a class, not a '
      'rewrite.';
}
