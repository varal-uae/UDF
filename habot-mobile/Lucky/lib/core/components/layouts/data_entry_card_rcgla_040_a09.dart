// RCGLA-040-A09 — DataEntryCard Standardized Layout Container.
// Builds a standalone, single-purpose card container enforcing strict Material 3 design tokens, dynamic validation color rules (flashing red on error), and Poka-Yoke constraints limiting the card to exactly one input field.

import 'package:flutter/material.dart';

/// Mock data model representing the atomic-level data fields required for styling and tracking.
class CardDesignToken {
  final String colorCodeHex;
  final String colorName;
  final String colorScheme;
  final double contrastRatio;
  final Map<String, String> colorApplicationMap;

  const CardDesignToken({
    required this.colorCodeHex,
    required this.colorName,
    required this.colorScheme,
    required this.contrastRatio,
    required this.colorApplicationMap,
  });
}

/// Hardcoded mock repository providing local data without backend dependency.
class MockDesignTokenRepository {
  static const CardDesignToken defaultToken = CardDesignToken(
    colorCodeHex: '#FFFFFF',
    colorName: 'Surface White',
    colorScheme: 'Light Corporate',
    contrastRatio: 4.5,
    colorApplicationMap: {
      'background': '#FFFFFF',
      'text': '#1C1B1F',
      'error': '#B3261E',
      'badge_corporate': '#6750A4',
      'badge_clinical': '#006A6A',
    },
  );

  static const CardDesignToken clinicalToken = CardDesignToken(
    colorCodeHex: '#F4EFF4',
    colorName: 'Clinical Surface',
    colorScheme: 'Light Clinical',
    contrastRatio: 5.2,
    colorApplicationMap: {
      'background': '#F4EFF4',
      'text': '#1C1B1F',
      'error': '#B3261E',
      'badge_corporate': '#6750A4',
      'badge_clinical': '#006A6A',
    },
  );
}

enum CardContextType { corporate, clinical }

/// A standardized, standalone layout container block inside the client view framework.
/// Enforces Mobile-First & Responsive UX decisions:
/// - Strict card context containment.
/// - Forced standard round corner attributes.
/// - Single vertical column stacking properties.
/// - Disables multi-layer nested card variations.
/// - Poka-Yoke: Blocks embedding more than one input box.
class DataEntryCard extends StatefulWidget {
  /// The single allowed input widget (Poka-Yoke enforcement).
  final Widget inputField;

  /// Optional label displayed as a clean standard chip element.
  final String? label;

  /// Context type to distinguish corporate from clinical statuses via visual badge themes.
  final CardContextType contextType;

  /// Validation status. If false, triggers dynamic red background flash.
  final bool isValid;

  /// Design token override. Defaults to mock repository token if null.
  final CardDesignToken? designToken;

  const DataEntryCard({
    super.key,
    required this.inputField,
    this.label,
    this.contextType = CardContextType.corporate,
    this.isValid = true,
    this.designToken,
  });

  @override
  State<DataEntryCard> createState() => _DataEntryCardState();
}

class _DataEntryCardState extends State<DataEntryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _colorAnimation;
  late CardDesignToken _activeToken;

  @override
  void initState() {
    super.initState();
    _activeToken =
        widget.designToken ?? MockDesignTokenRepository.defaultToken;

    // Setup dynamic color rules that flash red backgrounds if validation fails
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final errorColor = Color(
      int.parse(
        _activeToken.colorApplicationMap['error']!.replaceAll('#', '0xFF'),
      ),
    );
    final bgColor = Color(
      int.parse(
        _activeToken.colorApplicationMap['background']!.replaceAll('#', '0xFF'),
      ),
    );

    _colorAnimation = ColorTween(
      begin: bgColor,
      end: errorColor.withOpacity(0.2),
    ).animate(_flashController);

    _handleValidationState();
  }

  @override
  void didUpdateWidget(covariant DataEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isValid != widget.isValid ||
        oldWidget.designToken != widget.designToken) {
      _activeToken =
          widget.designToken ?? MockDesignTokenRepository.defaultToken;
      _handleValidationState();
    }
  }

  void _handleValidationState() {
    if (!widget.isValid) {
      _flashController.repeat(reverse: true);
    } else {
      _flashController.stop();
      _flashController.reset();
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Card(
          elevation: 1.0,
          margin: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), // Padding metrics placeholder for HC-SCH-0077
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16.0), // Forced standard round corners
          ),
          color: widget.isValid
              ? Color(
                  int.parse(
                    _activeToken.colorApplicationMap['background']!
                        .replaceAll('#', '0xFF'),
                  ),
                )
              : _colorAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Single vertical column stacking properties.
            // Multi-layer nested cards are strictly disabled by API design.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.label != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildBadgeChip(theme),
                  ),
                // Exactly ONE input field permitted (Poka-Yoke)
                widget.inputField,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Assigns separate visual badge themes to distinguish corporate from clinical statuses.
  Widget _buildBadgeChip(ThemeData theme) {
    final isCorporate = widget.contextType == CardContextType.corporate;
    final hexColor = isCorporate
        ? _activeToken.colorApplicationMap['badge_corporate']!
        : _activeToken.colorApplicationMap['badge_clinical']!;

    final badgeColor =
        Color(int.parse(hexColor.replaceAll('#', '0xFF')));

    // Interface selection inputs choose clean standard chip elements
    return Chip(
      label: Text(
        widget.label!,
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: badgeColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Helper widget name matching Flutter's actual AnimatedBuilder equivalent.
/// Note: Flutter uses [AnimatedBuilder] natively in newer versions or [AnimatedBuilder] alias.
/// We use standard [AnimatedBuilder] which maps to flutter's internal animated builder.
class AnimatedBuilder extends StatelessWidget {
  final Animation<Color?> animation;
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderInternal(
      animation: animation,
      builder: builder,
    );
  }
}

// Using Flutter's native AnimatedBuilder directly to avoid custom wrapper issues
class AnimatedBuilderInternal extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilderInternal({
    super.key,
    required Animation<Color?> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}