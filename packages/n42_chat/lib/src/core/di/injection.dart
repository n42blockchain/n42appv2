import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/giphy_service.dart';
import '../services/tenor_service.dart';
import '../services/gif_service.dart';
import '../services/reminder_service.dart';
import '../services/subscription_service.dart';
import '../services/fiat_ramp_service.dart';
import '../services/live_caption_service.dart';
import '../services/system_integration_service.dart';
import '../services/local_llm_service.dart';
import '../services/ai_provider_router.dart';
import '../services/ai_sticker_service.dart';
import '../encryption/mls_protocol.dart';
import '../encryption/mls_manager.dart';
import '../services/remark_service.dart';
import '../services/mymemory_translation_service.dart';
import '../services/translation_service.dart';
import '../../data/datasources/local/preferences_datasource.dart';
import '../../data/datasources/local/secure_storage_datasource.dart';
import '../../data/datasources/matrix/matrix_auth_datasource.dart';
import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../../data/datasources/matrix/matrix_contact_datasource.dart';
import '../../data/datasources/matrix/matrix_group_datasource.dart';
import '../../data/datasources/matrix/matrix_message_datasource.dart';
import '../../data/datasources/matrix/matrix_room_datasource.dart';
import '../../data/datasources/matrix/matrix_reaction_datasource.dart';
import '../../data/datasources/matrix/matrix_search_datasource.dart';
import '../../data/datasources/matrix/matrix_moment_datasource.dart';
import '../../data/datasources/matrix/matrix_sticker_datasource.dart';
import '../../data/datasources/matrix/matrix_story_datasource.dart';
import '../../presentation/pages/game/services/game_score_service.dart';
import '../services/chat_backup_service.dart';
import '../services/data_tier_service.dart';
import '../services/archive_integrity_service.dart';
import '../services/archive_search_service.dart';
import '../services/message_archive_service.dart';
import '../services/download_service.dart';
import '../services/auto_download_policy_service.dart';
import '../services/bot_webhook_service.dart';
import '../services/media_lifecycle_service.dart';
import '../services/storage_cleanup_service.dart';
import '../services/storage_monitor_service.dart';
import '../services/sync_optimization_service.dart';
import '../services/url_preview_service.dart';
import '../services/storage_manager_service.dart';
import '../services/speech_to_text_service.dart';
import '../services/voice_service.dart';
import '../../data/datasources/local/archive_database.dart';
import '../../data/datasources/local/media_metadata_database.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/moment_repository_impl.dart';
import '../../data/repositories/sticker_repository_impl.dart';
import '../../data/repositories/story_repository_impl.dart';
import '../../data/repositories/contact_repository_impl.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../data/repositories/message_action_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/repositories/message_action_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/repositories/moment_repository.dart';
import '../../domain/repositories/sticker_repository.dart';
import '../../domain/repositories/story_repository.dart';
import '../../integration/api_hub_bridge.dart';
import '../../integration/wallet_bridge.dart';
import '../../n42_chat_config.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/chat/chat_bloc.dart';
import '../../presentation/blocs/contact/contact_bloc.dart';
import '../../presentation/blocs/conversation/conversation_bloc.dart';
import '../../presentation/blocs/group/group_bloc.dart';
import '../../presentation/blocs/message_action/message_action_bloc.dart';
import '../../presentation/blocs/search/search_bloc.dart';
import '../../presentation/blocs/transfer/transfer_bloc.dart';
import '../../presentation/blocs/moment/moment_bloc.dart';
import '../../presentation/blocs/story/story_bloc.dart';
import '../../presentation/blocs/thread/thread_bloc.dart';
import '../../presentation/blocs/live_location/live_location_bloc.dart';
import '../../presentation/blocs/voice_room/voice_room_bloc.dart';
import '../../data/datasources/matrix/matrix_voice_room_datasource.dart';
import '../services/ai_service.dart';
import '../services/username_service.dart';
import '../services/ens_cache_service.dart';
import '../../data/datasources/ai_datasource.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../data/repositories/voice_room_repository_impl.dart';
import '../../data/datasources/matrix/matrix_space_datasource.dart';
import '../../data/repositories/space_repository_impl.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/voice_room_repository.dart';
import '../../domain/repositories/space_repository.dart';
import '../../presentation/blocs/ai_assistant/ai_assistant_bloc.dart';
import '../../presentation/blocs/chat_folder/chat_folder_bloc.dart';
import '../../presentation/blocs/space/space_bloc.dart';
import '../../services/voip/voice_room_service.dart';
import '../../data/datasources/push_protocol/push_protocol_datasource.dart';
import '../../data/repositories/on_chain_notification_repository_impl.dart';
import '../../domain/repositories/on_chain_notification_repository.dart';
import '../../presentation/blocs/on_chain_notification/on_chain_notification_bloc.dart';
import '../services/on_chain_notification_service.dart';
import '../services/in_app_notification_service.dart';
import '../services/red_packet_service.dart';
import '../../data/datasources/local/local_red_packet_service.dart';

