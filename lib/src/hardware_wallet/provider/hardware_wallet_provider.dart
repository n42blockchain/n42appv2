// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42appv2/src/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42appv2/src/hardware_wallet/service/ledger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 硬件钱包 Provider
///
/// 管理硬件钱包连接、账户和签名操作
class HardwareWalletProvider extends ChangeNotifier {
  final LedgerService _ledgerService = LedgerService();

  // 状态
  HardwareWalletConnectionState _connectionState = HardwareWalletConnectionState.disconnected;
  String? _errorMessage;
  bool _isScanning = false;

  // 设备列表
  List<BluetoothDeviceInfo> _discoveredDevices = [];
  List<HardwareWalletDevice> _savedDevices = [];
  HardwareWalletDevice? _currentDevice;

  // 账户列表
  List<HardwareWalletAccount> _accounts = [];

  // 订阅
  StreamSubscription? _scanSubscription;
  StreamSubscription? _stateSubscription;

  // Getters
  HardwareWalletConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  bool get isScanning => _isScanning;
  bool get isConnected => _connectionState == HardwareWalletConnectionState.connected;
  List<BluetoothDeviceInfo> get discoveredDevices => _discoveredDevices;
  List<HardwareWalletDevice> get savedDevices => _savedDevices;
  HardwareWalletDevice? get currentDevice => _currentDevice;
  List<HardwareWalletAccount> get accounts => _accounts;

  HardwareWalletProvider() {
    _init();
  }

  Future<void> _init() async {
    // 监听连接状态
    _stateSubscription = _ledgerService.connectionStateStream.listen((state) {
      _connectionState = state;
      if (state == HardwareWalletConnectionState.error) {
        _errorMessage = 'Connection error';
      }
      notifyListeners();
    });

    // 监听扫描结果
    _scanSubscription = _ledgerService.scanResults.listen((devices) {
      _discoveredDevices = devices;
      notifyListeners();
    });

    // 加载已保存的设备
    await _loadSavedDevices();
  }

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

      // 保存设备到本地
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
    final deviceInfo = BluetoothDeviceInfo(
      id: device.id,
      name: device.name,
      rssi: -50,
    );
    return await connectDevice(deviceInfo);
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

  /// 加载账户列表
  Future<void> loadAccounts(String coinType) async {
    if (!isConnected || _currentDevice == null) return;

    _accounts = [];

    // 根据币种确定派生路径
    String basePath;
    switch (coinType.toUpperCase()) {
      case 'ETH':
      case 'BNB':
      case 'MATIC':
      case 'AVAX':
      case 'FTM':
      case 'OP':
      case 'ARB':
        basePath = "m/44'/60'/0'/0/";
        break;
      case 'BTC':
        basePath = "m/84'/0'/0'/0/";
        break;
      case 'SOL':
        basePath = "m/44'/501'/0'/0'/";
        break;
      default:
        basePath = "m/44'/60'/0'/0/";
    }

    // 加载前 5 个账户
    for (var i = 0; i < 5; i++) {
      try {
        String? address;
        final path = '$basePath$i';

        if (coinType.toUpperCase() == 'BTC') {
          address = await _ledgerService.getBitcoinAddress(derivationPath: path);
        } else {
          address = await _ledgerService.getEthereumAddress(derivationPath: path);
        }

        if (address != null) {
          _accounts.add(HardwareWalletAccount(
            address: address,
            coinType: coinType,
            derivationPath: path,
            index: i,
          ));
        }
      } catch (e) {
        debugPrint('Failed to load account $i: $e');
        break;
      }
    }

    // 更新设备的账户列表
    if (_currentDevice != null) {
      _currentDevice = _currentDevice!.copyWith(accounts: List.from(_accounts));
      await _saveDevice(_currentDevice!);
    }

    notifyListeners();
  }

