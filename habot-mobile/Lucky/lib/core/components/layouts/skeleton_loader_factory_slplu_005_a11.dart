// SLPLU-005-A11 — SkeletonLoaderFactory & Data Fetch Interceptor.
// Provides configurable shimmering skeleton placeholders matching component shapes, responsive layouts for mobile/tablet/desktop, and an interceptor with safety timers for cloud database queries.

import 'dart:async';
import 'package:flutter/material.dart';

/// Enum representing the target layout profile for skeleton generation.
enum SkeletonLayoutProfile {
  singleColumnMobile,
  multiColumnTablet,
  intricateDesktopMetrics,
}

/// Configuration for the skeleton loader.
class SkeletonConfig {
  final int rowCount;
  final SkeletonLayoutProfile profile;
  final bool hasLeading;
  final bool hasTrailing;
  final double borderRadius;

  const SkeletonConfig({
    this.rowCount = 5,
    this.profile = SkeletonLayoutProfile.singleColumnMobile,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.borderRadius = 8.0,
  });
}

/// Factory responsible for generating appropriate skeleton loaders based on configuration.
class SkeletonLoaderFactory {
  const SkeletonLoaderFactory._();

  static Widget create(SkeletonConfig config) {
    return _ShimmerEffect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return _DesktopSkeletonGrid(config: config);
          } else if (constraints.maxWidth > 600) {
            return _TabletSkeletonList(config: config);
          }
          return _MobileSkeletonList(config: config);
        },
      ),
    );
  }
}

/// Base shimmer animation widget using Material 3 design tokens.
class _ShimmerEffect extends StatefulWidget {
  final Widget child;

  const _ShimmerEffect({required this.child});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.8).animate(
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
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                Color.lerp(baseColor, highlightColor, _animation.value)!,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _MobileSkeletonList extends StatelessWidget {
  final SkeletonConfig config;

  const _MobileSkeletonList({required this.config});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: config.rowCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _SkeletonRow(config: config),
    );
  }
}

class _TabletSkeletonList extends StatelessWidget {
  final SkeletonConfig config;

  const _TabletSkeletonList({required this.config});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.0,
      ),
      itemCount: config.rowCount,
      itemBuilder: (context, index) => _SkeletonRow(config: config),
    );
  }
}

class _DesktopSkeletonGrid extends StatelessWidget {
  final SkeletonConfig config;

  const _DesktopSkeletonGrid({required this.config});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: config.rowCount,
      itemBuilder: (context, index) => Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  final SkeletonConfig config;

  const _SkeletonRow({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(config.borderRadius),
      ),
      child: Row(
        children: [
          if (config.hasLeading)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          if (config.hasLeading) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          if (config.hasTrailing) ...[
            const SizedBox(width: 16),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

/// Interceptor to detect when cloud database queries begin and end,
/// automatically showing/hiding skeletons with a safety timeout.
class DataFetchInterceptor<T> {
  final Future<T> Function() fetchOperation;
  final Duration safetyTimeout;
  final VoidCallback? onTimeout;

  DataFetchInterceptor({
    required this.fetchOperation,
    this.safetyTimeout = const Duration(seconds: 10),
    this.onTimeout,
  });

  Future<T?> execute() async {
    try {
      return await fetchOperation().timeout(safetyTimeout, onTimeout: () {
        onTimeout?.call();
        throw TimeoutException('Data fetch exceeded safety timer boundary.');
      });
    } catch (e) {
      rethrow;
    }
  }
}

/// A wrapper widget that automatically manages skeleton visibility
/// based on data stream or future resolution.
class InterceptedSkeletonView<T> extends StatefulWidget {
  final DataFetchInterceptor<T> interceptor;
  final SkeletonConfig skeletonConfig;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  const InterceptedSkeletonView({
    super.key,
    required this.interceptor,
    required this.skeletonConfig,
    required this.dataBuilder,
    this.errorBuilder,
  });

  @override
  State<InterceptedSkeletonView<T>> createState() =>
      _InterceptedSkeletonViewState<T>();
}

class _InterceptedSkeletonViewState<T>
    extends State<InterceptedSkeletonView<T>> {
  T? _data;
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _executeFetch();
  }

  Future<void> _executeFetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.interceptor.execute();
      if (mounted) {
        setState(() {
          _data = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SkeletonLoaderFactory.create(widget.skeletonConfig);
    }

    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!);
      }
      return Center(
        child: Text(
          'Failed to load data.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      );
    }

    if (_data != null) {
      return widget.dataBuilder(context, _data as T);
    }

    return const SizedBox.shrink();
  }
}

// --- MOCK DATA & USAGE EXAMPLE ---

class MockInstallationRecord {
  final String installationId;
  final String status;
  final DateTime timestamp;
  final String configDetails;
  final String systemPath;

  const MockInstallationRecord({
    required this.installationId,
    required this.status,
    required this.timestamp,
    required this.configDetails,
    required this.systemPath,
  });
}

final List<MockInstallationRecord> mockInstallations = [
  MockInstallationRecord(
    installationId: 'INST-001',
    status: 'Active',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    configDetails: '{"theme": "dark", "lang": "en"}',
    systemPath: '/sys/var/udf/001',
  ),
  MockInstallationRecord(
    installationId: 'INST-002',
    status: 'Pending',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    configDetails: '{"theme": "light", "lang": "ar"}',
    systemPath: '/sys/var/udf/002',
  ),
];

/// Example implementation demonstrating the factory and interceptor.
class SkeletonDemoScreen extends StatelessWidget {
  const SkeletonDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final interceptor = DataFetchInterceptor<List<MockInstallationRecord>>(
      fetchOperation: () async {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 1500));
        return mockInstallations;
      },
      safetyTimeout: const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('SLPLU-005-A11: Safety timer triggered.');
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Skeleton Loader Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InterceptedSkeletonView<List<MockInstallationRecord>>(
          interceptor: interceptor,
          skeletonConfig: const SkeletonConfig(
            rowCount: 4,
            profile: SkeletonLayoutProfile.singleColumnMobile,
            hasLeading: true,
            hasTrailing: true,
          ),
          dataBuilder: (context, data) {
            return ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = data[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.storage)),
                  title: Text(item.installationId),
                  subtitle: Text(item.status),
                  trailing: Chip(label: Text(item.systemPath)),
                );
              },
            );
          },
          errorBuilder: (context, error) {
            return Center(child: Text('Error: $error'));
          },
        ),
      ),
    );
  }
}