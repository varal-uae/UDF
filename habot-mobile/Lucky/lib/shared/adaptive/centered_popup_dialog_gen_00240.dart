// GEN-00240 — Centered Popup Dialog with Header Slot.
// Ensures zero-offset centered dialogs stay fully inside 360/390/412px mobile viewports; M3 single-column layout with header-slot composition.
import 'package:flutter/material.dart';

/// EC Blueprint — Validate viewport against primary breakpoints.
class ViewportGuardGen00240 {
  static const List<double> primaryBreakpoints = <double>[360, 390, 412];
  static const double mobileMax = 600;
  static const double desktopMin = 840;

  // Verify: return true if width is within supported mobile matrix.
  static bool isPrimaryBreakpoint(double width) {
    for (final bp in primaryBreakpoints) {
      if ((width - bp).abs() < 1.0) return true;
    }
    return width >= 320 && width < mobileMax;
  }

  // Clamp: compute safe dialog width that never overflows viewport.
  static double dialogWidth(double viewportWidth) {
    if (viewportWidth < mobileMax) {
      return (viewportWidth * 0.92).clamp(288.0, 400.0);
    }
    if (viewportWidth < desktopMin) {
      return 480.0;
    }
    return 560.0;
  }

  // Clamp: compute safe dialog max height (leaves status-bar + nav + keyboard room).
  static double dialogMaxHeight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final insets = MediaQuery.viewInsetsOf(context);
    return (size.height - insets.bottom - 48.0).clamp(200.0, 720.0);
  }
}

/// Reusable zero-centered M3 popup dialog.
///
/// Header slot accepts any header content as a child prop (`header`).
/// Body stays single-column on mobile (<600dp), multi-column capable on desktop.
class CenteredPopupDialogGen00240 extends StatelessWidget {
  final Widget? header;
  final Widget? body;
  final List<Widget>? actions;
  final String? statusLabel;
  final bool? isPass;
  final VoidCallback? onClose;
  final bool showClose;

  const CenteredPopupDialogGen00240({
    super.key,
    this.header,
    this.body,
    this.actions,
    this.statusLabel,
    this.isPass,
    this.onClose,
    this.showClose = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final width = ViewportGuardGen00240.dialogWidth(viewportWidth);
    final maxHeight = ViewportGuardGen00240.dialogMaxHeight(context);

    return Dialog(
      alignment: Alignment.center,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
            child: Material(
              type: MaterialType.card,
              color: colorScheme.surfaceContainerHigh,
              elevation: 3.0,
              shadowColor: colorScheme.shadow,
              surfaceTintColor: colorScheme.surfaceTint,
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: header ?? const SizedBox.shrink()),
                        if (showClose)
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: IconButton(
                              tooltip: 'Close dialog',
                              onPressed: onClose ?? () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                            ),
                          ),
                      ],
                    ),
                    if (statusLabel != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(statusLabel!),
                          avatar: Icon(
                            (isPass ?? true) ? Icons.check_circle : Icons.error,
                            size: 18,
                          ),
                          side: BorderSide.none,
                          backgroundColor: (isPass ?? true)
                              ? colorScheme.secondaryContainer
                              : colorScheme.errorContainer,
                          labelStyle: theme.textTheme.labelLarge,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ),
                    ],
                    if (body != null) ...[
                      const SizedBox(height: 12),
                      Flexible(child: body!),
                    ],
                    if (actions != null && actions!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _ActionsBlock(actions: actions!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsBlock extends StatelessWidget {
  final List<Widget> actions;
  const _ActionsBlock({required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                SizedBox(minHeight: 48, child: actions[i]),
              ],
            ],
          );
        }
        return Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: actions,
        );
      },
    );
  }
}

// Display: show zero-centered dialog that never overflows mobile viewport.
Future<void> showCenteredPopupGen00240({
  required BuildContext context,
  Widget? header,
  Widget? body,
  List<Widget>? actions,
  String? statusLabel,
  bool? isPass,
  bool barrierDismissible = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black54,
    useSafeArea: true,
    builder: (dialogContext) => CenteredPopupDialogGen00240(
      header: header,
      body: body,
      actions: actions,
      statusLabel: statusLabel,
      isPass: isPass,
      onClose: () => Navigator.of(dialogContext).pop(),
    ),
  );
}
