// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:n42appv2/src/hardware_wallet/models/hardware_wallet_models.dart';

/// Ledger 设备服务
///
/// 通过蓝牙 BLE 与 Ledger 硬件钱包通信
class LedgerService {
  static final LedgerService _instance = LedgerService._internal();
  factory LedgerService() => _instance;
  LedgerService._internal();

  // 平台通道
  static const MethodChannel _channel = MethodChannel('hardware_wallet');
  static const EventChannel _scanChannel = EventChannel('hardware_wallet/scan');

  // Ledger BLE 服务 UUID
  static const String _ledgerServiceUUID = '13d63400-2c97-0004-0000-4c6564676572';

  // 当前连接的设备
  HardwareWalletDevice? _connectedDevice;
  HardwareWalletConnectionState _connectionState = HardwareWalletConnectionState.disconnected;

  // 事件流
  final StreamController<List<BluetoothDeviceInfo>> _scanResultsController =
      StreamController<List<BluetoothDeviceInfo>>.broadcast();
  final StreamController<HardwareWalletConnectionState> _connectionStateController =
      StreamController<HardwareWalletConnectionState>.broadcast();

  // 扫描到的设备
  final List<BluetoothDeviceInfo> _discoveredDevices = [];

  // 扫描流订阅（防止泄漏）
  StreamSubscription? _scanStreamSubscription;

  // Getters
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

      // 取消之前的订阅，防止泄漏
      await _scanStreamSubscription?.cancel();

