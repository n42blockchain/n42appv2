import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/entities/mini_app_entity.dart';
import '../../integration/wallet_bridge.dart';
import '../theme/app_colors.dart';
import '../utils/debug_log.dart';

/// Mini App <-> Native 通信消息
class _BridgeMessage {
  final String method;
  final String? id;
  final Map<String, dynamic>? params;

  _BridgeMessage({required this.method, this.id, this.params});

  factory _BridgeMessage.fromJson(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return _BridgeMessage(
      method: map['method'] as String,
      id: map['id']?.toString(),
      params: map['params'] as Map<String, dynamic>?,
    );
  }
}

enum MiniAppChatActionType { sendMessage, close, ignore }

@immutable
class MiniAppChatAction {
  final MiniAppChatActionType type;
  final String? text;

  const MiniAppChatAction._(this.type, {this.text});

  const MiniAppChatAction.ignore() : this._(MiniAppChatActionType.ignore);

  const MiniAppChatAction.close() : this._(MiniAppChatActionType.close);

  const MiniAppChatAction.sendMessage(String text)
    : this._(MiniAppChatActionType.sendMessage, text: text);
}

MiniAppChatAction parseMiniAppChatAction(
  String rawMessage, {
  required bool canSendMessage,
}) {
  final message = _BridgeMessage.fromJson(rawMessage);

  switch (message.method) {
    case 'sendMessage':
      if (!canSendMessage) {
        return const MiniAppChatAction.ignore();
      }
      final text = message.params?['text'] as String?;
      final trimmed = text?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return const MiniAppChatAction.ignore();
      }
      return MiniAppChatAction.sendMessage(trimmed);
    case 'close':
      return const MiniAppChatAction.close();
    default:
      return const MiniAppChatAction.ignore();
  }
}

Uri? normalizeTrustedMiniAppUri(String? rawUrl) {
  final normalized = rawUrl?.trim();
  if (normalized == null || normalized.isEmpty) return null;

  final uri = Uri.tryParse(normalized);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    return null;
  }

  return uri;
}

bool isTrustedMiniAppNavigationUrl({
  required String? appUrl,
  required String? candidateUrl,
}) {
  final trustedUri = normalizeTrustedMiniAppUri(appUrl);
  final candidateUri = normalizeTrustedMiniAppUri(candidateUrl);
  if (trustedUri == null || candidateUri == null) return false;

  return trustedUri.host == candidateUri.host &&
      trustedUri.port == candidateUri.port;
}

/// Mini App JS Bridge 服务
///
/// 向 WebView 注入 `window.n42` API，提供 Mini App 与原生钱包/聊天的通信通道。
///
/// ## JavaScript API
/// ```js
/// // 钱包
/// const addr = await window.n42.wallet.getAddress();
/// const tx   = await window.n42.wallet.requestTransaction({to, value, data});
///
/// // 聊天
/// window.n42.chat.sendMessage('Hello!');
/// window.n42.chat.close();
/// const roomId = window.n42.chat.getRoomId();
/// ```
class MiniAppBridgeService {
  final IWalletBridge _walletBridge;
  final String _roomId;
  final MiniAppEntity? _app;

  /// 外部回调：Mini App 要发送消息到聊天室
  final void Function(String text)? onSendMessage;

  /// 外部回调：Mini App 请求关闭
  final VoidCallback? onClose;

  MiniAppBridgeService({
    required IWalletBridge walletBridge,
    required String roomId,
    MiniAppEntity? app,
    this.onSendMessage,
    this.onClose,
  }) : _walletBridge = walletBridge,
       _roomId = roomId,
       _app = app;

  /// 检查 Mini App 是否拥有指定权限
  bool _hasPermission(MiniAppPermission permission) {
    if ((permission == MiniAppPermission.chatRead ||
            permission == MiniAppPermission.chatSend) &&
        _roomId.trim().isEmpty) {
      return false;
    }
    if (_app == null) {
      // 没有清单时只保留低风险只读能力，避免把交易或发消息默认放开。
      return permission == MiniAppPermission.walletAddress;
    }
    return _app.permissions.contains(permission);
  }

