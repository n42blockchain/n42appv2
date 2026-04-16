#!/bin/bash

# N42 Matrix Chat 项目初始化脚本
# 用于快速创建项目基础结构

set -e

echo "🚀 N42 Matrix Chat 项目初始化"
echo "================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查Flutter环境
check_flutter() {
    echo -e "${YELLOW}检查Flutter环境...${NC}"
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}错误: 未找到Flutter SDK${NC}"
        echo "请先安装Flutter: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    flutter --version
    echo -e "${GREEN}✓ Flutter环境正常${NC}"
}

# 创建项目结构
create_structure() {
    echo -e "\n${YELLOW}创建项目目录结构...${NC}"
    
    # 如果已存在n42_chat目录，询问是否覆盖
    if [ -d "n42_chat" ]; then
        echo -e "${RED}警告: n42_chat目录已存在${NC}"
        read -p "是否删除并重新创建? (y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo "取消操作"
            exit 0
        fi
        rm -rf n42_chat
    fi
    
    # 创建Flutter package
    flutter create --template=package n42_chat
    cd n42_chat
    
    # 创建src目录结构
    mkdir -p lib/src/core/{di,router,theme,utils,constants,extensions}
    mkdir -p lib/src/data/{datasources/{local,matrix},models,repositories}
    mkdir -p lib/src/domain/{entities,repositories,usecases}
    mkdir -p lib/src/presentation/{pages,widgets,blocs}
    mkdir -p lib/src/integration
    
    # 创建子目录
    mkdir -p lib/src/presentation/pages/{auth,conversation,chat,contacts,discover,profile,group,search}
    mkdir -p lib/src/presentation/widgets/{common,chat,contacts,profile,animations,gestures}
    mkdir -p lib/src/presentation/blocs/{auth,conversation_list,chat,contacts,profile,search}
    
    mkdir -p lib/src/domain/usecases/{auth,conversation,message,contact,group,profile,search}
    
    mkdir -p lib/src/data/datasources/local/database/tables
    
    # 创建example目录结构
    mkdir -p example/lib/{pages,mock}
    
    # 创建test目录结构
    mkdir -p test/{domain/usecases,data/repositories,presentation/{blocs,widgets,pages},mocks}
    
    echo -e "${GREEN}✓ 目录结构创建完成${NC}"
}

# 创建pubspec.yaml
create_pubspec() {
    echo -e "\n${YELLOW}创建pubspec.yaml...${NC}"
    
    cat > pubspec.yaml << 'EOF'
name: n42_chat
description: A Matrix-based chat module with WeChat-style UI for N42 Wallet integration.
version: 0.1.0
homepage: https://github.com/n42/n42_chat

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Matrix Protocol (Apache 2.0)
  matrix: ^0.24.0
  
  # State Management (MIT)
  flutter_bloc: ^8.1.0
  bloc: ^8.1.0
  
  # Dependency Injection (MIT)
  get_it: ^7.6.0
  injectable: ^2.3.0
  
  # Routing (BSD-3)
  go_router: ^13.0.0
  
  # Local Storage (MIT/BSD-3)
  drift: ^2.15.0
  sqflite: ^2.3.0
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.0
  path: ^1.8.0
  
  # Network (MIT)
  dio: ^5.4.0
  
  # UI Components (MIT/BSD-3)
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_slidable: ^3.0.0
  pull_to_refresh: ^2.0.0
  
  # Image & Media
  image_picker: ^1.0.0
  photo_view: ^0.14.0
  
  # Utils (MIT/BSD-3)
  equatable: ^2.0.5
  json_annotation: ^4.8.0
  intl: ^0.18.0
  uuid: ^4.2.0
  collection: ^1.18.0
  rxdart: ^0.27.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
  injectable_generator: ^2.4.0
  drift_dev: ^2.15.0
  mockito: ^5.4.0
  bloc_test: ^9.1.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
EOF

    echo -e "${GREEN}✓ pubspec.yaml创建完成${NC}"
}

