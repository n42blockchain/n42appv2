import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet_connect/pages/wallet_connect_page.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/dapp_security_badge.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/core/security/dapp_security_service.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;

/// Known EIP-155 chain ID → human-readable name mapping.
const _chainNames = <String, String>{
  '1': 'Ethereum',
  '56': 'BNB Chain',
  '137': 'Polygon',
  '42161': 'Arbitrum',
  '10': 'Optimism',
  '43114': 'Avalanche',
  '250': 'Fantom',
  '100': 'Gnosis',
  '324': 'zkSync Era',
  '8453': 'Base',
  '59144': 'Linea',
  '5': 'Goerli',
  '11155111': 'Sepolia',
};

class WcSessionListPage extends ConsumerStatefulWidget {
  const WcSessionListPage({super.key});

  @override
  ConsumerState<WcSessionListPage> createState() => _WcSessionListPageState();
}

class _WcSessionListPageState extends ConsumerState<WcSessionListPage> {
  Future<void> _scanNewConnection() async {
    final scanStr = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScanPage()),
    );
    if (!mounted || scanStr == null || scanStr.isEmpty) return;
    if (scanStr.contains('relay-protocol') && scanStr.contains('symKey')) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WalletConnectPage(scanStr)),
      );
      if (mounted) setState(() {});
    } else {
      ToastUtils.show(S.of(context).g_key_203);
    }
  }

  /// Show a confirm/cancel dialog. Returns true if the user confirmed.
  Future<bool> _showConfirmDialog({String? title, required String content}) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.g_key_79),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.g_key_78,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _confirmDisconnect(String topic, String dAppName) async {
    final confirmed = await _showConfirmDialog(
      title: dAppName,
      content: S.of(context).g_wc_disconnect_confirm,
    );
    if (confirmed && mounted) {
      await ref.read(wcpBridgeProvider).disconnectSessionByTopic(topic);
    }
  }

  Future<void> _confirmDisconnectAll() async {
    final confirmed = await _showConfirmDialog(
      content: S.of(context).g_wc_disconnect_all_confirm,
    );
    if (confirmed && mounted) {
      await ref.read(wcpBridgeProvider).disconnectAllSessions();
    }
  }

  void _onSessionTap(wallet_connect.SessionData session) {
    ref.read(wcpBridgeProvider).setActiveSession(session);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WalletConnectPage("")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wcp = ref.watch(wcpBridgeProvider);
    final sessions = wcp.getActiveSessions();
    final entries = sessions.entries.toList();

    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_wc_sessions,
        actions: entries.isNotEmpty
            ? [
                IconButton(
                  onPressed: _confirmDisconnectAll,
                  icon: Icon(
                    Icons.link_off,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                    size: ScreenUtil().setWidth(44),
                  ),
                  tooltip: S.of(context).g_wc_disconnect_all,
                ),
              ]
            : null,
      ),
      body: entries.isEmpty ? _buildEmptyState() : _buildSessionList(entries),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanNewConnection,
        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.link_off,
            size: ScreenUtil().setWidth(120),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          Text(
            S.of(context).g_wc_no_sessions,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            S.of(context).g_wc_no_sessions_desc,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(List<MapEntry<String, wallet_connect.SessionData>> entries) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(24),
        vertical: ScreenUtil().setWidth(16),
      ),
      itemCount: entries.length,
      separatorBuilder: (_, _) => SizedBox(height: ScreenUtil().setWidth(16)),
      itemBuilder: (context, index) {
        final session = entries[index].value;
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(wallet_connect.SessionData session) {
    final meta = session.peer.metadata;
    final iconUrl = (meta.icons.isNotEmpty) ? meta.icons[0] : "";
    final chains = _extractChains(session);
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(session.expiry * 1000);
    final isExpired = expiryDate.isBefore(DateTime.now());

    return InkWell(
      onTap: () => _onSessionTap(session),
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DApp icon
            Container(
              width: ScreenUtil().setWidth(72),
              height: ScreenUtil().setWidth(72),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                child: iconUrl.isNotEmpty
                    ? ImageNetWork(
                        imageUrl: iconUrl,
                        placeholder: "assets/wallet/WalletConnect.png",
                      )
                    : Image.asset("assets/wallet/WalletConnect.png"),
              ),
            ),
            // Info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    meta.name,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  // URL
                  if (meta.url.isNotEmpty)
                    Text(
                      meta.url,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: ScreenUtil().setWidth(10)),
                  // Chain tags
                  if (chains.isNotEmpty)
                    Wrap(
                      spacing: ScreenUtil().setWidth(8),
                      runSpacing: ScreenUtil().setWidth(6),
                      children: chains.map((chain) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(12),
                            vertical: ScreenUtil().setWidth(4),
                          ),
                          decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                          ),
                          child: Text(
                            chain,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(20),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  // Method history chips
                  FutureBuilder<List<String>>(
                    future: DAppPermissionsTracker.getForOrigin(
                      Uri.tryParse(meta.url)?.host ?? '',
                    ),
                    builder: (ctx, snap) {
                      final methods = snap.data ?? [];
                      if (methods.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(
                          top: ScreenUtil().setWidth(6),
                          bottom: ScreenUtil().setWidth(2),
                        ),
                        child: DAppMethodChips(methods: methods),
                      );
                    },
                  ),
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  // Expiry
                  Text(
                    isExpired
                        ? 'Expired'
                        : 'Expires: ${_formatDate(expiryDate)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: isExpired
                          ? AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name)
                          : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
                ],
              ),
            ),
            // Disconnect button
            IconButton(
              onPressed: () => _confirmDisconnect(session.topic, meta.name),
              icon: Icon(
                Icons.link_off,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                size: ScreenUtil().setWidth(40),
              ),
              tooltip: S.of(context).g_connect_key2,
            ),
          ],
        ),
      ),
    );
  }

  /// Extract unique chain names from session namespaces.
  List<String> _extractChains(wallet_connect.SessionData session) {
    final chainIds = <String>{};
    for (final ns in session.namespaces.values) {
      for (final account in ns.accounts) {
        // account format: "eip155:1:0xabc..." or "tron:0x2b6653dc:T..."
        final parts = account.split(':');
        if (parts.length >= 2) {
          chainIds.add('${parts[0]}:${parts[1]}');
        }
      }
    }
    return chainIds.map((id) {
      final parts = id.split(':');
      if (parts[0] == 'eip155') {
        return _chainNames[parts[1]] ?? 'EIP155:${parts[1]}';
      } else if (parts[0] == 'tron') {
        return 'TRON';
      }
      return id;
    }).toList();
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
