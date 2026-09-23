import 'dart:async';
import 'package:flutter/material.dart';

/// Unique styling tokens for the Fail Closed Circuit Breaker Console.
abstract final class FailClosedTokens {
  static const Color primaryCrimson = Color(0xFF991B1B);
  static const Color circuitOpen = Color(0xFFDC2626);
  static const Color circuitOpenBg = Color(0xFFFEE2E2);
  static const Color circuitClosed = Color(0xFF16A34A);
  static const Color circuitClosedBg = Color(0xFFDCFCE7);
  static const Color circuitHalfOpen = Color(0xFFD97706);
  static const Color circuitHalfOpenBg = Color(0xFFFEF3C7);

  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
}

/// Circuit Breaker operating state.
enum CircuitBreakerState {
  closed, // Healthy: normal traffic flow
  tripped, // Fail-Closed: circuit severed, all egress blocked
  halfOpen, // Probing: testing recovery with sentinel canary
}

/// Representation of an ingested payload event.
class DataCircuitEvent {
  final String eventId;
  final String timestamp;
  final String payloadType;
  final bool isMalformed;
  final String statusDescription;

  const DataCircuitEvent({
    required this.eventId,
    required this.timestamp,
    required this.payloadType,
    required this.isMalformed,
    required this.statusDescription,
  });
}

/// Interactive console implementing strict "Fail Closed" circuit breaker logic under ISO/IEC 27001:2022.
class FailClosedCircuitBreakerConsole extends StatefulWidget {
  final void Function(CircuitBreakerState state)? onStateChanged;

  const FailClosedCircuitBreakerConsole({
    super.key,
    this.onStateChanged,
  });

  @override
  State<FailClosedCircuitBreakerConsole> createState() =>
      _FailClosedCircuitBreakerConsoleState();
}

