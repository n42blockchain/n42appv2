import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/chain_api/apt_api.dart';
import '../utils/transfer_serializer.dart';

class AptPendingSubmission {
  final int chainId;
  final String sender;
  final String hash;
  final BigInt sequence;
  const AptPendingSubmission(
    this.chainId,
    this.sender,
    this.hash,
    this.sequence,
  );
}

class AptSubmissionPending extends StateError {
  final AptPendingSubmission submission;
  AptSubmissionPending(this.submission)
    : super('Reconcile the original Aptos transaction');
}

/// Durable account-wide exclusion. Stores no key or signed transaction bytes.
/// Locks coordinate this isolate; cross-process writers need separate coordination.
class AptSubmissionJournal {
  final FlutterSecureStorage _storage;
  AptSubmissionJournal({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  String _address(String sender) {
    if (!RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(sender) ||
        sender.contains(RegExp(r'\s'))) {
      throw ArgumentError('Invalid Aptos sender');
    }
    return '0x${sender.substring(2).toLowerCase().padLeft(64, '0')}';
  }

  String _key(int chain, String sender) {
    if (chain < 1 || chain > 255) throw ArgumentError('Invalid Aptos chain');
    return 'n42.apt.pending.v1.$chain.${_address(sender)}';
  }

  Future<AptPendingSubmission?> pending(int chain, String sender) async {
    final raw = await _storage.read(key: _key(chain, sender));
    if (raw == null) return null;
    final data = jsonDecode(raw);
    if (data is! Map ||
        data['chainId'] != chain ||
        data['sender'] != _address(sender) ||
        data['hash'] is! String ||
        data['hash'].length != 66 ||
        !RegExp(r'^0x[0-9a-f]{64}$').hasMatch(data['hash'])) {
      throw StateError('Invalid pending Aptos record');
    }
    return AptPendingSubmission(
      chain,
      _address(sender),
      data['hash'],
      AptApi.parseUint64(data['sequence']),
    );
  }

  Future<AptPendingSubmission> broadcast({
    required int chainId,
    required String sender,
    required BigInt sequence,
    required String signedTx,
    required Future<void> Function(AptPendingSubmission) send,
    required bool Function() isCurrent,
  }) => TransferSerializer.run(_key(chainId, sender), () async {
    final existing = await pending(chainId, sender);
    if (existing != null) throw AptSubmissionPending(existing);
    AptApi.parseUint64(sequence);
    final record = AptPendingSubmission(
      chainId,
      _address(sender),
      AptApi.transactionHash(signedTx),
      sequence,
    );
    if (!isCurrent()) {
      throw StateError('Aptos owner changed before persistence');
    }
    await _storage.write(
      key: _key(chainId, sender),
      value: jsonEncode({
        'chainId': chainId,
        'sender': record.sender,
        'hash': record.hash,
        'sequence': sequence.toString(),
      }),
    );
    if (!isCurrent()) {
      // No submission was attempted. A failed deletion remains safely locked.
      await _storage.delete(key: _key(chainId, sender));
      throw StateError('Aptos owner changed before submission');
    }
    // Any error from here leaves the original record in durable storage.
    await send(record);
    return record;
  });

  /// Persist the terminal result before releasing the account. Never rebroadcast.
  /// The callback must be idempotent: a crash/delete failure can repeat it.
  Future<AptTransactionReceipt?> reconcile({
    required int chainId,
    required String sender,
    required AptApi api,
    required Future<void> Function(AptPendingSubmission, AptTransactionReceipt)
    saveResult,
  }) => TransferSerializer.run(_key(chainId, sender), () async {
    final record = await pending(chainId, sender);
    if (record == null) return null;
    final result = await api.getTransactionReceipt(
      hash: record.hash,
      sender: record.sender,
      sequence: record.sequence,
      chainId: record.chainId,
    );
    if (result.error || result.data is! AptTransactionReceipt) return null;
    final receipt = result.data as AptTransactionReceipt;
    if (receipt.hash != record.hash) return null;
    if (receipt.status == AptTransactionStatus.pending) return receipt;
    await saveResult(record, receipt);
    await _storage.delete(key: _key(chainId, sender));
    return receipt;
  });
}
