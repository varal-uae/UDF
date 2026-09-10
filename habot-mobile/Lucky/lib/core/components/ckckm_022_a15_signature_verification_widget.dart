// CKCKM-022-A15 — Mobile Client Signature Pad Verification Component.
// Full-screen Material 3 signature wizard with deliberate confirmation, biometric gate, vector capture, and poka-yoke error locking.

import 'package:flutter/material.dart';

class Ckckm022A15SignatureVerificationWidget extends StatefulWidget {
  const Ckckm022A15SignatureVerificationWidget({
    super.key,
    required this.onVerified,
    this.onBiometricRequested,
    this.errorMessage,
  });

  final ValueChanged<List<Offset>> onVerified;
  final Future<bool> Function()? onBiometricRequested;
  final String? errorMessage;

  @override
  State<Ckckm022A15SignatureVerificationWidget> createState() =>
      _Ckckm022A15SignatureVerificationWidgetState();
}

class _Ckckm022A15SignatureVerificationWidgetState
    extends State<Ckckm022A15SignatureVerificationWidget> {
  final List<List<Offset>> _strokes = <List<Offset>>[];
  List<Offset>? _activeStroke;
  bool _biometricConfirmed = false;
  bool _hasFocus = true;
  bool _submitting = false;
  String? _localError;

  bool get _hasSignature => _strokes.any((stroke) => stroke.length > 1);

  @override
  void didUpdateWidget(covariant Ckckm022A15SignatureVerificationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorMessage != widget.errorMessage) {
      _localError = widget.errorMessage;
    }
  }

  void _clearIfFocusLost() {
    if (!_hasFocus) {
      _strokes.clear();
      _activeStroke = null;
      _biometricConfirmed = false;
      _localError = 'Signature cleared because process focus was lost.';
      setState(() {});
    }
  }

  Future<void> _handleBiometricGate() async {
    final callback = widget.onBiometricRequested;
    if (callback == null) {
      setState(() {
        _biometricConfirmed = true;
        _localError = null;
      });
      return;
    }

    final confirmed = await callback();
    if (!mounted) return;
    setState(() {
      _biometricConfirmed = confirmed;
      _localError = confirmed ? null : 'Biometric verification is required before capture.';
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (!_biometricConfirmed || !_hasFocus) return;
    setState(() {
      _activeStroke = <Offset>[details.localPosition];
      _strokes.add(_activeStroke!);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_biometricConfirmed || !_hasFocus || _activeStroke == null) return;
    setState(() {
      _activeStroke!.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _activeStroke = null;
    setState(() {});
  }

  Future<void> _confirmSignature() async {
    if (!_hasSignature) {
      setState(() {
        _localError = 'A drawn signature is required.';
      });
      return;
    }
    if (!_biometricConfirmed) {
      setState(() {
        _localError = 'Biometric confirmation is required.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _localError = null;
    });

    widget.onVerified(_strokes.expand((stroke) => stroke).toList(growable: false));

    if (!mounted) return;
    setState(() {
      _submitting = false;
    });
  }

  void _reset() {
    setState(() {
      _strokes.clear();
      _activeStroke = null;
      _biometricConfirmed = false;
      _localError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Focus(
      onFocusChange: (hasFocus) {
        _hasFocus = hasFocus;
        _clearIfFocusLost();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Signature Verification'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deliberate confirmation',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Swipe up to confirm biometric identity, then sign inside the card.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                              _handleBiometricGate();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _biometricConfirmed
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _biometricConfirmed
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _biometricConfirmed ? Icons.verified_user : Icons.fingerprint,
                                  color: _biometricConfirmed
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _biometricConfirmed
                                        ? 'Biometric identity confirmed'
                                        : 'Swipe up for biometric check',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _hasSignature ? colorScheme.primary : colorScheme.outlineVariant,
                        width: _hasSignature ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: CustomPaint(
                          painter: _Ckckm022A15SignaturePainter(
                            strokes: _strokes,
                            strokeColor: colorScheme.onSurface,
                            backgroundColor: colorScheme.surface,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_localError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _localError!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _submitting ? null : _reset,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submitting ? null : _confirmSignature,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.lock),
                        label: Text(_submitting ? 'Submitting' : 'Confirm signature'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Ckckm022A15SignaturePainter extends CustomPainter {
  const _Ckckm022A15SignaturePainter({
    required this.strokes,
    required this.strokeColor,
    required this.backgroundColor,
  });

  final List<List<Offset>> strokes;
  final Color strokeColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _Ckckm022A15SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}