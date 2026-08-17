import 'package:flutter/material.dart';
import '../utils/validated_form.dart';

// BCDLD-007-A01 — Binary Yes/No Input Masks.
// Spec: "Restrict worker selections to absolute binary choices."
//       Single-column layout · Token-driven styling · 48dp touch targets
//
// Poka-Yoke: field physically prevents any value other than the two
// configured options. No free text. No null submission allowed.
//
// Integrates with ValidatedFieldRegistry:
//   - Starts invalid (no selection)
//   - Reports isValid=true the moment either option is tapped
//   - Submit stays locked until a choice is made
//
// 3 presentation modes:
//   BinaryStyle.segmented  — MD3 SegmentedButton (default)
//   BinaryStyle.chips      — two FilterChip buttons side by side
//   BinaryStyle.radioTiles — two RadioListTile rows (compact/wide friendly)

// ── Binary choice model ───────────────────────────────────────────────────────

class BinaryOption {
  const BinaryOption({
    required this.value,
    required this.label,
    this.icon,
    this.semanticsLabel,
  });

  final bool value;
  final String label;
  final IconData? icon;
  final String? semanticsLabel;

  /// Standard Yes/No pair
  static const yes = BinaryOption(
    value: true,
    label: 'Yes',
    icon:  Icons.check_rounded,
    semanticsLabel: 'Yes',
  );

  static const no = BinaryOption(
    value: false,
    label: 'No',
    icon:  Icons.close_rounded,
    semanticsLabel: 'No',
  );

  /// Standard Accept/Reject pair
  static const accept = BinaryOption(
    value: true,
    label: 'Accept',
    icon:  Icons.thumb_up_rounded,
  );

  static const reject = BinaryOption(
    value: false,
    label: 'Reject',
    icon:  Icons.thumb_down_rounded,
  );

  /// Standard True/False pair
  static const trueOption = BinaryOption(value: true,  label: 'True');
  static const falseOption = BinaryOption(value: false, label: 'False');

  /// Standard Approve/Decline pair
  static const approve = BinaryOption(value: true,  label: 'Approve', icon: Icons.verified_rounded);
  static const decline = BinaryOption(value: false, label: 'Decline', icon: Icons.block_rounded);
}

enum BinaryStyle { segmented, chips, radioTiles }

// ── BinaryChoiceField ─────────────────────────────────────────────────────────

class BinaryChoiceField extends StatefulWidget {
  const BinaryChoiceField({
    super.key,
    required this.fieldKey,
    this.registry,
    this.label,
    this.positiveOption = BinaryOption.yes,
    this.negativeOption = BinaryOption.no,
    this.style = BinaryStyle.segmented,
    this.initialValue,
    this.onChanged,
    this.required = true,
    this.errorText,
  });

  /// Key in ValidatedFieldRegistry
  final String fieldKey;
  final ValidatedFieldRegistry? registry;

  final String? label;
  final BinaryOption positiveOption;
  final BinaryOption negativeOption;
  final BinaryStyle style;
  final bool? initialValue;
  final ValueChanged<bool>? onChanged;
  final bool required;
  final String? errorText;

  @override
  State<BinaryChoiceField> createState() => _BinaryChoiceFieldState();
}

class _BinaryChoiceFieldState extends State<BinaryChoiceField> {
  bool? _selected;

