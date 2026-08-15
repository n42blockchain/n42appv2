import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_widgets_mixin.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/widgets/loading_page.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// WalletConnect connection sheet displayed as a modal bottom sheet.
///
/// Mirrors [WalletConnectPage] but without the full-screen Scaffold,
/// so it doesn't cover the browser while the user reviews the connection.
class WalletConnectSheet extends ConsumerStatefulWidget {
  final String uri;
  const WalletConnectSheet(this.uri, {super.key});

  /// Show the sheet and return true if the user approved the connection.
  static Future<bool> show(BuildContext context, String uri) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WalletConnectSheet(uri),
    );
    return result ?? false;
  }

  @override
  ConsumerState<WalletConnectSheet> createState() => _WalletConnectSheetState();
}

class _WalletConnectSheetState extends ConsumerState<WalletConnectSheet>
    with WalletConnectWidgetsMixin {
  late final WalletConnectProvider _connectV2;

  @override
  void initState() {
    super.initState();
    _connectV2 = ref.read(wcpBridgeProvider);
    if (widget.uri.isNotEmpty) {
      // 必须推迟到首帧之后：viewStateDeal 会 notifyListeners()，在 initState
      // 里同步调用等于在 widget 树构建期间修改 provider，Riverpod 会抛
      // "Tried to modify a provider while the widget tree was building" 断言。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _connectV2.pageOpen = true;
        _connectV2.viewStateDeal(
          WalletConnectState.loading,
          params: widget.uri,
        );
      });
    }
  }

  @override
  void dispose() {
    _connectV2.pageOpen = false;
    super.dispose();
  }

  @override
  Future<String> scan() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScanPage()),
    );
    return result ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final connectV2 = ref.watch(wcpBridgeProvider);

    // When a new WC connection is established (non-empty URI flow), auto-close
    // the sheet so pageOpen becomes false. Subsequent transaction requests will
    // then be handled by showAlertWidget() instead of rendering inside this sheet.
    ref.listen<WalletConnectProvider>(wcpBridgeProvider, (prev, next) {
      if (!widget.uri.isNotEmpty) return;
      final prevState = prev?.walletConnectState;
      final nextState = next.walletConnectState;
      if (prevState != WalletConnectState.connect &&
          nextState == WalletConnectState.connect) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context, true);
        });
      }
    });

    final bgColor = AppColorTokens.of(context).bgBase;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      // 80% of screen height to show browser behind
      height: MediaQuery.of(context).size.height * 0.8,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: buildDAppConnectWidget(connectV2)),
            if (connectV2.load == Load.loading)
              Positioned.fill(child: LoadingPage()),
          ],
        ),
      ),
    );
  }
}
