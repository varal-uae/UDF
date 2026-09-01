import 'dart:math';
import 'package:flutter/material.dart';

/// ============================================================================
/// TELEMETRY METADATA
/// Mobile Platform: Android / iOS / Web
/// OS Version: iOS 17.4 / Android 14 / Web Chrome 124
/// Device Type: Mobile / Tablet / Desktop Web
/// Screen Dimensions: Responsive Breakpoint Adaptive
/// Mobile Configuration: M3 Surface Color Token / Exponential Backoff Ingestion
/// Completion Status: Good (Target < 100ms response time)
/// ============================================================================

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// ACRAE-011: Responsive Mobile-First AI Chat Flow with Strict API Rate-Limit Handling
class MobileFirstAiChatFlow extends StatefulWidget {
  const MobileFirstAiChatFlow({super.key});

  @override
  State<MobileFirstAiChatFlow> createState() => _MobileFirstAiChatFlowState();
}

class _MobileFirstAiChatFlowState extends State<MobileFirstAiChatFlow> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isChatVisible = true;
  bool _isRateLimited = false;
  bool _isSending = false;
  int _retryAttempt = 0;
  String _retryDelayNotice = '';

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'MSG-001',
      text: 'Hello! I am your AI Copilot. How can I assist with your workspace setup today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Exponential Backoff Logic (Poka-Yoke) & 429 Rate-Limit Handling:
  /// Simulates 429 rate limit exceptions, displays subtle SnackBar "Please slow down",
  /// and doubles wait time (1s, 2s, 4s, etc.) before re-enabling controls.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isRateLimited || _isSending) return;

    final userMsg = ChatMessage(
      id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isSending = true;
      _textController.clear();
    });

    _scrollToBottom();

    // Randomly simulate a 429 Rate-Limit Response for demonstration purposes (e.g. 50% chance on fast triggers)
    final bool simulateRateLimit = _retryAttempt > 0 || Random().nextBool();

    if (simulateRateLimit) {
      setState(() {
        _isRateLimited = true;
        _retryAttempt++;
      });

      // Calculate exponential backoff delay: 2^(retryAttempt - 1) seconds capped at 8s
      final int backoffSeconds = min(pow(2, _retryAttempt - 1).toInt(), 8);

      setState(() {
        _retryDelayNotice =
            '429 Too Many Requests: Exponential backoff active (${backoffSeconds}s retry window)...';
      });

      // Subtle SnackBar notification instead of blocking AlertDialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please slow down'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Wait exponential delay time
      await Future.delayed(Duration(seconds: backoffSeconds));

      if (!mounted) return;

      setState(() {
        _isRateLimited = false;
        _retryDelayNotice = '';
      });
    }

    // AI Response Generation
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final aiMsg = ChatMessage(
      id: 'MSG-AI-${DateTime.now().millisecondsSinceEpoch}',
      text: 'Acknowledged: Processing request payload for "$text". All system constraints satisfied.',
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(aiMsg);
      _isSending = false;
      _retryAttempt = 0; // Reset retry attempt on success
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile-First AI Chat Flow'),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_isRateLimited ? Icons.speed : Icons.bolt),
            tooltip: 'Toggle Rate Limit Simulation',
            onPressed: () {
              setState(() {
                _isRateLimited = !_isRateLimited;
              });
              if (_isRateLimited) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please slow down'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
      // M3 Chat Initiation FloatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isChatVisible = !_isChatVisible;
          });
        },
        backgroundColor: theme.colorScheme.primaryContainer,
        elevation: 3.0,
        child: Icon(
          _isChatVisible ? Icons.chat_bubble_outline : Icons.chat,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Rate-Limit Exponential Backoff Notice Bar
              if (_retryDelayNotice.isNotEmpty || _isRateLimited)
                Container(
                  width: double.infinity,
                  color: theme.colorScheme.errorContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top, color: theme.colorScheme.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _retryDelayNotice.isNotEmpty
                              ? _retryDelayNotice
                              : '429 Rate Limit Active: Controls Disabled. Please slow down.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Chat Visibility Body Container
              Expanded(
                child: _isChatVisible
                    ? Column(
                        children: [
                          // Messages ListView.builder
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                return _buildChatBubble(_messages[index], theme);
                              },
                            ),
                          ),

                          // Chat Input Box & Send Button
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              border: Border(
                                top: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _textController,
                                    enabled: !_isRateLimited, // Disabled when rate limited
                                    onSubmitted: (val) => sendMessage(val),
                                    decoration: InputDecoration(
                                      hintText: _isRateLimited
                                          ? 'Rate limited (Please slow down)...'
                                          : 'Type your message...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: _isRateLimited || _isSending
                                      ? null // Disabled when rate limited or sending
                                      : () => sendMessage(_textController.text),
                                   icon: _isSending
                                       ? SizedBox(
                                           width: 18,
                                           height: 18,
                                           child: CircularProgressIndicator(
                                             strokeWidth: 2,
                                             color: theme.colorScheme.onPrimary,
                                           ),
                                         )
                                       : const Icon(Icons.send),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'AI Chat Interface Hidden',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap the Floating Action Button below to open chat.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// M3 Chat Bubble with explicitly mapped surface color & rounded 16.0 corners
  Widget _buildChatBubble(ChatMessage msg, ThemeData theme) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        constraints: const BoxConstraints(maxWidth: 320.0),
        decoration: BoxDecoration(
          // Strict M3 styling: borderRadius 16.0 & AI bubble mapped explicitly to colorScheme.surface
          borderRadius: BorderRadius.circular(16.0),
          color: isUser
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          border: isUser
              ? null
              : Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person : Icons.smart_toy,
                  size: 16,
                  color: isUser
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  isUser ? 'User' : 'AI Copilot',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUser
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                color: isUser
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
