import 'package:flutter/material.dart';

/// Unique styling tokens for the Locked Bottom Panel Keyboard Host.
abstract final class LockedPanelKeyboardTokens {
  static const Color primaryIndigo = Color(0xFF4338CA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const Color panelBg = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF1F5F9);
}

/// A pinned bottom panel with interactive virtual keyboard triggering and viewport insets management.
class LockedBottomPanelKeyboardHost extends StatefulWidget {
  final void Function(String query)? onQuerySubmitted;

  const LockedBottomPanelKeyboardHost({
    super.key,
    this.onQuerySubmitted,
  });

  @override
  State<LockedBottomPanelKeyboardHost> createState() =>
      _LockedBottomPanelKeyboardHostState();
}

class _LockedBottomPanelKeyboardHostState
    extends State<LockedBottomPanelKeyboardHost> {
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  bool _isKeyboardActive = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardActive = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _triggerKeyboard() {
    _focusNode.requestFocus();
  }

  void _dismissKeyboard() {
    _focusNode.unfocus();
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onQuerySubmitted?.call(text);
      _textController.clear();
      _dismissKeyboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect system keyboard bottom insets if nested inside a scaffold with real IME
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: LockedPanelKeyboardTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: LockedPanelKeyboardTokens.borderLight),
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
                  color: LockedPanelKeyboardTokens.primaryIndigo.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.keyboard_rounded,
                  color: LockedPanelKeyboardTokens.primaryIndigo,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Locked Bottom Keyboard Host',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: LockedPanelKeyboardTokens.textDark,
                      ),
                    ),
                    Text(
                      'Viewport Insets Avoidance & Virtual Keyboard Trigger',
                      style: TextStyle(
                        fontSize: 12,
                        color: LockedPanelKeyboardTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isKeyboardActive
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isKeyboardActive ? 'IME FOCUSED' : 'PANEL IDLE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _isKeyboardActive
                        ? const Color(0xFFB45309)
                        : const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Scrollable Activity Feed simulation
          Container(
            height: 90,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: LockedPanelKeyboardTokens.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: LockedPanelKeyboardTokens.borderLight),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feed Area (Safe from Virtual Keyboard Occlusion)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: LockedPanelKeyboardTokens.textDark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '• Real-time channel telemetry logs active.\n'
                  '• Bottom panel auto-lifts via viewInsets without obscuring form buttons.\n'
                  '• WCAG 2.1 touch baseline preserved.',
                  style: TextStyle(
                    fontSize: 10,
                    color: LockedPanelKeyboardTokens.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Locked Bottom Panel Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: 10 + (bottomInsets > 0 ? 8 : 0),
            ),
            decoration: BoxDecoration(
              color: LockedPanelKeyboardTokens.panelBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isKeyboardActive
                    ? LockedPanelKeyboardTokens.primaryIndigo
                    : LockedPanelKeyboardTokens.borderLight,
                width: _isKeyboardActive ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSubmit(),
                    decoration: InputDecoration(
                      hintText: 'Type command or telemetry tag...',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: LockedPanelKeyboardTokens.textMuted,
                      ),
                      filled: true,
                      fillColor: LockedPanelKeyboardTokens.inputBg,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.terminal_rounded, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isKeyboardActive ? _handleSubmit : _triggerKeyboard,
                  icon: Icon(
                    _isKeyboardActive
                        ? Icons.send_rounded
                        : Icons.keyboard_alt_outlined,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: LockedPanelKeyboardTokens.primaryIndigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(44, 44),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Control Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Status: ${_isKeyboardActive ? 'Keyboard Activated' : 'Unfocused'}',
                style: const TextStyle(
                  fontSize: 11,
                  color: LockedPanelKeyboardTokens.textMuted,
                ),
              ),
              if (_isKeyboardActive)
                TextButton(
                  onPressed: _dismissKeyboard,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Dismiss Keyboard',
                      style: TextStyle(fontSize: 11)),
                ),
            ],
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
            child: LockedBottomPanelKeyboardHost(),
          ),
        ),
      ),
    ),
  );
}
