/*
 * GEN-01876 — Build the useSLATimer component hook in the React/Mobile canvas.
 * 
 * Global Reference ID: GEN-01876
 * Atomic Steps Reference ID: GEN-01876
 * Setup Step (Action): Build the useSLATimer component hook in the React/Mobile canvas.
 * Setup Step Description: Single-column mobile layout with M3 status cards displaying step completion state.
 * S.No: 6620 | Sequence Order: 18585 | Assigned Team: UDF (Pooja)
 * 
 * Dependency: Dependent on prior foundational steps.
 * Decision Group: Architecture & Implementation Governance
 * Why This Matters: Build the useSLATimer component hook in the React/Mobile canvas. is a critical implementation step. Without it, downstream steps lack the required baseline configuration.
 * Mobile App First Implication: Ensures sub-100ms API response latencies on mobile clients via optimized backend configuration.
 * Data Requirement: Data/artifacts to prepare: React/Mobile; useSLATimer. Metric config: 'Step Completion Rate (%)' (floor threshold: 90). Reference standard/spec to configure against: ISO/IEC 27001:2022 General Standards. Output field to capture: Complete/Partial/Not Complete.
 * User Interaction / Flow Impact: Users interact with this step exclusively through the mobile engineering console. Read-only M3 KPI cards with deep-link drill-down.
 * Dashboard / Interface Implication: Engineering console dashboard displays step health via M3 Elevated Card with inline status chip.
 * What Standardized Must Be Done: English Code (EC) blueprint required before any code is written. All functions must have single-verb EC headers.
 * Atomic Reusability: Core pattern for this step stored as a reusable module in the shared library.
 * Common Library to Store: @habot/shared-library
 * GCP / BigQuery Alignment: All step execution events stream to BigQuery partitioned by event_date, clustered by trace_id.
 * Estimated Time Required: 4 Hours
 * Expected Output: Fully configured and validated implementation of: Build the useSLATimer component hook in the React/Mobile canvas..
 * Completion Measures: 100% CI/CD pass rate. All validation checks passing. Documentation committed to runbook.
 * M3 UX Decision: M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (≥840dp).
 * M3 UI Decision: M3 Elevated Cards Level 2 (3dp). M3 Status Chips for health indicators. 48x48dp touch targets.
 * M3 UX Implementation: Background polling refreshes data every 30 seconds. Pull-to-refresh triggers manual sync.
 * M3 UI Implementation: M3 Bottom Sheet for configuration inputs. M3 Snackbar for confirmations. Material You dynamic color.
 * Domain Expertise Needed: Mobile Engineering, GCP Architecture, UX/UI Design (MD3), DCDF Engine Architecture.
 * Mistake-Proofing (Poka-Yoke): CI/CD pipeline physically blocks deployment if any gate for this step fails.
 * Self-Chasing: Automated Liveness Handshake monitors this step every 30 seconds and triggers rollback on failure.
 * Vitality & Prosperity (Us): Eliminates manual overhead, reduces operational cost, and protects revenue pipelines.
 * Vitality & Prosperity (Customer): Engineers and end-users experience reliable, uninterrupted platform performance.
 * Responsive UX/UI Design: M3 responsive single-column on mobile, multi-panel on tablet/desktop. 48x48dp touch targets.
 * Vitality & Prosperity (VAP): Us: Eliminates manual overhead and reduces operational cost. | Customer: Reliable, uninterrupted platform performance.
 * 
 * AUDIT NOTICE & BOUNDARY TARGETS:
 * Standard: ISO/IEC 27001:2022 General Standards
 * Metric Boundaries:
 * - Floor Boundary: 90
 * - Optimal Target: 99
 * - Ceiling Boundary: 100
 * Best Qualitative Output: Complete/Partial/Not Complete
 * Data Collected by System: React/Mobile; useSLATimer; Completion Status ('Complete/Partial/Not Complete'); Action/Event Timestamp; User/Session ID
 */

import 'dart:async';
import 'package:flutter/material.dart';

/// Style tokens for the SLA Timer Hook Canvas.
abstract final class SlaHookTokens {
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color statusGreen = Color(0xFF16A34A);
  static const Color statusAmber = Color(0xFFD97706);
  static const Color statusRed = Color(0xFFDC2626);
  static const Color darkCanvas = Color(0xFF0F172A);
}

/// Operating phase of the SLA timer hook.
enum SlaTimerPhase {
  idle,
  running,
  paused,
  breached,
}

/// Visual canvas implementing the useSLATimer mobile component hook under ISO/IEC 27001.
class SlaTimerHookCanvas extends StatefulWidget {
  final ValueChanged<int>? onSecondsRemainingChanged;
  final VoidCallback? onTimerBreached;

