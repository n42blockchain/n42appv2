import 'dart:typed_data';
import 'dart:convert';

import 'package:pointycastle/digests/sha3.dart';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

typedef AptTransactionSubmit = Future<dynamic> Function(
  String url,
  Uint8List bytes, {
  required Map<String, dynamic> header,
  required bool enableRetry,
});

enum AptTransactionStatus { pending, succeeded, failed, expired, notSubmitted }

class AptTransactionReceipt {
  final String hash;
  final AptTransactionStatus status;
  final BigInt? version;
  const AptTransactionReceipt(this.hash, this.status, {this.version});
}

class AptApi {
  final String url;
  final AptTransactionSubmit? submit;
  final Future<dynamic> Function(String url)? read;

  Future<dynamic> _get(String endpoint) => read != null
      ? read!(endpoint)
      : BaseApi.requestEmptyH.get(endpoint, params: {});

  /// Preserve REST uint64 strings; never accept rounded floating-point values.
  static BigInt parseUint64(dynamic value) {
    if (value is! String && value is! int && value is! BigInt) {
      throw const FormatException('Invalid Aptos uint64');
    }
    final text = value.toString();
    final number = BigInt.tryParse(text);
    if (number == null ||
        number < BigInt.zero ||
        number >= (BigInt.one << 64) ||
        number.toString() != text) {
      throw const FormatException('Invalid Aptos uint64');
    }
    return number;
  }

  AptApi({bool isTest = false, this.submit, this.read})
    : url = RequestUrl().getUrl2(CoinType.APT.name, 'rpc', isTest: isTest);

