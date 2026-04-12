/// 集中管理所有超时、轮询、缓存等可调优数值。
///
/// 修改单一位置即可全局生效，避免硬编码 Duration 散布在各文件中。
class TimingConstants {
  TimingConstants._();

  // ==================== 网络超时 ====================

  /// 外部 API 请求超时（CoinGecko, Messari, DeFiLlama 等）
  static const Duration apiTimeout = Duration(seconds: 10);

  /// 区块链 RPC 请求超时
  static const Duration rpcTimeout = Duration(seconds: 15);

  /// 媒体文件上传超时
  static const Duration uploadTimeout = Duration(minutes: 2);

  /// 认证相关操作超时（登录、Token 刷新）
  static const Duration authTimeout = Duration(seconds: 30);

  /// 深度链接初始化超时
  static const Duration deepLinkTimeout = Duration(seconds: 5);

  // ==================== 同步与轮询 ====================

  /// Matrix 同步等待超时
  static const Duration syncTimeout = Duration(seconds: 10);

  /// 通用状态轮询间隔
  static const Duration pollInterval = Duration(seconds: 10);

  /// 输入防抖延迟
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // ==================== 缓存与分页 ====================

  /// 消息实体缓存最大条目数
  static const int messageCacheSize = 200;

  /// 列表默认分页大小
  static const int defaultPageSize = 50;

  // ==================== 重试 ====================
  // 网络层重试参数由 RetryPolicy (retry_interceptor.dart) 管理。
  // Chat 消息重试参数由 AppConstants (n42_chat) 管理。
  // 此处不重复定义，避免多源冲突。
}
