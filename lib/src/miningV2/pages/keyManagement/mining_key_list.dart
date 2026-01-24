import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/src/miningV2/pages/keyManagement/mining_output_tip.dart';
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:provider/provider.dart';

class MiningKeyList extends StatefulWidget {
  const MiningKeyList({super.key});

  @override
  State<MiningKeyList> createState() => _MiningKeyListState();
}

class _MiningKeyListState extends State<MiningKeyList> {

  Map<String,dynamic>? miningData;
  List<dynamic> miningList=[];
  List<String> miningKeyList=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMiningData();
  }

  getMiningData()async{
    miningData=await SPUtil().getMiningData();
    if(miningData !=null){
      miningList=miningData!.values.toList();
      miningKeyList=miningData!.keys.toList();
    }
    setState(() {});
  }
  removeKey(int index)async{
    miningData!.remove(miningKeyList[index]);
    await SPUtil().setMiningData(miningData!);
    getMiningData();
    if (!mounted) return;
    Provider.of<MiningV2Provider>(context,listen: false).getMiningData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:S.of(context).g_mining_key_103,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(
            ScreenUtil().setWidth(30)
        ),
        itemBuilder: (BuildContext context,index){
          Map<String,dynamic> keyValue=miningList[index] as Map<String,dynamic>;
          bool isMining=keyValue['isMining']??false;
          return ContainerStyle1(
            context,
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
            child:Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(miningKeyList[index],
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                              fontSize: ScreenUtil().setSp(32),
                            ),
                          ),
                          Text(
                            isMining?
                            S.of(context).g_key_193:
                            S.of(context).g_mining_key_102,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, isMining?AppThemeKeys.rightTextColor.name:AppThemeKeys.errorTextColor.name),
                              fontSize: ScreenUtil().setSp(30),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    if(isMining==false)
                      InkWell(
                        onTap: (){
                          removeKey(index);
                        },
                        child: Icon(
                          Icons.delete_forever_outlined,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                          size: ScreenUtil().setWidth(40),
                        ),
                      ),
                    if(isMining)
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>MiningOutputTip(value: keyValue['keypart'],)));
                        },
                        child: Icon(
                          Icons.output_outlined,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                          size: ScreenUtil().setWidth(40),
                        ),
                      ),
                  ],
                ),
                Divider(
                  height: ScreenUtil().setWidth(20),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
                  indent: 0,
                  endIndent: 0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('PublicKey:${keyValue['keypart']['publicKey']}',
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                        fontSize: ScreenUtil().setSp(32),
                      ),
                    ),),
                    SizedBox(width: 10,),
                    InkWell(
                      onTap: (){
                        Clipboard.setData(ClipboardData(text: keyValue['keypart']['publicKey']));
                        ToastUtils.show(S.of(context).copy);
                      },
                      child: Icon(
                        Icons.copy,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        size: ScreenUtil().setWidth(40),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        itemCount: miningList.length,
      ),
    );
  }
}
