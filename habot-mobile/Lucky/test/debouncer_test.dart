import 'package:test/test.dart';
import 'package:habot_lucky/core/utils/debouncer.dart';

// VPVMP-021-13 — Unit test: rapid sequential keystrokes.
// Spec: ISO/IEC/IEEE 29119 — debounce fires once after typing stops.
//
// Run: dart test test/debouncer_test.dart

void main() {
  group('Debouncer — rapid keystrokes', () {
    test('fires once after burst of 20 calls', () async {
      final debouncer = Debouncer(
        delay: const Duration(milliseconds: 100),
      );
      var callCount = 0;

      for (var i = 0; i < 20; i++) {
        debouncer.run(() => callCount++);
      }

      expect(callCount, 0);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(callCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(callCount, 1);
    });

    test('cancels pending callback on cancel()', () async {
      final debouncer = Debouncer(
        delay: const Duration(milliseconds: 100),
      );
      var fired = false;

      debouncer.run(() => fired = true);
      debouncer.cancel();

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(fired, false);
    });

    test('input vs auto-save durations match spec', () {
      expect(DebounceDuration.input, const Duration(milliseconds: 300));
      expect(DebounceDuration.autoSave, const Duration(milliseconds: 800));
    });

    test('rapid keystrokes on separate debouncers stay independent', () async {
      final input = Debouncer(delay: const Duration(milliseconds: 80));
      final save  = Debouncer(delay: const Duration(milliseconds: 120));

      var inputCount = 0;
      var saveCount  = 0;

      for (var i = 0; i < 15; i++) {
        input.run(() => inputCount++);
        save.run(() => saveCount++);
      }

      await Future<void>.delayed(const Duration(milliseconds: 90));
      expect(inputCount, 1);
      expect(saveCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(saveCount, 1);
    });
  });
}
