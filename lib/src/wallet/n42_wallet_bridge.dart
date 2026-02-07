// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/services/ens_service.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:provider/provider.dart';

/// N42 钱包桥接实现
///
/// 将主应用的钱包功能桥接到 n42_chat 插件
class N42WalletBridge implements IWalletBridge {
  WalletActionProvider? _walletProvider;

  WalletActionProvider? get _provider {
    if (_walletProvider != null) return _walletProvider;
    try {
      if (AppGlobals.appContext.mounted) {
        _walletProvider = Provider.of<WalletActionProvider>(
          AppGlobals.appContext,
          listen: false,
        );
      }
    } catch (e) {
      debugPrint('N42WalletBridge: Failed to get WalletActionProvider: $e');
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

    // 优先获取 ETH 地址作为默认收款地址
    final ethAddress = provider.getAddress('ETH');
    if (ethAddress != null && ethAddress.toString().isNotEmpty) {
      return ethAddress.toString();
    }

    // 如果没有 ETH 地址，尝试获取 N 链地址
    final nAddress = provider.getAddress('N');
    if (nAddress != null && nAddress.toString().isNotEmpty) {
      return nAddress.toString();
    }

    // 尝试从 coinModels 获取第一个有效地址
    for (final coinModel in provider.coinModels) {
      if (coinModel.address != null && coinModel.address.toString().isNotEmpty) {
        return coinModel.address.toString();
      }
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
    debugPrint('N42WalletBridge: Transfer requested - to: $toAddress, amount: $amount $token');
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

    return PaymentRequest(
      requestId: requestId,
      amount: amount,
      token: token,
      receiverAddress: address,
      memo: memo,
      qrCodeData: 'n42://pay?address=$address&amount=$amount&token=$token${memo != null ? '&memo=$memo' : ''}',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
    );
  }

  @override
  Future<void> showReceiveQRCode() async {
    // TODO: 导航到收款二维码页面
    debugPrint('N42WalletBridge: Show receive QR code requested');
  }

  @override
  bool isValidAddress(String address) {
    // 支持 ETH 地址格式 (0x...)
    if (address.startsWith('0x') && address.length == 42) {
      return true;
    }
    // 支持 N 链地址格式
    if (address.startsWith('N') && address.length >= 30) {
      return true;
    }
    return false;
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
      debugPrint('N42WalletBridge: Failed to resolve ENS name: $e');
      return null;
    }
  }

  @override
  Future<String?> lookupEnsName(String address) async {
    try {
      return await _ensService.resolveAddress(address);
    } catch (e) {
      debugPrint('N42WalletBridge: Failed to lookup ENS name: $e');
      return null;
    }
  }

  @override
  Future<String?> getEnsAvatar(String ensName) async {
    try {
      return await _ensService.getAvatar(ensName);
    } catch (e) {
      debugPrint('N42WalletBridge: Failed to get ENS avatar: $e');
      return null;
    }
  }

  @override
  Future<Map<String, String?>> batchLookupEnsNames(List<String> addresses) async {
    try {
      return await _ensService.resolveAddresses(addresses);
    } catch (e) {
      debugPrint('N42WalletBridge: Failed to batch lookup ENS: $e');
      final results = <String, String?>{};
      for (final addr in addresses) {
        results[addr] = null;
      }
      return results;
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
    try {
      final address = ownerAddress ?? walletAddress;
      if (address == null) return BigInt.zero;

      final result = await _tokenViewApi.getBalanceEth(
        'ETH',
        address,
        contractAddress,
      );

      if (!result.error && result.data != null) {
        final balanceStr = result.data.toString();
        return BigInt.tryParse(balanceStr) ?? BigInt.zero;
      }
      return BigInt.zero;
    } catch (e) {
      debugPrint('N42WalletBridge: Failed to get ERC-20 balance: $e');
      return BigInt.zero;
    }
  }

  @override
  Future<int> getErc721Balance({
    required String contractAddress,
    required int chainId,
    String? ownerAddress,
  }) async {
    try {
      final address = ownerAddress ?? walletAddress;
      if (address == null) return 0;

      // Use ERC-20 balance query as proxy - NFT balance returns count
      final result = await _tokenViewApi.getBalanceEth(
        'ETH',
        address,
        contractAddress,
      );

      if (!result.error && result.data != null) {
        final balanceStr = result.data.toString();
        return int.tryParse(balanceStr) ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('N42WalletBridge: Failed to get ERC-721 balance: $e');
      return 0;
    }
  }

  @override
  Future<BigInt> getErc1155Balance({
    required String contractAddress,
    required BigInt tokenId,
    required int chainId,
    String? ownerAddress,
  }) async {
    try {
      final address = ownerAddress ?? walletAddress;
      if (address == null) return BigInt.zero;

      // ERC-1155 balanceOf(address, tokenId) - query via token API
      final result = await _tokenViewApi.getBalanceEth(
        'ETH',
        address,
        contractAddress,
      );

      if (!result.error && result.data != null) {
        final balanceStr = result.data.toString();
        return BigInt.tryParse(balanceStr) ?? BigInt.zero;
      }
      return BigInt.zero;
    } catch (e) {
      debugPrint('N42WalletBridge: Failed to get ERC-1155 balance: $e');
      return BigInt.zero;
    }
  }
}
