// AEETE-011-15 — Dynamic feature config utility menu with adaptive layout and sanitized paste field.
// Supports mobile sub-panel lists, wide-screen primary nav badges/descriptions, and paste input filtering.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents a remotely toggled feature flag shown in utility menus.
class FeatureFlagConfig {
  const FeatureFlagConfig({
    required this.id,
    required this.label,
    required this.isEnabled,
    this.updatedWorkspace = false,
    this.description = '',
  });

  final String id;
  final String label;
  final bool isEnabled;
  final bool updatedWorkspace;
  final String description;

  FeatureFlagConfig copyWith({
    bool? isEnabled,
    bool? updatedWorkspace,
  }) {
    return FeatureFlagConfig(
      id: id,
      label: label,
      isEnabled: isEnabled ?? this.isEnabled,
      updatedWorkspace: updatedWorkspace ?? this.updatedWorkspace,
      description: description,
    );
  }
}

/// Adaptive panel for grouping advanced testing features.
/// Mobile: single sub-panel list with badges.
/// Wide/desktop: primary navigation list + description box beside selected flag.
class FeatureConfigMenuPanel extends StatefulWidget {
  const FeatureConfigMenuPanel({
    super.key,
    required this.configs,
    required this.onConfigChanged,
  });

  final List<FeatureFlagConfig> configs;
  final ValueChanged<FeatureFlagConfig> onConfigChanged;

  @override
  State<FeatureConfigMenuPanel> createState() => _FeatureConfigMenuPanelState();
}

class _FeatureConfigMenuPanelState extends State<FeatureConfigMenuPanel> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        if (isWide) {
          return _buildWideLayout();
        }
        return _buildMobileLayout();
      },
    );
  }

  Widget _buildMobileLayout() {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < widget.configs.length; i++)
            ExpansionTile(
              leading: _FeatureBadge(updated: widget.configs[i].updatedWorkspace),
              title: Text(widget.configs[i].label),
              subtitle: Text(widget.configs[i].description),
              trailing: Switch(
                value: widget.configs[i].isEnabled,
                onChanged: (value) {
                  widget.onConfigChanged(widget.configs[i].copyWith(isEnabled: value));
                },
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(widget.configs[i].description),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: ListView(
            children: [
              for (int i = 0; i < widget.configs.length; i++)
                ListTile(
                  selected: _selectedIndex == i,
                  selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
                  leading: _FeatureBadge(updated: widget.configs[i].updatedWorkspace),
                  title: Text(widget.configs[i].label),
                  trailing: Switch(
                    value: widget.configs[i].isEnabled,
                    onChanged: (value) {
                      widget.onConfigChanged(widget.configs[i].copyWith(isEnabled: value));
                    },
                  ),
                  onTap: () => setState(() => _selectedIndex = i),
                ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedIndex == null
              ? const Center(child: Text('Select a feature to view details'))
              : _FeatureDetailsPanel(
                  config: widget.configs[_selectedIndex!],
                  onChanged: (value) {
                    widget.onConfigChanged(
                      widget.configs[_selectedIndex!].copyWith(isEnabled: value),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.updated});

  final bool updated;

  @override
  Widget build(BuildContext context) {
    if (!updated) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'UPDATED',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _FeatureDetailsPanel extends StatelessWidget {
  const _FeatureDetailsPanel({
    required this.config,
    required this.onChanged,
  });

  final FeatureFlagConfig config;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(config.label, style: Theme.of(context).textTheme.headlineSmall)),
              Switch(value: config.isEnabled, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: 12),
          Text(config.description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// Text field that sanitizes pasted content and typed input against a character filter.
/// In Flutter, paste goes through the same input formatter pipeline as keyboard input,
/// so a single FilteringTextInputFormatter enforces the character policy.
class SanitizedPasteTextField extends StatelessWidget {
  const SanitizedPasteTextField({
    super.key,
    required this.controller,
    required this.allowedPattern,
    this.labelText,
    this.hintText,
  });

  final TextEditingController controller;
  final RegExp allowedPattern;
  final String? labelText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      inputFormatters: [
        FilteringTextInputFormatter.allow(allowedPattern),
      ],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}