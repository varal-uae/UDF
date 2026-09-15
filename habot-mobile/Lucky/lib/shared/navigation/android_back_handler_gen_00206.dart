// GEN-00206 — UDF Step Back Handler & Finalized Design Registry.
// Maps Android hardware back to step-back behavior with M3 single-column layout, finalized spacing and typography tokens.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Finalize: canonical visual coordinates and typography scale from Figma registry.
abstract final class Gen00206DesignRegistry {
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double radiusMd = 12.0;
  static const double cardElevation = 3.0;
  static const double typeScaleRatio = 1.25;
  static const double bodyM = 14.0;
  static const double titleM = 16.0;
  static const double headlineS = 20.0;
  static const double minTouchTarget = 48.0;
  static const Duration livenessPoll = Duration(seconds: 30);
}

// Define: step-back contract shared by system back and in-app back.
typedef Gen00206StepBackCallback = Future<bool> Function();

// Display: M3 step screen with finalized tokens and Android back mapping.
class Gen00206UdfStepScreen extends StatefulWidget {
  final String stepTitle;
  final String completionStatus;
  final Gen00206StepBackCallback? onStepBack;
  final Future<void> Function()? onRefresh;

  const Gen00206UdfStepScreen({
    super.key,
    this.stepTitle = 'Finalize visual coordinates & type scale',
    this.completionStatus = 'Complete',
    this.onStepBack,
    this.onRefresh,
  });

  @override
  State<Gen00206UdfStepScreen> createState() => _Gen00206UdfStepScreenState();
}

class _Gen00206UdfStepScreenState extends State<Gen00206UdfStepScreen> {
  Timer? _livenessTimer;
  DateTime? _lastBackPress;
  bool _isHandlingBack = false;

  @override
  void initState() {
    super.initState();
    // Monitor: 30s liveness handshake for step health.
    _livenessTimer = Timer.periodic(Gen00206DesignRegistry.livenessPoll, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _livenessTimer?.cancel();
    super.dispose();
  }

  // Handle: map hardware back to identical step-back behavior.
  Future<void> _handleSystemBack(bool didPop) async {
    if (didPop || _isHandlingBack) return;
    _isHandlingBack = true;
    try {
      HapticFeedback.selectionClick();
      bool shouldPop = true;
      if (widget.onStepBack != null) {
        shouldPop = await widget.onStepBack!();
      } else {
        shouldPop = _confirmDoublePress();
      }
      if (!mounted) return;
      if (shouldPop) {
        Navigator.of(context).maybePop();
      } else {
        // Confirm: M3 Snackbar for blocked / confirm-press feedback.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Press back again to leave this step')),
        );
      }
    } finally {
      _isHandlingBack = false;
    }
  }

  // Confirm: require double-press within 2s when no custom handler supplied.
  bool _confirmDoublePress() {
    final now = DateTime.now();
    if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      return false;
    }
    return true;
  }

  // Display: M3 Bottom Sheet for configuration inputs.
  void _showConfigSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Gen00206DesignRegistry.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step configuration', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Gen00206DesignRegistry.spacingSm),
              Text('Type scale ratio: ${Gen00206DesignRegistry.typeScaleRatio} | Body: ${Gen00206DesignRegistry.bodyM}sp',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: Gen00206DesignRegistry.spacingMd),
              SizedBox(
                width: double.infinity,
                height: Gen00206DesignRegistry.minTouchTarget,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 840;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _handleSystemBack(didPop),
      child: Scaffold(
        appBar: AppBar(
          leading: Semantics(
            button: true,
            label: 'Back to previous step',
            child: SizedBox(
              width: Gen00206DesignRegistry.minTouchTarget,
              height: Gen00206DesignRegistry.minTouchTarget,
              child: IconButton(
                onPressed: () => _handleSystemBack(false),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          title: const Text('GEN-00206 · UDF'),
          actions: [
            SizedBox(
              width: Gen00206DesignRegistry.minTouchTarget,
              height: Gen00206DesignRegistry.minTouchTarget,
              child: IconButton(onPressed: _showConfigSheet, icon: const Icon(Icons.tune)),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: widget.onRefresh ?? () async {},
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 720 : 600),
              child: ListView(
                padding: const EdgeInsets.all(Gen00206DesignRegistry.spacingMd),
                children: [
                  Card(
                    elevation: Gen00206DesignRegistry.cardElevation,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Gen00206DesignRegistry.radiusMd),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(Gen00206DesignRegistry.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(widget.stepTitle,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: Gen00206DesignRegistry.titleM)),
                              ),
                              // Display: M3 status chip for step health.
                              Chip(
                                label: Text(widget.completionStatus),
                                avatar: const Icon(Icons.check_circle, size: 18),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: Gen00206DesignRegistry.spacingSm),
                          Text('Visual coordinates and typography scale ratios finalized in Figma registry.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Gen00206DesignRegistry.bodyM)),
                          const SizedBox(height: Gen00206DesignRegistry.spacingSm),
                          Text('Hardware back on Android triggers the same step-back as the AppBar back button.',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
