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
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/nft_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show getPathWithIndex;
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:eip712/eip712.dart';

final _walletBridgeHexRegExp = RegExp(r'^[0-9a-fA-F]+$');

/// Resolves the token precision used by the Chat wallet bridge.
///
/// Wallet coin records use `decimals`. The singular key is accepted only for
/// compatibility with older imported records.
int resolveWalletBridgeTokenDecimals(
  Map<String, dynamic> coin, {
  int fallback = 18,
}) {
  final value = coin['decimals'] ?? coin['decimal'];
  if (value is! num || value < 0 || value > 255) return fallback;
  final decimals = value.toInt();
  return value == decimals ? decimals : fallback;
}

String buildErc1155BalanceCalldata(String ownerAddress, BigInt tokenId) {
  final owner = ownerAddress.replaceFirst(RegExp(r'^0x'), '');
  if (owner.length != 40 ||
      !_walletBridgeHexRegExp.hasMatch(owner) ||
      tokenId.isNegative) {
    throw ArgumentError('Invalid ERC-1155 balance query');
  }
  final ownerWord = owner.padLeft(64, '0');
  final tokenWord = tokenId.toRadixString(16).padLeft(64, '0');
  return '0x00fdd58e$ownerWord$tokenWord';
}

String buildErc721TokenUriCalldata(BigInt tokenId) {
  if (tokenId.isNegative) throw ArgumentError('Invalid NFT token ID');
  return '0xc87b56dd${tokenId.toRadixString(16).padLeft(64, '0')}';
}

