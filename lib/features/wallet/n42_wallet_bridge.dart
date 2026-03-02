// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';

/// N42 钱包桥接实现
///
/// 将主应用的钱包功能桥接到 n42_chat 插件
class N42WalletBridge implements IWalletBridge {
  WalletActionProvider? _walletProvider;

  WalletActionProvider? get _provider {
    if (_walletProvider != null) return _walletProvider;
    try {
      _walletProvider = globalWapAdapter;
    } catch (e) {
      if (kDebugMode) debugPrint('N42WalletBridge: Failed to get WalletActionProvider: $e');
    }
    return _walletProvider;
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
    // 转账功能需要导航到转账页面，这里暂时返回取消
    // TODO: 实现实际转账逻辑
    if (kDebugMode) debugPrint('N42WalletBridge: Transfer requested - to: $toAddress, amount: $amount $token');
    return TransferResult.cancelled();
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
    // TODO: 导航到收款二维码页面
    if (kDebugMode) debugPrint('N42WalletBridge: Show receive QR code requested');
  }

  static final _ethAddressRegExp = RegExp(r'^0x[0-9a-fA-F]{40}$');

  @override
  bool isValidAddress(String address) {
    // ETH address: 0x + 40 hex chars, or N chain address (30-50 chars)
    return _ethAddressRegExp.hasMatch(address) ||
        (address.startsWith('N') && address.length >= 30 && address.length <= 50);
  }

  @override
  Future<WalletUserInfo?> getUserInfoByAddress(String address) async {
    // TODO: 从地址簿或服务器获取用户信息
    return null;
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
      if (kDebugMode) debugPrint('N42WalletBridge: Failed to resolve ENS name: $e');
      return null;
    }
  }

  @override
  Future<String?> lookupEnsName(String address) async {
    try {
      return await _ensService.resolveAddress(address);
    } catch (e) {
      if (kDebugMode) debugPrint('N42WalletBridge: Failed to lookup ENS name: $e');
      return null;
    }
  }

  @override
  Future<String?> getEnsAvatar(String ensName) async {
    try {
      return await _ensService.getAvatar(ensName);
    } catch (e) {
      if (kDebugMode) debugPrint('N42WalletBridge: Failed to get ENS avatar: $e');
      return null;
    }
  }

  @override
  Future<Map<String, String?>> batchLookupEnsNames(List<String> addresses) async {
    try {
      return await _ensService.resolveAddresses(addresses);
    } catch (e) {
      if (kDebugMode) debugPrint('N42WalletBridge: Failed to batch lookup ENS: $e');
      return {for (final addr in addresses) addr: null};
    }
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
    try {
      final address = walletAddress;
      if (address == null) return null;

      // 通过 TokenViewApi 查询 NFT tokenURI
      final result = await _tokenViewApi.getBalanceEth('ETH', address, contractAddress);
      if (!result.error && result.data != null) {
        // tokenURI 通常需要通过合约调用获取，当前 API 不直接支持
        // 返回 null 由调用方处理
        return null;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('N42WalletBridge: Failed to get ERC-721 tokenURI: $e');
      return null;
    }
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
      if (kDebugMode) debugPrint('N42WalletBridge: Failed to get $tokenStandard balance: $e');
      return '0';
    }
  }
}
