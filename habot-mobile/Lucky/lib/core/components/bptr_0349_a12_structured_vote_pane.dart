// BPTR-0349-A12 — Structured Vote Pane: removes narrative UI waste and free-text inputs.
// Provides a concise label header, a structured single-select choice list, and a bottom voting action pane.
// Submitting without a selected structured category vibrates and shakes the form to prevent unstructured data.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bptr0349A12StructuredVotePane extends StatefulWidget {
  const Bptr0349A12StructuredVotePane({
    super.key,
    required this.title,
    required this.options,
    required this.onSubmit,
    this.submitLabel = 'Submit',
    this.initialSelectedIndex,
  });

  final String title;
  final List<String> options;
  final ValueChanged<int> onSubmit;
  final String submitLabel;
  final int? initialSelectedIndex;

  @override
  State<Bptr0349A12StructuredVotePane> createState() =>
      _Bptr0349A12StructuredVotePaneState();
}

class _Bptr0349A12StructuredVotePaneState
    extends State<Bptr0349A12StructuredVotePane>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  late final AnimationController _shakeController;
  late final Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0.06, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.06, 0), end: const Offset(-0.06, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.06, 0), end: const Offset(0.03, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.03, 0), end: Offset.zero),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedIndex == null) {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
      return;
    }
    widget.onSubmit(_selectedIndex!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select one option',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: _shakeAnimation.value,
                    child: child,
                  ),
                  child: ListView.separated(
                    itemCount: widget.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      return Card(
                        elevation: isSelected ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => setState(() => _selectedIndex = index),
                          selected: isSelected,
                          selectedTileColor: colorScheme.primaryContainer.withOpacity(0.2),
                          leading: Radio<int>(
                            value: index,
                            groupValue: _selectedIndex,
                            onChanged: (value) =>
                                setState(() => _selectedIndex = value),
                          ),
                          title: Text(widget.options[index]),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: _submit,
          child: Text(widget.submitLabel),
        ),
      ),
    );
  }
}
