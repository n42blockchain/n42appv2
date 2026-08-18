import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vodozemac;
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:n42_chat/src/core/utils/io_helper.dart' as io_helper;
import 'package:n42_chat/src/n42_chat_config.dart';
import '../../../core/services/privacy_http_client.dart';
import '../../../core/utils/debug_log.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../local/preferences_datasource.dart';

/// Matrix客户端管理器
///
/// 单例模式管理Matrix Client实例，负责：
/// - 客户端初始化和配置
/// - 连接管理（连接、断开、重连）
/// - 同步状态管理
/// - 事件分发
class MatrixClientManager {
  MatrixClientManager._();

  static final MatrixClientManager _instance = MatrixClientManager._();
  static MatrixClientManager get instance => _instance;

  Client? _client;
  http.Client? _managedHttpClient;
  bool _isInitialized = false;
  bool _vodozemacInitialized = false;
  Completer<void>? _initCompleter;
  Duration _syncWaitTimeout = const Duration(seconds: 3);

  static final _heicHeifRegExp = RegExp(
    r'\.(heic|heif)$',
    caseSensitive: false,
  );

  /// 获取Matrix客户端实例
  Client? get client => _client;

  /// 获取已初始化的客户端实例；未初始化时抛 [StateError]。
  /// datasource 各 op 起始统一调用，避免散落的 `if (_client == null) throw ...`。
  Client requireClient([String? op]) {
    final c = _client;
    if (c == null) {
      throw StateError(
        op == null
            ? 'Matrix client not initialized'
            : 'Matrix client not initialized (op: $op)',
      );
    }
    return c;
  }

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 是否已登录
  bool get isLoggedIn => _client?.isLogged() ?? false;

  /// 当前用户ID
  String? get userId => _client?.userID;

  /// 当前用户显示名
  String? get displayName => _client?.userID?.localpart;

  /// 同步状态流
  Stream<SyncStatusUpdate>? get onSyncStatus => _client?.onSyncStatus.stream;

  /// 登录状态变化流
  Stream<LoginState>? get onLoginStateChanged =>
      _client?.onLoginStateChanged.stream;

  /// 房间更新流
  Stream<String>? get onRoomUpdate => _client?.onSync.stream.map(
    (sync) => sync.rooms?.join?.keys.firstOrNull ?? '',
  );

  // ============================================
  // 初始化
  // ============================================

