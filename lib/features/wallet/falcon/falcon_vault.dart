import '../utils/transfer_serializer.dart';

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'falcon_crypto.dart';

/// Independent Falcon account: not recoverable from the EVM mnemonic.
final class FalconVault {
  FalconVault(this.crypto, this.scope, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage() {
    if (scope.isEmpty) throw ArgumentError('Wallet scope required');
  }
  final FalconCrypto crypto;
  final String scope;
  final FlutterSecureStorage _storage;
  String get _key => 'n42.falcon512.v1.${base64Url.encode(utf8.encode(scope))}';
  Future<Map<String, dynamic>?> _read() async {
    final data = await _storage.read(key: _key);
    return data == null ? null : jsonDecode(data) as Map<String, dynamic>;
  }

  Future<bool> backupVerified() async =>
      (await _read())?['backupVerified'] == true;
  Future<Uint8List?> publicKey() async {
    final record = await _read();
    return record == null ? null : base64Decode(record['public'] as String);
  }

  Future<void> create() => TransferSerializer.run('falcon-key:$scope', _create);
  Future<void> _create() async {
    if (await _read() != null) {
      throw StateError('Falcon account already exists');
    }
    final pair = crypto.generate();
    try {
      await _storage.write(
        key: _key,
        value: jsonEncode({
          'public': base64Encode(pair.publicKey),
          'secret': base64Encode(pair.secretKey),
        }),
      );
    } finally {
      pair.secretKey.fillRange(0, pair.secretKey.length, 0);
    }
  }

  Future<Uint8List> sign(Uint8List digest) async {
    final record = await _read();
    if (record == null) throw StateError('No Falcon account');
    final secret = base64Decode(record['secret'] as String);
    try {
      final signature = crypto.sign(secret, digest);
      if (!crypto.verify(
        base64Decode(record['public'] as String),
        digest,
        signature,
      )) {
        throw StateError('Falcon signature verification failed');
      }
      return signature;
    } finally {
      secret.fillRange(0, secret.length, 0);
    }
  }

  static final _cipher = AesGcm.with256bits();
  static final _kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 310000,
    bits: 256,
  );
  static void _password(String password) {
    if (password.length < 12 || password.length > 256) {
      throw ArgumentError('Use a backup password of 12–256 characters');
    }
  }

  Future<String> backup(String password) async {
    _password(password);
    final record = await _read();
    if (record == null) throw StateError('No Falcon account');
    final salt = List.generate(16, (_) => Random.secure().nextInt(256));
    final key = await _kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    final clear = Uint8List.fromList(utf8.encode(jsonEncode(record)));
    try {
      final box = await _cipher.encrypt(
        clear,
        secretKey: key,
        aad: utf8.encode('n42-falcon-backup-v1'),
      );
      return jsonEncode({
        'version': 1,
        'algorithm': 'Falcon-512',
        'salt': base64Encode(salt),
        'nonce': base64Encode(box.nonce),
        'ciphertext': base64Encode(box.cipherText),
        'mac': base64Encode(box.mac.bytes),
      });
    } finally {
      clear.fillRange(0, clear.length, 0);
    }
  }

  Future<void> restore(String blob, String password) => TransferSerializer.run(
    'falcon-key:$scope',
    () => _restore(blob, password),
  );
  Future<Map<String, dynamic>> _openBackup(String blob, String password) async {
    _password(password);
    if (blob.length > 12000) {
      throw FormatException('Backup too large');
    }
    final envelope = jsonDecode(blob) as Map<String, dynamic>;
    if (envelope['version'] != 1 || envelope['algorithm'] != 'Falcon-512') {
      throw FormatException('Unsupported backup');
    }
    final salt = base64Decode(envelope['salt'] as String);
    final nonce = base64Decode(envelope['nonce'] as String);
    final mac = base64Decode(envelope['mac'] as String);
    if (salt.length != 16 || nonce.length != 12 || mac.length != 16) {
      throw FormatException('Invalid backup');
    }
    final key = await _kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    final clear = await _cipher.decrypt(
      SecretBox(
        base64Decode(envelope['ciphertext'] as String),
        nonce: nonce,
        mac: Mac(mac),
      ),
      secretKey: key,
      aad: utf8.encode('n42-falcon-backup-v1'),
    );
    try {
      final record = jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
      final secret = base64Decode(record['secret'] as String),
          public = base64Decode(record['public'] as String);
      try {
        final challenge = Uint8List(32)..[0] = 42;
        if (!crypto.verify(public, challenge, crypto.sign(secret, challenge))) {
          throw FormatException('Backup key mismatch');
        }
        return {
          'public': record['public'],
          'secret': record['secret'],
          'backupVerified': true,
        };
      } finally {
        secret.fillRange(0, secret.length, 0);
      }
    } finally {
      clear.fillRange(0, clear.length, 0);
    }
  }

  Future<void> _restore(String blob, String password) async {
    if (await _read() != null) {
      throw StateError('Restore requires an empty Falcon account');
    }
    final record = await _openBackup(blob, password);
    await _storage.write(key: _key, value: jsonEncode(record));
  }

  /// Prove the user has a decryptable backup of this exact account before send.
  Future<void> verifyBackup(String blob, String password) =>
      TransferSerializer.run('falcon-key:$scope', () async {
        final existing = await _read();
        if (existing == null) {
          throw StateError('No Falcon account');
        }
        final opened = await _openBackup(blob, password);
        if (opened['public'] != existing['public']) {
          throw StateError('Backup belongs to a different key');
        }
        await _storage.write(
          key: _key,
          value: jsonEncode({...existing, 'backupVerified': true}),
        );
      });
}
