import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../n42_chat.dart';
import '../../blocs/moment/moment_bloc.dart';
import '../../blocs/moment/moment_event.dart';
import '../../blocs/moment/moment_state.dart';
import '../../blocs/search/search_bloc.dart';
import '../../widgets/common/common_widgets.dart';
import '../game/game_center_page.dart';
import '../mini_app/mini_app_market_page.dart';
import '../moment/moment_list_page.dart';
import '../qrcode/scan_qr_page.dart';
import '../search/global_search_page.dart';
import 'social_hub_page.dart';
import '../space/space_list_page.dart';
import '../voice_room/voice_room_list_page.dart';
import 'channel_discover_page.dart';

/// 发现页面（仿微信）
class DiscoverPage extends StatelessWidget {
  /// 是否显示 AppBar（嵌入到主框架时可设为 false）
  final bool showAppBar;

  const DiscoverPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = context.pageBackground;

    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: showAppBar
          ? N42AppBar(
              title: l10n?.commonDiscover ?? 'Discover',
              showBackButton: false,
            )
          : null,
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // 朋友圈
          _buildGroupCard(
            context,
            isDark,
            children: [
              _buildMomentsMenuItem(context, isDark, l10n),
              _buildDivider(context, isDark),
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFEC4899),
                  size: 26,
                ),
                title: 'Stories & Fun',
                onTap: () => _openSocialHub(context),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 扫一扫、搜一搜
          _buildGroupCard(
            context,
            isDark,
            children: [
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: _ScanIcon(),
                title: l10n?.commonScan ?? 'Scan',
                onTap: () => _openScanQR(context),
              ),
              _buildDivider(context, isDark),
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: _SearchIcon(),
                title: l10n?.discoverSearchDiscover ?? 'Search',
                onTap: () => _openSearch(context),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 直播、听一听、看一看
          _buildGroupCard(
            context,
            isDark,
            children: [
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: _LiveIcon(),
                title: l10n?.discoverLive ?? 'Live',
                onTap: () => _openVoiceRooms(context),
              ),
              _buildDivider(context, isDark),
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: _MusicIcon(),
                title: l10n?.discoverListen ?? 'Listen',
                onTap: () =>
                    _showComingSoon(context, l10n?.discoverListen ?? 'Listen'),
              ),
              _buildDivider(context, isDark),
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: _WatchIcon(),
                title: l10n?.discoverWatch ?? 'Watch',
                onTap: () =>
                    _showComingSoon(context, l10n?.discoverWatch ?? 'Watch'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 游戏
          _buildGroupCard(
            context,
            isDark,
            children: [
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: const Icon(
                  Icons.graphic_eq,
                  color: Color(0xFFFF8A65),
                  size: 26,
                ),
                title: l10n?.voiceRoomTitle ?? 'Voice Room',
                onTap: () => _openVoiceRooms(context),
              ),
              _buildDivider(context, isDark),
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: const Icon(
                  Icons.apps_rounded,
                  color: Color(0xFF00B894),
                  size: 26,
                ),
                title:
                    l10n?.discoverMiniPrograms ??
                    l10n?.miniAppMarketTitle ??
                    'Mini Apps',
                onTap: () => _openMiniApps(context),
              ),
              _buildDivider(context, isDark),
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: _GameIcon(),
                title: l10n?.discoverGames ?? 'Games',
                onTap: () => _openGames(context),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 社区/Communities
          _buildGroupCard(
            context,
            isDark,
            children: [
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: const Icon(
                  Icons.groups,
                  color: Color(0xFF7B68EE),
                  size: 26,
                ),
                title: l10n?.spacesTitle ?? 'Communities',
                onTap: () => _openCommunities(context),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 附近的人
          _buildGroupCard(
            context,
            isDark,
            children: [
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: _NearbyIcon(),
                title: l10n?.discoverNearbyPeople ?? 'Nearby',
                onTap: () => _showComingSoon(
                  context,
                  l10n?.discoverNearbyPeople ?? 'Nearby',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 频道发现
          _buildGroupCard(
            context,
            isDark,
            children: [
              _buildMenuItem(
                context,
                isDark: isDark,
                iconWidget: const Icon(
                  Icons.campaign,
                  color: Color(0xFFFF6B6B),
                  size: 26,
                ),
                title:
                    l10n?.discoverVideoChannels ??
                    l10n?.channelDiscoverTitle ??
                    'Channels',
                onTap: () => _openChannelDiscover(context),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    bool isDark, {
    required List<Widget> children,
  }) {
    return Container(
      color: context.surfaceColor,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required bool isDark,
    required Widget iconWidget,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final textColor = context.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(width: 26, height: 26, child: iconWidget),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, height: 1.3, color: textColor),
                ),
              ),
              ?trailing,
              Icon(
                AppIcons.chevron,
                color: context.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 58),
      child: Divider(
        height: 1,
        color: context.dividerColor,
      ),
    );
  }

  void _openScanQR(BuildContext context) {
    Navigator.of(context)
        .push<Map<String, dynamic>?>(
          MaterialPageRoute<Map<String, dynamic>?>(
            builder: (_) => const ScanQRPage(),
          ),
        )
        .then((result) {
          if (result == null || !context.mounted) return;
          final roomId = result['roomId'] as String?;
          final userId = result['userId'] as String?;
          if (roomId != null) {
            N42Chat.openConversation(roomId, context: context);
          } else if (userId != null) {
            N42Chat.openUserProfile(userId, context: context);
          }
        });
  }

  void _openSocialHub(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SocialHubPage()));
  }

  Widget _buildMomentsMenuItem(BuildContext context, bool isDark, S? l10n) {
    // 尝试从上层获取 MomentBloc
    MomentBloc? momentBloc;
    try {
      momentBloc = context.read<MomentBloc>();
    } catch (_) {
      // DiscoverPage also works without a MomentBloc in lightweight hosts/tests.
    }

    if (momentBloc == null) {
      return _buildMenuItem(
        context,
        isDark: isDark,
        iconWidget: _MomentsIcon(),
        title: l10n?.commonMoments ?? 'Moments',
        onTap: () => _openMoments(context),
      );
    }

    return BlocBuilder<MomentBloc, MomentState>(
      builder: (context, state) {
        Widget? trailing;
        final unread = state.unreadCount;
        final latestMoment = state.moments.isNotEmpty
            ? state.moments.first
            : null;

        if (unread > 0 || latestMoment != null) {
          trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (latestMoment != null)
                N42Avatar(
                  name: latestMoment.userName,
                  imageUrl: latestMoment.userAvatarUrl,
                  size: 32,
                ),
              if (unread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          );
        }

        return _buildMenuItem(
          context,
          isDark: isDark,
          iconWidget: _MomentsIcon(),
          title: l10n?.commonMoments ?? 'Moments',
          trailing: trailing,
          onTap: () => _openMoments(context),
        );
      },
    );
  }

  void _openMoments(BuildContext context) {
    // 标记已读
    try {
      context.read<MomentBloc>().add(const MarkMomentsAsRead());
    } catch (_) {
      // Skip unread state updates when the optional MomentBloc is absent.
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MomentListPage()));
  }

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<SearchBloc>(),
          child: const GlobalSearchPage(),
        ),
      ),
    );
  }

  void _openGames(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const GameCenterPage()));
  }

  void _openVoiceRooms(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const VoiceRoomListPage()));
  }

  void _openMiniApps(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MiniAppMarketPage(roomId: ''),
      ),
    );
  }

  void _openCommunities(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SpaceListPage()));
  }

  void _openChannelDiscover(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChannelDiscoverPage()),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context)?.commonFeatureComingSoon(feature) ??
              '$feature coming soon',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ==================== 图标组件 ====================

