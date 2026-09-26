import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reown_core/store/i_store.dart';
import 'package:reown_core/utils/constants.dart';

/// Reown's secure records use the reviewed default secure-storage namespace.
///
/// Unlike Reown's SecureStore, this store never falls back to shared
/// preferences, discards malformed records, or publishes a failed write.
class N42ReownSecureStore implements IStore<Map<String, dynamic>> {
  N42ReownSecureStore({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(resetOnError: false),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  }) : _secureStorage = secureStorage;

  static const _keychainKey = 'wc@2:core:0.3//keychain';
  static const _keychainVersionKey = 'wc@2:core:keychain';
  final FlutterSecureStorage _secureStorage;
  Map<String, Map<String, dynamic>> _map = {};
  Future<void> _pending = Future<void>.value();
  bool _initialized = false;
  bool _failed = false;

  @override
  String get storagePrefix => ReownConstants.CORE_STORAGE_PREFIX;

  @override
  Map<String, Map<String, dynamic>> get map {
    _checkReady();
    return Map.unmodifiable(_map);
  }

  @override
  List<String> get keys => List.unmodifiable(map.keys);

  @override
  List<Map<String, dynamic>> get values => List.unmodifiable(map.values);

  @override
  Future<void> init() async {
    if (_initialized) {
      _checkReady();
      return;
    }
    if (_failed) throw StateError('Reown secure storage is unusable');
    try {
      final all = await _secureStorage.readAll();
      final restored = <String, Map<String, dynamic>>{};
      for (final entry in all.entries) {
        if (!entry.key.startsWith(storagePrefix)) continue;
        final dynamic decoded = jsonDecode(entry.value);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Reown secure record is not an object');
        }
        if (entry.key == _keychainKey &&
            decoded.values.any((value) => value is! String)) {
          throw const FormatException(
            'Reown keychain contains a non-string key',
          );
        }
        if (entry.key == _keychainVersionKey && decoded['version'] is! String) {
          throw const FormatException('Reown keychain version is invalid');
        }
        restored[entry.key] = Map.unmodifiable(decoded);
      }
      _map = restored;
      _initialized = true;
    } catch (_) {
      _failed = true;
      throw StateError('Reown secure storage restore failed');
    }
  }

  @override
  Map<String, dynamic>? get(String key) {
    _checkReady();
    return _map['$storagePrefix$key'];
  }

  @override
  bool has(String key) {
    _checkReady();
    return _map.containsKey('$storagePrefix$key');
  }

  @override
  List<dynamic> getAll() => values;

  @override
  Future<void> set(String key, Map<String, dynamic> value) =>
      _serialize(() async {
        final fullKey = '$storagePrefix$key';
        final snapshot = Map<String, dynamic>.unmodifiable(value);
        await _secureStorage.write(key: fullKey, value: jsonEncode(snapshot));
        _map[fullKey] = snapshot;
      });

  @override
  Future<void> update(String key, Map<String, dynamic> value) =>
      _serialize(() async {
        final fullKey = '$storagePrefix$key';
        if (!_map.containsKey(fullKey)) {
          throw StateError('Reown secure record does not exist');
        }
        final snapshot = Map<String, dynamic>.unmodifiable(value);
        await _secureStorage.write(key: fullKey, value: jsonEncode(snapshot));
        _map[fullKey] = snapshot;
      });

  @override
  Future<void> delete(String key) => _serialize(() async {
    final fullKey = '$storagePrefix$key';
    await _secureStorage.delete(key: fullKey);
    _map.remove(fullKey);
  });

  @override
  Future<void> deleteAll() => _serialize(() async {
    for (final key in _map.keys.toList()) {
      await _secureStorage.delete(key: key);
      _map.remove(key);
    }
  });

  Future<void> _serialize(Future<void> Function() action) {
    _checkReady();
    final operation = _pending.then((_) async {
      _checkReady();
      try {
        await action();
      } catch (_) {
        _failed = true;
        rethrow;
      }
    });
    _pending = operation.catchError((Object _) {});
    return operation;
  }

  void _checkReady() {
    if (!_initialized || _failed) {
      throw StateError('Reown secure storage is unusable');
    }
  }
}
