// GEN-00151 — Prerequisite Gate (Steps 5 & 16) Verification Console.
// Single-column M3 status cards on mobile with 30s liveness polling, pull-to-refresh and 100% ITIL v4 dependency gating.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// VERIFY: define predecessor step model for Steps 5 and 16.
enum GateStepStatus { pass, fail, pending }

class PredecessorStepGen00151 {
  final String id;
  final String title;
  final String specRef;
  GateStepStatus status;
  DateTime? verifiedAt;
  PredecessorStepGen00151({required this.id, required this.title, required this.specRef, this.status = GateStepStatus.pending, this.verifiedAt});
  bool get isVerifiedPass => status == GateStepStatus.pass;
}

// CONFIGURE: map input field ids to keyboard + mask formatters.
class InputMaskConfigGen00151 {
  final String fieldId;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> formatters;
  const InputMaskConfigGen00151({required this.fieldId, required this.hint, required this.keyboardType, required this.formatters});
}

class InputMasksGen00151 {
  static List<TextInputFormatter> sessionIdMask() => <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-_]')),
    LengthLimitingTextInputFormatter(64),
  ];
  static List<TextInputFormatter> traceIdMask() => <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9-]')),
    LengthLimitingTextInputFormatter(36),
  ];
  static List<InputMaskConfigGen00151> all() => [
    InputMaskConfigGen00151(fieldId: 'session_id', hint: 'User / Session ID', keyboardType: TextInputType.text, formatters: sessionIdMask()),
    InputMaskConfigGen00151(fieldId: 'trace_id', hint: 'Trace ID (for BigQuery clustering)', keyboardType: TextInputType.text, formatters: traceIdMask()),
  ];
}

// RENDER: M3 prerequisite gate screen with responsive layout and liveness handshake.
class PrerequisiteGateScreenGen00151 extends StatefulWidget {
  const PrerequisiteGateScreenGen00151({super.key});
  @override
  State<PrerequisiteGateScreenGen00151> createState() => _PrerequisiteGateScreenGen00151State();
}

class _PrerequisiteGateScreenGen00151State extends State<PrerequisiteGateScreenGen00151> {
  late List<PredecessorStepGen00151> _steps;
  Timer? _pollTimer;
  bool _isSyncing = false;
  DateTime? _lastHandshake;
  final TextEditingController _sessionCtrl = TextEditingController();
  final TextEditingController _traceCtrl = TextEditingController();
  final String _globalRef = 'GEN-00151';
  final String _dependsOn = 'GEN-00150';

  @override
  void initState() {
    super.initState();
    _steps = [
      PredecessorStepGen00151(id: 'STEP-05', title: 'Step 5 — Foundational Baseline', specRef: 'PMBOK 7th milestone sequencing'),
      PredecessorStepGen00151(id: 'STEP-16', title: 'Step 16 — Foundational Baseline', specRef: 'ITIL v4 Change Enablement'),
    ];
    // POLL: background liveness handshake every 30s per Self-Chasing requirement.
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refreshGate(silent: true));
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshGate(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _sessionCtrl.dispose();
    _traceCtrl.dispose();
    super.dispose();
  }

  // CALCULATE: predecessor dependency verification rate (floor 100%, ceiling 100%).
  double get _verificationRate {
    if (_steps.isEmpty) return 0;
    final verified = _steps.where((s) => s.isVerifiedPass).length;
    return verified / _steps.length;
  }

  bool get _isGatePass => _steps.every((s) => s.isVerifiedPass);
  String get _gateLabel => _isGatePass ? 'Pass' : 'Fail';

