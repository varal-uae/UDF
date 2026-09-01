/// COMPLIANCE METADATA BLOCK
/// - Step Execution ID: AMLCO-014-SEC-2026
/// - Execution Status: Active / Authenticated Flow
/// - Execution Timestamp: 2026-08-18T10:10:00Z
/// - Step Outcome: Biometric Auth & Token Refresh Gate Validated
/// - User ID: AML-OFFICER-7712
/// - Specification Scoping Completeness Rate: Target: Complete - 100% parsed & documented per ISO 9001:2015
library;

import 'package:flutter/material.dart';

/// Simulated Token & Biometric Auth Service enforcing silent background refresh on 401.
class MockAuthService {
  static bool hasValidToken = false;
  static bool refreshTokenExpired = true; // Simulates expired refresh token requiring biometric fallback

  /// Simulates an API query that returns 401 Unauthorized, triggering silent refresh logic.
  static Future<bool> executeAmlQueryWithTokenValidation({
    required Function() onSilentRefreshFailedTriggerBiometrics,
  }) async {
    // Simulate 401 Unauthorized API response
    if (!hasValidToken) {
      // Attempt silent background token refresh first
      final bool silentSuccess = await _attemptSilentTokenRefresh();
      if (silentSuccess) {
        hasValidToken = true;
        return true;
      } else {
        // Silent refresh failed -> Trigger biometric prompt rather than blocking error modal
        onSilentRefreshFailedTriggerBiometrics();
        return false;
      }
    }
    return true;
  }

  static Future<bool> _attemptSilentTokenRefresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // If refresh token is not expired, silently refresh token
    if (!refreshTokenExpired) {
      return true;
    }
    return false; // Silent refresh failed
  }

  static Future<bool> authenticateWithBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 600));
    hasValidToken = true;
    return true;
  }
}

/// Data model for AML Query Gate items.
class AmlQueryRecord {
  final String entityId;
  final String entityName;
  final String riskScore;
  final String matchStatus;
  final List<String> tags;

  const AmlQueryRecord({
    required this.entityId,
    required this.entityName,
    required this.riskScore,
    required this.matchStatus,
    required this.tags,
  });
}

/// AMLCO-014: AML Query Gate & Secure Auth Flow
class AmlQueryGateView extends StatefulWidget {
  const AmlQueryGateView({super.key});

  @override
  State<AmlQueryGateView> createState() => _AmlQueryGateViewState();
}

class _AmlQueryGateViewState extends State<AmlQueryGateView> {
  bool _isAuthenticated = false;
  bool _keepMeLoggedIn = true;
  bool _isAuthenticating = false;

  final TextEditingController _usernameController =
      TextEditingController(text: 'aml.officer@bank.sec');
  final TextEditingController _passwordController =
      TextEditingController(text: '••••••••••••');

