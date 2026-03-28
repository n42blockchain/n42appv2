import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/face_api.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/face_matching/face_match.dart';
import 'package:n42_wallet/features/wallet/pages/face_matching/face_user_notice.dart';
import 'package:n42_wallet/features/wallet/pages/face_matching/face_wallet_utils.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_manage.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_manage_flags_utils.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/create_wallet_button.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_4.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/loading_page.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'wallet_list_face_section.dart';
part 'wallet_list_tiles.dart';
part 'wallet_list_actions.dart';

class WalletList extends ConsumerStatefulWidget {
  const WalletList({super.key});

  @override
  ConsumerState<WalletList> createState() => _WalletListState();
}

class _WalletListState extends ConsumerState<WalletList>
    with _WalletListFaceMixin, _WalletListActionsMixin, _WalletListTilesMixin {
  List<WalletInfo> walletList = [];
  Load load = Load.finish;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    walletList = ref.read(wapBridgeProvider).walletInfoLsit;
    checkFaceBindingWallet();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_manage,
        actions: [
          IconButton(
            onPressed: () async {
              sheetBottom(
                context,
                "",
                CreateWalletButton(
                  onTapBack: () {
                    initData();
                  },
                ),
              );
            },
            icon: Icon(
              Icons.add_circle_outline,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(20.0),
                        bottom: ScreenUtil().setWidth(10.0),
                        left: ScreenUtil().setWidth(30.0),
                      ),
                      child: Text(
                        S.of(context).g_face_match_key6,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                          fontSize: ScreenUtil().setSp(32.0),
                        ),
                      ),
                    ),
                    _buildFaceBind(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(20.0),
                        bottom: ScreenUtil().setWidth(10.0),
                        left: ScreenUtil().setWidth(30.0),
                      ),
                      child: Text(
                        S.of(context).g_key_ex_keystore_13,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                          fontSize: ScreenUtil().setSp(32.0),
                        ),
                      ),
                    ),
                    _buildList(),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Visibility(
                visible: load == Load.loading,
                child: LoadingPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
