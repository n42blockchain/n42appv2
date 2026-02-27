import 'dart:convert';

import 'package:eip712/eip712.dart';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_connection.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_session.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_state.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart' show bytesToHex;
import 'package:wallet/wallet.dart' as wallet_types;

/// Mixin: WalletConnect signing handlers for messages and transactions.
mixin WalletConnectSigning on ChangeNotifier, WalletConnectConnection, WalletConnectSession {
  /// Map method name to EIP-712 typed data version.
  static const _typedDataVersions = {
    "eth_signTypedData": TypedDataVersion.v4,
    "eth_signTypedData_v3": TypedDataVersion.v3,
    "eth_signTypedData_v4": TypedDataVersion.v4,
  };

  Future<void> messageSignTap() async {
    try {
      if (walletConnectState == WalletConnectState.messageSign) return;
      viewStateDeal(WalletConnectState.messageSign);
      final eventData = actionData as wallet_connect.SessionRequestEvent;
      String signedDataHex;

      if (eventData.method == "personal_sign") {
        final requestParams = (eventData.params! as List).cast<String>();
        final rawData = requestParams[0];
        // DApps may send either hex-encoded bytes (0xdeadbeef) or plain
        // UTF-8 text (e.g. SIWE messages). Detect and decode accordingly.
        final stripped = web3.strip0x(rawData);
        final encodedMessage = _isValidHex(stripped)
            ? web3.hexToBytes(stripped)
            : Uint8List.fromList(utf8.encode(rawData));
        final signedData = privateKey.signPersonalMessageToUint8List(encodedMessage);
        signedDataHex = bytesToHex(signedData, include0x: true);
      } else if (_typedDataVersions.containsKey(eventData.method)) {
        final requestParams = (eventData.params! as List).cast<String>();
        signedDataHex = _signTypedData(
          privateKey: privateKey,
          jsonData: requestParams[1],
          version: _typedDataVersions[eventData.method]!,
        );
      } else if (eventData.method == "tron_signMessage") {
        final requestParams = eventData.params! as Map;
        final dataToSign = requestParams["message"];
        final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.TRX.name).firstOrNull;
        if (cm == null) {
          viewStateDeal(WalletConnectState.error, params: 'TRON chain not supported');
          return;
        }
        final credentials = await getTronCredentials();
        final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
        signedDataHex = await trustdart.signMessage(
          CoinType.TRX.name, path, dataToSign,
          mnemonic: credentials.mnemonic, pk: credentials.privateKey,
        );
      } else {
        final requestParams = (eventData.params! as List).cast<String>();
        final dataToSign = web3.strip0x(requestParams[1]);
        if (coinModels[coinModelsIndex].coin['coinType'] == CoinType.N.name) {
          signedDataHex = await trustdart.signMessage(
            CoinType.N.name, "", dataToSign,
            pk: base64Encode(privateKey.privateKey),
          );
          signedDataHex = "0x$signedDataHex";
        } else {
          final encodedMessage = web3.hexToBytes(dataToSign);
          final signedData = privateKey.signPersonalMessageToUint8List(encodedMessage);
          signedDataHex = bytesToHex(signedData, include0x: true);
        }
      }

      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(id: eventData.id, result: signedDataHex),
      );
      viewStateDeal(WalletConnectState.connect);
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }

  Future<void> transactionSignTap() async {
    try {
      if (walletConnectState == WalletConnectState.transaction) return;
      viewStateDeal(WalletConnectState.transaction);
      final eventData = actionData as wallet_connect.SessionRequestEvent;
      final initOk = await web3clientInitFromChainId(eventData.chainId);
      if (!initOk) return;

      if (eventData.method == "tron_signTransaction") {
        await _handleTronTransaction(eventData);
        return;
      }

      await _handleEthTransaction(eventData);
    } catch (e) {
      viewStateDeal(WalletConnectState.error, params: e.toString());
    }
  }

  Future<void> _handleTronTransaction(wallet_connect.SessionRequestEvent eventData) async {
    final requestParams = eventData.params! as Map;
    final dataToSign = requestParams["message"];
    final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.TRX.name).firstOrNull;
    if (cm == null) {
      viewStateDeal(WalletConnectState.error, params: 'TRON chain not supported');
      return;
    }
    final credentials = await getTronCredentials();
    final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
    final returnStr = await trustdart.signTransaction(
      CoinType.TRX.name, path, dataToSign,
      mnemonic: credentials.mnemonic, pk: credentials.privateKey,
    );
    signClient!.respondSessionRequest(
      topic: eventData.topic,
      response: wallet_connect.JsonRpcResponse(id: eventData.id, result: returnStr),
    );
    viewStateDeal(WalletConnectState.connect);
  }

  Future<void> _handleEthTransaction(wallet_connect.SessionRequestEvent eventData) async {
    final parameters = eventData.params.first as Map<String, dynamic>;
    final from = parameters['from'] as String;
    final to = parameters['to'] as String?;
    final value = parameters['value'] as String?;
    final nonce = parameters['nonce'] as String?;
    final gasPrice = parameters['gasPrice'] as String?;
    final maxFeePerGas = parameters['maxFeePerGas'] as String?;
    final maxPriorityFeePerGas = parameters['maxPriorityFeePerGas'] as String?;
    final gasLimit = parameters['gasLimit'] as String?;
    final data = parameters['data'] as String?;

    final transaction = web3.Transaction(
      from: wallet_types.EthereumAddress.fromHex(from),
      to: wallet_types.EthereumAddress.fromHex(to ?? "0x"),
      value: wallet_types.EtherAmount.fromBigInt(
        wallet_types.EtherUnit.wei,
        BigInt.tryParse(value ?? "0x") ?? BigInt.zero,
      ),
      gasPrice: gasPrice != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.gwei, BigInt.tryParse(gasPrice) ?? BigInt.zero)
          : null,
      maxFeePerGas: maxFeePerGas != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.gwei, BigInt.tryParse(maxFeePerGas) ?? BigInt.zero)
          : null,
      maxPriorityFeePerGas: maxPriorityFeePerGas != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.gwei, BigInt.tryParse(maxPriorityFeePerGas) ?? BigInt.zero)
          : null,
      maxGas: int.tryParse(gasLimit ?? ''),
      nonce: int.tryParse(nonce ?? ''),
      data: (data != null && data != '0x') ? web3.hexToBytes(data) : null,
    );

    String returnStr;
    if (eventData.method == "eth_signTransaction") {
      final sig = await web3client!.signTransaction(privateKey, transaction);
      returnStr = bytesToHex(sig, include0x: true);
    } else {
      final cm = coinModels[coinModelsIndex];
      returnStr = await web3client!.sendTransaction(
        privateKey,
        transaction,
        chainId: cm.isTest ? cm.coin['chainId_test'] : cm.coin['chainId'],
      );
    }

    signClient!.respondSessionRequest(
      topic: eventData.topic,
      response: wallet_connect.JsonRpcResponse(id: eventData.id, result: returnStr),
    );
    viewStateDeal(WalletConnectState.connect);
  }

  /// Returns true if [s] contains only hex characters (0-9, a-f, A-F).
  /// Empty string returns false to avoid creating a zero-length byte array.
  static bool _isValidHex(String s) {
    if (s.isEmpty) return false;
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);
  }

  /// Sign typed data using EIP-712 standard.
  ///
  /// IMPORTANT: [hashTypedData] already returns keccak256(0x1901 ‖ domainHash ‖ messageHash).
  /// We must sign this hash DIRECTLY with secp256k1 — do NOT use [signToEcSignature]
  /// which internally calls keccak256 again, producing an invalid double-hashed signature.
  String _signTypedData({
    required web3.EthPrivateKey privateKey,
    required String jsonData,
    required TypedDataVersion version,
  }) {
    final Map<String, dynamic> typedData = json.decode(jsonData);
    const requiredFields = ['types', 'primaryType', 'domain', 'message'];
    for (final field in requiredFields) {
      if (!typedData.containsKey(field)) {
        throw FormatException('Invalid EIP-712 data: missing required field "$field"');
      }
    }

    final typedMessage = TypedMessage.fromJson(typedData);

    // hashTypedData returns the final 32-byte keccak256 hash — ready to sign
    final hash = hashTypedData(typedData: typedMessage, version: version);

    // Sign the pre-hashed data directly via secp256k1.
    // ecSign does NOT hash again; it signs the raw 32-byte digest.
    // The returned v is already recovery + 27 (i.e. 27 or 28).
    final signature = web3.sign(hash, privateKey.privateKey);

    // Encode to 65-byte hex: r (32 bytes) + s (32 bytes) + v (1 byte)
    final r = signature.r.toRadixString(16).padLeft(64, '0');
    final s = signature.s.toRadixString(16).padLeft(64, '0');
    final v = signature.v.toRadixString(16).padLeft(2, '0');

    return '0x$r$s$v';
  }
}
