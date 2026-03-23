import 'dart:convert';

import 'package:eip712/eip712.dart';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
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
      } else if (eventData.method == "aptos_signMessage") {
        final requestParams = eventData.params! as Map;
        final message = requestParams["message"] as String? ??
            (requestParams["fullMessage"] as String? ?? '');
        final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.APT.name).firstOrNull;
        if (cm == null) {
          viewStateDeal(WalletConnectState.error, params: 'Aptos chain not configured');
          return;
        }
        final credentials = await getAptosCredentials();
        final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
        final sig = await trustdart.signMessage(
          CoinType.APT.name, path, message,
          mnemonic: credentials.mnemonic, pk: credentials.privateKey,
        );
        signClient!.respondSessionRequest(
          topic: eventData.topic,
          response: wallet_connect.JsonRpcResponse(
            id: eventData.id,
            result: {"signature": sig},
          ),
        );
        viewStateDeal(WalletConnectState.connect);
        return;
      } else if (eventData.method == "sui_signMessage") {
        final requestParams = eventData.params! as Map;
        final message = requestParams["message"] as String? ?? '';
        final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.SUI.name).firstOrNull;
        if (cm == null) {
          viewStateDeal(WalletConnectState.error, params: 'Sui chain not configured');
          return;
        }
        final credentials = await getSuiCredentials();
        final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
        final sig = await trustdart.signMessage(
          CoinType.SUI.name, path, message,
          mnemonic: credentials.mnemonic, pk: credentials.privateKey,
        );
        signClient!.respondSessionRequest(
          topic: eventData.topic,
          response: wallet_connect.JsonRpcResponse(
            id: eventData.id,
            result: {"signature": sig},
          ),
        );
        viewStateDeal(WalletConnectState.connect);
        return;
      } else if (eventData.method == "solana_signMessage") {
        final requestParams = eventData.params! as Map;
        // DApp sends base64-encoded message bytes
        final dataToSign = requestParams["message"] as String? ?? '';
        final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.SOL.name).firstOrNull;
        if (cm == null) {
          viewStateDeal(WalletConnectState.error, params: 'Solana chain not configured');
          return;
        }
        final credentials = await getSolanaCredentials();
        final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
        // Native signMessage for SOL decodes base64 and returns base64 signature
        final sig = await trustdart.signMessage(
          CoinType.SOL.name, path, dataToSign,
          mnemonic: credentials.mnemonic, pk: credentials.privateKey,
        );
        signClient!.respondSessionRequest(
          topic: eventData.topic,
          response: wallet_connect.JsonRpcResponse(
            id: eventData.id,
            result: {"signature": sig},
          ),
        );
        viewStateDeal(WalletConnectState.connect);
        return;
      } else if (eventData.method == "eth_sign") {
        // eth_sign signs arbitrary data and can be exploited to phish
        // transaction signatures. Reject it — DApps should use personal_sign.
        signClient!.respondSessionRequest(
          topic: eventData.topic,
          response: wallet_connect.JsonRpcResponse(
            id: eventData.id,
            error: wallet_connect.JsonRpcError(
              code: 4200,
              message: 'eth_sign is disabled for security reasons. Use personal_sign instead.',
            ),
          ),
        );
        viewStateDeal(WalletConnectState.connect);
        return;
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

      if (eventData.method == "solana_signTransaction" ||
          eventData.method == "solana_signAndSendTransaction") {
        await _handleSolanaTransaction(eventData);
        return;
      }

      if (eventData.method == "aptos_signTransaction" ||
          eventData.method == "aptos_signAndSubmitTransaction") {
        await _handleAptosTransaction(eventData);
        return;
      }

      if (eventData.method == "sui_signTransaction" ||
          eventData.method == "sui_signAndExecuteTransaction") {
        await _handleSuiTransaction(eventData);
        return;
      }

      if (eventData.method == "near_signTransaction" ||
          eventData.method == "near_signAndSendTransaction") {
        await _handleNearTransaction(eventData);
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

  Future<void> _handleSolanaTransaction(wallet_connect.SessionRequestEvent eventData) async {
    final requestParams = eventData.params! as Map;
    // DApp sends a base64-encoded serialized transaction
    final rawTxBase64 = requestParams["transaction"] as String? ?? '';
    final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.SOL.name).firstOrNull;
    if (cm == null) {
      viewStateDeal(WalletConnectState.error, params: 'Solana chain not configured');
      return;
    }
    final credentials = await getSolanaCredentials();
    final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);

    // trustdart signs the raw serialized transaction and returns base64 signed tx
    final txData = {
      "type": "WC_SOL",
      "transaction": rawTxBase64,
      "encodeType": "base64",
    };
    final signedTxBase64 = await trustdart.signTransaction(
      CoinType.SOL.name, path, txData,
      mnemonic: credentials.mnemonic, pk: credentials.privateKey,
    );

    if (signedTxBase64.isEmpty) {
      viewStateDeal(WalletConnectState.error, params: 'Solana transaction signing failed');
      return;
    }

    if (eventData.method == "solana_signAndSendTransaction") {
      // Broadcast the signed transaction
      final solApi = SolApi();
      final result = await solApi.sendTransaction(signedTxBase64);
      if (result.error) {
        viewStateDeal(WalletConnectState.error, params: result.data?.toString() ?? 'Broadcast failed');
        return;
      }
      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(
          id: eventData.id,
          result: {"signature": result.data},
        ),
      );
    } else {
      // solana_signTransaction: return the signed transaction
      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(
          id: eventData.id,
          result: {"transaction": signedTxBase64},
        ),
      );
    }
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
        _parseHexOrDecBigInt(value ?? "0x0"),
      ),
      // DApps send gas values as hex strings in wei per JSON-RPC spec.
      // Must use EtherUnit.wei, NOT gwei, to avoid 10^9x overcharge.
      gasPrice: gasPrice != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.wei, _parseHexOrDecBigInt(gasPrice))
          : null,
      maxFeePerGas: maxFeePerGas != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.wei, _parseHexOrDecBigInt(maxFeePerGas))
          : null,
      maxPriorityFeePerGas: maxPriorityFeePerGas != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.wei, _parseHexOrDecBigInt(maxPriorityFeePerGas))
          : null,
      maxGas: gasLimit != null ? _parseHexOrDecInt(gasLimit) : null,
      nonce: nonce != null ? _parseHexOrDecInt(nonce) : null,
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

  /// Parse a hex (0x-prefixed) or decimal string to BigInt.
  /// DApps send values as hex per JSON-RPC spec (e.g. "0xde0b6b3a7640000").
  static BigInt _parseHexOrDecBigInt(String s) {
    if (s.startsWith('0x') || s.startsWith('0X')) {
      return BigInt.tryParse(s.substring(2), radix: 16) ?? BigInt.zero;
    }
    return BigInt.tryParse(s) ?? BigInt.zero;
  }

  /// Parse a hex (0x-prefixed) or decimal string to int.
  static int? _parseHexOrDecInt(String s) {
    if (s.startsWith('0x') || s.startsWith('0X')) {
      return int.tryParse(s.substring(2), radix: 16);
    }
    return int.tryParse(s);
  }

  static final RegExp _hexRegExp = RegExp(r'^[0-9a-fA-F]+$');

  Future<void> _handleAptosTransaction(wallet_connect.SessionRequestEvent eventData) async {
    final requestParams = eventData.params! as Map;
    // DApp sends pre-built BCS-encoded raw transaction (base64 or hex)
    final rawTx = requestParams["encodedTransaction"] as String? ??
        (requestParams["transaction"] as String? ?? '');
    final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.APT.name).firstOrNull;
    if (cm == null) {
      viewStateDeal(WalletConnectState.error, params: 'Aptos chain not configured');
      return;
    }
    final credentials = await getAptosCredentials();
    final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
    final txData = {
      "type": "WC_APT",
      "encodedTransaction": rawTx,
    };
    final signedHex = await trustdart.signTransaction(
      CoinType.APT.name, path, txData,
      mnemonic: credentials.mnemonic, pk: credentials.privateKey,
    );
    if (signedHex.isEmpty) {
      viewStateDeal(WalletConnectState.error, params: 'Aptos transaction signing failed');
      return;
    }

    if (eventData.method == "aptos_signAndSubmitTransaction") {
      final aptApi = AptApi(isTest: cm.isTest);
      final result = await aptApi.sendTxHash(signedHex);
      if (result.error) {
        viewStateDeal(WalletConnectState.error, params: result.data?.toString() ?? 'Broadcast failed');
        return;
      }
      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(
          id: eventData.id,
          result: {"hash": result.data},
        ),
      );
    } else {
      // aptos_signTransaction: return signed bytes
      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(
          id: eventData.id,
          result: {"signedTransaction": signedHex},
        ),
      );
    }
    viewStateDeal(WalletConnectState.connect);
  }

  Future<void> _handleSuiTransaction(wallet_connect.SessionRequestEvent eventData) async {
    final requestParams = eventData.params! as Map;
    // DApp sends base64-encoded transaction block
    final txBlock = requestParams["transactionBlock"] as String? ??
        (requestParams["transaction"] as String? ?? '');
    final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.SUI.name).firstOrNull;
    if (cm == null) {
      viewStateDeal(WalletConnectState.error, params: 'Sui chain not configured');
      return;
    }
    final credentials = await getSuiCredentials();
    final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);
    final txData = {
      "type": "WC_SUI",
      "transaction": txBlock,
    };
    final signedResult = await trustdart.signTransaction(
      CoinType.SUI.name, path, txData,
      mnemonic: credentials.mnemonic, pk: credentials.privateKey,
    );
    if (signedResult.isEmpty) {
      viewStateDeal(WalletConnectState.error, params: 'Sui transaction signing failed');
      return;
    }
    // signedResult is base64(flag+sig+pubkey) as returned by native code
    signClient!.respondSessionRequest(
      topic: eventData.topic,
      response: wallet_connect.JsonRpcResponse(
        id: eventData.id,
        result: {
          "signature": signedResult,
          "transactionBlock": txBlock,
        },
      ),
    );
    viewStateDeal(WalletConnectState.connect);
  }

  Future<void> _handleNearTransaction(wallet_connect.SessionRequestEvent eventData) async {
    final requestParams = eventData.params! as Map;
    // DApp sends either a list of base64-encoded borsh transactions or a single one
    final txList = requestParams["transactions"];
    final List<String> rawTxList;
    if (txList is List) {
      rawTxList = txList.map((e) => e.toString()).toList();
    } else {
      final single = requestParams["transaction"] as String? ?? '';
      rawTxList = single.isNotEmpty ? [single] : [];
    }
    if (rawTxList.isEmpty) {
      viewStateDeal(WalletConnectState.error, params: 'NEAR: no transaction provided');
      return;
    }
    final cm = coinModels.where((c) => c.coin['coinType'] == CoinType.NEAR.name).firstOrNull;
    if (cm == null) {
      viewStateDeal(WalletConnectState.error, params: 'NEAR chain not configured');
      return;
    }
    final credentials = await getNearCredentials();
    final path = getPathWithIndex(cm.coin['path'][cm.addrType], cm.pathIndex);

    final signedTxList = <String>[];
    for (final rawTx in rawTxList) {
      final txData = {"type": "WC_NEAR", "transaction": rawTx};
      final signed = await trustdart.signTransaction(
        CoinType.NEAR.name, path, txData,
        mnemonic: credentials.mnemonic, pk: credentials.privateKey,
      );
      if (signed.isEmpty) {
        viewStateDeal(WalletConnectState.error, params: 'NEAR transaction signing failed');
        return;
      }
      signedTxList.add(signed);
    }

    if (eventData.method == "near_signAndSendTransaction") {
      final nearApi = NearApi(isTest: cm.isTest);
      // Broadcast first transaction
      final result = await nearApi.sendTransaction(signedTxList[0]);
      if (result.error) {
        viewStateDeal(WalletConnectState.error, params: result.data?.toString() ?? 'Broadcast failed');
        return;
      }
      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(
          id: eventData.id,
          result: result.data,
        ),
      );
    } else {
      signClient!.respondSessionRequest(
        topic: eventData.topic,
        response: wallet_connect.JsonRpcResponse(
          id: eventData.id,
          result: signedTxList.length == 1 ? signedTxList[0] : signedTxList,
        ),
      );
    }
    viewStateDeal(WalletConnectState.connect);
  }

  /// Returns true if [s] contains only hex characters (0-9, a-f, A-F).
  /// Empty string returns false to avoid creating a zero-length byte array.
  static bool _isValidHex(String s) {
    if (s.isEmpty) return false;
    return _hexRegExp.hasMatch(s);
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
