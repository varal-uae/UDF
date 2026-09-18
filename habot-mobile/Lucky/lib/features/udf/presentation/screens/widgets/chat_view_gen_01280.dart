// GEN-01280 — Mobile Chat View with Message Bubbles.
// Displays chat messages aligned right for parent and left for provider using M3 Elevated Cards and responsive layout.

import 'package:flutter/material.dart';

enum MessageSender { parent, provider }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

class _MockChatRepository {
  static List<ChatMessage> getMessages() {
    return [
      ChatMessage(
        id: 'msg_001',
        text: 'Hello, I need assistance with my child\'s schedule.',
        sender: MessageSender.parent,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ChatMessage(
        id: 'msg_002',
        text: 'Sure, I can help you with that. What time works best?',
        sender: MessageSender.provider,
        timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
      ),
      ChatMessage(
        id: 'msg_003',
        text: 'Can we do it around 3 PM tomorrow?',
        sender: MessageSender.parent,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      ChatMessage(
        id: 'msg_004',
        text: '3 PM works perfectly. I will send a confirmation shortly.',
        sender: MessageSender.provider,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      ChatMessage(
        id: 'msg_005',
        text: 'Thank you so much!',
        sender: MessageSender.parent,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}

class ChatViewGen01280 extends StatefulWidget {
  const ChatViewGen01280({super.key});

  @override
  State<ChatViewGen01280> createState() => _ChatViewGen01280State();
}

class _ChatViewGen01280State extends State<ChatViewGen01280> {
  late List<ChatMessage> _messages;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = _MockChatRepository.getMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: text.trim(),
        sender: MessageSender.parent,
        timestamp: DateTime.now(),
      ));
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final isDesktop = MediaQuery.of(context).size.width >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  setState(() {
                    _messages = _MockChatRepository.getMessages();
                  });
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: message.sender == MessageSender.parent
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (isDesktop && message.sender == MessageSender.provider)
                                const SizedBox(width: 120),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * (isDesktop ? 0.5 : 0.75),
                                ),
                                child: _MessageBubble(
                                  message: message,
                                  theme: theme,
                                ),
                              ),
                              if (isDesktop && message.sender == MessageSender.parent)
                                const SizedBox(width: 120),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            _buildInputArea(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 48.0,
            height: 48.0,
            child: FilledButton(
              onPressed: () => _sendMessage(_controller.text),
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.send_rounded, size: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ThemeData theme;

  const _MessageBubble({
    required this.message,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isParent = message.sender == MessageSender.parent;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16.0),
          topRight: const Radius.circular(16.0),
          bottomLeft: Radius.circular(isParent ? 16.0 : 4.0),
          bottomRight: Radius.circular(isParent ? 4.0 : 16.0),
        ),
      ),
      color: isParent
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isParent
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4.0),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(message.timestamp),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isParent
                      ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7)
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
