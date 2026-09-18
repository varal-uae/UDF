// GEN-01556 — Card Number Form Entry Validation Test Suite.
// Tests form entry validation against valid and invalid card number datasets using Luhn algorithm with PCI-DSS compliance mock data.

import 'package:flutter_test/flutter_test.dart';

/// Mock PCI-DSS v4.0 compliant card validation utility for testing.
class CardValidationUtilsGen01556 {
  /// Validates a card number using the Luhn algorithm.
  static bool isValidCardNumber(String cardNumber) {
    final sanitized = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (sanitized.isEmpty || !RegExp(r'^\d+$').hasMatch(sanitized)) {
      return false;
    }
    if (sanitized.length < 13 || sanitized.length > 19) {
      return false;
    }

    int sum = 0;
    bool alternate = false;
    for (int i = sanitized.length - 1; i >= 0; i--) {
      int n = int.parse(sanitized[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}

/// Mock dataset representing PCI-DSS Field Tokenization Compliance test entries.
class MockCardDatasetGen01556 {
  static const List<Map<String, dynamic>> validCards = [
    {'cardNumber': '4111111111111111', 'label': 'Visa Test 1', 'expected': 'Pass'},
    {'cardNumber': '5500000000000004', 'label': 'Mastercard Test 1', 'expected': 'Pass'},
    {'cardNumber': '340000000000009', 'label': 'Amex Test 1', 'expected': 'Pass'},
    {'cardNumber': '6011000000000004', 'label': 'Discover Test 1', 'expected': 'Pass'},
    {'cardNumber': '4111 1111 1111 1111', 'label': 'Visa Spaced Test', 'expected': 'Pass'},
  ];

  static const List<Map<String, dynamic>> invalidCards = [
    {'cardNumber': '4111111111111112', 'label': 'Invalid Luhn', 'expected': 'Fail'},
    {'cardNumber': '1234567890123456', 'label': 'Random Digits', 'expected': 'Fail'},
    {'cardNumber': 'abcd1234efgh5678', 'label': 'Alphanumeric', 'expected': 'Fail'},
    {'cardNumber': '', 'label': 'Empty String', 'expected': 'Fail'},
    {'cardNumber': '411', 'label': 'Too Short', 'expected': 'Fail'},
    {'cardNumber': '411111111111111111111111111111', 'label': 'Too Long', 'expected': 'Fail'},
  ];
}

void main() {
  group('GEN-01556: Form Entry Validation Against Card Number Datasets', () {
    group('Valid Card Numbers (PCI-DSS Pass)', () {
      for (final testCase in MockCardDatasetGen01556.validCards) {
        test('Should pass validation for ${testCase['label']}', () {
          final result = CardValidationUtilsGen01556.isValidCardNumber(
            testCase['cardNumber'] as String,
          );
          expect(result, isTrue, reason: 'Expected Pass for ${testCase['cardNumber']}');
        });
      }
    });

    group('Invalid Card Numbers (PCI-DSS Fail)', () {
      for (final testCase in MockCardDatasetGen01556.invalidCards) {
        test('Should fail validation for ${testCase['label']}', () {
          final result = CardValidationUtilsGen01556.isValidCardNumber(
            testCase['cardNumber'] as String,
          );
          expect(result, isFalse, reason: 'Expected Fail for ${testCase['cardNumber']}');
        });
      }
    });

    test('Completion Measure: 100% CI/CD pass rate on validation checks', () {
      int totalTests = MockCardDatasetGen01556.validCards.length +
          MockCardDatasetGen01556.invalidCards.length;
      int passedTests = 0;

      for (final tc in MockCardDatasetGen01556.validCards) {
        if (CardValidationUtilsGen01556.isValidCardNumber(tc['cardNumber'] as String)) {
          passedTests++;
        }
      }
      for (final tc in MockCardDatasetGen01556.invalidCards) {
        if (!CardValidationUtilsGen01556.isValidCardNumber(tc['cardNumber'] as String)) {
          passedTests++;
        }
      }

      expect(passedTests, equals(totalTests),
          reason: 'All validation checks must pass for PCI-DSS Field Tokenization Compliance.');
    });
  });
}