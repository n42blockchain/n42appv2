import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/mess_mnemonic_words_item.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_three.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class BackupTwo extends StatefulWidget {
  final WalletInfo walletInfo;
  final int walletIndex;
  const BackupTwo(this.walletInfo, this.walletIndex, {super.key});
  @override
  State<BackupTwo> createState() => _BackupTwoState();
}

class _BackupTwoState extends State<BackupTwo> {
  late final DataUtils dataUtils = DataUtils();
  late final List<String> mnemonicWordsList;
  late final List<MessMnemonicWordsItem> messMnemonicWordsList;
  List<MessMnemonicWordsItem> userHandList = [];
  bool isCanClick = false;

  SliverGridDelegateWithFixedCrossAxisCount get _gridDelegate =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: ScreenUtil().setWidth(20.0),
        crossAxisSpacing: ScreenUtil().setWidth(20.0),
        childAspectRatio: 2.4,
      );

  @override
  void initState() {
    super.initState();
    mnemonicWordsList = parseBackupMnemonicWords(widget.walletInfo.mnemonic);
    final list = dataUtils.shuffle(mnemonicWordsList);
    messMnemonicWordsList = [
      for (int i = 0; i < list.length; i++)
        MessMnemonicWordsItem(list[i], false, i),
    ];
  }

  void _onConfirmTap() {
    if (mnemonicWordsList.isEmpty) {
      ToastUtils.show(walletBackupPhraseUnavailableMessage);
      return;
    }
    if (isCanClick) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BackupThree(widget.walletInfo, widget.walletIndex),
        ),
      );
    } else {
      ToastUtils.show(S.of(context).g_key_mnemonic);
    }
  }

  void _removeUserWord(int index) {
    final item = userHandList[index];
    messMnemonicWordsList.firstWhere((e) => e.index == item.index).isSelected =
        false;
    userHandList.removeAt(index);
    setState(() {});
  }

  void _selectWord(MessMnemonicWordsItem item) {
    if (item.isSelected) return;
    item.isSelected = true;
    userHandList.add(item);
    final list = userHandList.map((e) => e.word).toList();
    isCanClick = dataUtils.sameList(list, mnemonicWordsList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_wallet_c46),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(30),
                      ),
                      child: Text(
                        S.of(context).g_key_wallet_c12,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(50.0),
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                    ),
                    _buildUserHandList(),
                    SizedBox(height: ScreenUtil().setWidth(50.0)),
                    _buildGridView(),
                    SizedBox(height: ScreenUtil().setWidth(148.0)),
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
                  const Divider(height: 1),
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppColorTokens.of(context).bgBase,
                    height: ScreenUtil().setWidth(148),
                    child: AppButton(
                      label: S.of(context).g_key_wallet_c43,
                      onPressed: _onConfirmTap,
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

  Widget _buildUserHandList() {
    return GridView.builder(
      itemCount: messMnemonicWordsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: _gridDelegate,
      itemBuilder: (context, index) {
        if (index >= userHandList.length) {
          return _emptySlot();
        }
        return _filledSlot(index);
      },
    );
  }

  Widget _emptySlot() {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor8.name,
        ),
        borderRadius: AppRadius.brSm,
      ),
    );
  }

  Widget _filledSlot(int index) {
    final item = userHandList[index];
    final isWrong = item.word != mnemonicWordsList[index];
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainButtonBgColor.name,
            ),
            borderRadius: AppRadius.brSm,
          ),
          child: Center(
            child: Text(
              item.word,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainButtonTextColor.name,
                ),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
          ),
        ),
        if (isWrong)
          Positioned(
            top: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(
                ScreenUtil().setWidth(10.0),
                -ScreenUtil().setWidth(10.0),
              ),
              child: GestureDetector(
                onTap: () => _removeUserWord(index),
                child: Container(
                  width: ScreenUtil().setWidth(36.0),
                  height: ScreenUtil().setWidth(36.0),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.brMd,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.cancel,
                    size: ScreenUtil().setWidth(36.0),
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      itemCount: messMnemonicWordsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: _gridDelegate,
      itemBuilder: (context, index) {
        final item = messMnemonicWordsList[index];
        return GestureDetector(
          key: ValueKey(item),
          onTap: () => _selectWord(item),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: item.isSelected
                    ? Colors.blueAccent
                    : AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainGreyColor.name,
                      ),
                width: 1,
              ),
              borderRadius: AppRadius.brSm,
            ),
            child: Center(
              child: Text(
                item.word,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: item.isSelected
                      ? Colors.blueAccent
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.ff444444.name,
                        ),
                  fontSize: ScreenUtil().setSp(28.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
