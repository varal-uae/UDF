import 'package:flutter/material.dart';

/// Unique styling tokens for Form Draft Recovery Engine Card.
abstract final class FormDraftRecoveryTokens {
  static const Color primaryBlue = Color(0xFF1E40AF);
  static const Color restoredGreen = Color(0xFF16A34A);
  static const Color restoredGreenBg = Color(0xFFDCFCE7);
  static const Color crashRed = Color(0xFFDC2626);
  static const Color crashRedBg = Color(0xFFFEE2E2);

  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
}

/// A data recovery test bed that preserves input state across simulated force-closes.
class FormDraftRecoveryEngineCard extends StatefulWidget {
  final void Function(bool recovered, String title, String notes)?
      onDraftRestored;

  const FormDraftRecoveryEngineCard({
    super.key,
    this.onDraftRestored,
  });

  @override
  State<FormDraftRecoveryEngineCard> createState() =>
      _FormDraftRecoveryEngineCardState();
}

class _FormDraftRecoveryEngineCardState
    extends State<FormDraftRecoveryEngineCard> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  // Simulated encrypted draft cache on local device disk
  static String _diskSavedTitle = 'Q3 Compliance Audit Checklist';
  static String _diskSavedNotes =
      'ISO 27001 controls verified for telemetry ingress...';
  static bool _hasUnrestoredDraft = true;

  bool _isCrashed = false;
  bool _isRestored = false;

  @override
  void initState() {
    super.initState();
    // Default initial populated or blank
    if (!_hasUnrestoredDraft) {
      _titleController.text = _diskSavedTitle;
      _notesController.text = _diskSavedNotes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onKeystroke(String val) {
    // Auto-save to simulated disk cache on every keystroke
    setState(() {
      _diskSavedTitle = _titleController.text;
      _diskSavedNotes = _notesController.text;
    });
  }

  void _simulateForceClose() {
    setState(() {
      _isCrashed = true;
      _isRestored = false;
      _hasUnrestoredDraft = true;
      _titleController.clear();
      _notesController.clear();
    });
  }

  void _relaunchAppAndRestore() {
    setState(() {
      _isCrashed = false;
      _isRestored = true;
      _hasUnrestoredDraft = false;
      _titleController.text = _diskSavedTitle;
      _notesController.text = _diskSavedNotes;
    });

    widget.onDraftRestored?.call(true, _diskSavedTitle, _diskSavedNotes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FormDraftRecoveryTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: FormDraftRecoveryTokens.borderLight),
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
                  color: FormDraftRecoveryTokens.primaryBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.save_as_rounded,
                  color: FormDraftRecoveryTokens.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form Force-Close Recovery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: FormDraftRecoveryTokens.textDark,
                      ),
                    ),
                    Text(
                      'Zero Data-Loss Persistence (ISO/IEC 27001)',
                      style: TextStyle(
                        fontSize: 12,
                        color: FormDraftRecoveryTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isRestored
                      ? FormDraftRecoveryTokens.restoredGreenBg
                      : (_isCrashed
                          ? FormDraftRecoveryTokens.crashRedBg
                          : const Color(0xFFEFF6FF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isRestored
                      ? 'DRAFT RESTORED'
                      : (_isCrashed ? 'FORCE-CLOSED' : 'AUTO-SAVED'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isRestored
                        ? FormDraftRecoveryTokens.restoredGreen
                        : (_isCrashed
                            ? FormDraftRecoveryTokens.crashRed
                            : FormDraftRecoveryTokens.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isCrashed) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FormDraftRecoveryTokens.crashRedBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: FormDraftRecoveryTokens.crashRed.withAlpha(60),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.mobile_off_rounded,
                    color: FormDraftRecoveryTokens.crashRed,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simulated Process Termination',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: FormDraftRecoveryTokens.crashRed,
                          ),
                        ),
                        Text(
                          'OS killed process mid-edit. RAM purged. Disk snapshot safe.',
                          style: TextStyle(
                            fontSize: 11,
                            color: FormDraftRecoveryTokens.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _relaunchAppAndRestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FormDraftRecoveryTokens.restoredGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                    child: const Text('Relaunch & Restore',
                        style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          ] else ...[
            if (_hasUnrestoredDraft && !_isRestored)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_edu_rounded,
                        color: Color(0xFFB45309), size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Uncommitted draft found from previous session.',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E)),
                      ),
                    ),
                    TextButton(
                      onPressed: _relaunchAppAndRestore,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: const Color(0xFF92400E),
                      ),
                      child: const Text('Restore',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: _titleController,
              onChanged: _onKeystroke,
              decoration: InputDecoration(
                labelText: 'Document Subject / Title',
                hintText: 'e.g. SOC2 Incident Investigation',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              onChanged: _onKeystroke,
              decoration: InputDecoration(
                labelText: 'Operational Notes & Findings',
                hintText: 'Enter incident telemetry details...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _simulateForceClose,
                    icon: const Icon(Icons.flash_off_rounded,
                        size: 16, color: FormDraftRecoveryTokens.crashRed),
                    label: const Text('Simulate App Force-Close'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FormDraftRecoveryTokens.crashRed,
                      side: const BorderSide(
                          color: FormDraftRecoveryTokens.crashRed),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Form successfully committed to backend.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Commit Form'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FormDraftRecoveryTokens.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
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
            child: FormDraftRecoveryEngineCard(),
          ),
        ),
      ),
    ),
  );
}
