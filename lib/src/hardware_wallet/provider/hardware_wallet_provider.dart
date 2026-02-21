// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42appv2/src/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42appv2/src/hardware_wallet/service/keystone_service.dart';
import 'package:n42appv2/src/hardware_wallet/service/ledger_service.dart';
import 'package:n42appv2/src/hardware_wallet/service/trezor_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 硬件钱包 Provider
///
/// 管理硬件钱包连接、账户和签名操作。
///
/// 支持的链（BIP-44 派生路径）：
/// EVM 链：ETH/BNB/MATIC/AVAX/FTM/OP/ARB/BASE → m/44'/60'/0'/0/
/// BTC:    m/84'/0'/0'/0/   (Native SegWit P2WPKH)
/// LTC:    m/84'/2'/0'/0/   (Native SegWit)
/// DOGE:   m/44'/3'/0'/0/
/// BCH:    m/44'/145'/0'/0/
/// SOL:    m/44'/501'/0'/0' (Solana app)
/// ATOM:   m/44'/118'/0'/0/ (Cosmos app)
/// DOT:    m/44'/354'/0'/0/ (Polkadot app)
/// TRX:    m/44'/195'/0'/0/ (Tron app)
class HardwareWalletProvider extends ChangeNotifier {
  final LedgerService _ledgerService = LedgerService();
  final TrezorService _trezorService = TrezorService();
  final KeystoneService _keystoneService = KeystoneService();

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

  // 当前选中的 coinType（用于 loadMoreAccounts）
  String _currentCoinType = 'ETH';

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
    if (device.isTrezor) {
      return await _reconnectTrezor(device);
    }
    if (device.isKeystone) {
      // Keystone 是气隙设备，无需重新连接；直接标记为"已连接"
      _currentDevice = device.copyWith(isConnected: true);
      _connectionState = HardwareWalletConnectionState.connected;
      notifyListeners();
      return true;
    }
    // Ledger BLE 重连
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
  ///
  /// 返回 [HardwareWalletDevice]（连接成功）或 null（失败）。
  /// 错误消息通过 [errorMessage] getter 获取。
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
  ///
  /// Keystone 设备不需要主动连接；调用方传入从 [KeystoneService.parseSyncQr]
  /// 解析得到的 [KeystoneAccountInfo]，此方法将其保存为虚拟设备。
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

  /// 获取当前设备的 [KeystoneService]（仅 Keystone 设备有效）
  KeystoneService get keystoneService => _keystoneService;

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

