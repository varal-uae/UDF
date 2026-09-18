// GEN-01589 — Message Input Composer with Text, Voice Notes, and Photo Attachments.
// Embeds input fields for text entry, voice notes, and photo attachments using M3 Elevated Cards, Bottom Sheets, and responsive layouts.

import 'package:flutter/material.dart';

/// Mock data model representing a composed message payload.
class MessagePayload {
  final String text;
  final bool hasVoiceNote;
  final bool hasPhotoAttachment;
  final DateTime timestamp;

  const MessagePayload({
    required this.text,
    required this.hasVoiceNote,
    required this.hasPhotoAttachment,
    required this.timestamp,
  });
}

/// Controller to manage state for the message input composer.
class MessageInputController extends ChangeNotifier {
  final TextEditingController textEditingController = TextEditingController();
  bool _isRecordingVoice = false;
  bool _hasPhotoAttached = false;
  final List<MessagePayload> _sentMessages = [];

  bool get isRecordingVoice => _isRecordingVoice;
  bool get hasPhotoAttached => _hasPhotoAttached;
  List<MessagePayload> get sentMessages => List.unmodifiable(_sentMessages);

  void toggleVoiceRecording() {
    _isRecordingVoice = !_isRecordingVoice;
    notifyListeners();
  }

  void attachPhoto() {
    _hasPhotoAttached = true;
    notifyListeners();
  }

  void removePhoto() {
    _hasPhotoAttached = false;
    notifyListeners();
  }

  void sendMessage() {
    final text = textEditingController.text.trim();
    if (text.isEmpty && !_hasPhotoAttached && !_isRecordingVoice) return;

    _sentMessages.add(MessagePayload(
      text: text,
      hasVoiceNote: _isRecordingVoice,
      hasPhotoAttachment: _hasPhotoAttached,
      timestamp: DateTime.now(),
    ));

    textEditingController.clear();
    _isRecordingVoice = false;
    _hasPhotoAttached = false;
    notifyListeners();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}

/// Main widget embedding input fields for text entry, voice notes, and photo attachments.
/// Implements M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
class MessageInputComposerGen01589 extends StatefulWidget {
  const MessageInputComposerGen01589({super.key});

  @override
  State<MessageInputComposerGen01589> createState() => _MessageInputComposerGen01589State();
}

class _MessageInputComposerGen01589State extends State<MessageInputComposerGen01589> {
  late final MessageInputController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MessageInputController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.removeListener(() => setState(() {}));
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isDesktop) {
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMessageHistoryList(),
        _buildInputCard(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildMessageHistoryList()),
        const SizedBox(width: 16),
        Expanded(flex: 1, child: _buildInputCard(context)),
      ],
    );
  }

  Widget _buildMessageHistoryList() {
    if (_controller.sentMessages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('No messages yet. Start composing below.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _controller.sentMessages.length,
      itemBuilder: (context, index) {
        final msg = _controller.sentMessages[index];
        return Card(
          elevation: 2, // M3 Elevated Cards Level 2 (3dp approximation)
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(msg.text.isEmpty ? '[Media/Voice]' : msg.text),
            subtitle: Text(
              '${msg.timestamp.toLocal().toString().split('.').first}\n'
              'Voice: ${msg.hasVoiceNote ? "Yes" : "No"} | Photo: ${msg.hasPhotoAttachment ? "Yes" : "No"}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildInputCard(BuildContext context) {
    return Card(
      elevation: 2, // M3 Elevated Cards Level 2 (3dp)
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text Entry Field
            TextField(
              controller: _controller.textEditingController,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Enter text message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons Row (48x48dp touch targets)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Photo Attachment Button
                _buildActionButton(
                  icon: Icons.photo_camera_outlined,
                  label: 'Photo',
                  isActive: _controller.hasPhotoAttached,
                  onTap: () => _showConfigurationBottomSheet(context, isPhoto: true),
                ),
                // Voice Note Button
                _buildActionButton(
                  icon: _controller.isRecordingVoice ? Icons.stop_circle : Icons.mic_none,
                  label: _controller.isRecordingVoice ? 'Stop' : 'Voice',
                  isActive: _controller.isRecordingVoice,
                  onTap: () => _showConfigurationBottomSheet(context, isPhoto: false),
                ),
                // Send Button
                _buildActionButton(
                  icon: Icons.send_rounded,
                  label: 'Send',
                  isActive: false,
                  isPrimary: true,
                  onTap: _controller.sendMessage,
                ),
              ],
            ),

            // Status Chips (M3 Status Chips for health indicators)
            if (_controller.hasPhotoAttached || _controller.isRecordingVoice)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (_controller.hasPhotoAttached)
                      Chip(
                        avatar: const Icon(Icons.image, size: 18),
                        label: const Text('Photo Attached'),
                        onDeleted: _controller.removePhoto,
                      ),
                    if (_controller.isRecordingVoice)
                      Chip(
                        avatar: const Icon(Icons.graphic_eq, size: 18),
                        label: const Text('Recording...'),
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    final color = isPrimary
        ? theme.colorScheme.primary
        : (isActive ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 48, // 48x48dp touch targets
        height: 48, // 48x48dp touch targets
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// M3 Bottom Sheet for configuration inputs as per requirements.
  void _showConfigurationBottomSheet(BuildContext context, {required bool isPhoto}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPhoto ? 'Attach Photo' : 'Record Voice Note',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  isPhoto
                      ? 'Select an image from your gallery or take a new photo to embed in the message.'
                      : 'Press the button below to start or stop recording your voice note.',
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48, // 48x48dp touch target
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (isPhoto) {
                        _controller.attachPhoto();
                        _showSnackbar(context, 'Photo attached successfully.');
                      } else {
                        _controller.toggleVoiceRecording();
                        _showSnackbar(
                          context,
                          _controller.isRecordingVoice ? 'Voice recording started.' : 'Voice recording stopped.',
                        );
                      }
                    },
                    child: Text(isPhoto ? 'Choose Image' : (_controller.isRecordingVoice ? 'Stop Recording' : 'Start Recording')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// M3 Snackbar for confirmations as per requirements.
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}