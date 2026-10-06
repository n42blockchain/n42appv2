import 'package:n42_chat/n42_chat.dart';

typedef EvmReceiptRpcCall = Future<Object?> Function(
  String method,
  List<Object?> params,
);

/// Checks one standard native or ERC-20 transfer against an EVM receipt.
///
/// The caller binds the RPC endpoint and expected chain ID to the selected
/// wallet asset. Unknown shapes fail closed.
class EvmTransferReceiptVerifier {
  static const _transferTopic =
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
  static final _hashPattern = RegExp(r'^0x[0-9a-fA-F]{64}$');
  static final _addressPattern = RegExp(r'^0x[0-9a-fA-F]{40}$');
  static final _hexPattern = RegExp(r'^0x[0-9a-fA-F]+$');
  static final _wordPattern = RegExp(r'^0x[0-9a-fA-F]{64}$');

  static Future<WalletTransferReceiptResult> verify({
    required WalletTransferReceiptRequest request,
    required int expectedChainId,
    required int requiredConfirmations,
    required int decimals,
    required EvmReceiptRpcCall rpcCall,
  }) async {
    if (!_validRequest(request) ||
        expectedChainId <= 0 ||
        requiredConfirmations <= 0 ||
        decimals < 0 ||
        decimals > 255) {
      return const WalletTransferReceiptResult(
        WalletTransferReceiptState.mismatch,
      );
    }

    try {
      final chainId = _parseQuantity(await rpcCall('eth_chainId', const []));
      if (chainId == null) return _unavailable();
      if (chainId != BigInt.from(expectedChainId)) return _mismatch();

      final transaction = _asMap(
        await rpcCall('eth_getTransactionByHash', [request.transactionHash]),
      );
      if (transaction == null) return _pending(requiredConfirmations);
      final receipt = _asMap(
        await rpcCall('eth_getTransactionReceipt', [request.transactionHash]),
      );
      if (receipt == null) return _pending(requiredConfirmations);

      final txHash = transaction['hash']?.toString();
      final receiptHash = receipt['transactionHash']?.toString();
      if (!_same(txHash, request.transactionHash) ||
          !_same(receiptHash, request.transactionHash)) {
        return _mismatch();
      }

      final transactionBlock = _parseQuantity(transaction['blockNumber']);
      final includedBlock = _parseQuantity(receipt['blockNumber']);
      final transactionBlockHash = transaction['blockHash']?.toString();
      final receiptBlockHash = receipt['blockHash']?.toString();
      if (transactionBlock == null ||
          includedBlock == null ||
          transactionBlockHash == null ||
          receiptBlockHash == null ||
          !_hashPattern.hasMatch(transactionBlockHash) ||
          !_hashPattern.hasMatch(receiptBlockHash)) {
        return _unavailable();
      }
      if (transactionBlock != includedBlock ||
          !_same(transactionBlockHash, receiptBlockHash)) {
        return _unavailable();
      }

      // A receipt may be returned from a stale RPC view during a reorg.
      // Confirm its block is still canonical before counting confirmations.
      final canonicalBlock = _asMap(
        await rpcCall('eth_getBlockByNumber', [
          _toQuantity(includedBlock),
          false,
        ]),
      );
      if (canonicalBlock == null) return _pending(requiredConfirmations);
      final canonicalBlockHash = canonicalBlock['hash']?.toString();
      if (canonicalBlockHash == null ||
          !_hashPattern.hasMatch(canonicalBlockHash)) {
        return _unavailable();
      }
      if (!_same(canonicalBlockHash, receiptBlockHash)) {
        return _pending(requiredConfirmations);
      }

      final expectedUnits = _decimalToUnits(request.amount, decimals);
      if (expectedUnits == null || expectedUnits <= BigInt.zero) {
        return _mismatch();
      }
      final senderMatches = _same(
        transaction['from']?.toString(),
        request.senderAddress,
      );

      final isNative = request.assetType == 'native';
      final transactionMatches = isNative
          ? senderMatches &&
                _same(transaction['to']?.toString(), request.receiverAddress) &&
                _parseQuantity(transaction['value']) == expectedUnits &&
                _emptyInput(transaction['input'])
          : _matchesErc20Call(
              transaction,
              request: request,
              expectedUnits: expectedUnits,
              senderMatches: senderMatches,
            );
      if (!transactionMatches) return _mismatch();

      final receiptStatus = _parseQuantity(receipt['status']);
      if (receiptStatus == BigInt.zero) {
        return const WalletTransferReceiptResult(
          WalletTransferReceiptState.failed,
        );
      }
      if (receiptStatus != BigInt.one) return _unavailable();

      if (!isNative &&
          !_hasMatchingTransferLog(
            receipt,
            request: request,
            expectedUnits: expectedUnits,
          )) {
        return _mismatch();
      }

      final latestBlock = _parseQuantity(
        await rpcCall('eth_blockNumber', const []),
      );
      if (latestBlock == null) return _unavailable();
      if (latestBlock < includedBlock) return _mismatch();
      final confirmationsBig = latestBlock - includedBlock + BigInt.one;
      final confirmations = confirmationsBig > BigInt.from(0x7fffffff)
          ? 0x7fffffff
          : confirmationsBig.toInt();
      if (confirmations < requiredConfirmations) {
        return WalletTransferReceiptResult(
          WalletTransferReceiptState.pending,
          confirmations: confirmations,
          requiredConfirmations: requiredConfirmations,
        );
      }
      return WalletTransferReceiptResult(
        WalletTransferReceiptState.confirmed,
        confirmations: confirmations,
        requiredConfirmations: requiredConfirmations,
      );
    } catch (_) {
      return _unavailable();
    }
  }

