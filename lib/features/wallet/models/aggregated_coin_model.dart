// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

/// 链上余额信息
class ChainBalance {
  final String chainSymbol;
  final String contract;
  final int decimals;
  final int chainId;
  final BigInt balance;
  final String address;

  ChainBalance({
    required this.chainSymbol,
    required this.contract,
    required this.decimals,
    required this.chainId,
    required this.balance,
    required this.address,
  });

  /// 格式化余额
  double get balanceDouble {
    if (balance == BigInt.zero) return 0.0;
    // 使用整数除法避免精度丢失
    final divisor = BigInt.from(10).pow(decimals);
    final intPart = balance ~/ divisor;
    final fracPart = balance.remainder(divisor);
    return intPart.toDouble() + fracPart.toDouble() / divisor.toDouble();
  }
}

/// 聚合代币模型 - 用于主页显示多链聚合的 USDT/USDC
class AggregatedCoinModel extends CoinModel {
  /// 聚合代币配置
  final AggregatedToken tokenConfig;

  /// 各链余额
  final Map<String, ChainBalance> chainBalances = {};

  /// 是否为聚合代币
  bool get isAggregated => true;

  /// 获取总余额（所有链余额之和，转换为统一 6 位精度）
  BigInt get totalBalance {
    BigInt total = BigInt.zero;
    for (final cb in chainBalances.values) {
      final diff = cb.decimals - 6;
      if (diff > 0) {
        total += cb.balance ~/ BigInt.from(10).pow(diff);
      } else if (diff < 0) {
        total += cb.balance * BigInt.from(10).pow(-diff);
      } else {
        total += cb.balance;
      }
    }
    return total;
  }

  /// 获取总余额（浮点数）
  double get totalBalanceDouble {
    final bal = totalBalance;
    final divisor = BigInt.from(10).pow(6);
    final intPart = bal ~/ divisor;
    final fracPart = bal.remainder(divisor);
    return intPart.toDouble() + fracPart.toDouble() / divisor.toDouble();
  }

  /// 支持的链列表
  List<String> get supportedChains => tokenConfig.chains.map((c) => c.chainSymbol).toList();

  AggregatedCoinModel({required this.tokenConfig}) {
    // 初始化 coin 基本信息
    // 注意：coinPrice 初始化为 0.0，会从 API 获取真实价格
    coin = {
      'mKey': tokenConfig.symbol,
      'blockchainType': 'Aggregated',
      'coinType': 'AGGREGATED',
      'icon': tokenConfig.icon,
      'name': tokenConfig.name,
      'miniName': tokenConfig.symbol,
      'unit': tokenConfig.symbol,
      'decimals': 6, // 统一使用 6 位精度显示
      'balance': '0',
      'balance_test': '0',
      'coinPrice': 0.0, // 从 API 获取真实价格
      'percentage': 0.0,
      'isContract': true,
      'isAggregated': true, // 标记为聚合代币
      'path': {'legacy': "m/44'/60'/0'/0/0"},
      'service': '',
      'service_test': '',
      'chainId': 0,
      'chainId_test': 0,
      'contract': '',
      'contract_test': '',
      'canEdit': false,
      'rules': 'MULTI',
    };
    showList = true;
    isTest = false;
    coinPrice = 0.0; // 从 API 获取真实价格
  }

  /// 根据链符号获取该链的余额
  ChainBalance? getChainBalance(String chainSymbol) {
    return chainBalances[chainSymbol.toUpperCase()];
  }

  /// 更新某条链的余额
  void updateChainBalance(String chainSymbol, BigInt newBalance, String address) {
    final config = tokenConfig.chains
        .where((c) => c.chainSymbol == chainSymbol)
        .firstOrNull;
    if (config == null) return; // 不支持的链静默返回

    chainBalances[chainSymbol.toUpperCase()] = ChainBalance(
      chainSymbol: chainSymbol,
      contract: config.contract,
      decimals: config.decimals,
      chainId: config.chainId,
      balance: newBalance,
      address: address,
    );

    // 更新总余额
    balance = totalBalance;
    value = totalBalanceDouble * coinPrice;
  }

