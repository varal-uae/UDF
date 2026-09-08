/// AISS GATE -- Step 114 of 115
/// Global Reference ID:       GEN-04119
/// Atomic Steps Reference ID: GEN-04119-A01
/// Setup Step (Action):       "Store fetched SDUI layout JSON files in
///                             client-side encrypted local storage."
/// Metric: Encrypted Storage Synchronization -- every band 1.0.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// TWO THINGS RECORDED BEFORE ANY ASSERTION:
///   1. SDUI is NOT APPLICABLE -- this app has no server-driven UI layer. The
///      encrypted-storage half is real and is built; the SDUI half is recorded
///      rather than invented.
///   2. NO CIPHER SHIPS IN lib/. Real device-bound encryption needs a platform
///      keystore this environment cannot resolve, and a hand-rolled cipher is
///      worse than none because it looks like encryption in a review. The
///      obviously-fake cipher below lives HERE, in the test, and says so in
///      its own name.
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/encrypted_store.dart';
import 'package:udf_setup/design_system/data/local_store.dart';

import 'aiss_reporter.dart';

/// NOT ENCRYPTION. A reversible byte rotation, used only to prove that bytes
/// pass through the cipher and come back. Its `isProductionGrade` is false,
/// and `assertProductionReady` throws on it -- which is itself gated below.
class _NotSecureRotationCipher implements HabotCipher {
  const _NotSecureRotationCipher({this.shift = 37, this.brokenKey = false});

  final int shift;

  /// Simulates a rotated or wrong key: decrypt returns null.
  final bool brokenKey;

  @override
  String get algorithmName => 'byte-rotation (NOT SECURE -- test only)';

  @override
  bool get isProductionGrade => false;

  @override
  Uint8List encrypt(Uint8List plaintext) => Uint8List.fromList(
    plaintext.map((int b) => (b + shift) & 0xFF).toList(),
  );

  @override
  Uint8List? decrypt(Uint8List ciphertext) => brokenKey
      ? null
      : Uint8List.fromList(
          ciphertext.map((int b) => (b - shift) & 0xFF).toList(),
        );
}

/// A cipher that does nothing at all -- the stub someone leaves in.
class _IdentityCipher implements HabotCipher {
  const _IdentityCipher();

  @override
  String get algorithmName => 'identity (a stub)';

  @override
  bool get isProductionGrade => false;

  @override
  Uint8List encrypt(Uint8List plaintext) => plaintext;

  @override
  Uint8List? decrypt(Uint8List ciphertext) => ciphertext;
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  const HabotCollection jobs = HabotCollection('jobs');
  late HabotMemoryStore inner;
  late HabotEncryptedStore store;

