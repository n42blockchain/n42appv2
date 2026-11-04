import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex, hexToBytes, keccak256;

import '../utils/transfer_serializer.dart';

/// Durable, account-scoped intent. An unknown broadcast must never erase it.
class BatchSubmissionJournal {
  BatchSubmissionJournal({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  String _key(int chainId, String sender) {
    if (chainId <= 0 || !RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(sender)) {
      throw ArgumentError('Invalid batch account');
    }
    return 'n42.batch.pending.v1.$chainId.${sender.toLowerCase()}';
  }

  Future<String?> pendingHash(int chainId, String sender) async {
    final raw = await _storage.read(key: _key(chainId, sender));
    if (raw == null) return null;
    final record = jsonDecode(raw);
    if (record is! Map ||
        record['chainId'] != chainId ||
        record['sender'] != sender.toLowerCase() ||
        record['hash'] is! String ||
        !RegExp(r'^0x[0-9a-f]{64}$').hasMatch(record['hash'] as String)) {
      throw StateError('Invalid pending batch record');
    }
    return record['hash'] as String;
  }

  Future<bool> resolve(
    int chainId,
    String sender,
    String hash,
    Future<bool> Function() isFinal,
  ) => TransferSerializer.run(_key(chainId, sender), () async {
    if (await pendingHash(chainId, sender) != hash || !await isFinal()) {
      return false;
    }
    await _storage.delete(key: _key(chainId, sender));
    return true;
  });

  Future<String> broadcast({
    required int chainId,
    required String sender,
    required String signedTx,
    required Future<void> Function(String hash) send,
    bool Function()? isCurrent,
  }) => TransferSerializer.run(_key(chainId, sender), () async {
    final existing = await pendingHash(chainId, sender);
    if (existing != null) throw BatchSubmissionPending(existing);
    if (!RegExp(r'^0x(?:[0-9a-fA-F]{2})+$').hasMatch(signedTx)) {
      throw ArgumentError('Invalid signed transaction bytes');
    }
    final hash = bytesToHex(keccak256(hexToBytes(signedTx)), include0x: true);
    await _storage.write(
      key: _key(chainId, sender),
      value: jsonEncode({
        'chainId': chainId,
        'sender': sender.toLowerCase(),
        'hash': hash,
      }),
    );
    if (isCurrent != null && !isCurrent()) {
      // No network call occurred; this intent can safely be discarded.
      await _storage.delete(key: _key(chainId, sender));
      throw BatchSubmissionCancelled();
    }
    // Storage must complete before the only allowed network submission.
    await send(hash);
    return hash;
  });
}

class BatchSubmissionPending extends StateError {
  BatchSubmissionPending(this.hash)
    : super('Reconcile the original batch transaction');
  final String hash;
}

class BatchSubmissionCancelled extends StateError {
  BatchSubmissionCancelled() : super('Batch changed before broadcast');
}
