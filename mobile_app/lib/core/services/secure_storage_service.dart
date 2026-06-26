/// Encrypted persistence service wrapping [FlutterSecureStorage].
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider for the [SecureStorageService] singleton.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provides encrypted read/write operations for sensitive data.
///
/// Uses AES encryption on Android and Keychain on iOS.
/// All wardrobe data (including image bytes) is stored encrypted at rest,
/// satisfying GDPR Article 32 requirements for data protection.
class SecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  final FlutterSecureStorage _storage;

  /// Reads and decodes a JSON map from encrypted storage.
  Future<Map<String, dynamic>?> readJson(String key) async {
    try {
      final raw = await _storage.read(key: key);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } on Exception catch (_) {
      debugPrint('SecureStorage read error for key=$key');
      return null;
    }
  }

  /// Encodes and writes a JSON-serializable map to encrypted storage.
  Future<void> writeJson(String key, Map<String, dynamic> data) async {
    try {
      final encoded = await compute(jsonEncode, data);
      await _storage.write(key: key, value: encoded);
    } on Exception catch (_) {
      debugPrint('SecureStorage write error for key=$key');
    }
  }

  /// Deletes a key from encrypted storage.
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on Exception catch (_) {
      debugPrint('SecureStorage delete error for key=$key');
    }
  }

  /// Deletes all data from encrypted storage.
  /// Use for GDPR "right to erasure" compliance.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } on Exception catch (_) {
      debugPrint('SecureStorage deleteAll error');
    }
  }
}
