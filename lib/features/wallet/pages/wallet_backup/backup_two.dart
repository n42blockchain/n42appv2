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
        // Fixed 44pt rows: the 2.4 aspect ratio gave 40pt tiles at 375pt
        // and 33pt at 320pt.
        mainAxisExtent: AppTouch.target,
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
      ToastUtils.show(S.of(context).g_ui3_backup_phrase_unavailable);
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
                padding: EdgeInsets.all(AppSpacing.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: AppSpacing.space8),
                      child: Text(
                        S.of(context).g_key_wallet_c12,
                        style: AppTypography.displayLg.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    _buildUserHandList(),
                    SizedBox(height: ScreenUtil().setWidth(50.0)),
                    _buildGridView(),
                    // Room for the bottom bar: 48pt button + padding.
                    SizedBox(
                      height: kMinInteractiveDimension + AppSpacing.space8 * 2,
                    ),
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
                  // No fixed height: a 148px box clamped the button to
                  // 42pt (32pt at 320pt width).
                  Container(
                    padding: EdgeInsets.all(AppSpacing.space8),
                    color: AppColorTokens.of(context).bgBase,
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
    final tile = Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColorTokens.of(context).brandFill,
            borderRadius: AppRadius.brSm,
          ),
          child: Center(
            child: Text(
              item.word,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainButtonTextColor.name,
                ),
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
                    color: AppColorTokens.of(context).danger,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    if (!isWrong) return tile;
    // The 18pt X badge is too small to hit; the whole wrong tile removes
    // the word as well.
    return Semantics(
      button: true,
      label: S.of(context).g_alert_remove,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _removeUserWord(index),
        child: tile,
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
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
                    ? AppColorTokens.of(context).brand
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
                style: AppTypography.body.copyWith(
                  color: item.isSelected
                      ? AppColorTokens.of(context).brand
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.ff444444.name,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