# 创建analysis_options.yaml
create_analysis_options() {
    echo -e "\n${YELLOW}创建analysis_options.yaml...${NC}"
    
    cat > analysis_options.yaml << 'EOF'
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - avoid_types_as_parameter_names
    - avoid_unused_constructor_parameters
    - await_only_futures
    - camel_case_extensions
    - camel_case_types
    - cancel_subscriptions
    - close_sinks
    - constant_identifier_names
    - curly_braces_in_flow_control_structures
    - empty_catches
    - file_names
    - hash_and_equals
    - no_duplicate_case_values
    - non_constant_identifier_names
    - null_closures
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_in_for_each
    - prefer_final_locals
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_single_quotes
    - sort_child_properties_last
    - type_init_formals
    - unawaited_futures
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_new
    - unnecessary_null_in_if_null_operators
    - unnecessary_this
    - use_key_in_widget_constructors
EOF

    echo -e "${GREEN}✓ analysis_options.yaml创建完成${NC}"
}

# 创建主入口文件
create_main_entry() {
    echo -e "\n${YELLOW}创建主入口文件...${NC}"
    
    cat > lib/n42_chat.dart << 'EOF'
/// N42 Matrix Chat - A WeChat-style Matrix client for N42 Wallet
///
/// This library provides a complete chat solution based on the Matrix protocol,
/// designed to be embedded in the N42 Wallet app or run as a standalone application.
library n42_chat;

// Core exports
export 'src/n42_chat.dart';
export 'src/n42_chat_config.dart';
export 'src/core/theme/n42_chat_theme.dart';

// Entity exports (for external use)
export 'src/domain/entities/conversation_entity.dart';
export 'src/domain/entities/message_entity.dart';
export 'src/domain/entities/contact_entity.dart';

// Integration exports
export 'src/integration/wallet_bridge.dart';
EOF

    # 创建N42Chat主类占位
    cat > lib/src/n42_chat.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'n42_chat_config.dart';

/// Main entry point for N42 Chat module
class N42Chat {
  static bool _initialized = false;
  static N42ChatConfig? _config;

  /// Initialize the chat module
  static Future<void> initialize(N42ChatConfig config) async {
    if (_initialized) return;
    _config = config;
    // TODO: Initialize dependencies, Matrix client, etc.
    _initialized = true;
  }

  /// Get the main chat widget for embedding in TabView
  static Widget chatWidget() {
    _ensureInitialized();
    // TODO: Return ConversationListPage wrapped with necessary providers
    return const Placeholder();
  }

  /// Get routes for integration with main app router
  static List<RouteBase> routes() {
    _ensureInitialized();
    // TODO: Return chat-related routes
    return [];
  }

  /// Login with username and password
  static Future<void> login({
    required String homeserver,
    required String username,
    required String password,
  }) async {
    _ensureInitialized();
    // TODO: Implement Matrix login
  }

  /// Login with existing token
  static Future<void> loginWithToken({
    required String homeserver,
    required String accessToken,
    required String userId,
    required String deviceId,
  }) async {
    _ensureInitialized();
    // TODO: Implement token-based login
  }

  /// Logout current user
  static Future<void> logout() async {
    _ensureInitialized();
    // TODO: Implement logout
  }

  /// Check if user is logged in
  static bool get isLoggedIn {
    _ensureInitialized();
    // TODO: Check Matrix client login status
    return false;
  }

  /// Stream of unread message count
  static Stream<int> get unreadCountStream {
    _ensureInitialized();
    // TODO: Return stream from Matrix client
    return const Stream.empty();
  }

  /// Open a specific conversation
  static void openConversation(String roomId) {
    _ensureInitialized();
    // TODO: Navigate to conversation
  }

  /// Create a direct message conversation
  static Future<String> createDirectMessage(String userId) async {
    _ensureInitialized();
    // TODO: Create DM room via Matrix
    return '';
  }

  /// Dispose resources
  static Future<void> dispose() async {
    if (!_initialized) return;
    // TODO: Clean up resources
    _initialized = false;
    _config = null;
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('N42Chat has not been initialized. Call N42Chat.initialize() first.');
    }
  }
}
EOF

    # 创建配置类
    cat > lib/src/n42_chat_config.dart << 'EOF'
import 'package:flutter/material.dart';
import 'core/theme/n42_chat_theme.dart';

/// Configuration for N42 Chat module
class N42ChatConfig {
  /// Default Matrix homeserver URL
  final String defaultHomeserver;

  /// Enable end-to-end encryption
  final bool enableEncryption;

  /// Enable push notifications
  final bool enablePushNotifications;

  /// Sync timeout duration
  final Duration syncTimeout;

  /// Custom theme (optional)
  final N42ChatTheme? customTheme;

  /// Callback when a message is tapped
  final void Function(String roomId, String eventId)? onMessageTap;

  /// Callback when wallet transfer is requested
  final Future<bool> Function(String toAddress, String amount, String token)? onTransferRequest;

