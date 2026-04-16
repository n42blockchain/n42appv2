import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n42_chat/n42_chat.dart';

import 'server_test_page.dart';

// 导入本地化支持
import 'package:n42_chat/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // 初始化N42 Chat
  await N42Chat.initialize(
    N42ChatConfig(
      defaultHomeserver: 'https://matrix.org',
      enableEncryption: true,
      enablePushNotifications: true,
      walletBridge: NoOpWalletBridge(), // 未集成钱包时的安全降级
      onMessageTap: (roomId, eventId) {
        debugPrint('Message tapped: $roomId / $eventId');
      },
    ),
  );

  runApp(const N42ChatExampleApp());
}

/// N42 Chat 示例应用
class N42ChatExampleApp extends StatefulWidget {
  const N42ChatExampleApp({super.key});

  @override
  State<N42ChatExampleApp> createState() => _N42ChatExampleAppState();
}

class _N42ChatExampleAppState extends State<N42ChatExampleApp> {
  Locale _locale = N42Chat.locale;

  @override
  void initState() {
    super.initState();
    // 监听 N42Chat 的语言变化
    N42Chat.addLocaleListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    N42Chat.removeLocaleListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged(Locale locale) {
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'N42 Chat Demo',
      debugShowCheckedModeBanner: false,
      theme: N42ChatTheme.wechatLight().toThemeData(),
      darkTheme: N42ChatTheme.wechatDark().toThemeData(),
      themeMode: ThemeMode.system,
      // 国际化配置
      locale: _locale,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: const MainScreen(),
    );
  }
}

/// 主屏幕 - 直接显示聊天界面（独立聊天程序）
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 登录后直接显示消息页面，无底部导航
    return N42Chat.chatWidget();
  }
}

/// 钱包页面占位
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: Text(S.of(context)?.profileWallet ?? 'Wallet'),
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: const Color(0xFF181818),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF07C160).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 40,
                color: Color(0xFF07C160),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'N42 Wallet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF181818),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context)?.commonWalletArea ?? 'Wallet area',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  _BalanceItem(label: 'ETH', value: '1.5000'),
                  Divider(height: 24),
                  _BalanceItem(label: 'USDT', value: '100.00'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final String value;

  const _BalanceItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF181818),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181818),
          ),
        ),
      ],
    );
  }
}

/// 发现页面占位
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: Text(S.of(context)?.commonDiscover ?? 'Discover'),
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: const Color(0xFF181818),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildSection([
            _DiscoverItem(
              icon: Icons.qr_code_scanner,
              iconColor: const Color(0xFF3D7CF4),
              title: S.of(context)?.commonScan ?? 'Scan',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 10),
          _buildSection([
            _DiscoverItem(
              icon: Icons.apps,
              iconColor: const Color(0xFF7D48D8),
              title: 'DApps',
              onTap: () {},
            ),
            _DiscoverItem(
              icon: Icons.swap_horiz,
              iconColor: const Color(0xFF07C160),
              title: 'Swap',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> items) {
    return Container(
      color: Colors.white,
      child: Column(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Divider(height: 0.5, indent: 56);
          }
          return items[index ~/ 2];
        }),
      ),
    );
  }
}

class _DiscoverItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _DiscoverItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFCCCCCC),
      ),
      onTap: onTap,
    );
  }
}

/// 个人中心页面占位
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: const Color(0xFFF7F7F7),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF7F7F7),
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07C160),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'N42 User',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF181818),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '@user:matrix.org',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.qr_code,
                      color: Color(0xFF888888),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFCCCCCC),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildSection([
                  _ProfileItem(
                    icon: Icons.settings,
                    title: S.of(context)?.commonSettings ?? 'Settings',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 10),
                _buildSection([
                  _ProfileItem(
                    icon: Icons.science,
                    title: 'Server Test',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServerTestPage(),
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 10),
                _buildSection([
                  _ProfileItem(
                    icon: Icons.info_outline,
                    title: S.of(context)?.settingsAbout ?? 'About',
                    onTap: () {},
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> items) {
    return Container(
      color: Colors.white,
      child: Column(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Divider(height: 0.5, indent: 56);
          }
          return items[index ~/ 2];
        }),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF07C160)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFCCCCCC),
      ),
      onTap: onTap,
    );
  }
}