  Future<MessageModel> getBalance(
    String address, {
    String contract = '',
    String tokenName = '',
  }) async {
    try {
      // This endpoint takes the asset itself, not its CoinStore resource tag.
      // Keep the legacy explicit Celer symbol path for existing callers.
      final assetType = contract.isEmpty
          ? '0x1::aptos_coin::AptosCoin'
          : tokenName.isNotEmpty && !contract.contains('::')
          ? '$contract::celer_coin_manager::$tokenName'
          : contract;
      final uri =
          '${url}accounts/${Uri.encodeComponent(address)}/balance/'
          '${Uri.encodeComponent(assetType)}';
      final data = await _get(uri);
      return MessageModel()..data = parseUint64(data);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> getGasPrice() async {
    try {
      final data = await _get('${url}estimate_gas_price');
      return MessageModel()..data = parseUint64(data['gas_estimate']);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> getAccountInfo(String address) async {
    try {
      final data = await _get('${url}accounts/$address');
      return MessageModel()..data = parseUint64(data['sequence_number']);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> getServiceInfo({int? expectedChainId}) async {
    try {
      final data = await _get(url);
      if (expectedChainId != null) {
        if (expectedChainId < 1 ||
            expectedChainId > 255 ||
            data is! Map ||
            data['chain_id'] is! int ||
            data['chain_id'] != expectedChainId) {
          return MessageModel.error()..data = 'Aptos RPC chain ID mismatch';
        }
      }
      return MessageModel()..data = parseUint64(data['ledger_timestamp']);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Read only. Missing/malformed responses must not unlock a pending intent.
  /// RPC field consistency is not a cryptographic ledger proof.
  Future<MessageModel> getTransactionReceipt({
    required String hash,
    required String sender,
    required BigInt sequence,
    required int chainId,
  }) async {
    try {
      if (!RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(hash) || hash.length != 66) {
        throw const FormatException('Invalid Aptos transaction hash');
      }
      String canonicalAddress(dynamic value) {
        if (value is! String ||
            !RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(value) ||
            value.contains(RegExp(r'\s'))) {
          throw const FormatException('Invalid Aptos transaction sender');
        }
        return value.substring(2).toLowerCase().padLeft(64, '0');
      }

      final expectedSender = canonicalAddress(sender);
      parseUint64(sequence);
      final ledger = await getServiceInfo(expectedChainId: chainId);
      if (ledger.error) return ledger;
      final expectedHash = hash.toLowerCase();
      final data = await _get('${url}transactions/by_hash/$expectedHash');
      if (data is! Map ||
          data['hash'] is! String ||
          data['hash'].toString().toLowerCase() != expectedHash ||
          canonicalAddress(data['sender']) != expectedSender ||
          parseUint64(data['sequence_number']) != sequence) {
        throw const FormatException('Aptos transaction identity mismatch');
      }
      if (data['type'] == 'pending_transaction') {
        if (data.containsKey('success') || data.containsKey('version')) {
          throw const FormatException('Inconsistent Aptos pending transaction');
        }
        return MessageModel()
          ..data = AptTransactionReceipt(
            expectedHash,
            AptTransactionStatus.pending,
          );
      }
      if (data['type'] != 'user_transaction' || data['success'] is! bool) {
        throw const FormatException('Invalid Aptos execution status');
      }
      final version = parseUint64(data['version']);
      return MessageModel()
        ..data = AptTransactionReceipt(
          expectedHash,
          data['success']
              ? AptTransactionStatus.succeeded
              : AptTransactionStatus.failed,
          version: version,
        );
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// A committed ledger past expiry plus unchanged sequence proves this
  /// sequence-based transaction did not execute at that version. Never use the
  /// device clock or an unversioned account read for this decision.
  Future<bool> isExpiredWithoutExecution({
    required String sender,
    required BigInt sequence,
    required BigInt expirationSeconds,
    required int chainId,
  }) async {
    try {
      if (chainId < 1 ||
          chainId > 255 ||
          !RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(sender) ||
          sender.contains(RegExp(r'\s'))) {
        return false;
      }
      parseUint64(sequence);
      parseUint64(expirationSeconds);
      if (expirationSeconds == BigInt.zero) return false;
      final ledger = await _get(url);
      if (ledger is! Map ||
          ledger['chain_id'] is! int ||
          ledger['chain_id'] != chainId) {
        return false;
      }
      final version = parseUint64(ledger['ledger_version']);
      final timestamp = parseUint64(ledger['ledger_timestamp']);
      if (timestamp <= expirationSeconds * BigInt.from(1000000)) return false;
      final account = await _get(
        '${url}accounts/$sender?ledger_version=$version',
      );
      return account is Map &&
          parseUint64(account['sequence_number']) == sequence;
    } catch (_) {
      return false;
    }
  }

  static Uint8List _signedBytes(String signedHex) {
    final hex = signedHex.startsWith('0x') || signedHex.startsWith('0X')
        ? signedHex.substring(2)
        : signedHex;
    if (hex.isEmpty ||
        hex.length.isOdd ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex) ||
        hex.contains(RegExp(r'\s'))) {
      throw const FormatException('Invalid Aptos signed transaction');
    }
    return Uint8List.fromList([
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ]);
  }

  /// Hash the signed user-transaction envelope, not the raw signing message.
  /// This is a deterministic identifier, not signature or BCS validation.
  static String transactionHash(String signedHex) =>
      _hashSignedBytes(_signedBytes(signedHex));

  static String _hashSignedBytes(Uint8List bytes) {
    final domain = SHA3Digest(256)
        .process(Uint8List.fromList(utf8.encode('APTOS::Transaction')));
    final hash = SHA3Digest(256)
        .process(Uint8List.fromList([...domain, 0, ...bytes]));
    return '0x${hash.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
  }

  /// Native signers return hex; the REST BCS endpoint requires raw bytes.
  Future<MessageModel> sendTxHash(String signedHex) async {
    try {
      final bytes = _signedBytes(signedHex);
      final expectedHash = _hashSignedBytes(bytes);
      const header = <String, dynamic>{
        'content-type': 'application/x.aptos.signed_transaction+bcs',
      };
      final request = submit;
      final data = request != null
          ? await request(
              '${url}transactions',
              bytes,
              header: header,
              enableRetry: false,
            )
          : await BaseApi.requestEmptyH.post(
              '${url}transactions',
              params: {},
              data: bytes,
              header: header,
              enableRetry: false,
            );
      if (data is! Map ||
          data['hash'] is! String ||
          (data['hash'] as String).length != 66 ||
          !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(data['hash'] as String) ||
          (data['hash'] as String).toLowerCase() != expectedHash ||
          (data.containsKey('success') && data['success'] != true)) {
        return MessageModel.error()
          ..data = 'Invalid or failed Aptos submission response';
      }
      // A hash acknowledges submission; it is not proof of final execution.
      return MessageModel()..data = expectedHash;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
