// BLGTA-038-13 — Navigation Motion Curves & Viewport Restoration.
// Applies standard Material motion curves to screen route transitions and resets document display coordinate offsets instantly.

import 'package:flutter/material.dart';

class Blgta03813MotionPageRoute<T> extends PageRouteBuilder<T> {
  Blgta03813MotionPageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.025),
                  end: Offset.zero,
                ).animate(curvedAnimation),
              ),
            );
          },
        );
}

/// Instantly resets the viewport to its top-left origin,
/// clearing any document display coordinate offsets.
void blgta03813RestoreViewport(ScrollController scrollController) {
  if (!scrollController.hasClients) return;
  scrollController.jumpTo(0.0);
}
