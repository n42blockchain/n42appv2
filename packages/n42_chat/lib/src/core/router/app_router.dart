import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/encryption/utils/key_verification.dart' as kv;

import '../../../l10n/app_localizations.dart';
import '../../n42_chat.dart';
import '../di/injection.dart';
import '../encryption/e2ee_manager.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../presentation/blocs/chat/chat_bloc.dart';
import '../../presentation/blocs/contact/contact_bloc.dart';
import '../../presentation/pages/ai/ai_assistant_page.dart';
import '../../presentation/pages/ai/ai_assistant_settings_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/welcome_page.dart';
import '../../presentation/pages/chat/live_location_page.dart';
import '../../presentation/pages/chat/thread_detail_page.dart';
import '../../presentation/pages/chat/chat_export_page.dart';
import '../../presentation/pages/chat/viewers/image_viewer_page.dart';
import '../../presentation/pages/chat/viewers/pdf_viewer_page.dart';
import '../../presentation/pages/chat/viewers/video_player_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/chat/chat_folder_management_page.dart';
import '../../presentation/pages/chat/chat_page.dart';
import '../../presentation/pages/contact/add_friend_page.dart';
import '../../presentation/pages/contact/contact_detail_page.dart';
import '../../presentation/pages/contact/contact_list_page.dart';
import '../../presentation/pages/conversation/conversation_list_page.dart';
import '../../presentation/pages/discover/discover_page.dart';
import '../../presentation/pages/group/create_group_page.dart';
import '../../presentation/pages/group/group_media_hub_page.dart';
import '../../presentation/pages/group/group_members_page.dart';
import '../../presentation/pages/group/group_settings_page.dart';
import '../../presentation/pages/media/media_gallery_page.dart';
import '../../presentation/pages/media/media_preview_page.dart';
import '../../presentation/pages/qrcode/my_qrcode_page.dart';
import '../../presentation/pages/qrcode/scan_qr_page.dart';
import '../../presentation/pages/group/token_gate_settings_page.dart';
import '../../presentation/pages/group/token_gate_verify_page.dart';
import '../../presentation/pages/profile/profile_edit_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/profile/set_username_page.dart';
import '../../presentation/pages/search/global_search_page.dart';
import '../../presentation/pages/search/chat_search_page.dart';
import '../../presentation/pages/security/sas_verification_page.dart';
import '../../presentation/pages/settings/auto_download_settings_page.dart';
import '../../presentation/pages/settings/chat_background_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/settings/storage_management_page.dart';
import '../../presentation/pages/space/space_detail_page.dart';
import '../../presentation/pages/space/space_list_page.dart';
import '../../presentation/pages/voice_room/voice_room_list_page.dart';
import '../../presentation/pages/voice_room/voice_room_page.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/token_gate_entity.dart';
import '../../presentation/blocs/group/group_bloc.dart';
import '../../presentation/blocs/search/search_bloc.dart';
import '../../presentation/blocs/space/space_bloc.dart';
import '../../presentation/blocs/voice_room/voice_room_bloc.dart';
import '../../presentation/blocs/voice_room/voice_room_event.dart';
import '../../domain/repositories/voice_room_repository.dart';
import '../../services/voip/voice_room_service.dart';
import 'routes.dart';

/// N42 Chat 路由配置
///
/// 提供两种使用方式：
/// 1. 独立运行：使用 [router] 作为完整的路由配置
/// 2. 嵌入主应用：使用 [routes] 获取路由列表合并到主路由
class N42ChatRouter {
  N42ChatRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _router;
  static bool _debugLogDiagnosticsEnabled = false;

