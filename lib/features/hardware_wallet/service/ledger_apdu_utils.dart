// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';

/// Ledger APDU 构建与工具方法
///
/// 纯工具类（全部静态方法），负责：
/// - APDU 命令构建（获取应用名、获取地址、签名交易）
/// - BIP32 派生路径序列化
/// - APDU 响应状态码解析
/// - 数据分块、签名编码等辅助工具
class LedgerApduUtils {
  LedgerApduUtils._(); // 禁止实例化

  // ============ APDU 构建 ============

  /// 构建 GET_APP_NAME APDU
  static Uint8List buildGetAppNameApdu() {
    return Uint8List.fromList([0xB0, 0x01, 0x00, 0x00, 0x00]);
  }

  /// 构建 ETH GET_ADDRESS APDU
  static Uint8List buildEthGetAddressApdu(String path, bool display) {
    final pathBytes = serializeDerivationPath(path);
    final p1 = display ? 0x01 : 0x00;

    return Uint8List.fromList([
      0xE0, // CLA
      0x02, // INS: GET_PUBLIC_KEY
      p1, // P1: display
      0x00, // P2: return address
      pathBytes.length,
      ...pathBytes,
    ]);
  }

  /// 构建 ETH SIGN_TX APDU
  static Uint8List buildEthSignTxApdu(
    String path,
    Uint8List data, {
    required bool isFirst,
  }) {
    List<int> payload;

    if (isFirst) {
      final pathBytes = serializeDerivationPath(path);
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

  // ============ 路径序列化 ============

  /// 序列化 BIP32 派生路径: m/44'/60'/0'/0/0
  static Uint8List serializeDerivationPath(String path) {
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

  // ============ 状态码处理 ============

  /// 处理 APDU 响应状态码
  ///
  /// 标准状态码（最后 2 字节）：
  ///   0x9000 = 成功
  ///   0x6985 / 0x5501 = 用户拒绝
  ///   0x6A82 = 应用未打开
  ///   0x6982 / 0x5515 = 设备已锁定
  ///   0x6700 = 错误长度
  ///   0x6D00 / 0x6E00 = INS/CLA 不支持
  static Uint8List? handleApduStatusCode(int sw, Uint8List result) {
    switch (sw) {
      case 0x9000:
        return result.length > 2 ? result.sublist(0, result.length - 2) : Uint8List(0);
      case 0x6985:
      case 0x5501:
        throw HardwareWalletError(
          code: HardwareWalletError.userRejected,
          message: 'User rejected on device',
        );
      case 0x6A82:
        throw HardwareWalletError(
          code: HardwareWalletError.appNotOpen,
          message: 'App not open on device',
        );
      case 0x6982:
      case 0x5515:
        throw HardwareWalletError(
          code: HardwareWalletError.deviceLocked,
          message: 'Device is locked. Please unlock it first',
        );
      case 0x6700:
        throw HardwareWalletError(
          code: HardwareWalletError.invalidTransaction,
          message: 'Invalid APDU length',
        );
      case 0x6D00:
        throw HardwareWalletError(
          code: HardwareWalletError.appNotOpen,
          message: 'Instruction not supported. Check that the correct app is open',
        );
      case 0x6E00:
        throw HardwareWalletError(
          code: HardwareWalletError.appNotOpen,
          message: 'Class not supported. Wrong app may be open',
        );
      default:
        debugPrint('LedgerService: unrecognized SW 0x${sw.toRadixString(16).padLeft(4, '0')}');
        return result;
    }
  }

  /// 处理旧版 native PlatformException 错误码
  static void handlePlatformExceptionCode(String code) {
    final codeLower = code.toLowerCase();
    final errorMap = <String, (String, String)>{
      '6985': (HardwareWalletError.userRejected, 'User rejected on device'),
      '5501': (HardwareWalletError.userRejected, 'User rejected on device'),
      '6a82': (HardwareWalletError.appNotOpen, 'App not open on device'),
      '6982': (HardwareWalletError.deviceLocked, 'Device is locked'),
      '5515': (HardwareWalletError.deviceLocked, 'Device is locked'),
      '6700': (HardwareWalletError.invalidTransaction, 'Invalid APDU length'),
      '6d00': (HardwareWalletError.appNotOpen, 'Instruction not supported'),
      '6e00': (HardwareWalletError.appNotOpen, 'Class not supported'),
    };

    final entry = errorMap[codeLower];
    if (entry != null) {
      throw HardwareWalletError(code: entry.$1, message: entry.$2);
    }
  }

  // ============ 数据工具 ============

  /// 将数据分块发送（Ledger BLE MTU 限制）
  static List<Uint8List> splitIntoChunks(Uint8List data, int chunkSize) {
    return [
      for (var i = 0; i < data.length; i += chunkSize)
        data.sublist(i, i + chunkSize < data.length ? i + chunkSize : data.length),
    ];
  }

  /// 编码签名为十六进制字符串
  static String encodeSignature(int v, Uint8List r, Uint8List s) {
    final vHex = v.toRadixString(16).padLeft(2, '0');
    final rHex = r.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final sHex = s.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '0x$rHex$sHex$vHex';
  }
}
