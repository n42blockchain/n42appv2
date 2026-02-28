import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/mess_mnemonic_words_item.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_three.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class BackupTwo extends StatefulWidget {
  final WalletInfo walletInfo;
  final int walletIndex;
  const BackupTwo(this.walletInfo,this.walletIndex,{super.key});
  @override
  State<BackupTwo> createState() => _BackupTwoState();
}

class _BackupTwoState extends State<BackupTwo> {
  late final DataUtils dataUtils = DataUtils();

  //原始集合
  late final List<String> mnemonicWordsList;

  // 打乱的助记词
  late final List<MessMnemonicWordsItem> messMnemonicWordsList;

  // 用户点击之后 按顺序生成的集合
  List<MessMnemonicWordsItem> userHandList = [];
  //按钮是否可点击
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
    mnemonicWordsList = widget.walletInfo.mnemonic!.split(" ");
    //克隆一个数组，然后打乱
    final list = dataUtils.shuffle(mnemonicWordsList);
    messMnemonicWordsList = [
      for (int i = 0; i < list.length; i++)
        MessMnemonicWordsItem(list[i], false, i),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_c46,
      ),
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
                      margin: EdgeInsets.only(
                        top: ScreenUtil().setWidth(30),
                        bottom: ScreenUtil().setWidth(30),
                      ),
                      child: Text(
                        S.of(context).g_key_wallet_c12,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(50.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                    ),
                    _buildUserHandList(),
                    SizedBox(
                      height: ScreenUtil().setWidth(50.0),
                    ),
                    _buildGridView(),
                    SizedBox(height: ScreenUtil().setWidth(148.0),),
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
                  Divider(height: 1),
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    height: ScreenUtil().setWidth(148),
                    child: buttonStyle6(
                      context,
                          (){
                        if (isCanClick) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BackupThree(widget.walletInfo, widget.walletIndex)));
                        } else {
                          //请输入正确的助记词
                          ToastUtils.show(S.of(context).g_key_mnemonic);
                        }
                      },
                      S.of(context).g_key_wallet_c43,
                      AppThemeUtils.getColorByKey(
                        context,
                        isCanClick?
                        AppThemeKeys.mainButtonBgColor.name:
                        AppThemeKeys.mainButtonBgColor3.name,
                      ),
                      AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainButtonTextColor.name
                      ),
                      false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
  //根据用户点击顺序生成的list
  Widget _buildUserHandList() {
    return GridView.builder(
        itemCount: messMnemonicWordsList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: _gridDelegate,
        itemBuilder: (context, index) {
          if (index >= userHandList.length) {
            return Container(
              decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor8.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),

            );
          }
          /// 对比当前位置的助记词和元数据中的是否一致
          final item = userHandList[index];
          final flag = item.word != mnemonicWordsList[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
                child: Center(
                  child: Text(
                    item.word,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                  ),
                ),
              ),
              // 用户每次点击添加一个助记词，要判断当前的位置是否时正确的助记词
              if (flag)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Transform.translate(
                      offset: Offset(ScreenUtil().setWidth(10.0),ScreenUtil().setWidth(10.0)*-1),
                      child: GestureDetector(
                        child:Container(
                          width: ScreenUtil().setWidth(36.0),
                          height: ScreenUtil().setWidth(36.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(18.0),),
                              color: Colors.white),
                          child: Icon(
                            Icons.cancel,
                            size: ScreenUtil().setWidth(36.0),
                            color: Colors.red,
                          ),
                        ),
                        onTap: () async {
                          //修改打乱数组选中状态
                          MessMnemonicWordsItem itemMess =
                          messMnemonicWordsList.firstWhere(
                                  (element) => element.index == item.index);
                          itemMess.isSelected = false;
                          //删除
                          userHandList.removeAt(index);
                          setState(() {});
                        },
                      )
                  ),
                )
            ],
          );
        });
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
            onTap: () async {
              //助记词是可以重复的12个单词
              if (!item.isSelected) {
                item.isSelected = true;
                userHandList.add(item);
                //isCanClick逻辑处理 很简单 直接判断2个集合是否完全一致
                var list = userHandList.map((e) => e.word).toList();
                isCanClick = dataUtils.sameList(list, mnemonicWordsList);
                setState(() {});
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: item.isSelected
                          ? Colors.blueAccent
                          : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainGreyColor.name),
                      width: 1),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
              child: Center(
                child: Text(
                  item.word,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: item.isSelected
                        ? Colors.blueAccent
                        : AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.ff444444.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