  const N42ChatConfig({
    this.defaultHomeserver = 'https://matrix.org',
    this.enableEncryption = true,
    this.enablePushNotifications = true,
    this.syncTimeout = const Duration(seconds: 30),
    this.customTheme,
    this.onMessageTap,
    this.onTransferRequest,
  });
}
EOF

    echo -e "${GREEN}✓ 主入口文件创建完成${NC}"
}

# 创建主题文件
create_theme_files() {
    echo -e "\n${YELLOW}创建主题文件...${NC}"
    
    # 创建颜色常量
    cat > lib/src/core/theme/app_colors.dart << 'EOF'
import 'package:flutter/material.dart';

/// WeChat-style color palette
abstract class AppColors {
  // Primary colors (WeChat Green)
  static const Color primary = Color(0xFF07C160);
  static const Color primaryLight = Color(0xFF4CD964);
  static const Color primaryDark = Color(0xFF06AD56);

  // Background colors
  static const Color background = Color(0xFFEDEDED);
  static const Color backgroundDark = Color(0xFF111111);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Navigation bar
  static const Color navBar = Color(0xFFF7F7F7);
  static const Color navBarDark = Color(0xFF2C2C2C);

  // Dividers
  static const Color divider = Color(0xFFE5E5E5);
  static const Color dividerDark = Color(0xFF3D3D3D);

  // Text colors
  static const Color textPrimary = Color(0xFF181818);
  static const Color textPrimaryDark = Color(0xFFE5E5E5);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textTertiary = Color(0xFFB2B2B2);

  // Message bubbles
  static const Color messageSent = Color(0xFF95EC69);
  static const Color messageReceived = Color(0xFFFFFFFF);
  static const Color messageSentDark = Color(0xFF3EB575);
  static const Color messageReceivedDark = Color(0xFF2C2C2C);

  // Status colors
  static const Color error = Color(0xFFFA5151);
  static const Color warning = Color(0xFFFF9900);
  static const Color success = Color(0xFF07C160);
  static const Color info = Color(0xFF10AEFF);

  // Badge
  static const Color badge = Color(0xFFFA5151);

  // Overlay
  static const Color overlay = Color(0x80000000);
}
EOF

    # 创建主题类
    cat > lib/src/core/theme/n42_chat_theme.dart << 'EOF'
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Customizable theme for N42 Chat
class N42ChatTheme {
  final Color primaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color messageBubbleSentColor;
  final Color messageBubbleReceivedColor;
  final Color dividerColor;
  final Color navBarColor;
  final double avatarRadius;
  final double messageBubbleRadius;
  final TextStyle? titleTextStyle;
  final TextStyle? bodyTextStyle;
  final TextStyle? captionTextStyle;

  const N42ChatTheme({
    required this.primaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.messageBubbleSentColor,
    required this.messageBubbleReceivedColor,
    required this.dividerColor,
    required this.navBarColor,
    this.avatarRadius = 4.0,
    this.messageBubbleRadius = 4.0,
    this.titleTextStyle,
    this.bodyTextStyle,
    this.captionTextStyle,
  });

  /// WeChat light theme preset
  static N42ChatTheme wechatLight() => const N42ChatTheme(
        primaryColor: AppColors.primary,
        backgroundColor: AppColors.background,
        surfaceColor: AppColors.surface,
        textPrimaryColor: AppColors.textPrimary,
        textSecondaryColor: AppColors.textSecondary,
        messageBubbleSentColor: AppColors.messageSent,
        messageBubbleReceivedColor: AppColors.messageReceived,
        dividerColor: AppColors.divider,
        navBarColor: AppColors.navBar,
      );

  /// WeChat dark theme preset
  static N2ChatTheme wechatDark() => const N42ChatTheme(
        primaryColor: AppColors.primary,
        backgroundColor: AppColors.backgroundDark,
        surfaceColor: AppColors.surfaceDark,
        textPrimaryColor: AppColors.textPrimaryDark,
        textSecondaryColor: AppColors.textSecondary,
        messageBubbleSentColor: AppColors.messageSentDark,
        messageBubbleReceivedColor: AppColors.messageReceivedDark,
        dividerColor: AppColors.dividerDark,
        navBarColor: AppColors.navBarDark,
      );

  /// Generate theme from Material ThemeData
  static N42ChatTheme fromMaterialTheme(ThemeData theme) => N42ChatTheme(
        primaryColor: theme.primaryColor,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceColor: theme.cardColor,
        textPrimaryColor: theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary,
        textSecondaryColor: theme.textTheme.bodySmall?.color ?? AppColors.textSecondary,
        messageBubbleSentColor: theme.primaryColor.withOpacity(0.3),
        messageBubbleReceivedColor: theme.cardColor,
        dividerColor: theme.dividerColor,
        navBarColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
      );
}

// Fix typo alias
typedef N2ChatTheme = N42ChatTheme;
EOF

    echo -e "${GREEN}✓ 主题文件创建完成${NC}"
}

