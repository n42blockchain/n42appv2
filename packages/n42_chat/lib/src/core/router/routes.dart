/// 路由路径常量
abstract class Routes {
  Routes._();

  // ============================================
  // 主Tab页面
  // ============================================

  /// 会话列表（消息Tab）
  static const String conversationList = '/chat';
  static const String conversationListName = 'conversationList';

  /// 通讯录Tab
  static const String contacts = '/contacts';
  static const String contactsName = 'contacts';

  /// 发现Tab
  static const String discover = '/discover';
  static const String discoverName = 'discover';

  /// 个人中心Tab
  static const String profile = '/profile';
  static const String profileName = 'profile';

  // ============================================
  // 聊天相关
  // ============================================

  /// 聊天详情页
  static const String chat = '/chat/conversation/:roomId';
  static const String chatName = 'chat';

  /// 生成聊天详情路径
  static String chatPath(String roomId) =>
      '/chat/conversation/${Uri.encodeComponent(roomId)}';

  // ============================================
  // 通讯录相关
  // ============================================

  /// 联系人详情
  static const String contactDetail = '/contacts/detail/:userId';
  static const String contactDetailName = 'contactDetail';

  /// 生成联系人详情路径
  static String contactDetailPath(String userId) =>
      '/contacts/detail/${Uri.encodeComponent(userId)}';

  /// 添加联系人
  static const String addContact = '/contacts/add';
  static const String addContactName = 'addContact';

  // ============================================
  // 个人中心相关
  // ============================================

  /// 设置
  static const String settings = '/profile/settings';
  static const String settingsName = 'settings';

  /// 编辑资料
  static const String editProfile = '/profile/edit';
  static const String editProfileName = 'editProfile';

  // ============================================
  // 认证相关
  // ============================================

  /// 登录
  static const String login = '/login';
  static const String loginName = 'login';

  /// 注册
  static const String register = '/register';
  static const String registerName = 'register';

  /// 欢迎页
  static const String welcome = '/welcome';
  static const String welcomeName = 'welcome';

  // ============================================
  // 群组相关
  // ============================================

  /// 创建群聊
  static const String createGroup = '/group/create';
  static const String createGroupName = 'createGroup';

  /// 群资料
  static const String groupInfo = '/group/:roomId/info';
  static const String groupInfoName = 'groupInfo';

  /// 生成群资料路径
  static String groupInfoPath(String roomId) =>
      '/group/${Uri.encodeComponent(roomId)}/info';

  /// 群成员
  static const String groupMembers = '/group/:roomId/members';
  static const String groupMembersName = 'groupMembers';

  /// 生成群成员路径
  static String groupMembersPath(String roomId) =>
      '/group/${Uri.encodeComponent(roomId)}/members';

  // ============================================
  // 搜索
  // ============================================

  /// 全局搜索
  static const String search = '/search';
  static const String searchName = 'search';

  /// 会话内搜索
  static const String chatSearch = '/chat/:roomId/search';
  static const String chatSearchName = 'chatSearch';

  /// 生成会话内搜索路径
  static String chatSearchPath(String roomId) =>
      '/chat/${Uri.encodeComponent(roomId)}/search';

  // ============================================
  // 媒体预览
  // ============================================

  /// 图片预览
  static const String imagePreview = '/preview/image';
  static const String imagePreviewName = 'imagePreview';

  /// 视频播放
  static const String videoPlayer = '/preview/video';
  static const String videoPlayerName = 'videoPlayer';

  // ============================================
  // Space/社区
  // ============================================

  /// Space 列表
  static const String spaceList = '/spaces';
  static const String spaceListName = 'spaceList';

  /// Space 详情
  static const String spaceDetail = '/spaces/:spaceId';
  static const String spaceDetailName = 'spaceDetail';

  /// 生成 Space 详情路径
  static String spaceDetailPath(String spaceId) =>
      '/spaces/${Uri.encodeComponent(spaceId)}';

  // ============================================
  // 媒体画廊
  // ============================================

  /// 媒体画廊
  static const String mediaGallery = '/chat/:roomId/media';
  static const String mediaGalleryName = 'mediaGallery';

  /// 生成媒体画廊路径
  static String mediaGalleryPath(String roomId) =>
      '/chat/${Uri.encodeComponent(roomId)}/media';

  /// PDF 预览
  static const String pdfViewer = '/preview/pdf';
  static const String pdfViewerName = 'pdfViewer';

  // ============================================
  // 聊天记录导出
  // ============================================

