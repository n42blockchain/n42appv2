// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'hardware_wallet_provider.dart';

// ============ 链工具（顶层函数，供两个 mixin 共用） ============

/// 返回 coinType 对应的 BIP-44 基础路径（不含最后的 index）
String _derivationBasePath(String coin) {
  switch (coin) {
    case 'ETH':
    case 'BNB':
    case 'MATIC':
    case 'AVAX':
    case 'FTM':
    case 'OP':
    case 'ARB':
    case 'BASE':
      return "m/44'/60'/0'/0/";
    case 'BTC':
      return "m/84'/0'/0'/0/";
    case 'LTC':
      return "m/84'/2'/0'/0/";
    case 'DOGE':
      return "m/44'/3'/0'/0/";
    case 'BCH':
      return "m/44'/145'/0'/0/";
    case 'SOL':
      return "m/44'/501'/0'/0'/";
    case 'ATOM':
      return "m/44'/118'/0'/0/";
    case 'DOT':
      return "m/44'/354'/0'/0/";
    case 'TRX':
      return "m/44'/195'/0'/0/";
    default:
      return "m/44'/60'/0'/0/";
  }
}

/// EVM 兼容链（使用 Ledger Ethereum app）
bool _isEvmChain(String coin) {
  const evmCoins = {'ETH', 'BNB', 'MATIC', 'AVAX', 'FTM', 'OP', 'ARB', 'BASE'};
  return evmCoins.contains(coin);
}

/// 类比特币链（使用 Ledger Bitcoin/Litecoin/Dogecoin app）
bool _isBitcoinLikeChain(String coin) {
  const btcCoins = {'BTC', 'LTC', 'DOGE', 'BCH'};
  return btcCoins.contains(coin);
}

// ============ 连接管理 mixin ============

