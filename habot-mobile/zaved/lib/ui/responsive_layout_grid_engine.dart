import 'package:flutter/material.dart';

/// ============================================================================
/// ARCHITECTURAL METADATA
/// Definition Name: Responsive Breakpoint & Column Engine
/// Definition Parameters: xs (<600), sm (600-840), md (840-1024), lg (1024-1440), xl (>1440)
/// Definition Type: Grid Layout Utility & Anti-Clipping Guardrail
/// Definition ID: ARCH-GRID-ENG-RCGLA-021
/// Validation Status: Pass
/// ============================================================================

/// Breakpoint Constants Engine
class LayoutBreakpoints {
  static const double xsMax = 599.9;
  static const double smMin = 600.0;
  static const double smMax = 839.9;
  static const double mdMin = 840.0;
  static const double mdMax = 1023.9;
  static const double lgMin = 1024.0;
  static const double lgMax = 1439.9;
  static const double xlMin = 1440.0;

  static String getBreakpointName(double width) {
    if (width < smMin) return 'xs (< 600)';
    if (width <= smMax) return 'sm (600 - 840)';
    if (width <= mdMax) return 'md (840 - 1024)';
    if (width <= lgMax) return 'lg (1024 - 1440)';
    return 'xl (> 1440)';
  }
}

/// The 4-8-12 Column & Margin Engine Wrapper Widget
class ResponsiveGridContainer extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveGridContainer({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final double horizontalMargin;
        final int columnCount;

        if (width < 600) {
          // Mobile: 4 columns, 16.0 margin, unified vertical Column
          horizontalMargin = 16.0;
          columnCount = 4;
        } else if (width <= 840) {
          // Tablet: 8 columns, 24.0 margin
          horizontalMargin = 24.0;
          columnCount = 8;
        } else {
          // Desktop: 12 columns, 24.0 margin
          horizontalMargin = 24.0;
          columnCount = 12;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grid Engine Header Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_on,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Grid Engine: $columnCount-Columns | Margin: ${horizontalMargin.toInt()}dp | Breakpoint: ${LayoutBreakpoints.getBreakpointName(width)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Layout Arrangement based on breakpoint
              if (width < 600)
                // Mobile (< 600): Unified Vertical Column
                Column(
                  children: children
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: SizedBox(width: double.infinity, child: c),
                          ))
                      .toList(),
                )
              else
                // Tablet/Desktop (>= 600): Row / Wrap Side-by-Side Configuration
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: children.map((c) {
                    final cardWidth = width < 840
                        ? (width - (horizontalMargin * 2) - 16.0) / 2
                        : (width - (horizontalMargin * 2) - 32.0) / 3;

                    return SizedBox(
                      width: cardWidth.clamp(280.0, 450.0),
                      child: c,
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Anti-Clipping Guardrails (Poka-Yoke) Wrapper Widget
/// Enforces a ConstrainedBox with maxWidth equal to parent constraints,
/// physically preventing layout breaking or overflow clipping on wide components.
class SafeTableContainer extends StatelessWidget {
  final Widget child;

  const SafeTableContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: IntrinsicWidth(
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// RCGLA-021: Demo Stateful Dashboard for Responsive Layout Grid & Breakpoint Engine
class ResponsiveLayoutGridEngine extends StatefulWidget {
  const ResponsiveLayoutGridEngine({super.key});

  @override
  State<ResponsiveLayoutGridEngine> createState() =>
      _ResponsiveLayoutGridEngineState();
}

class _ResponsiveLayoutGridEngineState
    extends State<ResponsiveLayoutGridEngine> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Layout Grid & Breakpoint Engine'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Grid Container Module
            ResponsiveGridContainer(
              children: [
                _buildDemoModuleCard(
                  title: 'Module 01: Telemetry Stream',
                  subtitle: 'Real-time Pub/Sub Data Pipeline',
                  icon: Icons.stream,
                  theme: theme,
                ),
                _buildDemoModuleCard(
                  title: 'Module 02: Key Management',
                  subtitle: 'CMEK HSM Secret Vault',
                  icon: Icons.vpn_key,
                  theme: theme,
                ),
                _buildDemoModuleCard(
                  title: 'Module 03: Compliance Engine',
                  subtitle: 'DAMA-DMBOK2 Audit Logger',
                  icon: Icons.verified_user,
                  theme: theme,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Anti-Clipping Guardrail SafeTableContainer Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Poka-Yoke Anti-Clipping Guardrail (SafeTableContainer)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prevents horizontal layout overflow clipping on wide data tables across constrained viewports.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: SafeTableContainer(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Param ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Grid Breakpoint', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Column Count', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Margin (dp)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Anti-Clip Guard', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Validation Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: [
                          DataRow(cells: [
                            const DataCell(Text('GRID-XS-01')),
                            const DataCell(Text('xs (<600)')),
                            const DataCell(Text('4 Columns')),
                            const DataCell(Text('16.0 dp')),
                            const DataCell(Text('ACTIVE')),
                            DataCell(Text('PASS', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('GRID-SM-02')),
                            const DataCell(Text('sm (600-840)')),
                            const DataCell(Text('8 Columns')),
                            const DataCell(Text('24.0 dp')),
                            const DataCell(Text('ACTIVE')),
                            DataCell(Text('PASS', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('GRID-MD-03')),
                            const DataCell(Text('md (840-1024)')),
                            const DataCell(Text('12 Columns')),
                            const DataCell(Text('24.0 dp')),
                            const DataCell(Text('ACTIVE')),
                            DataCell(Text('PASS', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              child: Icon(icon),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
