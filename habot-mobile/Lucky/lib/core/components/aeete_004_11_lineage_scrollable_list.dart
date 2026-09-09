// AEETE-004-11 — Scrollable lineage list alternative for mobile viewports.
// Provides touch-expandable lineage nodes with interactive hash truncation handlers,
// following Material 3 design and accessibility touch-target requirements.

import 'package:flutter/material.dart';

/// A node in a data lineage graph rendered as a mobile-friendly list.
class Aeete00411LineageNode {
  const Aeete00411LineageNode({
    required this.id,
    required this.label,
    required this.hash,
    this.children = const [],
  });

  final String id;
  final String label;
  final String hash;
  final List<Aeete00411LineageNode> children;
}

/// Scrollable alternative to lineage map graphs for narrow viewports.
class Aeete00411LineageList extends StatelessWidget {
  const Aeete00411LineageList({
    super.key,
    required this.nodes,
    this.onHashTap,
    this.onNodeTap,
  });

  final List<Aeete00411LineageNode> nodes;
  final ValueChanged<String>? onHashTap;
  final ValueChanged<Aeete00411LineageNode>? onNodeTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: nodes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _Aeete00411LineageTile(
        node: nodes[index],
        onHashTap: onHashTap,
        onNodeTap: onNodeTap,
      ),
    );
  }
}

class _Aeete00411LineageTile extends StatefulWidget {
  const _Aeete00411LineageTile({
    required this.node,
    this.onHashTap,
    this.onNodeTap,
  });

  final Aeete00411LineageNode node;
  final ValueChanged<String>? onHashTap;
  final ValueChanged<Aeete00411LineageNode>? onNodeTap;

  @override
  State<_Aeete00411LineageTile> createState() => _Aeete00411LineageTileState();
}

class _Aeete00411LineageTileState extends State<_Aeete00411LineageTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() => _expanded = !_expanded);
              widget.onNodeTap?.call(widget.node);
            },
            leading: widget.node.children.isEmpty
                ? const Icon(Icons.circle_outlined)
                : Icon(_expanded ? Icons.expand_more : Icons.chevron_right),
            title: Text(widget.node.label),
            subtitle: _HashDisplay(
              hash: widget.node.hash,
              onTap: widget.onHashTap,
            ),
          ),
          if (_expanded && widget.node.children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(
                children: widget.node.children
                    .map((child) => _Aeete00411LineageTile(
                          node: child,
                          onHashTap: widget.onHashTap,
                          onNodeTap: widget.onNodeTap,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _HashDisplay extends StatelessWidget {
  const _HashDisplay({required this.hash, this.onTap});

  final String hash;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    final text = hash.length > 12
        ? '${hash.substring(0, 6)}...${hash.substring(hash.length - 6)}'
        : hash;
    return Semantics(
      button: true,
      label: 'Data lineage hash $hash',
      child: GestureDetector(
        onTap: () => onTap?.call(hash),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.content_copy,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