  void gate(
    String id,
    String source,
    String description,
    Future<bool> Function() run,
  ) {
    test('[$id] $description', () async {
      bool passed = false;
      try {
        passed = await run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  setUp(() {
    inner = HabotMemoryStore();
    store = HabotEncryptedStore(
      inner: inner,
      cipher: const _NotSecureRotationCipher(),
    );
  });

  Uint8List plain(String s) =>
      HabotRecordCodec.encode(<String, Object?>{'note': s});

  group('GEN-04119-A01 :: nothing reaches the device in the clear', () {
    gate(
      'GEN-04119-G1',
      'Metric: every band is 1.0 -- every persisted payload encrypted, or the '
          'step fails.',
      'What lands in the underlying store is not the plaintext, carries the '
          'format header, and comes back identical through the cipher; the '
          'encrypted share of the collection is exactly 1.0',
      () async {
        final Uint8List p = plain('a signed delivery note');
        await store.write(jobs, 'J1', p);
        final Uint8List raw = (await inner.read(jobs, 'J1'))!;
        final Uint8List back = (await store.read(jobs, 'J1'))!;
        return !_sameBytes(raw, p) &&
            HabotEncryptedStore.hasHeader(raw) &&
            HabotEncryptedStore.versionOf(raw) ==
                HabotEncryptedStore.formatVersion &&
            _sameBytes(back, p) &&
            await store.encryptedShare(jobs) == 1.0 &&
            store.plaintextWritesAttempted == 0;
      },
    );

    gate(
      'GEN-04119-G2',
      'A cipher that returns its input is either a stub left in or a '
          'misconfiguration. Either way the write must not happen.',
      'A no-op cipher is caught at write time and the record is refused, with '
          'the attempt counted rather than passing silently',
      () async {
        final HabotEncryptedStore stub = HabotEncryptedStore(
          inner: HabotMemoryStore(),
          cipher: const _IdentityCipher(),
        );
        bool threw = false;
        try {
          await stub.write(jobs, 'J1', plain('anything'));
        } on StateError catch (e) {
          threw = e.message.contains('not encryption');
        }
        return threw &&
            stub.plaintextWritesAttempted == 1 &&
            await stub.encryptedShare(jobs) == 1.0;
      },
    );

    gate(
      'GEN-04119-G3',
      'A build that reaches production with a stub cipher is a build that '
          'thinks it is encrypted and is not.',
      'The store requires a cipher at construction -- there is no default -- '
          'and a cipher that declares itself non-production makes the '
          'readiness check throw with the algorithm named',
      () async {
        bool threw = false;
        try {
          store.assertProductionReady();
        } on StateError catch (e) {
          threw = e.message.contains('NOT SECURE') &&
              e.message.contains('platform keystore');
        }
        return threw &&
            !store.cipher.isProductionGrade &&
            store.engineName.contains('NOT durable') &&
            store.engineName.contains('NOT SECURE');
      },
    );
  });

  group('GEN-04119-A01 :: a refusal is not an absence', () {
    gate(
      'GEN-04119-G4',
      'Returning "no data" for data that exists but could not be decrypted is '
          'how an app quietly deletes a user work after a key rotation.',
      'A record the cipher cannot decrypt raises a REFUSAL naming the key and '
          'the reason, rather than reading as missing',
      () async {
        await store.write(jobs, 'J1', plain('a signed delivery note'));
        final HabotEncryptedStore afterRotation = HabotEncryptedStore(
          inner: inner,
          cipher: const _NotSecureRotationCipher(brokenKey: true),
        );
        HabotDecryptRefusal? refusal;
        try {
          await afterRotation.read(jobs, 'J1');
        } on HabotDecryptRefusedException catch (e) {
          refusal = e.refusal;
        }
        return refusal == HabotDecryptRefusal.decryptFailed &&
            afterRotation.refusals.length == 1 &&
            // ...and a key that genuinely is not there still reads as null.
            await afterRotation.read(jobs, 'MISSING') == null;
      },
    );

    gate(
      'GEN-04119-G5',
      'A record written before encryption existed -- or by something '
          'bypassing this store -- is not a record to hand back.',
      'An unheadered record and a record from an unknown format version are '
          'both refused with their own reasons, rather than being returned as '
          'plaintext',
      () async {
        await inner.write(jobs, 'LEGACY', plain('written by an older build'));
        final Uint8List wrongVersion = Uint8List.fromList(<int>[
          ...HabotEncryptedStore.headerMagic,
          HabotEncryptedStore.formatVersion + 1,
          1,
          2,
          3,
        ]);
        await inner.write(jobs, 'FUTURE', wrongVersion);

        HabotDecryptRefusal? legacy;
        HabotDecryptRefusal? future;
        try {
          await store.read(jobs, 'LEGACY');
        } on HabotDecryptRefusedException catch (e) {
          legacy = e.refusal;
        }
        try {
          await store.read(jobs, 'FUTURE');
        } on HabotDecryptRefusedException catch (e) {
          future = e.refusal;
        }
        return legacy == HabotDecryptRefusal.unheaderedRecord &&
            future == HabotDecryptRefusal.unknownFormat &&
            await store.encryptedShare(jobs) < 1.0;
      },
    );

    gate(
      'GEN-04119-G6',
      'The two recorded decisions must live where the evidence is, not in a '
          'document nobody reads beside the code.',
      'The SDUI non-applicability and the absent cipher are stated in the '
          'source itself, and the wrapper satisfies the Step 113 store '
          'contract so the DAO above cannot tell the difference',
      () async {
        return HabotEncryptedStore.sduiApplicability.contains(
              'NOT APPLICABLE',
            ) &&
            HabotEncryptedStore.cipherProvenance.contains('Keystore') &&
            // It IS a HabotLocalStore, so the DAO above cannot tell the
            // difference -- which is what stops encryption being forgotten at
            // one call site.
            store.supportsTransactions == inner.supportsTransactions &&
            store.isDurable == inner.isDurable &&
            store.engineName != inner.engineName;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04119',
        atomicStepReferenceId: 'GEN-04119-A01',
        setupStepAction:
            'Store fetched SDUI layout JSON files in client-side encrypted '
            'local storage.',
        implementationOrder: 114,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotEncryptedStore / HabotCipher',
          'Component Properties':
              'wraps any HabotLocalStore; '
              '${HabotEncryptedStore.headerLength}-byte format header on '
              'every record; ${HabotDecryptRefusal.values.length} named '
              'refusal reasons; no default cipher',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Encrypted Storage Synchronization (share of records '
                'carrying the encryption header)',
            observed:
                '1.0 for every record written through the store. A cipher '
                'that returns its input is refused at write time and counted, '
                'so the share cannot be reached by writing plaintext through '
                'a broken cipher.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          const AissMeasurement(
            metricName: 'Cryptographic strength',
            observed:
                'NOT PRODUCED, AND NOT CLAIMED. No cipher ships in lib/. '
                'Device-bound encryption needs Android Keystore or the iOS '
                'Keychain through a plugin this environment cannot resolve. '
                'HabotEncryptedStore requires a HabotCipher and has no '
                'default, so the absence is a compile-time obstacle rather '
                'than a silent gap. The test cipher is a byte rotation, is '
                'named NOT SECURE, and assertProductionReady throws on it.',
            floor: 'platform keystore required',
            optimal: 'platform keystore required',
            ceiling: 'platform keystore required',
          ),
          const AissMeasurement(
            metricName: 'SDUI layout storage (the row names it)',
            observed:
                'NOT APPLICABLE. This app has no server-driven UI layer; the '
                'interface is compiled Flutter. The encrypted-storage half of '
                'the requirement is implemented and gated. Nothing was '
                'invented for the SDUI half.',
            floor: 'not applicable',
            optimal: 'not applicable',
            ceiling: 'not applicable',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/encrypted_store.dart',
        ],
      ),
    );
  });
}

bool _sameBytes(Uint8List a, Uint8List b) {
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
