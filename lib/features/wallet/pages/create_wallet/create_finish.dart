import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'create_finish_content.dart';

class CreateFinish extends ConsumerStatefulWidget {
  final WalletInfo? wInfo;
  final String createMetod;
  @visibleForTesting
  final Future<void> Function(WalletInfo wallet)? addWalletForTesting;
  @visibleForTesting
  final Future<int> Function(WalletInfo wallet)? checkWalletMnemonicForTesting;

  const CreateFinish({
    this.wInfo,
    this.createMetod = "Create",
    this.addWalletForTesting,
    this.checkWalletMnemonicForTesting,
    super.key,
  });

  @override
  ConsumerState<CreateFinish> createState() => _CreateFinishState();
}

class _CreateFinishState extends ConsumerState<CreateFinish>
    with _CreateFinishContentMixin {
  @override
  Load load = Load.loading;
  @override
  bool exportKeystore = false;
  @override
  String pageName = "/CreateOne";
  WalletInfo? _wInfo;

  Future<bool> _pageBack() {
    if (Navigator.canPop(context)) {
      if (load == Load.finish || load == Load.error) {
        Navigator.popUntil(context, ModalRoute.withName(pageName));
      }
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(false);
  }

  Future<void> createWallet() async {
    _wInfo = widget.wInfo;
    final walletActionProvider = ref.read(wapBridgeProvider);

    var saved = false;
    try {
      if (_wInfo == null) {
        _wInfo = WalletInfo(
          walletName: "",
          password: "",
          walletUuid: walletActionProvider.userUUID,
        );
        _wInfo!.mnemonic = await Trustdart().generateMnemonic();
      }

      if (widget.createMetod == 'Create' &&
          !_wInfo!.watchOnly &&
          !_wInfo!.hasPrivateKey &&
          _wInfo!.mnemonic?.trim().isEmpty == true) {
        throw StateError('Wallet mnemonic generation failed');
      }
      if (_wInfo!.walletName == "") {
        _wInfo!.walletName =
            "Account${walletActionProvider.walletInfoLsit.length + 1}";
      }
      _wInfo!.coinInfo ??= chainUrlMap;
      _wInfo!.timestamp = "${DateTime.now().millisecondsSinceEpoch}";

      int code = -1;
      if (!mounted) return;
      setState(() => load = Load.loading);

      code = widget.createMetod == "Import"
          ? await (widget.checkWalletMnemonicForTesting?.call(_wInfo!) ??
                walletActionProvider.checkWalletMnemonic(_wInfo!))
          : 0;

      if (code == 0) {
        await (widget.addWalletForTesting?.call(_wInfo!) ??
            walletActionProvider.addWalletInfo(_wInfo!));
        saved = true;
      } else {
        AppLogger.w('CreateFinish', 'create wallet err');
      }
    } catch (_) {
      AppLogger.w('CreateFinish', 'Wallet creation failed');
    } finally {
      if (mounted) {
        setState(() => load = saved ? Load.finish : Load.error);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    pageName = switch (widget.createMetod) {
      "Import" => "/ImportOne",
      "PrivateKey" => "/ImportPrivatekey",
      _ => pageName,
    };
    createWallet();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColorTokens.of(context).bgBase,
          actions: [SizedBox(width: ScreenUtil().setWidth(130.0))],
          leadingWidth: ScreenUtil().setWidth(130.0),
          leading: const SizedBox(),
          title: _buildProgressIndicator(),
        ),
        body: SafeArea(
          child: exportKeystore
              ? _buildExportKeystoreContent()
              : _buildMainContent(),
        ),
      ),
    );
  }
}
