import 'package:equatable/equatable.dart';

/// 链类型
enum ChainType {
  ethereum,
  bitcoin,
  solana,
  tron,
  polygon,
  bsc,
  avalanche,
  arbitrum,
  optimism,
  fantom,
  amaze, // N42 原生链
}

/// 钱包实体
class Wallet extends Equatable {
  /// 钱包 ID
  final String id;
  
  /// 钱包名称
  final String name;
  
  /// 钱包地址
  final String address;
  
  /// 链类型
  final ChainType chainType;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 是否是 HD 钱包
  final bool isHD;
  
  /// HD 钱包派生路径
  final String? derivationPath;
  
  /// 是否是观察钱包
  final bool isWatchOnly;
  
  /// 钱包索引（用于 HD 钱包）
  final int? index;

  const Wallet({
    required this.id,
    required this.name,
    required this.address,
    required this.chainType,
    required this.createdAt,
    this.isHD = true,
    this.derivationPath,
    this.isWatchOnly = false,
    this.index,
  });

  /// 获取链名称
  String get chainName {
    switch (chainType) {
      case ChainType.ethereum:
        return 'Ethereum';
      case ChainType.bitcoin:
        return 'Bitcoin';
      case ChainType.solana:
        return 'Solana';
      case ChainType.tron:
        return 'Tron';
      case ChainType.polygon:
        return 'Polygon';
      case ChainType.bsc:
        return 'BSC';
      case ChainType.avalanche:
        return 'Avalanche';
      case ChainType.arbitrum:
        return 'Arbitrum';
      case ChainType.optimism:
        return 'Optimism';
      case ChainType.fantom:
        return 'Fantom';
      case ChainType.amaze:
        return 'Amaze Chain';
    }
  }

  /// 获取缩短的地址
  String get shortAddress {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// 复制并修改
  Wallet copyWith({
    String? id,
    String? name,
    String? address,
    ChainType? chainType,
    DateTime? createdAt,
    bool? isHD,
    String? derivationPath,
    bool? isWatchOnly,
    int? index,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      chainType: chainType ?? this.chainType,
      createdAt: createdAt ?? this.createdAt,
      isHD: isHD ?? this.isHD,
      derivationPath: derivationPath ?? this.derivationPath,
      isWatchOnly: isWatchOnly ?? this.isWatchOnly,
      index: index ?? this.index,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    chainType,
    createdAt,
    isHD,
    derivationPath,
    isWatchOnly,
    index,
  ];
}

/// 钱包资产
class WalletAsset extends Equatable {
  /// 资产符号
  final String symbol;
  
  /// 资产名称
  final String name;
  
  /// 余额
  final BigInt balance;
  
  /// 小数位数
  final int decimals;
  
  /// 合约地址（代币）
  final String? contractAddress;
  
  /// 图标 URL
  final String? iconUrl;
  
  /// 是否是原生代币
  final bool isNative;
  
  /// 当前价格（美元）
  final double? priceUsd;

  const WalletAsset({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.decimals,
    this.contractAddress,
    this.iconUrl,
    this.isNative = false,
    this.priceUsd,
  });

  /// 获取格式化的余额
  String get formattedBalance {
    final value = balance / BigInt.from(10).pow(decimals);
    return value.toStringAsFixed(decimals > 6 ? 6 : decimals);
  }

  /// 获取美元价值
  double? get valueUsd {
    if (priceUsd == null) return null;
    final value = balance / BigInt.from(10).pow(decimals);
    return value.toDouble() * priceUsd!;
  }

  @override
  List<Object?> get props => [
    symbol,
    name,
    balance,
    decimals,
    contractAddress,
    iconUrl,
    isNative,
    priceUsd,
  ];
}