  /// 初始化Matrix客户端
  ///
  /// [clientName] 客户端名称，用于设备识别
  /// [databasePath] 数据库存储路径，为空则使用默认路径
  /// [forceReinit] 强制重新初始化
  /// [config] N42ChatConfig，用于读取安全配置（如 shareE2eeKeysWithAllDevices）
  Future<void> initialize({
    String clientName = 'N42Chat',
    String? databasePath,
    bool forceReinit = false,
    N42ChatConfig? config,
    PreferencesDataSource? preferencesDataSource,
  }) async {
    if (_isInitialized && !forceReinit) {
      debugLog('MatrixClientManager: Already initialized');
      return;
    }

    // 如果强制重新初始化，先清理旧的客户端
    if (forceReinit && _client != null) {
      debugLog(
        'MatrixClientManager: Force reinitializing, disposing old client...',
      );
      // 若有进行中的 Completer，先令其以错误终止，避免等待者永久挂起
      if (_initCompleter != null && !_initCompleter!.isCompleted) {
        _initCompleter!.completeError(
          StateError('MatrixClientManager: Interrupted by forceReinit'),
        );
      }
      _initCompleter = null;
      try {
        await _client!.dispose();
      } catch (e) {
        debugLog('MatrixClientManager: Error disposing old client: $e');
      }
      _managedHttpClient?.close();
      _managedHttpClient = null;
      _client = null;
      _isInitialized = false;
    }

    // 防止并发初始化：第二次调用等待第一次完成
    if (_initCompleter != null) {
      debugLog(
        'MatrixClientManager: Already initializing, waiting for completion...',
      );
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      _syncWaitTimeout = config?.syncTimeout ?? const Duration(seconds: 3);

      // 三个独立 I/O 并行：vodozemac FFI init（~50-200ms）、数据库路径解析
      // （path_provider channel）、隐私配置读取（SharedPreferences）。
      // vodozemac 必须在 Client.init() 之前完成，但与 path 解析、prefs 读取
      // 完全无依赖。`null` 表示该步骤无 I/O，跳过 await 也省一次 microtask。
      final vodozemacFuture = _vodozemacInitialized ? null : vodozemac.init();
      final dbPathFuture = databasePath == null
          ? _getDefaultDatabasePath()
          : null;
      final privacySettingsFuture = preferencesDataSource
          ?.getPrivacySettingsModel();

      if (vodozemacFuture != null) {
        await vodozemacFuture;
        _vodozemacInitialized = true;
        debugLog('MatrixClientManager: vodozemac initialized');
      }
      final dbPath = databasePath ?? await dbPathFuture!;
      debugLog('MatrixClientManager: Using database path: $dbPath');

      // 确保数据库目录存在（仅在非 Web 平台）
      if (!kIsWeb && dbPath.isNotEmpty) {
        try {
          await io_helper.ensureDirectoryExists(dbPath);
          debugLog('MatrixClientManager: Created database directory');
        } catch (e) {
          debugLog('MatrixClientManager: Could not create directory: $e');
        }
      }

      // 使用 MatrixSdkDatabase（Matrix 6.0 推荐，基于 drift/sqlite）
      // 原生平台必须先打开 sqflite Database 再传入 MatrixSdkDatabase.init()
      debugLog('MatrixClientManager: Creating MatrixSdkDatabase...');
      DatabaseApi database;
      if (kIsWeb) {
        database = await MatrixSdkDatabase.init(clientName);
      } else {
        final sqfliteDb = await sqflite.openDatabase(
          p.join(dbPath, '$clientName.db'),
        );
        database = await MatrixSdkDatabase.init(
          clientName,
          database: sqfliteDb,
        );
      }

      // Default to cross-verified devices. Opting into all devices improves
      // compatibility but explicitly trusts unverified sessions.
      final shareKeysWith = (config?.shareE2eeKeysWithAllDevices ?? false)
          ? ShareKeysWith.all
          : ShareKeysWith.crossVerified;
      final syncFilterConfig = config?.syncFilter ?? const SyncFilterConfig();
      final syncFilter = Filter(
        room: RoomFilter(
          includeLeave: syncFilterConfig.includeLeaveRooms,
          state: StateFilter(lazyLoadMembers: syncFilterConfig.lazyLoadMembers),
          timeline: StateFilter(
            limit: syncFilterConfig.timelineLimit,
            lazyLoadMembers: syncFilterConfig.lazyLoadMembers,
          ),
          ephemeral: StateFilter(notTypes: ['m.receipt']),
        ),
      );
      final privacySettings =
          await privacySettingsFuture ?? const PrivacySettings();
      _swapManagedHttpClient(
        createPrivacyAwareHttpClient(settings: privacySettings),
      );

      // 创建客户端（端到端加密由 flutter_vodozemac 自动支持）
      _client = Client(
        clientName,
        database: database,
        httpClient: _managedHttpClient,
        supportedLoginTypes: {
          AuthenticationTypes.password,
          AuthenticationTypes.sso,
          AuthenticationTypes.token,
        },
        shareKeysWith: shareKeysWith,
        logLevel: kDebugMode ? Level.debug : Level.warning,
        importantStateEvents: {EventTypes.Encryption},
        syncFilter: syncFilter,
      );

      // 初始化客户端
      // waitForFirstSync: false  → 不阻塞网络同步（快速启动）
      // waitUntilLoadCompletedLoaded: true → 必须等待本地数据库加载完成
      //   确保之前缓存的房间/消息可用，否则 UI 会显示空列表
      debugLog('MatrixClientManager: Starting client init...');
      await _client!.init(
        waitForFirstSync: false,
        waitUntilLoadCompletedLoaded: true,
      );

      _isInitialized = true;
      debugLog('MatrixClientManager: Initialized successfully');
      debugLog(
        'MatrixClientManager: Logged in: $isLoggedIn, rooms: ${_client!.rooms.length}',
      );
      _initCompleter!.complete();
    } catch (e, stack) {
      debugLog('MatrixClientManager: Initialize failed: $e');
      debugLog('Stack: $stack');
      // 清理失败的初始化
      if (_client != null) {
        try {
          await _client!.dispose();
        } catch (e) {
          debugLog('Error: $e');
        }
        _client = null;
      }
      _managedHttpClient?.close();
      _managedHttpClient = null;
      _isInitialized = false;
      _initCompleter!.completeError(e, stack);
      rethrow;
    } finally {
      _initCompleter = null;
    }
  }

