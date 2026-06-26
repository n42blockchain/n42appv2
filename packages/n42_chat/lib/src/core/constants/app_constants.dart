/// 应用常量定义
abstract class AppConstants {
  AppConstants._();

  // ============================================
  // 应用信息
  // ============================================

  /// 应用名称
  static const String appName = 'N42 Chat';

  /// 应用版本
  static const String appVersion = '0.1.0';

  /// 应用包名
  static const String packageName = 'com.n42.chat';

  // ============================================
  // Matrix 相关
  // ============================================

  /// 默认Matrix服务器
  static const String defaultHomeserver = 'https://m.si46.world';

  /// 支持的Matrix服务器列表
  static const List<String> popularHomeservers = [
    defaultHomeserver,
    'https://matrix.org',
    'https://matrix.im',
    'https://tchncs.de',
  ];

  /// 同步超时时间（秒）
  static const int syncTimeout = 30;

  /// 每页消息数量
  static const int messagesPerPage = 50;

  /// 最大重试次数
  static const int maxRetryCount = 3;

  /// 重试延迟（毫秒）
  static const int retryDelayMs = 1000;

  // ============================================
  // 消息相关
  // ============================================

  /// 消息撤回时限（秒）
  static const int messageDeleteTimeout = 120;

  /// 时间分隔阈值（分钟）
  static const int timeSeparatorThreshold = 5;

  /// 消息输入框最大行数
  static const int inputMaxLines = 6;

  /// 消息最大长度
  static const int messageMaxLength = 10000;

  // ============================================
  // 媒体相关
  // ============================================

  /// 图片最大尺寸（字节）- 10MB
  static const int maxImageSize = 10 * 1024 * 1024;

  /// 图片压缩质量
  static const int imageCompressQuality = 80;

  /// 图片缩略图尺寸
  static const int thumbnailSize = 200;

  /// 文件最大尺寸（字节）- 50MB
  static const int maxFileSize = 50 * 1024 * 1024;

  /// 语音消息最大时长（秒）
  static const int maxVoiceDuration = 60;

  /// 语音消息最小时长（秒）
  static const int minVoiceDuration = 1;

  // ============================================
  // 缓存相关
  // ============================================

  /// 图片缓存大小（字节）- 100MB
  static const int imageCacheMaxSize = 100 * 1024 * 1024;

  /// 图片缓存有效期（天）
  static const int imageCacheMaxAge = 30;

  /// 消息缓存有效期（天）
  static const int messageCacheMaxAge = 90;

  // ============================================
  // UI相关
  // ============================================

  /// 下拉刷新触发距离
  static const double pullToRefreshTrigger = 80;

  /// 列表滚动阈值（触发加载更多）
  static const double scrollThreshold = 200;

  /// 键盘弹出延迟
  static const int keyboardDelayMs = 100;

  // ============================================
  // 通知相关
  // ============================================

  /// 通知渠道ID - Android
  static const String notificationChannelId = 'n42_chat_messages';

  /// 通知渠道名称
  static const String notificationChannelName = 'N42 Chat Messages';

  /// 通知渠道描述
  static const String notificationChannelDesc = 'New message notifications';

  // ============================================
  // 正则表达式
  // ============================================

  /// Matrix用户ID正则
  static final RegExp matrixIdPattern = RegExp(
    r'^@[a-zA-Z0-9._=\-/]+:[a-zA-Z0-9.\-]+$',
  );

  /// Matrix房间ID正则
  static final RegExp roomIdPattern = RegExp(
    r'^![a-zA-Z0-9]+:[a-zA-Z0-9.\-]+$',
  );

  /// Matrix房间别名正则
  static final RegExp roomAliasPattern = RegExp(
    r'^#[a-zA-Z0-9._=\-]+:[a-zA-Z0-9.\-]+$',
  );

  /// URL正则
  static final RegExp urlPattern = RegExp(
    r'https?://[^\s<>\[\]{}|\\^`"]+',
    caseSensitive: false,
  );
}

/// 存储管理相关常量
abstract class StorageConstants {
  StorageConstants._();

  /// 默认自动清理天数
  static const int defaultCleanupDays = 90;

  /// 存储预警阈值 (MB)
  static const int defaultWarningThresholdMB = 500;

  /// 存储严重阈值 (MB)
  static const int defaultCriticalThresholdMB = 1000;

  /// 热数据天数（内存缓存 + 完整媒体）
  static const int hotDataDays = 30;

  /// 暖数据天数（缩略图 + 按需加载）
  static const int warmDataDays = 180;

  /// 大文件阈值（字节）- 10MB
  static const int largeFileThreshold = 10 * 1024 * 1024;

  /// 备份文件扩展名
  static const String backupExtension = '.n42backup';

  /// 备份目录名
  static const String backupDirName = 'n42_chat_backups';

  /// 媒体元数据数据库目录名
  static const String metaDbDirName = 'n42_chat_storage';

  /// 媒体元数据数据库文件名
  static const String metaDbFileName = 'media_meta.db';
}