// P2.1 Protocol Abstraction
import '../../domain/protocols/messaging_protocol.dart';
import '../../data/protocols/matrix_protocol.dart';
import '../../data/protocols/protocol_registry.dart';

// P2.2 Governance
import '../../data/datasources/governance/snapshot_graphql_datasource.dart';
import '../../data/datasources/governance/snapshot_hub_datasource.dart';
import '../../data/repositories/governance_repository_impl.dart';
import '../../domain/repositories/governance_repository.dart';
import '../../presentation/blocs/governance/governance_bloc.dart';

// P2.3 Social Graph
import '../../data/datasources/social/debank_datasource.dart';
import '../../data/datasources/social/alchemy_social_datasource.dart';
import '../../data/datasources/social/on_chain_identity_datasource.dart';
import '../../data/repositories/social_graph_repository_impl.dart';
import '../../domain/repositories/social_graph_repository.dart';
import '../services/social_graph_service.dart';
import '../../presentation/blocs/social/social_graph_bloc.dart';

// P2.4 Points Economy
import '../../data/datasources/points/points_api_datasource.dart';
import '../../data/repositories/points_repository_impl.dart';
import '../../domain/repositories/points_repository.dart';
import '../services/points_tracking_service.dart';
import '../../presentation/blocs/points/points_bloc.dart';
import '../utils/debug_log.dart';

/// 全局GetIt实例
final GetIt getIt = GetIt.instance;

/// 配置依赖注入
///
/// 在N42Chat.initialize()中调用
Future<void> configureDependencies(
  N42ChatConfig config, {
  IWalletBridge? walletBridge,
}) async {
  // 注册配置
  getIt.registerSingleton<N42ChatConfig>(config);

  // 注册钱包桥接
  getIt.registerSingleton<IWalletBridge>(
    walletBridge ?? config.walletBridge ?? NoOpWalletBridge(),
  );

  // 注册 API Hub 桥接
  getIt.registerSingleton<IApiHubBridge>(
    config.apiHubBridge ?? MockApiHubBridge(),
  );

  // 注册数据源
  await _registerDataSources();

  // 注册服务
  await _registerServices(config);

  // 注册仓库
  _registerRepositories();

  // 注册用例
  _registerUseCases();

  // 注册BLoC
  _registerBlocs();

  // 等待所有异步单例初始化完成（如 MediaMetadataDatabase）
  await getIt.allReady();

  // 初始化备注名服务
  await _initializeRemarkService();
}

/// 初始化备注名服务
Future<void> _initializeRemarkService() async {
  try {
    final remarkService = RemarkService.instance;
    await remarkService.initialize();
    debugLog('RemarkService initialized successfully');
  } catch (e) {
    debugLog('Failed to initialize RemarkService: $e');
  }
}

