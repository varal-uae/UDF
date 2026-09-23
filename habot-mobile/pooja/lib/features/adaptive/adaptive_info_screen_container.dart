import 'package:flutter/material.dart';

/// Unique design tokens for Adaptive Info Screen Container.
abstract final class AdaptiveContainerTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color badgeGreenBg = Color(0xFFDCFCE7);
  static const Color badgeGreenText = Color(0xFF166534);
}

/// MD3 Window Size Class definition.
enum WindowSizeClass {
  compact, // < 600dp
  medium, // 600 - 840dp
  expanded, // > 840dp
}

/// Posture state for foldable/adaptive devices.
enum DevicePosture {
  flat,
  tabletop,
  book,
}

/// Strongly-typed immutable AdaptiveInfo structure enforcing MD3 Adaptive Architecture.
class AdaptiveInfo {
  final WindowSizeClass sizeClass;
  final DevicePosture posture;
  final Orientation orientation;
  final double screenWidth;
  final double screenHeight;

  const AdaptiveInfo({
    required this.sizeClass,
    required this.posture,
    required this.orientation,
    required this.screenWidth,
    required this.screenHeight,
  });

  /// Factory constructor to derive AdaptiveInfo from current BuildContext.
  factory AdaptiveInfo.fromContext(BuildContext context, {DevicePosture posture = DevicePosture.flat}) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    final WindowSizeClass sizeClass;
    if (width < 600) {
      sizeClass = WindowSizeClass.compact;
    } else if (width < 840) {
      sizeClass = WindowSizeClass.medium;
    } else {
      sizeClass = WindowSizeClass.expanded;
    }

    return AdaptiveInfo(
      sizeClass: sizeClass,
      posture: posture,
      orientation: media.orientation,
      screenWidth: width,
      screenHeight: height,
    );
  }
}

/// A feature screen configured strictly to consume and render via AdaptiveInfo structures.
class AdaptiveInfoScreenContainer extends StatefulWidget {
  final AdaptiveInfo? initialInfo;
  final void Function(AdaptiveInfo info)? onLayoutChanged;

  const AdaptiveInfoScreenContainer({
    super.key,
    this.initialInfo,
    this.onLayoutChanged,
  });

  @override
  State<AdaptiveInfoScreenContainer> createState() => _AdaptiveInfoScreenContainerState();
}

class _AdaptiveInfoScreenContainerState extends State<AdaptiveInfoScreenContainer> {
  late WindowSizeClass _simulatedSizeClass;
  late DevicePosture _simulatedPosture;
  int _selectedItemIndex = 0;

  final List<String> _items = const [
    'Service Delivery Orchestrator',
    'Tenant Fleet Telemetry',
    'Real-time SLA Governance',
    'Billing Token Aggregator',
  ];

  @override
  void initState() {
    super.initState();
    _simulatedSizeClass = widget.initialInfo?.sizeClass ?? WindowSizeClass.compact;
    _simulatedPosture = widget.initialInfo?.posture ?? DevicePosture.flat;
  }

  AdaptiveInfo _buildCurrentInfo() {
    return AdaptiveInfo(
      sizeClass: _simulatedSizeClass,
      posture: _simulatedPosture,
      orientation: Orientation.portrait,
      screenWidth: _simulatedSizeClass == WindowSizeClass.compact
          ? 390.0
          : (_simulatedSizeClass == WindowSizeClass.medium ? 720.0 : 960.0),
      screenHeight: 844.0,
    );
  }

  void _updateSimulation(WindowSizeClass size, DevicePosture posture) {
    setState(() {
      _simulatedSizeClass = size;
      _simulatedPosture = posture;
    });
    widget.onLayoutChanged?.call(_buildCurrentInfo());
  }

