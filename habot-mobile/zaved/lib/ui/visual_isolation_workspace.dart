import 'package:flutter/material.dart';

/// A Visual Isolation Workspace screen adhering to responsive Material Design guidelines.
class VisualIsolationWorkspace extends StatelessWidget {
  const VisualIsolationWorkspace({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Scaffold Setup: Intentionally omit AppBar, BottomNavigationBar, and Drawer for strict workspace isolation.
    return Scaffold(
      body: SafeArea(
        // 5. Workspace Lock: Full available height without root-level scrolling
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final colorScheme = Theme.of(context).colorScheme;

            // 3. Panel 1 (Image Crop Viewer): Expanded container with dark contrasting background
            final panel1 = Expanded(
              child: Container(
                color: colorScheme.inverseSurface,
                alignment: Alignment.center,
                child: Text(
                  'Image Crop Canvas',
                  style: TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );

            // 4. Panel 2 (Data Entry): Expanded container with theme background and TextField
            final panel2 = Expanded(
              child: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.all(24.0),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Entry',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Metadata Input',
                        hintText: 'Enter canvas metadata...',
                      ),
                    ),
                  ],
                ),
              ),
            );

            // 2. Responsive Layout: Column for < 600dp (mobile), Row for >= 600dp (desktop/tablet)
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  panel1,
                  panel2,
                ],
              );
            } else {
              return Row(
                children: [
                  panel1,
                  panel2,
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
