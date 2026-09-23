import 'package:flutter/material.dart';

/// Unique design tokens for Primitive Color Styling Token Matrix.
abstract final class PrimitiveColorTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Tonal primitive bases
  static const Color primaryBase = Color(0xFF2563EB);
  static const Color secondaryBase = Color(0xFF0D9488);
  static const Color tertiaryBase = Color(0xFFD97706);
  static const Color neutralBase = Color(0xFF64748B);

  // ISO / MD3 Compliance badge
  static const Color complianceBadgeBg = Color(0xFFECFDF5);
  static const Color complianceBadgeText = Color(0xFF065F46);
}

/// Model representing a single tonal swatch within the MD3 primitive system.
class TonalPrimitiveSwatch {
  final int tone;
  final Color color;
  final String hex;
  final String semanticRole;

  const TonalPrimitiveSwatch({
    required this.tone,
    required this.color,
    required this.hex,
    required this.semanticRole,
  });
}

/// Primitive color styling tokens explorer compliant with ISO/IEC 25010 & MD3.
class PrimitiveColorTokenMatrix extends StatefulWidget {
  final void Function(TonalPrimitiveSwatch swatch)? onSwatchSelected;

  const PrimitiveColorTokenMatrix({
    super.key,
    this.onSwatchSelected,
  });

  @override
  State<PrimitiveColorTokenMatrix> createState() => _PrimitiveColorTokenMatrixState();
}

class _PrimitiveColorTokenMatrixState extends State<PrimitiveColorTokenMatrix> {
  String _selectedFamily = 'Primary';
  int _selectedTone = 40;

  // Primary family tonal steps (0 to 100)
  final List<TonalPrimitiveSwatch> _primaryTones = const [
    TonalPrimitiveSwatch(tone: 0, color: Color(0xFF000000), hex: '#000000', semanticRole: 'Absolute Black'),
    TonalPrimitiveSwatch(tone: 10, color: Color(0xFF001A41), hex: '#001A41', semanticRole: 'Dark On-Primary Container'),
    TonalPrimitiveSwatch(tone: 20, color: Color(0xFF002F6C), hex: '#002F6C', semanticRole: 'Primary Dark Surface'),
    TonalPrimitiveSwatch(tone: 30, color: Color(0xFF00459B), hex: '#00459B', semanticRole: 'Primary Dark Accent'),
    TonalPrimitiveSwatch(tone: 40, color: Color(0xFF2563EB), hex: '#2563EB', semanticRole: 'Primary Base Brand (Default)'),
    TonalPrimitiveSwatch(tone: 50, color: Color(0xFF3B82F6), hex: '#3B82F6', semanticRole: 'Primary Hover State'),
    TonalPrimitiveSwatch(tone: 60, color: Color(0xFF60A5FA), hex: '#60A5FA', semanticRole: 'Primary Focus Outline'),
    TonalPrimitiveSwatch(tone: 70, color: Color(0xFF93C5FD), hex: '#93C5FD', semanticRole: 'Primary Container Border'),
    TonalPrimitiveSwatch(tone: 80, color: Color(0xFFBFDBFE), hex: '#BFDBFE', semanticRole: 'Primary Light Accent'),
    TonalPrimitiveSwatch(tone: 90, color: Color(0xFFDBEAFE), hex: '#DBEAFE', semanticRole: 'Primary Soft Container'),
    TonalPrimitiveSwatch(tone: 95, color: Color(0xFFEFF6FF), hex: '#EFF6FF', semanticRole: 'Primary Light Surface Tint'),
    TonalPrimitiveSwatch(tone: 100, color: Color(0xFFFFFFFF), hex: '#FFFFFF', semanticRole: 'Absolute White'),
  ];

  // Secondary family tonal steps (Teal)
  final List<TonalPrimitiveSwatch> _secondaryTones = const [
    TonalPrimitiveSwatch(tone: 0, color: Color(0xFF000000), hex: '#000000', semanticRole: 'Absolute Black'),
    TonalPrimitiveSwatch(tone: 10, color: Color(0xFF042F2E), hex: '#042F2E', semanticRole: 'Teal On-Secondary'),
    TonalPrimitiveSwatch(tone: 20, color: Color(0xFF134E4A), hex: '#134E4A', semanticRole: 'Teal Deep Surface'),
    TonalPrimitiveSwatch(tone: 30, color: Color(0xFF115E59), hex: '#115E59', semanticRole: 'Teal Medium'),
    TonalPrimitiveSwatch(tone: 40, color: Color(0xFF0D9488), hex: '#0D9488', semanticRole: 'Secondary Base Teal'),
    TonalPrimitiveSwatch(tone: 50, color: Color(0xFF14B8A6), hex: '#14B8A6', semanticRole: 'Secondary Active Accent'),
    TonalPrimitiveSwatch(tone: 60, color: Color(0xFF2DD4BF), hex: '#2DD4BF', semanticRole: 'Secondary Light Highlight'),
    TonalPrimitiveSwatch(tone: 70, color: Color(0xFF5EEAD4), hex: '#5EEAD4', semanticRole: 'Secondary Subtle Accent'),
    TonalPrimitiveSwatch(tone: 80, color: Color(0xFF99F6E4), hex: '#99F6E4', semanticRole: 'Secondary Muted Container'),
    TonalPrimitiveSwatch(tone: 90, color: Color(0xFFCCFBF1), hex: '#CCFBF1', semanticRole: 'Secondary Light Container'),
    TonalPrimitiveSwatch(tone: 95, color: Color(0xFFF0FDFA), hex: '#F0FDFA', semanticRole: 'Secondary Tint Surface'),
    TonalPrimitiveSwatch(tone: 100, color: Color(0xFFFFFFFF), hex: '#FFFFFF', semanticRole: 'Absolute White'),
  ];

