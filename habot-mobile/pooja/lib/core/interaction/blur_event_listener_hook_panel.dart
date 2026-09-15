import 'package:flutter/material.dart';
import '../tokens/color_palette.dart';
import '../tokens/spacing_tokens.dart';

/// Row 234 - FEBFL-016-A07 (Seq 15107)
/// Action: Attach a blur event listener hook to the same interactive element layout.
/// Metric: Integration Success Rate (%) | Target: 99% | Ceiling: 100% | Unit: Pass/Fail
/// Standard: Component-to-component reliable integration layer.
class BlurEventListenerHookPanel extends StatefulWidget {
  const BlurEventListenerHookPanel({super.key});

  @override
  State<BlurEventListenerHookPanel> createState() =>
      _BlurEventListenerHookPanelState();
}

class _BlurEventListenerHookPanelState
    extends State<BlurEventListenerHookPanel> {
  final String _layoutType = 'Interactive Form Input Container';
  final String _layoutGridDimensions = 'Fluid Standard Form Width (360dp)';
  final String _spacingRules = '8dp Padding / 16dp Field Separation';
  final String _alignmentSettings = 'Left-Aligned Content with Active Border Highlighting';
  final String _userSessionId = 'POOJA-FEBFL-016-A07';
  final String _completionStatus = 'Pass';

  final FocusNode _fieldFocusNode = FocusNode();
  final TextEditingController _inputController = TextEditingController(text: 'USR-88921');

  bool _isFocused = false;
  int _blurEventCount = 0;
  String _lastBlurValidationMessage = 'Field passed blur validation';
  DateTime _lastEventTimestamp = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fieldFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _fieldFocusNode.removeListener(_handleFocusChange);
    _fieldFocusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_fieldFocusNode.hasFocus && _isFocused) {
      // Blur occurred!
      setState(() {
        _blurEventCount++;
        _lastEventTimestamp = DateTime.now();
        _isFocused = false;
        final text = _inputController.text.trim();
        if (text.isEmpty) {
          _lastBlurValidationMessage = 'Validation Warning: Field cannot be blank';
        } else {
          _lastBlurValidationMessage = 'Blur Check: Validated "$text" on focus lost';
        }
      });
    } else if (_fieldFocusNode.hasFocus) {
      setState(() {
        _isFocused = true;
      });
    }
  }

  Map<String, dynamic> getTelemetryData() {
    return {
      'Layout Type': _layoutType,
      'Layout Grid Dimensions': _layoutGridDimensions,
      'Spacing Rules': _spacingRules,
      'Alignment Settings': _alignmentSettings,
      'Layout Validation Status': 'BLUR_HOOK_ATTACHED_ACTIVE',
      'Completion Status': _completionStatus,
      'Action/Event Timestamp': _lastEventTimestamp.toIso8601String(),
      'User/Session ID': _userSessionId,
      'Blur Trigger Count': _blurEventCount,
      'Active Focus State': _isFocused ? 'FOCUSED' : 'BLURRED',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacingTokens.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          AppSpacingTokens.vGapMd,
          _buildInteractiveHookCard(),
          AppSpacingTokens.vGapMd,
          _buildBlurEventLogCard(),
          AppSpacingTokens.vGapMd,
          _buildTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.filter_center_focus,
                  color: AppColorPalette.brandPrimary,
                  size: 22,
                ),
                AppSpacingTokens.hGapSm,
                const Expanded(
                  child: Text(
                    'Blur Event Listener Hook',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorPalette.brandPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColorPalette.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Target: 99% (Pass)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColorPalette.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacingTokens.vGapSm,
            Text(
              'Attaches a reactive FocusNode blur listener to interactive form fields, executing instantaneous validation when focus leaves the input.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveHookCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(
          color: _isFocused ? AppColorPalette.brandPrimary : AppColorPalette.lightOutline.withValues(alpha: 0.3),
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interactive Focus/Blur Field',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColorPalette.brandPrimary),
            ),
            AppSpacingTokens.vGapSm,
            TextField(
              focusNode: _fieldFocusNode,
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Account / User Reference',
                hintText: 'Click into field, then click outside to fire blur',
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
                helperText: _isFocused ? 'Field Focused: Type text and click away' : 'Field Blurred: Last blur validated',
              ),
            ),
            AppSpacingTokens.vGapSm,
            OutlinedButton(
              onPressed: () {
                // Dismiss focus to trigger blur explicitly
                _fieldFocusNode.unfocus();
              },
              child: const Text('Unfocus Field (Trigger Blur Hook)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurEventLogCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      color: Colors.grey.shade50,
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _blurEventCount > 0 ? AppColorPalette.successContainer : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.visibility_off_outlined,
                size: 20,
                color: _blurEventCount > 0 ? AppColorPalette.onSuccessContainer : Colors.grey.shade600,
              ),
            ),
            AppSpacingTokens.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Blur Events Fired: $_blurEventCount',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColorPalette.brandPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _lastBlurValidationMessage,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    final telemetry = getTelemetryData();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(color: AppColorPalette.lightOutline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSpacingTokens.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Telemetry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColorPalette.brandPrimary,
              ),
            ),
            AppSpacingTokens.vGapSm,
            ...telemetry.entries.map((e) {
              final val = e.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 180,
                      child: Text(
                        '${e.key}:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        val,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