/// 朋友圈图标 - 彩色花瓣/蝴蝶
class _MomentsIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(26, 26),
      painter: _MomentsIconPainter(),
    );
  }
}

class _MomentsIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.28;

    // 四个椭圆花瓣，交织在一起
    final colors = [
      const Color(0xFF56CCF2), // 上 - 蓝
      const Color(0xFFFF9F43), // 右 - 橙
      const Color(0xFF26DE81), // 下 - 绿
      const Color(0xFFFC5C65), // 左 - 粉红
    ];

    // 绘制四个交织的椭圆
    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(i * math.pi / 2 + math.pi / 4);

      final rect = Rect.fromCenter(
        center: Offset(r * 0.5, 0),
        width: r * 1.5,
        height: r * 0.9,
      );
      canvas.drawOval(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 直播图标 - 红色同心圆
class _LiveIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(26, 26), painter: _LiveIconPainter());
  }
}

class _LiveIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const color = Color(0xFFFF4757);

    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, size.width * 0.38, outerPaint);

    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.15, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 听一听图标 - 粉色音符
class _MusicIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.music_note, color: Color(0xFFFF69B4), size: 26);
  }
}

/// 看一看图标 - 黄色六边形
class _WatchIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(26, 26), painter: _WatchIconPainter());
  }
}

