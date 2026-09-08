/// AISS Step 114 -- GEN-04119
/// "Store fetched SDUI layout JSON files in client-side encrypted local
///  storage."
/// Metric: Encrypted Storage Synchronization -- every band 1.0.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// TWO THINGS ARE RECORDED BEFORE ANY CODE.
///
/// 1. SDUI: NOT APPLICABLE. The row names "SDUI layout JSON". There is no
///    server-driven UI in this project -- the interface is compiled Flutter.
///    The encrypted-storage half of the requirement is real and is built here.
///    The SDUI half is recorded as not applicable rather than invented. If
///    server-driven UI is genuinely planned, the Step 112 repository is the
///    file that changes, and it changes significantly: a repository designed
///    for records is not a repository designed for layouts.
///
/// 2. NO CIPHER IS SHIPPED IN THIS FILE, AND THAT IS DELIBERATE. Real
///    device-bound encryption needs a platform keystore -- Android Keystore or
///    the iOS Keychain -- reached through a plugin this environment cannot
///    resolve. The available alternatives were: ship a hand-rolled cipher, or
///    ship the interface and refuse to run without a real one. A hand-rolled
///    cipher is worse than no encryption, because it looks like encryption in
///    a code review and in an audit. So [HabotEncryptedStore] REQUIRES a
///    [HabotCipher] and has no default; the test suite supplies an obviously
///    fake one whose own name says it is not secure, and it lives in the test
///    file, not in `lib/`.
///
/// WHAT IS ACTUALLY GUARANTEED HERE, since it is not the cryptography:
///   * every byte written through this store passes through the cipher --
///    [plaintextWritesAttempted] counts any attempt to bypass it and is
///    asserted to be zero;
///   * ciphertext is never confusable with plaintext: every record carries a
///    version header, and a read that finds an unheadered record refuses it
///    rather than returning what it found;
///   * a decrypt failure is a REFUSAL, never a silent empty result. Returning
///    "no data" for data that exists but could not be decrypted is how an app
///    quietly deletes a user's work after a key rotation.
///
/// All metric bands are 1.0, which is the sheet saying the same thing: every
/// persisted payload encrypted, or the step fails.
library;

import 'dart:typed_data';

import 'local_store.dart';

/// The cryptographic operation, supplied by whatever can actually do it on the
/// platform. Two methods, no configuration: a cipher with options is a cipher
/// that gets configured wrongly.
abstract interface class HabotCipher {
  /// A name for the evidence record, e.g. 'AES-GCM-256 (Android Keystore)'.
  String get algorithmName;

  /// False for anything that must not reach production. Checked by
  /// [HabotEncryptedStore.assertProductionReady].
  bool get isProductionGrade;

  Uint8List encrypt(Uint8List plaintext);

  /// Returns null when the bytes cannot be decrypted -- a wrong key, a
  /// rotated key, a truncated file. Never throws for those, because they are
  /// ordinary on a real device; never returns empty bytes either, because a
  /// caller cannot tell that apart from an empty record.
  Uint8List? decrypt(Uint8List ciphertext);
}

/// Why an encrypted read was refused.
enum HabotDecryptRefusal {
  /// The record has no header, so it was written before encryption existed --
  /// or by something bypassing this store.
  unheaderedRecord,

  /// The header names a format this build does not know.
  unknownFormat,

  /// The cipher could not decrypt it.
  decryptFailed,
}

/// Thrown on a refusal. Deliberately an exception rather than a null: a caller
/// that ignores this is a caller that shows an empty screen where a user's
/// data is.
class HabotDecryptRefusedException implements Exception {
  const HabotDecryptRefusedException(this.refusal, this.key);

  final HabotDecryptRefusal refusal;
  final String key;

  @override
  String toString() =>
      'HabotDecryptRefusedException: refused to return record "$key" '
      '(${refusal.name}). The record exists but could not be decrypted; '
      'reporting it as absent would look like data loss to the user and would '
      'invite an overwrite.';
}

/// Wraps any [HabotLocalStore] so that nothing reaches the device in the
/// clear.
///
/// It IS a [HabotLocalStore], which is the point: the DAO above it does not
/// know whether it is talking to an encrypted store or a plain one, so
/// encryption cannot be forgotten at one call site.
class HabotEncryptedStore implements HabotLocalStore {
  HabotEncryptedStore({required this.inner, required this.cipher});

  final HabotLocalStore inner;
  final HabotCipher cipher;

  /// The header every ciphertext record starts with. Four bytes: magic, magic,
  /// magic, format version.
  static const List<int> headerMagic = <int>[0x48, 0x42, 0x54];
  static const int formatVersion = 1;
  static int get headerLength => headerMagic.length + 1;

  /// Counts any attempt to write past the cipher. Asserted zero by
  /// GEN-04119-G1; the counter exists so the assertion is about observed
  /// behaviour rather than about reading the code.
  int plaintextWritesAttempted = 0;

  /// Reads that found a record and refused to return it.
  final List<HabotDecryptRefusal> refusals = <HabotDecryptRefusal>[];

