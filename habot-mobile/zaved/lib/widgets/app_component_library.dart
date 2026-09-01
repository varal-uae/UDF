import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_design_tokens.dart';
export 'dynamic_typography_wrapper.dart';
export 'responsive_grid_wrapper.dart';
export 'universal_widgets.dart';

/// Phase 3: Core Component Library

// ============================================================================
// 3.1 Button Component (AppButton)
// ============================================================================
enum AppButtonVariant { filled, outlined, tonal, elevated, text }

class AppButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null || widget.isLoading;

    // Scale animation on press (scale 0.98)
    final double scale = _isPressed && !isDisabled ? 0.98 : 1.0;

    // Touch targets: Minimum 44px height x 48px width (padded 12px top/bottom, 24px left/right)
    final EdgeInsets padding = const EdgeInsets.symmetric(
      vertical: 12.0,
      horizontal: 24.0,
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
          const SizedBox(width: AppDesignTokens.spaceS),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18),
          const SizedBox(width: AppDesignTokens.spaceS),
        ],
        Text(
          widget.label,
          style: AppDesignTokens.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );

    // Disabled state opacity 0.38
    Widget buttonChild = AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 100),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44.0, minWidth: 48.0),
        child: Opacity(
          opacity: isDisabled ? 0.38 : 1.0,
          child: _buildVariantButton(theme, padding, content),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: IgnorePointer(
        ignoring: isDisabled,
        child: buttonChild,
      ),
    );
  }

  Widget _buildVariantButton(ThemeData theme, EdgeInsets padding, Widget content) {
    switch (widget.variant) {
      case AppButtonVariant.filled:
        return FilledButton(
          style: FilledButton.styleFrom(
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
            ),
          ),
          onPressed: widget.onPressed,
          child: content,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
            ),
          ),
          onPressed: widget.onPressed,
          child: content,
        );
      case AppButtonVariant.tonal:
        return FilledButton.tonal(
          style: FilledButton.styleFrom(
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
            ),
          ),
          onPressed: widget.onPressed,
          child: content,
        );
      case AppButtonVariant.elevated:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: padding,
            elevation: AppDesignTokens.elevation1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
            ),
          ),
          onPressed: widget.onPressed,
          child: content,
        );
      case AppButtonVariant.text:
        return TextButton(
          style: TextButton.styleFrom(
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
            ),
          ),
          onPressed: widget.onPressed,
          child: content,
        );
    }
  }
}

// ============================================================================
// 3.2 Form Input Fields & Real-Time Masking Formatters
// ============================================================================

/// Mask Formatter for Entity ID: AAA-000
class AppEntityIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toUpperCase();
    final buffer = StringBuffer();
    int letters = 0;
    int digits = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (letters < 3 && RegExp(r'[A-Z]').hasMatch(char)) {
        buffer.write(char);
        letters++;
        if (letters == 3 && i < text.length - 1) {
          buffer.write('-');
        }
      } else if (letters == 3 && digits < 3 && RegExp(r'[0-9]').hasMatch(char)) {
        if (!buffer.toString().endsWith('-')) {
          buffer.write('-');
        }
        buffer.write(char);
        digits++;
      }
    }

    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

/// Mask Formatter for USD Currency: $0,000.00
class AppCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleanDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanDigits.isEmpty) return const TextEditingValue(text: '');

    final double value = double.parse(cleanDigits) / 100.0;
    final String formatted = '\$${value.toStringAsFixed(2)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// AppFormField with Native Save-Lock Interceptor (RIMV-007)
/// Height 56px, side padding 16px, 8px rounded corners, 1px border (2px focus)
class AppFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool isMonospace;
  final TextInputType? keyboardType;

  const AppFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.inputFormatters,
    this.validator,
    this.prefixIcon,
    this.isMonospace = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppDesignTokens.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDesignTokens.spaceXs),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56.0),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: isMonospace
                ? AppDesignTokens.monospaceToken
                : AppDesignTokens.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spaceM, // 16px side padding
                vertical: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall), // 8px corners
                borderSide: const BorderSide(color: AppDesignTokens.outline, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
                borderSide: const BorderSide(color: AppDesignTokens.errorMain, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSmall),
                borderSide: const BorderSide(color: AppDesignTokens.errorMain, width: 2.0),
              ),
              errorStyle: const TextStyle(
                color: AppDesignTokens.errorMain,
                fontWeight: FontWeight.bold,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 3.3 Toggles, Checkboxes & Steppers
// ============================================================================

/// AppToggleSwitch: Track 52dp x 32dp
class AppToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52.0,
      height: 32.0,
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// Blocked Step Indicator (Padlock icon + 40% opacity)
class AppBlockedStepIndicator extends StatelessWidget {
  final String title;

  const AppBlockedStepIndicator({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.40, // 40% opacity requirement
        child: Container(
          padding: const EdgeInsets.all(AppDesignTokens.spaceM),
          decoration: BoxDecoration(
            color: AppDesignTokens.outline.withAlpha(30),
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
            border: Border.all(color: AppDesignTokens.outline),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock, color: AppDesignTokens.outline),
              const SizedBox(width: AppDesignTokens.spaceM),
              Expanded(
                child: Text(
                  '$title (Blocked)',
                  style: AppDesignTokens.titleMedium.copyWith(
                    color: AppDesignTokens.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vertical Stepper Item Model
class AppStepItem {
  final String title;
  final String subtitle;
  final String auditId; // Monospace format
  final bool isCompleted;
  final bool isCurrent;

  AppStepItem({
    required this.title,
    required this.subtitle,
    required this.auditId,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

/// AppVerticalStepper Widget
class AppVerticalStepper extends StatelessWidget {
  final List<AppStepItem> steps;

  const AppVerticalStepper({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: step.isCompleted
                      ? AppDesignTokens.successMain
                      : (step.isCurrent ? theme.colorScheme.primary : AppDesignTokens.outline),
                  foregroundColor: Colors.white,
                  child: step.isCompleted
                      ? const Icon(Icons.check, size: 16)
                      : Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 48,
                    color: step.isCompleted ? AppDesignTokens.successMain : AppDesignTokens.outline,
                  ),
              ],
            ),
            const SizedBox(width: AppDesignTokens.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppDesignTokens.titleMedium.copyWith(
                      fontWeight: step.isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  Text(step.subtitle, style: AppDesignTokens.bodySmall),
                  const SizedBox(height: 4),
                  // Read-only audit ID in Monospace font
                  Text(
                    'AUDIT_HASH: ${step.auditId}',
                    style: AppDesignTokens.monospaceToken.copyWith(
                      fontSize: 11.0,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppDesignTokens.spaceL),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ============================================================================
// 3.4 Navigation Components
// ============================================================================

/// AppBottomNavigationBar: Height 80dp, 3-5 items max, fixed with 1px top border
class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0, // Height 80dp requirement
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppDesignTokens.outline, width: 1.0),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}
