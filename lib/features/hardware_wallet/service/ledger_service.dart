// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/service/ledger_apdu_utils.dart';

/// Ledger 设备服务
///
/// 通过蓝牙 BLE 与 Ledger 硬件钱包通信。
///
/// 连接稳定性：
/// - connect() 内部实现最多 3 次重试（线性退避）
/// - 连接成功后启动 keepalive 心跳（每 30s 调 getCurrentApp()）
/// - keepalive 失败自动触发 _onConnectionLost()
///
/// 支持链：
/// - EVM 链（ETH/BNB/MATIC/AVAX/FTM/OP/ARB/BASE）通过 APDU 直接获取地址
/// - BTC 通过 native 平台通道
/// - SOL/ATOM/DOT/TRX 通过 native 平台通道（各链专属 Ledger app）
class LedgerService {
  static final LedgerService _instance = LedgerService._internal();
  factory LedgerService() => _instance;
  LedgerService._internal();

  static const MethodChannel _channel = MethodChannel('hardware_wallet');
  static const EventChannel _scanChannel = EventChannel('hardware_wallet/scan');
  static const String _ledgerServiceUUID = '13d63400-2c97-0004-0000-4c6564676572';
  static const int _maxConnectRetries = 3;
  static const Duration _keepaliveInterval = Duration(seconds: 30);

  HardwareWalletDevice? _connectedDevice;
  HardwareWalletConnectionState _connectionState = HardwareWalletConnectionState.disconnected;
  final StreamController<List<BluetoothDeviceInfo>> _scanResultsController =
      StreamController<List<BluetoothDeviceInfo>>.broadcast();
  final StreamController<HardwareWalletConnectionState> _connectionStateController =
      StreamController<HardwareWalletConnectionState>.broadcast();
  final List<BluetoothDeviceInfo> _discoveredDevices = [];
  StreamSubscription? _scanStreamSubscription;
  Timer? _keepaliveTimer;

