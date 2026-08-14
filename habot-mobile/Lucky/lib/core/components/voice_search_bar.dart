import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/debouncer.dart';
import '../utils/speech_hook.dart';

// BPTR-0269-A05 — Voice-enabled search input area.
//
// M3 Search Bar layout:
//   - 56dp height touch target
//   - Microphone icon with pulse animation when listening
//   - Debounced filter loop (300ms)
//   - Permission-safe fallback — text entry always works
//   - Auto-stop listening after 4s pause (SpeechHook)

class HabotVoiceSearchBar extends StatefulWidget {
  const HabotVoiceSearchBar({
    super.key,
    this.hint = 'Speak or type to search…',
    this.onQueryChanged,
    this.debounceDuration = DebounceDuration.input,
    this.controller,
  });

  final String hint;
  final ValueChanged<String>? onQueryChanged;
  final Duration debounceDuration;
  final TextEditingController? controller;

  @override
  State<HabotVoiceSearchBar> createState() => _HabotVoiceSearchBarState();
}

class _HabotVoiceSearchBarState extends State<HabotVoiceSearchBar>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final Debouncer _debouncer;
  late final AnimationController _pulse;

  bool _isListening = false;
  bool _hasText = false;
  Timer? _listenTimeout;

  static const _barHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _debouncer  = Debouncer(delay: widget.debounceDuration);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_syncHasText);
  }

  void _syncHasText() {
    final next = _controller.text.isNotEmpty;
    if (next != _hasText && mounted) setState(() => _hasText = next);
  }

  @override
  void dispose() {
    _listenTimeout?.cancel();
    _debouncer.dispose();
    _pulse.dispose();
    _controller.removeListener(_syncHasText);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debouncer.run(() => widget.onQueryChanged?.call(value));
  }

  void _clear() {
    _controller.clear();
    widget.onQueryChanged?.call('');
    _stopListening();
  }

  Future<void> _toggleVoice() async {
    if (_isListening) {
      _stopListening();
      return;
    }

    final started = await SpeechHook.listen(
      pauseTimeout: const Duration(seconds: 4),
      onResult: (text) {
        if (!mounted) return;
        _controller.text = text;
        _controller.selection = TextSelection.collapsed(offset: text.length);
        _onTextChanged(text);
      },
    );

    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Voice search unavailable — continue typing instead.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() => _isListening = true);
    _pulse.repeat();

    _listenTimeout?.cancel();
    _listenTimeout = Timer(const Duration(seconds: 4), _stopListening);
  }

  void _stopListening() {
    _listenTimeout?.cancel();
    SpeechHook.stop();
    if (_isListening) {
      _pulse.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SearchBar(
      hintText: widget.hint,
      controller: _controller,
      onChanged: _onTextChanged,
      leading: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
      trailing: [
        _VoiceMicButton(
          isListening: _isListening,
          pulse: _pulse,
          onPressed: _toggleVoice,
        ),
        if (_hasText)
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: 'Clear',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: _clear,
          ),
      ],
      constraints: const BoxConstraints(minHeight: _barHeight),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      elevation: WidgetStateProperty.all(0),
    );
  }
}

class _VoiceMicButton extends StatelessWidget {
  const _VoiceMicButton({
    required this.isListening,
    required this.pulse,
    required this.onPressed,
  });

  final bool isListening;
  final AnimationController pulse;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      tooltip: isListening ? 'Stop listening' : 'Voice search',
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: onPressed,
      icon: AnimatedBuilder(
        animation: pulse,
        builder: (_, child) {
          final scale = isListening ? 1.0 + pulse.value * 0.15 : 1.0;
          return Transform.scale(
            scale: scale,
            child: Icon(
              isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: isListening
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}