  /// 加载账户列表（前 5 个）
  ///
  /// 支持的 coinType 及其 BIP-44 路径：
  /// - EVM 链：m/44'/60'/0'/0/   (ETH/BNB/MATIC/AVAX/FTM/OP/ARB/BASE)
  /// - BTC:   m/84'/0'/0'/0/    (Native SegWit)
  /// - LTC:   m/84'/2'/0'/0/    (Native SegWit)
  /// - DOGE:  m/44'/3'/0'/0/
  /// - BCH:   m/44'/145'/0'/0/
  /// - SOL:   m/44'/501'/0'/0'
  /// - ATOM:  m/44'/118'/0'/0/
  /// - DOT:   m/44'/354'/0'/0/
  /// - TRX:   m/44'/195'/0'/0/
  Future<void> loadAccounts(String coinType) async {
    if (!isConnected || _currentDevice == null) return;

    _accounts = [];
    _currentCoinType = coinType.toUpperCase();

    await _loadAccountsFrom(coinType, startIndex: 0, count: 5);

    // 更新设备的账户列表
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
  ///
  /// 根据当前连接设备类型自动路由到 Ledger 或 Trezor 服务。
  /// Keystone 设备通过 xpub 本地派生地址，暂不在此方法处理。
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
          // SOL / ATOM / DOT / TRX — 通过 native 平台通道
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
  ///
  /// 根据当前设备类型和 coinType 路由到对应的签名实现：
  ///
  /// **Trezor 设备**：
  /// - EVM / BTC / SOL / ATOM / DOT / TRX → Trezor 平台通道
  ///
  /// **Ledger 设备**：
  /// - EVM 链 → signEthereumTransaction / signEthereumMessage
  /// - BTC/LTC/DOGE/BCH → signBitcoinTransaction
  /// - SOL/ATOM/DOT/TRX → signChainTransaction（native 实现）
  ///
  /// **Keystone 设备**：
  /// - 返回 [HardwareWalletSignResponse] 标记为需要 QR 签名。
  ///   调用方需检测 [needsKeystoneQr] == true，然后导航至 KeystoneSignPage。
  Future<HardwareWalletSignResponse> signTransaction(
    HardwareWalletSignRequest request,
  ) async {
    if (!isConnected) {
      return HardwareWalletSignResponse.error('No device connected');
    }

    final coinType = request.coinType.toUpperCase();

    // ── Trezor ──────────────────────────────────────────────────
    if (_currentDevice?.isTrezor ?? false) {
      return await _signWithTrezor(request, coinType);
    }

    // ── Keystone ────────────────────────────────────────────────
    if (_currentDevice?.isKeystone ?? false) {
      // Keystone 签名需要 QR 交互；返回特殊响应让 UI 层处理
      return HardwareWalletSignResponse(
        success: false,
        error: null,
        needsKeystoneQr: true,
        rawTxForQr: _isEvmChain(coinType)
            ? _serializeEthTransaction(request.transactionData)
            : null,
      );
    }

    // ── Ledger ──────────────────────────────────────────────────
    if (_isEvmChain(coinType)) {
      if (request.signType == HardwareWalletSignType.message) {
        return await signEthereumMessage(
          derivationPath: request.derivationPath,
          message: request.message ?? '',
        );
      } else {
        final rawTx = _serializeEthTransaction(request.transactionData);
        return await signEthereumTransaction(
          derivationPath: request.derivationPath,
          rawTx: rawTx,
        );
      }
    }

    if (_isBitcoinLikeChain(coinType)) {
      return await signBitcoinTransaction(
        derivationPath: request.derivationPath,
        txData: request.transactionData,
      );
    }

    // SOL / ATOM / DOT / TRX — 通过 native 实现
    switch (coinType) {
      case 'SOL':
      case 'ATOM':
      case 'DOT':
      case 'TRX':
        return await _ledgerService.signChainTransaction(
          coinType: coinType,
          derivationPath: request.derivationPath,
          txData: request.transactionData,
        );
      default:
        return HardwareWalletSignResponse.error(
          'Unsupported coin type: $coinType',
        );
    }
  }

  Future<HardwareWalletSignResponse> _signWithTrezor(
    HardwareWalletSignRequest request,
    String coinType,
  ) async {
    if (_isEvmChain(coinType)) {
      if (request.signType == HardwareWalletSignType.message) {
        return await _trezorService.signMessage(
          derivationPath: request.derivationPath,
          messageBytes: Uint8List.fromList(
            (request.message ?? '').codeUnits,
          ),
        );
      } else if (request.signType == HardwareWalletSignType.typedData) {
        return await _trezorService.signTypedData(
          derivationPath: request.derivationPath,
          typedDataJson: request.message ?? '{}',
        );
      } else {
        return await _trezorService.signEthTransaction(
          derivationPath: request.derivationPath,
          txData: request.transactionData,
        );
      }
    }

    if (_isBitcoinLikeChain(coinType)) {
      final psbtHex = request.transactionData['psbtHex'] as String? ?? '';
      return await _trezorService.signBtcTransaction(
        derivationPath: request.derivationPath,
        psbtHex: psbtHex,
      );
    }

    // SOL / other via generic channel
    return await _trezorService.signChainTransaction(
      coinType: coinType,
      derivationPath: request.derivationPath,
      txData: request.transactionData,
    );
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

  /// 序列化以太坊交易为 RLP 编码字节
  ///
  /// 支持两种格式：
  /// - EIP-1559 (type 2)：当 txData 包含 maxFeePerGas 或 maxPriorityFeePerGas 时使用
  ///   格式: 0x02 || RLP([chainId, nonce, maxPriorityFeePerGas, maxFeePerGas, gasLimit, to, value, data, accessList])
  /// - Legacy (type 0)：其余情况，含 EIP-155 重放保护
  ///   格式: RLP([nonce, gasPrice, gasLimit, to, value, data, chainId, 0, 0])
  Uint8List _serializeEthTransaction(Map<String, dynamic> txData) {
    final bool isEip1559 =
        txData.containsKey('maxFeePerGas') || txData.containsKey('maxPriorityFeePerGas');

    if (isEip1559) {
      return _serializeEip1559Transaction(txData);
    } else {
      return _serializeLegacyTransaction(txData);
    }
  }

  /// 序列化 EIP-1559 (type 2) 交易
  Uint8List _serializeEip1559Transaction(Map<String, dynamic> txData) {
    // 字段顺序: chainId, nonce, maxPriorityFeePerGas, maxFeePerGas, gasLimit, to, value, data, accessList
    final items = <List<int>>[
      _rlpEncode(txData['chainId'] ?? 1),
      _rlpEncode(txData['nonce'] ?? 0),
      _rlpEncode(txData['maxPriorityFeePerGas'] ?? '0x0'),
      _rlpEncode(txData['maxFeePerGas'] ?? '0x0'),
      _rlpEncode(txData['gasLimit'] ?? txData['gas'] ?? '0x0'),
      _rlpEncode(txData['to'] ?? ''),
      _rlpEncode(txData['value'] ?? '0x0'),
      _rlpEncode(txData['data'] ?? '0x'),
      // accessList: 空列表 RLP
      ...[_rlpEncodeList([])],
    ];

    final payload = items.expand((e) => e).toList();
    final rlpList = _rlpEncodeList(payload);

    // type 2 前缀 0x02
    return Uint8List.fromList([0x02, ...rlpList]);
  }

  /// 序列化 Legacy (type 0) 交易，含 EIP-155 重放保护
  Uint8List _serializeLegacyTransaction(Map<String, dynamic> txData) {
    final chainId = txData['chainId'] ?? 1;

    // 字段顺序: nonce, gasPrice, gasLimit, to, value, data, chainId (EIP-155), 0, 0
    final items = <List<int>>[
      _rlpEncode(txData['nonce'] ?? 0),
      _rlpEncode(txData['gasPrice'] ?? '0x0'),
      _rlpEncode(txData['gasLimit'] ?? txData['gas'] ?? '0x0'),
      _rlpEncode(txData['to'] ?? ''),
      _rlpEncode(txData['value'] ?? '0x0'),
      _rlpEncode(txData['data'] ?? '0x'),
      // EIP-155: v=chainId, r=0, s=0
      _rlpEncode(chainId),
      [0x80], // r = empty
      [0x80], // s = empty
    ];

    final payload = items.expand((e) => e).toList();
    return Uint8List.fromList(_rlpEncodeList(payload));
  }

  /// RLP 编码单个值
  ///
  /// 支持：
  /// - int → 直接编码
  /// - String（十六进制带 0x）→ 转为字节编码
  /// - String（十六进制不带 0x 的地址）→ 转为字节编码
  List<int> _rlpEncode(dynamic value) {
    if (value is int) {
      if (value == 0) return [0x80];
      if (value < 0x80) return [value];
      final bytes = _intToMinBytes(value);
      return [0x80 + bytes.length, ...bytes];
    }

    if (value is String) {
      // 十六进制字符串
      final hexStr = value.startsWith('0x') ? value.substring(2) : value;

      // 地址（40 字符十六进制）或空
      if (hexStr.isEmpty) return [0x80];

      final bytes = _hexToBytes(hexStr);

      // 整数编码（去除前导零）
      // 判断是否应作为整数编码：不是固定长度地址且无前导零意义
      if (bytes.length == 20) {
        // 以太坊地址：直接编码为字节串
        return bytes.length < 56
            ? [0x80 + bytes.length, ...bytes]
            : [0xb7 + _intToMinBytes(bytes.length).length, ..._intToMinBytes(bytes.length), ...bytes];
      }

      // 数值型十六进制：去除前导零
      final stripped = _stripLeadingZeroBytes(bytes);
      if (stripped.isEmpty) return [0x80];
      if (stripped.length == 1 && stripped[0] < 0x80) return stripped;
      if (stripped.length < 56) return [0x80 + stripped.length, ...stripped];
      final lenBytes = _intToMinBytes(stripped.length);
      return [0xb7 + lenBytes.length, ...lenBytes, ...stripped];
    }

    return [0x80];
  }

  /// RLP 编码列表（已编码的各字段拼接在一起）
  List<int> _rlpEncodeList(List<int> encodedItems) {
    if (encodedItems.isEmpty) return [0xc0];
    if (encodedItems.length < 56) {
      return [0xc0 + encodedItems.length, ...encodedItems];
    }
    final lenBytes = _intToMinBytes(encodedItems.length);
    return [0xf7 + lenBytes.length, ...lenBytes, ...encodedItems];
  }

  /// 将整数转换为最小表示的字节列表（大端序，无前导零）
  List<int> _intToMinBytes(int value) {
    if (value == 0) return [];
    final bytes = <int>[];
    while (value > 0) {
      bytes.add(value & 0xff);
      value >>= 8;
    }
    return bytes.reversed.toList();
  }

  /// 十六进制字符串转字节列表
  List<int> _hexToBytes(String hex) {
    final normalized = hex.length % 2 != 0 ? '0$hex' : hex;
    final bytes = <int>[];
    for (var i = 0; i < normalized.length; i += 2) {
      bytes.add(int.parse(normalized.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  /// 去除字节列表前导零
  List<int> _stripLeadingZeroBytes(List<int> bytes) {
    var start = 0;
    while (start < bytes.length && bytes[start] == 0) {
      start++;
    }
    return bytes.sublist(start);
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _stateSubscription?.cancel();
    _ledgerService.dispose();
    super.dispose();
  }
}
