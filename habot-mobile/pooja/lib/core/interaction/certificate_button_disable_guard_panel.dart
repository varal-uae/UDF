import 'package:flutter/material.dart';

/// Row 348: GEN-00804 (Seq 17513)
/// Action: Hardcode validation rules physically disabling the "Generate" button until all mandatory UTM fields are populated.
/// Quality Gate: OWASP Input Validation Sheet (UI Interlock Reliability: 100%).
class CertificateButtonDisableGuardPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const CertificateButtonDisableGuardPanel({
    super.key,
    this.globalRefId = 'GEN-00804',
    this.atomicStepRefId = 'GEN-00804',
    this.sequenceOrder = 17513,
  });

  @override
  State<CertificateButtonDisableGuardPanel> createState() =>
      _CertificateButtonDisableGuardPanelState();
}

class _CertificateButtonDisableGuardPanelState
    extends State<CertificateButtonDisableGuardPanel> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _campaignController = TextEditingController();
  bool _isSourceValid = false;
  bool _isCampaignValid = false;

  @override
  void initState() {
    super.initState();
    _sourceController.addListener(() {
      final valid = _sourceController.text.trim().isNotEmpty;
      if (valid != _isSourceValid) {
        setState(() => _isSourceValid = valid);
      }
    });
    _campaignController.addListener(() {
      final valid = _campaignController.text.trim().isNotEmpty;
      if (valid != _isCampaignValid) {
        setState(() => _isCampaignValid = valid);
      }
    });
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _campaignController.dispose();
    super.dispose();
  }

  bool get _canGenerate => _isSourceValid && _isCampaignValid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lock_clock_rounded,
                    color: theme.colorScheme.onErrorContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GEN-00804: Generate Button Interlock',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seq: 17513 • Standard: OWASP Input Validation Sheet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    _canGenerate ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                    color: _canGenerate ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  label: Text(_canGenerate ? 'Unlocked' : 'Interlocked'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: _sourceController,
              decoration: InputDecoration(
                labelText: 'UTM Source (Required)',
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: Icon(
                  _isSourceValid ? Icons.check_circle : Icons.error_outline,
                  color: _isSourceValid ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _campaignController,
              decoration: InputDecoration(
                labelText: 'UTM Campaign (Required)',
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: Icon(
                  _isCampaignValid ? Icons.check_circle : Icons.error_outline,
                  color: _isCampaignValid ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _canGenerate
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Interlock satisfied: UTM Certificate generated successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.verified_rounded, size: 20),
                label: Text(
                  _canGenerate
                      ? 'Generate Certificate'
                      : 'Generate Locked (Populate Mandatory UTM Fields)',
                ),
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
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: CertificateButtonDisableGuardPanel(),
          ),
        ),
      ),
    ),
  );
}
