// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/api/address_book_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show getPathWithIndex;
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:eip712/eip712.dart';

/// N42 钱包桥接实现
///
/// 将主应用的钱包功能桥接到 n42_chat 插件
class N42WalletBridge implements IWalletBridge {
  WalletActionProvider? get _provider {
    try {
      return globalWapAdapter;
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'failed to get WalletActionProvider: $e');
      return null;
    }
  }

  @override
  bool get isWalletConnected {
    final provider = _provider;
    return provider != null && provider.walletInfoLsit.isNotEmpty;
  }

  @override
  String? get walletAddress {
    final provider = _provider;
    if (provider == null) return null;

    // 优先获取 ETH 地址作为默认收款地址，其次 N 链地址
    for (final chain in ['ETH', 'N']) {
      final addr = provider.getAddress(chain)?.toString();
      if (addr != null && addr.isNotEmpty) return addr;
    }

    // 尝试从 coinModels 获取第一个有效地址
    for (final coinModel in provider.coinModels) {
      final addr = coinModel.address?.toString();
      if (addr != null && addr.isNotEmpty) return addr;
    }

    return null;
  }

  @override
  Future<List<TokenInfo>> getSupportedTokens() async {
    final provider = _provider;
    if (provider == null) return [];

    final tokens = <TokenInfo>[];

    for (final coinModel in provider.coinModels) {
      final coinType = coinModel.coin['coinType'] as String?;
      final miniName = coinModel.coin['miniName'] as String?;
      final decimals = coinModel.coin['decimal'] as int? ?? 18;
      final icon = coinModel.coin['icon'] as String?;

      if (coinType != null) {
        tokens.add(TokenInfo(
          symbol: miniName ?? coinType,
          name: coinModel.coin['name'] as String? ?? coinType,
          decimals: decimals,
          iconUrl: icon,
          isNative: coinModel.coin['isContract'] != true,
        ));
      }
    }

    return tokens;
  }

  @override
  Future<String> getBalance(String token) async {
    final provider = _provider;
    if (provider == null) return '0';

    // 查找对应的 coinModel
    for (final coinModel in provider.coinModels) {
      final miniName = coinModel.coin['miniName'] as String?;
      final coinType = coinModel.coin['coinType'] as String?;

      if (miniName?.toUpperCase() == token.toUpperCase() ||
          coinType?.toUpperCase() == token.toUpperCase()) {
        return coinModel.balanceStringAll();
      }
    }

    return '0';
  }

  @override
  Future<TransferResult> requestTransfer({
    required String toAddress,
    required String amount,
    required String token,
    String? memo,
  }) async {
    try {
      if (!isWalletConnected) {
        return TransferResult.failure('Wallet not connected');
      }

      final value = double.tryParse(amount) ?? 0.0;
      if (value <= 0) {
        return TransferResult.failure('Invalid transfer amount');
      }

      final provider = _provider;
      if (provider == null) return TransferResult.failure('Wallet not connected');

      // Find CoinModel matching the token symbol
      CoinModel? coinModel;
      for (final cm in provider.coinModels) {
        final coinType = cm.coin['coinType'] as String? ?? '';
        final miniName = cm.coin['miniName'] as String? ?? '';
        if (coinType.toUpperCase() == token.toUpperCase() ||
            miniName.toUpperCase() == token.toUpperCase()) {
          coinModel = cm;
          break;
        }
      }
      if (coinModel == null) {
        return TransferResult.failure('Token $token not found in wallet');
      }

      final addrType = coinModel.addrType;
      final baseInfo = coinModel.coin['baseInfo'] as Map<String, dynamic>?;
      final pathMap = baseInfo?['path'] as Map<String, dynamic>?;
      final basePath = pathMap?[addrType]?.toString() ?? "m/44'/60'/0'/0/0";
      final path = getPathWithIndex(basePath, coinModel.pathIndex);
      final decimals = (coinModel.coin['decimals'] as num?)?.toInt() ?? 18;
      final coinType = coinModel.coin['coinType'] as String? ?? token;
      final contractAddress = coinModel.coin['isContract'] == true
          ? (coinModel.coin['contract'] as String? ?? '')
          : '';

      final result = await SenderFactory.instance.getSender(coinType).send(
        SendParams(
          coinType: coinType,
          fromAddress: coinModel.address.toString(),
          toAddress: toAddress,
          amount: value,
          decimals: decimals,
          path: path,
          isTest: false,
          contractAddress: contractAddress,
          tokenDecimals: contractAddress.isNotEmpty ? decimals : 0,
          memo: memo,
          chainConfig: coinModel.coin,
        ),
      );

      if (!result.success) {
        return TransferResult.failure(result.error ?? 'Transfer failed');
      }
      return TransferResult.success(result.txHash ?? '');
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'transfer error: $e');
      return TransferResult.failure(e.toString());
    }
  }

  @override
  Future<PaymentRequest> generatePaymentRequest({
    required String amount,
    required String token,
    String? memo,
  }) async {
    final address = walletAddress ?? '';
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();

    final qrUri = Uri(
      scheme: 'n42',
      host: 'pay',
      queryParameters: {
        'address': address,
        'amount': amount,
        'token': token,
        // ignore: use_null_aware_elements
        if (memo != null) 'memo': memo,
      },
    );

    return PaymentRequest(
      requestId: requestId,
      amount: amount,
      token: token,
      receiverAddress: address,
      memo: memo,
      qrCodeData: qrUri.toString(),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
    );
  }

  @override
  Future<void> showReceiveQRCode() async {
    try {
      final provider = _provider;
      if (provider == null) return;

      // 找到 ETH 主链 coinModel 作为默认收款链
      CoinModel? chainCoin;
      for (final cm in provider.coinModels) {
        final coinType = cm.coin['coinType'] as String?;
        if (coinType == CoinType.ETH.name && cm.coin['isContract'] != true) {
          chainCoin = cm;
          break;
        }
      }
      chainCoin ??= provider.coinModels.isNotEmpty
          ? provider.coinModels.first
          : null;
      if (chainCoin == null) return;

      final context = AppGlobals.navigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WalletReceiveQr(chainCoin!),
        ),
      );
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'showReceiveQRCode error: $e');
    }
  }

  static final _ethAddressRegExp = RegExp(r'^0x[0-9a-fA-F]{40}$');

  @override
  bool isValidAddress(String address) {
    // ETH address: 0x + 40 hex chars, or N chain address (30-50 chars)
    return _ethAddressRegExp.hasMatch(address) ||
        (address.startsWith('N') && address.length >= 30 && address.length <= 50);
  }

  final AddressBookApi _addressBookApi = AddressBookApi();

  @override
  Future<WalletUserInfo?> getUserInfoByAddress(String address) async {
    try {
      final results = await _addressBookApi.searchAddressBook(address);
      for (final item in results) {
        if (item.address?.toLowerCase() == address.toLowerCase()) {
          return WalletUserInfo(
            address: address,
            username: item.name,
          );
        }
      }
      return null;
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'getUserInfoByAddress error: $e');
      return null;
    }
  }

  // ============================================
  // ENS 集成
  // ============================================

  final EnsService _ensService = EnsServiceProvider.instance;

  @override
  Future<String?> resolveEnsName(String ensName) async {
    try {
      final result = await _ensService.resolveName(ensName);
      return result.success ? result.address : null;
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'failed to resolve ENS name: $e');
      return null;
    }
  }

  @override
  Future<String?> lookupEnsName(String address) async {
    try {
      return await _ensService.resolveAddress(address);
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'failed to lookup ENS name: $e');
      return null;
    }
  }

  @override
  Future<String?> getEnsAvatar(String ensName) async {
    try {
      return await _ensService.getAvatar(ensName);
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'failed to get ENS avatar: $e');
      return null;
    }
  }

  @override
  Future<Map<String, String?>> batchLookupEnsNames(List<String> addresses) async {
    try {
      return await _ensService.resolveAddresses(addresses);
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'failed to batch lookup ENS: $e');
      return {for (final addr in addresses) addr: null};
    }
  }

  // ============================================
  // 消息签名（治理投票等）
  // ============================================

  @override
  Future<String?> signMessage(String message) async {
    try {
      final ethKey = await _getEthPrivateKey();
      if (ethKey == null) return null;

      // Detect hex-encoded vs UTF-8 message
      final Uint8List encodedMessage;
      if (message.startsWith('0x')) {
        final stripped = message.substring(2);
        encodedMessage = _isValidHex(stripped)
            ? web3.hexToBytes(stripped)
            : Uint8List.fromList(utf8.encode(message));
      } else {
        encodedMessage = Uint8List.fromList(utf8.encode(message));
      }

      final signedData = ethKey.signPersonalMessageToUint8List(encodedMessage);
      final result = web3.bytesToHex(signedData, include0x: true);
      _zeroKey(ethKey);
      return result;
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'signMessage error: $e');
      return null;
    }
  }

  @override
  Future<String?> signTypedData(String typedDataJson) async {
    try {
      final ethKey = await _getEthPrivateKey();
      if (ethKey == null) return null;

      final Map<String, dynamic> typedData = json.decode(typedDataJson);
      const requiredFields = ['types', 'primaryType', 'domain', 'message'];
      for (final field in requiredFields) {
        if (!typedData.containsKey(field)) {
          AppLogger.w(
            'N42WalletBridge',
            'missing EIP-712 field "$field"',
          );
          return null;
        }
      }

      final typedMessage = TypedMessage.fromJson(typedData);
      final hash = hashTypedData(typedData: typedMessage, version: TypedDataVersion.v4);
      final signature = web3.sign(hash, ethKey.privateKey);

      final r = signature.r.toRadixString(16).padLeft(64, '0');
      final s = signature.s.toRadixString(16).padLeft(64, '0');
      final v = signature.v.toRadixString(16).padLeft(2, '0');
      final result = '0x$r$s$v';
      _zeroKey(ethKey);
      return result;
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'signTypedData error: $e');
      return null;
    }
  }

  /// 获取 ETH 链的私钥用于签名
  Future<web3.EthPrivateKey?> _getEthPrivateKey() async {
    try {
      final provider = _provider;
      if (provider == null) return null;

      // 查找 ETH coinModel
      CoinModel? ethCoin;
      for (final cm in provider.coinModels) {
        if (cm.coin['coinType'] == CoinType.ETH.name &&
            cm.coin['isContract'] != true) {
          ethCoin = cm;
          break;
        }
      }
      if (ethCoin == null) return null;

      final walletService = globalProviderContainer.read(walletServiceProvider);
      if (walletService == null) return null;

      final walletIndex = provider.walletIndex;
      String? pKey = await walletService.getPrivateKeyForWallet(walletIndex);

      if (pKey == null) {
        final mnemonic = await walletService.getMnemonicForWallet(walletIndex);
        if (mnemonic != null) {
          final path = getPathWithIndex(
            ethCoin.coin['path']?['legacy'] ?? "m/44'/60'/0'/0/0",
            ethCoin.pathIndex,
          );
          pKey = await Trustdart().getPrivateKey(mnemonic, CoinType.ETH.name, path);
        }
      }

      if (pKey == null) return null;

      final decodedKey = base64Decode(pKey);
      if (decodedKey.length != 32) return null;

      final ethKey = web3.EthPrivateKey(Uint8List.fromList(decodedKey));
      // Zero out the decoded key bytes from memory
      decodedKey.fillRange(0, decodedKey.length, 0);
      return ethKey;
    } catch (e) {
      AppLogger.w('N42WalletBridge', '_getEthPrivateKey error: $e');
      return null;
    }
  }

  /// Zero out the private key bytes to minimize in-memory exposure.
  void _zeroKey(web3.EthPrivateKey key) {
    try {
      key.privateKey.fillRange(0, key.privateKey.length, 0);
    } catch (_) {
      // privateKey may be unmodifiable; best-effort zeroing
    }
  }

  static final _hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
  static bool _isValidHex(String s) {
    if (s.isEmpty || s.length.isOdd) return false;
    return _hexRegExp.hasMatch(s);
  }

  // ============================================
  // 代币门控
  // ============================================

  final TokenViewApi _tokenViewApi = TokenViewApi();

  @override
  Future<BigInt> getErc20Balance({
    required String contractAddress,
    required int chainId,
    String? ownerAddress,
  }) async {
    final raw = await _queryTokenBalance(contractAddress, ownerAddress, 'ERC-20');
    return BigInt.tryParse(raw) ?? BigInt.zero;
  }

  @override
  Future<int> getErc721Balance({
    required String contractAddress,
    required int chainId,
    String? ownerAddress,
  }) async {
    // Use ERC-20 balance query as proxy - NFT balance returns count
    final raw = await _queryTokenBalance(contractAddress, ownerAddress, 'ERC-721');
    return int.tryParse(raw) ?? 0;
  }

  @override
  Future<BigInt> getErc1155Balance({
    required String contractAddress,
    required BigInt tokenId,
    required int chainId,
    String? ownerAddress,
  }) async {
    // ERC-1155 balanceOf(address, tokenId) - query via token API
    final raw = await _queryTokenBalance(contractAddress, ownerAddress, 'ERC-1155');
    return BigInt.tryParse(raw) ?? BigInt.zero;
  }

  @override
  Future<String?> getErc721TokenUri({
    required String contractAddress,
    required int tokenId,
    required int chainId,
  }) async {
    // tokenURI requires a dedicated contract call not supported by current API
    return null;
  }

  /// Query token balance via TokenViewApi; returns raw balance string or '0'.
  Future<String> _queryTokenBalance(
    String contractAddress,
    String? ownerAddress,
    String tokenStandard,
  ) async {
    try {
      final address = ownerAddress ?? walletAddress;
      if (address == null) return '0';

      final result = await _tokenViewApi.getBalanceEth('ETH', address, contractAddress);
      if (!result.error && result.data != null) {
        return result.data.toString();
      }
      return '0';
    } catch (e) {
      AppLogger.w(
        'N42WalletBridge',
        'failed to get $tokenStandard balance: $e',
      );
      return '0';
    }
  }
}
