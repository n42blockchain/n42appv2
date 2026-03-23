import 'dart:convert';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/pages/share_mining.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_plugin_utils.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/features/mining_v1/widgets/ast_level.dart';
import 'package:n42_wallet/features/mining_v1/widgets/group_confrim.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:web3dart/web3dart.dart';

part 'full_node_page_widgets.dart';
part 'full_node_page_logic.dart';

class FullNodePage extends StatefulWidget {
  final int astNum;
  const FullNodePage({required this.astNum, super.key});

  @override
  State<FullNodePage> createState() => _FullNodePageState();
}

class _FullNodePageState extends State<FullNodePage>
    with _FullNodePageWidgets, _FullNodePageLogic {
  Load load = Load.finish;
  int _payType = 0;
  int _payMethod = 0;

  bool isLoadingAstBalance = false;
  bool isLoadingNftBalance = false;

  double? astBalance;
  String? astAddress;

  BigInt nft50num = BigInt.zero;
  BigInt nft100num = BigInt.zero;
  BigInt nft500num = BigInt.zero;

  DataUtils? _dataUtils;
  DataUtils get dataUtils {
    _dataUtils ??= DataUtils();
    return _dataUtils!;
  }

  @override
  void initState() {
    super.initState();
    checkAstBalance();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = _resolveAppBarTitle(context);

    return Scaffold(
      appBar: AppBarWidget(text: appBarTitle),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(30)),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          AstLevel(astNum: widget.astNum),
                          SizedBox(height: ScreenUtil().setWidth(90)),
                          Text(
                            S.current.g_mining_key_38,
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context,
                                    AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(30)),
                          ),
                          SizedBox(height: ScreenUtil().setWidth(30)),
                          _buildPayMethod(
                            "assets/mining/pay_ast.png",
                            S.of(context).g_mining_key_40,
                            isSelected: _payType == 0,
                            onTap: () {
                              setState(() {
                                _payType = 0;
                              });
                            },
                          ),
                          SizedBox(height: ScreenUtil().setWidth(24)),
                          Divider(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemLineColor.name),
                          ),
                          SizedBox(height: ScreenUtil().setWidth(24)),
                          Text(
                            S.of(context).g_mining_key46,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(26)),
                          ),
                          SizedBox(height: ScreenUtil().setWidth(90)),
                          Text(
                            S.current.g_mining_key_39,
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context,
                                    AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(30)),
                          ),
                          SizedBox(height: ScreenUtil().setWidth(24)),
                          _buildPayMethods(),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(148)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Divider(
                    height: ScreenUtil().setWidth(1),
                    indent: 0,
                    endIndent: 0,
                  ),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setWidth(148),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    child: buttonStyle6(
                      context,
                      () async {
                        await _handleConfirmTap();
                      },
                      S.of(context).g_key_78,
                      AppThemeUtils.getColorByKey(
                        context,
                        load == Load.loading
                            ? AppThemeKeys.mainButtonBgColor3.name
                            : AppThemeKeys.mainButtonBgColor.name,
                      ),
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainButtonTextColor.name,
                      ),
                      load == Load.loading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveAppBarTitle(BuildContext context) {
    final levelLabel = switch (widget.astNum) {
      50  => S.of(context).g_mining_key_62,
      100 => S.of(context).g_mining_key_61,
      _   => S.of(context).g_mining_key_63,
    };
    return '${S.current.g_mining_key_37}:$levelLabel';
  }
}
