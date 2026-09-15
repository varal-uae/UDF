// GEN-00162 — Auth Assurance Logger & M3 Status Card.
// Logs auth_method, mfa_status, token_expiry per NIST SP 800-63B / RFC 8446; evaluates AAL2 floor (TLS 1.2 min) to Pass/Fail.
import 'dart:async';
import 'package:flutter/material.dart';

/// Metric thresholds for 'Authentication Assurance Level'.
class AuthAssuranceThresholds {
  static const String floorBoundary = 'TLS 1.2 minimum / AAL2';
  static const String optimalTarget = 'TLS 1.3, AAL2-AAL3 with biometric step-up';
  static const String ceilingBoundary = 'AAL3 (hardware-bound)';
}

/// Supported auth methods (never log secrets/tokens themselves).
enum AuthMethod { password, otp, push, totp, webauthn, biometric, federated, unknown }

/// MFA enrollment/verification state.
enum MfaStatus { unenrolled, enrolled, verified, failed, steppedUp }

/// Qualitative output for this atomic step.
enum AssuranceVerdict { pass, fail }

/// Telemetry event streamed to BigQuery (partitioned by event_date, clustered by trace_id).
@immutable
class AuthAssuranceEvent {
  final AuthMethod authMethod;
  final MfaStatus mfaStatus;
  final DateTime tokenExpiry;
  final AssuranceVerdict verdict;
  final DateTime timestamp;
  final String userId;
  final String sessionId;
  final String traceId;
  final String tlsVersion;

  const AuthAssuranceEvent({
    required this.authMethod,
    required this.mfaStatus,
    required this.tokenExpiry,
    required this.verdict,
    required this.timestamp,
    required this.userId,
    required this.sessionId,
    required this.traceId,
    required this.tlsVersion,
  });

  Map<String, dynamic> toJson() => {
        'auth_method': authMethod.name,
        'mfa_status': mfaStatus.name,
        'token_expiry': tokenExpiry.toIso8601String(),
        'completion_status': verdict == AssuranceVerdict.pass ? 'Pass' : 'Fail',
        'event_timestamp': timestamp.toIso8601String(),
        'event_date': timestamp.toIso8601String().substring(0, 10),
        'user_id': userId,
        'session_id': sessionId,
        'trace_id': traceId,
        'tls_version': tlsVersion,
        'metric': 'Authentication Assurance Level',
        'global_ref': 'GEN-00162',
      };
}

/// Sink abstraction for BigQuery streaming / analytics pipeline.
abstract class AuthAssuranceSink {
  Future<void> send(Map<String, dynamic> json);
}

/// Debug sink — replace with BigQuery/GCP publisher in production.
class DebugAuthAssuranceSink implements AuthAssuranceSink {
  @override
  Future<void> send(Map<String, dynamic> json) async {
    // ignore: avoid_print
    print('[GEN-00162] $json');
  }
}

/// Central logger for authentication assurance data.
class AuthAssuranceLogger extends ChangeNotifier {
  final AuthAssuranceSink _sink;
  AuthAssuranceEvent? _lastEvent;
  AuthAssuranceEvent? get lastEvent => _lastEvent;

  AuthAssuranceLogger({AuthAssuranceSink? sink}) : _sink = sink ?? DebugAuthAssuranceSink();

  // EC: Log — persist auth_method, mfa_status, token_expiry without secrets.
  Future<AssuranceVerdict> log({
    required AuthMethod authMethod,
    required MfaStatus mfaStatus,
    required DateTime tokenExpiry,
    required String userId,
    required String sessionId,
    required String traceId,
    String tlsVersion = 'TLS 1.3',
  }) async {
    final verdict = evaluate(authMethod: authMethod, mfaStatus: mfaStatus, tlsVersion: tlsVersion);
    final event = AuthAssuranceEvent(
      authMethod: authMethod,
      mfaStatus: mfaStatus,
      tokenExpiry: tokenExpiry,
      verdict: verdict,
      timestamp: DateTime.now().toUtc(),
      userId: userId,
      sessionId: sessionId,
      traceId: traceId,
      tlsVersion: tlsVersion,
    );
    _lastEvent = event;
    await _sink.send(event.toJson());
    notifyListeners();
    return verdict;
  }

  // EC: Evaluate — return Fail if below AAL2 floor (TLS <1.2 or single-factor).
  AssuranceVerdict evaluate({
    required AuthMethod authMethod,
    required MfaStatus mfaStatus,
    required String tlsVersion,
  }) {
    final tlsOk = tlsVersion.contains('1.3') || tlsVersion.contains('1.2');
    if (!tlsOk) return AssuranceVerdict.fail;
    final mfaOk = mfaStatus == MfaStatus.verified || mfaStatus == MfaStatus.steppedUp;
    final methodOk = authMethod != AuthMethod.unknown && authMethod != AuthMethod.password;
    // Single-factor password alone without verified MFA fails AAL2.
    if (authMethod == AuthMethod.password && !mfaOk) return AssuranceVerdict.fail;
    if (!mfaOk && !methodOk) return AssuranceVerdict.fail;
    return AssuranceVerdict.pass;
  }

  // EC: Check — report true when token is expired.
  bool isExpired(DateTime tokenExpiry) => DateTime.now().toUtc().isAfter(tokenExpiry.toUtc());
}

/// M3 Elevated Card Level 2 (3dp) with inline status chip for engineering console.
class AuthAssuranceStatusCard extends StatelessWidget {
  final AuthAssuranceEvent? event;
  final VoidCallback? onDrillDown;

  const AuthAssuranceStatusCard({super.key, this.event, this.onDrillDown});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPass = (event?.verdict ?? AssuranceVerdict.fail) == AssuranceVerdict.pass;
    final chipBg = isPass ? cs.primaryContainer : cs.errorContainer;
    final chipFg = isPass ? cs.onPrimaryContainer : cs.onErrorContainer;
    return Semantics(
      label: isPass ? 'Authentication assurance Pass' : 'Authentication assurance Fail',
      liveRegion: true,
      child: Card(
        elevation: 3,
        surfaceTintColor: cs.surfaceTint,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onDrillDown,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Auth Assurance • GEN-00162', style: Theme.of(context).textTheme.titleSmall),
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text(isPass ? 'Pass' : 'Fail', style: TextStyle(color: chipFg, fontWeight: FontWeight.w600))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('auth_method: ${event?.authMethod.name ?? '—'} • mfa: ${event?.mfaStatus.name ?? '—'}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('token_expiry: ${event?.tokenExpiry.toIso8601String() ?? '—'}', style: Theme.of(context).textTheme.bodySmall),
                  Text('TLS: ${event?.tlsVersion ?? '—'} • AAL floor: ${AuthAssuranceThresholds.floorBoundary}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive section: single-column <600dp, multi-column >=840dp, 30s polling + pull-to-refresh.
class AuthAssuranceSection extends StatefulWidget {
  final AuthAssuranceLogger logger;
  const AuthAssuranceSection({super.key, required this.logger});

  @override
  State<AuthAssuranceSection> createState() => _AuthAssuranceSectionState();
}

class _AuthAssuranceSectionState extends State<AuthAssuranceSection> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    widget.logger.addListener(_onChange);
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => _onChange());
  }

  void _onChange() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    _poll?.cancel();
    widget.logger.removeListener(_onChange);
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 840;
        final card = AuthAssuranceStatusCard(event: widget.logger.lastEvent, onDrillDown: () {});
        return RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: card), const Expanded(child: SizedBox())])
                : Column(children: [card]),
          ),
        );
      },
    );
  }
}