/// 连接管理 mixin
///
/// 包含扫描、连接、重连、断开、地址获取、账户加载等操作。
mixin _HardwareWalletConnectionMixin on ChangeNotifier {
  LedgerService get _ledgerService;
  TrezorService get _trezorService;

  // ignore: unused_element
  HardwareWalletConnectionState get _connectionState;
  set _connectionState(HardwareWalletConnectionState v);

  // ignore: unused_element
  String? get _errorMessage;
  set _errorMessage(String? v);

  // ignore: unused_element
  bool get _isScanning;
  set _isScanning(bool v);

  // ignore: unused_element
  List<BluetoothDeviceInfo> get _discoveredDevices;
  set _discoveredDevices(List<BluetoothDeviceInfo> v);

  HardwareWalletDevice? get _currentDevice;
  set _currentDevice(HardwareWalletDevice? v);

  List<HardwareWalletAccount> get _accounts;
  set _accounts(List<HardwareWalletAccount> v);

  List<HardwareWalletDevice> get _savedDevices;

  String get _currentCoinType;
  set _currentCoinType(String v);

  bool get isConnected;

  Future<void> _saveDevice(HardwareWalletDevice device);
  Future<void> _persistSavedDevices();

  /// 检查蓝牙是否可用
  Future<bool> checkBluetoothAvailable() async {
    return await _ledgerService.isBluetoothAvailable();
  }

  /// 请求蓝牙权限
  Future<bool> requestPermissions() async {
    return await _ledgerService.requestBluetoothPermissions();
  }

  /// 开始扫描设备
  Future<void> startScan() async {
    _errorMessage = null;
    _isScanning = true;
    _discoveredDevices = [];
    notifyListeners();

    try {
      await _ledgerService.startScan();
    } on HardwareWalletError catch (e) {
      _errorMessage = e.userFriendlyMessage;
      _isScanning = false;
      notifyListeners();
    }
  }

  /// 停止扫描
  Future<void> stopScan() async {
    await _ledgerService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  /// 连接设备
  Future<bool> connectDevice(BluetoothDeviceInfo deviceInfo) async {
    _errorMessage = null;
    _connectionState = HardwareWalletConnectionState.connecting;
    notifyListeners();

    try {
      final device = await _ledgerService.connect(deviceInfo);
      _currentDevice = device;
      _connectionState = HardwareWalletConnectionState.connected;
      await _saveDevice(device);
      notifyListeners();
      return true;
    } on HardwareWalletError catch (e) {
      _errorMessage = e.userFriendlyMessage;
      _connectionState = HardwareWalletConnectionState.error;
      notifyListeners();
      return false;
    }
  }

  /// 重新连接已保存的设备
  Future<bool> reconnectDevice(HardwareWalletDevice device) async {
    if (device.isTrezor) {
      return await _reconnectTrezor(device);
    }
    if (device.isKeystone) {
      _currentDevice = device.copyWith(isConnected: true);
      _connectionState = HardwareWalletConnectionState.connected;
      notifyListeners();
      return true;
    }
    final deviceInfo = BluetoothDeviceInfo(
      id: device.id,
      name: device.name,
      rssi: -50,
    );
    return await connectDevice(deviceInfo);
  }

  Future<bool> _reconnectTrezor(HardwareWalletDevice device) async {
    _errorMessage = null;
    _connectionState = HardwareWalletConnectionState.connecting;
    notifyListeners();

    try {
      final connected = await _trezorService.connect();
      _currentDevice = connected.copyWith(
        id: device.id,
        lastConnectedAt: DateTime.now(),
      );
      _connectionState = HardwareWalletConnectionState.connected;
      await _saveDevice(_currentDevice!);
      notifyListeners();
      return true;
    } on HardwareWalletError catch (e) {
      _errorMessage = e.userFriendlyMessage;
      _connectionState = HardwareWalletConnectionState.error;
      notifyListeners();
      return false;
    }
  }

  /// 连接 Trezor 设备（USB）
  Future<HardwareWalletDevice?> connectTrezor() async {
    _errorMessage = null;
    _connectionState = HardwareWalletConnectionState.connecting;
    notifyListeners();

    try {
      final device = await _trezorService.connect();
      _currentDevice = device;
      _connectionState = HardwareWalletConnectionState.connected;
      await _saveDevice(device);
      notifyListeners();
      return device;
    } on HardwareWalletError catch (e) {
      _errorMessage = e.userFriendlyMessage;
      _connectionState = HardwareWalletConnectionState.error;
      notifyListeners();
      return null;
    }
  }

  /// 注册 Keystone 气隙设备（从 xpub QR 扫描结果创建）
  Future<HardwareWalletDevice> registerKeystone(
    KeystoneAccountInfo accountInfo,
  ) async {
    final device = accountInfo.toDevice();
    _currentDevice = device;
    _connectionState = HardwareWalletConnectionState.connected;
    await _saveDevice(device);
    notifyListeners();
    return device;
  }

  /// 断开连接
  Future<void> disconnect() async {
    await _ledgerService.disconnect();
    _currentDevice = _currentDevice?.copyWith(isConnected: false);
    _connectionState = HardwareWalletConnectionState.disconnected;
    _accounts = [];
    notifyListeners();
  }

  /// 获取当前打开的应用
  Future<LedgerAppInfo?> getCurrentApp() async {
    if (!isConnected) return null;
    return await _ledgerService.getCurrentApp();
  }

  /// 获取以太坊地址
  Future<String?> getEthereumAddress({
    String derivationPath = "m/44'/60'/0'/0/0",
    bool display = false,
  }) async {
    if (!isConnected) {
      _errorMessage = 'No device connected';
      notifyListeners();
      return null;
    }

    try {
      return await _ledgerService.getEthereumAddress(
        derivationPath: derivationPath,
        display: display,
      );
    } on HardwareWalletError catch (e) {
      _errorMessage = e.userFriendlyMessage;
      notifyListeners();
      return null;
    }
  }

  /// 获取比特币地址
  Future<String?> getBitcoinAddress({
    String derivationPath = "m/84'/0'/0'/0/0",
    bool display = false,
  }) async {
    if (!isConnected) {
      _errorMessage = 'No device connected';
      notifyListeners();
      return null;
    }

    try {
      return await _ledgerService.getBitcoinAddress(
        derivationPath: derivationPath,
        display: display,
      );
    } on HardwareWalletError catch (e) {
      _errorMessage = e.userFriendlyMessage;
      notifyListeners();
      return null;
    }
  }

  /// 删除已保存的设备
  Future<void> removeDevice(String deviceId) async {
    _savedDevices.removeWhere((d) => d.id == deviceId);
    await _persistSavedDevices();

    if (_currentDevice?.id == deviceId) {
      await disconnect();
    }

    notifyListeners();
  }

  /// 加载账户列表（前 5 个）
  Future<void> loadAccounts(String coinType) async {
    if (!isConnected || _currentDevice == null) return;

    _accounts = [];
    _currentCoinType = coinType.toUpperCase();

    await _loadAccountsFrom(coinType, startIndex: 0, count: 5);

    if (_currentDevice != null) {
      _currentDevice = _currentDevice!.copyWith(accounts: List.from(_accounts));
      await _saveDevice(_currentDevice!);
    }

    notifyListeners();
  }

  /// 加载更多账户（从当前最大 index 继续）
  Future<void> loadMoreAccounts() async {
    if (!isConnected || _currentDevice == null) return;

    final startIndex = _accounts.isEmpty ? 0 : _accounts.last.index + 1;
    await _loadAccountsFrom(_currentCoinType, startIndex: startIndex, count: 5);

    if (_currentDevice != null) {
      _currentDevice = _currentDevice!.copyWith(accounts: List.from(_accounts));
      await _saveDevice(_currentDevice!);
    }

    notifyListeners();
  }

  /// 内部：从 [startIndex] 开始加载 [count] 个账户
  Future<void> _loadAccountsFrom(
    String coinType, {
    required int startIndex,
    required int count,
  }) async {
    final coin = coinType.toUpperCase();
    final basePath = _derivationBasePath(coin);
    final isEvm = _isEvmChain(coin);
    final isBtcLike = _isBitcoinLikeChain(coin);
    final isTrezor = _currentDevice?.isTrezor ?? false;

    for (var i = startIndex; i < startIndex + count; i++) {
      try {
        String? address;
        final path = '$basePath$i';

        if (isTrezor) {
          address = await _trezorService.getAddress(
            coinType: coin,
            derivationPath: path,
          );
        } else if (isEvm) {
          address = await _ledgerService.getEthereumAddress(derivationPath: path);
        } else if (isBtcLike) {
          address = await _ledgerService.getBitcoinAddress(derivationPath: path);
        } else {
          address = await _ledgerService.getChainAddress(
            coinType: coin,
            derivationPath: path,
          );
        }

        if (address != null) {
          _accounts.add(HardwareWalletAccount(
            address: address,
            coinType: coin,
            derivationPath: path,
            index: i,
          ));
        }
      } catch (e) {
        debugPrint('Failed to load account $i for $coin: $e');
        break;
      }
    }
  }
}