# 创建实体占位文件
create_entity_files() {
    echo -e "\n${YELLOW}创建实体文件占位...${NC}"
    
    cat > lib/src/domain/entities/conversation_entity.dart << 'EOF'
import 'package:equatable/equatable.dart';

/// Represents a conversation (chat room)
class ConversationEntity extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isDirect;
  final bool isEncrypted;
  final bool isPinned;
  final bool isMuted;

  const ConversationEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isDirect = true,
    this.isEncrypted = false,
    this.isPinned = false,
    this.isMuted = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        lastMessage,
        lastMessageTime,
        unreadCount,
        isDirect,
        isEncrypted,
        isPinned,
        isMuted,
      ];

  ConversationEntity copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isDirect,
    bool? isEncrypted,
    bool? isPinned,
    bool? isMuted,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isDirect: isDirect ?? this.isDirect,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}
EOF

    cat > lib/src/domain/entities/message_entity.dart << 'EOF'
import 'package:equatable/equatable.dart';

enum MessageType { text, image, voice, video, file, location, system }

enum MessageStatus { sending, sent, delivered, read, failed }

/// Represents a message in a conversation
class MessageEntity extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? replyToId;
  final Map<String, dynamic>? metadata;

  const MessageEntity({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.replyToId,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        senderId,
        senderName,
        senderAvatarUrl,
        content,
        type,
        timestamp,
        status,
        replyToId,
        metadata,
      ];

  bool get isFromMe => false; // TODO: Compare with current user ID
}
EOF

    cat > lib/src/domain/entities/contact_entity.dart << 'EOF'
import 'package:equatable/equatable.dart';

enum PresenceStatus { online, offline, unavailable }

/// Represents a contact (Matrix user)
class ContactEntity extends Equatable {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final PresenceStatus presence;
  final DateTime? lastActiveTime;
  final String? statusMessage;

  const ContactEntity({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.presence = PresenceStatus.offline,
    this.lastActiveTime,
    this.statusMessage,
  });

  @override
  List<Object?> get props => [
        userId,
        displayName,
        avatarUrl,
        presence,
        lastActiveTime,
        statusMessage,
      ];

  /// Get first letter for index grouping
  String get indexLetter {
    if (displayName.isEmpty) return '#';
    final first = displayName[0].toUpperCase();
    if (RegExp(r'[A-Z]').hasMatch(first)) return first;
    return '#';
  }
}
EOF

    echo -e "${GREEN}✓ 实体文件创建完成${NC}"
}

# 创建钱包集成接口
create_wallet_bridge() {
    echo -e "\n${YELLOW}创建钱包集成接口...${NC}"
    
    cat > lib/src/integration/wallet_bridge.dart << 'EOF'
/// Abstract interface for wallet integration
/// 
/// Implement this interface in your main app to enable
/// cryptocurrency transfer features in chat.
abstract class IWalletBridge {
  /// Whether wallet is connected
  bool get isWalletConnected;

  /// Current wallet address
  String? get walletAddress;

  /// Request a transfer to another address
  Future<TransferResult> requestTransfer({
    required String toAddress,
    required String amount,
    required String token,
    String? memo,
  });

  /// Generate a payment request
  Future<PaymentRequest> generatePaymentRequest({
    required String amount,
    required String token,
    String? memo,
  });

  /// Show QR code for receiving payment
  Future<void> showReceiveQRCode();

  /// Get balance for a specific token
  Future<String> getBalance(String token);
}

/// Result of a transfer operation
class TransferResult {
  final bool success;
  final String? transactionHash;
  final String? errorMessage;

  const TransferResult({
    required this.success,
    this.transactionHash,
    this.errorMessage,
  });

  factory TransferResult.success(String txHash) => TransferResult(
        success: true,
        transactionHash: txHash,
      );

  factory TransferResult.failure(String error) => TransferResult(
        success: false,
        errorMessage: error,
      );
}

/// Payment request data
class PaymentRequest {
  final String requestId;
  final String amount;
  final String token;
  final String? memo;
  final String qrCodeData;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const PaymentRequest({
    required this.requestId,
    required this.amount,
    required this.token,
    this.memo,
    required this.qrCodeData,
    required this.createdAt,
    this.expiresAt,
  });
}
EOF

    echo -e "${GREEN}✓ 钱包集成接口创建完成${NC}"
}