  HardwareWalletDevice? get connectedDevice => _connectedDevice;
  HardwareWalletConnectionState get connectionState => _connectionState;
  Stream<List<BluetoothDeviceInfo>> get scanResults => _scanResultsController.stream;
  Stream<HardwareWalletConnectionState> get connectionStateStream => _connectionStateController.stream;
  List<BluetoothDeviceInfo> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  /// 检查蓝牙是否可用
  Future<bool> isBluetoothAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isBluetoothAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check Bluetooth: ${e.message}');
      return false;
    }
  }

  /// 请求蓝牙权限
  Future<bool> requestBluetoothPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestBluetoothPermissions');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to request permissions: ${e.message}');
      return false;
    }
  }

  /// 开始扫描 Ledger 设备
  Future<void> startScan({Duration timeout = const Duration(seconds: 15)}) async {
    _discoveredDevices.clear();
    _updateConnectionState(HardwareWalletConnectionState.scanning);

    try {
      await _channel.invokeMethod('startScan', {
        'serviceUUID': _ledgerServiceUUID,
        'timeout': timeout.inMilliseconds,
      });

      await _scanStreamSubscription?.cancel();

      _scanStreamSubscription = _scanChannel.receiveBroadcastStream().listen(
        (event) {
          if (event is Map) {
            final device = BluetoothDeviceInfo.fromJson(Map<String, dynamic>.from(event));
            if (device.isLedger && !_discoveredDevices.any((d) => d.id == device.id)) {
              _discoveredDevices.add(device);
              _scanResultsController.add(List.from(_discoveredDevices));
            }
          }
        },
        onError: (error) {
          debugPrint('Scan error: $error');
        },
        onDone: () {
          if (_connectionState == HardwareWalletConnectionState.scanning) {
            _updateConnectionState(HardwareWalletConnectionState.disconnected);
          }
        },
      );

      Future.delayed(timeout, () {
        if (_connectionState == HardwareWalletConnectionState.scanning) {
          stopScan();
        }
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to start scan: ${e.message}');
      _updateConnectionState(HardwareWalletConnectionState.error);
      throw HardwareWalletError(
        code: HardwareWalletError.bluetoothDisabled,
        message: e.message ?? 'Failed to start Bluetooth scan',
      );
    }
  }

  /// 停止扫描
  Future<void> stopScan() async {
    try {
      await _scanStreamSubscription?.cancel();
      _scanStreamSubscription = null;
      await _channel.invokeMethod('stopScan');
      if (_connectionState == HardwareWalletConnectionState.scanning) {
        _updateConnectionState(HardwareWalletConnectionState.disconnected);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to stop scan: ${e.message}');
    }
  }

  /// 连接到 Ledger 设备（最多 3 次重试，线性退避）
  Future<HardwareWalletDevice> connect(BluetoothDeviceInfo deviceInfo) async {
    _updateConnectionState(HardwareWalletConnectionState.connecting);

    HardwareWalletError? lastError;

    for (var attempt = 1; attempt <= _maxConnectRetries; attempt++) {
      try {
        final result = await _channel.invokeMethod<Map>('connect', {
          'deviceId': deviceInfo.id,
          'serviceUUID': _ledgerServiceUUID,
        });

        if (result == null) {
          throw HardwareWalletError(
            code: HardwareWalletError.connectionFailed,
            message: 'Failed to connect to device',
          );
        }

        final firmwareVersion = await _getFirmwareVersion();
        final deviceType = _determineDeviceType(deviceInfo.name);

        _connectedDevice = HardwareWalletDevice(
          id: deviceInfo.id,
          name: deviceInfo.name,
          type: deviceType,
          firmwareVersion: firmwareVersion,
          isConnected: true,
          lastConnectedAt: DateTime.now(),
        );

        _updateConnectionState(HardwareWalletConnectionState.connected);
        _startKeepalive();
        return _connectedDevice!;
      } on PlatformException catch (e) {
        lastError = HardwareWalletError(
          code: HardwareWalletError.connectionFailed,
          message: e.message ?? 'Connection failed',
          details: e.details?.toString(),
        );
        debugPrint('Connect attempt $attempt/$_maxConnectRetries failed: ${e.message}');
      } on HardwareWalletError catch (e) {
        lastError = e;
      }

      if (attempt < _maxConnectRetries) {
        await Future.delayed(Duration(seconds: attempt));
      }
    }

    _updateConnectionState(HardwareWalletConnectionState.error);
    throw lastError!;
  }

  /// 断开连接
  Future<void> disconnect() async {
    _stopKeepalive();
    try {
      await _channel.invokeMethod('disconnect');
      _connectedDevice = null;
      _updateConnectionState(HardwareWalletConnectionState.disconnected);
    } on PlatformException catch (e) {
      debugPrint('Failed to disconnect: ${e.message}');
    }
  }

  /// 获取当前打开的应用
  Future<LedgerAppInfo?> getCurrentApp() async {
    if (_connectedDevice == null) return null;

    try {
      final result = await _sendApdu(LedgerApduUtils.buildGetAppNameApdu());
      if (result != null && result.length > 2) {
        final name = String.fromCharCodes(result.sublist(0, result.length - 2));
        return LedgerAppInfo(name: name, version: '', isOpen: true);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get current app: $e');
      return null;
    }
  }

  /// 获取 EVM 链地址
  Future<String?> getEthereumAddress({
    String derivationPath = "m/44'/60'/0'/0/0",
    bool display = false,
  }) async {
    _assertConnected();
    final apdu = LedgerApduUtils.buildEthGetAddressApdu(derivationPath, display);
    final result = await _sendApdu(apdu);
    if (result != null && result.length >= 42) {
      final pubKeyLen = result[0];
      final addressLen = result[1 + pubKeyLen];
      final addressStart = 2 + pubKeyLen;
      return String.fromCharCodes(result.sublist(addressStart, addressStart + addressLen));
    }
    return null;
  }

  /// 获取比特币地址（通过 native 平台通道）
  Future<String?> getBitcoinAddress({
    String derivationPath = "m/84'/0'/0'/0/0",
    bool display = false,
  }) async {
    _assertConnected();
    try {
      return await _channel.invokeMethod<String>('getBitcoinAddress', {
        'path': derivationPath,
        'display': display,
      });
    } on PlatformException catch (e) {
      _throwPlatformError(e, fallbackMessage: 'Failed to get Bitcoin address');
    }
  }

  /// 获取非 EVM/BTC 链地址（SOL / ATOM / DOT / TRX 等）
  Future<String?> getChainAddress({
    required String coinType,
    required String derivationPath,
    bool display = false,
  }) async {
    _assertConnected();
    try {
      return await _channel.invokeMethod<String>('getChainAddress', {
        'coinType': coinType.toUpperCase(),
        'path': derivationPath,
        'display': display,
      });
    } on PlatformException catch (e) {
      _throwPlatformError(e, fallbackMessage: 'Failed to get $coinType address');
    }
  }

  /// 签名以太坊交易
  Future<HardwareWalletSignResponse> signEthereumTransaction({
    required String derivationPath,
    required Uint8List rawTx,
  }) async {
    if (_connectedDevice == null) {
      return HardwareWalletSignResponse.error('No device connected');
    }

    try {
      final chunks = LedgerApduUtils.splitIntoChunks(rawTx, 150);
      Uint8List? response;

      for (var i = 0; i < chunks.length; i++) {
        final apdu = LedgerApduUtils.buildEthSignTxApdu(
          derivationPath,
          chunks[i],
          isFirst: i == 0,
        );
        response = await _sendApdu(apdu);
      }

      if (response != null && response.length >= 65) {
        final v = response[0];
        final r = response.sublist(1, 33);
        final s = response.sublist(33, 65);
        final signature = LedgerApduUtils.encodeSignature(v, r, s);
        return HardwareWalletSignResponse.success(signature: signature);
      }

      return HardwareWalletSignResponse.error('Invalid signature response');
    } on HardwareWalletError catch (e) {
      return HardwareWalletSignResponse.error(e.userFriendlyMessage);
    } catch (e) {
      return HardwareWalletSignResponse.error(e.toString());
    }
  }

  /// 签名以太坊消息（EIP-191 personal_sign）
  Future<HardwareWalletSignResponse> signEthereumMessage({
    required String derivationPath,
    required String message,
  }) async {
    return _signViaChannel('signEthMessage', {
      'path': derivationPath,
      'message': message,
    });
  }

  /// 签名比特币交易
  Future<HardwareWalletSignResponse> signBitcoinTransaction({
    required String derivationPath,
    required Map<String, dynamic> txData,
  }) async {
    return _signViaChannel('signBitcoinTx', {
      'path': derivationPath,
      'txData': txData,
    }, signatureKey: 'signedTx');
  }

  /// 签名非 EVM/BTC 链交易（SOL / ATOM / DOT / TRX）
  Future<HardwareWalletSignResponse> signChainTransaction({
    required String coinType,
    required String derivationPath,
    required Map<String, dynamic> txData,
  }) async {
    return _signViaChannel('signChainTx', {
      'coinType': coinType.toUpperCase(),
      'path': derivationPath,
      'txData': txData,
    });
  }

  /// 通用平台通道签名：调用 [method]，从结果中提取 [signatureKey] 字段
  Future<HardwareWalletSignResponse> _signViaChannel(
    String method,
    Map<String, dynamic> args, {
    String signatureKey = 'signature',
  }) async {
    if (_connectedDevice == null) {
      return HardwareWalletSignResponse.error('No device connected');
    }

    try {
      final result = await _channel.invokeMethod<Map>(method, args);

      if (result != null && result[signatureKey] != null) {
        return HardwareWalletSignResponse.success(
          signature: result[signatureKey] as String,
          txHash: result['txHash'] as String?,
        );
      }

      return HardwareWalletSignResponse.error('Signing failed');
    } on PlatformException catch (e) {
      if (e.code == 'USER_REJECTED') {
        return HardwareWalletSignResponse.error('Transaction rejected on device');
      }
      return HardwareWalletSignResponse.error(e.message ?? 'Signing failed');
    }
  }

  void _assertConnected() {
    if (_connectedDevice == null) {
      throw HardwareWalletError(
        code: HardwareWalletError.deviceNotFound,
        message: 'No device connected',
      );
    }
  }

  /// 将 PlatformException 转换为 HardwareWalletError 并抛出（Never 返回）
  Never _throwPlatformError(PlatformException e, {required String fallbackMessage}) {
    LedgerApduUtils.handlePlatformExceptionCode(e.code);
    throw HardwareWalletError(
      code: HardwareWalletError.signingFailed,
      message: e.message ?? fallbackMessage,
    );
  }

  void _updateConnectionState(HardwareWalletConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  void _startKeepalive() {
    _stopKeepalive();
    _keepaliveTimer = Timer.periodic(_keepaliveInterval, (_) async {
      if (_connectionState != HardwareWalletConnectionState.connected) {
        _stopKeepalive();
        return;
      }
      try {
        await getCurrentApp();
      } catch (e) {
        debugPrint('Keepalive failed: $e');
        _onConnectionLost();
      }
    });
  }

  void _stopKeepalive() {
    _keepaliveTimer?.cancel();
    _keepaliveTimer = null;
  }

  void _onConnectionLost() {
    _stopKeepalive();
    _connectedDevice = _connectedDevice?.copyWith(isConnected: false);
    _updateConnectionState(HardwareWalletConnectionState.error);
    debugPrint('LedgerService: connection lost');
  }

  HardwareWalletType _determineDeviceType(String name) {
    final n = name.toLowerCase();
    if (n.contains('nano x')) return HardwareWalletType.ledgerNanoX;
    if (n.contains('nano s plus') || n.contains('nano s+')) return HardwareWalletType.ledgerNanoSPlus;
    if (n.contains('stax')) return HardwareWalletType.ledgerStax;
    return HardwareWalletType.ledgerNanoX;
  }

  Future<String?> _getFirmwareVersion() async {
    try {
      return await _channel.invokeMethod<String>('getFirmwareVersion');
    } catch (_) {
      return null;
    }
  }

  /// 发送 APDU 并处理标准 Ledger 状态码
  Future<Uint8List?> _sendApdu(Uint8List apdu) async {
    try {
      final result = await _channel.invokeMethod<Uint8List>('sendApdu', {
        'apdu': apdu,
      });

      if (result != null && result.length >= 2) {
        final sw = (result[result.length - 2] << 8) | result[result.length - 1];
        return LedgerApduUtils.handleApduStatusCode(sw, result);
      }

      return result;
    } on PlatformException catch (e) {
      LedgerApduUtils.handlePlatformExceptionCode(e.code);
      rethrow;
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    _stopKeepalive();
    await _scanStreamSubscription?.cancel();
    _scanStreamSubscription = null;
    await disconnect();
    await _scanResultsController.close();
    await _connectionStateController.close();
  }
}