  ValidatedFieldRegistry? get _registry =>
      widget.registry ?? ValidatedForm.registryOf(context);

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registry?.register(widget.fieldKey, required: widget.required);
      // If no initial value — starts invalid, submit locked
      _registry?.setValidity(
        widget.fieldKey,
        isValid: _selected != null,
      );
    });
  }

  @override
  void dispose() {
    _registry?.unregister(widget.fieldKey);
    super.dispose();
  }

  void _onSelect(bool value) {
    setState(() => _selected = value);
    _registry?.setValidity(widget.fieldKey, isValid: true);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.required
                  ? '${widget.label} *'
                  : widget.label!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

        // Choice control
        switch (widget.style) {
          BinaryStyle.segmented   => _SegmentedChoice(
              selected:        _selected,
              positiveOption:  widget.positiveOption,
              negativeOption:  widget.negativeOption,
              onSelect:        _onSelect,
            ),
          BinaryStyle.chips       => _ChipChoice(
              selected:        _selected,
              positiveOption:  widget.positiveOption,
              negativeOption:  widget.negativeOption,
              onSelect:        _onSelect,
            ),
          BinaryStyle.radioTiles  => _RadioTileChoice(
              selected:        _selected,
              positiveOption:  widget.positiveOption,
              negativeOption:  widget.negativeOption,
              onSelect:        _onSelect,
            ),
        },

        // Error
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.error_outline_rounded, size: 14,
                  color: theme.colorScheme.error),
              const SizedBox(width: 4),
              Text(
                widget.errorText!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── MD3 Segmented button ──────────────────────────────────────────────────────

class _SegmentedChoice extends StatelessWidget {
  const _SegmentedChoice({
    required this.selected,
    required this.positiveOption,
    required this.negativeOption,
    required this.onSelect,
  });

  final bool? selected;
  final BinaryOption positiveOption;
  final BinaryOption negativeOption;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment<bool>(
          value: negativeOption.value,
          label: Text(negativeOption.label),
          icon:  negativeOption.icon != null
              ? Icon(negativeOption.icon, size: 18)
              : null,
        ),
        ButtonSegment<bool>(
          value: positiveOption.value,
          label: Text(positiveOption.label),
          icon:  positiveOption.icon != null
              ? Icon(positiveOption.icon, size: 18)
              : null,
        ),
      ],
      selected:       selected != null ? {selected!} : {},
      onSelectionChanged: (s) => onSelect(s.first),
      emptySelectionAllowed: true,
      style: ButtonStyle(
        // 48dp minimum tap target
        minimumSize: WidgetStateProperty.all(
          const Size(0, 48),
        ),
      ),
    );
  }
}

// ── Chip pair ─────────────────────────────────────────────────────────────────

class _ChipChoice extends StatelessWidget {
  const _ChipChoice({
    required this.selected,
    required this.positiveOption,
    required this.negativeOption,
    required this.onSelect,
  });

  final bool? selected;
  final BinaryOption positiveOption;
  final BinaryOption negativeOption;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BinaryChip(
            option:     negativeOption,
            isSelected: selected == negativeOption.value,
            onTap:      () => onSelect(negativeOption.value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BinaryChip(
            option:     positiveOption,
            isSelected: selected == positiveOption.value,
            onTap:      () => onSelect(positiveOption.value),
          ),
        ),
      ],
    );
  }
}

class _BinaryChip extends StatelessWidget {
  const _BinaryChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final BinaryOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration:    const Duration(milliseconds: 150),
        curve:       Curves.easeOut,
        // 48dp minimum height
        constraints: const BoxConstraints(minHeight: 48),
        padding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 18,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              option.label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Radio tile pair ───────────────────────────────────────────────────────────

class _RadioTileChoice extends StatelessWidget {
  const _RadioTileChoice({
    required this.selected,
    required this.positiveOption,
    required this.negativeOption,
    required this.onSelect,
  });

  final bool? selected;
  final BinaryOption positiveOption;
  final BinaryOption negativeOption;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RadioTile(
          option:     negativeOption,
          groupValue: selected,
          onSelect:   onSelect,
        ),
        _RadioTile(
          option:     positiveOption,
          groupValue: selected,
          onSelect:   onSelect,
        ),
      ],
    );
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.option,
    required this.groupValue,
    required this.onSelect,
  });

  final BinaryOption option;
  final bool? groupValue;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    // RadioListTile is natively 48dp height
    return RadioListTile<bool>(
      title: Row(
        children: [
          if (option.icon != null) ...[
            Icon(option.icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(option.label),
        ],
      ),
      value:     option.value,
      groupValue: groupValue,
      onChanged: (v) { if (v != null) onSelect(v); },
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
