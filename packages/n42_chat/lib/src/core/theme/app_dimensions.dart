/// 尺寸常量定义
///
/// 基于微信设计规范
abstract class AppDimensions {
  AppDimensions._();

  // ============================================
  // 间距
  // ============================================

  /// 超小间距 - 4dp
  static const double spacingXS = 4.0;

  /// 小间距 - 8dp
  static const double spacingS = 8.0;

  /// 中等间距 - 12dp
  static const double spacingM = 12.0;

  /// 标准间距 - 16dp
  static const double spacing = 16.0;

  /// 大间距 - 20dp
  static const double spacingL = 20.0;

  /// 超大间距 - 24dp
  static const double spacingXL = 24.0;

  /// 超超大间距 - 32dp
  static const double spacingXXL = 32.0;

  // ============================================
  // 圆角
  // ============================================

  /// 超小圆角 - 2dp
  static const double radiusXS = 2.0;

  /// 小圆角 - 4dp (微信风格)
  static const double radiusS = 4.0;

  /// 中等圆角 - 8dp
  static const double radiusM = 8.0;

  /// 大圆角 - 12dp
  static const double radiusL = 12.0;

  /// 超大圆角 - 16dp
  static const double radiusXL = 16.0;

  /// 圆形
  static const double radiusFull = 999.0;

  // ============================================
  // 头像
  // ============================================

  /// 头像大小 - 会话列表
  static const double avatarSizeConversation = 48.0;

  /// 头像大小 - 聊天页
  static const double avatarSizeChat = 40.0;

  /// 头像大小 - 小
  static const double avatarSizeSmall = 32.0;

  /// 头像大小 - 超小
  static const double avatarSizeXSmall = 24.0;

  /// 头像大小 - 个人资料
  static const double avatarSizeProfile = 72.0;

  /// 头像圆角
  static const double avatarRadius = 4.0;

  // ============================================
  // 导航栏
  // ============================================

  /// 导航栏高度
  static const double appBarHeight = 44.0;

  /// 底部导航栏高度
  static const double bottomNavBarHeight = 56.0;

  /// 搜索栏高度
  static const double searchBarHeight = 36.0;

  // ============================================
  // 列表项
  // ============================================

  /// 会话列表项高度
  static const double conversationItemHeight = 72.0;

  /// 联系人列表项高度
  static const double contactItemHeight = 56.0;

  /// 设置列表项高度
  static const double settingsItemHeight = 52.0;

  /// 列表项内边距
  static const double listItemPadding = 16.0;

  // ============================================
  // 消息
  // ============================================

  /// 消息气泡最大宽度比例
  static const double messageBubbleMaxWidthRatio = 0.7;

  /// 消息气泡圆角
  static const double messageBubbleRadius = 4.0;

  /// 消息气泡内边距
  static const double messageBubblePadding = 10.0;

  /// 消息间距
  static const double messageSpacing = 8.0;

  /// 时间分隔线间距
  static const double timeSeparatorSpacing = 20.0;

  // ============================================
  // 输入框
  // ============================================

  /// 输入框高度 - 最小
  static const double inputMinHeight = 36.0;

  /// 输入框高度 - 最大
  static const double inputMaxHeight = 120.0;

  /// 聊天输入栏高度
  static const double chatInputBarMinHeight = 56.0;

  // ============================================
  // 按钮
  // ============================================

  /// 按钮高度 - 标准
  static const double buttonHeight = 48.0;

  /// 按钮高度 - 小
  static const double buttonHeightSmall = 36.0;

  /// 按钮圆角
  static const double buttonRadius = 4.0;

  // ============================================
  // 徽章
  // ============================================

  /// 红点大小
  static const double badgeDotSize = 8.0;

  /// 数字徽章最小宽度
  static const double badgeMinWidth = 18.0;

  /// 数字徽章高度
  static const double badgeHeight = 18.0;

  // ============================================
  // 图标
  // ============================================

  /// 图标大小 - 导航栏
  static const double iconSizeAppBar = 24.0;

  /// 图标大小 - 底部导航
  static const double iconSizeBottomNav = 24.0;

  /// 图标大小 - 标准
  static const double iconSize = 24.0;

  /// 图标大小 - 小
  static const double iconSizeSmall = 20.0;

  /// 图标大小 - 超小
  static const double iconSizeXSmall = 16.0;

  // ============================================
  // 分割线
  // ============================================

  /// 分割线粗细
  static const double dividerThickness = 0.5;

  /// 分割线缩进
  static const double dividerIndent = 72.0;

  // ============================================
  // 动画时长
  // ============================================

  /// 快速动画
  static const Duration animationFast = Duration(milliseconds: 150);

  /// 标准动画
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// 慢速动画
  static const Duration animationSlow = Duration(milliseconds: 450);
}