  /// 向 WebViewController 注册所有 JS Channel
  void registerChannels(WebViewController controller, BuildContext context) {
    controller
      ..addJavaScriptChannel(
        'N42WalletChannel',
        onMessageReceived: (msg) =>
            _handleWalletMessage(controller, msg, context),
      )
      ..addJavaScriptChannel(
        'N42ChatChannel',
        onMessageReceived: (msg) =>
            unawaited(_handleChatMessage(controller, msg)),
      );
  }

  /// 初始化注入脚本 —— 在页面加载完成后执行
  String get initScript =>
      '''
(function() {
  if (window.n42) return; // 防止重复注入

  var _canChatRead = ${_hasPermission(MiniAppPermission.chatRead)};
  var _canChatSend = ${_hasPermission(MiniAppPermission.chatSend)};

  // ─── Promise 响应追踪 ───
  var _pendingCallbacks = {};
  function _nextId() { return '_n42_' + Date.now() + '_' + Math.random().toString(36).slice(2); }

  function _makeWalletCall(method, params) {
    return new Promise(function(resolve, reject) {
      var id = _nextId();
      _pendingCallbacks[id] = {resolve: resolve, reject: reject};
      N42WalletChannel.postMessage(JSON.stringify({method: method, id: id, params: params || {}}));
    });
  }

  // ─── 接收 Native 回调 ───
  window._n42NativeCallback = function(id, success, data) {
    var cb = _pendingCallbacks[id];
    if (!cb) return;
    delete _pendingCallbacks[id];
    if (success) cb.resolve(data);
    else cb.reject(new Error(data));
  };

  // ─── Public API ───
  window.n42 = {
    version: '1.0',
    chainCount: 236,

    wallet: {
      getAddress: function() {
        return _makeWalletCall('getAddress');
      },
      getBalance: function(chainId) {
        return _makeWalletCall('getBalance', {chainId: chainId});
      },
      requestTransaction: function(params) {
        return _makeWalletCall('requestTransaction', params);
      },
    },

    chat: {
      getRoomId: function() {
        if (!_canChatRead) return null;
        return '${_escapeJsString(_roomId)}';
      },
      sendMessage: function(text) {
        if (!_canChatSend || typeof text !== 'string' || !text.trim()) return false;
        N42ChatChannel.postMessage(JSON.stringify({method: 'sendMessage', params: {text: text}}));
        return true;
      },
      close: function() {
        N42ChatChannel.postMessage(JSON.stringify({method: 'close'}));
        return true;
      },
    },

    lifecycle: {
      onPause: null,
      onResume: null,
      onDestroy: null,
    },
  };

  console.log('[N42 MiniApp Bridge] Initialized. Chains: 236+');
})();
''';

