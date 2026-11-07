import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:n42_chat/n42_chat.dart';
// IAuthRepository 未从 n42_chat 公共入口导出，经实现导入访问。
// ignore: implementation_imports
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';

/// 直播客户端使用的 Matrix homeserver。
const String liveHomeserver = 'https://m.si46.world';

// 单飞（single-flight）守护：视频与弹幕会并发触发初始化/登录，
// 必须共享同一个进行中的 Future，否则会重复匿名注册、产生多个账户/身份。
Future<void>? _readyFuture;
Future<void>? _loginFuture;
IAuthRepository? _loginAuth;

/// 确保 n42_chat 已初始化（弹幕 + LiveKit 配置发现来源）。
///
/// 直播间为公开房，关闭 E2E 加密以简化匿名观众接入；MVP 暂不接推送。
/// 并发调用共享同一进行中的 Future；失败后允许下次重试。
Future<void> ensureLiveChatReady() {
  final existing = _readyFuture;
  if (existing != null) return existing;
  if (N42Chat.isInitialized) return Future<void>.value();
  final f = N42Chat.initialize(
    N42ChatConfig(
      defaultHomeserver: liveHomeserver,
      enableEncryption: false,
      enablePushNotifications: false,
    ),
  );
  _readyFuture = f;
  unawaited(
    f.then(
      (_) {
        if (identical(_readyFuture, f)) _readyFuture = null;
      },
      onError: (Object _, StackTrace _) {
        if (identical(_readyFuture, f)) _readyFuture = null;
      },
    ),
  );
  return f;
}

/// 确保已登录 Matrix。无钱包账户的观众以匿名身份注册登录
/// （n42_chat 无原生游客只读，任何读写都需 Matrix uid）。
///
/// 单飞：并发调用只触发一次匿名注册，避免重复建号。
Future<void> ensureAnonymousLogin() {
  final auth = GetIt.instance<IAuthRepository>();
  final existing = _loginFuture;
  if (existing != null && identical(_loginAuth, auth)) return existing;
  final f = _doAnonymousLogin(auth);
  _loginAuth = auth;
  _loginFuture = f;
  void clear() {
    if (!identical(_loginFuture, f)) return;
    _loginFuture = null;
    _loginAuth = null;
  }

  unawaited(
    f.then((_) => clear(), onError: (Object _, StackTrace _) => clear()),
  );
  return f;
}

Future<void> _doAnonymousLogin(IAuthRepository auth) async {
  if (auth.isLoggedIn) return;
  final random = Random.secure();
  final pw =
      'live_${base64UrlEncode(List<int>.generate(32, (_) => random.nextInt(256)))}';
  final res = await auth.registerAnonymously(
    homeserver: liveHomeserver,
    password: pw,
  );
  if (!res.success) {
    throw StateError('匿名登录失败: ${res.errorMessage ?? 'unknown'}');
  }
}