/// 注册服务
Future<void> _registerServices(N42ChatConfig config) async {
  // Matrix客户端管理器
  final clientManager = MatrixClientManager.instance;

  // 尝试初始化 Matrix 客户端（包括 Hive 数据库）
  // 如果失败，允许后续在登录/注册时再次尝试
  if (!clientManager.isInitialized) {
    try {
      await clientManager.initialize(
        config: config,
        preferencesDataSource: getIt<PreferencesDataSource>(),
      );
    } catch (e) {
      // 初始化失败时记录错误，但不阻塞依赖注入
      // 后续在登录/注册时会再次尝试初始化
      debugLog('MatrixClientManager: Initial initialization failed: $e');
      debugLog('MatrixClientManager: Will retry on login/register');
    }
  }

  getIt.registerLazySingleton<MatrixClientManager>(
    () => clientManager,
    dispose: (manager) => manager.dispose(),
  );

  // 语音服务（生命周期由 DI 管理）
  final voiceService = VoiceService();
  await voiceService.initialize();
  getIt.registerSingleton<VoiceService>(
    voiceService,
    dispose: (service) => service.dispose(),
  );

  final speechService = SpeechToTextService()..resetConfiguration();
  final hasGoogleSpeechKey =
      config.googleSpeechApiKey != null &&
      config.googleSpeechApiKey!.isNotEmpty;
  final hasAzureSpeechKey =
      config.azureSpeechApiKey != null && config.azureSpeechApiKey!.isNotEmpty;
  if (hasGoogleSpeechKey) {
    speechService.configureGoogle(config.googleSpeechApiKey!);
  } else if (hasAzureSpeechKey) {
    speechService.configureAzure(
      config.azureSpeechApiKey!,
      config.azureSpeechRegion,
    );
  } else if (config.speechUseProxyEndpoint) {
    if (config.speechGoogleBaseUrl != null &&
        config.speechGoogleBaseUrl!.isNotEmpty) {
      speechService.configureGoogleProxy(
        baseUrl: config.speechGoogleBaseUrl!,
        authToken: config.proxyAuthToken,
      );
    } else if (config.speechAzureBaseUrl != null &&
        config.speechAzureBaseUrl!.isNotEmpty) {
      speechService.configureAzureProxy(
        baseUrl: config.speechAzureBaseUrl!,
        authToken: config.proxyAuthToken,
      );
    }
  }

  if (!getIt.isRegistered<SpeechToTextService>()) {
    getIt.registerSingleton<SpeechToTextService>(speechService);
  }

  // 实时字幕服务（复用 STT + Voice；音频源可插拔——通话音频管道/麦克风喂 chunk）
  getIt.registerLazySingleton<LiveCaptionService>(
    () => LiveCaptionService(
      getIt<SpeechToTextService>(),
      getIt<VoiceService>(),
    ),
    dispose: (svc) => svc.dispose(),
  );

  // 系统级集成（MethodChannel 桥；原生未实现时优雅 no-op）
  getIt.registerLazySingleton<SystemIntegrationService>(
    () => SystemIntegrationService(),
  );

  // 端侧推理（Dart 桥+服务；原生未接入时 unavailable）
  getIt.registerLazySingleton<LocalLlmBridge>(() => LocalLlmBridge());
  getIt.registerLazySingleton<LocalLlmService>(
    () => LocalLlmService(getIt<LocalLlmBridge>()),
    dispose: (s) => s.dispose(),
  );
  // AI 云↔端路由（端侧就绪走本地，否则云端；端侧失败回退云端）
  getIt.registerLazySingleton<AiProviderRouter>(
    () => AiProviderRouter(
      cloud: getIt.isRegistered<AiService>() ? getIt<AiService>() : null,
      local: getIt<LocalLlmService>(),
    ),
  );

  // MLS 双栈调度（默认 Olm；底层 OpenMLS FFI 未绑定时 mlsAvailable=false）
  getIt.registerLazySingleton<MlsManager>(
    () => MlsManager(const UnboundMlsProtocol()),
  );

  // Giphy 服务（配置了 API Key 或代理端点时注册）
  if ((config.giphyApiKey != null && config.giphyApiKey!.isNotEmpty) ||
      config.giphyUseProxyEndpoint) {
    getIt.registerLazySingleton<GiphyService>(
      () => GiphyService(
        config: GiphyConfig(
          apiKey: config.giphyApiKey ?? '',
          baseUrl: config.giphyBaseUrl,
          authToken: config.proxyAuthToken,
          useProxyEndpoint: config.giphyUseProxyEndpoint,
        ),
      ),
      dispose: (service) => service.dispose(),
    );
  }

  // Tenor 服务（配置了 API Key 或代理端点时注册）
  if ((config.tenorApiKey != null && config.tenorApiKey!.isNotEmpty) ||
      config.tenorUseProxyEndpoint) {
    getIt.registerLazySingleton<TenorService>(
      () => TenorService(
        config: TenorConfig(
          apiKey: config.tenorApiKey ?? '',
          baseUrl: config.tenorBaseUrl,
          authToken: config.proxyAuthToken,
          useProxyEndpoint: config.tenorUseProxyEndpoint,
        ),
      ),
      dispose: (service) => service.dispose(),
    );
  }

  // 统一 GIF 服务（Giphy 主 + Tenor 兜底，任一可用即注册，供 GifPicker 使用）
  final gifProviders = <GifService>[
    if (getIt.isRegistered<GiphyService>()) getIt<GiphyService>(),
    if (getIt.isRegistered<TenorService>()) getIt<TenorService>(),
  ];
  if (gifProviders.isNotEmpty) {
    getIt.registerLazySingleton<GifService>(
      () => CompositeGifService(gifProviders),
    );
  }

  // 法币出入金（配置了 key 才注册；未注册时入口/页面降级提示）
  if (config.fiatRampApiKey != null && config.fiatRampApiKey!.isNotEmpty) {
    getIt.registerLazySingleton<FiatRampService>(
      () => FiatRampService(FiatRampConfig(
        provider: config.fiatRampProvider,
        apiKey: config.fiatRampApiKey!,
      )),
    );
  }

  // 用户名服务
  getIt.registerLazySingleton<UsernameService>(
    () => UsernameService(getIt<MatrixClientManager>()),
  );

  // ENS 缓存服务
  getIt.registerLazySingleton<EnsCacheService>(
    () => EnsCacheService(
      clientManager: getIt<MatrixClientManager>(),
      walletBridge: getIt<IWalletBridge>(),
    ),
  );

  // 翻译服务 fallback chain:
  // 1. Google Translate（有 API key 时）
  // 2. AI Translation（有 AI key 或代理端点时）
  // 3. MyMemory（免费 fallback，无需任何 key）
  getIt.registerLazySingleton<ITranslationService>(() {
    final hasGoogleKey =
        config.googleTranslateApiKey != null &&
        config.googleTranslateApiKey!.isNotEmpty;
    if (hasGoogleKey) {
      return GoogleTranslationService(
        apiKey: config.googleTranslateApiKey,
        storageDataSource: getIt<PreferencesDataSource>(),
      );
    }
    if ((config.aiApiKey != null && config.aiApiKey!.isNotEmpty) ||
        config.aiUseProxyEndpoint) {
      return AiTranslationService(
        aiService: getIt<AiService>(),
        storageDataSource: getIt<PreferencesDataSource>(),
      );
    }
    return MyMemoryTranslationService(
      storageDataSource: getIt<PreferencesDataSource>(),
    );
  });

  // 游戏分数服务
  getIt.registerLazySingleton<GameScoreService>(() => GameScoreService());

  // 下载服务
  getIt.registerLazySingleton<DownloadService>(
    () => DownloadService(),
    dispose: (service) => service.dispose(),
  );

  // URL 预览服务
  getIt.registerLazySingleton<UrlPreviewService>(
    () => UrlPreviewService(
      preferencesDataSource: getIt<PreferencesDataSource>(),
    ),
  );

  getIt.registerLazySingleton<BotWebhookService>(
    () => BotWebhookService(
      preferencesDataSource: getIt<PreferencesDataSource>(),
      secureStorageDataSource: getIt<SecureStorageDataSource>(),
    ),
  );

  // 媒体自动下载策略
  getIt.registerLazySingleton<AutoDownloadPolicyService>(
    () => AutoDownloadPolicyService(
      preferencesDataSource: getIt<PreferencesDataSource>(),
    ),
  );

  // 存储管理服务
  getIt.registerLazySingleton<StorageManagerService>(
    () => StorageManagerService(clientManager: getIt<MatrixClientManager>()),
  );

  // 媒体元数据数据库（异步初始化，延迟获取，30 秒超时）
  getIt.registerSingletonAsync<MediaMetadataDatabase>(() async {
    try {
      return await MediaMetadataDatabase.getInstance().timeout(
        const Duration(seconds: 30),
      );
    } on TimeoutException {
      debugLog(
        'DI: MediaMetadataDatabase timed out after 30s, rethrowing for caller to handle',
      );
      rethrow;
    }
  });

  // 归档数据库（异步初始化，延迟获取，30 秒超时）
  getIt.registerSingletonAsync<ArchiveDatabase>(() async {
    try {
      return await ArchiveDatabase.getInstance().timeout(
        const Duration(seconds: 30),
      );
    } on TimeoutException {
      debugLog(
        'DI: ArchiveDatabase timed out after 30s, rethrowing for caller to handle',
      );
      rethrow;
    }
  });

  // 消息归档服务
  getIt.registerLazySingleton<MessageArchiveService>(
    () => MessageArchiveService(
      db: getIt<ArchiveDatabase>(),
      clientManager: getIt<MatrixClientManager>(),
    ),
  );

  // 归档完整性服务
  getIt.registerLazySingleton<ArchiveIntegrityService>(
    () => ArchiveIntegrityService(db: getIt<ArchiveDatabase>()),
  );

  // 归档搜索服务
  getIt.registerLazySingleton<ArchiveSearchService>(
    () => ArchiveSearchService(db: getIt<ArchiveDatabase>()),
  );

  // 媒体生命周期服务
  getIt.registerLazySingleton<MediaLifecycleService>(() {
    final service = MediaLifecycleService(
      db: getIt<MediaMetadataDatabase>(),
      downloadService: getIt<DownloadService>(),
    );
    // 连接下载服务与生命周期服务
    getIt<DownloadService>().setMediaLifecycleService(service);
    return service;
  }, dispose: (service) => service.dispose());

  // 存储监控服务
  getIt.registerLazySingleton<StorageMonitorService>(
    () => StorageMonitorService(
      storageManager: getIt<StorageManagerService>(),
      lifecycleService: getIt<MediaLifecycleService>(),
    ),
    dispose: (service) => service.dispose(),
  );

  // 存储清理建议服务
  getIt.registerLazySingleton<StorageCleanupService>(
    () => StorageCleanupService(
      lifecycleService: getIt<MediaLifecycleService>(),
      storageManager: getIt<StorageManagerService>(),
    ),
  );

  // 聊天备份服务
  getIt.registerLazySingleton<ChatBackupService>(
    () => ChatBackupService(
      clientManager: getIt<MatrixClientManager>(),
      secureStorage: getIt<SecureStorageDataSource>(),
      preferencesStorage: getIt<PreferencesDataSource>(),
      archiveService: getIt<MessageArchiveService>(),
    ),
  );

  // 数据分级服务
  getIt.registerLazySingleton<DataTierService>(
    () => DataTierService(
      lifecycleService: getIt<MediaLifecycleService>(),
      monitorService: getIt<StorageMonitorService>(),
      archiveService: getIt<MessageArchiveService>(),
    ),
  );

  // 同步优化服务
  getIt.registerLazySingleton<SyncOptimizationService>(
    () => SyncOptimizationService(clientManager: getIt<MatrixClientManager>()),
  );

  // AI 服务（配置了 API Key 或代理端点时注册）
  if ((config.aiApiKey != null && config.aiApiKey!.isNotEmpty) ||
      config.aiUseProxyEndpoint) {
    getIt.registerLazySingleton<AiService>(
      () => AiDatasource(
        apiKey: config.aiApiKey ?? '',
        baseUrl: config.aiBaseUrl,
        defaultModel: config.aiModel,
        useProxyEndpoint: config.aiUseProxyEndpoint,
      ),
      dispose: (service) => service.dispose(),
    );
  }

  // 红包服务（本地实现，过渡方案）
  getIt.registerLazySingleton<IRedPacketService>(() => LocalRedPacketService());

  // 链上事件推送后台服务（仅当 Push Protocol 启用时注册）
  final ppConfig = config.pushProtocol;
  if (ppConfig != null && ppConfig.enabled) {
    getIt.registerLazySingleton<OnChainNotificationService>(
      () => OnChainNotificationService(
        repository: getIt<IOnChainNotificationRepository>(),
        walletBridge: getIt<IWalletBridge>(),
        inAppNotificationService: InAppNotificationService.instance,
        chainId: ppConfig.chainId,
        pollInterval: ppConfig.pollInterval,
      ),
    );
  }

  // ─── P2.1 协议抽象层 ───────────────────────────────────────────────────
  if (config.enableProtocolAbstraction) {
    getIt.registerLazySingleton<ProtocolRegistry>(() => ProtocolRegistry());
    getIt.registerLazySingleton<IMessagingProtocol>(() {
      final protocol = MatrixProtocol(
        clientManager: getIt<MatrixClientManager>(),
        roomDataSource: getIt<MatrixRoomDataSource>(),
        messageDataSource: getIt<MatrixMessageDataSource>(),
        contactDataSource: getIt<MatrixContactDataSource>(),
      );
      // 自动注册到 ProtocolRegistry
      getIt<ProtocolRegistry>().register(protocol);
      return protocol;
    }, dispose: (protocol) => (protocol as MatrixProtocol).dispose());
  }

  // ─── P2.3 社交图谱服务 ─────────────────────────────────────────────────
  if (config.enableSocialGraph) {
    getIt.registerLazySingleton<SocialGraphService>(
      () => SocialGraphService(
        debank: getIt<DeBankDatasource>(),
        alchemy: getIt<AlchemySocialDatasource>(),
      ),
    );
  }

  // ─── P2.4 积分追踪服务 ─────────────────────────────────────────────────
  if (config.enablePoints && config.pointsApiBaseUrl != null) {
    getIt.registerLazySingleton<PointsTrackingService>(
      () => PointsTrackingService(
        repository: getIt<IPointsRepository>(),
        clientManager: getIt<MatrixClientManager>(),
      ),
      dispose: (svc) => svc.dispose(),
    );
  }

  // 语音房间服务（业务服务，不属于 BLoC 注册区）。
  // 依赖 IVoiceRoomRepository（_registerRepositories）+ MatrixClientManager；
  // 用 lazySingleton 推迟到首次解析，避免与 repository 注册顺序耦合。
  getIt.registerLazySingleton<VoiceRoomService>(
    () => VoiceRoomService(
      repository: getIt<IVoiceRoomRepository>(),
      currentUserIdProvider: () => getIt<MatrixClientManager>().userId,
    ),
    dispose: (service) => service.dispose(),
  );
}

