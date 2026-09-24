// GEN-02143 — System-Native Messaging UI with Conversational Flow.
// Renders a Material 3 messaging interface with clean text separation, single-column mobile layout,
// M3 Elevated Cards, Status Chips, 48x48dp touch targets, pull-to-refresh, and 30s background polling.

import 'dart:async';
import 'package:flutter/material.dart';

enum MessageSender { user, system }

enum StepHealth { high, medium, low }

class MockChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final StepHealth health;

  const MockChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.health,
  });
}

final List<MockChatMessage> _mockMessages = [
  MockChatMessage(
    id: 'msg_001',
    text: 'System initialized. All baseline configurations applied.',
    sender: MessageSender.system,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    health: StepHealth.high,
  ),
  MockChatMessage(
    id: 'msg_002',
    text: 'Requesting conversational flow completion metrics.',
    sender: MessageSender.user,
    timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    health: StepHealth.medium,
  ),
  MockChatMessage(
    id: 'msg_003',
    text: 'Conversational Flow Completion Rate is currently at 82%. Target optimal threshold met.',
    sender: MessageSender.system,
    timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    health: StepHealth.high,
  ),
  MockChatMessage(
    id: 'msg_004',
    text: 'Trigger manual sync for downstream validation checks.',
    sender: MessageSender.user,
    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    health: StepHealth.low,
  ),
];

class MessagingUiGen02143 extends StatefulWidget {
  const MessagingUiGen02143({super.key});

  @override
  State<MessagingUiGen02143> createState() => _MessagingUiGen02143State();
}

class _MessagingUiGen02143State extends State<MessagingUiGen02143> {
  late List<MockChatMessage> _messages;
  Timer? _pollingTimer;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _messages = List.from(_mockMessages);
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Background polling refreshes data every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _simulateDataRefresh();
    });
  }

  Future<void> _simulateDataRefresh() async {
    if (!mounted) return;
    setState(() => _isSyncing = true);
    
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms latency simulation
    
    if (!mounted) return;
    setState(() {
      _isSyncing = false;
    });
  }

  Future<void> _onPullToRefresh() async {
    if (_isSyncing) return;
    await _simulateDataRefresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manual sync completed successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getHealthColor(StepHealth health, ColorScheme colorScheme) {
    switch (health) {
      case StepHealth.high:
        return colorScheme.primary;
      case StepHealth.medium:
        return colorScheme.tertiary;
      case StepHealth.low:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // M3 KPI Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3, // M3 Elevated Cards Level 2 (3dp)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conversational Flow Completion Rate',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '82%',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Chip(
                      label: const Text('Optimal'),
                      backgroundColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Single-column mobile layout messaging list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onPullToRefresh,
              color: colorScheme.primary,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: _messages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.sender == MessageSender.user;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Card(
                        elevation: isUser ? 0 : 3,
                        color: isUser ? colorScheme.primaryContainer : colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: isUser ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: isUser
                                          ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (!isUser) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getHealthColor(message.health, colorScheme),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Bottom Input Area simulating M3 Bottom Sheet trigger
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true, // Read-only interaction as per requirement
                      decoration: InputDecoration(
                        hintText: 'Read-only engineering console...',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 48x48dp touch target
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Configuration Inputs', style: Theme.of(ctx).textTheme.titleLarge),
                                const SizedBox(height: 16),
                                const Text('M3 Bottom Sheet for configuration inputs.'),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: FilledButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Close'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.settings_outlined, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}