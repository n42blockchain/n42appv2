// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 跨链桥支持的链
class BridgeChain {
  final int chainId;
  final String key;
  final String name;
  final String logoUri;
  final String nativeToken;
  final int nativeDecimals;

  BridgeChain({
    required this.chainId,
    required this.key,
    required this.name,
    required this.logoUri,
    required this.nativeToken,
    required this.nativeDecimals,
  });

  factory BridgeChain.fromJson(Map<String, dynamic> json) {
    return BridgeChain(
      chainId: json['id'] ?? 0,
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      logoUri: json['logoURI'] ?? '',
      nativeToken: json['nativeToken']?['symbol'] ?? '',
      nativeDecimals: json['nativeToken']?['decimals'] ?? 18,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': chainId,
      'key': key,
      'name': name,
      'logoURI': logoUri,
      'nativeToken': {
        'symbol': nativeToken,
        'decimals': nativeDecimals,
      },
    };
  }
}

/// 跨链桥代币
class BridgeToken {
  final String address;
  final String symbol;
  final String name;
  final int decimals;
  final int chainId;
  final String logoUri;
  final double? priceUSD;

  BridgeToken({
    required this.address,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.chainId,
    required this.logoUri,
    this.priceUSD,
  });

  factory BridgeToken.fromJson(Map<String, dynamic> json) {
    return BridgeToken(
      address: json['address'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      decimals: json['decimals'] ?? 18,
      chainId: json['chainId'] ?? 0,
      logoUri: json['logoURI'] ?? '',
      priceUSD: json['priceUSD']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'symbol': symbol,
      'name': name,
      'decimals': decimals,
      'chainId': chainId,
      'logoURI': logoUri,
      'priceUSD': priceUSD,
    };
  }

  /// 是否为原生代币
  bool get isNative =>
      address.toLowerCase() == '0x0000000000000000000000000000000000000000' ||
      address.isEmpty;
}

/// 跨链桥报价请求
class BridgeQuoteRequest {
  final int fromChainId;
  final int toChainId;
  final String fromTokenAddress;
  final String toTokenAddress;
  final String fromAmount;
  final String fromAddress;
  final String toAddress;
  final double? slippage;

  BridgeQuoteRequest({
    required this.fromChainId,
    required this.toChainId,
    required this.fromTokenAddress,
    required this.toTokenAddress,
    required this.fromAmount,
    required this.fromAddress,
    required this.toAddress,
    this.slippage = 0.5,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'fromChain': fromChainId.toString(),
      'toChain': toChainId.toString(),
      'fromToken': fromTokenAddress,
      'toToken': toTokenAddress,
      'fromAmount': fromAmount,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'slippage': (slippage ?? 0.5).toString(),
    };
  }
}

/// 跨链桥路由步骤
class BridgeRouteStep {
  final String type;
  final String tool;
  final String toolName;
  final String toolLogoUri;
  final BridgeToken fromToken;
  final BridgeToken toToken;
  final String fromAmount;
  final String toAmount;
  final int estimatedSeconds;

  BridgeRouteStep({
    required this.type,
    required this.tool,
    required this.toolName,
    required this.toolLogoUri,
    required this.fromToken,
    required this.toToken,
    required this.fromAmount,
    required this.toAmount,
    required this.estimatedSeconds,
  });

  factory BridgeRouteStep.fromJson(Map<String, dynamic> json) {
    return BridgeRouteStep(
      type: json['type'] ?? '',
      tool: json['tool'] ?? '',
      toolName: json['toolDetails']?['name'] ?? json['tool'] ?? '',
      toolLogoUri: json['toolDetails']?['logoURI'] ?? '',
      fromToken: BridgeToken.fromJson(json['action']?['fromToken'] ?? {}),
      toToken: BridgeToken.fromJson(json['action']?['toToken'] ?? {}),
      fromAmount: json['action']?['fromAmount'] ?? '0',
      toAmount: json['estimate']?['toAmount'] ?? '0',
      estimatedSeconds: json['estimate']?['executionDuration'] ?? 0,
    );
  }
}

/// 跨链桥路由
class BridgeRoute {
  final String id;
  final List<BridgeRouteStep> steps;
  final BridgeToken fromToken;
  final BridgeToken toToken;
  final String fromAmount;
  final String toAmount;
  final String toAmountMin;
  final double gasCostUSD;
  final int estimatedSeconds;
  final List<String> tags;