  /// 签名以太坊交易
  Future<HardwareWalletSignResponse> signEthereumTransaction({
    required String derivationPath,
    required Uint8List rawTx,
  }) async {
    if (!isConnected) {
      return HardwareWalletSignResponse.error('No device connected');
    }

    try {
      return await _ledgerService.signEthereumTransaction(
        derivationPath: derivationPath,
        rawTx: rawTx,
      );
    } on HardwareWalletError catch (e) {
      return HardwareWalletSignResponse.error(e.userFriendlyMessage);
    }
  }

  /// 签名以太坊消息
  Future<HardwareWalletSignResponse> signEthereumMessage({
    required String derivationPath,
    required String message,
  }) async {
    if (!isConnected) {
      return HardwareWalletSignResponse.error('No device connected');
    }

    try {
      return await _ledgerService.signEthereumMessage(
        derivationPath: derivationPath,
        message: message,
      );
    } on HardwareWalletError catch (e) {
      return HardwareWalletSignResponse.error(e.userFriendlyMessage);
    }
  }

  /// 签名比特币交易
  Future<HardwareWalletSignResponse> signBitcoinTransaction({
    required String derivationPath,
    required Map<String, dynamic> txData,
  }) async {
    if (!isConnected) {
      return HardwareWalletSignResponse.error('No device connected');
    }

    try {
      return await _ledgerService.signBitcoinTransaction(
        derivationPath: derivationPath,
        txData: txData,
      );
    } on HardwareWalletError catch (e) {
      return HardwareWalletSignResponse.error(e.userFriendlyMessage);
    }
  }

  /// 通用签名方法
  Future<HardwareWalletSignResponse> signTransaction(
    HardwareWalletSignRequest request,
  ) async {
    final coinType = request.coinType.toUpperCase();

    // 根据币种选择签名方法
    switch (coinType) {
      case 'ETH':
      case 'BNB':
      case 'MATIC':
      case 'AVAX':
      case 'FTM':
      case 'OP':
      case 'ARB':
      case 'BASE':
        if (request.signType == HardwareWalletSignType.message) {
          return await signEthereumMessage(
            derivationPath: request.derivationPath,
            message: request.message ?? '',
          );
        } else {
          // 将交易数据序列化为 RLP
          final rawTx = _serializeEthTransaction(request.transactionData);
          return await signEthereumTransaction(
            derivationPath: request.derivationPath,
            rawTx: rawTx,
          );
        }

      case 'BTC':
      case 'LTC':
      case 'DOGE':
      case 'BCH':
        return await signBitcoinTransaction(
          derivationPath: request.derivationPath,
          txData: request.transactionData,
        );

      default:
        return HardwareWalletSignResponse.error(
          'Unsupported coin type: $coinType',
        );
    }
  }

  /// 导入硬件钱包账户到本地追踪列表
  ///
  /// 将账户地址保存到独立的 SharedPreferences key，
  /// 与主钱包助记词存储隔离，避免破坏主钱包数据。
  ///
  /// 使用独立的地址 Set（_hw_addr_set）做 O(1) 去重检查，
  /// 避免对每条 JSON 条目进行完整解析（原先为 O(n) 解析）。
  Future<bool> importAccount(HardwareWalletAccount account) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'hardware_wallet_imported_accounts';
      const addrSetKey = '_hw_addr_set';

      // O(1) 快速去重：从独立地址集合检查，避免 O(n) JSON 解析
      final addrSet = Set<String>.from(prefs.getStringList(addrSetKey) ?? []);
      final addrKey = '${account.address}:${account.coinType}';
      if (addrSet.contains(addrKey)) {
        return false; // 已导入，返回 false 让调用方提示用户
      }

      // 序列化完整条目
      final entry = json.encode({
        'address': account.address,
        'coinType': account.coinType,
        'derivationPath': account.derivationPath,
        'index': account.index,
        'deviceId': _currentDevice?.id ?? '',
        'deviceName': _currentDevice?.name ?? '',
        'importedAt': DateTime.now().toIso8601String(),
      });

