import 'package:flutter/material.dart';
import '../../../../core/utils/auth_abandon_telemetry.dart';

// ARCPE-001 — Splash Screen.
// Spec: "Smooth transition from the Splash screen to an immediate interactive state."
//       "Zero friction during the critical first 30 seconds of app exposure."
//
// Auto-navigates to login after 2 seconds.
// Uses FadeTransition — no jarring jump.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onComplete});

  /// Called when splash completes — navigate to login.
  final VoidCallback? onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _fadeCtrl;
  late final Animation<double>    _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Auto-navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo placeholder — replace with actual asset
              Container(
                width:  80,
                height: 80,
                decoration: BoxDecoration(
                  color:        cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.hub_rounded,
                  size:  40,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),

              // App name
              Text(
                'Habot',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:      cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Connect DMCC',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
