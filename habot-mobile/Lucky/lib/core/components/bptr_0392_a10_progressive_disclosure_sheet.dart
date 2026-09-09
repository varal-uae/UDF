// BPTR-0392-A10 — Progressive Disclosure Bottom Sheets: bite-sized contextual selection with Material 3 bottom sheet, dimmed scrim, swipe-to-dismiss, and terminal-node apply gating.
// Cascading logic opens the sheet on click and disables Apply until a terminal node is selected; attempted dismiss without selection vibrates the phone and pulses the required field.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A node in a cascading progressive-disclosure selection tree.
class ProgressiveDisclosureNode<T> {
  const ProgressiveDisclosureNode({
    required this.label,
    this.terminalValue,
    this.children = const [],
  }) : assert(terminalValue != null || children.isNotEmpty,
            'A non-terminal node must have children.');

  final String label;
  final T? terminalValue;
  final List<ProgressiveDisclosureNode<T>> children;

  bool get isTerminal => terminalValue != null;
}

/// Opens a Material 3 progressive-disclosure bottom sheet.
Future<T?> showProgressiveDisclosureBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<ProgressiveDisclosureNode<T>> nodes,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    enableDrag: true,
    builder: (sheetContext) => _ProgressiveDisclosureSheet<T>(
      title: title,
      nodes: nodes,
    ),
  );
}

/// Reusable trigger that opens the bottom sheet on click.
class ProgressiveDisclosureField<T> extends StatelessWidget {
  const ProgressiveDisclosureField({
    super.key,
    required this.label,
    required this.sheetTitle,
    required this.nodes,
    this.valueLabel,
    this.hintText = 'Select',
    this.onChanged,
  });

  final String label;
  final String sheetTitle;
  final List<ProgressiveDisclosureNode<T>> nodes;
  final String? valueLabel;
  final String hintText;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await showProgressiveDisclosureBottomSheet<T>(
          context: context,
          title: sheetTitle,
          nodes: nodes,
        );
        if (result != null) {
          onChanged?.call(result);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(valueLabel ?? hintText),
      ),
    );
  }
}

class _ProgressiveDisclosureSheet<T> extends StatefulWidget {
  const _ProgressiveDisclosureSheet({
    required this.title,
    required this.nodes,
  });

  final String title;
  final List<ProgressiveDisclosureNode<T>> nodes;

  @override
  State<_ProgressiveDisclosureSheet<T>> createState() =>
      _ProgressiveDisclosureSheetState<T>();
}

class _ProgressiveDisclosureSheetState<T>
    extends State<_ProgressiveDisclosureSheet<T>>
    with SingleTickerProviderStateMixin {
  late final List<List<ProgressiveDisclosureNode<T>>> _stack;
  T? _selectedValue;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _stack = [widget.nodes];
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.06), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 0.97), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerPulse() {
    _pulseController.forward(from: 0);
    HapticFeedback.vibrate();
  }

  void _selectTerminal(ProgressiveDisclosureNode<T> node) {
    setState(() => _selectedValue = node.terminalValue);
  }

  void _openNode(ProgressiveDisclosureNode<T> node) {
    setState(() => _stack.add(node.children));
  }

  void _back() {
    if (_stack.length > 1) {
      setState(() => _stack.removeLast());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentNodes = _stack.last;

    return PopScope<T>(
      canPop: _selectedValue != null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedValue == null) {
          _triggerPulse();
        }
      },
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_stack.length > 1)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_selectedValue != null) {
                        Navigator.pop(context, _selectedValue);
                      } else {
                        _triggerPulse();
                      }
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Column(
                      children: currentNodes
                          .map(
                            (node) => _OptionTile<T>(
                              node: node,
                              isSelected: node.terminalValue == _selectedValue,
                              onTap: node.isTerminal
                                  ? () => _selectTerminal(node)
                                  : () => _openNode(node),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _selectedValue == null
                    ? null
                    : () => Navigator.pop(context, _selectedValue),
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile<T> extends StatelessWidget {
  const _OptionTile({
    required this.node,
    required this.isSelected,
    required this.onTap,
  });

  final ProgressiveDisclosureNode<T> node;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? scheme.secondaryContainer : scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          title: Text(node.label),
          trailing: node.isTerminal
              ? Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? scheme.primary : scheme.outline,
                )
              : const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