  /// 导出聊天记录
  static const String chatExport = '/chat/:roomId/export';
  static const String chatExportName = 'chatExport';

  /// 生成导出路径
  static String chatExportPath(String roomId) =>
      '/chat/${Uri.encodeComponent(roomId)}/export';

  // ============================================
  // 安全验证
  // ============================================

  /// SAS 设备验证
  static const String sasVerification = '/security/verify';
  static const String sasVerificationName = 'sasVerification';

  // ============================================
  // 消息线程
  // ============================================

  /// 线程详情页
  static const String threadDetail = '/chat/:roomId/thread/:threadRootEventId';
  static const String threadDetailName = 'threadDetail';

  /// 生成线程详情路径
  static String threadDetailPath(String roomId, String threadRootEventId) =>
      '/chat/${Uri.encodeComponent(roomId)}/thread/${Uri.encodeComponent(threadRootEventId)}';

  // ============================================
  // 语音聊天室
  // ============================================

  /// 语音房间列表
  static const String voiceRoomList = '/voice-rooms';
  static const String voiceRoomListName = 'voiceRoomList';

  /// 语音房间详情
  static const String voiceRoom = '/voice-rooms/:roomId';
  static const String voiceRoomName = 'voiceRoom';

  /// 生成语音房间路径
  static String voiceRoomPath(String roomId) =>
      '/voice-rooms/${Uri.encodeComponent(roomId)}';

  // ============================================
  // 用户名设置
  // ============================================

  /// 设置用户名页面
  static const String setUsername = '/profile/username';
  static const String setUsernameName = 'setUsername';

  // ============================================
  // 代币门控
  // ============================================

  /// 代币门控设置页
  static const String tokenGateSettings = '/group/:roomId/token-gate';
  static const String tokenGateSettingsName = 'tokenGateSettings';

  /// 生成代币门控设置路径
  static String tokenGateSettingsPath(String roomId) =>
      '/group/${Uri.encodeComponent(roomId)}/token-gate';

  /// 代币门控验证页
  static const String tokenGateVerify = '/group/:roomId/token-gate/verify';
  static const String tokenGateVerifyName = 'tokenGateVerify';

  /// 生成代币门控验证路径
  static String tokenGateVerifyPath(String roomId) =>
      '/group/${Uri.encodeComponent(roomId)}/token-gate/verify';

  // ============================================
  // 媒体中心
  // ============================================

  /// 媒体预览
  static const String mediaPreview = '/preview/media';
  static const String mediaPreviewName = 'mediaPreview';

  /// 群媒体中心
  static const String groupMediaHub = '/group/:roomId/media-hub';
  static const String groupMediaHubName = 'groupMediaHub';

  /// 生成群媒体中心路径
  static String groupMediaHubPath(String roomId) =>
      '/group/${Uri.encodeComponent(roomId)}/media-hub';

  /// 实时位置
  static const String liveLocation = '/chat/:roomId/live-location';
  static const String liveLocationName = 'liveLocation';

  /// 生成实时位置路径
  static String liveLocationPath(String roomId) =>
      '/chat/${Uri.encodeComponent(roomId)}/live-location';

  // ============================================
  // 设置子页面
  // ============================================

  /// 存储管理
  static const String storageManagement = '/settings/storage';
  static const String storageManagementName = 'storageManagement';

  /// 聊天背景
  static const String chatBackground = '/settings/chat-background';
  static const String chatBackgroundName = 'chatBackground';

  /// 自动下载设置
  static const String autoDownload = '/settings/auto-download';
  static const String autoDownloadName = 'autoDownload';

  // ============================================
  // 其他
  // ============================================

  /// 二维码扫描
  static const String qrScanner = '/qr/scan';
  static const String qrScannerName = 'qrScanner';

  /// 我的二维码
  static const String myQrCode = '/qr/my';
  static const String myQrCodeName = 'myQrCode';

  // ============================================
  // AI 助手
  // ============================================

  /// AI 助手页面
  static const String aiAssistant = '/ai-assistant';
  static const String aiAssistantName = 'aiAssistant';

  /// AI 助手设置
  static const String aiAssistantSettings = '/ai-assistant/settings';
  static const String aiAssistantSettingsName = 'aiAssistantSettings';

  // ============================================
  // 聊天文件夹
  // ============================================

  /// 聊天文件夹管理
  static const String chatFolderManagement = '/settings/chat-folders';
  static const String chatFolderManagementName = 'chatFolderManagement';
}