/// 注册数据源
Future<void> _registerDataSources() async {
  // 安全存储（仅敏感数据：会话、凭据、多账号、生物识别）
  getIt.registerLazySingleton<SecureStorageDataSource>(
    () => SecureStorageDataSource(),
  );

  // 偏好设置存储（非敏感数据：外观、备注、草稿等）
  getIt.registerLazySingleton<PreferencesDataSource>(
    () => PreferencesDataSource(),
  );

  // 待办提醒服务（自带本地通知 + 60s 周期到期检查）
  getIt.registerLazySingleton<ReminderService>(
    () => ReminderService(getIt<PreferencesDataSource>()),
    dispose: (svc) => svc.dispose(),
  );
  getIt<ReminderService>().start();

  // 订阅服务（创作者计划 + 用户订阅记录，本地存储）
  getIt.registerLazySingleton<SubscriptionService>(
    () => SubscriptionService(getIt<PreferencesDataSource>()),
  );

  // Matrix认证数据源
  getIt.registerLazySingleton<MatrixAuthDataSource>(
    () => MatrixAuthDataSource(
      clientManager: getIt<MatrixClientManager>(),
      secureStorage: getIt<SecureStorageDataSource>(),
    ),
  );

  // Matrix房间数据源
  getIt.registerLazySingleton<MatrixRoomDataSource>(
    () => MatrixRoomDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix消息数据源
  getIt.registerLazySingleton<MatrixMessageDataSource>(
    () => MatrixMessageDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix联系人数据源
  getIt.registerLazySingleton<MatrixContactDataSource>(
    () => MatrixContactDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix群聊数据源
  getIt.registerLazySingleton<MatrixGroupDataSource>(
    () => MatrixGroupDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix搜索数据源
  getIt.registerLazySingleton<MatrixSearchDataSource>(
    () => MatrixSearchDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix消息反应数据源
  getIt.registerLazySingleton<MatrixReactionDataSource>(
    () => MatrixReactionDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix动态数据源
  getIt.registerLazySingleton<MatrixMomentDataSource>(
    () => MatrixMomentDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix贴纸数据源
  getIt.registerLazySingleton<MatrixStickerDataSource>(
    () => MatrixStickerDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix Story 数据源
  getIt.registerLazySingleton<MatrixStoryDataSource>(
    () => MatrixStoryDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix 语音房间数据源
  getIt.registerLazySingleton<MatrixVoiceRoomDataSource>(
    () => MatrixVoiceRoomDataSource(getIt<MatrixClientManager>()),
  );

  // Matrix Space 数据源
  getIt.registerLazySingleton<MatrixSpaceDataSource>(
    () => MatrixSpaceDataSource(getIt<MatrixClientManager>()),
  );

  // Push Protocol 数据源（链上事件通知，仅在启用时注册）
  final ppConfig = getIt<N42ChatConfig>().pushProtocol;
  if (ppConfig != null && ppConfig.enabled) {
    getIt.registerSingletonAsync<PushProtocolDatasource>(() async {
      final prefs = await SharedPreferences.getInstance();
      return PushProtocolDatasource(prefs: prefs, baseUrl: ppConfig.apiBaseUrl);
    });
  }

  final config = getIt<N42ChatConfig>();

  // ─── P2.2 Governance 数据源 ────────────────────────────────────────────
  if (config.enableGovernance) {
    getIt.registerLazySingleton<SnapshotGraphQLDatasource>(
      () => SnapshotGraphQLDatasource(),
      dispose: (ds) => ds.dispose(),
    );
    getIt.registerLazySingleton<SnapshotHubDatasource>(
      () => SnapshotHubDatasource(
        walletBridge: getIt<IWalletBridge>(),
        hubEndpoint: config.snapshotHubUrl,
      ),
      dispose: (ds) => ds.dispose(),
    );
  }

  // ─── P2.3 Social Graph 数据源 ──────────────────────────────────────────
  if (config.enableSocialGraph) {
    getIt.registerLazySingleton<DeBankDatasource>(
      () => DeBankDatasource(
        baseUrl: config.debankBaseUrl,
        apiKey: config.debankApiKey,
        authToken: config.proxyAuthToken,
        useProxyEndpoint: config.debankUseProxyEndpoint,
      ),
      dispose: (ds) => ds.dispose(),
    );
    getIt.registerLazySingleton<AlchemySocialDatasource>(
      () => AlchemySocialDatasource(
        apiKey: config.alchemyApiKey ?? '',
        baseUrl: config.alchemyBaseUrl,
        authToken: config.proxyAuthToken,
        useProxyEndpoint: config.alchemyUseProxyEndpoint,
      ),
      dispose: (ds) => ds.dispose(),
    );
    getIt.registerLazySingleton<OnChainIdentityDatasource>(
      () => OnChainIdentityDatasource(),
      dispose: (ds) => ds.dispose(),
    );
  }

  // ─── P2.4 Points 数据源 ────────────────────────────────────────────────
  if (config.enablePoints && config.pointsApiBaseUrl != null) {
    getIt.registerLazySingleton<PointsApiDatasource>(
      () => PointsApiDatasource(
        baseUrl: config.pointsApiBaseUrl!,
        getAccessToken: () {
          final client = MatrixClientManager.instance.client;
          return client?.accessToken;
        },
      ),
      dispose: (ds) => ds.dispose(),
    );
  }
}

/// 注册仓库
void _registerRepositories() {
  // 认证仓库
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      authDataSource: getIt<MatrixAuthDataSource>(),
      secureStorage: getIt<SecureStorageDataSource>(),
    ),
    dispose: (repo) => (repo as AuthRepositoryImpl).dispose(),
  );

  // 会话仓库
  getIt.registerLazySingleton<IConversationRepository>(
    () => ConversationRepositoryImpl(
      getIt<MatrixRoomDataSource>(),
      getIt<PreferencesDataSource>(),
    ),
  );

  // 消息仓库
  getIt.registerLazySingleton<IMessageRepository>(
    () => MessageRepositoryImpl(
      getIt<MatrixMessageDataSource>(),
      getIt<MatrixClientManager>(),
      getIt<PreferencesDataSource>(),
      archiveService: getIt<MessageArchiveService>(),
    ),
  );

  // 联系人仓库
  getIt.registerLazySingleton<IContactRepository>(
    () => ContactRepositoryImpl(
      getIt<MatrixContactDataSource>(),
      getIt<PreferencesDataSource>(),
      getIt<MatrixMomentDataSource>(),
    ),
  );

  // 群聊仓库
  getIt.registerLazySingleton<IGroupRepository>(
    () => GroupRepositoryImpl(
      getIt<MatrixGroupDataSource>(),
      getIt<MatrixClientManager>(),
      walletBridge: getIt<IWalletBridge>(),
      messageDataSource: getIt<MatrixMessageDataSource>(),
    ),
  );

  // 转账仓库
  getIt.registerLazySingleton<ITransferRepository>(
    () => TransferRepositoryImpl(
      getIt<IWalletBridge>(),
      getIt<MatrixMessageDataSource>(),
      getIt<MatrixClientManager>(),
    ),
  );

  // 搜索仓库
  getIt.registerLazySingleton<ISearchRepository>(
    () => SearchRepositoryImpl(
      getIt<MatrixSearchDataSource>(),
      getIt<MatrixClientManager>(),
      ensCacheService: getIt<EnsCacheService>(),
      usernameService: getIt<UsernameService>(),
    ),
  );

  // 消息操作仓库
  getIt.registerLazySingleton<IMessageActionRepository>(
    () => MessageActionRepositoryImpl(
      getIt<MatrixReactionDataSource>(),
      getIt<MatrixClientManager>(),
      getIt<PreferencesDataSource>(),
    ),
  );

  // 动态仓库
  getIt.registerLazySingleton<IMomentRepository>(
    () => MomentRepositoryImpl(
      getIt<MatrixMomentDataSource>(),
      getIt<PreferencesDataSource>(),
    ),
  );

  // 贴纸仓库
  getIt.registerLazySingleton<IStickerRepository>(
    () => StickerRepositoryImpl(getIt<MatrixStickerDataSource>()),
  );

  // AI 生成贴纸服务（云端文生图 → 贴纸包）。AiProviderRouter 总注册，
  // 其 supportsImageGeneration 反映云端是否可用（无云端则 UI 隐藏入口）。
  getIt.registerLazySingleton<AiStickerService>(
    () => AiStickerService(
      getIt<AiProviderRouter>(),
      getIt<IStickerRepository>(),
    ),
  );

  // Story 仓库
  getIt.registerLazySingleton<IStoryRepository>(
    () => StoryRepositoryImpl(
      getIt<MatrixStoryDataSource>(),
      getIt<PreferencesDataSource>(),
    ),
  );

  // 语音房间仓库
  getIt.registerLazySingleton<IVoiceRoomRepository>(
    () => VoiceRoomRepositoryImpl(getIt<MatrixVoiceRoomDataSource>()),
  );

  // Space 社群仓库
  getIt.registerLazySingleton<ISpaceRepository>(
    () => SpaceRepositoryImpl(getIt<MatrixSpaceDataSource>()),
  );

  // AI 仓库（仅当 AI 服务已注册时）
  if (getIt.isRegistered<AiService>()) {
    getIt.registerLazySingleton<IAiRepository>(
      () => AiRepositoryImpl(
        aiService: getIt<AiService>(),
        storage: getIt<PreferencesDataSource>(),
      ),
    );
  }

  // 链上事件通知仓库（仅当 Push Protocol 数据源已注册时）
  if (getIt.isRegistered<PushProtocolDatasource>()) {
    getIt.registerSingletonAsync<IOnChainNotificationRepository>(() async {
      final ds = await getIt.getAsync<PushProtocolDatasource>();
      return OnChainNotificationRepositoryImpl(ds);
    });
  }

  // ─── P2.2 Governance 仓库 ──────────────────────────────────────────────
  if (getIt.isRegistered<SnapshotGraphQLDatasource>()) {
    getIt.registerLazySingleton<IGovernanceRepository>(
      () => GovernanceRepositoryImpl(
        graphql: getIt<SnapshotGraphQLDatasource>(),
        hub: getIt<SnapshotHubDatasource>(),
      ),
    );
  }

  // ─── P2.3 Social Graph 仓库 ───────────────────────────────────────────
  if (getIt.isRegistered<DeBankDatasource>()) {
    getIt.registerLazySingleton<ISocialGraphRepository>(
      () => SocialGraphRepositoryImpl(
        debank: getIt<DeBankDatasource>(),
        identity: getIt<OnChainIdentityDatasource>(),
        graphService: getIt<SocialGraphService>(),
      ),
    );
  }

  // ─── P2.4 Points 仓库 ─────────────────────────────────────────────────
  if (getIt.isRegistered<PointsApiDatasource>()) {
    getIt.registerLazySingleton<IPointsRepository>(
      () => PointsRepositoryImpl(api: getIt<PointsApiDatasource>()),
    );
  }
}

/// 注册用例
///
/// 当前架构中 BLoC 直接依赖 Repository，无 UseCase 中间层。
/// domain/usecases/ 目录尚未创建。如果后续需要引入 UseCase 层
/// （例如跨 Repository 的业务编排），在此处注册。
void _registerUseCases() {
  // BLoC → Repository 直连模式，暂无独立 UseCase 需注册
}

/// 注册BLoC
void _registerBlocs() {
  // 认证BLoC - 使用 LazySingleton，保持与 N42Chat._authBloc 引用一致
  // 如需重置（重新登录），由 resetDependencies() 统一处理
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: getIt<IAuthRepository>()),
  );

  // 会话列表BLoC
  getIt.registerFactory<ConversationBloc>(
    () => ConversationBloc(
      conversationRepository: getIt<IConversationRepository>(),
      storageDataSource: getIt<PreferencesDataSource>(),
    ),
  );

  // 聊天BLoC
  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(
      messageRepository: getIt<IMessageRepository>(),
      secureStorage: getIt<PreferencesDataSource>(),
      groupRepository: getIt<IGroupRepository>(),
      translationService: getIt<ITranslationService>(),
      clientManager: getIt<MatrixClientManager>(),
    ),
  );

  // 联系人BLoC
  getIt.registerFactory<ContactBloc>(
    () => ContactBloc(getIt<IContactRepository>()),
  );

  // 群聊BLoC
  getIt.registerFactory<GroupBloc>(
    () => GroupBloc(
      getIt<IGroupRepository>(),
      botWebhookService: getIt<BotWebhookService>(),
    ),
  );

  // 转账BLoC
  getIt.registerFactory<TransferBloc>(
    () => TransferBloc(getIt<ITransferRepository>(), getIt<IWalletBridge>()),
  );

  // 搜索BLoC
  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(getIt<ISearchRepository>()),
  );

  // 消息操作BLoC
  getIt.registerFactory<MessageActionBloc>(
    () => MessageActionBloc(getIt<IMessageActionRepository>()),
  );

  // 动态BLoC
  getIt.registerFactory<MomentBloc>(
    () => MomentBloc(getIt<IMomentRepository>()),
  );

  // Story BLoC
  getIt.registerFactory<StoryBloc>(() => StoryBloc(getIt<IStoryRepository>()));

  // 线程 BLoC
  getIt.registerFactory<ThreadBloc>(
    () => ThreadBloc(messageRepository: getIt<IMessageRepository>()),
  );

  // 实时位置 BLoC
  getIt.registerFactory<LiveLocationBloc>(
    () => LiveLocationBloc(messageDataSource: getIt<MatrixMessageDataSource>()),
  );

  // 语音房间 BLoC（VoiceRoomService 在 _registerServices 中注册）
  getIt.registerFactory<VoiceRoomBloc>(
    () => VoiceRoomBloc(
      repository: getIt<IVoiceRoomRepository>(),
      voiceRoomService: getIt<VoiceRoomService>(),
    ),
  );

  // AI 助手 BLoC（仅当 AI 仓库已注册时）
  if (getIt.isRegistered<IAiRepository>()) {
    getIt.registerFactory<AiAssistantBloc>(
      () => AiAssistantBloc(
        aiRepository: getIt<IAiRepository>(),
        walletBridge: getIt.isRegistered<IWalletBridge>()
            ? getIt<IWalletBridge>()
            : null,
      ),
    );
  }

  // 聊天文件夹 BLoC
  getIt.registerFactory<ChatFolderBloc>(
    () => ChatFolderBloc(storage: getIt<PreferencesDataSource>()),
  );

  // Space 社群 BLoC
  getIt.registerFactory<SpaceBloc>(
    () => SpaceBloc(repository: getIt<ISpaceRepository>()),
  );

  // 链上事件通知 BLoC（仅当 Push Protocol 仓库已注册时）
  if (getIt.isRegistered<IOnChainNotificationRepository>()) {
    final ppCfg = getIt<N42ChatConfig>().pushProtocol;
    getIt.registerFactory<OnChainNotificationBloc>(
      () => OnChainNotificationBloc(
        repository: getIt<IOnChainNotificationRepository>(),
        walletBridge: getIt<IWalletBridge>(),
        chainId: ppCfg?.chainId ?? 1,
      ),
    );
  }

  // ─── P2.2 Governance BLoC ─────────────────────────────────────────────
  if (getIt.isRegistered<IGovernanceRepository>()) {
    getIt.registerFactory<GovernanceBloc>(
      () => GovernanceBloc(repository: getIt<IGovernanceRepository>()),
    );
  }

  // ─── P2.3 Social Graph BLoC ───────────────────────────────────────────
  if (getIt.isRegistered<ISocialGraphRepository>()) {
    getIt.registerFactory<SocialGraphBloc>(
      () => SocialGraphBloc(repository: getIt<ISocialGraphRepository>()),
    );
  }

  // ─── P2.4 Points BLoC ─────────────────────────────────────────────────
  if (getIt.isRegistered<IPointsRepository>()) {
    getIt.registerFactory<PointsBloc>(
      () => PointsBloc(repository: getIt<IPointsRepository>()),
    );
  }
}

/// 重置依赖（用于测试）
Future<void> resetDependencies() async {
  await getIt.reset();
}

/// 检查是否已注册
bool isRegistered<T extends Object>() => getIt.isRegistered<T>();

/// 扩展方法：简化获取依赖
extension GetItExtension on GetIt {
  /// 获取配置
  N42ChatConfig get config => get<N42ChatConfig>();
}