# 创建example应用
create_example_app() {
    echo -e "\n${YELLOW}创建example应用...${NC}"
    
    # 更新example pubspec.yaml
    cat > example/pubspec.yaml << 'EOF'
name: n42_chat_example
description: Example app demonstrating N42 Chat integration.
publish_to: 'none'
version: 1.0.0

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  n42_chat:
    path: ../
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
EOF

    # 创建example main.dart
    cat > example/lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:n42_chat/n42_chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize N42 Chat
  await N42Chat.initialize(const N42ChatConfig(
    defaultHomeserver: 'https://matrix.org',
    enableEncryption: true,
  ));
  
  runApp(const N42ChatExampleApp());
}

class N42ChatExampleApp extends StatelessWidget {
  const N42ChatExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'N42 Chat Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF07C160)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WalletPlaceholder(),
    N42Chat.chatWidget(),
    const DiscoverPlaceholder(),
    const ProfilePlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF07C160),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '钱包',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class WalletPlaceholder extends StatelessWidget {
  const WalletPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('钱包页面 (N42 Wallet)'),
    );
  }
}

class DiscoverPlaceholder extends StatelessWidget {
  const DiscoverPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('发现页面'),
    );
  }
}

class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('我的页面'),
    );
  }
}
EOF

    echo -e "${GREEN}✓ example应用创建完成${NC}"
}

# 创建资源目录
create_assets() {
    echo -e "\n${YELLOW}创建资源目录...${NC}"
    mkdir -p assets/images
    mkdir -p assets/icons
    
    # 创建.gitkeep保持空目录
    touch assets/images/.gitkeep
    touch assets/icons/.gitkeep
    
    echo -e "${GREEN}✓ 资源目录创建完成${NC}"
}

# 创建README
create_readme() {
    echo -e "\n${YELLOW}创建README.md...${NC}"
    
    cat > README.md << 'EOF'
# N42 Matrix Chat

基于Matrix协议的微信风格即时通讯模块，专为N42钱包设计。

## 特性

- 🎨 **微信风格UI** - 熟悉的交互体验
- 🔐 **端对端加密** - Matrix E2EE支持
- 🔌 **插件化设计** - 可独立运行或嵌入主应用
- 💰 **钱包集成** - 支持加密货币转账
- 🌐 **去中心化** - 基于Matrix协议

## 快速开始

### 作为依赖引入

```yaml
dependencies:
  n42_chat:
    path: ../n42_chat
```

### 初始化

```dart
await N42Chat.initialize(const N42ChatConfig(
  defaultHomeserver: 'https://matrix.org',
  enableEncryption: true,
));
```

### 嵌入TabView

```dart
TabBarView(
  children: [
    WalletPage(),
    N42Chat.chatWidget(),  // 聊天Tab
    DiscoverPage(),
    ProfilePage(),
  ],
)
```

## 开发

```bash
# 获取依赖
flutter pub get

# 运行example
cd example && flutter run

# 运行测试
flutter test
```

## 许可证

MIT License - 详见 [LICENSE](LICENSE)

## 开源依赖

本项目使用以下开源库（均为商业友好许可）：

- matrix (Apache 2.0)
- flutter_bloc (MIT)
- get_it (MIT)
- go_router (BSD-3)
- drift (MIT)
- 更多见 pubspec.yaml
EOF

    echo -e "${GREEN}✓ README.md创建完成${NC}"
}

# 主流程
main() {
    check_flutter
    create_structure
    create_pubspec
    create_analysis_options
    create_main_entry
    create_theme_files
    create_entity_files
    create_wallet_bridge
    create_example_app
    create_assets
    create_readme
    
    echo -e "\n${GREEN}================================${NC}"
    echo -e "${GREEN}✓ 项目初始化完成！${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo "下一步："
    echo "1. cd n42_chat"
    echo "2. flutter pub get"
    echo "3. cd example && flutter run"
    echo ""
    echo "然后按照 N42_MATRIX_CHAT_PROMPTS.md 中的提示词继续开发"
}

# 运行主流程
main