  /// 动态更新网络隐私设置（代理/Tor/IP 保护）
  Future<void> updateNetworkPrivacy(PrivacySettings settings) async {
    final nextClient = createPrivacyAwareHttpClient(settings: settings);
    _swapManagedHttpClient(nextClient, assignToMatrixClient: true);
    debugLog(
      'MatrixClientManager: Network privacy updated '
      '(proxy=${settings.proxyEnabled}, tor=${settings.useTor}, '
      'ipProtection=${settings.protectIpAddress})',
    );
  }

  /// 获取默认数据库路径
  Future<String> _getDefaultDatabasePath() async {
    if (kIsWeb) {
      // Web 平台使用空路径，Hive 会使用 IndexedDB
      return '';
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      // 使用子目录来存储数据库
      final dbDir = p.join(dir.path, 'n42_chat_db');
      return dbDir;
    } catch (e) {
      debugLog('MatrixClientManager: Failed to get documents directory: $e');
      // 尝试使用应用支持目录
      try {
        final supportDir = await getApplicationSupportDirectory();
        final dbDir = p.join(supportDir.path, 'n42_chat_db');
        return dbDir;
      } catch (e2) {
        debugLog('MatrixClientManager: Failed to get support directory: $e2');
        return '';
      }
    }
  }

  // ============================================
  // 认证
  // ============================================

  /// 使用用户名或邮箱+密码登录
  ///
  /// [homeserver] Matrix服务器地址
  /// [username] 用户名或邮箱地址
  /// [password] 密码
  /// [deviceName] 设备名称
  Future<LoginResponse> login({
    required String homeserver,
    required String username,
    required String password,
    String? deviceName,
  }) async {
    _ensureInitialized();

    try {
      // 设置homeserver（6.0 返回 record tuple，这里只需确认连接成功）
      final homeserverUri = Uri.parse(homeserver);
      final (_, _, _, _) = await _client!.checkHomeserver(homeserverUri);

      // 检测是否为邮箱格式（包含 @ 且 @ 后有域名部分）
      final isEmail =
          username.contains('@') &&
          username.indexOf('@') > 0 &&
          username.indexOf('@') < username.length - 1 &&
          username.substring(username.indexOf('@') + 1).contains('.');

      if (isEmail) {
        debugLog('MatrixClientManager: Using email identifier for login');
        // 尝试顺序：
        // 1. 新式 m.id.thirdparty identifier（标准 Matrix 邮箱登录）
        // 2. legacy address/medium 顶层字段（旧版 Matrix 邮箱登录）
        // 3. 邮箱 @ 前的本地部分作为用户名（服务器不支持邮箱登录时的兜底）
        MatrixException? lastEmailError;
        try {
          final response = await _client!.login(
            LoginType.mLoginPassword,
            identifier: AuthenticationThirdPartyIdentifier(
              medium: 'email',
              address: username,
            ),
            password: password,
            initialDeviceDisplayName: deviceName ?? 'N42Chat',
          );
          debugLog(
            'MatrixClientManager: Login successful - ${response.userId}',
          );
          return response;
        } on MatrixException catch (e) {
          if (e.errcode != 'M_UNKNOWN') rethrow;
          lastEmailError = e;
          debugLog(
            'MatrixClientManager: Email identifier rejected (M_UNKNOWN), '
            'retrying with legacy address/medium fields',
          );
        }

        try {
          // ignore: deprecated_member_use
          final response = await _client!.login(
            LoginType.mLoginPassword,
            // ignore: deprecated_member_use
            address: username,
            // ignore: deprecated_member_use
            medium: 'email',
            password: password,
            initialDeviceDisplayName: deviceName ?? 'N42Chat',
          );
          debugLog(
            'MatrixClientManager: Login successful (legacy) - ${response.userId}',
          );
          return response;
        } on MatrixException catch (e) {
          if (e.errcode != 'M_UNKNOWN') rethrow;
          lastEmailError = e;
          debugLog(
            'MatrixClientManager: Legacy email fields also rejected (M_UNKNOWN), '
            'retrying with email local-part as username',
          );
        }

        // 服务器不支持邮箱登录（如 N42 Conduit），用 @ 前的本地部分作为用户名兜底
        final localPart = username.substring(0, username.indexOf('@'));
        if (localPart.isNotEmpty) {
          try {
            final response = await _client!.login(
              LoginType.mLoginPassword,
              identifier: AuthenticationUserIdentifier(user: localPart),
              password: password,
              initialDeviceDisplayName: deviceName ?? 'N42Chat',
            );
            debugLog(
              'MatrixClientManager: Login successful (local-part fallback) - ${response.userId}',
            );
            return response;
          } on MatrixException catch (_) {
            // 三次全部失败，抛出原始邮箱错误，保留更清晰的提示信息
            throw lastEmailError;
          }
        }
        throw lastEmailError;
      } else {
        debugLog('MatrixClientManager: Using username identifier for login');
        final response = await _client!.login(
          LoginType.mLoginPassword,
          identifier: AuthenticationUserIdentifier(user: username),
          password: password,
          initialDeviceDisplayName: deviceName ?? 'N42Chat',
        );
        debugLog('MatrixClientManager: Login successful - ${response.userId}');
        return response;
      }
    } catch (e) {
      debugLog('MatrixClientManager: Login failed: $e');
      rethrow;
    }
  }

