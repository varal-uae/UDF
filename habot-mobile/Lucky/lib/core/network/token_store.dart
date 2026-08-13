import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// GEN-03981 / GEN-04467 — Secure Token Store.
// Persists access + refresh tokens in platform secure storage:
//   iOS  → Keychain
//   Android → EncryptedSharedPreferences (hardware-backed Keystore when available)
//
// Spec: NIST SP 800-63B — tokens stored in secure enclave, never in plain prefs.
// Rule: raw token values NEVER logged or serialised to non-secure storage.

class TokenStore {
  TokenStore._();
  static final TokenStore instance = TokenStore._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _kAccess  = 'habot.auth.access_token';
  static const _kRefresh = 'habot.auth.refresh_token';
  static const _kExpiry  = 'habot.auth.access_expiry_ms';

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccess,  value: accessToken),
      _storage.write(key: _kRefresh, value: refreshToken),
      _storage.write(key: _kExpiry,  value: expiry.millisecondsSinceEpoch.toString()),
    ]);
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<String?> get accessToken  => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  Future<bool> get isAccessTokenExpired async {
    final raw = await _storage.read(key: _kExpiry);
    if (raw == null) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(raw));
    // Treat as expired 30 seconds early — prevents edge-case 401s
    return DateTime.now().isAfter(expiry.subtract(const Duration(seconds: 30)));
  }

  Future<bool> get hasTokens async {
    final access  = await accessToken;
    final refresh = await refreshToken;
    return access != null && refresh != null;
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  /// Called on logout or refresh failure — wipes all auth state.
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kAccess),
      _storage.delete(key: _kRefresh),
      _storage.delete(key: _kExpiry),
    ]);
  }
}