String? decodeAbiString(String raw) {
  final hex = raw.replaceFirst(RegExp(r'^0x'), '');
  if (hex.length < 128 ||
      hex.length.isOdd ||
      !_walletBridgeHexRegExp.hasMatch(hex)) {
    return null;
  }
  try {
    final offset = int.parse(hex.substring(0, 64), radix: 16) * 2;
    if (offset < 0 || offset + 64 > hex.length) return null;
    final length = int.parse(hex.substring(offset, offset + 64), radix: 16);
    final start = offset + 64;
    final end = start + length * 2;
    if (length < 0 || end > hex.length) return null;
    return utf8.decode(web3.hexToBytes(hex.substring(start, end)));
  } catch (_) {
    return null;
  }
}

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
      final decimals = resolveWalletBridgeTokenDecimals(coinModel.coin);
      final icon = coinModel.coin['icon'] as String?;

      if (coinType != null) {
        tokens.add(
          TokenInfo(
            symbol: miniName ?? coinType,
            name: coinModel.coin['name'] as String? ?? coinType,
            decimals: decimals,
            iconUrl: icon,
            isNative: coinModel.coin['isContract'] != true,
          ),
        );
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
      if (provider == null) {
        return TransferResult.failure('Wallet not connected');
      }

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
      // 派生路径取不到时绝不能套用 ETH 路径：非 EVM 币会用一把与 fromAddress
      // 不对应的密钥签名，签出来的交易要么废掉，要么动到别的账户。
      final basePath = coinModel.config.pathForAddrType(addrType);
      if (basePath == null || basePath.isEmpty) {
        return TransferResult.failure(
          'Missing derivation path for $token ($addrType)',
        );
      }
      final path = getPathWithIndex(basePath, coinModel.pathIndex);
      final decimals = resolveWalletBridgeTokenDecimals(coinModel.coin);
      final coinType = coinModel.config.coinType.isNotEmpty
          ? coinModel.config.coinType
          : token;
      final contractAddress = coinModel.config.isContract
          ? coinModel.config.contract
          : '';

      final result = await SenderFactory.instance
          .getSender(coinType, chainConfig: coinModel.coin)
          .send(
            SendParams(
              coinType: coinType,
              fromAddress: coinModel.address.toString(),
              toAddress: toAddress,
              amount: value,
              decimals: decimals,
              path: path,
              isTest: coinModel.isTest,
              contractAddress: contractAddress,
              tokenDecimals: contractAddress.isNotEmpty ? decimals : 0,
              memo: memo,
              privateKey: coinModel.privateKey,
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
        'memo': ?memo,
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

      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => WalletReceiveQr(chainCoin!)));
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'showReceiveQRCode error: $e');
    }
  }

  static final _ethAddressRegExp = RegExp(r'^0x[0-9a-fA-F]{40}$');

  @override
  bool isValidAddress(String address) {
    // ETH address: 0x + 40 hex chars, or N chain address (30-50 chars)
    return _ethAddressRegExp.hasMatch(address) ||
        (address.startsWith('N') &&
            address.length >= 30 &&
            address.length <= 50);
  }

  final AddressBookApi _addressBookApi = AddressBookApi();

  @override
  Future<WalletUserInfo?> getUserInfoByAddress(String address) async {
    try {
      final results = await _addressBookApi.searchAddressBook(address);
      for (final item in results) {
        if (item.address?.toLowerCase() == address.toLowerCase()) {
          return WalletUserInfo(address: address, username: item.name);
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
  Future<Map<String, String?>> batchLookupEnsNames(
    List<String> addresses,
  ) async {
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
    web3.EthPrivateKey? ethKey;
    try {
      ethKey = await _getEthPrivateKey();
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
      return result;
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'signMessage error: $e');
      return null;
    } finally {
      if (ethKey != null) {
        _zeroKey(ethKey);
      }
    }
  }

  @override
  Future<String?> signTypedData(String typedDataJson) async {
    web3.EthPrivateKey? ethKey;
    try {
      final decoded = json.decode(typedDataJson);
      if (decoded is! Map<String, dynamic>) {
        AppLogger.w('N42WalletBridge', 'invalid EIP-712 payload');
        return null;
      }
      final typedData = decoded;
      const requiredFields = ['types', 'primaryType', 'domain', 'message'];
      for (final field in requiredFields) {
        if (!typedData.containsKey(field)) {
          AppLogger.w('N42WalletBridge', 'missing EIP-712 field "$field"');
          return null;
        }
      }

      ethKey = await _getEthPrivateKey();
      if (ethKey == null) return null;

      final typedMessage = TypedMessage.fromJson(typedData);
      final hash = hashTypedData(
        typedData: typedMessage,
        version: TypedDataVersion.v4,
      );
      final signature = web3.sign(hash, ethKey.privateKey);

      final r = signature.r.toRadixString(16).padLeft(64, '0');
      final s = signature.s.toRadixString(16).padLeft(64, '0');
      final v = signature.v.toRadixString(16).padLeft(2, '0');
      final result = '0x$r$s$v';
      return result;
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'signTypedData error: $e');
      return null;
    } finally {
      if (ethKey != null) {
        _zeroKey(ethKey);
      }
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
          pKey = await Trustdart().getPrivateKey(
            mnemonic,
            CoinType.ETH.name,
            path,
          );
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
    final raw = await _queryTokenBalance(
      contractAddress,
      ownerAddress,
      'ERC-20',
      chainId,
    );
    return BigInt.tryParse(raw) ?? BigInt.zero;
  }

  @override
  Future<int> getErc721Balance({
    required String contractAddress,
    required int chainId,
    String? ownerAddress,
  }) async {
    // Use ERC-20 balance query as proxy - NFT balance returns count
    final raw = await _queryTokenBalance(
      contractAddress,
      ownerAddress,
      'ERC-721',
      chainId,
    );
    return int.tryParse(raw) ?? 0;
  }

  @override
  Future<BigInt> getErc1155Balance({
    required String contractAddress,
    required BigInt tokenId,
    required int chainId,
    String? ownerAddress,
  }) async {
    final address = ownerAddress ?? walletAddress;
    final provider = _provider;
    if (address == null ||
        provider == null ||
        !_ethAddressRegExp.hasMatch(contractAddress) ||
        !_ethAddressRegExp.hasMatch(address)) {
      return BigInt.zero;
    }
    final coinModel = _findEvmChainCoin(provider, chainId);
    if (coinModel == null) return BigInt.zero;
    try {
      final data = buildErc1155BalanceCalldata(address, tokenId);
      final result = await _ethCall(coinModel, contractAddress, data);
      if (result.error) return BigInt.zero;
      final hex = result.data?.toString() ?? '';
      return hex.startsWith('0x')
          ? BigInt.tryParse(hex.substring(2), radix: 16) ?? BigInt.zero
          : BigInt.zero;
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'failed to get ERC-1155 balance: $e');
      return BigInt.zero;
    }
  }

  @override
  Future<String?> getErc721TokenUri({
    required String contractAddress,
    required int tokenId,
    required int chainId,
  }) async {
    final provider = _provider;
    if (provider == null || !_ethAddressRegExp.hasMatch(contractAddress)) {
      return null;
    }
    final coinModel = _findEvmChainCoin(provider, chainId);
    if (coinModel == null) return null;
    try {
      final result = await _ethCall(
        coinModel,
        contractAddress,
        buildErc721TokenUriCalldata(BigInt.from(tokenId)),
      );
      if (result.error) return null;
      return decodeAbiString(result.data?.toString() ?? '');
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'failed to get ERC-721 token URI: $e');
      return null;
    }
  }

  @override
  Future<TransferResult> requestNftTransfer({
    required String contractAddress,
    required String tokenId,
    required String toAddress,
    required int chainId,
    NftStandard standard = NftStandard.erc721,
    int amount = 1,
  }) async {
    try {
      if (!isWalletConnected) {
        return TransferResult.failure('Wallet not connected');
      }
      if (!_ethAddressRegExp.hasMatch(contractAddress) ||
          !_ethAddressRegExp.hasMatch(toAddress)) {
        return TransferResult.failure('Invalid NFT transfer address');
      }
      if (BigInt.tryParse(tokenId) == null) {
        return TransferResult.failure('Invalid NFT token ID');
      }
      if (standard == NftStandard.erc1155 && amount <= 0) {
        return TransferResult.failure('Invalid NFT transfer amount');
      }

      final provider = _provider;
      if (provider == null) {
        return TransferResult.failure('Wallet not connected');
      }

      final coinModel = _findEvmChainCoin(provider, chainId);
      if (coinModel == null) {
        return TransferResult.failure('Chain $chainId not found in wallet');
      }

      final addrType = coinModel.addrType;
      final basePath =
          coinModel.config.pathForAddrType(addrType) ?? "m/44'/60'/0'/0/0";
      final path = getPathWithIndex(basePath, coinModel.pathIndex);
      final coinType = coinModel.coin['coinType'] as String? ?? 'ETH';
      final nftStandard = standard == NftStandard.erc1155
          ? 'ERC1155'
          : 'ERC721';

      final result = await NftSender().send(
        SendParams(
          coinType: coinType,
          fromAddress: coinModel.address.toString(),
          toAddress: toAddress,
          amount: 0.0,
          decimals: resolveWalletBridgeTokenDecimals(coinModel.coin),
          path: path,
          isTest: coinModel.isTest,
          contractAddress: contractAddress,
          nftTokenId: tokenId,
          nftStandard: nftStandard,
          nftQuantity: standard == NftStandard.erc1155 ? amount : 1,
          privateKey: coinModel.privateKey,
          chainConfig: coinModel.coin,
        ),
      );

      if (!result.success) {
        return TransferResult.failure(result.error ?? 'NFT transfer failed');
      }
      return TransferResult.success(result.txHash ?? '');
    } catch (e) {
      AppLogger.w('N42WalletBridge', 'NFT transfer error: $e');
      return TransferResult.failure(e.toString());
    }
  }

  /// Query token balance via TokenViewApi; returns raw balance string or '0'.
  Future<String> _queryTokenBalance(
    String contractAddress,
    String? ownerAddress,
    String tokenStandard,
    int chainId,
  ) async {
    try {
      final address = ownerAddress ?? walletAddress;
      final provider = _provider;
      if (address == null ||
          provider == null ||
          !_ethAddressRegExp.hasMatch(contractAddress) ||
          !_ethAddressRegExp.hasMatch(address)) {
        return '0';
      }
      final coinModel = _findEvmChainCoin(provider, chainId);
      if (coinModel == null) return '0';

      final result = await _tokenViewApi.getBalanceEth(
        coinModel.config.coinType,
        address,
        contractAddress,
        isTest: coinModel.isTest,
        rpc: coinModel.config.custom ? coinModel.config.service : null,
      );
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

  Future<MessageModel> _ethCall(
    CoinModel coinModel,
    String contractAddress,
    String data,
  ) {
    final rpc = coinModel.config.custom ? coinModel.config.service : null;
    return EthAPI.init(null, rpc, null).ethCallRaw(
      contractAddress,
      data,
      coinType: coinModel.config.coinType,
      isTest: coinModel.isTest,
    );
  }

  CoinModel? _findEvmChainCoin(WalletActionProvider provider, int chainId) {
    for (final coinModel in provider.coinModels) {
      if (coinModel.config.isContract) continue;
      // 只按 chainId 匹配会误命中非 EVM 链——Aptos 原生币的 baseInfo 同样
      // 是 chainId: 1，chainId=1 的 ERC 调用会被路由到 APT 模型上。
      if (coinModel.config.blockchainType != BlockchainType.Ethereum.name) {
        continue;
      }
      final modelChainId = _readChainId(coinModel);
      if (modelChainId == chainId) return coinModel;
    }
    return null;
  }

  int? _readChainId(CoinModel coinModel) {
    final chainId = coinModel.config.chainId;
    return chainId == 0 ? null : chainId;
  }
}
