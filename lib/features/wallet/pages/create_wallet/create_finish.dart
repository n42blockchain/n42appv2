import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_gen_success.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'create_finish_content.dart';

class CreateFinish extends ConsumerStatefulWidget {
  final WalletInfo? wInfo;
  final String createMetod;
  const CreateFinish({this.wInfo, this.createMetod = "Create", super.key});

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
      if (load == Load.finish) {
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

    if (_wInfo == null) {
      _wInfo = WalletInfo(
        walletName: "",
        password: "",
        walletUuid: walletActionProvider.userUUID,
      );
      _wInfo!.mnemonic = await Trustdart().generateMnemonic();
    }

    if (_wInfo!.walletName == "") {
      _wInfo!.walletName =
          "Account${walletActionProvider.walletInfoLsit.length + 1}";
    }
    _wInfo!.coinInfo ??= chainUrlMap;
    _wInfo!.timestamp = "${DateTime.now().millisecondsSinceEpoch}";

    int code = -1;
    try {
      setState(() => load = Load.loading);

      code = widget.createMetod == "Import"
          ? await walletActionProvider.checkWalletMnemonic(_wInfo!)
          : 0;

      if (code == 0) {
        await walletActionProvider.addWalletInfo(_wInfo!);
      } else {
        debugPrint("create wallet err: ");
        ToastUtils.showFtToast(child: createWalletErrView('error'));
      }
    } catch (err) {
      ToastUtils.show(err.toString());
      debugPrint("create wallet err: $err");
    } finally {
      if (mounted) {
        setState(() => load = Load.finish);
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
          backgroundColor: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.backGroundColor.name,
          ),
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
