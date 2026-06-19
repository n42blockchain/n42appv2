import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_state.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_widgets_mixin.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';

/// WalletConnect Page - Migrated to Riverpod
///
/// Handles WalletConnect integration for DApp connections
class WalletConnectPage extends ConsumerStatefulWidget {
  final String uri;
  const WalletConnectPage(this.uri, {super.key});

  @override
  ConsumerState<WalletConnectPage> createState() => _WalletConnectPageState();
}

class _WalletConnectPageState extends ConsumerState<WalletConnectPage>
    with WalletConnectWidgetsMixin {
  @override
  void initState() {
    super.initState();
    if (widget.uri != "") {
      ref.read(wcpBridgeProvider).pageOpen = true;
      ref
          .read(wcpBridgeProvider)
          .viewStateDeal(WalletConnectState.loading, params: widget.uri);
    }
  }

  @override
  void dispose() {
    ref.read(wcpBridgeProvider).pageOpen = false;
    super.dispose();
  }

  @override
  Future<String> scan() async {
    final scanValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
    return scanValue ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final connectV2 = ref.watch(wcpBridgeProvider);
    return Scaffold(
      appBar: AppBarWidget(text: connectV2.metadata?.name ?? "Wallet Connect"),
      body: SafeArea(
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