  final List<AmlQueryRecord> _queryRecords = const [
    AmlQueryRecord(
      entityId: 'AML-ENT-8821',
      entityName: 'Apex Zenith Global Ltd',
      riskScore: '0.04 (LOW)',
      matchStatus: 'CLEARED',
      tags: ['Reputation Check', 'GACL Cleared', 'PEP Screened', 'OFAC Pass'],
    ),
    AmlQueryRecord(
      entityId: 'AML-ENT-9912',
      entityName: 'Vanguard Logistics Corp',
      riskScore: '0.12 (LOW)',
      matchStatus: 'CLEARED',
      tags: ['Reputation Check', 'GACL Cleared', 'Sanction Clean'],
    ),
    AmlQueryRecord(
      entityId: 'AML-ENT-3304',
      entityName: 'Hyperion Energy Traders',
      riskScore: '0.78 (HIGH)',
      matchStatus: 'REVIEW_NEEDED',
      tags: ['PEP Flagged', 'Secondary Review', 'OFAC Audit'],
    ),
    AmlQueryRecord(
      entityId: 'AML-ENT-4491',
      entityName: 'Solaris Offshore Holdings',
      riskScore: '0.01 (LOW)',
      matchStatus: 'CLEARED',
      tags: ['Reputation Check', 'GACL Cleared', 'ISO 9001 Valid'],
    ),
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLoginSubmit() async {
    setState(() => _isAuthenticating = true);
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate 401 and attempt silent refresh, falling back to biometrics
    final success = await MockAuthService.executeAmlQueryWithTokenValidation(
      onSilentRefreshFailedTriggerBiometrics: () {
        _triggerBiometricPrompt();
      },
    );

    if (success) {
      setState(() {
        _isAuthenticated = true;
        _isAuthenticating = false;
      });
    } else {
      setState(() => _isAuthenticating = false);
    }
  }

  void _triggerBiometricPrompt() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('401 Unauthorized: Silent refresh failed. Prompting Biometric Auth...'),
        duration: Duration(seconds: 2),
      ),
    );

    final bioSuccess = await MockAuthService.authenticateWithBiometrics();
    if (bioSuccess) {
      setState(() {
        _isAuthenticated = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Biometric Authentication Successful! AML Gate Unlocked.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAuthenticated ? 'AML Query Gate Dashboard' : 'Secure AML Login'),
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Lock Session',
              onPressed: () {
                setState(() {
                  _isAuthenticated = false;
                  MockAuthService.hasValidToken = false;
                });
              },
            ),
        ],
      ),
      body: _isAuthenticated ? _buildDashboardView() : _buildLoginView(),
    );
  }

  /// Widget requirement 2: Login UI & Oversized Toggles
  Widget _buildLoginView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.security,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AML Query Auth Gate',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ISO 9001 Enforced Biometric & Token Validation',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Official Officer Email',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Authentication Key / Token',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Requirement 2: SwitchListTile with Transform.scale(scale: 1.3) for oversized toggle
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Keep me logged in',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Transform.scale(
                          scale: 1.3, // Oversized toggle switch for rapid touch interaction
                          child: Switch(
                            value: _keepMeLoggedIn,
                            onChanged: (val) {
                              setState(() => _keepMeLoggedIn = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isAuthenticating ? null : _handleLoginSubmit,
                      icon: _isAuthenticating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        _isAuthenticating ? 'VERIFYING TOKEN...' : 'AUTHENTICATE & ENTER',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _triggerBiometricPrompt,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('BYPASS WITH BIOMETRICS'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget requirement 3 & 4: Query Gate Dashboard with M3 Chips & Outline Accents & LayoutBuilder
  Widget _buildDashboardView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.verified_user, color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AML QUERY GATE ACTIVE',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Token refreshed • Biometric identity verified • ISO 9001 Scoped',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth <= 600;

                if (isMobile) {
                  // Mobile: Compact single-column vertical layout
                  return ListView.builder(
                    itemCount: _queryRecords.length,
                    itemBuilder: (context, index) {
                      return _buildOutlinedAmlCard(_queryRecords[index], colorScheme, theme);
                    },
                  );
                } else {
                  // Tablet/Web: Multi-column outlined-card grid
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _queryRecords.length,
                    itemBuilder: (context, index) {
                      return _buildOutlinedAmlCard(_queryRecords[index], colorScheme, theme);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedAmlCard(
    AmlQueryRecord record,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final isCleared = record.matchStatus == 'CLEARED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      // Clean outline accent mapping layout boundaries clearly
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCleared
              ? colorScheme.outline.withValues(alpha: 0.5)
              : colorScheme.tertiary,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.entityId,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Chip(
                  label: Text(
                    record.matchStatus,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: isCleared ? colorScheme.primaryContainer : colorScheme.tertiaryContainer,
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              record.entityName,
              style: theme.textTheme.titleMedium?.copyWith(
                 fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Force highly visible typography for main data point using headlineMedium
            Row(
              children: [
                Text(
                  'Risk Score: ',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  record.riskScore,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isCleared ? colorScheme.primary : colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Summary text metadata elements using Chip or RawChip
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: record.tags.map((tag) {
                return RawChip(
                  label: Text(tag, style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
