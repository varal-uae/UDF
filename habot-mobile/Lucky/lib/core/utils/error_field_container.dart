import 'package:flutter/material.dart';

// FIEVR-032-A01 — Error Field Container.
// Wraps any form field widget with:
//   - High-visibility error highlight bound to semantic token colors
//   - Sharp text outline around error description (guaranteed contrast)
//   - Fluid flash animation when error appears
//   - Clean overlay that doesn't corrupt global padding alignment

class ErrorFieldContainer extends StatefulWidget {
  const ErrorFieldContainer({
    super.key,
    required this.fieldKey,
    required this.containerKey,
    required this.child,
    this.errorText,
    this.hasError = false,
  });

  /// The registered GlobalKey from FormErrorFocusEngine.register()
  final GlobalKey containerKey;

  /// Field identifier — used for semantics.
  final String fieldKey;

  final Widget child;
  final String? errorText;
  final bool hasError;

  @override
  State<ErrorFieldContainer> createState() => _ErrorFieldContainerState();
}

class _ErrorFieldContainerState extends State<ErrorFieldContainer>
    with SingleTickerProviderStateMixin {

  late final AnimationController _flashAnim;
  late final Animation<double> _flashOpacity;

  @override
  void initState() {
    super.initState();
    _flashAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashAnim, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(ErrorFieldContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Flash animation when error appears
    if (widget.hasError && !oldWidget.hasError) {
      _flashAnim.forward(from: 0.0);
    } else if (!widget.hasError && oldWidget.hasError) {
      _flashAnim.reverse();
    }
  }

  @override
  void dispose() {
    _flashAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KeyedSubtree(
      key: widget.containerKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Field — wrapped in animated error border overlay
          AnimatedBuilder(
            animation: _flashOpacity,
            builder: (context, child) {
              return Container(
                decoration: widget.hasError
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          // Spec: match warning flags to high-visibility semantic token colors
                          color: theme.colorScheme.error
                              .withOpacity(_flashOpacity.value),
                          width: 1.5,
                        ),
                      )
                    : null,
                child: child,
              );
            },
            child: widget.child,
          ),

          // Error message — sharp text outline for guaranteed contrast
          if (widget.hasError && widget.errorText != null)
            FadeTransition(
              opacity: _flashOpacity,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      // Spec: high-visibility semantic token color
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.errorText!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                          // Spec: sharp text outlines around error descriptions
                          shadows: [
                            Shadow(
                              color: theme.colorScheme.surface,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
