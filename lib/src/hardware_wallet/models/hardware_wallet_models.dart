// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 硬件钱包类型
enum HardwareWalletType {
  ledgerNanoX,
  ledgerNanoSPlus,
  ledgerStax,
  trezorModelT,
  trezorOne,
}

/// 硬件钱包连接状态
enum HardwareWalletConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// 蓝牙设备信息
class BluetoothDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final bool isConnectable;

  BluetoothDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
    this.isConnectable = true,
  });

  factory BluetoothDeviceInfo.fromJson(Map<String, dynamic> json) {
    return BluetoothDeviceInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Device',
      rssi: json['rssi'] ?? -100,
      isConnectable: json['isConnectable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rssi': rssi,
      'isConnectable': isConnectable,
    };
  }

  /// 信号强度等级 (0-4)
  int get signalStrength {
    if (rssi >= -50) return 4;
    if (rssi >= -60) return 3;
    if (rssi >= -70) return 2;
    if (rssi >= -80) return 1;
    return 0;
  }

  /// 判断是否为 Ledger 设备
  bool get isLedger {
    final nameLower = name.toLowerCase();
    return nameLower.contains('ledger') ||
        nameLower.contains('nano') ||
        nameLower.contains('stax');
  }
}

/// 硬件钱包设备信息
class HardwareWalletDevice {
  final String id;
  final String name;
  final HardwareWalletType type;
  final String? firmwareVersion;
  final bool isConnected;
  final DateTime? lastConnectedAt;
  final List<HardwareWalletAccount> accounts;

  HardwareWalletDevice({
    required this.id,
    required this.name,
    required this.type,
    this.firmwareVersion,
    this.isConnected = false,
    this.lastConnectedAt,
    this.accounts = const [],
  });

  factory HardwareWalletDevice.fromJson(Map<String, dynamic> json) {
    return HardwareWalletDevice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: HardwareWalletType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => HardwareWalletType.ledgerNanoX,
      ),
      firmwareVersion: json['firmwareVersion'],
      isConnected: json['isConnected'] ?? false,
      lastConnectedAt: json['lastConnectedAt'] != null
          ? DateTime.parse(json['lastConnectedAt'])
          : null,
      accounts: (json['accounts'] as List<dynamic>?)
              ?.map((a) => HardwareWalletAccount.fromJson(a))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'firmwareVersion': firmwareVersion,
      'isConnected': isConnected,
      'lastConnectedAt': lastConnectedAt?.toIso8601String(),
      'accounts': accounts.map((a) => a.toJson()).toList(),
    };
  }

  HardwareWalletDevice copyWith({
    String? id,
    String? name,
    HardwareWalletType? type,
    String? firmwareVersion,
    bool? isConnected,
    DateTime? lastConnectedAt,
    List<HardwareWalletAccount>? accounts,
  }) {
    return HardwareWalletDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      isConnected: isConnected ?? this.isConnected,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      accounts: accounts ?? this.accounts,
    );
  }

  /// 获取设备类型显示名称
  String get typeDisplayName {
    switch (type) {
      case HardwareWalletType.ledgerNanoX:
        return 'Ledger Nano X';
      case HardwareWalletType.ledgerNanoSPlus:
        return 'Ledger Nano S Plus';
      case HardwareWalletType.ledgerStax:
        return 'Ledger Stax';
      case HardwareWalletType.trezorModelT:
        return 'Trezor Model T';
      case HardwareWalletType.trezorOne:
        return 'Trezor One';
    }
  }

  /// 是否为 Ledger 设备
  bool get isLedger {
    return type == HardwareWalletType.ledgerNanoX ||
        type == HardwareWalletType.ledgerNanoSPlus ||
        type == HardwareWalletType.ledgerStax;
  }

  /// 是否为 Trezor 设备
  bool get isTrezor {
    return type == HardwareWalletType.trezorModelT ||
        type == HardwareWalletType.trezorOne;
  }
}

/// 硬件钱包账户
class HardwareWalletAccount {
  final String address;
  final String coinType;
  final String derivationPath;
  final String? name;
  final int index;

  HardwareWalletAccount({
    required this.address,
    required this.coinType,
    required this.derivationPath,
    this.name,
    this.index = 0,
  });