  /// 使用Token登录（恢复会话）
  ///
  /// [homeserver] Matrix服务器地址
  /// [accessToken] 访问令牌
  /// [userId] 用户ID
  /// [deviceId] 设备ID
  Future<void> loginWithToken({
    required String homeserver,
    required String accessToken,
    required String userId,
    required String deviceId,
  }) async {
    _ensureInitialized();

    // 如果 SDK 已使用相同用户登录（从自身 SQLite DB 恢复），跳过二次 init
    // 二次 init 会短暂重置状态，造成不必要的开销和潜在竞态
    if (isLoggedIn && this.userId == userId) {
      debugLog(
        'MatrixClientManager: Already logged in as $userId, skipping re-init',
      );
      return;
    }

    try {
      final homeserverUri = Uri.parse(homeserver);
      // 不调用 checkHomeserver — 恢复已知会话时跳过此额外网络往返
      // 使用token恢复登录
      // 显式设置 waitForFirstSync: false，由后续 startSync() 统一处理同步
      await _client!.init(
        newToken: accessToken,
        newUserID: userId,
        newDeviceID: deviceId,
        newDeviceName: 'N42Chat',
        newHomeserver: homeserverUri,
        waitForFirstSync: false,
      );

      debugLog('MatrixClientManager: Token login successful - $userId');
    } catch (e) {
      debugLog('MatrixClientManager: Token login failed: $e');
      rethrow;
    }
  }