  const SlaTimerHookCanvas({
    super.key,
    this.onSecondsRemainingChanged,
    this.onTimerBreached,
  });

  @override
  State<SlaTimerHookCanvas> createState() => _SlaTimerHookCanvasState();
}

class _SlaTimerHookCanvasState extends State<SlaTimerHookCanvas> {
  final int _totalDurationSeconds = 45;
  late int _remainingSeconds;
  SlaTimerPhase _phase = SlaTimerPhase.idle;
  Timer? _timer;
  final List<String> _eventTelemetry = [];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _totalDurationSeconds;
    _logEvent('Hook mounted: useSLATimer initialized with $_totalDurationSeconds s');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _logEvent(String event) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _eventTelemetry.insert(0, '[$timeStr] $event');
    if (_eventTelemetry.length > 20) {
      _eventTelemetry.removeLast();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _phase = SlaTimerPhase.running;
    });
    _logEvent('Timer started: $_remainingSeconds s remaining');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
        widget.onSecondsRemainingChanged?.call(_remainingSeconds);
        if (_remainingSeconds == 15) {
          _logEvent('Threshold reached: WARNING (15s remaining)');
        } else if (_remainingSeconds == 5) {
          _logEvent('Threshold reached: CRITICAL (5s remaining)');
        }
      } else {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _phase = SlaTimerPhase.breached;
        });
        widget.onSecondsRemainingChanged?.call(0);
        widget.onTimerBreached?.call();
        _logEvent('SLA BREACH DETECTED: Timer reached zero');
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _phase = SlaTimerPhase.paused;
    });
    _logEvent('Timer paused at $_remainingSeconds s');
  }

  void _resumeTimer() {
    _startTimer();
    _logEvent('Timer resumed from $_remainingSeconds s');
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalDurationSeconds;
      _phase = SlaTimerPhase.idle;
    });
    _logEvent('Timer reset to $_totalDurationSeconds s');
  }

  void _addExtension() {
    setState(() {
      _remainingSeconds += 15;
      if (_phase == SlaTimerPhase.breached) {
        _phase = SlaTimerPhase.running;
        _startTimer();
      }
    });
    _logEvent('Grace extension: +15s added (now $_remainingSeconds s)');
  }

  Color _getCurrentColor() {
    if (_phase == SlaTimerPhase.breached || _remainingSeconds <= 5) {
      return SlaHookTokens.statusRed;
    }
    if (_remainingSeconds <= 15) {
      return SlaHookTokens.statusAmber;
    }
    return SlaHookTokens.statusGreen;
  }

  String _formatTime(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalDurationSeconds > 0
        ? _remainingSeconds / _totalDurationSeconds
        : 0.0;
    final activeColor = _getCurrentColor();

    return Container(
      color: SlaHookTokens.backgroundLight,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: SlaHookTokens.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SlaHookTokens.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'useSLATimer Hook Canvas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: SlaHookTokens.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'GEN-01876 • Mobile Lifecycle-Aware SLA Hook',
                        style: TextStyle(
                          fontSize: 12,
                          color: SlaHookTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: activeColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _phase.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual SLA Dial / Countdown Display
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: SlaHookTokens.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SlaHookTokens.borderLight),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: SlaHookTokens.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            _formatTime(_remainingSeconds),
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: activeColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_remainingSeconds / _totalDurationSeconds * 100).toInt()}% Remaining',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: SlaHookTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: SlaHookTokens.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Controls
            Row(
              children: [
                if (_phase == SlaTimerPhase.idle)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startTimer,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Start SLA Window'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SlaHookTokens.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else if (_phase == SlaTimerPhase.running)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pauseTimer,
                      icon: const Icon(Icons.pause, size: 18),
                      label: const Text('Pause SLA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SlaHookTokens.statusAmber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else if (_phase == SlaTimerPhase.paused)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resumeTimer,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Resume SLA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SlaHookTokens.statusGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Restart Window'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SlaHookTokens.statusRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _addExtension,
                  icon: const Icon(Icons.more_time, size: 18),
                  label: const Text('+15s'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SlaHookTokens.primaryTeal,
                    side: const BorderSide(color: SlaHookTokens.primaryTeal),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.restart_alt),
                  tooltip: 'Reset Timer',
                  style: IconButton.styleFrom(
                    foregroundColor: SlaHookTokens.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Telemetry Event Stream
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SlaHookTokens.darkCanvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TELEMETRY AUDIT STREAM',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Icon(Icons.terminal, color: Color(0xFF94A3B8), size: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      itemCount: _eventTelemetry.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            _eventTelemetry[index],
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SlaTimerHookCanvas(),
        ),
      ),
    ),
  );
}