  factory HardwareWalletAccount.fromJson(Map<String, dynamic> json) {
    return HardwareWalletAccount(
      address: json['address'] ?? '',
      coinType: json['coinType'] ?? '',
      derivationPath: json['derivationPath'] ?? '',
      name: json['name'],
      index: json['index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coinType': coinType,
      'derivationPath': derivationPath,
      'name': name,
      'index': index,
    };
  }

  /// 获取显示名称
  String get displayName => name ?? '$coinType Account ${index + 1}';

  /// 获取截短的地址
  String get shortAddress {
    if (address.length <= 14) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }
}

/// 硬件钱包签名请求
class HardwareWalletSignRequest {
  final String coinType;
  final String derivationPath;
  final Map<String, dynamic> transactionData;
  final String? message;
  final HardwareWalletSignType signType;

  HardwareWalletSignRequest({
    required this.coinType,
    required this.derivationPath,
    required this.transactionData,
    this.message,
    this.signType = HardwareWalletSignType.transaction,
  });
}

/// 签名类型
enum HardwareWalletSignType {
  transaction,
  message,
  typedData,
}

/// 硬件钱包签名响应
class HardwareWalletSignResponse {
  final bool success;
  final String? signature;
  final String? txHash;
  final String? error;

  HardwareWalletSignResponse({
    required this.success,
    this.signature,
    this.txHash,
    this.error,
  });

  factory HardwareWalletSignResponse.success({
    required String signature,
    String? txHash,
  }) {
    return HardwareWalletSignResponse(
      success: true,
      signature: signature,
      txHash: txHash,
    );
  }

  factory HardwareWalletSignResponse.error(String error) {
    return HardwareWalletSignResponse(
      success: false,
      error: error,
    );
  }
}

/// Ledger 应用信息
class LedgerAppInfo {
  final String name;
  final String version;
  final bool isOpen;

  LedgerAppInfo({
    required this.name,
    required this.version,
    this.isOpen = false,
  });

  factory LedgerAppInfo.fromJson(Map<String, dynamic> json) {
    return LedgerAppInfo(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      isOpen: json['isOpen'] ?? false,
    );
  }
}

/// 支持的 Ledger 应用
class LedgerApps {
  static const String ethereum = 'Ethereum';
  static const String bitcoin = 'Bitcoin';
  static const String solana = 'Solana';
  static const String cosmos = 'Cosmos';
  static const String polkadot = 'Polkadot';
  static const String tron = 'Tron';

  /// 根据 coinType 获取对应的 Ledger 应用名称
  static String? getAppName(String coinType) {
    final coin = coinType.toUpperCase();
    switch (coin) {
      case 'ETH':
      case 'BNB':
      case 'MATIC':
      case 'AVAX':
      case 'FTM':
      case 'OP':
      case 'ARB':
      case 'BASE':
        return ethereum;
      case 'BTC':
      case 'LTC':
      case 'DOGE':
      case 'BCH':
        return bitcoin;
      case 'SOL':
        return solana;
      case 'ATOM':
        return cosmos;
      case 'DOT':
        return polkadot;
      case 'TRX':
        return tron;
      default:
        return null;
    }
  }
}

/// 硬件钱包操作错误
class HardwareWalletError {
  final String code;
  final String message;
  final String? details;

  HardwareWalletError({
    required this.code,
    required this.message,
    this.details,
  });

  static const String bluetoothDisabled = 'BLUETOOTH_DISABLED';
  static const String deviceNotFound = 'DEVICE_NOT_FOUND';
  static const String connectionFailed = 'CONNECTION_FAILED';
  static const String connectionTimeout = 'CONNECTION_TIMEOUT';
  static const String appNotOpen = 'APP_NOT_OPEN';
  static const String userRejected = 'USER_REJECTED';
  static const String signingFailed = 'SIGNING_FAILED';
  static const String invalidTransaction = 'INVALID_TRANSACTION';
  static const String deviceLocked = 'DEVICE_LOCKED';
  static const String unsupportedCoin = 'UNSUPPORTED_COIN';

  @override
  String toString() => '$code: $message';

  /// 获取用户友好的错误消息
  String get userFriendlyMessage {
    switch (code) {
      case bluetoothDisabled:
        return 'Please enable Bluetooth on your device';
      case deviceNotFound:
        return 'Hardware wallet not found. Make sure it is turned on and nearby';
      case connectionFailed:
        return 'Failed to connect to hardware wallet. Please try again';
      case connectionTimeout:
        return 'Connection timed out. Please try again';
      case appNotOpen:
        return 'Please open the corresponding app on your hardware wallet';
      case userRejected:
        return 'Transaction was rejected on the hardware wallet';
      case signingFailed:
        return 'Failed to sign transaction. Please try again';
      case invalidTransaction:
        return 'Invalid transaction data';
      case deviceLocked:
        return 'Hardware wallet is locked. Please unlock it first';
      case unsupportedCoin:
        return 'This coin is not supported by the hardware wallet';
      default:
        return message;
    }
  }
}
