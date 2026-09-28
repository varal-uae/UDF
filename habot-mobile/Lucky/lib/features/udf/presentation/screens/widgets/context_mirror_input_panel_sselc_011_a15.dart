// SSELC-011-A15 — ContextMirrorInputPanel: Split-screen data correction workspace panel.
// Provides a reusable text correction entry field layout with 48dp minimum touch targets,
// dynamic active field highlighting using md.sys.color.primary, keyboard-aware scrolling,
// input masking linked to dropdown state, and poka-yoke blank submission blocking.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock domain models for Workspace context data.
class WorkspaceConfig {
  final String workspaceName;
  final String workspaceId;
  final String status;
  final List<String> memberList;

  const WorkspaceConfig({
    required this.workspaceName,
    required this.workspaceId,
    required this.status,
    required this.memberList,
  });
}

/// Hardcoded mock data simulating backend payload.
const WorkspaceConfig _mockWorkspace = WorkspaceConfig(
  workspaceName: 'UDF Correction Workspace Alpha',
  workspaceId: 'WS-99281-X',
  status: 'Active',
  memberList: ['Operator A', 'Operator B', 'Supervisor C'],
);

enum CorrectionFieldType { plainText, numericCode, maskedId }

/// Reusable split-screen contextual mirror input panel component.
class ContextMirrorInputPanel extends StatefulWidget {
  final WorkspaceConfig workspace;
  final VoidCallback? onSubmissionSuccess;

  const ContextMirrorInputPanel({
    super.key,
    this.workspace = _mockWorkspace,
    this.onSubmissionSuccess,
  });

  @override
  State<ContextMirrorInputPanel> createState() => _ContextMirrorInputPanelState();
}

class _ContextMirrorInputPanelState extends State<ContextMirrorInputPanel> {
  final _formKey = GlobalKey<FormState>();
  final _correctionController = TextEditingController();
  final _notesController = TextEditingController();
  
  CorrectionFieldType _selectedFieldType = CorrectionFieldType.plainText;
  bool _isFieldFocused = false;

  @override
  void dispose() {
    _correctionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Dynamic regex updating based on dropdown selection (Input Masking).
  List<TextInputFormatter> _buildInputFormatters() {
    switch (_selectedFieldType) {
      case CorrectionFieldType.numericCode:
        return [FilteringTextInputFormatter.digitsOnly];
      case CorrectionFieldType.maskedId:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
        ];
      case CorrectionFieldType.plainText:
      default:
        return [];
    }
  }

  TextInputType _buildKeyboardType() {
    switch (_selectedFieldType) {
      case CorrectionFieldType.numericCode:
        return TextInputType.number;
      case CorrectionFieldType.maskedId:
        return TextInputType.text;
      case CorrectionFieldType.plainText:
      default:
        return TextInputType.multiline;
    }
  }

  void _submitCorrection() {
    // Poka-Yoke: The entry panel blocks form submission completely if the user
    // attempts to send a text correction field blank.
    if (_correctionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correction field cannot be blank.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Simulate streaming corrected data packages back into system pipelines
      widget.onSubmissionSuccess?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correction submitted successfully.')),
      );
      _correctionController.clear();
      _notesController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Embed touch interaction blockers to prevent operators from panning or dragging
    // out of the isolated viewport window.
    return GestureDetector(
      onPanStart: (details) => details.delta = Offset.zero,
      onHorizontalDragStart: (details) {},
      onVerticalDragStart: (details) {},
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.workspace.workspaceName),
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
        // Use scroll containers that adjust for on-screen keyboards to keep inputs visible
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Upper/Left Pane: Reference Material / Context Data
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    color: colorScheme.surfaceContainerLow,
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reference Context',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Workspace ID', widget.workspace.workspaceId, theme),
                          _buildInfoRow('Status', widget.workspace.status, theme),
                          _buildInfoRow(
                            'Members',
                            widget.workspace.memberList.join(', '),
                            theme,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Original Text Block:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: const Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Lower/Right Pane: Correction Entry Area
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    // Apply distinct background tones to make it clear which input field is currently active
                    color: _isFieldFocused
                        ? colorScheme.primaryContainer.withOpacity(0.2)
                        : colorScheme.surface,
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Correction Entry',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Dropdown linked to input masking
                          DropdownButtonFormField<CorrectionFieldType>(
                            value: _selectedFieldType,
                            decoration: InputDecoration(
                              labelText: 'Field Type',
                              border: const OutlineInputBorder(),
                              constraints: const BoxConstraints(minHeight: 48),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            ),
                            items: CorrectionFieldType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.name.replaceAll('_', ' ').toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedFieldType = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Minimum touch height of 48dp for easy selection
                          Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {
                                _isFieldFocused = hasFocus;
                              });
                            },
                            child: TextFormField(
                              controller: _correctionController,
                              keyboardType: _buildKeyboardType(),
                              inputFormatters: _buildInputFormatters(),
                              maxLines: 4,
                              minLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Corrected Text',
                                hintText: 'Enter correction here...',
                                border: const OutlineInputBorder(),
                                constraints: const BoxConstraints(minHeight: 48),
                                filled: true,
                                // Update active input field highlight properties dynamically
                                // using design system token colors (md.sys.color.primary)
                                fillColor: _isFieldFocused
                                    ? colorScheme.primary.withOpacity(0.08)
                                    : colorScheme.surfaceContainerHighest.withOpacity(0.1),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Correction text is required.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _notesController,
                            maxLines: 2,
                            minLines: 1,
                            decoration: InputDecoration(
                              labelText: 'Operator Notes (Optional)',
                              border: const OutlineInputBorder(),
                              constraints: const BoxConstraints(minHeight: 48),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 48, // Minimum touch height
                            child: FilledButton.icon(
                              onPressed: _submitCorrection,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Submit Correction'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}