  /// 获取完整的路由器（独立运行模式）
  ///
  /// 使用懒加载单例模式，避免每次访问创建新实例导致路由状态丢失。
  static GoRouter get router => _router ??= GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.conversationList,
    debugLogDiagnostics: debugLogDiagnosticsEnabled,
    routes: routes,
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
    redirect: _handleRedirect,
  );

  static bool get debugLogDiagnosticsEnabled => _debugLogDiagnosticsEnabled;

  static void configure({required bool enableDebugLogs}) {
    final shouldResetRouter = _debugLogDiagnosticsEnabled != enableDebugLogs;
    _debugLogDiagnosticsEnabled = enableDebugLogs;
    if (shouldResetRouter) {
      reset(preserveDebugLogging: true);
    }
  }

  static void reset({bool preserveDebugLogging = false}) {
    _router?.dispose();
    _router = null;
    if (!preserveDebugLogging) {
      _debugLogDiagnosticsEnabled = false;
    }
  }

  /// 获取路由列表（嵌入模式）
  ///
  /// 可以合并到主应用的路由配置中
  ///
  /// ```dart
  /// GoRouter(
  ///   routes: [
  ///     ...myAppRoutes,
  ///     ...N42ChatRouter.routes,
  ///   ],
  /// )
  /// ```
  static List<RouteBase> get routes => [
    // 会话列表（聊天Tab主页）
    GoRoute(
      path: Routes.conversationList,
      name: Routes.conversationListName,
      builder: (context, state) => const ConversationListPage(),
      routes: [
        // 会话详情
        GoRoute(
          path: 'conversation/:roomId',
          name: Routes.chatName,
          builder: (context, state) {
            final roomId = state.pathParameters['roomId']!;
            final conversation = state.extra as ConversationEntity?;
            return _ChatPageLoader(roomId: roomId, conversation: conversation);
          },
        ),
      ],
    ),

    // 通讯录
    GoRoute(
      path: Routes.contacts,
      name: Routes.contactsName,
      builder: (context, state) => const ContactListPage(),
      routes: [
        // 联系人详情
        GoRoute(
          path: 'detail/:userId',
          name: Routes.contactDetailName,
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return ContactDetailPage(
              userId: userId,
              displayName: extra?['displayName'] as String? ?? userId,
              avatarUrl: extra?['avatarUrl'] as String?,
            );
          },
        ),
        // 添加联系人
        GoRoute(
          path: 'add',
          name: Routes.addContactName,
          builder: (context, state) => const AddFriendPage(),
        ),
      ],
    ),

    // 发现
    GoRoute(
      path: Routes.discover,
      name: Routes.discoverName,
      builder: (context, state) => const DiscoverPage(),
    ),

    // 个人中心
    GoRoute(
      path: Routes.profile,
      name: Routes.profileName,
      builder: (context, state) => const ProfilePage(),
      routes: [
        // 设置
        GoRoute(
          path: 'settings',
          name: Routes.settingsName,
          builder: (context, state) => const SettingsPage(),
        ),
        // 编辑资料
        GoRoute(
          path: 'edit',
          name: Routes.editProfileName,
          builder: (context, state) => BlocProvider.value(
            value: N42Chat.authBloc,
            child: const ProfileEditPage(),
          ),
        ),
        // 设置用户名
        GoRoute(
          path: 'username',
          name: Routes.setUsernameName,
          builder: (context, state) => const SetUsernamePage(),
        ),
      ],
    ),

    // 登录
    GoRoute(
      path: Routes.login,
      name: Routes.loginName,
      builder: (context, state) => const LoginPage(),
    ),

    // 注册
    GoRoute(
      path: Routes.register,
      name: Routes.registerName,
      builder: (context, state) => BlocProvider.value(
        value: N42Chat.authBloc,
        child: const RegisterPage(),
      ),
    ),

    // 欢迎页
    GoRoute(
      path: Routes.welcome,
      name: Routes.welcomeName,
      builder: (context, state) => WelcomePage(
        onLogin: () => context.push(Routes.login),
        onRegister: () => context.push(Routes.register),
      ),
    ),

    // 搜索
    GoRoute(
      path: Routes.search,
      name: Routes.searchName,
      builder: (context, state) => const GlobalSearchPage(),
    ),

    // 聊天内搜索
    GoRoute(
      path: Routes.chatSearch,
      name: Routes.chatSearchName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return BlocProvider(
          create: (_) => getIt<SearchBloc>(),
          child: ChatSearchPage(roomId: roomId),
        );
      },
    ),

    // 图片预览
    GoRoute(
      path: Routes.imagePreview,
      name: Routes.imagePreviewName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final imageUrl = extra?['imageUrl'] as String?;
        if (imageUrl == null || imageUrl.isEmpty) {
          return _ErrorPage(error: Exception('Missing imageUrl'));
        }
        return ImageViewerPage(
          imageUrl: imageUrl,
          heroTag: extra?['heroTag'] as String? ?? imageUrl,
        );
      },
    ),

    // 视频播放
    GoRoute(
      path: Routes.videoPlayer,
      name: Routes.videoPlayerName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final videoUrl = extra?['videoUrl'] as String?;
        if (videoUrl == null || videoUrl.isEmpty) {
          return _ErrorPage(error: Exception('Missing videoUrl'));
        }
        return VideoPlayerPage(
          videoUrl: videoUrl,
          thumbnailUrl: extra?['thumbnailUrl'] as String?,
        );
      },
    ),

    // 媒体预览
    GoRoute(
      path: Routes.mediaPreview,
      name: Routes.mediaPreviewName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final items = extra?['items'] as List<MediaItem>?;
        if (items == null || items.isEmpty) {
          return _ErrorPage(error: Exception('Missing media preview items'));
        }
        return MediaPreviewPage(
          items: items,
          initialIndex: extra?['initialIndex'] as int? ?? 0,
        );
      },
    ),

    // PDF 预览
    GoRoute(
      path: Routes.pdfViewer,
      name: Routes.pdfViewerName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final filePath = extra?['filePath'] as String?;
        final url = extra?['url'] as String?;
        final fileName = extra?['fileName'] as String?;
        if ((filePath == null || filePath.isEmpty) &&
            (url == null || url.isEmpty)) {
          return _ErrorPage(
            error: Exception('Missing filePath/url for PDF preview'),
          );
        }
        if (fileName == null || fileName.isEmpty) {
          return _ErrorPage(error: Exception('Missing fileName'));
        }
        return PdfViewerPage(
          filePath: filePath,
          url: url,
          fileName: fileName,
          headers: extra?['headers'] as Map<String, String>?,
        );
      },
    ),

    // SAS 安全验证
    GoRoute(
      path: Routes.sasVerification,
      name: Routes.sasVerificationName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final e2eeManager = extra?['e2eeManager'] as E2EEManager?;
        final userId = extra?['userId'] as String?;
        if (e2eeManager == null || userId == null || userId.isEmpty) {
          return _ErrorPage(
            error: Exception('Missing e2eeManager/userId for SAS verification'),
          );
        }
        return SasVerificationPage(
          e2eeManager: e2eeManager,
          userId: userId,
          deviceId: extra?['deviceId'] as String?,
          deviceName: extra?['deviceName'] as String?,
          incomingVerification:
              extra?['incomingVerification'] as kv.KeyVerification?,
        );
      },
    ),

    // 创建群聊
    GoRoute(
      path: Routes.createGroup,
      name: Routes.createGroupName,
      builder: (context, state) => const CreateGroupPage(),
    ),

    // 群资料
    GoRoute(
      path: Routes.groupInfo,
      name: Routes.groupInfoName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return BlocProvider(
          create: (_) => getIt<GroupBloc>(),
          child: GroupSettingsPage(roomId: roomId),
        );
      },
    ),

    // 群成员
    GoRoute(
      path: Routes.groupMembers,
      name: Routes.groupMembersName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return BlocProvider(
          create: (_) => getIt<GroupBloc>(),
          child: GroupMembersPage(roomId: roomId),
        );
      },
    ),

    // 代币门控设置
    GoRoute(
      path: Routes.tokenGateSettings,
      name: Routes.tokenGateSettingsName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        final config = state.extra as TokenGateConfig?;
        return BlocProvider(
          create: (_) => getIt<GroupBloc>(),
          child: TokenGateSettingsPage(roomId: roomId, currentConfig: config),
        );
      },
    ),

    // 代币门控验证
    GoRoute(
      path: Routes.tokenGateVerify,
      name: Routes.tokenGateVerifyName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        final config = state.extra as TokenGateConfig?;
        if (config == null) {
          return _ErrorPage(
            error: Exception('Missing token gate config for $roomId'),
          );
        }
        return BlocProvider(
          create: (_) => getIt<GroupBloc>(),
          child: TokenGateVerifyPage(roomId: roomId, config: config),
        );
      },
    ),

    // AI 助手
    GoRoute(
      path: Routes.aiAssistant,
      name: Routes.aiAssistantName,
      builder: (context, state) => const AiAssistantPage(),
      routes: [
        GoRoute(
          path: 'settings',
          name: Routes.aiAssistantSettingsName,
          builder: (context, state) => const AiAssistantSettingsPage(),
        ),
      ],
    ),

    // 聊天文件夹管理
    GoRoute(
      path: Routes.chatFolderManagement,
      name: Routes.chatFolderManagementName,
      builder: (context, state) => const ChatFolderManagementPage(),
    ),

    // Space 列表
    GoRoute(
      path: Routes.spaceList,
      name: Routes.spaceListName,
      builder: (context, state) => const SpaceListPage(),
    ),

    // Space 详情
    GoRoute(
      path: Routes.spaceDetail,
      name: Routes.spaceDetailName,
      builder: (context, state) {
        final spaceId = state.pathParameters['spaceId']!;
        return BlocProvider(
          create: (_) => getIt<SpaceBloc>(),
          child: SpaceDetailPage(spaceId: spaceId),
        );
      },
    ),

    // 群媒体中心
    GoRoute(
      path: Routes.groupMediaHub,
      name: Routes.groupMediaHubName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        final groupName = state.extra as String? ?? roomId;
        return GroupMediaHubPage(roomId: roomId, groupName: groupName);
      },
    ),

    // 媒体画廊
    GoRoute(
      path: Routes.mediaGallery,
      name: Routes.mediaGalleryName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return MediaGalleryPage(
          roomId: roomId,
          roomName: extra?['roomName'] as String? ?? roomId,
          mediaMessages:
              extra?['mediaMessages'] as List<MessageEntity>? ??
              const <MessageEntity>[],
        );
      },
    ),

    // 实时位置
    GoRoute(
      path: Routes.liveLocation,
      name: Routes.liveLocationName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return LiveLocationPage(roomId: roomId);
      },
    ),

    // 线程详情
    GoRoute(
      path: Routes.threadDetail,
      name: Routes.threadDetailName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        final threadRootEventId = state.pathParameters['threadRootEventId']!;
        return ThreadDetailPage(
          roomId: roomId,
          threadRootEventId: threadRootEventId,
        );
      },
    ),

    // 聊天记录导出
    GoRoute(
      path: Routes.chatExport,
      name: Routes.chatExportName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return ChatExportPage(
          roomId: roomId,
          roomName: extra?['roomName'] as String? ?? roomId,
          messages:
              extra?['messages'] as List<MessageEntity>? ??
              const <MessageEntity>[],
        );
      },
    ),

    // 存储管理
    GoRoute(
      path: Routes.storageManagement,
      name: Routes.storageManagementName,
      builder: (context, state) => const StorageManagementPage(),
    ),

    // 聊天背景
    GoRoute(
      path: Routes.chatBackground,
      name: Routes.chatBackgroundName,
      builder: (context, state) => const ChatBackgroundPage(),
    ),

    // 自动下载
    GoRoute(
      path: Routes.autoDownload,
      name: Routes.autoDownloadName,
      builder: (context, state) => const AutoDownloadSettingsPage(),
    ),

    // 扫码
    GoRoute(
      path: Routes.qrScanner,
      name: Routes.qrScannerName,
      builder: (context, state) => const ScanQRPage(),
    ),

    // 我的二维码
    GoRoute(
      path: Routes.myQrCode,
      name: Routes.myQrCodeName,
      builder: (context, state) => const MyQRCodePage(),
    ),

    // 语音房间列表
    GoRoute(
      path: Routes.voiceRoomList,
      name: Routes.voiceRoomListName,
      builder: (context, state) => const VoiceRoomListPage(),
    ),

    // 语音房间详情
    GoRoute(
      path: Routes.voiceRoom,
      name: Routes.voiceRoomName,
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return BlocProvider(
          create: (_) => VoiceRoomBloc(
            repository: getIt<IVoiceRoomRepository>(),
            voiceRoomService: getIt<VoiceRoomService>(),
          )..add(JoinVoiceRoom(roomId)),
          child: VoiceRoomPage(roomId: roomId),
        );
      },
    ),
  ];

  /// 路由重定向（auth guard）
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = N42Chat.isLoggedIn;
    final isAuthRoute =
        state.matchedLocation == Routes.login ||
        state.matchedLocation == Routes.register ||
        state.matchedLocation == Routes.welcome;

    if (!isLoggedIn && !isAuthRoute) {
      return Routes.login;
    }

    if (isLoggedIn && isAuthRoute) {
      return Routes.conversationList;
    }

    return null;
  }

  /// 微信风格页面转场
  static CustomTransitionPage<T> wechatTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

