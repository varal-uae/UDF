import 'package:flutter/material.dart';

// FEBFL-027-09 — Programmatic Layout Mapping Engine.
// Spec: "Deploy a dynamic layout rendering engine that reads backend
//        JSON instructions to assemble screens automatically."
//       "Bind data fields from JSON payload directly to UI component properties."
//
// How it works:
//   Backend sends a JSON schema → LayoutRenderer parses it →
//   Assembles Flutter widgets at runtime — no hardcoded screen structure.
//
// Supported component types (extensible):
//   text, heading, subheading, divider, spacer,
//   textField, numberField, dateField, dropdown, toggle, checkbox,
//   button, card, row, column, padding

// ── JSON schema types ─────────────────────────────────────────────────────────

/// Represents one component node from the backend JSON layout schema.
class LayoutNode {
  const LayoutNode({
    required this.type,
    this.id,
    this.properties = const {},
    this.children = const [],
  });

  final String type;
  final String? id;
  final Map<String, dynamic> properties;
  final List<LayoutNode> children;

  factory LayoutNode.fromJson(Map<String, dynamic> json) {
    return LayoutNode(
      type:       json['type'] as String? ?? 'text',
      id:         json['id'] as String?,
      properties: (json['properties'] as Map<String, dynamic>?) ?? {},
      children:   (json['children'] as List<dynamic>?)
              ?.map((c) => LayoutNode.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  dynamic prop(String key, [dynamic fallback]) => properties[key] ?? fallback;
}

// ── Layout renderer ───────────────────────────────────────────────────────────

class LayoutRenderer extends StatelessWidget {
  const LayoutRenderer({
    super.key,
    required this.schema,
    this.onFieldChanged,
    this.onAction,
  });

  /// List of root-level LayoutNodes from backend JSON.
  final List<LayoutNode> schema;

  /// Fires when any input field changes: (fieldId, value)
  final void Function(String id, dynamic value)? onFieldChanged;

  /// Fires when any button/action is tapped: (actionId)
  final void Function(String actionId)? onAction;

  /// Parse JSON array directly.
  factory LayoutRenderer.fromJson(
    List<dynamic> json, {
    void Function(String, dynamic)? onFieldChanged,
    void Function(String)? onAction,
  }) {
    return LayoutRenderer(
      schema: json
          .map((e) => LayoutNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      onFieldChanged: onFieldChanged,
      onAction:       onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: schema
          .map((node) => _buildNode(context, node))
          .toList(),
    );
  }

  Widget _buildNode(BuildContext context, LayoutNode node) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    switch (node.type) {
      // ── Text ──
      case 'text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            node.prop('value', '') as String,
            style: theme.textTheme.bodyMedium,
          ),
        );

      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            node.prop('value', '') as String,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        );

      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Text(
            node.prop('value', '') as String,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        );

      // ── Structural ──
      case 'divider':
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child:   Divider(),
        );

      case 'spacer':
        return SizedBox(height: (node.prop('height', 16) as num).toDouble());

      // ── Input fields ──
      case 'textField':
      case 'numberField':
      case 'dateField':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            keyboardType: node.type == 'numberField'
                ? TextInputType.number
                : node.type == 'dateField'
                    ? TextInputType.datetime
                    : TextInputType.text,
            decoration: InputDecoration(
              labelText: node.prop('label', node.id ?? node.type) as String,
              hintText:  node.prop('hint') as String?,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (v) {
              if (node.id != null) onFieldChanged?.call(node.id!, v);
            },
          ),
        );

      case 'dropdown':
        final options = (node.prop('options', []) as List)
            .map((e) => e.toString())
            .toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: node.prop('label', 'Select') as String,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (v) {
              if (node.id != null && v != null) {
                onFieldChanged?.call(node.id!, v);
              }
            },
          ),
        );

      case 'toggle':
        return SwitchListTile.adaptive(
          title: Text(node.prop('label', node.id ?? 'Toggle') as String),
          value: node.prop('value', false) as bool,
          onChanged: (v) {
            if (node.id != null) onFieldChanged?.call(node.id!, v);
          },
          contentPadding: EdgeInsets.zero,
        );

      case 'checkbox':
        return CheckboxListTile(
          title: Text(node.prop('label', node.id ?? 'Check') as String),
          value: node.prop('value', false) as bool,
          onChanged: (v) {
            if (node.id != null) onFieldChanged?.call(node.id!, v ?? false);
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        );

      // ── Actions ──
      case 'button':
        final isPrimary = node.prop('variant', 'filled') == 'filled';
        final label = node.prop('label', 'Submit') as String;
        final actionId = node.id ?? 'button';

        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: isPrimary
                ? FilledButton(
                    onPressed: () => onAction?.call(actionId),
                    child: Text(label),
                  )
                : OutlinedButton(
                    onPressed: () => onAction?.call(actionId),
                    child: Text(label),
                  ),
          ),
        );

      // ── Layout ──
      case 'card':
        return Card(
          elevation: (node.prop('elevation', 2) as num).toDouble(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: node.children
                  .map((c) => _buildNode(context, c))
                  .toList(),
            ),
          ),
        );

      case 'row':
        return Row(
          children: node.children
              .map((c) => Expanded(child: _buildNode(context, c)))
              .toList(),
        );

      case 'column':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: node.children
              .map((c) => _buildNode(context, c))
              .toList(),
        );

      case 'padding':
        final p = (node.prop('padding', 16) as num).toDouble();
        return Padding(
          padding: EdgeInsets.all(p),
          child: node.children.isNotEmpty
              ? _buildNode(context, node.children.first)
              : const SizedBox.shrink(),
        );

      default:
        // Unknown component type — render nothing in release, warning in debug
        assert(() {
          debugPrint('[LayoutRenderer] Unknown component type: ${node.type}');
          return true;
        }());
        return const SizedBox.shrink();
    }
  }
}