  @override
  Widget build(BuildContext context) {
    final info = _buildCurrentInfo();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AdaptiveContainerTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AdaptiveContainerTokens.borderLight),
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
                  color: AdaptiveContainerTokens.primaryTeal.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.devices_fold_rounded,
                  color: AdaptiveContainerTokens.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AdaptiveInfo Screen Container',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AdaptiveContainerTokens.textDark,
                      ),
                    ),
                    Text(
                      'Type-Safe MD3 Adaptive Architecture Invariant',
                      style: TextStyle(
                        fontSize: 12,
                        color: AdaptiveContainerTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdaptiveContainerTokens.badgeGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ADAPTIVE OK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AdaptiveContainerTokens.badgeGreenText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Adaptive Class Controls
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Compact (<600dp)'),
                selected: _simulatedSizeClass == WindowSizeClass.compact,
                onSelected: (selected) {
                  if (selected) _updateSimulation(WindowSizeClass.compact, _simulatedPosture);
                },
              ),
              ChoiceChip(
                label: const Text('Medium (600-840dp)'),
                selected: _simulatedSizeClass == WindowSizeClass.medium,
                onSelected: (selected) {
                  if (selected) _updateSimulation(WindowSizeClass.medium, _simulatedPosture);
                },
              ),
              ChoiceChip(
                label: const Text('Expanded (>840dp)'),
                selected: _simulatedSizeClass == WindowSizeClass.expanded,
                onSelected: (selected) {
                  if (selected) _updateSimulation(WindowSizeClass.expanded, _simulatedPosture);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Posture Controls
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                avatar: const Icon(Icons.tablet_android, size: 16),
                label: const Text('Flat Posture'),
                selected: _simulatedPosture == DevicePosture.flat,
                onSelected: (selected) {
                  if (selected) _updateSimulation(_simulatedSizeClass, DevicePosture.flat);
                },
              ),
              ChoiceChip(
                avatar: const Icon(Icons.laptop_chromebook, size: 16),
                label: const Text('Tabletop Mode'),
                selected: _simulatedPosture == DevicePosture.tabletop,
                onSelected: (selected) {
                  if (selected) _updateSimulation(_simulatedSizeClass, DevicePosture.tabletop);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Layout Canvas Rendering based on AdaptiveInfo
          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdaptiveContainerTokens.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdaptiveContainerTokens.borderLight),
            ),
            child: _buildAdaptiveLayout(info),
          ),
          const SizedBox(height: 12),
          // Invariant Telemetry Metadata
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdaptiveContainerTokens.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.memory_rounded, size: 16, color: AdaptiveContainerTokens.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Input Contract: AdaptiveInfo(sizeClass: ${info.sizeClass.name}, posture: ${info.posture.name})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: AdaptiveContainerTokens.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveLayout(AdaptiveInfo info) {
    if (info.sizeClass == WindowSizeClass.compact) {
      // Single Pane Compact View
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android, size: 16, color: AdaptiveContainerTokens.primaryTeal),
              const SizedBox(width: 6),
              Text(
                'Single-Pane Feed (${info.screenWidth.toInt()}dp Compact)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, idx) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AdaptiveContainerTokens.borderLight),
                  ),
                  child: Text(_items[idx], style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ],
      );
    } else {
      // Split Master-Detail Layout for Medium / Expanded
      return Row(
        children: [
          // Master Pane
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdaptiveContainerTokens.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Master List', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, idx) {
                        final isSel = _selectedItemIndex == idx;
                        return InkWell(
                          onTap: () => setState(() => _selectedItemIndex = idx),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSel ? AdaptiveContainerTokens.primaryTeal.withAlpha(20) : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _items[idx],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? AdaptiveContainerTokens.primaryTeal : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Detail Pane
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdaptiveContainerTokens.primaryTeal.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail: ${_items[_selectedItemIndex]}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdaptiveContainerTokens.primaryTeal),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configured dynamically for ${info.sizeClass.name} width (${info.screenWidth.toInt()}dp) under ${info.posture.name} posture orientation.',
                    style: const TextStyle(fontSize: 11, color: AdaptiveContainerTokens.textMuted),
                  ),
                  const Spacer(),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Text('Dual-Pane Ready', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
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
            child: AdaptiveInfoScreenContainer(),
          ),
        ),
      ),
    ),
  );
}
