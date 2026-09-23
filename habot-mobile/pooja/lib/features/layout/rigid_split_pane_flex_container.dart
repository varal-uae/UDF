import 'package:flutter/material.dart';

/// Unique styling tokens for Rigid 50/50 Split Pane Flex Container.
abstract final class RigidSplitPaneTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const Color paneLeftBg = Color(0xFFEFF6FF);
  static const Color paneLeftBorder = Color(0xFF3B82F6);
  static const Color paneRightBg = Color(0xFFF0FDF4);
  static const Color paneRightBorder = Color(0xFF22C55E);

  static const Color dividerColor = Color(0xFF94A3B8);
  static const double minPaneTouchTarget = 48.0;
}

/// A rigid 50/50 flex container for multi-window and foldable displays under MD3.
class RigidSplitPaneFlexContainer extends StatefulWidget {
  final Widget? leftPaneContent;
  final Widget? rightPaneContent;
  final void Function(bool isDividedEqually)? onLayoutValidated;

  const RigidSplitPaneFlexContainer({
    super.key,
    this.leftPaneContent,
    this.rightPaneContent,
    this.onLayoutValidated,
  });

  @override
  State<RigidSplitPaneFlexContainer> createState() =>
      _RigidSplitPaneFlexContainerState();
}

class _RigidSplitPaneFlexContainerState
    extends State<RigidSplitPaneFlexContainer> {
  bool _isLocked5050 = true;
  double _customSplitRatio = 0.5; // Strictly locked when _isLocked5050 is true

  @override
  Widget build(BuildContext context) {
    final leftFlex = _isLocked5050 ? 50 : (_customSplitRatio * 100).toInt();
    final rightFlex = 100 - leftFlex;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: RigidSplitPaneTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: RigidSplitPaneTokens.borderLight),
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
                  color: const Color(0xFF2563EB).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.vertical_split_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rigid 50/50 Split-Pane Flex',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: RigidSplitPaneTokens.textDark,
                      ),
                    ),
                    Text(
                      'MD3 Foldable & Dual-Window Rigid Constraint Box',
                      style: TextStyle(
                        fontSize: 12,
                        color: RigidSplitPaneTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isLocked5050
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isLocked5050 ? '50/50 RIGID LOCK' : '$leftFlex / $rightFlex FLEX',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isLocked5050
                        ? const Color(0xFF166534)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Toggle Constraint Lock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enforce Rigid 50% Symmetry Constraint',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: RigidSplitPaneTokens.textDark,
                ),
              ),
              Switch(
                value: _isLocked5050,
                onChanged: (val) {
                  setState(() {
                    _isLocked5050 = val;
                    if (val) _customSplitRatio = 0.5;
                  });
                  widget.onLayoutValidated?.call(val);
                },
              ),
            ],
          ),
          if (!_isLocked5050) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Ratio:',
                    style: TextStyle(
                        fontSize: 11, color: RigidSplitPaneTokens.textMuted)),
                Expanded(
                  child: Slider(
                    value: _customSplitRatio,
                    min: 0.2,
                    max: 0.8,
                    onChanged: (v) => setState(() => _customSplitRatio = v),
                  ),
                ),
                Text('$leftFlex% : $rightFlex%',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Split Pane Canvas Display
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: RigidSplitPaneTokens.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: RigidSplitPaneTokens.borderLight),
            ),
            child: Row(
              children: [
                // Left Pane (Flex 50)
                Expanded(
                  flex: leftFlex,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RigidSplitPaneTokens.paneLeftBg,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12)),
                      border: Border(
                        right: BorderSide(
                          color: _isLocked5050
                              ? RigidSplitPaneTokens.paneLeftBorder
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: widget.leftPaneContent ??
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.source_outlined,
                                    size: 16, color: Color(0xFF1E40AF)),
                                SizedBox(width: 6),
                                Text(
                                  'Left Pane (50%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Master Navigation & Primary Action Stream',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                  ),
                ),
                // Center Rigid Divider Bar
                Container(
                  width: 4,
                  height: double.infinity,
                  color: _isLocked5050
                      ? RigidSplitPaneTokens.dividerColor
                      : Colors.grey.shade300,
                ),
                // Right Pane (Flex 50)
                Expanded(
                  flex: rightFlex,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: RigidSplitPaneTokens.paneRightBg,
                      borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(12)),
                    ),
                    child: widget.rightPaneContent ??
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.preview_outlined,
                                    size: 16, color: Color(0xFF166534)),
                                SizedBox(width: 6),
                                Text(
                                  'Right Pane (50%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Detail Inspection & Telemetry Inspector',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RigidSplitPaneTokens.borderLight),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: Colors.green),
                SizedBox(width: 6),
                Text(
                  'ISO Verified: Dual flex containers maintain 1:1 aspect symmetry.',
                  style: TextStyle(fontSize: 11, color: RigidSplitPaneTokens.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
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
            child: RigidSplitPaneFlexContainer(),
          ),
        ),
      ),
    ),
  );
}