  BridgeRoute({
    required this.id,
    required this.steps,
    required this.fromToken,
    required this.toToken,
    required this.fromAmount,
    required this.toAmount,
    required this.toAmountMin,
    required this.gasCostUSD,
    required this.estimatedSeconds,
    required this.tags,
  });

  factory BridgeRoute.fromJson(Map<String, dynamic> json) {
    final steps = (json['steps'] as List<dynamic>?)
            ?.map((s) => BridgeRouteStep.fromJson(s))
            .toList() ??
        [];

    return BridgeRoute(
      id: json['id'] ?? '',
      steps: steps,
      fromToken: BridgeToken.fromJson(json['fromToken'] ?? {}),
      toToken: BridgeToken.fromJson(json['toToken'] ?? {}),
      fromAmount: json['fromAmount'] ?? '0',
      toAmount: json['toAmount'] ?? '0',
      toAmountMin: json['toAmountMin'] ?? '0',
      gasCostUSD: double.tryParse(json['gasCostUSD']?.toString() ?? '0') ?? 0.0,
      estimatedSeconds: _calculateTotalDuration(steps),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  static int _calculateTotalDuration(List<BridgeRouteStep> steps) {
    return steps.fold(0, (sum, step) => sum + step.estimatedSeconds);
  }

  /// 是否为推荐路由
  bool get isRecommended => tags.contains('RECOMMENDED');

  /// 是否为最快路由
  bool get isFastest => tags.contains('FASTEST');

  /// 是否为最便宜路由
  bool get isCheapest => tags.contains('CHEAPEST');
}

/// 跨链桥报价响应
class BridgeQuoteResponse {
  final List<BridgeRoute> routes;
  final String? error;

  BridgeQuoteResponse({
    required this.routes,
    this.error,
  });

  factory BridgeQuoteResponse.fromJson(Map<String, dynamic> json) {
    if (json['routes'] == null) {
      return BridgeQuoteResponse(
        routes: [],
        error: json['message'] ?? 'No routes available',
      );
    }

    final routes = (json['routes'] as List<dynamic>)
        .map((r) => BridgeRoute.fromJson(r))
        .toList();

    return BridgeQuoteResponse(routes: routes);
  }

  bool get hasRoutes => routes.isNotEmpty;

  /// 获取推荐路由
  BridgeRoute? get recommendedRoute {
    if (routes.isEmpty) return null;
    return routes.cast<BridgeRoute?>().firstWhere(
          (r) => r!.isRecommended,
          orElse: () => routes.first,
        );
  }
}

/// 跨链桥交易数据
class BridgeTransactionRequest {
  final String routeId;
  final String fromAddress;
  final String toAddress;

  BridgeTransactionRequest({
    required this.routeId,
    required this.fromAddress,
    required this.toAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'route': routeId,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
    };
  }
}

/// 跨链桥交易响应
class BridgeTransactionResponse {
  final String? transactionRequest;
  final Map<String, dynamic>? txData;
  final String? error;

  BridgeTransactionResponse({
    this.transactionRequest,
    this.txData,
    this.error,
  });

  factory BridgeTransactionResponse.fromJson(Map<String, dynamic> json) {
    if (json['transactionRequest'] == null) {
      return BridgeTransactionResponse(
        error: json['message'] ?? 'Failed to get transaction data',
      );
    }

    return BridgeTransactionResponse(
      transactionRequest: json['transactionRequest']?['data'],
      txData: json['transactionRequest'],
    );
  }

  bool get isSuccess => error == null && txData != null;
}

/// 跨链桥交易状态
enum BridgeTransactionStatus {
  pending,
  inProgress,
  completed,
  failed,
}

/// 跨链桥交易记录
class BridgeTransaction {
  final String txHash;
  final int fromChainId;
  final int toChainId;
  final BridgeToken fromToken;
  final BridgeToken toToken;
  final String fromAmount;
  final String toAmount;
  final String fromAddress;
  final String toAddress;
  final BridgeTransactionStatus status;
  final DateTime createdAt;
  final String? bridgeTool;
  final String? destinationTxHash;

  BridgeTransaction({
    required this.txHash,
    required this.fromChainId,
    required this.toChainId,
    required this.fromToken,
    required this.toToken,
    required this.fromAmount,
    required this.toAmount,
    required this.fromAddress,
    required this.toAddress,
    required this.status,
    required this.createdAt,
    this.bridgeTool,
    this.destinationTxHash,
  });

  factory BridgeTransaction.fromJson(Map<String, dynamic> json) {
    return BridgeTransaction(
      txHash: json['txHash'] ?? '',
      fromChainId: json['fromChainId'] ?? 0,
      toChainId: json['toChainId'] ?? 0,
      fromToken: BridgeToken.fromJson(json['fromToken'] ?? {}),
      toToken: BridgeToken.fromJson(json['toToken'] ?? {}),
      fromAmount: json['fromAmount'] ?? '0',
      toAmount: json['toAmount'] ?? '0',
      fromAddress: json['fromAddress'] ?? '',
      toAddress: json['toAddress'] ?? '',
      status: BridgeTransactionStatus.values[json['status'] ?? 0],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      bridgeTool: json['bridgeTool'],
      destinationTxHash: json['destinationTxHash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txHash': txHash,
      'fromChainId': fromChainId,
      'toChainId': toChainId,
      'fromToken': fromToken.toJson(),
      'toToken': toToken.toJson(),
      'fromAmount': fromAmount,
      'toAmount': toAmount,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'bridgeTool': bridgeTool,
      'destinationTxHash': destinationTxHash,
    };
  }
}

/// 跨链桥交易状态查询响应
class BridgeStatusResponse {
  final BridgeTransactionStatus status;
  final String? substatus;
  final String? destinationTxHash;
  final String? error;

  BridgeStatusResponse({
    required this.status,
    this.substatus,
    this.destinationTxHash,
    this.error,
  });

  factory BridgeStatusResponse.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString().toUpperCase() ?? 'PENDING';
    BridgeTransactionStatus status;

    switch (statusStr) {
      case 'DONE':
        status = BridgeTransactionStatus.completed;
        break;
      case 'FAILED':
        status = BridgeTransactionStatus.failed;
        break;
      case 'PENDING':
        status = BridgeTransactionStatus.pending;
        break;
      default:
        status = BridgeTransactionStatus.inProgress;
    }

    return BridgeStatusResponse(
      status: status,
      substatus: json['substatus'],
      destinationTxHash: json['receiving']?['txHash'],
      error: json['error'],
    );
  }
}

/// 常用链 ID 常量
class BridgeChainIds {
  static const int ethereum = 1;
  static const int optimism = 10;
  static const int bsc = 56;
  static const int polygon = 137;
  static const int fantom = 250;
  static const int arbitrum = 42161;
  static const int avalanche = 43114;
  static const int base = 8453;
  static const int linea = 59144;
  static const int scroll = 534352;
  static const int zksync = 324;

  /// 根据链名称获取链 ID
  static int? getChainId(String chainName) {
    switch (chainName.toLowerCase()) {
      case 'eth':
      case 'ethereum':
        return ethereum;
      case 'op':
      case 'optimism':
        return optimism;
      case 'bnb':
      case 'bsc':
        return bsc;
      case 'matic':
      case 'polygon':
        return polygon;
      case 'ftm':
      case 'fantom':
        return fantom;
      case 'arb':
      case 'arbitrum':
        return arbitrum;
      case 'avax':
      case 'avalanche':
        return avalanche;
      case 'base':
        return base;
      case 'linea':
        return linea;
      case 'scroll':
        return scroll;
      case 'zksync':
        return zksync;
      default:
        return null;
    }
  }

  /// 获取链名称
  static String getChainName(int chainId) {
    switch (chainId) {
      case ethereum:
        return 'Ethereum';
      case optimism:
        return 'Optimism';
      case bsc:
        return 'BNB Chain';
      case polygon:
        return 'Polygon';
      case fantom:
        return 'Fantom';
      case arbitrum:
        return 'Arbitrum';
      case avalanche:
        return 'Avalanche';
      case base:
        return 'Base';
      case linea:
        return 'Linea';
      case scroll:
        return 'Scroll';
      case zksync:
        return 'zkSync Era';
      default:
        return 'Unknown';
    }
  }
}