class _WatchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFFFFB300);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 0.22, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 附近的人图标 - 蓝色雷达人形
class _NearbyIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(26, 26), painter: _NearbyIconPainter());
  }
}

class _NearbyIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF10AEFF);
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width * 0.9,
        height: size.height * 0.9,
      ),
      math.pi * 0.65,
      math.pi * 0.7,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width * 0.9,
        height: size.height * 0.9,
      ),
      -math.pi * 0.35,
      math.pi * 0.7,
      false,
      paint,
    );

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.1),
      size.width * 0.1,
      headPaint,
    );
    canvas.drawLine(
      Offset(cx, cy + size.height * 0.02),
      Offset(cx, cy + size.height * 0.22),
      headPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 游戏图标 - 游戏手柄
class _GameIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(26, 26), painter: _GameIconPainter());
  }
}

class _GameIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..style = PaintingStyle.fill;

    // Controller body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.25, w * 0.84, h * 0.45),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Left grip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.4, w * 0.2, h * 0.4),
        const Radius.circular(4),
      ),
      bodyPaint,
    );

    // Right grip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.75, h * 0.4, w * 0.2, h * 0.4),
        const Radius.circular(4),
      ),
      bodyPaint,
    );

    final btnPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // D-pad (cross)
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w * 0.3, h * 0.47),
        width: w * 0.04,
        height: h * 0.18,
      ),
      btnPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w * 0.3, h * 0.47),
        width: w * 0.18,
        height: h * 0.04,
      ),
      btnPaint,
    );

    // Action buttons (two dots)
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), w * 0.04, btnPaint);
    canvas.drawCircle(Offset(w * 0.76, h * 0.52), w * 0.04, btnPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 扫一扫图标 - 蓝色扫描框
class _ScanIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(26, 26), painter: _ScanIconPainter());
  }
}

class _ScanIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10AEFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final corner = w * 0.28;
    final p = w * 0.1;

    // 左上
    canvas.drawLine(Offset(p, p + corner), Offset(p, p), paint);
    canvas.drawLine(Offset(p, p), Offset(p + corner, p), paint);

    // 右上
    canvas.drawLine(Offset(w - p - corner, p), Offset(w - p, p), paint);
    canvas.drawLine(Offset(w - p, p), Offset(w - p, p + corner), paint);

    // 左下
    canvas.drawLine(Offset(p, h - p - corner), Offset(p, h - p), paint);
    canvas.drawLine(Offset(p, h - p), Offset(p + corner, h - p), paint);

    // 右下
    canvas.drawLine(Offset(w - p, h - p - corner), Offset(w - p, h - p), paint);
    canvas.drawLine(Offset(w - p - corner, h - p), Offset(w - p, h - p), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 搜一搜图标 - 红色星形放大镜
class _SearchIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(26, 26), painter: _SearchIconPainter());
  }
}

class _SearchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFFFF4757);
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final cx = w * 0.38;
    final cy = h * 0.38;
    final r = w * 0.2;

    // 六芒星/放射线
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x1 = cx + r * 0.4 * math.cos(angle);
      final y1 = cy + r * 0.4 * math.sin(angle);
      final x2 = cx + r * 1.3 * math.cos(angle);
      final y2 = cy + r * 1.3 * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // 手柄
    canvas.drawLine(
      Offset(cx + r * 0.9, cy + r * 0.9),
      Offset(w * 0.9, h * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
