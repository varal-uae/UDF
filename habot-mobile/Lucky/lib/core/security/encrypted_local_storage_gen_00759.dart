// GEN-00759 — Encrypted Local Storage & Offline Sync Architecture.
// Provisions AES-256 encrypted local storage for offline data sync and local event caching using Flutter Secure Storage, compliant with NIST SP 800-111.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Core service for provisioning AES-256 encrypted local storage.
/// Replaces native Room (Android) and CoreData/SQLite (iOS) references
/// with a cross-platform Flutter secure storage implementation.
class EncryptedLocalStorageService {
  EncryptedLocalStorageService._internal();

  static final EncryptedLocalStorageService instance =
      EncryptedLocalStorageService._internal();

  late final FlutterSecureStorage _secureStorage;

  /// Initializes the encrypted storage with platform-specific options.
  /// Ensures AES-256 encryption baseline per NIST SP 800-111.
  Future<void> initialize() async {
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
    );
    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    );

    _secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
  }

  /// Writes encrypted data to local storage.
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Reads decrypted data from local storage.
  Future<String?> read({required String key}) async {
    return _secureStorage.read(key: key);
  }

  /// Deletes a specific key from local storage.
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  /// Clears all locally cached events and data.
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}

/// M3 Elevated Card Level 2 (3dp) displaying storage health status.
/// Implements single-column mobile layout (<600dp) with 48x48dp touch targets.
class StorageHealthCard extends StatelessWidget {
  const StorageHealthCard({
    super.key,
    required this.isEncrypted,
    required this.onRefresh,
  });

  final bool isEncrypted;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0,
      surfaceTintColor: colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Local Storage Encryption',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Chip(
                  label: Text(
                    isEncrypted ? 'Pass' : 'Fail',
                    style: theme.textTheme.labelSmall,
                  ),
                  backgroundColor: isEncrypted
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  labelStyle: TextStyle(
                    color: isEncrypted
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Standard: NIST SP 800-111 | Target: AES-256',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 48.0,
                width: 48.0,
                child: IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.sync),
                  tooltip: 'Trigger manual sync',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Background polling controller that refreshes data every 30 seconds.
class StoragePollingController {
  StoragePollingController({required this.onPoll});

  final VoidCallback onPoll;
  bool _isRunning = false;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _poll();
  }

  void stop() {
    _isRunning = false;
  }

  Future<void> _poll() async {
    while (_isRunning) {
      onPoll();
      await Future.delayed(const Duration(seconds: 30));
    }
  }
}
