import 'package:flutter/material.dart';

/// Unique styling tokens for the Touch Target Constraint Test Console.
abstract final class TargetConstraintTestTokens {
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Status colors
  static const Color testPass = Color(0xFF16A34A);
  static const Color testPassBg = Color(0xFFDCFCE7);
  static const Color testFail = Color(0xFFDC2626);
  static const Color testFailBg = Color(0xFFFEE2E2);

  static const Color brandPrimary = Color(0xFF2563EB);
  static const double minBaselineTarget = 48.0;
}

/// Representation of a button target assertion test case.
class TargetTestCase {
  final String testName;
  final String targetIdentifier;
  double width;
  double height;
  bool isExecuted;
  bool hasFailed;
  String? assertionError;

  TargetTestCase({
    required this.testName,
    required this.targetIdentifier,
    required this.width,
    required this.height,
    this.isExecuted = false,
    this.hasFailed = false,
    this.assertionError,
  });
}

/// Automated UI test runner enforcing instant failure if any button measures <48x48dp.
class TouchTargetConstraintTestConsole extends StatefulWidget {
  final void Function(bool passed, int totalTests, int failedTests)? onSuiteExecuted;

  const TouchTargetConstraintTestConsole({
    super.key,
    this.onSuiteExecuted,
  });

  @override
  State<TouchTargetConstraintTestConsole> createState() =>
      _TouchTargetConstraintTestConsoleState();
}

class _TouchTargetConstraintTestConsoleState extends State<TouchTargetConstraintTestConsole> {
  bool _failInstantlyOnViolation = true;
  bool _isTestRunning = false;
  late List<TargetTestCase> _testCases;

  @override
  void initState() {
    super.initState();
    _resetTests();
  }

  void _resetTests() {
    _testCases = [
      TargetTestCase(
        testName: 'test_primary_checkout_touch_bounds',
        targetIdentifier: 'CheckoutElevatedButton',
        width: 320.0,
        height: 52.0,
      ),
      TargetTestCase(
        testName: 'test_cart_icon_button_touch_bounds',
        targetIdentifier: 'CartIconButton',
        width: 48.0,
        height: 48.0,
      ),
      TargetTestCase(
        testName: 'test_legacy_close_pill_touch_bounds',
        targetIdentifier: 'LegacyClosePillButton',
        width: 42.0,
        height: 32.0, // Violation of 48x48dp
      ),
      TargetTestCase(
        testName: 'test_category_filter_chip_touch_bounds',
        targetIdentifier: 'CategoryFilterChip',
        width: 88.0,
        height: 48.0,
      ),
    ];
  }

  void _runTestSuite() async {
    setState(() {
      _isTestRunning = true;
      for (final test in _testCases) {
        test.isExecuted = false;
        test.hasFailed = false;
        test.assertionError = null;
      }
    });

    int failedCount = 0;

    for (int i = 0; i < _testCases.length; i++) {
      final test = _testCases[i];
      test.isExecuted = true;

      if (test.width < TargetConstraintTestTokens.minBaselineTarget ||
          test.height < TargetConstraintTestTokens.minBaselineTarget) {
        test.hasFailed = true;
        test.assertionError =
            'AssertionError: [FAIL-FAST] Target \'${test.targetIdentifier}\' bounds '
            '(${test.width}x${test.height}dp) < baseline '
            '(${TargetConstraintTestTokens.minBaselineTarget}x${TargetConstraintTestTokens.minBaselineTarget}dp). '
            'CI/CD Gate Blocked.';
        failedCount++;

        if (_failInstantlyOnViolation) {
          // Instant halt of execution pipeline
          break;
        }
      }
    }

    setState(() {
      _isTestRunning = false;
    });

    widget.onSuiteExecuted?.call(failedCount == 0, _testCases.length, failedCount);
  }

  void _remediateLegacyButton() {
    setState(() {
      final legacy = _testCases.firstWhere((t) => t.targetIdentifier == 'LegacyClosePillButton');
      legacy.width = 48.0;
      legacy.height = 48.0;
      legacy.hasFailed = false;
      legacy.assertionError = null;
    });
    _runTestSuite();
  }

  @override
  Widget build(BuildContext context) {
    final hasRun = _testCases.any((t) => t.isExecuted);
    final anyFailures = _testCases.any((t) => t.hasFailed);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: TargetConstraintTestTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: TargetConstraintTestTokens.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TargetConstraintTestTokens.brandPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flaky_rounded,
                  color: TargetConstraintTestTokens.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UI Touch Test Gate (Instant Fail)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TargetConstraintTestTokens.textDark,
                      ),
                    ),
                    Text(
                      'Automated Fail-Fast Gate for <48x48dp Buttons',
                      style: TextStyle(
                        fontSize: 12,
                        color: TargetConstraintTestTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: !hasRun
                      ? TargetConstraintTestTokens.backgroundLight
                      : (anyFailures
                          ? TargetConstraintTestTokens.testFailBg
                          : TargetConstraintTestTokens.testPassBg),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  !hasRun
                      ? 'READY'
                      : (anyFailures ? 'GATE BLOCKED' : 'PASS 100%'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: !hasRun
                        ? TargetConstraintTestTokens.textMuted
                        : (anyFailures
                            ? TargetConstraintTestTokens.testFail
                            : TargetConstraintTestTokens.testPass),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Configuration Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: TargetConstraintTestTokens.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TargetConstraintTestTokens.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Fail instantly on first <48x48dp violation',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TargetConstraintTestTokens.textDark,
                    ),
                  ),
                ),
                Switch(
                  value: _failInstantlyOnViolation,
                  onChanged: (val) => setState(() => _failInstantlyOnViolation = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Test Cases List
          Column(
            children: _testCases.map((test) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: test.hasFailed
                      ? TargetConstraintTestTokens.testFailBg.withAlpha(120)
                      : TargetConstraintTestTokens.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: test.hasFailed
                        ? TargetConstraintTestTokens.testFail
                        : TargetConstraintTestTokens.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          !test.isExecuted
                              ? Icons.radio_button_unchecked_rounded
                              : (test.hasFailed
                                  ? Icons.cancel_rounded
                                  : Icons.check_circle_rounded),
                          size: 16,
                          color: !test.isExecuted
                              ? TargetConstraintTestTokens.textMuted
                              : (test.hasFailed
                                  ? TargetConstraintTestTokens.testFail
                                  : TargetConstraintTestTokens.testPass),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            test.testName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              color: TargetConstraintTestTokens.textDark,
                            ),
                          ),
                        ),
                        Text(
                          '${test.width.toInt()}x${test.height.toInt()} dp',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: (test.width < 48 || test.height < 48)
                                ? TargetConstraintTestTokens.testFail
                                : TargetConstraintTestTokens.testPass,
                          ),
                        ),
                      ],
                    ),
                    if (test.assertionError != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: TargetConstraintTestTokens.testFail.withAlpha(60)),
                        ),
                        child: Text(
                          test.assertionError!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: TargetConstraintTestTokens.testFail,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isTestRunning ? null : _runTestSuite,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Execute UI Test Suite'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TargetConstraintTestTokens.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _remediateLegacyButton,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                child: const Text('Fix & Re-Test'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: TouchTargetConstraintTestConsole(),
          ),
        ),
      ),
    ),
  );
}
