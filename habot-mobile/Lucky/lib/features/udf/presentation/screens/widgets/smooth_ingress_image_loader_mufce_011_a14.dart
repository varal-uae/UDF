// MUFCE-011-A14 — SmoothIngressImageLoader with motion curves and opacity transitions.
// Provides a reusable widget that animates image loading with ease-in/ease-out curves, fixed container footprints to prevent layout shifts, and automatic fallback icons for broken links.

import 'dart:async';
import 'package:flutter/material.dart';

/// Reusable component mapped to Atomic ID: MUFCE-011-A14
/// Implements smooth ingress animation motion curves for image rendering.
class SmoothIngressImageLoader extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Duration transitionDuration;
  final Curve motionCurve;
  final Widget? errorFallback;
  final Widget? placeholder;

  const SmoothIngressImageLoader({
    super.key,
    required this.imageUrl,
    this.width = 200.0,
    this.height = 200.0,
    this.fit = BoxFit.cover,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.motionCurve = Curves.easeInOutCubic,
    this.errorFallback,
    this.placeholder,
  });

  @override
  State<SmoothIngressImageLoader> createState() => _SmoothIngressImageLoaderState();
}

class _SmoothIngressImageLoaderState extends State<SmoothIngressImageLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  ImageStream? _imageStream;
  bool _hasError = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.motionCurve,
    );
    _loadImage();
  }

  void _loadImage() {
    try {
      final imageProvider = NetworkImage(widget.imageUrl);
      final resolver = imageProvider.resolve(ImageConfiguration.empty);
      _imageStream = resolver;
      
      // Use ImageStreamListener for precise load state completion triggers
      resolver.addListener(ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
            _hasError = false;
          });
          // Link asset load state completions to immediate layout initialization triggers
          _controller.forward();
        },
        onError: (Object exception, StackTrace? stackTrace) {
          if (!mounted) return;
          setState(() {
            _hasError = true;
            _isLoaded = false;
          });
          // Mistake-Proofing (Poka-Yoke): Broken link responses map to local system default icons automatically
          _controller.forward();
        },
      ));
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lock container footprints to prevent vertical layout shifts when data arrives
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          );
        },
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      // Poka-Yoke: Blocking broken code display errors
      return widget.errorFallback ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image_outlined,
              size: 48.0,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
    }

    if (!_isLoaded) {
      // Configure linear opacity scaling metrics for fading placeholders out
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
    }

    // GPU hardware acceleration tokens locally via RepaintBoundary
    return RepaintBoundary(
      child: Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorFallback ??
              Icon(
                Icons.broken_image_outlined,
                size: 48.0,
                color: Theme.of(context).colorScheme.error,
              );
        },
      ),
    );
  }
}

/// Mock data repository for testing without backend dependencies
class MockImageRepository {
  static const List<String> validImageUrls = [
    'https://picsum.photos/id/1015/400/300',
    'https://picsum.photos/id/1016/400/300',
    'https://picsum.photos/id/1018/400/300',
  ];

  static const List<String> brokenImageUrls = [
    'https://invalid-domain-test.local/broken-image.jpg',
    'https://example.com/non-existent-asset.png',
  ];

  static String getRandomValidUrl() {
    return validImageUrls[DateTime.now().millisecond % validImageUrls.length];
  }

  static String getRandomBrokenUrl() {
    return brokenImageUrls[DateTime.now().millisecond % brokenImageUrls.length];
  }
}

/// Preview screen for design token validation and UX translation verification
class SmoothIngressPreviewScreen extends StatelessWidget {
  const SmoothIngressPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MUFCE-011-A14: Smooth Ingress Loader'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valid Image Transitions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                SmoothIngressImageLoader(
                  imageUrl: MockImageRepository.validImageUrls[0],
                  width: 150,
                  height: 150,
                  transitionDuration: const Duration(milliseconds: 200),
                  motionCurve: Curves.easeIn,
                ),
                SmoothIngressImageLoader(
                  imageUrl: MockImageRepository.validImageUrls[1],
                  width: 150,
                  height: 150,
                  transitionDuration: const Duration(milliseconds: 200),
                  motionCurve: Curves.easeOut,
                ),
                SmoothIngressImageLoader(
                  imageUrl: MockImageRepository.validImageUrls[2],
                  width: 150,
                  height: 150,
                  transitionDuration: const Duration(milliseconds: 200),
                  motionCurve: Curves.easeInOut,
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            Text(
              'Broken Link Fallbacks (Poka-Yoke)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                SmoothIngressImageLoader(
                  imageUrl: MockImageRepository.brokenImageUrls[0],
                  width: 150,
                  height: 150,
                ),
                SmoothIngressImageLoader(
                  imageUrl: MockImageRepository.brokenImageUrls[1],
                  width: 150,
                  height: 150,
                  errorFallback: Container(
                    width: 150,
                    height: 150,
                    color: Colors.red.shade50,
                    child: const Icon(Icons.error_outline, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}