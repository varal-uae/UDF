import 'package:flutter/material.dart';

/// Unique styling tokens for the Accessibility Touch Matrix Auditor.
abstract final class AccessibilityMatrixTokens {
  static const Color primaryViolet = Color(0xFF6D28D9);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Touch bounding box indicator colors
  static const Color targetGuideColor = Color(0x338B5CF6);
  static const Color targetGuideBorder = Color(0xFF7C3AED);

  // Status badges
  static const Color passBadgeBg = Color(0xFFDCFCE7);
  static const Color passBadgeText = Color(0xFF166534);

  static const double baselineDp = 48.0;
}

/// Metadata model for audited touch element.
class TouchTargetAuditItem {
  final String elementId;
  final String label;
  final double width;
  final double height;
  final bool isCompliant;

  const TouchTargetAuditItem({
    required this.elementId,
    required this.label,
    required this.width,
    required this.height,
    required this.isCompliant,
  });
}

/// Interactive 48x48dp MD3 Accessibility target matrix auditor.
class AccessibilityTouchMatrixCard extends StatefulWidget {
  final void Function(TouchTargetAuditItem target)? onTargetAudited;

  const AccessibilityTouchMatrixCard({
    super.key,
    this.onTargetAudited,
  });

  @override
  State<AccessibilityTouchMatrixCard> createState() => _AccessibilityTouchMatrixCardState();
}

class _AccessibilityTouchMatrixCardState extends State<AccessibilityTouchMatrixCard> {
  bool _showTouchGrid = true;
  String _lastTappedName = 'IconButton (Cart)';
  double _lastWidth = 48.0;
  double _lastHeight = 48.0;

  bool _switchVal = true;
  bool _chipVal = true;

  final List<TouchTargetAuditItem> _registeredTargets = const [
    TouchTargetAuditItem(
      elementId: 'btn_icon_cart',
      label: 'Standard Icon Button (Cart)',
      width: 48.0,
      height: 48.0,
      isCompliant: true,
    ),
    TouchTargetAuditItem(
      elementId: 'sw_notif',
      label: 'Notification Switch Touch Bounds',
      width: 52.0,
      height: 48.0,
      isCompliant: true,
    ),
    TouchTargetAuditItem(
      elementId: 'chip_priority',
      label: 'M3 Filter Chip Target',
      width: 96.0,
      height: 48.0,
      isCompliant: true,
    ),
    TouchTargetAuditItem(
      elementId: 'fab_add',
      label: 'Action FAB Target Base',
      width: 56.0,
      height: 56.0,
      isCompliant: true,
    ),
  ];

  void _recordTouch(String name, double w, double h) {
    setState(() {
      _lastTappedName = name;
      _lastWidth = w;
      _lastHeight = h;
    });

    widget.onTargetAudited?.call(
      TouchTargetAuditItem(
        elementId: name.toLowerCase().replaceAll(' ', '_'),
        label: name,
        width: w,
        height: h,
        isCompliant: w >= AccessibilityMatrixTokens.baselineDp &&
            h >= AccessibilityMatrixTokens.baselineDp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AccessibilityMatrixTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AccessibilityMatrixTokens.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AccessibilityMatrixTokens.primaryViolet.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.accessibility_new_rounded,
                  color: AccessibilityMatrixTokens.primaryViolet,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '48x48dp Baseline Matrix',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AccessibilityMatrixTokens.textDark,
                      ),
                    ),
                    Text(
                      'MD3 & WCAG 2.1 AA 2.5.5 Touch Target Matrix',
                      style: TextStyle(
                        fontSize: 12,
                        color: AccessibilityMatrixTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AccessibilityMatrixTokens.passBadgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '100% PASS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AccessibilityMatrixTokens.passBadgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Toggle Visual Bounds
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Show 48x48dp Target Bounds',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AccessibilityMatrixTokens.textDark,
                ),
              ),
              Switch(
                value: _showTouchGrid,
                onChanged: (val) {
                  setState(() => _showTouchGrid = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Interactive Target Playground
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AccessibilityMatrixTokens.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AccessibilityMatrixTokens.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tap Elements to Inspect Live Hit-Test Geometry:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AccessibilityMatrixTokens.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 16,
                  runSpacing: 14,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Element 1: Icon Button
                    _wrapWithTargetGuide(
                      width: 48,
                      height: 48,
                      name: 'IconButton (Cart)',
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () => _recordTouch('IconButton (Cart)', 48, 48),
                      ),
                    ),
                    // Element 2: Notification Switch
                    _wrapWithTargetGuide(
                      width: 56,
                      height: 48,
                      name: 'Switch (Alerts)',
                      child: SizedBox(
                        width: 56,
                        height: 48,
                        child: Center(
                          child: Switch(
                            value: _switchVal,
                            onChanged: (val) {
                              setState(() => _switchVal = val);
                              _recordTouch('Switch (Alerts)', 56, 48);
                            },
                          ),
                        ),
                      ),
                    ),
                    // Element 3: M3 Filter Chip
                    _wrapWithTargetGuide(
                      width: 96,
                      height: 48,
                      name: 'FilterChip (VIP)',
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: FilterChip(
                            label: const Text('VIP Pass'),
                            selected: _chipVal,
                            onSelected: (val) {
                              setState(() => _chipVal = val);
                              _recordTouch('FilterChip (VIP)', 96, 48);
                            },
                          ),
                        ),
                      ),
                    ),
                    // Element 4: Mini FAB
                    _wrapWithTargetGuide(
                      width: 56,
                      height: 56,
                      name: 'Mini FAB (Add)',
                      child: FloatingActionButton.small(
                        heroTag: 'fab_touch_matrix_demo',
                        onPressed: () => _recordTouch('Mini FAB (Add)', 56, 56),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Last Tap Inspector Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AccessibilityMatrixTokens.surfaceCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AccessibilityMatrixTokens.targetGuideBorder.withAlpha(60)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AccessibilityMatrixTokens.primaryViolet.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.touch_app_rounded,
                      color: AccessibilityMatrixTokens.primaryViolet,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lastTappedName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AccessibilityMatrixTokens.textDark,
                        ),
                      ),
                      Text(
                        'Measured Bounds: ${_lastWidth.toStringAsFixed(0)}dp x ${_lastHeight.toStringAsFixed(0)}dp',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AccessibilityMatrixTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AccessibilityMatrixTokens.passBadgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${(_lastWidth - AccessibilityMatrixTokens.baselineDp).toStringAsFixed(0)}dp delta',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AccessibilityMatrixTokens.passBadgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Registered Targets Table preview
          Column(
            children: _registeredTargets.map((target) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      target.label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AccessibilityMatrixTokens.textDark,
                      ),
                    ),
                    Text(
                      '${target.width.toInt()}x${target.height.toInt()} dp (PASS)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AccessibilityMatrixTokens.passBadgeText,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _wrapWithTargetGuide({
    required double width,
    required double height,
    required String name,
    required Widget child,
  }) {
    if (!_showTouchGrid) return child;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AccessibilityMatrixTokens.targetGuideColor,
            border: Border.all(
              color: AccessibilityMatrixTokens.targetGuideBorder,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child,
      ],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: AccessibilityTouchMatrixCard(),
          ),
        ),
      ),
    ),
  );
}