/// ChatPage 需要 ConversationEntity，此 loader 从 roomId 异步加载
class _ChatPageLoader extends StatefulWidget {
  final String roomId;
  final ConversationEntity? conversation;

  const _ChatPageLoader({required this.roomId, this.conversation});

  @override
  State<_ChatPageLoader> createState() => _ChatPageLoaderState();
}

class _ChatPageLoaderState extends State<_ChatPageLoader> {
  ConversationEntity? _conversation;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.conversation != null) {
      _conversation = widget.conversation;
      _loading = false;
    } else {
      _loadConversation();
    }
  }

  Future<void> _loadConversation() async {
    try {
      final repo = getIt<IConversationRepository>();
      final conv = await repo.getConversationById(widget.roomId);
      if (!mounted) return;
      if (conv == null) {
        setState(() {
          _error = 'Conversation not found: ${widget.roomId}';
          _loading = false;
        });
      } else {
        setState(() {
          _conversation = conv;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error ?? 'Unknown error')),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ChatBloc>()),
        BlocProvider(create: (_) => getIt<ContactBloc>()),
      ],
      child: ChatPage(
        conversation: _conversation!,
        onBack: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// 错误页面
class _ErrorPage extends StatelessWidget {
  final Exception? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.chatError ?? 'Error'),
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: const Color(0xFF181818),
      ),
      backgroundColor: const Color(0xFFEDEDED),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFFA5151)),
            const SizedBox(height: 16),
            Text(
              l10n?.commonPageNotFound ?? 'Page not found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF181818),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.conversationList),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B6CFF),
              ),
              child: Text(l10n?.commonBackToHome ?? 'Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
