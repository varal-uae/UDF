import 'package:flutter/material.dart';
import 'code_export_modal.dart';
import 'component_code_registry.dart';

/// Responsive 'Board Signatory Access Constraint' UI Component (IRBCA-061).
/// Fulfills strict 100% Material 3 conformity:
/// 1. LayoutBuilder & Scaffold thumb-sweep ergonomics (FloatingActionButton vs FloatingActionButton.extended).
/// 2. Complete DOM Eradication (Poka-Yoke Security): Strict ternary removes FAB entirely if unauthorized.
/// 3. High-Density Typography: TextStyle with height: 1.2, letterSpacing: -0.2, fontSize: 14.0.
/// 4. Strict High-Contrast Status Colors: High-contrast tertiaryContainer / onTertiaryContainer for pending status.
class BoardSignatoryAccessConstraint extends StatefulWidget {
  const BoardSignatoryAccessConstraint({super.key});

  @override
  State<BoardSignatoryAccessConstraint> createState() =>
      _BoardSignatoryAccessConstraintState();
}

class _BoardSignatoryAccessConstraintState
    extends State<BoardSignatoryAccessConstraint> {
  // Requirement 2: Security State Variable
  bool _isAuthorizedSignatory = true;

  // Requirement 4: High-Contrast Status Variable
  bool _isPendingSignature = true;

  int _approvalCount = 3;
  final int _requiredCount = 5;

  void _handleApproveResolution() {
    setState(() {
      _approvalCount++;
      if (_approvalCount >= _requiredCount) {
        _isPendingSignature = false;
      }
    });

    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: colorScheme.onPrimary),
            const SizedBox(width: 8.0),
            Text(
              'Resolution Approved! Vote Count: $_approvalCount / $_requiredCount',
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openCodeExportModal() {
    final specData = ComponentCodeRegistry.getCodeSpec(
      globalRefId: 'IRBCA-061',
      title: 'Board Signatory Access Constraint',
      category: 'Workspaces & Sandbox',
    );
    CodeExportModalDialog.show(
      context: context,
      globalRefId: 'IRBCA-061',
      title: 'Board Signatory Access Constraint',
      fileName: specData['fileName']!,
      widgetClassName: specData['widgetClassName']!,
      category: 'Workspaces & Sandbox',
      sourceCode: specData['sourceCode']!,
      integrationGuide: '''// -------------------------------------------------------------
// INTEGRATION GUIDE: [IRBCA-061] Board Signatory Access Constraint
// -------------------------------------------------------------

1. File Setup:
   Create lib/ui/${specData['fileName']} in your target Flutter application.

2. Dependencies:
   Ensure useMaterial3: true is set in your ThemeData.

3. Import & Usage:
   import 'package:your_app/ui/${specData['fileName']}';

   @override
   Widget build(BuildContext context) {
     return const ${specData['widgetClassName']}();
   }

4. Responsiveness & Security Rules:
   - Mobile View (<=600dp): Renders standard FloatingActionButton at endFloat.
   - Tablet/Web View (>600dp): Renders FloatingActionButton.extended with label "Approve Resolution".
   - Poka-Yoke Security: FAB is completely eradicated from DOM tree if isAuthorizedSignatory is false.
''',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktopWebTablet = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('[IRBCA-061] Board Signatory Access Constraint'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.code),
                tooltip: 'Export Code & Integration Guide',
                onPressed: _openCodeExportModal,
              ),
            ],
          ),

          // Requirement 2: Strict DOM Eradication via ternary check
          // If unauthorized, const SizedBox.shrink() completely eradicates FAB from widget tree
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: _isAuthorizedSignatory
              ? (isDesktopWebTablet
                  ? FloatingActionButton.extended(
                      onPressed: _isPendingSignature ? _handleApproveResolution : null,
                      icon: const Icon(Icons.draw),
                      label: const Text(
                        'Approve Resolution',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    )
                  : FloatingActionButton(
                      onPressed: _isPendingSignature ? _handleApproveResolution : null,
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      tooltip: 'Approve Resolution',
                      child: const Icon(Icons.draw),
                    ))
              : const SizedBox.shrink(), // Complete DOM eradication

          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktopWebTablet ? 32.0 : 16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Control Panel Card (Toggle state switches)
                    Card(
                      elevation: 1,
                      color: theme.colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interactive Security & Signatory Simulator',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 16.0,
                              runSpacing: 8.0,
                              children: [
                                FilterChip(
                                  selected: _isAuthorizedSignatory,
                                  onSelected: (val) {
                                    setState(() {
                                      _isAuthorizedSignatory = val;
                                    });
                                  },
                                  avatar: Icon(
                                    _isAuthorizedSignatory
                                        ? Icons.verified_user
                                        : Icons.gpp_bad,
                                    size: 18.0,
                                  ),
                                  label: Text(
                                    _isAuthorizedSignatory
                                        ? 'Authorized Signatory (FAB Visible)'
                                        : 'Unauthorized Role (DOM Eradicated)',
                                  ),
                                ),
                                FilterChip(
                                  selected: _isPendingSignature,
                                  onSelected: (val) {
                                    setState(() {
                                      _isPendingSignature = val;
                                      if (val && _approvalCount >= _requiredCount) {
                                        _approvalCount = 3;
                                      }
                                    });
                                  },
                                  avatar: Icon(
                                    _isPendingSignature
                                        ? Icons.pending_actions
                                        : Icons.check_circle,
                                    size: 18.0,
                                  ),
                                  label: Text(
                                    _isPendingSignature
                                        ? 'Status: PENDING SIGNATURE'
                                        : 'Status: APPROVED & SIGNED',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Requirement 4: High-Contrast Status Banner Header
                    _buildStatusBannerHeader(theme),
                    const SizedBox(height: 20.0),

                    // Document Card with High-Density Typography
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                                  child: const Icon(Icons.gavel),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Board Resolution #2026-89A',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Enterprise Capital Expenditure Approval Protocol',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32.0),

                            // Requirement 3: High-Density Typography text block
                            Text(
                              'WHEREAS, the Board of Directors has reviewed the capital expenditure plan for fiscal Q3 2026 under governance directive NIST-SP-800;\n'
                              'NOW THEREFORE BE IT RESOLVED, that the executive signatories hereby authorize the allocation of \$4,500,000 USD towards distributed Cloud Security infrastructure subject to strict quorum confirmation.',
                              style: TextStyle(
                                fontSize: 14.0,
                                height: 1.2, // High-density tight line height
                                letterSpacing: -0.2, // Tightened letter spacing
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 20.0),

                            // Quorum Metrics Progress
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Signatory Quorum Progress:',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$_approvalCount / $_requiredCount Votes',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            LinearProgressIndicator(
                              value: _approvalCount / _requiredCount,
                              minHeight: 8.0,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Requirement 4: High-Contrast Document Status Header
  Widget _buildStatusBannerHeader(ThemeData theme) {
    if (_isPendingSignature) {
      // High-contrast Tertiary Container mapping for Pending State
      final bg = theme.colorScheme.tertiaryContainer;
      final fg = theme.colorScheme.onTertiaryContainer;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: theme.colorScheme.tertiary, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_top, color: fg, size: 28.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOCUMENT STATUS: PENDING SIGNATURE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: fg,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Awaiting final board member authorization. High-contrast security lock active.',
                    style: TextStyle(fontSize: 12.0, color: fg),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // High-contrast Primary Container mapping for Approved State
      final bg = theme.colorScheme.primaryContainer;
      final fg = theme.colorScheme.onPrimaryContainer;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.verified, color: fg, size: 28.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOCUMENT STATUS: APPROVED & SIGNED',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: fg,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Quorum reached. Resolution fully executed and locked.',
                    style: TextStyle(fontSize: 12.0, color: fg),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
