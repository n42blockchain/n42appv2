import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _mode = 'localSimulation';
final _maxUnits = BigInt.parse('9000000000000000');

enum LocalPaymentPendingOperation { transfer, create, claim, refund }

enum LocalPaymentPendingStatus { empty, ready, corrupt, unavailable }

final class LocalPaymentPendingStoreException implements Exception {
  const LocalPaymentPendingStoreException(this.code);
  final String code;
  @override
  String toString() => 'LocalPaymentPendingStoreException: $code';
}

/// An isolation namespace, not authentication or encryption. Synthetic fixture
/// tokens are predictable: their SHA256 hashes are not secret or anonymization.
final class LocalPaymentPendingScope {
  LocalPaymentPendingScope._(this.endpoint, this.accountHash);

  factory LocalPaymentPendingScope.fromAccount({
    required Uri endpoint,
    required String syntheticToken,
  }) {
    if (endpoint.scheme != 'http' ||
        endpoint.host != '127.0.0.1' ||
        endpoint.userInfo.isNotEmpty ||
        endpoint.hasQuery ||
        endpoint.hasFragment ||
        (endpoint.path.isNotEmpty && endpoint.path != '/') ||
        !RegExp(
          r'^synthetic-test-[A-Za-z0-9_-]{8,128}$',
        ).hasMatch(syntheticToken)) {
      throw const LocalPaymentPendingStoreException('invalid_scope');
    }
    return LocalPaymentPendingScope._(
      'http://127.0.0.1:${endpoint.port}',
      sha256.convert(utf8.encode(syntheticToken)).toString(),
    );
  }

  final String endpoint;
  final String accountHash;
  String get storageKey =>
      'n42.localSimulation.pending.v1.${sha256.convert(utf8.encode('$endpoint\u0000$accountHash'))}';
}

final class LocalPaymentPendingEntry {
  LocalPaymentPendingEntry({
    required this.key,
    required this.operation,
    required Map<String, String> parameters,
  }) : parameters = Map.unmodifiable(parameters) {
    _validateKey(key);
    final fields = switch (operation) {
      LocalPaymentPendingOperation.transfer => {'recipient', 'asset', 'amount'},
      LocalPaymentPendingOperation.create => {
        'room',
        'asset',
        'total',
        'slots',
        'expiresAt',
      },
      LocalPaymentPendingOperation.claim ||
      LocalPaymentPendingOperation.refund => {'packet'},
    };
    if (parameters.length != fields.length ||
        !fields.every(parameters.containsKey)) {
      throw const LocalPaymentPendingStoreException('invalid_entry');
    }
    for (final entry in parameters.entries) {
      if (entry.key == 'packet') {
        if (!RegExp(r'^packet_[a-f0-9]{64}$').hasMatch(entry.value)) {
          throw const LocalPaymentPendingStoreException('invalid_entry');
        }
      } else if ([
        'amount',
        'total',
        'slots',
        'expiresAt',
      ].contains(entry.key)) {
        if (!RegExp(r'^(0|[1-9][0-9]{0,15})$').hasMatch(entry.value)) {
          throw const LocalPaymentPendingStoreException('invalid_entry');
        }
        final units = BigInt.parse(entry.value);
        if (units > _maxUnits ||
            (entry.key != 'expiresAt' && units == BigInt.zero)) {
          throw const LocalPaymentPendingStoreException('invalid_entry');
        }
      } else if (entry.value.isEmpty ||
          entry.value.length > 256 ||
          RegExp(r'[\x00-\x1f\x7f]').hasMatch(entry.value)) {
        throw const LocalPaymentPendingStoreException('invalid_entry');
      }
    }
  }

  final String key;
  final LocalPaymentPendingOperation operation;
  final Map<String, String> parameters;

  Map<String, dynamic> _json() => {
    'key': key,
    'operation': operation.name,
    'parameters': parameters,
  };

  static LocalPaymentPendingEntry _decode(dynamic value) {
    if (value is! Map<String, dynamic> ||
        value.length != 3 ||
        value['key'] is! String ||
        value['operation'] is! String ||
        value['parameters'] is! Map<String, dynamic>) {
      throw const LocalPaymentPendingStoreException('invalid_entry');
    }
    final raw = value['parameters'] as Map<String, dynamic>;
    if (raw.values.any((v) => v is! String)) {
      throw const LocalPaymentPendingStoreException('invalid_entry');
    }
    return LocalPaymentPendingEntry(
      key: value['key'] as String,
      operation: LocalPaymentPendingOperation.values.byName(
        value['operation'] as String,
      ),
      parameters: raw.cast<String, String>(),
    );
  }

  bool _same(LocalPaymentPendingEntry other) =>
      operation == other.operation &&
      parameters.length == other.parameters.length &&
      parameters.entries.every((e) => other.parameters[e.key] == e.value);
}

void _validateKey(String key) {
  if (!RegExp(r'^[\x21-\x7e]{1,128}$').hasMatch(key)) {
    throw const LocalPaymentPendingStoreException('invalid_key');
  }
}

