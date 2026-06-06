// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/service/keystone_service.dart';
import 'package:n42_wallet/features/hardware_wallet/service/ledger_service.dart';
import 'package:n42_wallet/features/hardware_wallet/service/trezor_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'hardware_wallet_provider_connection.dart';
part 'hardware_wallet_provider_signing.dart';

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
class HardwareWalletProvider extends ChangeNotifier
    with _HardwareWalletConnectionMixin, _HardwareWalletSigningMixin {
  @override
  final LedgerService _ledgerService = LedgerService();
  @override
  final TrezorService _trezorService = TrezorService();
  final KeystoneService _keystoneService = KeystoneService();

  // 状态
  @override
  HardwareWalletConnectionState _connectionState =
      HardwareWalletConnectionState.disconnected;
  @override
  String? _errorMessage;
  @override
  bool _isScanning = false;

  // 设备列表
  @override
  List<BluetoothDeviceInfo> _discoveredDevices = [];
  @override
  List<HardwareWalletDevice> _savedDevices = [];
  @override
  HardwareWalletDevice? _currentDevice;

  // 账户列表
  @override
  List<HardwareWalletAccount> _accounts = [];

  // 当前选中的 coinType（用于 loadMoreAccounts）
  @override
  String _currentCoinType = 'ETH';
  @override
  int _accountLoadGeneration = 0;

  // 订阅
  StreamSubscription? _scanSubscription;
  StreamSubscription? _stateSubscription;

  // Getters
  HardwareWalletConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  bool get isScanning => _isScanning;
  @override
  bool get isConnected =>
      _connectionState == HardwareWalletConnectionState.connected;
  List<BluetoothDeviceInfo> get discoveredDevices => _discoveredDevices;
  List<HardwareWalletDevice> get savedDevices => _savedDevices;
  HardwareWalletDevice? get currentDevice => _currentDevice;
  List<HardwareWalletAccount> get accounts => _accounts;

  /// 获取当前设备的 [KeystoneService]（仅 Keystone 设备有效）
  KeystoneService get keystoneService => _keystoneService;

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

  /// 清除错误
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============ 持久化 ============

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
      AppLogger.w('HardwareWallet', 'failed to load saved devices: $e');
    }
  }

  @override
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

  @override
  Future<void> _persistSavedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = json.encode(
        _savedDevices.map((d) => d.toJson()).toList(),
      );
      await prefs.setString('hardware_wallet_devices', devicesJson);
    } catch (e) {
      AppLogger.w('HardwareWallet', 'failed to save devices: $e');
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
      AppLogger.w('HardwareWallet', 'failed to import account: $e');
      rethrow;
    }
  }

  /// 获取所有已导入的硬件钱包账户
  Future<List<Map<String, dynamic>>> getImportedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw =
          prefs.getStringList('hardware_wallet_imported_accounts') ?? [];
      return raw.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _stateSubscription?.cancel();
    _ledgerService.dispose();
    super.dispose();
  }
}
