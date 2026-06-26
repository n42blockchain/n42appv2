import 'package:equatable/equatable.dart';

/// Mini App 所需权限
enum MiniAppPermission {
  /// 读取钱包地址（低风险，通常自动授予）
  walletAddress,

  /// 读取余额（需要用户许可）
  walletBalance,

  /// 发起交易（高风险，每次需弹窗确认）
  walletTransaction,

  /// 向当前聊天发送消息
  chatSend,

  /// 读取当前聊天基本信息（房间 ID、名称）
  chatRead,
}

/// Mini App 分类
enum MiniAppCategory {
  defi('DeFi'),
  nft('NFT'),
  commerce('Commerce'),
  games('Games'),
  tools('Tools'),
  social('Social'),
  finance('Finance');

  final String label;
  const MiniAppCategory(this.label);
}

/// Mini App 实体 —— Mini App 的静态描述信息（清单）
class MiniAppEntity extends Equatable {
  /// 唯一标识符
  final String id;

  /// 显示名称
  final String name;

  /// 简短描述
  final String description;

  /// 加载 URL（HTTPS）
  final String url;

  /// 图标 URL 或 asset path
  final String iconUrl;

  /// 分类
  final MiniAppCategory category;

  /// 所需权限列表
  final List<MiniAppPermission> permissions;

  /// 是否内置应用（不可删除）
  final bool isBuiltIn;

  /// 是否推荐展示
  final bool isFeatured;

  /// 开发者名称
  final String? developer;

  /// 用户数量（展示用）
  final int? userCount;

  const MiniAppEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.iconUrl,
    required this.category,
    this.permissions = const [],
    this.isBuiltIn = false,
    this.isFeatured = false,
    this.developer,
    this.userCount,
  });

  @override
  List<Object?> get props => [id, name, url];
}

/// 内置 Mini App 列表
///
/// N42 平台预置的 DApps，展示多链优势（236+ 链）
class BuiltInMiniApps {
  static const List<MiniAppEntity> all = [
    MiniAppEntity(
      id: 'n42_swap',
      name: 'N42 Swap',
      description: 'Swap tokens across 236+ chains with best rates',
      url: 'https://swap.n42.world',
      iconUrl: 'assets/icons/miniapp_swap.png',
      category: MiniAppCategory.defi,
      permissions: [
        MiniAppPermission.walletAddress,
        MiniAppPermission.walletTransaction,
      ],
      isBuiltIn: true,
      isFeatured: true,
      developer: 'N42 Foundation',
      userCount: 50000,
    ),
    MiniAppEntity(
      id: 'n42_bridge',
      name: 'N42 Bridge',
      description: 'Cross-chain asset bridge supporting 236+ networks',
      url: 'https://bridge.n42.world',
      iconUrl: 'assets/icons/miniapp_bridge.png',
      category: MiniAppCategory.defi,
      permissions: [
        MiniAppPermission.walletAddress,
        MiniAppPermission.walletTransaction,
      ],
      isBuiltIn: true,
      isFeatured: true,
      developer: 'N42 Foundation',
      userCount: 32000,
    ),
    MiniAppEntity(
      id: 'n42_nft',
      name: 'NFT Gallery',
      description: 'View and trade NFTs across all supported chains',
      url: 'https://nft.n42.world',
      iconUrl: 'assets/icons/miniapp_nft.png',
      category: MiniAppCategory.nft,
      permissions: [
        MiniAppPermission.walletAddress,
        MiniAppPermission.walletBalance,
      ],
      isBuiltIn: true,
      developer: 'N42 Foundation',
      userCount: 18000,
    ),
    MiniAppEntity(
      id: 'n42_shop',
      name: 'N42 Shop',
      description:
          'Browse token-gated drops, digital goods, and merchant checkouts',
      url: 'https://shop.n42.world',
      iconUrl: 'assets/icons/miniapp_shop.png',
      category: MiniAppCategory.commerce,
      permissions: [
        MiniAppPermission.walletAddress,
        MiniAppPermission.walletTransaction,
      ],
      isBuiltIn: true,
      isFeatured: true,
      developer: 'N42 Commerce',
      userCount: 22000,
    ),
    MiniAppEntity(
      id: 'creator_pass',
      name: 'Creator Pass',
      description: 'Manage paid channel memberships and gated community access',
      url: 'https://creator.n42.world',
      iconUrl: 'assets/icons/miniapp_creator.png',
      category: MiniAppCategory.commerce,
      permissions: [
        MiniAppPermission.walletAddress,
        MiniAppPermission.walletBalance,
        MiniAppPermission.walletTransaction,
      ],
      isBuiltIn: true,
      developer: 'N42 Commerce',
      userCount: 9000,
    ),
    MiniAppEntity(
      id: 'n42_portfolio',
      name: 'Portfolio Tracker',
      description: 'Track assets across 236+ chains in real-time',
      url: 'https://portfolio.n42.world',
      iconUrl: 'assets/icons/miniapp_portfolio.png',
      category: MiniAppCategory.finance,
      permissions: [
        MiniAppPermission.walletAddress,
        MiniAppPermission.walletBalance,
      ],
      isBuiltIn: true,
      developer: 'N42 Foundation',
      userCount: 41000,
    ),
    MiniAppEntity(
      id: 'price_chart',
      name: 'Price Charts',
      description: 'Real-time price charts for 10,000+ tokens',
      url: 'https://charts.n42.world',
      iconUrl: 'assets/icons/miniapp_chart.png',
      category: MiniAppCategory.finance,
      permissions: [],
      isBuiltIn: true,
      developer: 'N42 Foundation',
    ),
  ];

  static List<MiniAppEntity> byCategory(MiniAppCategory category) =>
      all.where((a) => a.category == category).toList();

  static List<MiniAppEntity> get featured =>
      all.where((a) => a.isFeatured).toList();
}
