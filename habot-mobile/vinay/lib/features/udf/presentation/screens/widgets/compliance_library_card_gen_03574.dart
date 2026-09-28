// GEN-03574 — Central Compliance Library UI with binary rule check_compliance() functions.
// Implements M3 Elevated Card (Level 2, 3dp), Status Chips, single-column mobile layout, background polling every 30s, and pull-to-refresh for the engineering console dashboard.

import 'dart:async';
import 'package:flutter/material.dart';

/// Binary rule function simulating compliance check.
/// Returns true if test coverage meets or exceeds the floor threshold of 0.95.
bool checkCompliance(double testCoverage) {
  const double floorThreshold = 0.95;
  return testCoverage >= floorThreshold;
}

/// Mock data model representing a compliance rule in the Central Compliance Library.
class ComplianceRule {
  final String id;
  final String name;
  final double testCoverage;
  final DateTime lastChecked;

  const ComplianceRule({
    required this.id,
    required this.name,
    required this.testCoverage,
    required this.lastChecked,
  });
}

/// Mock repository providing local dummy data as per backend/mock data rule.
class MockComplianceRepository {
  static List<ComplianceRule> fetchRules() {
    return [
      ComplianceRule(
        id: 'RULE-001',
        name: 'Binary Rule Library Test Coverage',
        testCoverage: 0.98,
        lastChecked: DateTime.now(),
      ),
      ComplianceRule(
        id: 'RULE-002',
        name: 'IEEE 829 Software Test Docs Validation',
        testCoverage: 0.92,
        lastChecked: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ComplianceRule(
        id: 'RULE-003',
        name: 'CI/CD Pipeline Gate Check',
        testCoverage: 1.0,
        lastChecked: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }
}

/// Main widget implementing the M3 responsive layout for the compliance library.
/// Single-column on mobile (<600dp), multi-column on desktop (>=840dp).
/// Includes background polling every 30 seconds and pull-to-refresh.
class ComplianceLibraryCardGen03574 extends StatefulWidget {
  const ComplianceLibraryCardGen03574({super.key});

  @override
  State<ComplianceLibraryCardGen03574> createState() => _ComplianceLibraryCardGen03574State();
}

class _ComplianceLibraryCardGen03574State extends State<ComplianceLibraryCardGen03574> {
  late List<ComplianceRule> _rules;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _rules = MockComplianceRepository.fetchRules();
    // Automated Liveness Handshake / Background polling every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (!mounted || _isRefreshing) return;
    setState(() => _isRefreshing = true);
    
    // Simulate network delay for mock data fetch
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (mounted) {
      setState(() {
        _rules = MockComplianceRepository.fetchRules();
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Engineering Console - Compliance'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: colorScheme.primary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
            final bool isDesktop = constraints.maxWidth >= 840;
            final int crossAxisCount = isDesktop ? 2 : 1;

            if (_isRefreshing && _rules.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: isDesktop ? 2.5 : 3.0,
              ),
              itemCount: _rules.length,
              itemBuilder: (context, index) {
                final rule = _rules[index];
                final bool isPassing = checkCompliance(rule.testCoverage);
                return _buildM3ElevatedCard(rule, isPassing, colorScheme, textTheme);
              },
            );
          },
        ),
      ),
    );
  }

  /// Builds an M3 Elevated Card Level 2 (3dp) with inline status chip.
  /// Touch targets are minimum 48x48dp.
  Widget _buildM3ElevatedCard(
    ComplianceRule rule,
    bool isPassing,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // M3 Snackbar for confirmations / deep-link drill-down simulation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drilling down into ${rule.name}...'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      rule.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // M3 Status Chips for health indicators
                  _buildStatusChip(isPassing, colorScheme),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Coverage',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${(rule.testCoverage * 100).toStringAsFixed(1)}%',
                        style: textTheme.headlineSmall?.copyWith(
                          color: isPassing ? colorScheme.primary : colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Result',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        isPassing ? 'Pass' : 'Fail',
                        style: textTheme.titleMedium?.copyWith(
                          color: isPassing ? colorScheme.primary : colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Ensure 48x48dp touch target for any interactive elements if added later
              SizedBox(
                height: 48.0,
                width: 48.0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 24.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// M3 Status Chip implementation for Pass/Fail health indicators.
  Widget _buildStatusChip(bool isPassing, ColorScheme colorScheme) {
    return Chip(
      label: Text(
        isPassing ? 'PASS' : 'FAIL',
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: isPassing ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
        ),
      ),
      backgroundColor: isPassing ? colorScheme.primaryContainer : colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}
