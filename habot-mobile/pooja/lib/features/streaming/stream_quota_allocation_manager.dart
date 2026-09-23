import 'package:flutter/material.dart';

/// Unique design tokens for Stream Quota Allocation Manager.
abstract final class StreamQuotaTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Status & Priority
  static const Color tierPrimary = Color(0xFF2563EB); // Telemetry
  static const Color tierSecondary = Color(0xFF0D9488); // Chat
  static const Color tierTertiary = Color(0xFFD97706); // Analytics

  static const Color quotaNormal = Color(0xFF16A34A);
  static const Color quotaNormalBg = Color(0xFFDCFCE7);
  static const Color quotaWarning = Color(0xFFEA580C);
  static const Color quotaWarningBg = Color(0xFFFFEDD5);

  static const int globalHardLimit = 100;
}

/// Model representing a stream allocation tier.
class StreamTierAllocation {
  final String tierId;
  final String title;
  final String description;
  final Color accentColor;
  int currentAllocated;
  final int maxCap;

  StreamTierAllocation({
    required this.tierId,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.currentAllocated,
    required this.maxCap,
  });
}

/// Strategic stream quota allocator to avoid quota limit breaches under ISO/IEC 27001.
class StreamQuotaAllocationManager extends StatefulWidget {
  final void Function(int totalStreams, bool withinQuota)? onQuotaUpdated;

  const StreamQuotaAllocationManager({
    super.key,
    this.onQuotaUpdated,
  });

  @override
  State<StreamQuotaAllocationManager> createState() =>
      _StreamQuotaAllocationManagerState();
}

class _StreamQuotaAllocationManagerState extends State<StreamQuotaAllocationManager> {
  bool _autoThrottleEnabled = true;

  late List<StreamTierAllocation> _tiers;

  @override
  void initState() {
    super.initState();
    _tiers = [
      StreamTierAllocation(
        tierId: 'telemetry',
        title: 'Tier 1: Core Telemetry & Heartbeat',
        description: 'Critical system liveness pings',
        accentColor: StreamQuotaTokens.tierPrimary,
        currentAllocated: 40,
        maxCap: 50,
      ),
      StreamTierAllocation(
        tierId: 'chat',
        title: 'Tier 2: Real-time Customer Messaging',
        description: 'Interactive live chat WebSockets',
        accentColor: StreamQuotaTokens.tierSecondary,
        currentAllocated: 25,
        maxCap: 35,
      ),
      StreamTierAllocation(
        tierId: 'analytics',
        title: 'Tier 3: Background Batch Pipelines',
        description: 'Yields first under quota congestion',
        accentColor: StreamQuotaTokens.tierTertiary,
        currentAllocated: 15,
        maxCap: 25,
      ),
    ];
  }

  int get _totalAllocated =>
      _tiers.fold<int>(0, (sum, tier) => sum + tier.currentAllocated);

  void _adjustAllocation(StreamTierAllocation tier, int newVal) {
    setState(() {
      tier.currentAllocated = newVal;
      // If auto-throttle is on and total > 90, scale back Tier 3
      if (_autoThrottleEnabled && _totalAllocated > 90) {
        final t3 = _tiers.firstWhere((t) => t.tierId == 'analytics');
        if (t3.currentAllocated > 5) {
          t3.currentAllocated = (t3.currentAllocated - 5).clamp(5, 25);
        }
      }
    });

    widget.onQuotaUpdated?.call(
      _totalAllocated,
      _totalAllocated <= StreamQuotaTokens.globalHardLimit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalAllocated;
    final isWarning = total > 85;
    final isBreach = total > StreamQuotaTokens.globalHardLimit;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: StreamQuotaTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: StreamQuotaTokens.borderLight),
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
                  color: StreamQuotaTokens.tierPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.stream_rounded,
                  color: StreamQuotaTokens.tierPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stream Quota Governor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: StreamQuotaTokens.textDark,
                      ),
                    ),
                    Text(
                      'Strategic Stream Balancing (ISO/IEC 27001)',
                      style: TextStyle(
                        fontSize: 12,
                        color: StreamQuotaTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isBreach
                      ? const Color(0xFFFEE2E2)
                      : (isWarning ? StreamQuotaTokens.quotaWarningBg : StreamQuotaTokens.quotaNormalBg),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isBreach ? 'BREACH' : (isWarning ? 'CONGESTED' : 'NORMAL'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isBreach
                        ? const Color(0xFFDC2626)
                        : (isWarning ? StreamQuotaTokens.quotaWarning : StreamQuotaTokens.quotaNormal),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Global Quota Progress Meter
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: StreamQuotaTokens.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StreamQuotaTokens.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Stream Allocation',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: StreamQuotaTokens.textDark),
                    ),
                    Text(
                      '$total / ${StreamQuotaTokens.globalHardLimit} Streams (${((total / StreamQuotaTokens.globalHardLimit) * 100).toInt()}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isBreach ? Colors.red : (isWarning ? StreamQuotaTokens.quotaWarning : StreamQuotaTokens.quotaNormal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (total / StreamQuotaTokens.globalHardLimit).clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isBreach ? Colors.red : (isWarning ? StreamQuotaTokens.quotaWarning : StreamQuotaTokens.quotaNormal),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Strategic Sliders per Tier
          Column(
            children: _tiers.map((tier) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: StreamQuotaTokens.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: tier.accentColor, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(tier.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Text(
                          '${tier.currentAllocated} streams',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tier.accentColor),
                        ),
                      ],
                    ),
                    Slider(
                      value: tier.currentAllocated.toDouble(),
                      min: 0,
                      max: tier.maxCap.toDouble(),
                      activeColor: tier.accentColor,
                      onChanged: (v) => _adjustAllocation(tier, v.toInt()),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Auto-throttle protection toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-Throttle Low-Priority Tiers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Prevents exceeding hard limits during spikes', style: TextStyle(fontSize: 11, color: StreamQuotaTokens.textMuted)),
                  ],
                ),
              ),
              Switch(
                value: _autoThrottleEnabled,
                onChanged: (v) => setState(() => _autoThrottleEnabled = v),
              ),
            ],
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
            child: StreamQuotaAllocationManager(),
          ),
        ),
      ),
    ),
  );
}
