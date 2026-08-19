// DLQDP-015-02 — System-Verb Icon Mapping Matrix.
// Restricts structural icons strictly to a 24x24dp bounding box while embedding phantom padding to guarantee 48x48dp hit targets.

import 'package:flutter/material.dart';

class SystemVerbIconWrapper extends StatelessWidget {
  const SystemVerbIconWrapper({
    super.key,
    required this.icon,
    required this.onTap,
    this.semanticLabel = 'System Action',
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48.0,  // Phantom padding hit target width (48dp minimum)
          height: 48.0, // Phantom padding hit target height (48dp minimum)
          alignment: Alignment.center,
          child: SizedBox(
            width: 24.0,  // Strict 24x24dp icon bounding box
            height: 24.0,
            child: Icon(
              icon,
              size: 24.0,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
