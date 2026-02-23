// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';

/// LI.FI 跨链桥 API
///
/// LI.FI 是一个跨链桥聚合器，支持 15+ 桥接协议
/// API 文档: https://docs.li.fi/
class LiFiApi {
  static const String _baseUrl = 'https://li.quest/v1';

  static LiFiApi? _instance;

  LiFiApi._();

  factory LiFiApi() {
    _instance ??= LiFiApi._();
    return _instance!;
  }

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// 获取支持的链列表
  Future<MessageModel> getChains() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/chains',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['chains'] != null) {
        final chains = (response['chains'] as List<dynamic>)
            .map((c) => BridgeChain.fromJson(c))
            .toList();
        mm.data = chains;
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = 'Failed to get chains';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取指定链上的代币列表
  Future<MessageModel> getTokens({int? chainId}) async {
    try {
      String url = '$_baseUrl/tokens';
      if (chainId != null) {
        url += '?chains=$chainId';
      }

      final response = await BaseApi.requestEmptyH.get(
        url,
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['tokens'] != null) {
        final tokensMap = response['tokens'] as Map<String, dynamic>;
        final tokens = <BridgeToken>[];

        tokensMap.forEach((chainKey, tokenList) {
          if (tokenList is List) {
            for (final t in tokenList) {
              tokens.add(BridgeToken.fromJson(t));
            }
          }
        });

        mm.data = tokens;
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = 'Failed to get tokens';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取跨链路由报价
  ///
  /// 返回可用的跨链路由列表，按推荐程度排序
  Future<MessageModel> getQuote(BridgeQuoteRequest request) async {
    try {
      final queryParams = request.toQueryParams();
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/quote?$queryString',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map) {
        if (response['error'] != null || response['message'] != null) {
          mm.error = true;
          mm.data = response['message'] ?? response['error'] ?? 'Unknown error';
        } else {
          // 单个报价转换为路由格式
          final route = BridgeRoute.fromJson(response as Map<String, dynamic>);
          mm.data = BridgeQuoteResponse(routes: [route]);
          mm.error = false;
        }
      } else {
        mm.error = true;
        mm.data = 'Invalid response';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取所有可用路由
  ///
  /// 返回所有可用的跨链路由，包括不同的桥接协议
  Future<MessageModel> getRoutes(BridgeQuoteRequest request) async {
    try {
      final body = {
        'fromChainId': request.fromChainId,
        'toChainId': request.toChainId,
        'fromTokenAddress': request.fromTokenAddress,
        'toTokenAddress': request.toTokenAddress,
        'fromAmount': request.fromAmount,
        'fromAddress': request.fromAddress,
        'toAddress': request.toAddress,
        'options': {
          'slippage': request.slippage ?? 0.5,
          'order': 'RECOMMENDED',
        },
      };

      final response = await BaseApi.requestEmptyH.post(
        '$_baseUrl/advanced/routes',
        params: {},
        data: body,
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map) {
        if (response['routes'] != null) {
          mm.data = BridgeQuoteResponse.fromJson(response as Map<String, dynamic>);
          mm.error = false;
        } else if (response['message'] != null) {
          mm.error = true;
          mm.data = response['message'];
        } else {
          mm.error = true;
          mm.data = 'No routes available';
        }
      } else {
        mm.error = true;
        mm.data = 'Invalid response';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取交易数据
  ///
  /// 根据选择的路由生成交易数据，用于签名和广播
  Future<MessageModel> getStepTransaction({
    required Map<String, dynamic> step,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        '$_baseUrl/advanced/stepTransaction',
        params: {},
        data: {'step': step},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map) {
        if (response['transactionRequest'] != null) {
          mm.data = BridgeTransactionResponse.fromJson(response as Map<String, dynamic>);
          mm.error = false;
        } else {
          mm.error = true;
          mm.data = response['message'] ?? 'Failed to get transaction';
        }
      } else {
        mm.error = true;
        mm.data = 'Invalid response';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 查询交易状态
  ///
  /// 根据交易哈希查询跨链交易的状态
  Future<MessageModel> getStatus({
    required String txHash,
    required int fromChainId,
    required int toChainId,
    required String bridge,
  }) async {
    try {
      final queryParams = {
        'txHash': txHash,
        'fromChain': fromChainId.toString(),
        'toChain': toChainId.toString(),
        'bridge': bridge,
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/status?$queryString',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map) {
        mm.data = BridgeStatusResponse.fromJson(response as Map<String, dynamic>);
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = 'Invalid response';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取可用的桥接工具列表
  Future<MessageModel> getTools() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/tools',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['bridges'] != null) {
        mm.data = response['bridges'];
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = 'Failed to get tools';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取代币余额
  Future<MessageModel> getTokenBalance({
    required String walletAddress,
    required int chainId,
    required String tokenAddress,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/token?chain=$chainId&token=$tokenAddress&wallet=$walletAddress',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['amount'] != null) {
        mm.data = BigInt.parse(response['amount'].toString());
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = 'Failed to get balance';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 检查并获取代币授权状态
  Future<MessageModel> getTokenApproval({
    required int chainId,
    required String tokenAddress,
    required String walletAddress,
    required String spenderAddress,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_baseUrl/approval?chainId=$chainId&tokenAddress=$tokenAddress&walletAddress=$walletAddress&spenderAddress=$spenderAddress',
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map) {
        mm.data = response;
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = 'Failed to get approval status';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取代币授权交易数据
  Future<MessageModel> getApprovalTransaction({
    required int chainId,
    required String tokenAddress,
    required String spenderAddress,
    String? amount,
  }) async {
    try {
      String url = '$_baseUrl/approval/transaction?chainId=$chainId&tokenAddress=$tokenAddress&spenderAddress=$spenderAddress';
      if (amount != null) {
        url += '&amount=$amount';
      }

      final response = await BaseApi.requestEmptyH.get(
        url,
        params: {},
        header: _headers,
      );

      final mm = MessageModel();

      if (response is Map && response['transactionRequest'] != null) {
        mm.data = response['transactionRequest'];
        mm.error = false;
      } else {
        mm.error = true;
        mm.data = response['message'] ?? 'Failed to get approval transaction';
      }

      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
