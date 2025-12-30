import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/mess_mnemonic_words_item.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/wallet_backup/backup_three.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/edit_wallet_password.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class BackupTwo extends StatefulWidget {
  WalletInfo walletInfo;
  int walletIndex;
  BackupTwo(this.walletInfo,this.walletIndex,{super.key});
  @override
  State<BackupTwo> createState() => _BackupTwoState();
}

class _BackupTwoState extends State<BackupTwo> {
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    if(_dataUtils==null){
      _dataUtils= DataUtils();
    }
    return _dataUtils!;
  }
  //原始集合
  var mnemonicWordsList = [];

  // 打乱的助记词
  List<MessMnemonicWordsItem> messMnemonicWordsList = [];

  // 用户点击之后 按顺序生成的集合
  List<MessMnemonicWordsItem> userHandList = [];
  //按钮是否可点击
  bool isCanClick = false;
  @override
  void initState() {
    // TODO: implement initState
    mnemonicWordsList = widget.walletInfo.mnemonic!.split(" ");
    //克隆一个数组，然后打乱
    var list = dataUtils.shuffle(mnemonicWordsList);
    messMnemonicWordsList = [];
    for (int i = 0; i < list.length; i++) {
      messMnemonicWordsList.add(MessMnemonicWordsItem(list[i], false, i));
    }
    super.initState();
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                  Divider(
                    height: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    height: ScreenUtil().setWidth(148),
                    child: ButtonStyle6(
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
  _buildUserHandList() {
    return GridView.builder(
        itemCount: messMnemonicWordsList.length,//userHandList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //横轴元素个数
            crossAxisCount: 3,
            //纵轴间距
            mainAxisSpacing: ScreenUtil().setWidth(20.0),
            //横轴间距
            crossAxisSpacing: ScreenUtil().setWidth(20.0),
            //子组件宽高长度比例
            childAspectRatio: 2.4),
        itemBuilder: (context, index) {

          if(userHandList.length-1<index){
            return Container(
              decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor8.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),

            );
          }
          /// 对比当前位置的助记词和元数据中的是否一致
          MessMnemonicWordsItem? item = userHandList[index];
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

  _buildGridView() {
    return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        itemCount: messMnemonicWordsList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //横轴元素个数
            crossAxisCount: 3,
            //纵轴间距
            mainAxisSpacing: ScreenUtil().setWidth(20.0),
            //横轴间距
            crossAxisSpacing: ScreenUtil().setWidth(20.0),
            //子组件宽高长度比例
            childAspectRatio: 2.4),
        itemBuilder: (context, index) {
          MessMnemonicWordsItem item = messMnemonicWordsList[index];
          return GestureDetector(
            key: ValueKey(
              messMnemonicWordsList[index],
            ),
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
