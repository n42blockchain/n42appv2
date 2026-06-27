/// 通话端到端加密（LiveKit 帧加密）
///
/// 与 Matrix 文本 E2EE（[core/encryption/e2ee_manager.dart]）是两套独立机制：
/// 这里是 **WebRTC 媒体帧** 的端到端加密，基于 LiveKit insertable streams /
/// frame cryptor。开启后，音视频帧在离开本端前用共享密钥加密，SFU（LiveKit
/// 服务器）只转发密文，无法解密媒体内容。
///
/// ## 这是真实可用的能力
///
/// flutter_webrtc 原生侧实现了 frame cryptor，[BaseKeyProvider] +
/// [E2EEOptions] 接入 [RoomOptions] 后，端到端加密真实生效（非占位）。
/// 唯一前提是参会各端持有相同的 [sharedKey]——本类不规定密钥分发方式，
/// 调用方应通过既有 Matrix E2EE 通道（房间内安全下发）或带外约定来共享。
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../core/utils/debug_log.dart';

/// 通话 E2EE 密钥/选项提供器
class CallE2EEProvider {
  BaseKeyProvider? _keyProvider;
  bool _enabled = false;

  /// 是否已构建并启用 E2EE
  bool get isEnabled => _enabled;

  /// 当前使用的密钥提供器（构建后非空）
  BaseKeyProvider? get keyProvider => _keyProvider;

  /// 由共享密钥构建 [E2EEOptions]，用于传入 `RoomOptions.encryption`。
  ///
  /// [sharedKey] 为参会各端约定的相同密钥（任意长度字符串，内部会做 SHA-256
  /// 派生为定长密钥，避免弱口令直接当帧密钥）。
  Future<E2EEOptions> buildOptions(String sharedKey) async {
    final provider = await BaseKeyProvider.create(sharedKey: true);
    final derived = _deriveKey(sharedKey);
    await provider.setSharedKey(derived);
    _keyProvider = provider;
    _enabled = true;
    debugLog('CallE2EEProvider: E2EE options built (shared key set)');
    return E2EEOptions(keyProvider: provider);
  }

  /// 轮换共享密钥（前向保密）。需各端同步调用并约定新密钥。
  Future<void> rotateSharedKey(String newSharedKey) async {
    final provider = _keyProvider;
    if (provider == null) {
      debugLog('CallE2EEProvider: rotateSharedKey ignored — not initialized');
      return;
    }
    await provider.setSharedKey(_deriveKey(newSharedKey));
    debugLog('CallE2EEProvider: shared key rotated');
  }

  /// 棘轮推进当前共享密钥（无需带外重新约定，各端同步 ratchet 即可）。
  Future<void> ratchet() async {
    final provider = _keyProvider;
    if (provider == null) return;
    try {
      await provider.ratchetSharedKey();
      debugLog('CallE2EEProvider: shared key ratcheted');
    } catch (e) {
      debugLog('CallE2EEProvider: ratchet failed: $e');
    }
  }

  /// 把任意长度的口令派生为 base64 的定长（32 字节）密钥。
  String _deriveKey(String input) {
    final digest = sha256.convert(utf8.encode(input));
    return base64Encode(Uint8List.fromList(digest.bytes));
  }

  void reset() {
    _keyProvider = null;
    _enabled = false;
  }
}