  // ─────────────────────────────────────────────────────────────────────────
  // Message Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleWalletMessage(
    WebViewController controller,
    JavaScriptMessage msg,
    BuildContext context,
  ) async {
    _BridgeMessage? message;
    try {
      message = _BridgeMessage.fromJson(msg.message);
      if (!await _isTrustedSource(controller)) {
        await _resolveCallback(
          controller,
          message.id,
          false,
          jsonEncode('Permission denied: untrusted origin'),
        );
        return;
      }

      switch (message.method) {
        case 'getAddress':
          if (!_hasPermission(MiniAppPermission.walletAddress)) {
            await _resolveCallback(
              controller,
              message.id,
              false,
              jsonEncode('Permission denied: walletAddress'),
            );
            return;
          }
          final address = _walletBridge.walletAddress ?? '';
          await _resolveCallback(
            controller,
            message.id,
            true,
            jsonEncode(address),
          );
          return;

        case 'getBalance':
          if (!_hasPermission(MiniAppPermission.walletBalance)) {
            await _resolveCallback(
              controller,
              message.id,
              false,
              jsonEncode('Permission denied: walletBalance'),
            );
            return;
          }
          try {
            final chainId = message.params?['chainId'] as String? ?? 'ETH';
            final balance = await _walletBridge.getBalance(chainId);
            await _resolveCallback(
              controller,
              message.id,
              true,
              jsonEncode(balance),
            );
          } catch (e) {
            debugLog('MiniAppBridge: getBalance error: $e');
            await _resolveCallback(
              controller,
              message.id,
              false,
              jsonEncode('Failed to get balance: $e'),
            );
          }
          return;

        case 'requestTransaction':
          if (!_hasPermission(MiniAppPermission.walletTransaction)) {
            await _resolveCallback(
              controller,
              message.id,
              false,
              jsonEncode('Permission denied: walletTransaction'),
            );
            return;
          }
          if (!context.mounted) {
            await _resolveCallback(
              controller,
              message.id,
              false,
              jsonEncode('Mini App is no longer active'),
            );
            return;
          }
          final confirmed = await _showTransactionConfirmDialog(
            context,
            message.params,
          );
          if (confirmed) {
            try {
              final toAddress = message.params?['to'] as String? ?? '';
              final amount = message.params?['amount'] as String? ?? '0';
              final token = message.params?['token'] as String? ?? 'ETH';
              final memo = message.params?['memo'] as String?;
              final result = await _walletBridge.requestTransfer(
                toAddress: toAddress,
                amount: amount,
                token: token,
                memo: memo,
              );
              if (result.success) {
                final txHash = result.transactionHash ?? '';
                await _resolveCallback(
                  controller,
                  message.id,
                  true,
                  jsonEncode(<String, String>{
                    'status': 'confirmed',
                    'txHash': txHash,
                  }),
                );
              } else {
                await _resolveCallback(
                  controller,
                  message.id,
                  false,
                  jsonEncode(result.errorMessage ?? 'Transaction failed'),
                );
              }
            } catch (e) {
              debugLog('MiniAppBridge: requestTransaction error: $e');
              await _resolveCallback(
                controller,
                message.id,
                false,
                jsonEncode('Transaction failed: $e'),
              );
            }
          } else {
            await _resolveCallback(
              controller,
              message.id,
              false,
              jsonEncode('User rejected transaction'),
            );
          }
          return;
        default:
          await _resolveCallback(
            controller,
            message.id,
            false,
            jsonEncode('Unsupported wallet method: ${message.method}'),
          );
          return;
      }
    } catch (e) {
      debugLog('MiniAppBridge: wallet message error: $e');
      await _resolveCallback(
        controller,
        message?.id,
        false,
        jsonEncode('Mini App bridge error: $e'),
      );
    }
  }

  Future<void> _handleChatMessage(
    WebViewController controller,
    JavaScriptMessage msg,
  ) async {
    try {
      if (!await _isTrustedSource(controller)) {
        debugLog('MiniAppBridge: rejected chat message from untrusted origin');
        return;
      }
      final action = parseMiniAppChatAction(
        msg.message,
        canSendMessage: _hasPermission(MiniAppPermission.chatSend),
      );
      switch (action.type) {
        case MiniAppChatActionType.sendMessage:
          onSendMessage?.call(action.text!);
          return;
        case MiniAppChatActionType.close:
          onClose?.call();
          return;
        case MiniAppChatActionType.ignore:
          return;
      }
    } catch (e) {
      debugLog('MiniAppBridge: chat message error: $e');
    }
  }

  Future<void> _resolveCallback(
    WebViewController controller,
    String? id,
    bool success,
    String dataJson,
  ) async {
    if (id == null) return;
    // Validate callback id: only allow safe alphanumeric + underscore ids
    // to prevent JS injection via crafted callback identifiers.
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(id)) {
      debugLog('MiniAppBridge: rejected callback id with unsafe characters');
      return;
    }
    try {
      await controller.runJavaScript(
        "window._n42NativeCallback('$id', $success, $dataJson);",
      );
    } catch (e) {
      debugLog('MiniAppBridge: callback resolution error: $e');
    }
  }

  /// Escape a string for safe embedding inside a JS single-quoted literal.
  /// Prevents XSS via roomId or other injected values.
  static String _escapeJsString(String s) {
    return s
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('</', r'<\/');
  }

  Future<bool> _isTrustedSource(WebViewController controller) async {
    try {
      final currentUrl = await controller.currentUrl();
      return isTrustedMiniAppNavigationUrl(
        appUrl: _app?.url,
        candidateUrl: currentUrl,
      );
    } catch (e) {
      debugLog('MiniAppBridge: failed to inspect current URL: $e');
      return false;
    }
  }

  Future<bool> _showTransactionConfirmDialog(
    BuildContext context,
    Map<String, dynamic>? params,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Confirm Transaction'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A Mini App is requesting to send a transaction on your behalf.',
              style: TextStyle(fontSize: 14),
            ),
            if (params != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  params.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Reject'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