  static bool _validRequest(WalletTransferReceiptRequest request) =>
      _hashPattern.hasMatch(request.transactionHash) &&
      _addressPattern.hasMatch(request.senderAddress) &&
      _addressPattern.hasMatch(request.receiverAddress) &&
      request.chain.trim().isNotEmpty &&
      (request.network == 'mainnet' || request.network == 'testnet') &&
      (request.assetType == 'native' && request.assetId == null ||
          request.assetType == 'token' &&
              request.assetId != null &&
              _addressPattern.hasMatch(request.assetId!));

  static bool _matchesErc20Call(
    Map<String, dynamic> transaction, {
    required WalletTransferReceiptRequest request,
    required BigInt expectedUnits,
    required bool senderMatches,
  }) {
    final input = transaction['input']?.toString() ?? '';
    final contract = request.assetId;
    if (!senderMatches ||
        contract == null ||
        !_same(transaction['to']?.toString(), contract) ||
        _parseQuantity(transaction['value']) != BigInt.zero ||
        input.length != 138 ||
        input.substring(0, 10).toLowerCase() != '0xa9059cbb' ||
        !_hexPattern.hasMatch(input)) {
      return false;
    }
    final encodedAddress = input.substring(34, 74);
    final encodedAmount = BigInt.tryParse(input.substring(74, 138), radix: 16);
    final addressPadding = input.substring(10, 34);
    return RegExp(r'^0+$').hasMatch(addressPadding) &&
        encodedAddress.toLowerCase() ==
            request.receiverAddress.substring(2).toLowerCase() &&
        encodedAmount == expectedUnits;
  }

  static bool _hasMatchingTransferLog(
    Map<String, dynamic> receipt, {
    required WalletTransferReceiptRequest request,
    required BigInt expectedUnits,
  }) {
    final logs = receipt['logs'];
    if (logs is! List) return false;
    var total = BigInt.zero;
    for (final value in logs) {
      final log = _asMap(value);
      if (log == null || !_same(log['address']?.toString(), request.assetId)) {
        continue;
      }
      final topics = log['topics'];
      if (topics is! List || topics.length != 3) continue;
      if (!_same(topics[0]?.toString(), _transferTopic) ||
          !_sameTopicAddress(topics[1]?.toString(), request.senderAddress) ||
          !_sameTopicAddress(topics[2]?.toString(), request.receiverAddress)) {
        continue;
      }
      final data = log['data']?.toString() ?? '';
      if (!_wordPattern.hasMatch(data)) return false;
      final amount = _parseHex(data);
      if (amount == null) return false;
      total += amount;
    }
    return total == expectedUnits;
  }

  static bool _sameTopicAddress(String? topic, String address) {
    if (topic == null || !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(topic)) {
      return false;
    }
    return topic.substring(topic.length - 40).toLowerCase() ==
        address.substring(2).toLowerCase();
  }

  static BigInt? _decimalToUnits(String amount, int decimals) {
    if (!RegExp(r'^[0-9]+(?:\.[0-9]+)?$').hasMatch(amount)) return null;
    final parts = amount.split('.');
    final fraction = parts.length == 2 ? parts[1] : '';
    if (fraction.length > decimals) return null;
    final scale = BigInt.from(10).pow(decimals);
    final whole = BigInt.tryParse(parts.first);
    final fractional = fraction.isEmpty
        ? BigInt.zero
        : BigInt.tryParse(fraction.padRight(decimals, '0'));
    if (whole == null || fractional == null) return null;
    return whole * scale + fractional;
  }

  static BigInt? _parseQuantity(Object? value) {
    final text = value?.toString() ?? '';
    if (!RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(text)) return null;
    return BigInt.tryParse(text.substring(2), radix: 16);
  }

  static BigInt? _parseHex(String value) {
    if (!_hexPattern.hasMatch(value)) return null;
    return BigInt.tryParse(value.substring(2), radix: 16);
  }

  static String _toQuantity(BigInt value) => '0x${value.toRadixString(16)}';

  static bool _emptyInput(Object? value) => value?.toString() == '0x';

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static bool _same(String? left, String? right) =>
      left != null &&
      right != null &&
      left.toLowerCase() == right.toLowerCase();

  static WalletTransferReceiptResult _pending(int required) =>
      WalletTransferReceiptResult(
        WalletTransferReceiptState.pending,
        requiredConfirmations: required,
      );

  static WalletTransferReceiptResult _mismatch() =>
      const WalletTransferReceiptResult(WalletTransferReceiptState.mismatch);
  static WalletTransferReceiptResult _unavailable() =>
      const WalletTransferReceiptResult(WalletTransferReceiptState.unavailable);
}