  /// 获取各链余额（异步）
  Future<void> fetchAllBalances(Map<String, String> addressByChain) async {
    for (final chainConfig in tokenConfig.chains) {
      final address = addressByChain[chainConfig.chainSymbol];
      if (address == null || address.isEmpty) continue;

      try {
        final bal = await _fetchTokenBalance(chainConfig, address);
        updateChainBalance(chainConfig.chainSymbol, bal, address);
      } catch (e) {
        // 单链查询失败不影响其他链，静默处理
      }
    }
  }

  /// 查询单链代币余额
  Future<BigInt> _fetchTokenBalance(ChainTokenConfig config, String address) async {
    return switch (config.rules) {
      'SPL'   => _fetchSplTokenBalance(config, address),
      'TRC20' => _fetchTrc20Balance(config, address),
      _       => _fetchErc20Balance(config, address),
    };
  }

  /// HTTP 请求超时时间
  static const Duration _httpTimeout = Duration(seconds: 10);

  /// ERC20 余额查询
  Future<BigInt> _fetchErc20Balance(ChainTokenConfig config, String address) async {
    final httpClient = http.Client();
    final client = Web3Client(config.rpcUrl, httpClient);
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(
          '[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"}]',
          'ERC20',
        ),
        EthereumAddress.fromHex(config.contract),
      );

      final balanceFunction = contract.function('balanceOf');
      final result = await client.call(
        contract: contract,
        function: balanceFunction,
        params: [EthereumAddress.fromHex(address)],
      ).timeout(_httpTimeout);

      return result[0] as BigInt;
    } finally {
      client.dispose();
      httpClient.close();
    }
  }

  /// SPL Token 余额查询 (Solana)
  Future<BigInt> _fetchSplTokenBalance(ChainTokenConfig config, String address) async {
    try {
      final response = await http.post(
        Uri.parse(config.rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getTokenAccountsByOwner',
          'params': [
            address,
            {'mint': config.contract},
            {'encoding': 'jsonParsed'},
          ],
        }),
      ).timeout(_httpTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      if (data == null) return BigInt.zero;

      final result = data['result'] as Map<String, dynamic>?;
      final accounts = result?['value'] as List?;
      if (accounts == null || accounts.isEmpty) return BigInt.zero;

      final account = accounts[0] as Map<String, dynamic>?;
      final accountData = account?['account']?['data']?['parsed']?['info']?['tokenAmount'];
      if (accountData == null) return BigInt.zero;

      return BigInt.tryParse(accountData['amount']?.toString() ?? '0') ?? BigInt.zero;
    } catch (e) {
      return BigInt.zero;
    }
  }

  /// TRC20 余额查询 (Tron)
  Future<BigInt> _fetchTrc20Balance(ChainTokenConfig config, String address) async {
    try {
      final base = config.rpcUrl.endsWith('/') ? config.rpcUrl.substring(0, config.rpcUrl.length - 1) : config.rpcUrl;
      final apiUrl = '$base/wallet/triggerconstantcontract';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_address': address,
          'contract_address': config.contract,
          'function_selector': 'balanceOf(address)',
          'parameter': address.replaceFirst('T', '').padLeft(64, '0'),
        }),
      ).timeout(_httpTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      if (data == null) return BigInt.zero;

      final results = data['constant_result'] as List?;
      if (results == null || results.isEmpty) return BigInt.zero;

      final result = results[0]?.toString();
      if (result == null || result.isEmpty) return BigInt.zero;

      return BigInt.tryParse(result, radix: 16) ?? BigInt.zero;
    } catch (e) {
      return BigInt.zero;
    }
  }

  @override
  double balanceDoubleAll() {
    return totalBalanceDouble;
  }

  @override
  String balanceString() {
    return totalBalanceDouble.toStringAsFixed(2);
  }
}