      // 监听扫描结果
      _scanStreamSubscription = _scanChannel.receiveBroadcastStream().listen(
        (event) {
          if (event is Map) {
            final device = BluetoothDeviceInfo.fromJson(Map<String, dynamic>.from(event));
            // 只添加 Ledger 设备
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

      // 设置超时
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

  /// 连接到 Ledger 设备
  Future<HardwareWalletDevice> connect(BluetoothDeviceInfo deviceInfo) async {
    _updateConnectionState(HardwareWalletConnectionState.connecting);

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

      // 获取设备信息
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
      return _connectedDevice!;
    } on PlatformException catch (e) {
      _updateConnectionState(HardwareWalletConnectionState.error);
      throw HardwareWalletError(
        code: HardwareWalletError.connectionFailed,
        message: e.message ?? 'Connection failed',
        details: e.details?.toString(),
      );
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
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
      final result = await _sendApdu(_buildGetAppNameApdu());
      if (result != null && result.length > 2) {
        final name = String.fromCharCodes(result.sublist(0, result.length - 2));
        return LedgerAppInfo(
          name: name,
          version: '',
          isOpen: true,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get current app: $e');
      return null;
    }
  }

  /// 获取以太坊地址
  Future<String?> getEthereumAddress({
    String derivationPath = "m/44'/60'/0'/0/0",
    bool display = false,
  }) async {
    if (_connectedDevice == null) {
      throw HardwareWalletError(
        code: HardwareWalletError.deviceNotFound,
        message: 'No device connected',
      );
    }

    try {
      final apdu = _buildEthGetAddressApdu(derivationPath, display);
      final result = await _sendApdu(apdu);

      if (result != null && result.length >= 42) {
        // 解析响应: 公钥长度(1) + 公钥 + 地址长度(1) + 地址 + 链码(可选)
        final pubKeyLen = result[0];
        final addressLen = result[1 + pubKeyLen];
        final addressStart = 2 + pubKeyLen;
        final addressBytes = result.sublist(addressStart, addressStart + addressLen);
        return String.fromCharCodes(addressBytes);
      }

      return null;
    } on PlatformException catch (e) {
      if (e.code == 'USER_REJECTED') {
        throw HardwareWalletError(
          code: HardwareWalletError.userRejected,
          message: 'User rejected on device',
        );
      }
      throw HardwareWalletError(
        code: HardwareWalletError.signingFailed,
        message: e.message ?? 'Failed to get address',
      );
    }
  }

  /// 获取比特币地址
  Future<String?> getBitcoinAddress({
    String derivationPath = "m/84'/0'/0'/0/0",
    bool display = false,
  }) async {
    if (_connectedDevice == null) {
      throw HardwareWalletError(
        code: HardwareWalletError.deviceNotFound,
        message: 'No device connected',
      );
    }

    try {
      final result = await _channel.invokeMethod<String>('getBitcoinAddress', {
        'path': derivationPath,
        'display': display,
      });
      return result;
    } on PlatformException catch (e) {
      throw HardwareWalletError(
        code: HardwareWalletError.signingFailed,
        message: e.message ?? 'Failed to get Bitcoin address',
      );
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
      // 分块发送交易数据
      final chunks = _splitIntoChunks(rawTx, 150);
      Uint8List? response;

      for (var i = 0; i < chunks.length; i++) {
        final isFirst = i == 0;
        final apdu = _buildEthSignTxApdu(
          derivationPath,
          chunks[i],
          isFirst: isFirst,
        );
        response = await _sendApdu(apdu);
      }

      if (response != null && response.length >= 65) {
        // 解析签名: v(1) + r(32) + s(32)
        final v = response[0];
        final r = response.sublist(1, 33);
        final s = response.sublist(33, 65);

        final signature = _encodeSignature(v, r, s);
        return HardwareWalletSignResponse.success(signature: signature);
      }

      return HardwareWalletSignResponse.error('Invalid signature response');
    } on HardwareWalletError catch (e) {
      return HardwareWalletSignResponse.error(e.userFriendlyMessage);
    } catch (e) {
      return HardwareWalletSignResponse.error(e.toString());
    }
  }

  /// 签名以太坊消息
  Future<HardwareWalletSignResponse> signEthereumMessage({
    required String derivationPath,
    required String message,
  }) async {
    if (_connectedDevice == null) {
      return HardwareWalletSignResponse.error('No device connected');
    }

    try {
      final result = await _channel.invokeMethod<Map>('signEthMessage', {
        'path': derivationPath,
        'message': message,
      });

      if (result != null && result['signature'] != null) {
        return HardwareWalletSignResponse.success(
          signature: result['signature'] as String,
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

  /// 签名比特币交易
  Future<HardwareWalletSignResponse> signBitcoinTransaction({
    required String derivationPath,
    required Map<String, dynamic> txData,
  }) async {
    if (_connectedDevice == null) {
      return HardwareWalletSignResponse.error('No device connected');
    }

    try {
      final result = await _channel.invokeMethod<Map>('signBitcoinTx', {
        'path': derivationPath,
        'txData': txData,
      });

      if (result != null && result['signedTx'] != null) {
        return HardwareWalletSignResponse.success(
          signature: result['signedTx'] as String,
          txHash: result['txHash'] as String?,
        );
      }

      return HardwareWalletSignResponse.error('Signing failed');
    } on PlatformException catch (e) {
      return HardwareWalletSignResponse.error(e.message ?? 'Signing failed');
    }
  }

  // ============ Private Methods ============

  void _updateConnectionState(HardwareWalletConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  HardwareWalletType _determineDeviceType(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('nano x')) {
      return HardwareWalletType.ledgerNanoX;
    } else if (nameLower.contains('nano s plus') || nameLower.contains('nano s+')) {
      return HardwareWalletType.ledgerNanoSPlus;
    } else if (nameLower.contains('stax')) {
      return HardwareWalletType.ledgerStax;
    }
    // 默认为 Nano X
    return HardwareWalletType.ledgerNanoX;
  }

  Future<String?> _getFirmwareVersion() async {
    try {
      final result = await _channel.invokeMethod<String>('getFirmwareVersion');
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> _sendApdu(Uint8List apdu) async {
    try {
      final result = await _channel.invokeMethod<Uint8List>('sendApdu', {
        'apdu': apdu,
      });
      return result;
    } on PlatformException catch (e) {
      if (e.code == '6985') {
        throw HardwareWalletError(
          code: HardwareWalletError.userRejected,
          message: 'User rejected on device',
        );
      } else if (e.code == '6a82') {
        throw HardwareWalletError(
          code: HardwareWalletError.appNotOpen,
          message: 'App not open on device',
        );
      }
      rethrow;
    }
  }

  // ============ APDU Building ============

  Uint8List _buildGetAppNameApdu() {
    // INS_GET_APP_NAME: B0 01 00 00 00
    return Uint8List.fromList([0xB0, 0x01, 0x00, 0x00, 0x00]);
  }

  Uint8List _buildEthGetAddressApdu(String path, bool display) {
    final pathBytes = _serializeDerivationPath(path);
    final p1 = display ? 0x01 : 0x00;

    // CLA INS P1 P2 Lc Data
    return Uint8List.fromList([
      0xE0, // CLA
      0x02, // INS: GET_PUBLIC_KEY
      p1, // P1: display
      0x00, // P2: return address
      pathBytes.length,
      ...pathBytes,
    ]);
  }

  Uint8List _buildEthSignTxApdu(String path, Uint8List data, {required bool isFirst}) {
    List<int> payload;

    if (isFirst) {
      final pathBytes = _serializeDerivationPath(path);
      payload = [...pathBytes, ...data];
    } else {
      payload = data.toList();
    }

    return Uint8List.fromList([
      0xE0, // CLA
      0x04, // INS: SIGN
      isFirst ? 0x00 : 0x80, // P1: first or subsequent
      0x00, // P2
      payload.length,
      ...payload,
    ]);
  }

  Uint8List _serializeDerivationPath(String path) {
    // 解析 BIP32 路径: m/44'/60'/0'/0/0
    final components = path.split('/').where((c) => c.isNotEmpty && c != 'm').toList();
    final result = <int>[components.length];

    for (final component in components) {
      final hardened = component.endsWith("'");
      final numStr = hardened ? component.substring(0, component.length - 1) : component;
      var value = int.parse(numStr);
      if (hardened) {
        value += 0x80000000;
      }

      // 大端序 4 字节
      result.add((value >> 24) & 0xFF);
      result.add((value >> 16) & 0xFF);
      result.add((value >> 8) & 0xFF);
      result.add(value & 0xFF);
    }

    return Uint8List.fromList(result);
  }

  List<Uint8List> _splitIntoChunks(Uint8List data, int chunkSize) {
    final chunks = <Uint8List>[];
    for (var i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      chunks.add(data.sublist(i, end));
    }
    return chunks;
  }

  String _encodeSignature(int v, Uint8List r, Uint8List s) {
    final vHex = v.toRadixString(16).padLeft(2, '0');
    final rHex = r.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final sHex = s.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '0x$rHex$sHex$vHex';
  }

  /// 释放资源
  Future<void> dispose() async {
    // 先取消订阅和断开连接，再关闭流
    await _scanStreamSubscription?.cancel();
    _scanStreamSubscription = null;
    await disconnect();
    await _scanResultsController.close();
    await _connectionStateController.close();
  }
}