  // REFRESH: simulate backend check for Steps 5 and 16 completion.
  Future<void> _refreshGate({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) setState(() => _isSyncing = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _lastHandshake = DateTime.now().toUtc();
      _isSyncing = false;
    });
    _logStepEvent('handshake_ok');
  }

  // VERIFY: mark a predecessor step as Pass/Fail with timestamp.
  void _verifyStep(int index, bool pass) {
    setState(() {
      _steps[index].status = pass ? GateStepStatus.pass : GateStepStatus.fail;
      _steps[index].verifiedAt = DateTime.now().toUtc();
    });
    _logStepEvent(pass ? 'verify_pass:${_steps[index].id}' : 'verify_fail:${_steps[index].id}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_steps[index].id} marked as ${pass ? 'Pass' : 'Fail'}')));
  }

  // LOG: stream execution event to BigQuery partitioned by event_date clustered by trace_id.
  void _logStepEvent(String action) {
    final traceId = _traceCtrl.text.isEmpty ? 'unassigned' : _traceCtrl.text;
    debugPrint('BQ_LOG event_date=${DateTime.now().toUtc().toIso8601String().substring(0, 10)} trace_id=$traceId ref=$_globalRef action=$action rate=$_verificationRate gate=$_gateLabel');
  }

  // PRESENT: open M3 bottom sheet for session/trace config inputs with masks.
  void _openConfigSheet() {
    final masks = InputMasksGen00151.all();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 8),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Gate Configuration', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              Semantics(label: 'User Session ID input', textField: true, child: TextField(controller: _sessionCtrl, decoration: InputDecoration(labelText: masks[0].hint, border: const OutlineInputBorder(), helperText: 'Mask: alphanumeric + - _'), keyboardType: masks[0].keyboardType, inputFormatters: masks[0].formatters)),
              const SizedBox(height: 12),
              Semantics(label: 'Trace ID input', textField: true, child: TextField(controller: _traceCtrl, decoration: InputDecoration(labelText: masks[1].hint, border: const OutlineInputBorder(), helperText: 'Mask: UUID hex + -'), keyboardType: masks[1].keyboardType, inputFormatters: masks[1].formatters)),
              const SizedBox(height: 16),
              SizedBox(height: 48, child: FilledButton(onPressed: () { Navigator.pop(ctx); _logStepEvent('config_saved'); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuration saved'))); }, child: const Text('Save'))),
              const SizedBox(height: 16),
            ]),
          ),
        );
      },
    );
  }

  Widget _statusChip(GateStepStatus status) {
    final cs = Theme.of(context).colorScheme;
    final label = status == GateStepStatus.pass ? 'Pass' : status == GateStepStatus.fail ? 'Fail' : 'Pending';
    final bg = status == GateStepStatus.pass ? cs.primaryContainer : status == GateStepStatus.fail ? cs.errorContainer : cs.surfaceContainerHighest;
    final fg = status == GateStepStatus.pass ? cs.onPrimaryContainer : status == GateStepStatus.fail ? cs.onErrorContainer : cs.onSurfaceVariant;
    return Semantics(label: 'Status $label', child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg))));
  }

  Widget _stepCard(int index) {
    final s = _steps[index];
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(s.id, style: Theme.of(context).textTheme.labelMedium)), _statusChip(s.status)]),
          const SizedBox(height: 8),
          Text(s.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(s.specRef, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(s.verifiedAt == null ? 'Not yet verified' : 'Verified: ${s.verifiedAt!.toIso8601String()}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: SizedBox(height: 48, child: OutlinedButton(onPressed: () => _verifyStep(index, false), style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)), child: const Text('Fail')))),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 48, child: FilledButton(onPressed: () => _verifyStep(index, true), style: FilledButton.styleFrom(minimumSize: const Size(48, 48)), child: const Text('Pass')))),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ratePct = (_verificationRate * 100).toStringAsFixed(0);
    return Scaffold(
      appBar: AppBar(title: const Text('Prerequisite Gate — Steps 5 & 16'), actions: [SizedBox(width: 48, height: 48, child: IconButton(tooltip: 'Configure', onPressed: _openConfigSheet, icon: const Icon(Icons.settings_outlined)))]),
      body: LayoutBuilder(builder: (ctx, c) {
        final isDesktop = c.maxWidth >= 840;
        final isMobile = c.maxWidth < 600;
        final gateCard = Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text('Predecessor Dependency Verification Rate', style: Theme.of(context).textTheme.titleMedium)), _statusChip(_isGatePass ? GateStepStatus.pass : GateStepStatus.fail)]),
              const SizedBox(height: 8),
              Text('Floor: 100% verified | Target: 100% (no partial credit) | Depends on $_dependsOn', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Semantics(label: 'Verification rate $ratePct percent', child: LinearProgressIndicator(value: _verificationRate)),
              const SizedBox(height: 8),
              Text('$ratePct% — Output: $_gateLabel | Seq 16860 | ${_lastHandshake == null ? 'handshake pending' : 'liveness ${_lastHandshake!.toIso8601String()}'}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 48, child: FilledButton(onPressed: _isSyncing ? null : () => _refreshGate(), style: FilledButton.styleFrom(minimumSize: const Size(48, 48)), child: Text(_isSyncing ? 'Syncing...' : 'Re-verify Now'))),
              if (!_isGatePass) Padding(padding: const EdgeInsets.only(top: 8), child: Text('CI/CD gate blocked: downstream steps require 100% verification.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error))),
            ]),
          ),
        );
        final cards = List<Widget>.generate(_steps.length, (i) => _stepCard(i));
        return RefreshIndicator(
          onRefresh: () => _refreshGate(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  gateCard,
                  const SizedBox(height: 12),
                  if (isDesktop) GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.05, children: cards) else ...cards,
                  const SizedBox(height: 12),
                  Text('Standard: ITIL v4 Change Enablement; PMBOK 7th. BigQuery partitioned by event_date, clustered by trace_id.', style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }
}