final class LocalPaymentPendingLoad {
  LocalPaymentPendingLoad._(
    this.status, [
    List<LocalPaymentPendingEntry> entries = const [],
  ]) : entries = List.unmodifiable(entries);
  final LocalPaymentPendingStatus status;
  final List<LocalPaymentPendingEntry> entries;
}

/// Local test journal only. Await save success BEFORE issuing any POST.
/// SharedPreferences is not a transactional financial database or secure vault;
/// the journal survives normal restart, not guaranteed disk/OS failure.
final class LocalPaymentPendingStore {
  LocalPaymentPendingStore({
    required SharedPreferences preferences,
    required String mode,
  }) : _preferences = preferences {
    if (mode != _mode || kReleaseMode) {
      throw const LocalPaymentPendingStoreException('disabled');
    }
  }

  final SharedPreferences _preferences;
  // Serialize all instances in this isolate, including reload/read/write. This
  // does not claim a cross-isolate/process lock over SharedPreferences.
  static Future<void> _tail = Future.value();
  static const _maxBytes = 65536;
  static const _maxEntries = 32;

  Future<T> _serial<T>(Future<T> Function() action) {
    final next = _tail.then((_) => action());
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  Future<LocalPaymentPendingLoad> load(LocalPaymentPendingScope scope) =>
      _serial(() => _read(scope));

  Future<LocalPaymentPendingLoad> _read(LocalPaymentPendingScope scope) async {
    Object? raw;
    try {
      await _preferences.reload();
      raw = _preferences.get(scope.storageKey);
    } catch (_) {
      return LocalPaymentPendingLoad._(LocalPaymentPendingStatus.unavailable);
    }
    if (raw == null)
      return LocalPaymentPendingLoad._(LocalPaymentPendingStatus.empty);
    try {
      if (raw is! String || utf8.encode(raw).length > _maxBytes)
        throw const FormatException();
      final value = jsonDecode(raw);
      // We only write canonical JSON. Reject ambiguous duplicate-key or edited
      // representations rather than silently accepting a lossy JSON decode.
      if (raw != jsonEncode(value)) throw const FormatException();
      if (value is! Map<String, dynamic> ||
          value.length != 5 ||
          value['version'] != 1 ||
          value['version'] is! int ||
          value['mode'] != _mode ||
          value['endpoint'] != scope.endpoint ||
          value['accountHash'] != scope.accountHash ||
          value['entries'] is! List)
        throw const FormatException();
      final rows = value['entries'] as List;
      if (rows.length > _maxEntries) throw const FormatException();
      final entries = rows.map(LocalPaymentPendingEntry._decode).toList();
      if (entries.map((e) => e.key).toSet().length != entries.length)
        throw const FormatException();
      return LocalPaymentPendingLoad._(
        entries.isEmpty
            ? LocalPaymentPendingStatus.empty
            : LocalPaymentPendingStatus.ready,
        entries,
      );
    } catch (_) {
      return LocalPaymentPendingLoad._(LocalPaymentPendingStatus.corrupt);
    }
  }

  Future<List<LocalPaymentPendingEntry>> _editable(
    LocalPaymentPendingScope scope,
  ) async {
    final result = await _read(scope);
    if (result.status == LocalPaymentPendingStatus.corrupt ||
        result.status == LocalPaymentPendingStatus.unavailable) {
      throw LocalPaymentPendingStoreException(result.status.name);
    }
    return result.entries.toList();
  }

  Future<void> save(
    LocalPaymentPendingScope scope,
    LocalPaymentPendingEntry entry,
  ) => _serial(() async {
    final entries = await _editable(scope);
    final previous = entries.where((e) => e.key == entry.key).firstOrNull;
    if (previous != null) {
      if (!previous._same(entry))
        throw const LocalPaymentPendingStoreException('key_conflict');
      return;
    }
    if (entries.length >= _maxEntries)
      throw const LocalPaymentPendingStoreException('journal_full');
    entries.add(entry);
    await _write(scope, entries);
  });

  Future<void> remove(LocalPaymentPendingScope scope, String key) =>
      _serial(() async {
        _validateKey(key);
        final entries = await _editable(scope);
        if (!entries.any((entry) => entry.key == key)) return;
        entries.removeWhere((entry) => entry.key == key);
        await _write(scope, entries);
      });

  Future<void> _write(
    LocalPaymentPendingScope scope,
    List<LocalPaymentPendingEntry> entries,
  ) async {
    final encoded = jsonEncode({
      'version': 1,
      'mode': _mode,
      'endpoint': scope.endpoint,
      'accountHash': scope.accountHash,
      'entries': entries.map((e) => e._json()).toList(),
    });
    if (utf8.encode(encoded).length > _maxBytes)
      throw const LocalPaymentPendingStoreException('journal_full');
    try {
      if (!await _preferences.setString(scope.storageKey, encoded)) {
        throw const LocalPaymentPendingStoreException('write_failed');
      }
    } catch (_) {
      throw const LocalPaymentPendingStoreException('write_failed');
    }
  }
}
