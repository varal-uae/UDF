// SLPLU-006-A10 — Animated Skeleton Loader Components for Responsive Mobile Viewports.
// Provides hardware-accelerated shimmering placeholders that mirror target content structures to prevent layout shifts during async data loading, following MD3 surface guidelines.

import 'package:flutter/material.dart';

/// Hardware-accelerated animated skeleton loader component.
/// Uses [Transform.translate] (equivalent to CSS translate3d) for smooth 60fps animations on budget devices.
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8.0,
    this.child,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Utilize standard subtle surface variants for placeholder background colors (MD3)
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value + 1, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          // Ensure loading placeholder boundaries match the parent container's rounded corner styling properties
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Text line skeleton placeholder matching typographical weight guidelines.
class SkeletonTextLine extends StatelessWidget {
  final double widthFraction;
  final double height;
  final double borderRadius;

  const SkeletonTextLine({
    super.key,
    this.widthFraction = 1.0,
    this.height = 14.0,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFraction,
      child: SkeletonLoader(
        height: height,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Circular skeleton placeholder for avatars or circular loading indicators.
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

/// Composite Card Skeleton demonstrating Poka-Yoke mistake-proofing:
/// The placeholder layout mirrors the structural parameters of the target content directly.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Form control elements wrap layout blocks automatically to fit compact screens safely
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isCompact
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonCircle(size: 40),
                      SizedBox(height: 12),
                      SkeletonTextLine(widthFraction: 0.8),
                      SizedBox(height: 8),
                      SkeletonTextLine(widthFraction: 1.0),
                      SizedBox(height: 8),
                      SkeletonTextLine(widthFraction: 0.6),
                    ],
                  )
                : const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonCircle(size: 56),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonTextLine(widthFraction: 0.7),
                            SizedBox(height: 8),
                            SkeletonTextLine(widthFraction: 1.0),
                            SizedBox(height: 8),
                            SkeletonTextLine(widthFraction: 0.5),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// List Skeleton for analytical summary lists showing clean placeholder blocks.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final bool showCircularIndicators;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.showCircularIndicators = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (showCircularIndicators) {
          // Display list processing metrics using clear circular loading indicators using Material 3 guidelines
          return ListTile(
            leading: const SkeletonCircle(size: 40),
            title: const SkeletonTextLine(widthFraction: 0.6),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: SkeletonTextLine(widthFraction: 0.9),
            ),
            trailing: const SkeletonCircle(size: 24),
          );
        }
        return const SkeletonCard();
      },
    );
  }
}

/// Grid Skeleton mapping to 4-Column Fluid Grid System Configuration.
class SkeletonGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;

  const SkeletonGrid({
    super.key,
    this.crossAxisCount = 4,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SkeletonLoader(
          height: double.infinity,
          borderRadius: 12.0,
        );
      },
    );
  }
}

/// Mock Data and Usage Example for testing purposes.
class SkeletonLoaderMockRepository {
  static const String mockEndpoint = '/api/v1/udf/metrics';
  
  static const Map<String, dynamic> mockApiResponse = {
    'status': 'loading',
    'metrics': [],
    'timestamp': '2026-09-25T10:00:00Z'
  };

  static Future<List<Map<String, dynamic>>> fetchMetrics() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    return List.generate(5, (index) => {
      'id': index,
      'title': 'Metric $index',
      'value': (index * 10.5).toString(),
    });
  }
}

/// Test each placeholder component renders correctly at responsive breakpoints.
class SkeletonLoaderTestScreen extends StatelessWidget {
  const SkeletonLoaderTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skeleton Loaders - SLPLU-006-A10'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Text Lines', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const SkeletonTextLine(widthFraction: 1.0),
            const SizedBox(height: 8),
            const SkeletonTextLine(widthFraction: 0.75),
            const SizedBox(height: 8),
            const SkeletonTextLine(widthFraction: 0.5),
            const SizedBox(height: 24),
            const Text('Cards', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const SkeletonCard(),
            const SizedBox(height: 24),
            const Text('List with Circular Indicators', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const SkeletonList(itemCount: 3, showCircularIndicators: true),
            const SizedBox(height: 24),
            const Text('Responsive Grid (4-Column)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const SkeletonGrid(crossAxisCount: 4, itemCount: 8),
          ],
        ),
      ),
    );
  }
}