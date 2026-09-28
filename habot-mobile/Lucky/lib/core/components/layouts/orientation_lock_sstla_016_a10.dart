// SSTLA-016-A10 — Orientation Lock Manager & Viewport Constraint Specification.
// Enforces mobile screen orientation locking to prevent layout distortion and text clipping on data verification panels.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Atomic-level data model for orientation lock telemetry.
class OrientationLockRecord {
  final String lockType;
  final String lockStatus;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;
  final String completionStatus;
  final String sessionId;

  const OrientationLockRecord({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
    required this.completionStatus,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'lock_type': lockType,
        'lock_status': lockStatus,
        'locked_by': lockedBy,
        'lock_timestamp': lockTimestamp.toIso8601String(),
        'lock_reason': lockReason,
        'completion_status': completionStatus,
        'session_id': sessionId,
      };
}

/// Mock repository providing local data collection for orientation locks.
class OrientationLockMockRepository {
  static final List<OrientationLockRecord> _records = [];

  static void recordLock(OrientationLockRecord record) {
    _records.add(record);
  }

  static List<OrientationLockRecord> getRecords() => List.unmodifiable(_records);

  static double getTestPassRate() {
    if (_records.isEmpty) return 1.0;
    final passed = _records.where((r) => r.completionStatus == 'Pass').length;
    return passed / _records.length;
  }
}

/// Service responsible for enforcing viewport orientation constraints.
class OrientationLockService {
  OrientationLockService._();
  static final OrientationLockService instance = OrientationLockService._();

  bool _isLocked = false;

  /// Hard-locks the device orientation to portrait to prevent interaction clutter
  /// and accidental touch target displacement on small screens.
  Future<void> lockToPortrait({
    required String lockedBy,
    required String reason,
    required String sessionId,
  }) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _isLocked = true;

    final record = OrientationLockRecord(
      lockType: 'PORTRAIT_HARD_LOCK',
      lockStatus: 'LOCKED',
      lockedBy: lockedBy,
      lockTimestamp: DateTime.now(),
      lockReason: reason,
      completionStatus: 'Pass',
      sessionId: sessionId,
    );
    OrientationLockMockRepository.recordLock(record);
  }

  /// Releases the orientation constraint.
  Future<void> unlockOrientation({
    required String lockedBy,
    required String sessionId,
  }) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _isLocked = false;

    final record = OrientationLockRecord(
      lockType: 'UNLOCK',
      lockStatus: 'UNLOCKED',
      lockedBy: lockedBy,
      lockTimestamp: DateTime.now(),
      lockReason: 'User navigated away from constrained panel',
      completionStatus: 'Pass',
      sessionId: sessionId,
    );
    OrientationLockMockRepository.recordLock(record);
  }

  bool get isLocked => _isLocked;
}

/// A wrapper widget that enforces orientation locking when built.
/// Automatically handles lifecycle disposal to restore default orientations.
class OrientationConstrainedView extends StatefulWidget {
  final Widget child;
  final String lockedBy;
  final String lockReason;
  final String sessionId;

  const OrientationConstrainedView({
    super.key,
    required this.child,
    this.lockedBy = 'UDF_SYSTEM',
    this.lockReason = 'Prevent layout distortion on data entry panels',
    this.sessionId = 'SESSION_MOCK_001',
  });

  @override
  State<OrientationConstrainedView> createState() => _OrientationConstrainedViewState();
}

class _OrientationConstrainedViewState extends State<OrientationConstrainedView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyConstraint();
  }

  Future<void> _applyConstraint() async {
    await OrientationLockService.instance.lockToPortrait(
      lockedBy: widget.lockedBy,
      reason: widget.lockReason,
      sessionId: widget.sessionId,
    );
  }

  @override
  void didChangeMetrics() {
    // Built-in viewport checks automatically trigger layout adjustments
    // if hidden soft-key keyboard layers emerge (Self-Chasing requirement).
    super.didChangeMetrics();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    OrientationLockService.instance.unlockOrientation(
      lockedBy: widget.lockedBy,
      sessionId: widget.sessionId,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: viewInsets.bottom,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}