  /// 使用 Matrix login token 登录（SSO/OIDC 回调）
  Future<LoginResponse> loginWithLoginToken({
    required String homeserver,
    required String loginToken,
    String? deviceName,
  }) async {
    _ensureInitialized();

    try {
      final homeserverUri = Uri.parse(homeserver);
      await _client!.checkHomeserver(homeserverUri);

      final response = await _client!.login(
        LoginType.mLoginToken,
        token: loginToken,
        initialDeviceDisplayName: deviceName ?? 'N42Chat',
      );

      debugLog(
        'MatrixClientManager: Login token login successful - ${response.userId}',
      );
      return response;
    } catch (e) {
      debugLog('MatrixClientManager: Login token login failed: $e');
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    if (_client == null) return;

    try {
      await _client!.logout();
      debugLog('MatrixClientManager: Logout successful');
    } catch (e) {
      debugLog('MatrixClientManager: Logout failed: $e');
      // 即使登出失败也清理本地状态
    }
  }

  // ============================================
  // 同步
  // ============================================

  /// 开始同步
  ///
  /// 启动后台同步循环，并等待首次同步完成以确保房间数据是最新的。
  /// [timeout] 等待首次同步的超时时间；未传入时使用配置值
  /// [fullState] 是否获取完整状态
  Future<void> startSync({Duration? timeout, bool fullState = false}) async {
    _ensureInitialized();
    _ensureLoggedIn();
    final effectiveTimeout = timeout ?? _syncWaitTimeout;

    try {
      // 启动后台同步循环
      _client!.backgroundSync = true;

      // 等待首次同步完成，确保从服务器获取最新的房间和消息数据
      // 如果本地数据库已有缓存（prevBatch != null），同步会增量获取
      // 如果是全新登录（prevBatch == null），同步会获取完整初始数据
      debugLog(
        'MatrixClientManager: Sync enabled, waiting for first sync response...',
      );
      try {
        await _client!.onSync.stream.first.timeout(effectiveTimeout);
        debugLog(
          'MatrixClientManager: First sync completed, rooms: ${_client!.rooms.length}',
        );
      } on TimeoutException {
        debugLog(
          'MatrixClientManager: First sync timed out after $effectiveTimeout, '
          'continuing with ${_client!.rooms.length} cached rooms',
        );
      }
    } catch (e) {
      debugLog('MatrixClientManager: Start sync failed: $e');
      rethrow;
    }
  }

  /// 停止同步
  void stopSync() {
    if (_client != null) {
      _client!.backgroundSync = false;
      debugLog('MatrixClientManager: Sync stopped');
    }
  }

  // ============================================
  // 房间操作
  // ============================================

  /// 获取所有房间
  List<Room> get rooms => _client?.rooms ?? [];

  /// 获取房间
  Room? getRoom(String roomId) => _client?.getRoomById(roomId);

  /// 获取私聊房间（通过用户ID）
  Room? getDirectChat(String userId) {
    final roomId = _client?.getDirectChatFromUserId(userId);
    if (roomId == null) return null;
    return _client?.getRoomById(roomId);
  }

  /// 创建私聊房间
  Future<String> createDirectChat(
    String userId, {
    bool encrypted = true,
  }) async {
    _ensureInitialized();
    _ensureLoggedIn();

    final roomId = await _client!.startDirectChat(
      userId,
      enableEncryption: encrypted,
    );
    return roomId;
  }

  /// 创建群聊房间
  Future<String> createGroup({
    required String name,
    List<String> inviteUserIds = const [],
    String? topic,
    bool encrypted = true,
  }) async {
    _ensureInitialized();
    _ensureLoggedIn();

    final roomId = await _client!.createRoom(
      name: name,
      invite: inviteUserIds,
      topic: topic,
      preset: CreateRoomPreset.privateChat,
      initialState: encrypted
          ? [
              StateEvent(
                type: EventTypes.Encryption,
                stateKey: '',
                content: {'algorithm': 'm.megolm.v1.aes-sha2'},
              ),
            ]
          : null,
    );
    return roomId;
  }

  // ============================================
  // 用户操作
  // ============================================

  /// 搜索用户
  Future<SearchUserDirectoryResponse> searchUsers(
    String term, {
    int limit = 10,
  }) async {
    _ensureInitialized();
    _ensureLoggedIn();

    return await _client!.searchUserDirectory(term, limit: limit);
  }

  /// 获取用户资料
  Future<Profile> getUserProfile(String userId) async {
    _ensureInitialized();

    return await _client!.getProfileFromUserId(userId);
  }

  /// 更新显示名称
  Future<void> setDisplayName(String displayName) async {
    _ensureInitialized();
    _ensureLoggedIn();

    await _client!.setProfileField(_client!.userID!, 'displayname', {
      'displayname': displayName,
    });
  }

  /// 更新头像
  ///
  /// Matrix 头像上传流程:
  /// 1. 先上传文件到 Matrix 服务器获取 mxc:// URI
  /// 2. 然后调用 setAvatar 设置用户头像
  Future<void> setAvatar(Uint8List avatarBytes, String filename) async {
    debugLog('=== MatrixClientManager.setAvatar start ===');
    debugLog('filename: $filename');
    debugLog('avatarBytes.length: ${avatarBytes.length}');

    _ensureInitialized();
    _ensureLoggedIn();

    // 检查文件是否为空
    if (avatarBytes.isEmpty) {
      debugLog('ERROR: Avatar bytes is empty');
      throw Exception('头像数据为空');
    }

    // 检查文件大小（限制 10MB）
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (avatarBytes.length > maxSize) {
      debugLog('ERROR: Avatar too large: ${avatarBytes.length} bytes');
      throw Exception('头像文件过大，最大支持 10MB');
    }

    // 处理文件名 - 确保有扩展名
    String actualFilename = filename;
    if (!actualFilename.contains('.')) {
      actualFilename = '$actualFilename.jpg';
    }

    // 根据文件名确定 MIME 类型
    String mimeType = 'image/jpeg';
    final lowerFilename = actualFilename.toLowerCase();
    if (lowerFilename.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (lowerFilename.endsWith('.gif')) {
      mimeType = 'image/gif';
    } else if (lowerFilename.endsWith('.webp')) {
      mimeType = 'image/webp';
    } else if (lowerFilename.endsWith('.heic') ||
        lowerFilename.endsWith('.heif')) {
      // HEIC/HEIF 需要转换为 JPEG，因为 Matrix 服务器可能不支持
      mimeType = 'image/jpeg';
      actualFilename = actualFilename.replaceAll(_heicHeifRegExp, '.jpg');
    }

    debugLog('Final filename: $actualFilename');
    debugLog('Final mimeType: $mimeType');
    debugLog('User ID: ${_client!.userID}');

    try {
      // 直接使用 SDK 的 uploadContent 方法（最可靠）
      debugLog('Uploading avatar with SDK uploadContent...');
      Uri? mxcUri;

      try {
        mxcUri = await _client!.uploadContent(
          avatarBytes,
          filename: actualFilename,
          contentType: mimeType,
        );
        debugLog('SDK upload successful: $mxcUri');
      } catch (sdkError) {
        debugLog('SDK uploadContent failed: $sdkError');
        // 尝试手动上传
        debugLog('Trying manual upload...');
        mxcUri = await _uploadContentAuthenticated(
          avatarBytes,
          filename: actualFilename,
          contentType: mimeType,
        );
      }

      if (mxcUri == null) {
        throw Exception('上传头像失败');
      }

      debugLog('Avatar uploaded: $mxcUri');

      // 设置头像 URL
      debugLog('Setting avatar URL...');
      await _client!.setProfileField(_client!.userID!, 'avatar_url', {
        'avatar_url': mxcUri.toString(),
      });
      debugLog('Avatar URL set successfully');

      // 验证头像是否设置成功
      final profile = await _client!.getProfileFromUserId(_client!.userID!);
      debugLog('New avatar URL: ${profile.avatarUrl}');

      debugLog('=== setAvatar completed successfully ===');
    } catch (e, stackTrace) {
      debugLog('=== setAvatar ERROR: $e ===');
      debugLog('Stack: $stackTrace');
      rethrow;
    }
  }

  /// 检查服务器是否支持认证媒体上传
  Future<bool> _supportsAuthenticatedMedia() async {
    try {
      final versionsResponse = await _client!.getVersions();
      // 检查 Matrix 版本是否 >= v1.11 (支持认证媒体)
      final supportsV111 = versionsResponse.versions.any(
        (v) => _isVersionGreaterThanOrEqualTo(v, 'v1.11'),
      );
      // 或者检查 unstable feature
      final hasUnstableFeature =
          versionsResponse.unstableFeatures?['org.matrix.msc3916.stable'] ==
          true;

      debugLog(
        'MatrixClientManager: supportsV111=$supportsV111, hasUnstableFeature=$hasUnstableFeature',
      );
      return supportsV111 || hasUnstableFeature;
    } catch (e) {
      debugLog(
        'MatrixClientManager: Error checking authenticated media support: $e',
      );
      return false;
    }
  }

  bool _isVersionGreaterThanOrEqualTo(String version, String target) {
    try {
      final vParts = version.replaceAll('v', '').split('.');
      final tParts = target.replaceAll('v', '').split('.');

      final vMajor = int.tryParse(vParts[0]) ?? 0;
      final vMinor = vParts.length > 1 ? (int.tryParse(vParts[1]) ?? 0) : 0;
      final tMajor = int.tryParse(tParts[0]) ?? 0;
      final tMinor = tParts.length > 1 ? (int.tryParse(tParts[1]) ?? 0) : 0;

      if (vMajor > tMajor) return true;
      if (vMajor < tMajor) return false;
      return vMinor >= tMinor;
    } catch (e) {
      return false;
    }
  }

  /// 使用认证端点上传文件
  Future<Uri?> _uploadContentAuthenticated(
    Uint8List content, {
    String? filename,
    String? contentType,
  }) async {
    if (_client == null) {
      throw Exception('Matrix client not initialized');
    }
    if (_client!.accessToken == null) {
      throw Exception('No access token available');
    }
    if (_client!.homeserver == null) {
      throw Exception('No homeserver configured');
    }

    final supportsAuth = await _supportsAuthenticatedMedia();
    debugLog('MatrixClientManager: supportsAuthenticatedMedia=$supportsAuth');

    // 根据服务器能力选择端点
    final path = supportsAuth
        ? '_matrix/client/v1/media/upload' // 认证媒体端点 (MSC3916)
        : '_matrix/media/v3/upload'; // 传统端点

    final uri = Uri.parse('${_client!.homeserver}/$path').replace(
      queryParameters: filename != null ? {'filename': filename} : null,
    );

    debugLog('MatrixClientManager: Uploading to: $uri');
    debugLog('MatrixClientManager: Content size: ${content.length} bytes');
    debugLog('MatrixClientManager: Content type: $contentType');

    final request = http.Request('POST', uri);
    request.headers['Authorization'] = 'Bearer ${_client!.accessToken}';
    if (contentType != null) {
      request.headers['Content-Type'] = contentType;
    }
    request.bodyBytes = content;

    final httpClient = http.Client();
    try {
      final streamedResponse = await httpClient
          .send(request)
          .timeout(
            const Duration(minutes: 2),
            onTimeout: () =>
                throw TimeoutException('HTTP upload timed out after 2 minutes'),
          );
      final response = await http.Response.fromStream(streamedResponse);

      debugLog(
        'MatrixClientManager: Upload response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final contentUri = json['content_uri'] as String?;
        if (contentUri != null) {
          debugLog('MatrixClientManager: Upload successful: $contentUri');
          return Uri.parse(contentUri);
        }
      }

      // 上传失败，打印错误信息
      debugLog('MatrixClientManager: Upload failed: ${response.body}');

      // 如果使用认证端点失败，尝试传统端点
      if (supportsAuth && response.statusCode == 403) {
        debugLog(
          'MatrixClientManager: Auth endpoint failed, trying legacy endpoint...',
        );
        return _uploadContentLegacy(
          content,
          filename: filename,
          contentType: contentType,
        );
      }

      // 解析错误信息
      try {
        final errorJson = jsonDecode(response.body);
        final errcode = errorJson['errcode'] as String?;
        final error = errorJson['error'] as String?;
        throw Exception('Upload failed: $errcode - $error');
      } catch (e) {
        debugLog('Error: $e');
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugLog('MatrixClientManager: Upload error: $e');
      rethrow;
    } finally {
      httpClient.close();
    }
  }

  /// 使用传统端点上传文件（作为 fallback）
  Future<Uri?> _uploadContentLegacy(
    Uint8List content, {
    String? filename,
    String? contentType,
  }) async {
    if (_client == null) return null;

    final uri = Uri.parse('${_client!.homeserver}/_matrix/media/v3/upload')
        .replace(
          queryParameters: filename != null ? {'filename': filename} : null,
        );

    debugLog('MatrixClientManager: Uploading (legacy) to: $uri');

    final request = http.Request('POST', uri);
    request.headers['Authorization'] = 'Bearer ${_client!.accessToken}';
    if (contentType != null) {
      request.headers['Content-Type'] = contentType;
    }
    request.bodyBytes = content;

    final httpClient2 = http.Client();
    final http.Response response;
    try {
      final streamedResponse = await httpClient2
          .send(request)
          .timeout(
            const Duration(minutes: 2),
            onTimeout: () =>
                throw TimeoutException('HTTP upload timed out after 2 minutes'),
          );
      response = await http.Response.fromStream(streamedResponse);
    } finally {
      httpClient2.close();
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final contentUri = json['content_uri'] as String?;
      if (contentUri != null) {
        return Uri.parse(contentUri);
      }
    }

    debugLog('MatrixClientManager: Legacy upload failed: ${response.body}');
    return null;
  }

  // ============================================
  // 资源管理
  // ============================================

  /// 释放资源
  Future<void> dispose() async {
    stopSync();

    if (_client != null) {
      await _client!.dispose();
      _client = null;
    }
    _managedHttpClient?.close();
    _managedHttpClient = null;

    _isInitialized = false;
    debugLog('MatrixClientManager: Disposed');
  }

  // ============================================
  // 辅助方法
  // ============================================

  void _ensureInitialized() {
    if (!_isInitialized || _client == null) {
      throw StateError(
        'MatrixClientManager has not been initialized. '
        'Call initialize() first.',
      );
    }
  }

  void _ensureLoggedIn() {
    if (!isLoggedIn) {
      throw StateError('Not logged in. Call login() first.');
    }
  }

  void _swapManagedHttpClient(
    http.Client nextClient, {
    bool assignToMatrixClient = false,
  }) {
    final previousClient = _managedHttpClient;
    _managedHttpClient = nextClient;
    if (assignToMatrixClient && _client != null) {
      _client!.httpClient = FixedTimeoutHttpClient(
        nextClient,
        const Duration(seconds: 35),
      );
    }
    previousClient?.close();
  }
}