class _FailClosedCircuitBreakerConsoleState
    extends State<FailClosedCircuitBreakerConsole> {
  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _blockedRequests = 0;
  int _successfulTransmissions = 42;
  final List<DataCircuitEvent> _auditTrail = [];
  Timer? _canaryTimer;

  @override
  void initState() {
    super.initState();
    _auditTrail.add(
      const DataCircuitEvent(
        eventId: 'EVT-9901',
        timestamp: '16:45:10',
        payloadType: 'JSON_SCHEMA_V3',
        isMalformed: false,
        statusDescription: 'Payload signature valid. Egress permitted.',
      ),
    );
  }

  @override
  void dispose() {
    _canaryTimer?.cancel();
    super.dispose();
  }

  void _triggerUnexpectedResponse() {
    setState(() {
      _state = CircuitBreakerState.tripped; // Strict Fail-Closed trip
      _blockedRequests++;
      _auditTrail.insert(
        0,
        DataCircuitEvent(
          eventId: 'EVT-${DateTime.now().millisecondsSinceEpoch % 10000}',
          timestamp: '16:50:${DateTime.now().second.toString().padLeft(2, '0')}',
          payloadType: 'CORRUPTED_BLOB_NULL_BYTE',
          isMalformed: true,
          statusDescription:
              'CRITICAL: Unexpected payload shape detected. Fail-Closed tripped.',
        ),
      );
    });

    widget.onStateChanged?.call(_state);
  }

  void _simulateValidPayload() {
    if (_state == CircuitBreakerState.tripped) {
      setState(() => _blockedRequests++);
      return;
    }

    setState(() {
      _successfulTransmissions++;
      _auditTrail.insert(
        0,
        DataCircuitEvent(
          eventId: 'EVT-${DateTime.now().millisecondsSinceEpoch % 10000}',
          timestamp: '16:50:${DateTime.now().second.toString().padLeft(2, '0')}',
          payloadType: 'TELEMETRY_RECORD_V2',
          isMalformed: false,
          statusDescription: 'Valid authentication token verified. Processed.',
        ),
      );
    });
  }

  void _probeCanaryRecovery() {
    setState(() {
      _state = CircuitBreakerState.halfOpen;
    });

    _canaryTimer?.cancel();
    _canaryTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _state = CircuitBreakerState.closed;
          _auditTrail.insert(
            0,
            DataCircuitEvent(
              eventId: 'EVT-CANARY-PASS',
              timestamp:
                  '16:51:${DateTime.now().second.toString().padLeft(2, '0')}',
              payloadType: 'SENTINEL_PROBE',
              isMalformed: false,
              statusDescription:
                  'Canary health verified. Circuit closed to normal ingress.',
            ),
          );
        });
        widget.onStateChanged?.call(_state);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateBg = switch (_state) {
      CircuitBreakerState.closed => FailClosedTokens.circuitClosedBg,
      CircuitBreakerState.tripped => FailClosedTokens.circuitOpenBg,
      CircuitBreakerState.halfOpen => FailClosedTokens.circuitHalfOpenBg,
    };

    final stateText = switch (_state) {
      CircuitBreakerState.closed => FailClosedTokens.circuitClosed,
      CircuitBreakerState.tripped => FailClosedTokens.circuitOpen,
      CircuitBreakerState.halfOpen => FailClosedTokens.circuitHalfOpen,
    };

    final stateLabel = switch (_state) {
      CircuitBreakerState.closed => 'CIRCUIT SECURE (CLOSED)',
      CircuitBreakerState.tripped => 'FAIL-CLOSED TRIPPED (BLOCKED)',
      CircuitBreakerState.halfOpen => 'CANARY PROBE ACTIVE',
    };

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FailClosedTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: FailClosedTokens.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FailClosedTokens.primaryCrimson.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.electric_bolt_rounded,
                  color: FailClosedTokens.primaryCrimson,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fail-Closed Circuit Breaker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: FailClosedTokens.textDark,
                      ),
                    ),
                    Text(
                      'Automated Data Halt on Unexpected Res (ISO/IEC 27001)',
                      style: TextStyle(
                        fontSize: 12,
                        color: FailClosedTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stateBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stateLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: stateText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // KPI Metric Banner
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: FailClosedTokens.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: FailClosedTokens.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allowed Egress',
                        style: TextStyle(
                          fontSize: 11,
                          color: FailClosedTokens.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_successfulTransmissions pkts',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: FailClosedTokens.circuitClosed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: FailClosedTokens.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: FailClosedTokens.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fail-Closed Severed',
                        style: TextStyle(
                          fontSize: 11,
                          color: FailClosedTokens.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_blockedRequests blocked',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: FailClosedTokens.circuitOpen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Interactive Simulator Action Bar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _triggerUnexpectedResponse,
                icon: const Icon(Icons.warning_amber_rounded, size: 16),
                label: const Text('Inject Malformed Response'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FailClosedTokens.circuitOpen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _simulateValidPayload,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send Normal Payload'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              if (_state == CircuitBreakerState.tripped)
                FilledButton.tonalIcon(
                  onPressed: _probeCanaryRecovery,
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Canary Health Probe'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Live Circuit Event Stream
          const Text(
            'Circuit Breaker Audit Lineage:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FailClosedTokens.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FailClosedTokens.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FailClosedTokens.borderLight),
            ),
            child: ListView.builder(
              itemCount: _auditTrail.length,
              itemBuilder: (context, idx) {
                final item = _auditTrail[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    children: [
                      Icon(
                        item.isMalformed
                            ? Icons.cancel_rounded
                            : Icons.check_circle_rounded,
                        size: 14,
                        color: item.isMalformed
                            ? FailClosedTokens.circuitOpen
                            : FailClosedTokens.circuitClosed,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '[${item.timestamp}]',
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: FailClosedTokens.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.statusDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: item.isMalformed
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: item.isMalformed
                                ? FailClosedTokens.circuitOpen
                                : FailClosedTokens.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: FailClosedCircuitBreakerConsole(),
          ),
        ),
      ),
    ),
  );
}