  // Neutral family tonal steps (Slate)
  final List<TonalPrimitiveSwatch> _neutralTones = const [
    TonalPrimitiveSwatch(tone: 0, color: Color(0xFF000000), hex: '#000000', semanticRole: 'Absolute Black'),
    TonalPrimitiveSwatch(tone: 10, color: Color(0xFF0F172A), hex: '#0F172A', semanticRole: 'Neutral Foreground Dark'),
    TonalPrimitiveSwatch(tone: 20, color: Color(0xFF1E293B), hex: '#1E293B', semanticRole: 'Neutral Card Dark'),
    TonalPrimitiveSwatch(tone: 30, color: Color(0xFF334155), hex: '#334155', semanticRole: 'Neutral Body Medium'),
    TonalPrimitiveSwatch(tone: 40, color: Color(0xFF475569), hex: '#475569', semanticRole: 'Neutral Secondary Text'),
    TonalPrimitiveSwatch(tone: 50, color: Color(0xFF64748B), hex: '#64748B', semanticRole: 'Neutral Muted Icon/Text'),
    TonalPrimitiveSwatch(tone: 60, color: Color(0xFF94A3B8), hex: '#94A3B8', semanticRole: 'Neutral Border Outline'),
    TonalPrimitiveSwatch(tone: 70, color: Color(0xFFCBD5E1), hex: '#CBD5E1', semanticRole: 'Neutral Divider Line'),
    TonalPrimitiveSwatch(tone: 80, color: Color(0xFFE2E8F0), hex: '#E2E8F0', semanticRole: 'Neutral Card Border'),
    TonalPrimitiveSwatch(tone: 90, color: Color(0xFFF1F5F9), hex: '#F1F5F9', semanticRole: 'Neutral Secondary Surface'),
    TonalPrimitiveSwatch(tone: 95, color: Color(0xFFF8FAFC), hex: '#F8FAFC', semanticRole: 'Neutral Background Light'),
    TonalPrimitiveSwatch(tone: 100, color: Color(0xFFFFFFFF), hex: '#FFFFFF', semanticRole: 'Absolute White'),
  ];

  List<TonalPrimitiveSwatch> get _activePalette {
    switch (_selectedFamily) {
      case 'Secondary':
        return _secondaryTones;
      case 'Neutral':
        return _neutralTones;
      default:
        return _primaryTones;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSwatch = _activePalette.firstWhere(
      (s) => s.tone == _selectedTone,
      orElse: () => _activePalette[4],
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: PrimitiveColorTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: PrimitiveColorTokens.borderLight),
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
                  color: PrimitiveColorTokens.primaryBase.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.colorize_rounded,
                  color: PrimitiveColorTokens.primaryBase,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primitive Color Tokens',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PrimitiveColorTokens.textDark,
                      ),
                    ),
                    Text(
                      'ISO/IEC 25010 & MD3 Tonal Palette Primitives',
                      style: TextStyle(
                        fontSize: 12,
                        color: PrimitiveColorTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PrimitiveColorTokens.complianceBadgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ISO 25010',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PrimitiveColorTokens.complianceBadgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Family Switcher
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Primary', label: Text('Primary (Blue)')),
              ButtonSegment(value: 'Secondary', label: Text('Secondary (Teal)')),
              ButtonSegment(value: 'Neutral', label: Text('Neutral (Slate)')),
            ],
            selected: {_selectedFamily},
            onSelectionChanged: (newVal) {
              setState(() {
                _selectedFamily = newVal.first;
              });
            },
          ),
          const SizedBox(height: 16),
          // Tonal Ramp Horizontal Strip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PrimitiveColorTokens.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PrimitiveColorTokens.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tonal Palette Ramp (Tone 0 -> 100)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PrimitiveColorTokens.textDark,
                      ),
                    ),
                    Text(
                      '12 Tonal Steps',
                      style: TextStyle(
                        fontSize: 11,
                        color: PrimitiveColorTokens.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Horizontal scrollable swatches
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _activePalette.map((swatch) {
                      final isSelected = _selectedTone == swatch.tone;
                      final isLight = swatch.tone >= 60;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedTone = swatch.tone);
                          widget.onSwatchSelected?.call(swatch);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 44,
                          height: 64,
                          decoration: BoxDecoration(
                            color: swatch.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? PrimitiveColorTokens.primaryBase
                                  : PrimitiveColorTokens.borderLight,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${swatch.tone}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isLight ? Colors.black87 : Colors.white,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.arrow_drop_up_rounded,
                                  color: isLight ? Colors.black87 : Colors.white,
                                  size: 20,
                                )
                              else
                                const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Active Swatch Deep-Dive Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: activeSwatch.color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: activeSwatch.color.withAlpha(80)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: activeSwatch.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PrimitiveColorTokens.borderLight),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'md.ref.palette.${_selectedFamily.toLowerCase()}${activeSwatch.tone}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          color: PrimitiveColorTokens.textDark,
                        ),
                      ),
                      Text(
                        activeSwatch.semanticRole,
                        style: const TextStyle(
                          fontSize: 11,
                          color: PrimitiveColorTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      activeSwatch.hex,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        color: PrimitiveColorTokens.textDark,
                      ),
                    ),
                    Text(
                      'Tone ${activeSwatch.tone}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: PrimitiveColorTokens.textMuted,
                      ),
                    ),
                  ],
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
            child: PrimitiveColorTokenMatrix(),
          ),
        ),
      ),
    ),
  );
}
