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
  keystoneModel,
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

  static const _typeNames = {
    HardwareWalletType.ledgerNanoX: 'Ledger Nano X',
    HardwareWalletType.ledgerNanoSPlus: 'Ledger Nano S Plus',
    HardwareWalletType.ledgerStax: 'Ledger Stax',
    HardwareWalletType.trezorModelT: 'Trezor Model T',
    HardwareWalletType.trezorOne: 'Trezor One',
    HardwareWalletType.keystoneModel: 'Keystone',
  };

  /// 获取设备类型显示名称
  String get typeDisplayName => _typeNames[type] ?? type.name;

  static const _ledgerTypes = {
    HardwareWalletType.ledgerNanoX,
    HardwareWalletType.ledgerNanoSPlus,
    HardwareWalletType.ledgerStax,
  };
  static const _trezorTypes = {
    HardwareWalletType.trezorModelT,
    HardwareWalletType.trezorOne,
  };

  /// 是否为 Ledger 设备
  bool get isLedger => _ledgerTypes.contains(type);

  /// 是否为 Trezor 设备
  bool get isTrezor => _trezorTypes.contains(type);

  /// 是否为 Keystone 设备（气隙 QR 签名）
  bool get isKeystone => type == HardwareWalletType.keystoneModel;
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

  /// 当设备为 Keystone 时，此字段为 true，表示需要跳转 QR 签名页面
  final bool needsKeystoneQr;

  /// 需要 Keystone QR 签名时，此字段包含待签名的原始 RLP 交易字节
  final List<int>? rawTxForQr;

  HardwareWalletSignResponse({
    required this.success,
    this.signature,
    this.txHash,
    this.error,
    this.needsKeystoneQr = false,
    this.rawTxForQr,
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

  static const _coinToApp = {
    'ETH': ethereum, 'BNB': ethereum, 'MATIC': ethereum,
    'AVAX': ethereum, 'FTM': ethereum, 'OP': ethereum,
    'ARB': ethereum, 'BASE': ethereum,
    'BTC': bitcoin, 'LTC': bitcoin, 'DOGE': bitcoin, 'BCH': bitcoin,
    'SOL': solana,
    'ATOM': cosmos,
    'DOT': polkadot,
    'TRX': tron,
  };

  /// 根据 coinType 获取对应的 Ledger 应用名称
  static String? getAppName(String coinType) => _coinToApp[coinType.toUpperCase()];
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
  static const String usbPermissionDenied = 'USB_PERMISSION_DENIED';
  static const String qrParseError = 'QR_PARSE_ERROR';
  static const String qrCrcMismatch = 'QR_CRC_MISMATCH';

  @override
  String toString() => '$code: $message';

  static const _friendlyMessages = {
    bluetoothDisabled: 'Please enable Bluetooth on your device',
    deviceNotFound: 'Hardware wallet not found. Make sure it is turned on and nearby',
    connectionFailed: 'Failed to connect to hardware wallet. Please try again',
    connectionTimeout: 'Connection timed out. Please try again',
    appNotOpen: 'Please open the corresponding app on your hardware wallet',
    userRejected: 'Transaction was rejected on the hardware wallet',
    signingFailed: 'Failed to sign transaction. Please try again',
    invalidTransaction: 'Invalid transaction data',
    deviceLocked: 'Hardware wallet is locked. Please unlock it first',
    unsupportedCoin: 'This coin is not supported by the hardware wallet',
  };

  /// 获取用户友好的错误消息
  String get userFriendlyMessage => _friendlyMessages[code] ?? message;
}