      // 同步写入地址集合与完整数据列表
      addrSet.add(addrKey);
      final existing = prefs.getStringList(key) ?? [];
      existing.add(entry);
      await Future.wait([
        prefs.setStringList(key, existing),
        prefs.setStringList(addrSetKey, addrSet.toList()),
      ]);
      return true;
    } catch (e) {
      debugPrint('Failed to import hardware wallet account: $e');
      rethrow;
    }
  }

  /// 获取所有已导入的硬件钱包账户
  Future<List<Map<String, dynamic>>> getImportedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('hardware_wallet_imported_accounts') ?? [];
      return raw
          .map((e) => json.decode(e) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
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

  /// 清除错误
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============ Private Methods ============

  Future<void> _loadSavedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getString('hardware_wallet_devices');
      if (devicesJson != null) {
        final List<dynamic> devices = json.decode(devicesJson);
        _savedDevices = devices
            .map((d) => HardwareWalletDevice.fromJson(d))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load saved devices: $e');
    }
  }

  Future<void> _saveDevice(HardwareWalletDevice device) async {
    // 更新或添加设备
    final index = _savedDevices.indexWhere((d) => d.id == device.id);
    if (index >= 0) {
      _savedDevices[index] = device;
    } else {
      _savedDevices.add(device);
    }

    await _persistSavedDevices();
  }

  Future<void> _persistSavedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = json.encode(_savedDevices.map((d) => d.toJson()).toList());
      await prefs.setString('hardware_wallet_devices', devicesJson);
    } catch (e) {
      debugPrint('Failed to save devices: $e');
    }
  }

  Uint8List _serializeEthTransaction(Map<String, dynamic> txData) {
    // 简化的 RLP 编码
    // 实际实现需要完整的 RLP 编码库
    final List<int> encoded = [];

    // 交易字段: nonce, gasPrice, gasLimit, to, value, data, chainId
    final fields = ['nonce', 'gasPrice', 'gasLimit', 'to', 'value', 'data'];
    for (final field in fields) {
      final value = txData[field];
      if (value != null) {
        encoded.addAll(_rlpEncode(value));
      } else {
        encoded.add(0x80); // 空字符串
      }
    }

    // 添加 chainId 用于 EIP-155
    if (txData['chainId'] != null) {
      encoded.addAll(_rlpEncode(txData['chainId']));
      encoded.add(0x80); // r
      encoded.add(0x80); // s
    }

    // 包装成列表
    return Uint8List.fromList(_rlpEncodeList(encoded));
  }

  List<int> _rlpEncode(dynamic value) {
    if (value is int) {
      if (value == 0) return [0x80];
      if (value < 128) return [value];
      final bytes = _intToBytes(value);
      return [0x80 + bytes.length, ...bytes];
    } else if (value is String) {
      final hexStr = value.startsWith('0x') ? value.substring(2) : value;
      if (hexStr.isEmpty) return [0x80];
      final bytes = _hexToBytes(hexStr);
      if (bytes.length == 1 && bytes[0] < 128) return bytes;
      if (bytes.length < 56) return [0x80 + bytes.length, ...bytes];
      final lenBytes = _intToBytes(bytes.length);
      return [0xb7 + lenBytes.length, ...lenBytes, ...bytes];
    }
    return [0x80];
  }

  List<int> _rlpEncodeList(List<int> items) {
    if (items.length < 56) {
      return [0xc0 + items.length, ...items];
    }
    final lenBytes = _intToBytes(items.length);
    return [0xf7 + lenBytes.length, ...lenBytes, ...items];
  }

  List<int> _intToBytes(int value) {
    if (value == 0) return [];
    final bytes = <int>[];
    while (value > 0) {
      bytes.insert(0, value & 0xff);
      value >>= 8;
    }
    return bytes;
  }

  List<int> _hexToBytes(String hex) {
    final normalizedHex = hex.length % 2 != 0 ? '0$hex' : hex;
    final bytes = <int>[];
    for (var i = 0; i < normalizedHex.length; i += 2) {
      bytes.add(int.parse(normalizedHex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _stateSubscription?.cancel();
    _ledgerService.dispose();
    super.dispose();
  }
}
