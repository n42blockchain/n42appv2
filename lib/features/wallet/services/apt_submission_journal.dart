import 'dart:convert';

import '../../wallet_connect/validation/aptos_raw_transaction.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/chain_api/apt_api.dart';
import '../utils/transfer_serializer.dart';

class AptPendingSubmission {
  final int chainId;
  final String sender;
  final String hash;
  final BigInt sequence;
  final BigInt? expirationSeconds;

  /// False only when the durable journal proves dispatch has not started.
  final bool submissionAttempted;
  const AptPendingSubmission(
    this.chainId,
    this.sender,
    this.hash,
    this.sequence, {
    this.expirationSeconds,
    this.submissionAttempted = true,
  });
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
        (data.containsKey('submissionAttempted') &&
            data['submissionAttempted'] is! bool) ||
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
      submissionAttempted: data['submissionAttempted'] as bool? ?? true,
      expirationSeconds: data['expirationSeconds'] == null
          ? null
          : AptApi.parseUint64(data['expirationSeconds']),
    );
  }

  Future<AptPendingSubmission> broadcast({
    required int chainId,
    required String sender,
    required BigInt sequence,
    required String signedTx,
    BigInt? expirationSeconds,
    required Future<void> Function(AptPendingSubmission) send,
    required bool Function() isCurrent,
    Future<void> Function(AptPendingSubmission)? beforePersist,
  }) => TransferSerializer.run(_key(chainId, sender), () async {
    final existing = await pending(chainId, sender);
    if (existing != null) throw AptSubmissionPending(existing);
    AptApi.parseUint64(sequence);
    if (expirationSeconds != null) {
      AptApi.parseUint64(expirationSeconds);
      // Current native transfer signers emit a single Ed25519 authenticator:
      // variant 0, key vector(32), signature vector(64). Bind recovery metadata
      // to these actual signed bytes before trusting expiry for release.
      final hex = signedTx.replaceFirst(RegExp(r'^0[xX]'), '');
      if (hex.length < 198 ||
          hex.length.isOdd ||
          RegExp(r'[^0-9a-fA-F]').hasMatch(hex)) {
        throw const FormatException('Invalid Aptos signed envelope');
      }
      final auth = hex.substring(hex.length - 198).toLowerCase();
      if (!auth.startsWith('0020') || auth.substring(68, 70) != '40') {
        throw const FormatException('Unsupported Aptos recovery authenticator');
      }
      final raw = AptosRawTransaction.parse(
        '0x${hex.substring(0, hex.length - 198)}',
        expectedSender: sender,
        expectedChainId: chainId,
      ).bytes;
      BigInt uint64(int start) {
        var value = BigInt.zero;
        for (var i = 7; i >= 0; i--) {
          value = (value << 8) | BigInt.from(raw[start + i]);
        }
        return value;
      }

      if (uint64(32) != sequence ||
          uint64(raw.length - 9) != expirationSeconds) {
        throw const FormatException(
          'Aptos recovery metadata differs from signed bytes',
        );
      }
    }
    var record = AptPendingSubmission(
      chainId,
      _address(sender),
      AptApi.transactionHash(signedTx),
      sequence,
      expirationSeconds: expirationSeconds,
      submissionAttempted: false,
    );
    if (!isCurrent()) {
      throw StateError('Aptos owner changed before persistence');
    }
    Future<void> persist(bool attempted) => _storage.write(
      key: _key(chainId, sender),
      value: jsonEncode({
        'chainId': chainId,
        'sender': record.sender,
        'hash': record.hash,
        'sequence': sequence.toString(),
        'submissionAttempted': attempted,
        if (expirationSeconds != null)
          'expirationSeconds': expirationSeconds.toString(),
      }),
    );
    // Reserve recovery before touching the separate history database. A crash
    // during that write is locally recoverable even if no history row exists.
    await persist(false);
    if (!isCurrent()) {
      throw StateError('Aptos owner changed before history persistence');
    }
    await beforePersist?.call(record);
    if (!isCurrent()) {
      throw StateError('Aptos owner changed before submission');
    }
    // Persist the uncertain state BEFORE calling the network. Never downgrade
    // after this write: even an acknowledgement failure may have stored it.
    await persist(true);
    record = AptPendingSubmission(
      record.chainId,
      record.sender,
      record.hash,
      record.sequence,
      expirationSeconds: record.expirationSeconds,
    );
    if (!isCurrent()) {
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
    if (!record.submissionAttempted) {
      final receipt = AptTransactionReceipt(
        record.hash,
        AptTransactionStatus.notSubmitted,
      );
      await saveResult(record, receipt);
      await _storage.delete(key: _key(chainId, sender));
      return receipt;
    }
    final result = await api.getTransactionReceipt(
      hash: record.hash,
      sender: record.sender,
      sequence: record.sequence,
      chainId: record.chainId,
    );
    AptTransactionReceipt? receipt =
        !result.error && result.data is AptTransactionReceipt
        ? result.data as AptTransactionReceipt
        : null;
    if (receipt != null && receipt.hash != record.hash) return null;
    if (receipt == null || receipt.status == AptTransactionStatus.pending) {
      final expiry = record.expirationSeconds;
      if (expiry == null ||
          !await api.isExpiredWithoutExecution(
            sender: record.sender,
            sequence: record.sequence,
            expirationSeconds: expiry,
            chainId: record.chainId,
          )) {
        return receipt;
      }
      receipt = AptTransactionReceipt(
        record.hash,
        AptTransactionStatus.expired,
      );
    }
    await saveResult(record, receipt);
    await _storage.delete(key: _key(chainId, sender));
    return receipt;
  });
}
