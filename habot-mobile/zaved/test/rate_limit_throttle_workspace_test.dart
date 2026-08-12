import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/device_metadata_service.dart';
import 'package:flutter_application_1/services/rate_limit_interceptor.dart';
import 'package:flutter_application_1/ui/rate_limit_throttle_workspace.dart';

void main() {
  Widget buildTestApp() {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RateLimitThrottleWorkspace(),
    );
  }

  group('Device Metadata Payload Service Unit Tests', () {
    test('Requirement 1: DeviceMetadataService collects platform, OS version, model & screen dimensions', () {
      final metadata = DeviceMetadataService.collectMetadata();

      expect(metadata.platform, isNotEmpty);
      expect(metadata.osVersion, isNotEmpty);
      expect(metadata.deviceModel, isNotEmpty);
      expect(metadata.screenDimensions, isNotEmpty);

      final headers = metadata.toHeaders();
      expect(headers, contains('X-Client-OS'));
      expect(headers, contains('X-Client-Device'));
      expect(headers, contains('X-Client-Screen'));
      expect(headers, contains('X-Client-Metadata'));
    });
  });

  group('Rate Limit Interceptor & Poka-Yoke Widget Tests', () {
    test('Requirement 2: RateLimitInterceptor catches HTTP 429 and parses Retry-After header', () async {
      int? caughtCooldown;
      final interceptor = RateLimitInterceptor(
        onRateLimitTriggered: (cooldown, retryAction) {
          caughtCooldown = cooldown;
        },
      );

      const mockResponse = ApiResponse(
        statusCode: 429,
        body: '{"error": "Too Many Requests"}',
        headers: {'Retry-After': '6'},
      );

      expect(
        () => interceptor.interceptResponse(mockResponse, requestCall: () async => mockResponse),
        throwsA(isA<RateLimitException>()),
      );

      expect(caughtCooldown, equals(6));
    });

    testWidgets('Requirement 3: HTTP 429 triggers Poka-Yoke Modal with exact text & countdown timer',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      // Verify metadata panel is rendered
      expect(find.text('Device Metadata Payload (Header Injection)'), findsOneWidget);

      // Tap trigger 429 button
      final trigger429Button = find.widgetWithText(FilledButton, 'Trigger HTTP 429 Rate Limit (Poka-Yoke Modal)');
      expect(trigger429Button, findsOneWidget);
      await tester.tap(trigger429Button);
      await tester.pump(); // Start request

      // Wait for request execution (800ms delay)
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // Verify Modal Bottom Sheet is triggered with exact required text
      expect(find.text('Whoa, slow down! Please wait a moment.'), findsOneWidget);

      // Verify countdown timer text
      expect(find.textContaining('Automated Retry in'), findsOneWidget);

      // Wait for cooldown timer to count down and execute automated retry
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify modal dismisses upon cooldown completion and retry succeeds
      expect(find.text('Whoa, slow down! Please wait a moment.'), findsNothing);
      expect(find.text('HTTP 200 OK: API Gateway response received successfully.'), findsOneWidget);
    });
  });
}
