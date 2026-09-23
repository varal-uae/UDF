import 'dart:async';
import 'package:flutter/material.dart';

/// Unique styling tokens for Dynamic Skeleton Data Loader Card.
abstract final class SkeletonDataLoaderTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color skeletonBase = Color(0xFFE2E8F0);
  static const Color skeletonHighlight = Color(0xFFF1F5F9);
}

/// Simulated data payload model.
class HydratedDataPayload {
  final String orderId;
  final String customerName;
  final String amountFormatted;
  final String status;

  const HydratedDataPayload({
    required this.orderId,
    required this.customerName,
    required this.amountFormatted,
    required this.status,
  });
}

/// A dynamic component swapping skeleton loaders for actual data components seamlessly.
class DynamicSkeletonDataLoaderCard extends StatefulWidget {
  final void Function(bool isLoading)? onLoadingStateChanged;

  const DynamicSkeletonDataLoaderCard({
    super.key,
    this.onLoadingStateChanged,
  });

  @override
  State<DynamicSkeletonDataLoaderCard> createState() =>
      _DynamicSkeletonDataLoaderCardState();
}

class _DynamicSkeletonDataLoaderCardState
    extends State<DynamicSkeletonDataLoaderCard>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  HydratedDataPayload? _payload;
  late AnimationController _shimmerController;
  Timer? _fetchTimer;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1200));

    _simulateDataFetch();
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  void _simulateDataFetch() {
    setState(() {
      _isLoading = true;
      _payload = null;
    });
    widget.onLoadingStateChanged?.call(true);

    _fetchTimer?.cancel();
    _fetchTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _payload = const HydratedDataPayload(
            orderId: 'ORD-9842-AE',
            customerName: 'Amina Al Mansoori',
            amountFormatted: 'AED 1,480.00',
            status: 'SETTLED',
          );
        });
        widget.onLoadingStateChanged?.call(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: SkeletonDataLoaderTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: SkeletonDataLoaderTokens.borderLight),
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
                  color: SkeletonDataLoaderTokens.primaryBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_mode_rounded,
                  color: SkeletonDataLoaderTokens.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dynamic Skeleton Swapper',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SkeletonDataLoaderTokens.textDark,
                      ),
                    ),
                    Text(
                      'Seamless Placeholder to Data Transition (ISO/IEC 27001)',
                      style: TextStyle(
                        fontSize: 12,
                        color: SkeletonDataLoaderTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isLoading
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isLoading ? 'FETCHING SKELETON' : 'HYDRATED OK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _isLoading
                        ? const Color(0xFFB45309)
                        : const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dynamic Swapper Container with AnimatedSwitcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _isLoading
                ? _buildSkeletonPlaceholder()
                : _buildHydratedDataView(_payload!),
          ),
          const SizedBox(height: 14),
          // Manual Trigger Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _simulateDataFetch,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Simulate Dynamic Re-fetch & Skeleton Swap'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonPlaceholder() {
    return Container(
      key: const ValueKey('skeleton_view'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SkeletonDataLoaderTokens.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SkeletonDataLoaderTokens.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerBlock(width: 44, height: 44, radius: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBlock(width: 140, height: 14, radius: 4),
                    const SizedBox(height: 6),
                    _buildShimmerBlock(width: 80, height: 10, radius: 4),
                  ],
                ),
              ),
              _buildShimmerBlock(width: 60, height: 20, radius: 6),
            ],
          ),
          const SizedBox(height: 14),
          _buildShimmerBlock(width: double.infinity, height: 12, radius: 4),
          const SizedBox(height: 6),
          _buildShimmerBlock(width: 200, height: 12, radius: 4),
        ],
      ),
    );
  }

  Widget _buildHydratedDataView(HydratedDataPayload data) {
    return Container(
      key: const ValueKey('hydrated_view'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22C55E).withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF166534),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: SkeletonDataLoaderTokens.textDark,
                      ),
                    ),
                    Text(
                      data.orderId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: SkeletonDataLoaderTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Authorized Gross Amount:',
                  style: TextStyle(
                      fontSize: 11, color: SkeletonDataLoaderTokens.textMuted)),
              Text(
                data.amountFormatted,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: SkeletonDataLoaderTokens.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBlock({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: SkeletonDataLoaderTokens.skeletonBase,
        borderRadius: BorderRadius.circular(radius),
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
            child: DynamicSkeletonDataLoaderCard(),
          ),
        ),
      ),
    ),
  );
}