  @override
  bool get isDurable => inner.isDurable;

  @override
  String get engineName => '${inner.engineName} + ${cipher.algorithmName}';

  @override
  bool get supportsTransactions => inner.supportsTransactions;

  /// A build that reaches production with a non-production cipher is a build
  /// that thinks it is encrypted and is not.
  void assertProductionReady() {
    if (!cipher.isProductionGrade) {
      throw StateError(
        'HabotEncryptedStore is configured with "${cipher.algorithmName}", '
        'which declares itself not production grade. Supply a cipher backed '
        'by the platform keystore before shipping.',
      );
    }
  }

  static bool hasHeader(Uint8List bytes) {
    if (bytes.length < headerLength) {
      return false;
    }
    for (int i = 0; i < headerMagic.length; i++) {
      if (bytes[i] != headerMagic[i]) {
        return false;
      }
    }
    return true;
  }

  static Uint8List _wrap(Uint8List ciphertext) {
    final Uint8List out = Uint8List(headerLength + ciphertext.length);
    for (int i = 0; i < headerMagic.length; i++) {
      out[i] = headerMagic[i];
    }
    out[headerMagic.length] = formatVersion;
    out.setRange(headerLength, out.length, ciphertext);
    return out;
  }

  static int versionOf(Uint8List bytes) => bytes[headerMagic.length];

  @override
  Future<Uint8List?> read(HabotCollection collection, String key) async {
    final Uint8List? stored = await inner.read(collection, key);
    if (stored == null) {
      return null;
    }
    if (!hasHeader(stored)) {
      refusals.add(HabotDecryptRefusal.unheaderedRecord);
      throw HabotDecryptRefusedException(
        HabotDecryptRefusal.unheaderedRecord,
        key,
      );
    }
    if (versionOf(stored) != formatVersion) {
      refusals.add(HabotDecryptRefusal.unknownFormat);
      throw HabotDecryptRefusedException(
        HabotDecryptRefusal.unknownFormat,
        key,
      );
    }
    final Uint8List? plain = cipher.decrypt(
      Uint8List.sublistView(stored, headerLength),
    );
    if (plain == null) {
      refusals.add(HabotDecryptRefusal.decryptFailed);
      throw HabotDecryptRefusedException(
        HabotDecryptRefusal.decryptFailed,
        key,
      );
    }
    return plain;
  }

  @override
  Future<void> write(
    HabotCollection collection,
    String key,
    Uint8List bytes,
  ) async {
    final Uint8List ciphertext = cipher.encrypt(bytes);
    if (_looksLikePlaintext(bytes, ciphertext)) {
      plaintextWritesAttempted++;
      throw StateError(
        'The cipher returned its input unchanged for record "$key". That is '
        'not encryption, and writing it would put plaintext on the device '
        'behind a name that says otherwise.',
      );
    }
    await inner.write(collection, key, _wrap(ciphertext));
  }

  /// A cipher that returns its input is either a stub someone left in or a
  /// misconfiguration. Either way the write must not happen.
  static bool _looksLikePlaintext(Uint8List plain, Uint8List encrypted) {
    if (plain.isEmpty) {
      return false;
    }
    if (plain.length != encrypted.length) {
      return false;
    }
    for (int i = 0; i < plain.length; i++) {
      if (plain[i] != encrypted[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> remove(HabotCollection collection, String key) =>
      inner.remove(collection, key);

  @override
  Future<List<String>> keys(HabotCollection collection) =>
      inner.keys(collection);

  @override
  Future<void> clear(HabotCollection collection) => inner.clear(collection);

  @override
  Future<void> transaction(Future<void> Function() body) =>
      inner.transaction(body);

  /// The metric, computed: the share of records on the device that carry the
  /// encryption header. All bands are 1.0, so anything below 1 is a failure.
  Future<double> encryptedShare(HabotCollection collection) async {
    final List<String> ks = await inner.keys(collection);
    if (ks.isEmpty) {
      return 1;
    }
    int headered = 0;
    for (final String k in ks) {
      final Uint8List? raw = await inner.read(collection, k);
      if (raw != null && hasHeader(raw)) {
        headered++;
      }
    }
    return headered / ks.length;
  }

  /// Recorded here so the evidence file states it rather than a document
  /// nobody reads alongside the code.
  static const String sduiApplicability =
      'NOT APPLICABLE. The row names SDUI layout JSON; this app has no '
      'server-driven UI layer -- the interface is compiled Flutter. The '
      'encrypted-storage half of the requirement is implemented; the SDUI half '
      'is recorded as not applicable and nothing is invented in its place.';

  static const String cipherProvenance =
      'NO CIPHER SHIPS IN lib/. Device-bound encryption needs Android '
      'Keystore or the iOS Keychain via a plugin this environment cannot '
      'resolve. HabotEncryptedStore requires a HabotCipher and has no '
      'default, so the absence is a compile-time obstacle rather than a '
      'silent gap.';
}
