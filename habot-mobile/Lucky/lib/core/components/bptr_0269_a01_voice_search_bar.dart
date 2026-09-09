// BPTR-0269-A01 — Voice-enabled Search Input Area with Material 3 layout and permission-safe speech hooks.
// Integrates speech-to-text with 56dp tap target, mic animation, 4s silence auto-stop, clear button, and fallback to typing on permission denial.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceSearchBar extends StatefulWidget {
  const VoiceSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onVoiceResult,
    this.hintText = 'Speak or type to search...',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final ValueChanged<String>? onVoiceResult;
  final String hintText;

  @override
  State<VoiceSearchBar> createState() => _VoiceSearchBarState();
}

class _VoiceSearchBarState extends State<VoiceSearchBar>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  Timer? _silenceTimer;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleControllerChanged);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
    _initSpeech();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize();
      if (!mounted) return;
      setState(() => _speechAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  Future<void> _handleMicTap() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    final granted = await _requestMicrophonePermission();
    if (!granted) {
      _showPermissionDeniedMessage();
      return;
    }

    if (!_speechAvailable) {
      _showSpeechUnavailableMessage();
      return;
    }

    await _startListening();
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startListening() async {
    setState(() => _isListening = true);
    _pulseController.repeat(reverse: true);

    _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      cancelOnError: true,
      partialResults: false,
    );

    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 4), () {
      if (_isListening) {
        _stopListening();
      }
    });
  }

  Future<void> _stopListening() async {
    _silenceTimer?.cancel();
    _pulseController.stop();
    if (_isListening) {
      await _speech.stop();
    }
    if (mounted) setState(() => _isListening = false);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted || result.finalResult == false) return;
    final words = result.recognizedWords.trim();
    if (words.isEmpty) return;
    _controller.text = words;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    widget.onChanged?.call(words);
    widget.onVoiceResult?.call(words);
    _stopListening();
  }

  void _clearInput() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    if (_isListening) _stopListening();
    if (mounted) setState(() {});
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Microphone permission denied. You can still type to search.'),
      ),
    );
  }

  void _showSpeechUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search is unavailable on this device.'),
      ),
    );
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _pulseController.dispose();
    if (widget.controller == null) _controller.dispose();
    _controller.removeListener(_handleControllerChanged);
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIconConstraints: const BoxConstraints(minWidth: 112),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMicButton(),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearInput,
                  tooltip: 'Clear search',
                ),
            ],
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return IconButton(
      icon: _isListening
          ? _PulsingMicIcon(animation: _pulseController)
          : const Icon(Icons.mic_none),
      onPressed: _handleMicTap,
      tooltip: _isListening ? 'Stop voice search' : 'Start voice search',
    );
  }
}

class _PulsingMicIcon extends StatelessWidget {
  const _PulsingMicIcon({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: child,
        );
      },
      child: const Icon(Icons.mic),
    );
  }
}
