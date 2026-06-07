import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/mess_mnemonic_words_item.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_password.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class CreateThree extends StatefulWidget {
  final WalletInfo wInfo;
  const CreateThree(this.wInfo, {super.key});

  @override
  State<CreateThree> createState() => _CreateThreeState();
}

class _CreateThreeState extends State<CreateThree> {
  late final DataUtils dataUtils = DataUtils();
  late String mnemonicWords;
  var mnemonicWordsList = [];
  List<MessMnemonicWordsItem> messMnemonicWordsList = [];
  List<MessMnemonicWordsItem> userHandList = [];
  bool isCanClick = false;
  Load load = Load.finish;

  /// Theme color shortcut
  Color _tc(String key) => AppThemeUtils.getColorByKey(context, key);

  void initData() async {
    mnemonicWords = widget.wInfo.mnemonic ?? "";
    widget.wInfo.coinInfo = chainUrlMap;
    if (mounted) {
      setState(() {
        mnemonicWordsList = mnemonicWords.split(" ");
        final list = dataUtils.shuffle(mnemonicWordsList);
        messMnemonicWordsList = List.generate(
          list.length,
          (i) => MessMnemonicWordsItem(list[i], false, i),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  Widget _buildProgressBar(Color color) {
    return Container(
      height: ScreenUtil().setWidth(10.0),
      width: ScreenUtil().setWidth(88.0),
      decoration: BoxDecoration(borderRadius: AppRadius.brSm, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _tc(AppThemeKeys.mainBlueColor.name);
    final inactiveColor = _tc(AppThemeKeys.dividerColor.name);
    final bgColor = _tc(AppThemeKeys.backGroundColor.name);
    final mainText = _tc(AppThemeKeys.mainTextColor.name);
    final gap = SizedBox(width: ScreenUtil().setWidth(20.0));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProgressBar(activeColor),
            gap,
            _buildProgressBar(activeColor),
            gap,
            _buildProgressBar(activeColor),
            gap,
            _buildProgressBar(inactiveColor),
          ],
        ),
        actions: [SizedBox(width: ScreenUtil().setWidth(130.0))],
        leadingWidth: ScreenUtil().setWidth(130.0),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_key_wallet_c8,
                        style: AppTypography.titleLg.copyWith(
                          color: mainText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(60.0),
                        vertical: ScreenUtil().setWidth(50.0),
                      ),
                      child: Text(
                        S.of(context).g_key_wallet_c12,
                        style: AppTypography.headline.copyWith(color: mainText),
                        textAlign: TextAlign.center,
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
                  const Divider(height: 1, indent: 0, endIndent: 0),
                  Container(
                    height: ScreenUtil().setWidth(148.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                    width: double.infinity,
                    color: bgColor,
                    child: AppButton(
                      label: S.of(context).g_key_wallet_c43,
                      onPressed: () {
                        if (isCanClick) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreatePassword(widget.wInfo),
                            ),
                          );
                        } else {
                          ToastUtils.show(S.of(context).g_key_mnemonic);
                        }
                      },
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
    final borderRadius = AppRadius.brSm;

    return GridView.builder(
      itemCount: messMnemonicWordsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: ScreenUtil().setWidth(20.0),
        crossAxisSpacing: ScreenUtil().setWidth(20.0),
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        if (index >= userHandList.length) {
          return Container(
            decoration: BoxDecoration(
              color: _tc(AppThemeKeys.itemBgColor8.name),
              borderRadius: borderRadius,
            ),
          );
        }
        final item = userHandList[index];
        final isWrong = item.word != mnemonicWordsList[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _tc(AppThemeKeys.mainButtonBgColor.name),
                borderRadius: borderRadius,
              ),
              child: Center(
                child: Text(
                  item.word,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline.copyWith(
                    color: _tc(AppThemeKeys.mainButtonTextColor.name),
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
                    ScreenUtil().setWidth(10.0) * -1,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      messMnemonicWordsList
                              .firstWhere((e) => e.index == item.index)
                              .isSelected =
                          false;
                      userHandList.removeAt(index);
                      setState(() {});
                    },
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
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      itemCount: messMnemonicWordsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: ScreenUtil().setWidth(20.0),
        crossAxisSpacing: ScreenUtil().setWidth(20.0),
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final item = messMnemonicWordsList[index];
        final borderColor = item.isSelected
            ? Colors.blueAccent
            : _tc(AppThemeKeys.mainGreyColor.name);
        final textColor = item.isSelected
            ? Colors.blueAccent
            : _tc(AppThemeKeys.ff444444.name);

        return GestureDetector(
          key: ValueKey(messMnemonicWordsList[index]),
          onTap: () {
            if (!item.isSelected) {
              item.isSelected = true;
              userHandList.add(item);
              final list = userHandList.map((e) => e.word).toList();
              isCanClick = dataUtils.sameList(list, mnemonicWordsList);
              setState(() {});
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1),
              borderRadius: AppRadius.brSm,
            ),
            child: Center(
              child: Text(
                item.word,
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(color: textColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
